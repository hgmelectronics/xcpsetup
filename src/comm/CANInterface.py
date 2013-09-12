'''
Created on Aug 03, 2013

@author: dbrunner
'''

from collections import namedtuple
import socket
import struct
import sys
import time

class CANID(object):
    '''
    CAN identifier
    '''
    
    def __init__(self, raw):
        self.raw = raw
    
    def getString(self):
        if self.raw & 0x80000000:
            return "x%x" % (self.raw ^ 0x80000000)
        else:
            return "%x" % self.raw

CANPacket = namedtuple('CANPacket', ['ident', 'data'])

class XCPSlaveCANAddr(object):
    '''
    XCP slave that exists on the CAN network.
    '''
    
    def __init__(self, cmdId, resId):
        self.cmdId = CANID(cmdId)
        self.resId = CANID(resId)
    
    def description(self):
        return "CAN %(cmd)s / %(res)s" % {'cmd': self.cmdId.getString(), 'res': self.resId.getString()}

class CANError(Exception):
    pass

class CANConnectFailed(Exception):
    pass

class SocketCANInterface(object):
    '''
    Interface using Linux SocketCAN
    '''
    
    def __init__(self, name):
        self._s = socket.socket(socket.AF_CAN, socket.SOCK_RAW, socket.CAN_RAW)
        self._slaveAddr = XCPSlaveCANAddr(0xFFFFFFFF, 0xFFFFFFFF)
        try:
            self._s.bind((name,))
        except socket.error:
            self._s.close()
            raise CANConnectFailed()
    
    def close(self):
        self._s.close()
    
    def _build_frame(self, data, ident):
        can_dlc = len(data)
        return struct.pack("=IB3x8s", ident, can_dlc, data.ljust(8, b'\x00'))
    
    def _decode_frame(self, frame):
        ident, dlc, data = struct.unpack("=IB3x8s", frame)
        return ident, data[0:dlc]
    
    def connect(self, address):
        self._slaveAddr = address
        filt = struct.pack("=II", self._slaveAddr.resId.raw, 0x9FFFFFFF)
        self._s.setsockopt(socket.SOL_CAN_RAW, socket.CAN_RAW_FILTER, filt)
        # Now flush any packets that were previously there
        self._s.settimeout(0.001)
        while 1:
            try:
                frame = self._s.recvfrom(16)[0]
            except socket.timeout:
                break
    
    def disconnect(self):
        self._slaveAddr = XCPSlaveCANAddr(0xFFFFFFFF, 0xFFFFFFFF)
        filt = struct.pack("=II", 0, 0)
        self._s.setsockopt(socket.SOL_CAN_RAW, socket.CAN_RAW_FILTER, filt)
       
    def _sendFrame(self, frame):
        self._s.setblocking(1)
        while 1:
            try:
                self._s.send(frame)
                break
            except OSError as err:
                if err.errno != 105:
                    raise
                else:
                    # Need to repeatedly try to send frames if ENOBUFS (105) returned - shortcoming of SocketCAN
                    time.sleep(0.010)
    
    def transmit(self, data):
        frame = self._build_frame(data, self._slaveAddr.cmdId.raw)
        self._sendFrame(frame)
    
    def transmitTo(self, data, ident):
        frame = self._build_frame(data, ident)
        self._sendFrame(frame)
        
    def receive(self, timeout):
        if self._slaveAddr.resId.raw == 0xFFFFFFFF:
            return []
        
        msgs = []
        endTime = time.time() + timeout
        
        while 1:
            if len(msgs):
                self._s.setblocking(0)
            else:
                newTimeout = endTime - time.time()
                if newTimeout < 0:
                    self._s.setblocking(0)
                else:
                    self._s.settimeout(newTimeout)
            
            try:
                frame = self._s.recvfrom(16)[0]
            except (socket.timeout, BlockingIOError):
                break
            
            ident, data = self._decode_frame(frame)
            if data[0] == 0xFF or data[0] == 0xFE:
                msgs.append(data)
        return msgs
    
    def receivePackets(self, timeout):
        packets = []
        endTime = time.time() + timeout
        
        while 1:
            if len(packets):
                self._s.setblocking(0)
            else:
                newTimeout = endTime - time.time()
                if newTimeout < 0:
                    self._s.setblocking(0)
                else:
                    self._s.settimeout(newTimeout)
            
            try:
                frame = self._s.recvfrom(16)[0]
            except (socket.timeout, BlockingIOError):
                break
            
            ident, data = self._decode_frame(frame)
            if data[0] == 0xFF or data[0] == 0xFE:
                packets.append(CANPacket(ident, data))
        return packets
