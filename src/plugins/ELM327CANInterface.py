'''
Created on Oct 5, 2013

@author: gcardwel,doug@doug-brunner.com

@summary: Driver plugin for ELM327 based interfaces.

@note:  The ELM327 uses an AT command set (as in Hayes modem) and as such is a half duplex interface to the CAN bus.
        Sending a frame means aborting reception, waiting for a prompt, setting CAN ID, then entering the frame to send.
@note:  ELM327s are also highly bandwidth limited; the commercially available interfaces use 115.2 kbps async serial to
        reach the ELM327 and send CAN data as hexadecimal. This means an 8 byte frame with 29 bit ID takes 25 bytes to
        send (including CR), so reading more than 460.8 frames/second must cause a buffer overrun. This is about 1/4 of
        the available bandwidth on a 250kbit CAN bus so appropriate filter settings are essential.
@note:  The driver uses a separate thread for reading the serial port or TCP socket, implemented by the function
        ELM327Read. It reads input, discards zero bytes (which ELM docs say can sometimes be inserted in error),
        packages completed lines that appear to be CAN frames and places them in the receive queue. Lines that are not
        packets and not empty are placed in the cmdResp queue, and command prompts from the ELM327 (indicating
        readiness to receive commands) set the promptReady Event (reception of other data clears this event).
        The main program thread implements reception by reading the Receive queue. Transmission and filter/baud setup
        are implemented by sending CR to abort receive, waiting for PromptReady, sending the requisite commands, waiting
        for a response if one is expected, then sending ATMA to resume reception if needed.
@note:  Interesting apparently undocumented feature of the ELM327: if an extra character is appended to a CAN frame to
        be sent (eg 0011228, CAN frame is 001122 extra char is 8) it takes it as a number of frames to read from the
        bus before stopping. If this is absent it will read from the bus indefinitely.
'''
from comm import CANInterface
import serial
import socket
import binascii
import time
import threading
import queue
import string
import struct

class Error(CANInterface.Error):
    pass

class SerialError(Error):
    def __init__(self, value=None):
        self._value = value
    def __str__(self):
        if self._value != None:
            return 'Serial communications error with ELM327: ' + repr(self._value)
        else:
            return 'Serial communications error with ELM327'

class UnexpectedResponse(Error):
    def __init__(self, value=None):
        self._value = value
    def __str__(self):
        if self._value != None:
            return 'Unexpected response to ' + repr(self._value) + ' from ELM327'
        else:
            return 'Unexpected response from ELM327'

class BadBitrate(Error):
    def __init__(self, value=None):
        self._value = value
    def __str__(self):
        if self._value != None:
            return 'ELM327 cannot generate bitrate ' + repr(self._value)
        else:
            return 'ELM327 cannot generate bitrate'

class SocketAsPort(object):
    '''
    Adapter for sockets that makes them look like serial ports; implements just the methods (and 'timeout' member)
    that are used in this program.
    '''
    _s = None
    _s_timeout = 0
    timeout = 0
    
    def __init__(self, socket):
        self._s = socket
    
    def _updateTimeout(self):
        if self._s_timeout != self.timeout:
            self._s.settimeout(self.timeout)
            self._s_timeout = self.timeout
    
    def read(self, bufsize):
        self._updateTimeout()
        return self._s.recv(bufsize)
    
    def write(self, data):
        self._updateTimeout()
        self._s.send(data)
    
    def close(self):
        self._s.close()
        
    def flushInput(self):
        self._s.settimeout(0)
        self._s_timeout = 0
        while 1:
            try:
                self._s.recv(4096)
            except socket.timeout:
                break
        self._updateTimeout()

def ELM327Read(port, receive, cmdResp, promptReady):
    '''
    Reads input, discards zero bytes (which ELM docs say can sometimes be inserted in error),
    packages completed lines that appear to be CAN frames and places them in the receive queue.
    Lines that are not packets and not empty are placed in the cmdResp queue, and command prompts from the ELM327
    (indicating readiness to receive commands) set the promptReady Event (reception of other data clears this event).
    
    Expects that ELM327 has already received ATL0 (disable linefeed), ATS0 (disable spaces), and ATH1 (enable headers).
    '''
    EOL=b'\r'
    PROMPT=b'>'
    
    def PutDiscard(queue, item):
        '''
        Put something on a queue and discard the oldest entry if it's full. Has a race (consumer might call get() just after this func
        finds the queue is full and we will needlessly discard an item) but this should only happen in the case of CPU starvation
        or data that's not relevant anyway.
        '''
        if queue.full():
            queue.get()
        queue.put(item)
    
    lineBuffer=b''
    while 1:
        dataRead = port.read(4096).translate(None, b'\0')
        # First find complete lines and process them
        if EOL in dataRead:
            linesRead = dataRead.splitLines(keepends=True)
            # Add in any buffered data from last iter
            linesRead[0] = lineBuffer + linesRead[0]
            # We now have a list of lines with the CR still on the end, except if the last is not complete it will not have one.
            if not EOL in linesRead[-1]:
                lineBuffer = linesRead[-1] # Stash an incomplete line in lineBuffer
                del linesRead[-1]
            for rawLine in linesRead:
                # Now parse the line
                line = rawLine.strip(EOL)
                # Is it empty?
                if len(line) == 0:
                    pass
                # Does it contain non-hex characters?
                elif any(x for x in line if x not in b'0123456789ABCDEF'):
                    # Command response or a packet received with errors
                    PutDiscard(cmdResp, line)
                else:
                    # Must be a valid received frame
                    if len(line) % 2 == 1:
                        idLen = 3
                        mask = 0
                    else:
                        idLen = 8
                        mask = 0x80000000
                    if len(line) >= idLen:
                        ident = int(line[0:idLen], 16)
                        data = binascii.unhexlify(line[idLen:])
                        return CANInterface.Packet(ident | mask, data)
                    else:
                        # Too short to be valid
                        PutDiscard(cmdResp, line)
        # Manage the promptReady Event; it's set if and only if there is an incomplete line consisting of a prompt.
        if lineBuffer == PROMPT:
            promptReady.set()
        else:
            promptReady.clear()

class ELM327CANInterface(CANInterface.Interface):
    '''
    Interface using ELM327 via serial. Spawns a thread that manages communications with the device; two queues allow it to communicate with the main thread.
    "Write" queue can request transmission of a frame, set baud rate, set filters, or request that monitoring stop.
    "Read" queue contains messages received from the bus.
    '''
    _QUEUE_MAX_SIZE = 16384
    _POSSIBLE_BAUDRATES = [115200, 500000, 38400, 9600, 230400, 460800, 57600, 28800, 14400, 4800, 2400, 1200]
    
    _slaveAddr = None
    _port = None
    _bitRate = None
    _txAddrStd = False
    _baudDivisor = None
    _baud87Mult = None
    _hasSetCSM0 = False
    _tcpTimeout = 1.0
    _serialTimeout = 0.1
    
    _receiveQueue = queue.Queue(_QUEUE_MAX_SIZE)
    _cmdRespQueue = queue.Queue(_QUEUE_MAX_SIZE)
    _promptReady = threading.Event()
    _readThread = None
    
    def __init__(self, parsedURL):
        if len(parsedURL.netloc):
            # If netloc is present, we're using a TCP connection
            addr = parsedURL.netloc.split(':')
            if len(addr) == 1:
                addr.append(35000)  # use default port
            elif len(addr) != 2:
                raise CANInterface.Error('Interface address invalid')
            s = socket.socket()
            s.create_connection(addr, self._tcpTimeout)
            self._port = SocketAsPort(s)
        else:
            port = serial.Serial(timeout=self._serialTimeout)
            if 'COM' in parsedURL.path:
                port.port = parsedURL.path.strip('COM')
            else:
                port.port = '/dev/' + parsedURL.path
            port.open()
            foundBaud = False
            for baudRate in self._POSSIBLE_BAUDRATES:
                port.baudrate = baudRate
                port.interCharTimeout = min(10/baudRate, 0.0001)
                
                # Try sending a CR, if we get a prompt then it's probably the right baudrate
                port.write(b'\r')
                response = port.read(1024)
                if len(response) == 0 or response[-1:] != b'>':
                    continue
                
                # Turn off echo, this also serves as a test to make sure we didn't randomly get a > at the end of some gibberish
                port.write(b'ATE0\r')
                response = port.read(2)
                if response != b'OK':
                    continue
                
                # If we made contact at baudrate 500k, we're done
                if baudRate == 500000:
                    foundBaud = True
                    break
                
                # Not at 500k, try to change ELM to that
                port.timeout = 1.28 # Maximum possible timeout for ELM327
                port.write(b'ATBRD8\r')
                response = port.read(2)
                if response == b'?':
                    # Device does not allow baudrate change, but we found its operating baudrate
                    foundBaud = True
                    break
                elif response == b'OK':
                    # Device allows baudrate change, try to switch to 500k
                    port.baudrate = 500000
                    port.flushInput()
                    response = port.read(6)
                    if response != 'ELM327':
                        # Baudrate switch unsuccessful, try to recover
                        port.baudrate = baudRate
                        port.write(b'\r')
                        response = port.read(1024)
                        if len(response) == 0 or response[-1:] != b'>':
                            raise UnexpectedResponse('switching baudrate')
                    
                    # Baudrate switched, send a CR to confirm we're on board
                    port.write(b'\r')
                    response = port.read(2)
                    if response != b'OK':
                        raise UnexpectedResponse('switching baudrate')
                    foundBaud = True
                    break
            
            if not foundBaud:
                raise SerialError('could not find baudrate')
            port.timeout = self._serialTimeout
            port.open()
                
            self._port = port
        
        self._port.timeout = self._intfcTimeout
        self._port.flushInput()
        
        self._readThread = threading.Thread(target=ELM327Read, args=(self._port, self._receiveQueue, self._cmdRespQueue, self._promptReady))
        
        self._runCmdWithCheck('ATWS', checkOK=False, closeOnFail=True) # Software reset
        self._runCmdWithCheck('ATE0', closeOnFail=True) # Turn off echo
        self._runCmdWithCheck('ATL0', closeOnFail=True) # Turn off newlines
        self._runCmdWithCheck('ATS0', closeOnFail=True) # Turn off spaces
        self._runCmdWithCheck('ATH1', closeOnFail=True) # Turn on headers
        self._runCmdWithCheck('ATSPB', closeOnFail=True) # Switch to protocol B (user defined)
        
        self._slaveAddr = CANInterface.XCPSlaveCANAddr(0xFFFFFFFF, 0xFFFFFFFF)
    
    def __enter__(self):
        return self

    def __exit__(self, type, value, traceback):
        self._port.close()
        
    def close(self):
        self._port.close()
    
    def setBaud(self, bitrate):
        if self._bitrate != bitrate:
            self._bitrate = bitrate
            self._calcBaudDivisor()
            self._setBaudIDType()
    
    def _calcBaudDivisor(self):
        baudTol = 0.001
        divisor = round(500000 / self._baudRate)
        if abs(500000 / divisor / self._baudRate - 1) > baudTol:
            divisor = round((500000 * 8 / 7) / self._baudRate)
            if abs((500000 * 8 / 7) / divisor / self._baudRate - 1) > baudTol:
                raise ValueError('')
            self._baudDivisor = divisor
            self._baud87Mult = True
        else:
            self._baudDivisor = divisor
            self._baud87Mult = False
    
    def _setBaudIDType(self):
        if self._txAddrStd:
            canOptions = 0xE0
        else:
            canOptions = 0x60
        if self._baud87Mult:
            canOptions |= 0x10;
        self._runCmdWithCheck('ATPB' + binascii.hexlify(bytearray([canOptions, self._baudDivisor])), closeOnFail=True)
        if not self._hasSetCSM0:
            self._runCmdWithCheck('ATCSM0', closeOnFail=True)
            self._hasSetCSM0 = True
            
    def _runCmdWithCheck(self, cmd, checkOK=True, closeOnFail=False):
        def failAction():
            if closeOnFail:
                self.close()
            raise UnexpectedResponse(cmd)
        
        if not self._promptReady.wait(self._intfcTimeout):
            failAction()
        self._port.write(cmd + b'\r')
        if not self._promptReady.wait(self._intfcTimeout):
            failAction()
        gotOK = False
        while 1:
            try:
                response = self._cmdRespQueue.get_nowait()
                if 'OK' in response:
                    gotOK = True
                elif response == cmd + b'\r':
                    response = self._cmdRespQueue.get_nowait()
                    if 'OK' in response:
                        gotOK = True
            except queue.Empty:
                break
        if not gotOK:
            failAction()
    
    def _buildFrame(self, data, ident):
        can_dlc = len(data)
        if ident & 0x80000000:
            setHeader = 'ATSH' + '{:08x}'.format(ident)
        else:
            setHeader = 'ATSH' + '{:03x}'.format(ident)
        
            header = binascii.hexlify()
            binstr = struct.pack(">I8s", ident, data.ljust(8, b'\x00'))[0:can_dlc+4]
        else:
            binstr = struct.pack(">H8s", ident, data.ljust(8, b'\x00'))[0:can_dlc+2]
        return binascii.hexlify(binstr)
    
    def _decode_frame(self, frame):
        binstr = binascii.unhexlify(frame)
        
        bytearray.fromhex(string)

        ident, dlc, data = struct.unpack("=IB3x8s", binstr)
        return ident, data[0:dlc]
    
    def _set_

    def connect(self, address, dumpTraffic):
        self._slaveAddr = address
        self._dumpTraffic = dumpTraffic

            # Now flush the receive buffer
        icsMsgs = (_ICSSpyMessage * 20000)()
        icsNMsgs = ctypes.c_int()
        icsNErrors = ctypes.c_int()

        res = self._dll.icsneoGetMessages(self._neoObject, icsMsgs, ctypes.byref(icsNMsgs), ctypes.byref(icsNErrors))
    
    def disconnect(self):
        self._slaveAddr = CANInterface.XCPSlaveCANAddr(0xFFFFFFFF, 0xFFFFFFFF)
        self._dumpTraffic = False
    
    def transmit(self, data):
        if self._dumpTraffic:
            print('TX ' + self._slaveAddr.cmdId.getString() + ' ' + CANInterface.getDataHexString(data))
        frame = self._build_frame(data, self._slaveAddr.cmdId.raw)
        res = self._dll.icsneoTxMessages(self._neoObject, ctypes.byref(frame), self._ICSNETID_HSCAN, 1)  # network ID 1 = HS CAN
        if res != 1:
            raise CANInterface.Error()
    
    def transmitTo(self, data, ident):
        if self._dumpTraffic:
            print('TX ' + CANInterface.ID(ident).getString() + ' ' + CANInterface.getDataHexString(data))
        frame = self._build_frame(data, ident)
        res = self._dll.icsneoTxMessages(self._neoObject, ctypes.byref(frame), self._ICSNETID_HSCAN, 1)  # network ID 1 = HS CAN
        if res != 1:
            raise CANInterface.Error()
        
    def receive(self, timeout):
        if self._slaveAddr.resId.raw == 0xFFFFFFFF:
            return []
        if self._slaveAddr.resId.isExt():
            self._run_cmd_check_ok('CRA' + '{:08x}'.format(self._slaveAddr.resId.raw & 0x1FFFFFFF))
        else:
            self._run_cmd_check_ok('CRA' + '{:03x}'.format(self._slaveAddr.resId.raw))
            
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
                ident, data = self._decode_frame(icsMsgs[iMsg])
                if len(data) > 0 and ident == self._slaveAddr.resId.raw and (data[0] == 0xFF or data[0] == 0xFE):
                    if self._dumpTraffic:
                        print('RX ' + self._slaveAddr.resId.getString() + ' ' + CANInterface.getDataHexString(data))
                    packets.append(data)
            
            if len(packets) != 0:
                break
        return packets
    
    def receivePackets(self, timeout, stdFilter = (0xFFF, 0x000), extFilter = (0x1FFFFFFF, 0x00000000)):
        self._run_cmd_check_ok('CF' + '{:03x}'.format(stdFilter[0]))
        self._run_cmd_check_ok('CM' + '{:03x}'.format(stdFilter[1]))
        self._run_cmd_check_ok('CF' + '{:08x}'.extFilter(stdFilter[0]))
        self._run_cmd_check_ok('CM' + '{:08x}'.extFilter(stdFilter[1]))
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
                ident, data = self._decode_frame(icsMsgs[iMsg])
                if len(data) > 0 and (data[0] == 0xFF or data[0] == 0xFE):
                    packets.append(CANInterface.Packet(ident, data))
                    if self._dumpTraffic:
                        print('RX ' + CANInterface.ID(ident).getString() + ' ' + CANInterface.getDataHexString(data))
            
            if len(packets) != 0:
                break
        return packets

CANInterface.addInterface("elm327", ELM327CANInterface)