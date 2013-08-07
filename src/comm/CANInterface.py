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
        if rawid & 0x80000000:
            return "x%x" % self.raw
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
        return "CAN %s / %s" % cmdId.getString() % resId.getString()

class CANError:
    pass

class CANConnectFailed:
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
        ident, data = struct.unpack("=I4x8s", frame)
        return ident, data
    
    def connect(self, address):
        self._slaveAddr = address
    
    def disconnect(self):
        self._slaveAddr = XCPSlaveCANAddr(0xFFFFFFFF, 0xFFFFFFFF)
    
    def transmit(self, data):
        frame = self._build_frame(data, self._slaveAddr.cmdId)
        self._s.send(frame)
    
    def transmitTo(self, data, ident):
        frame = self._build_frame(data, ident)
        self._s.send(frame)
    
    def receive(self, timeout):
        if self._slaveAddr.resID.raw == 0xFFFFFFFF:
            return []
        
        endTime = time.time() + timeout
        msgs = []
        while 1:
            newTimeout = endTime - time.time()
            if newTimeout < 0:
                newTimeout = 0
            self._s.settimeout(newTimeout)
            try:
                frame = self._s.recvfrom(16)[0]
            except socket.timeout:
                break
            ident, data = self._decode_frame(frame)
            if ident == self._slaveAddr.resId.raw:
                msgs.append(data)
        return msgs
    
    def receivePackets(self, timeout):
        endTime = time.time() + timeout
        packets = []
        while 1:
            newTimeout = endTime - time.time()
            if newTimeout < 0:
                newTimeout = 0
            self._s.settimeout(newTimeout)
            try:
                frame = self._s.recvfrom(16)[0]
            except socket.timeout:
                break
            ident, data = self._decode_frame(frame)
            packet = CANPacket(ident, data)
            packets.append(packet)
        return packets
