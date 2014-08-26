'''
Created on Oct 3, 2013

@author: gcardwel
'''

import socket
import struct
import time
from comm import CANInterface

def SocketCANSupported():
    return hasattr(socket, 'AF_CAN')

class SocketCANInterface(CANInterface.Interface):
    '''
    Interface using Linux SocketCAN
    '''
    
    def __init__(self, parsedURL):
        if not SocketCANSupported():
            raise CANInterface.InterfaceNotSupported('Socket module does not support CAN')
        
        self._s = socket.socket(socket.AF_CAN, socket.SOCK_RAW, socket.CAN_RAW)
        self._slaveAddr = CANInterface.XCPSlaveCANAddr(0xFFFFFFFF, 0xFFFFFFFF)
        self._dumpTraffic = False
        if parsedURL.netloc == None:
            dev = 'can0'
        else:
            dev = parsedURL.netloc
        try:
            self._s.bind((dev,))
        except socket.error:
            self._s.close()
            raise CANInterface.ConnectFailed()
        
    def __enter__(self):
        return self

    def __exit__(self, exitType, value, traceback):
        self._s.close()
        
    def close(self):
        self._s.close()
    
    def _buildFrame(self, data, ident):
        can_dlc = len(data)
        return struct.pack("=IB3x8s", ident, can_dlc, data.ljust(8, b'\x00'))
    
    def _decodeFrame(self, frame):
        ident, dlc, data = struct.unpack("=IB3x8s", frame)
        return CANInterface.Packet(ident, data[0:dlc])
    
    def connect(self, address, dumpTraffic = False):
        self._slaveAddr = address
        self._dumpTraffic = dumpTraffic
        filt = struct.pack("=II", self._slaveAddr.resId.raw, 0x9FFFFFFF)
        self._s.setsockopt(socket.SOL_CAN_RAW, socket.CAN_RAW_FILTER, filt)
        # Now flush any packets that were previously there
        self._s.settimeout(0.001)
        while 1:
            try:
                self._s.recvfrom(16)[0]
            except socket.timeout:
                break
    
    def disconnect(self):
        self._slaveAddr = CANInterface.XCPSlaveCANAddr(0xFFFFFFFF, 0xFFFFFFFF)
        self._dumpTraffic = False
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
        if self._dumpTraffic:
            print('TX ' + self._slaveAddr.cmdId.getString() + ' ' + CANInterface.getDataHexString(data))
        frame = self._buildFrame(data, self._slaveAddr.cmdId.raw)
        self._sendFrame(frame)
    
    def transmitTo(self, data, ident):
        if self._dumpTraffic:
            print('TX ' + CANInterface.ID(ident).getString() + ' ' + CANInterface.getDataHexString(data))
        frame = self._buildFrame(data, ident)
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
            
            packet = self._decodeFrame(frame)
            if packet.data[0] == 0xFF or packet.data[0] == 0xFE:
                msgs.append(packet.data)
                if self._dumpTraffic:
                    print('RX ' + self._slaveAddr.resId.getString() + ' ' + CANInterface.getDataHexString(packet.data))
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
            
            packet = self._decodeFrame(frame)
            if packet.data[0] == 0xFF or packet.data[0] == 0xFE:
                packets.append(packet)
                if self._dumpTraffic:
                    print('RX ' + CANInterface.ID(packet.ident).getString() + ' ' + CANInterface.getDataHexString(packet.data))
        return packets
    
    def setFilter(self, filt):
        rfilter = struct.pack('LL', filt[0], filt[1])
        self._s.setsockopt(socket.SOL_CAN_RAW, socket.CAN_RAW_FILTER, rfilter)

if SocketCANSupported():
    CANInterface.addInterface("socketcan", SocketCANInterface)
