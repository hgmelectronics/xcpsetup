'''
Created on Aug 03, 2013

@author: dbrunner
'''

from collections import namedtuple
import socket
import struct
import sys
import time
import ctypes
import array

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
    def __init__(self, value=None):
        self._value = value
    def __str__(self):
        return repr(self._value)

class CANConnectFailed(Exception):
    def __init__(self, value=None):
        self._value = value
    def __str__(self):
        return repr(self._value)

class CANInterfaceNotSupported(Exception):
    def __init__(self, value=None):
        self._value = value
    def __str__(self):
        return repr(self._value)

_ICS_TYPE_TABLE = [(1,'NeoVI Blue'),\
                   (4,'DW ValueCAN'),\
                   (8,'NeoVI Fire'),\
                   (16,'ValueCAN 3'),\
                   (32,'NeoVI Yellow'),\
                   (64,'NeoVI Red'),\
                   (128,'ECU'),\
                   (256,'IEVB'),
                   (512,'Pendant')]

def _ICSDevTypeStr(typeBits):
    typeStrs=[typeEntry[1] for typeEntry in _ICS_TYPE_TABLE if (typeEntry[0] & typeBits)]
    return ','.join(typeStrs)

class _ICSSpyMessage(ctypes.Structure):
    _fields_ = [('StatusBitField',ctypes.c_ulong),\
                ('StatusBitField2',ctypes.c_ulong),\
                ('TimeHardware',ctypes.c_ulong),\
                ('TimeHardware2',ctypes.c_ulong),\
                ('TimeSystem',ctypes.c_ulong),\
                ('TimeSystem2',ctypes.c_ulong),\
                ('TimeStampHardwareID',ctypes.c_ubyte),\
                ('TimeStampSystemID',ctypes.c_ubyte),\
                ('NetworkID',ctypes.c_ubyte),\
                ('NodeID',ctypes.c_ubyte),\
                ('Protocol',ctypes.c_ubyte),\
                ('MessagePieceID',ctypes.c_ubyte),\
                ('ColorID',ctypes.c_ubyte),\
                ('NumberBytesHeader',ctypes.c_ubyte),\
                ('NumberBytesData',ctypes.c_ubyte),\
                ('DescriptionID',ctypes.c_short),\
                ('ArbIDOrHeader',ctypes.c_long),\
                ('Data',ctypes.c_ubyte * 8),\
                ('AckBytes',ctypes.c_ubyte * 8),\
                ('Value',ctypes.c_float),\
                ('MiscData',ctypes.c_ubyte)]

class _ICSNeoDevice(ctypes.Structure):
    _fields_ = [('DeviceType',ctypes.c_ulong),\
                ('Handle',ctypes.c_int),\
                ('NumberOfClients',ctypes.c_int),\
                ('SerialNumber',ctypes.c_int),\
                ('MaxAllowedClients',ctypes.c_int)]

class _ICSCANSettings(ctypes.Structure):
    _fields_ = [('Mode',ctypes.c_ubyte),\
                ('SetBaudrate',ctypes.c_ubyte),\
                ('Baudrate',ctypes.c_ubyte),\
                ('NetworkType',ctypes.c_ubyte),\
                ('TqSeg1',ctypes.c_ubyte),\
                ('TqSeg2',ctypes.c_ubyte),\
                ('TqProp',ctypes.c_ubyte),\
                ('TqSync',ctypes.c_ubyte),\
                ('BRP',ctypes.c_ushort),\
                ('auto_baud',ctypes.c_ushort)]

class _ICSSVCAN3Settings(ctypes.Structure):
    _fields_ = [('can1',_ICSCANSettings),\
                ('can2',_ICSCANSettings),\
                ('network_enables',ctypes.c_ushort),\
                ('network_enabled_on_boot',ctypes.c_ushort),\
                ('iso15765_separation_time_offset',ctypes.c_ushort),\
                ('perf_en',ctypes.c_ushort),\
                ('misc_io_initial_ddr',ctypes.c_ushort),\
                ('misc_io_initial_latch',ctypes.c_ushort),\
                ('misc_io_report_period',ctypes.c_ushort),\
                ('misc_io_on_report_events',ctypes.c_ushort)]

def MakeInterface(name):
    if name == 'ICS':
        return ICSCANInterface()
    else:
        try:
            return SocketCANInterface(name)
        except CANInterfaceNotSupported: # doesn't seem to be a Linux system with SocketCAN; try Windows
            return ICSCANInterface()

class ICSCANInterface(object):
    '''
    Interface using ICS NeoVI DLL
    '''

    _ICSNETID_HSCAN = 1
    _BITRATE = 250000

    def __init__(self):
        if not hasattr(ctypes, 'windll'):
            raise CANInterfaceNotSupported('Not a Windows system')
        
        try:
            self._dll = ctypes.windll.icsneo40
        except OSError:
            raise CANConnectFailed('Loading icsneo40.dll failed')
        
        neoDevices = (_ICSNeoDevice * 1)()
        self._neoObject = None

        nNeoDevices = ctypes.c_int(1)
        findResult = self._dll.icsneoFindNeoDevices(0xFFFFFFFF, neoDevices, ctypes.byref(nNeoDevices))
        if findResult != 1:
            raise CANConnectFailed('Finding ICS devices failed')

        if nNeoDevices.value < 1:
            raise CANConnectFailed('No ICS devices found')

        print('Connecting to ' + _ICSDevTypeStr(neoDevices[0].DeviceType))

        netIDs = (ctypes.c_ubyte * 64)()
        for i in range(len(netIDs)):
            netIDs[i] = i
        tempNeoObject = ctypes.c_int()
        openResult = self._dll.icsneoOpenNeoDevice(ctypes.byref(neoDevices[0]), ctypes.byref(tempNeoObject), netIDs, 1, 0)
        if openResult != 1:
            raise CANConnectFailed('Opening ICS device failed')
        self._neoObject = tempNeoObject.value

        setBitrateResult = self._dll.icsneoSetBitRate(self._neoObject, self._BITRATE, self._ICSNETID_HSCAN)
        if setBitrateResult != 1:
            raise CANConnectFailed()

        self._slaveAddr = XCPSlaveCANAddr(0xFFFFFFFF, 0xFFFFFFFF)

    def __enter__(self):
        return self

    def __exit__(self, type, value, traceback):
        if self._neoObject != None:
            numOfErrors = ctypes.c_int()
            self._dll.icsneoClosePort(self._neoObject, ctypes.byref(numOfErrors))
            self._dll.icsneoFreeObject(self._neoObject)
    
    def close(self):
        if self._neoObject != None:
            numOfErrors = ctypes.c_int()
            self._dll.icsneoClosePort(self._neoObject, ctypes.byref(numOfErrors))
            self._dll.icsneoFreeObject(self._neoObject)
    
    def _build_frame(self, data, ident):
        frame = _ICSSpyMessage()
        if ident & 0x80000000:
            frame.StatusBitField = 0x00000004  # Extended frame
        else:
            frame.StatusBitField = 0x00000000
        frame.StatusBitField2 = 0
        frame.NumberBytesData = len(data)
        frame.ArbIDOrHeader = ident & 0x1FFFFFFF
        for i in range(len(data)):
            frame.Data[i] = data[i]
        return frame
    
    def _decode_frame(self, frame):
        if frame.StatusBitField & 0x00000001:
            return 0x20000000, b''

        if frame.StatusBitField & 0x00000004:   # extended ID?
            ident = frame.ArbIDOrHeader | 0x80000000
        else:
            ident = frame.ArbIDOrHeader

        data = array.array('B', frame.Data).tostring()
        
        return ident, data[0:frame.NumberBytesData]
    
    def connect(self, address):
        self._slaveAddr = address

            # Now flush the receive buffer
        icsMsgs = (_ICSSpyMessage * 20000)()
        icsNMsgs = ctypes.c_int()
        icsNErrors = ctypes.c_int()

        res = self._dll.icsneoGetMessages(self._neoObject, icsMsgs, ctypes.byref(icsNMsgs), ctypes.byref(icsNErrors))
    
    def disconnect(self):
        self._slaveAddr = XCPSlaveCANAddr(0xFFFFFFFF, 0xFFFFFFFF)
    
    def transmit(self, data):
        frame = self._build_frame(data, self._slaveAddr.cmdId.raw)
        res = self._dll.icsneoTxMessages(self._neoObject, ctypes.byref(frame), self._ICSNETID_HSCAN, 1) # network ID 1 = HS CAN
        if res != 1:
            raise CANError()
    
    def transmitTo(self, data, ident):
        frame = self._build_frame(data, ident)
        res = self._dll.icsneoTxMessages(self._neoObject, ctypes.byref(frame), self._ICSNETID_HSCAN, 1) # network ID 1 = HS CAN
        if res != 1:
            raise CANError()
        
    def receive(self, timeout):
        if self._slaveAddr.resId.raw == 0xFFFFFFFF:
            return []
            
        packets = []

        if timeout != 0:
            endTime = time.time() + timeout
        else:
            endTime = None

        while 1:
            if endTime != None:
                newTimeout = int((endTime - time.time()) * 1000)
                if newTimeout > 0:
                    self._dll.icsneoWaitForRxMessagesWithTimeOut(self._neoObject, newTimeout)
                else:
                    break
            else:
                endTime = 0 # allow one pass, then return on the next

            icsMsgs = (_ICSSpyMessage * 20000)()
            icsNMsgs = ctypes.c_int()
            icsNErrors = ctypes.c_int()

            res = self._dll.icsneoGetMessages(self._neoObject, icsMsgs, ctypes.byref(icsNMsgs), ctypes.byref(icsNErrors))
            if res != 1:
                raise CANError()

            for iMsg in range(icsNMsgs.value):
                ident, data = self._decode_frame(icsMsgs[iMsg])
                if len(data) > 0 and ident == self._slaveAddr.resId.raw and (data[0] == 0xFF or data[0] == 0xFE):
                    packets.append(data)
            
            if len(packets) != 0:
                break
        return packets
    
    def receivePackets(self, timeout):
        packets = []

        if timeout != 0:
            endTime = time.time() + timeout
        else:
            endTime = None

        while 1:
            if endTime != None:
                newTimeout = int((endTime - time.time()) * 1000)
                if newTimeout > 0:
                    self._dll.icsneoWaitForRxMessagesWithTimeOut(self._neoObject, newTimeout)
                else:
                    break
            else:
                endTime = 0 # allow one pass, then return on the next

            icsMsgs = (_ICSSpyMessage * 20000)()
            icsNMsgs = ctypes.c_int()
            icsNErrors = ctypes.c_int()

            res = self._dll.icsneoGetMessages(self._neoObject, icsMsgs, ctypes.byref(icsNMsgs), ctypes.byref(icsNErrors))
            if res != 1:
                raise CANError()

            for iMsg in range(icsNMsgs.value):
                ident, data = self._decode_frame(icsMsgs[iMsg])
                if len(data) > 0 and (data[0] == 0xFF or data[0] == 0xFE):
                    packets.append(CANPacket(ident, data))
            
            if len(packets) != 0:
                break
        return packets

class SocketCANInterface(object):
    '''
    Interface using Linux SocketCAN
    '''
    
    def __init__(self, name):
        if not hasattr(socket, 'AF_CAN'):
            raise CANInterfaceNotSupported('Socket module does not support CAN')
        
        self._s = socket.socket(socket.AF_CAN, socket.SOCK_RAW, socket.CAN_RAW)
        self._slaveAddr = XCPSlaveCANAddr(0xFFFFFFFF, 0xFFFFFFFF)
        if name == None:
            dev = 'can0'
        else:
            dev = name
        try:
            self._s.bind((dev,))
        except socket.error:
            self._s.close()
            raise CANConnectFailed()
        
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
