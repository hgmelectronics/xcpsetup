'''
Created on Oct 3, 2013

@author: gcardwel
'''

import array
from collections import namedtuple
import ctypes
import socket
import struct
import sys
import time
from . import CANInterface


class SocketCANInterface(CANInterface.Interface):
    '''
    Interface using Linux SocketCAN
    '''
    
    def __init__(self, name):
        if not hasattr(socket, 'AF_CAN'):
            raise CANInterface.InterfaceNotSupported('Socket module does not support CAN')
        
        self._s = socket.socket(socket.AF_CAN, socket.SOCK_RAW, socket.CAN_RAW)
        self._slaveAddr = CANInterface.XCPSlaveCANAddr(0xFFFFFFFF, 0xFFFFFFFF)
        if name == None:
            dev = 'can0'
        else:
            dev = name
        try:
            self._s.bind((dev,))
        except socket.error:
            self._s.close()
            raise CANInterface.ConnectFailed()
        
    def __enter__(self):
        return self

    def __exit__(self, type, value, traceback):
        self._s.close()
        
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
        self._slaveAddr = CANInterface.XCPSlaveCANAddr(0xFFFFFFFF, 0xFFFFFFFF)
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
                packets.append(CANInterface.CANPacket(ident, data))
        return packets
