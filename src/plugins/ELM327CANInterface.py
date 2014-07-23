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
from collections import namedtuple

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

def identToHex(ident):
    if ident & 0x80000000:
        return b'{:08x}'.format(ident)
    else:
        return b'{:03x}'.format(ident)
        
class ELM327CANInterface(CANInterface.Interface):
    BitrateTXType = namedtuple('BitrateTXType', ['bitrate', 'txAddrStd'])
    '''
    Interface using ELM327 via serial. Spawns a thread that manages communications with the device; two queues allow it to communicate with the main thread.
    "Write" queue can request transmission of a frame, set baud rate, set filters, or request that monitoring stop.
    "Read" queue contains messages received from the bus.
    '''
    _QUEUE_MAX_SIZE = 16384
    _POSSIBLE_BAUDRATES = [115200, 500000, 38400, 9600, 230400, 460800, 57600, 28800, 14400, 4800, 2400, 1200]
    
    _slaveAddr = None
    _port = None
    _bitrateTXType = BitrateTXType(None, False)
    _cfgdBitrateTXType = BitrateTXType(None, False)
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
            port = serial.Serial()
            if 'COM' in parsedURL.path:
                port.port = parsedURL.path.strip('COM')
            else:
                port.port = '/dev/' + parsedURL.path
            port.open()
            foundBaud = False
            for baudRate in self._POSSIBLE_BAUDRATES:
                port.baudrate = baudRate
                port.interCharTimeout = min(10/baudRate, 0.0001)
                port.timeout = 0.1
                
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
                    if response != b'ELM327':
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
        
        self._runCmdWithCheck(b'ATWS', checkOK=False, closeOnFail=True) # Software reset
        self._runCmdWithCheck(b'ATE0', closeOnFail=True) # Turn off echo
        self._runCmdWithCheck(b'ATL0', closeOnFail=True) # Turn off newlines
        self._runCmdWithCheck(b'ATS0', closeOnFail=True) # Turn off spaces
        self._runCmdWithCheck(b'ATH1', closeOnFail=True) # Turn on headers
        self._runCmdWithCheck(b'ATSPB', closeOnFail=True) # Switch to protocol B (user defined)
        
        self._slaveAddr = CANInterface.XCPSlaveCANAddr(0xFFFFFFFF, 0xFFFFFFFF)
    
    def __enter__(self):
        return self

    def __exit__(self, exitType, value, traceback):
        self._port.close()
        
    def close(self):
        self._port.close()
    
    def setBaud(self, bitrate):
        self._bitrateTXType.bitrate = bitrate
        self._updateBitrateTXType()
    
    def _setTXTypeByIdent(self, ident):
        if ident & 0x80000000:
            self._bitrateTXType.txAddrStd = False
        else:
            self._bitrateTXType.txAddrStd = True
    
    def _updateBitrateTXType(self):
        if self._bitrateTXType != self._cfgdBitrateTXType:
            if self._bitrateTXType.bitrate != self._cfgdBitrateTXType.bitrate:
                self._calcBaudDivisor()
            self._setBitrateTXType()
            self._cfgdBitrateTXType = self._bitrateTXType
    
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
    
    def _setBitrateTXType(self):
        if self._txAddrStd:
            canOptions = 0xE0
        else:
            canOptions = 0x60
        if self._baud87Mult:
            canOptions |= 0x10;
        self._runCmdWithCheck(b'ATPB' + binascii.hexlify(bytearray([canOptions, self._baudDivisor])), closeOnFail=True)
        if not self._hasSetCSM0:
            self._runCmdWithCheck(b'ATCSM0', closeOnFail=True)
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
        setHeader = b'ATSH' + identToHex(ident) + b'\r'
        dataHex = binascii.hexlify(data)
        return setHeader + dataHex + b'\r'

    def connect(self, address, dumpTraffic):
        self._slaveAddr = address
        self._dumpTraffic = dumpTraffic
        self._runCmdWithCheck(b'ATCRA' + identToHex(address.resId.raw))
        self._runCmdWithCheck(b'ATMA', checkOK=False)
    
    def disconnect(self):
        self._slaveAddr = CANInterface.XCPSlaveCANAddr(0xFFFFFFFF, 0xFFFFFFFF)
        self._port.write(b'\r')
        self._runCmdWithCheck(b'ATCRA')
        self._dumpTraffic = False
    
    def transmit(self, data):
        if self._dumpTraffic:
            print('TX ' + self._slaveAddr.cmdId.getString() + ' ' + CANInterface.getDataHexString(data))
        frame = self._buildFrame(data, self._slaveAddr.cmdId.raw)
        self._port.write(b'\r')
        self._setTXTypeByIdent(self._slaveAddr.cmdId.raw)
        self._updateBitrateTXType()
        if not self._promptReady.wait(self._intfcTimeout):
            raise UnexpectedResponse('abort RX for transmission')
        self._port.write(frame)
    
    def transmitTo(self, data, ident):
        if self._dumpTraffic:
            print('TX ' + CANInterface.ID(ident).getString() + ' ' + CANInterface.getDataHexString(data))
        frame = self._buildFrame(data, ident)
        self._port.write(b'\r')
        self._setTXTypeByIdent(ident)
        self._updateBitrateTXType()
        if not self._promptReady.wait(self._intfcTimeout):
            raise UnexpectedResponse('abort RX for transmission')
        self._port.write(frame)
        
    def receive(self, timeout):
        if self._slaveAddr.resId.raw == 0xFFFFFFFF:
            return []
        
        msgs = []
        endTime = time.time() + timeout
        
        while 1:
            try:
                if len(msgs):
                    packet = self._receiveQueue.get_nowait()
                else:
                    newTimeout = endTime - time.time()
                    if newTimeout < 0:
                        packet = self._receiveQueue.get_nowait()
                    else:
                        packet = self._receiveQueue.get(timeout=newTimeout)
            except queue.Empty:
                break
            
            if packet.ident != self._slaveAddr.resId.raw:
                raise UnexpectedResponse('filtered data read')
            
            if packet.data[0] == 0xFF or packet.data[0] == 0xFE:
                msgs.append(packet.data)
                if self._dumpTraffic:
                    print('RX ' + self._slaveAddr.resId.getString() + ' ' + CANInterface.getDataHexString(packet.data))
        return msgs
    
    def receivePackets(self, timeout):
        packets = []
        endTime = time.time() + timeout
        
        while 1:
            try:
                if len(packets):
                    packet = self._receiveQueue.get_nowait()
                else:
                    newTimeout = endTime - time.time()
                    if newTimeout < 0:
                        packet = self._receiveQueue.get_nowait()
                    else:
                        packet = self._receiveQueue.get(timeout=newTimeout)
            except queue.Empty:
                break
            
            if packet.data[0] == 0xFF or packet.data[0] == 0xFE:
                packets.append(packet)
                if self._dumpTraffic:
                    print('RX ' + CANInterface.ID(packet.ident).getString() + ' ' + CANInterface.getDataHexString(packet.data))
        return packets

CANInterface.addInterface("elm327", ELM327CANInterface)