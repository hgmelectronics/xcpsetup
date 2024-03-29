'''
Created on Oct 3, 2013

@author: gcardwel
'''
import array
import ctypes
import sys
import time
from comm import CANInterface

_ICS_TYPE_TABLE = [(0x001, 'NeoVI Blue'), \
                   (0x004, 'DW ValueCAN'), \
                   (0x008, 'NeoVI Fire'), \
                   (0x010, 'ValueCAN 3'), \
                   (0x020, 'NeoVI Yellow'), \
                   (0x040, 'NeoVI Red'), \
                   (0x080, 'ECU'), \
                   (0x100, 'IEVB'),
                   (0x200, 'Pendant')]

_ICS_TYPE_STRING_MASKS = {'neovi-blue':     0x001,
                          'dw-valuecan':    0x004,
                          'neovi-fire':     0x008,
                          'valuecan-3':     0x010,
                          'neovi-yellow':   0x020,
                          'neovi-red':      0x040,
                          'ecu':            0x080,
                          'ievb':           0x100,
                          'pendant':        0x200,
                          'neovi':          0x069,
                          'valuecan':       0x014,
                          'vcan':           0x014,
                          'all':            0x3FF,
                          'any':            0x3FF,
                          None:             0x3FF
                          }

_ICS_NET_IDS = {
                'hscan': 1,
                'mscan': 2,
                'swcan': 3,
                'lsftcan': 4,
                'hscan2': 42,
                'hscan3': 44
                }

def _ICSDevTypeStr(typeBits):
    typeStrs = [typeEntry[1] for typeEntry in _ICS_TYPE_TABLE if (typeEntry[0] & typeBits)]
    return ','.join(typeStrs)

class _ICSSpyMessage(ctypes.Structure):
    _fields_ = [('StatusBitField', ctypes.c_ulong), \
                ('StatusBitField2', ctypes.c_ulong), \
                ('TimeHardware', ctypes.c_ulong), \
                ('TimeHardware2', ctypes.c_ulong), \
                ('TimeSystem', ctypes.c_ulong), \
                ('TimeSystem2', ctypes.c_ulong), \
                ('TimeStampHardwareID', ctypes.c_ubyte), \
                ('TimeStampSystemID', ctypes.c_ubyte), \
                ('NetworkID', ctypes.c_ubyte), \
                ('NodeID', ctypes.c_ubyte), \
                ('Protocol', ctypes.c_ubyte), \
                ('MessagePieceID', ctypes.c_ubyte), \
                ('ColorID', ctypes.c_ubyte), \
                ('NumberBytesHeader', ctypes.c_ubyte), \
                ('NumberBytesData', ctypes.c_ubyte), \
                ('DescriptionID', ctypes.c_short), \
                ('ArbIDOrHeader', ctypes.c_long), \
                ('Data', ctypes.c_ubyte * 8), \
                ('AckBytes', ctypes.c_ubyte * 8), \
                ('Value', ctypes.c_float), \
                ('MiscData', ctypes.c_ubyte)]

class _ICSNeoDevice(ctypes.Structure):
    _fields_ = [('DeviceType', ctypes.c_ulong), \
                ('Handle', ctypes.c_int), \
                ('NumberOfClients', ctypes.c_int), \
                ('SerialNumber', ctypes.c_int), \
                ('MaxAllowedClients', ctypes.c_int)]

class _ICSCANSettings(ctypes.Structure):
    _fields_ = [('Mode', ctypes.c_ubyte), \
                ('SetBaudrate', ctypes.c_ubyte), \
                ('Baudrate', ctypes.c_ubyte), \
                ('NetworkType', ctypes.c_ubyte), \
                ('TqSeg1', ctypes.c_ubyte), \
                ('TqSeg2', ctypes.c_ubyte), \
                ('TqProp', ctypes.c_ubyte), \
                ('TqSync', ctypes.c_ubyte), \
                ('BRP', ctypes.c_ushort), \
                ('auto_baud', ctypes.c_ushort)]

class _ICSSVCAN3Settings(ctypes.Structure):
    _fields_ = [('can1', _ICSCANSettings), \
                ('can2', _ICSCANSettings), \
                ('network_enables', ctypes.c_ushort), \
                ('network_enabled_on_boot', ctypes.c_ushort), \
                ('iso15765_separation_time_offset', ctypes.c_ushort), \
                ('perf_en', ctypes.c_ushort), \
                ('misc_io_initial_ddr', ctypes.c_ushort), \
                ('misc_io_initial_latch', ctypes.c_ushort), \
                ('misc_io_report_period', ctypes.c_ushort), \
                ('misc_io_on_report_events', ctypes.c_ushort)]

def ICSSupported():
    if not hasattr(ctypes, 'windll'):
        return False
    
    try:
        ctypes.windll.icsneo40
    except OSError:
        return False
    
    return True

class ICSCANInterface(CANInterface.Interface):
    '''
    Interface using ICS NeoVI DLL
    
    URI scheme: ics:<type-string>/<index>/<netid>
    '''


    def __init__(self, parsedURL):
        self._icsNetId = None
        self._cfgdBitrate = None
        self._dumpTraffic = False
        self._filter = 0x00000000
        self._mask = 0x00000000
        if not hasattr(ctypes, 'windll'):
            raise CANInterface.InterfaceNotSupported('Not a Windows system')
        
        try:
            self._dll = ctypes.windll.icsneo40
        except OSError:
            raise CANInterface.InterfaceNotSupported('Loading icsneo40.dll failed')
        
        neoDevices = (_ICSNeoDevice * 64)()
        self._neoObject = None

        nNeoDevices = ctypes.c_int(64)
        findResult = self._dll.icsneoFindNeoDevices(0xFFFFFFFF, neoDevices, ctypes.byref(nNeoDevices))
        if findResult != 1:
            raise CANInterface.ConnectFailed('Finding ICS devices failed')
        
        splitPath = parsedURL.path.split('/')
        if len(splitPath) != 3:
            raise CANInterface.ConnectFailed('Invalid ICS device path \'' + parsedURL.path + '\'; path is ics:<devtype>/<dev-index>/<net-id>')
        try:
            devTypeMask = _ICS_TYPE_STRING_MASKS[splitPath[0]]
        except KeyError:
            raise CANInterface.ConnectFailed('Invalid ICS device type \'' + splitPath[0] + '\'')
        try:
            devIdx = int(splitPath[1])
        except ValueError:
            raise CANInterface.ConnectFailed('Invalid ICS device index \'' + splitPath[1] + '\'')
        try:
            self._icsNetId = _ICS_NET_IDS[splitPath[2]]
        except KeyError:
            raise CANInterface.ConnectFailed('Invalid ICS net id \'' + splitPath[2])
        
        devOfType = [dev for dev in neoDevices[0:nNeoDevices.value] if dev.DeviceType & devTypeMask]
        if len(devOfType) < devIdx + 1:
            raise CANInterface.ConnectFailed('ICS device of type \'' + splitPath[0] + '\', index ' + str(devIdx) + ' not found')

        sys.stderr.write('Connecting to ' + _ICSDevTypeStr(neoDevices[0].DeviceType) + ' #' + str(devIdx) + '\n')

        netIDs = (ctypes.c_ubyte * 64)()
        for i in range(len(netIDs)):
            netIDs[i] = i
        tempNeoObject = ctypes.c_int()
        openResult = self._dll.icsneoOpenNeoDevice(ctypes.byref(devOfType[devIdx]), ctypes.byref(tempNeoObject), netIDs, 1, 0)
        if openResult != 1:
            raise CANInterface.ConnectFailed('Opening ICS device failed')
        self._neoObject = tempNeoObject.value
        
        self.setBitrate(CANInterface.URLBitrate(parsedURL))
        
        self._slaveAddr = CANInterface.XCPSlaveCANAddr(0xFFFFFFFF, 0xFFFFFFFF)

    def __enter__(self):
        return self

    def __exit__(self, exitType, value, traceback):
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
        if frame.StatusBitField & 0x00000001 or frame.StatusBitField & 0x00000002:
            return 0x20000000, b''

        if frame.StatusBitField & 0x00000004:  # extended ID?
            ident = frame.ArbIDOrHeader | 0x80000000
        else:
            ident = frame.ArbIDOrHeader

        data = array.array('B', frame.Data).tostring()
        
        return ident, data[0:frame.NumberBytesData]
    
    def setBitrate(self, bitrate):
        print('Setting bitrate ' + str(bitrate))
        setBitrateResult = self._dll.icsneoSetBitRate(self._neoObject, bitrate, self._icsNetId)
        if setBitrateResult != 1:
            raise CANInterface.Error('Setting bitrate failed')
        else:
            self._cfgdBitrate = bitrate
    
    def connect(self, address, dumpTraffic):
        self._slaveAddr = address
        self._dumpTraffic = dumpTraffic

            # Now flush the receive buffer
        icsMsgs = (_ICSSpyMessage * 20000)()
        icsNMsgs = ctypes.c_int()
        icsNErrors = ctypes.c_int()

        self._dll.icsneoGetMessages(self._neoObject, icsMsgs, ctypes.byref(icsNMsgs), ctypes.byref(icsNErrors))
    
    def disconnect(self):
        self._slaveAddr = CANInterface.XCPSlaveCANAddr(0xFFFFFFFF, 0xFFFFFFFF)
        self._dumpTraffic = False
    
    def transmit(self, data):
        assert self._cfgdBitrate != None
        
        if self._dumpTraffic:
            print('TX ' + self._slaveAddr.cmdId.getString() + ' ' + CANInterface.getDataHexString(data))
        frame = self._build_frame(data, self._slaveAddr.cmdId.raw)
        res = self._dll.icsneoTxMessages(self._neoObject, ctypes.byref(frame), self._icsNetId, 1)
        if res != 1:
            raise CANInterface.Error()
    
    def transmitTo(self, data, ident):
        assert self._cfgdBitrate != None
        
        if self._dumpTraffic:
            print('TX ' + CANInterface.ID(ident).getString() + ' ' + CANInterface.getDataHexString(data))
        frame = self._build_frame(data, ident)
        res = self._dll.icsneoTxMessages(self._neoObject, ctypes.byref(frame), self._icsNetId, 1)
        if res != 1:
            raise CANInterface.Error()
        
    def receive(self, timeout):
        assert self._cfgdBitrate != None
        
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
                endTime = 0  # allow one pass, then return on the next

            icsMsgs = (_ICSSpyMessage * 20000)()
            icsNMsgs = ctypes.c_int()
            icsNErrors = ctypes.c_int()

            res = self._dll.icsneoGetMessages(self._neoObject, icsMsgs, ctypes.byref(icsNMsgs), ctypes.byref(icsNErrors))
            if res != 1:
                raise CANInterface.Error()

            for iMsg in range(icsNMsgs.value):
                if icsMsgs[iMsg].NetworkID == self._icsNetId:
                    ident, data = self._decode_frame(icsMsgs[iMsg])
                    if len(data) > 0 and ident == self._slaveAddr.resId.raw and (data[0] == 0xFF or data[0] == 0xFE):
                        if self._dumpTraffic:
                            print('RX ' + self._slaveAddr.resId.getString() + ' ' + CANInterface.getDataHexString(data))
                        packets.append(data)
            
            if len(packets) != 0:
                break
        return packets
    
    def receivePackets(self, timeout):
        assert self._cfgdBitrate != None
        
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
                endTime = 0  # allow one pass, then return on the next

            icsMsgs = (_ICSSpyMessage * 20000)()
            icsNMsgs = ctypes.c_int()
            icsNErrors = ctypes.c_int()

            res = self._dll.icsneoGetMessages(self._neoObject, icsMsgs, ctypes.byref(icsNMsgs), ctypes.byref(icsNErrors))
            if res != 1:
                raise CANInterface.Error()

            for iMsg in range(icsNMsgs.value):
                if icsMsgs[iMsg].NetworkID == self._icsNetId:
                    ident, data = self._decode_frame(icsMsgs[iMsg])
                    if (ident & self._mask) == self._filter and len(data) > 0 and (data[0] == 0xFF or data[0] == 0xFE):
                        packets.append(CANInterface.Packet(ident, data))
                        if self._dumpTraffic:
                            print('RX ' + CANInterface.ID(ident).getString() + ' ' + CANInterface.getDataHexString(data))
            
            if len(packets) != 0:
                break
        return packets
    
    def setFilter(self, filt):
        self._filter = filt[0]
        self._mask = filt[1]

if ICSSupported():
    CANInterface.addInterface("ics", ICSCANInterface)
