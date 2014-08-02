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
        ELM327IO. It reads input, discards zero bytes (which ELM docs say can sometimes be inserted in error),
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
import sys
if not '..' in sys.path:
    sys.path.append('..')
from comm import CANInterface
#from ..comm import CANInterface FIXME need to find out if we are in plugins namespace
import serial
import socket
import binascii
import time
import threading
import queue

LOGGING=True

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

class BadFilter(Error):
    def __init__(self, value=None):
        self._value = value
    def __str__(self):
        if self._value != None:
            return 'Attempt to set invalid filter ' + repr(self._value)
        else:
            return 'Attempt to set invalid filter'

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

class LoggingPort(serial.Serial):
    def __init__(self, *args, **kwargs):
        super().__init__(*args, **kwargs)
    def _timeStr(self):
        return str(time.time())
    def open(self, *args, **kwargs):
        result = super().open(*args, **kwargs)
        print(self._timeStr() + ' OPEN')
        return result
    def close(self, *args, **kwargs):
        result = super().close(*args, **kwargs)
        print(self._timeStr() + ' CLOSE')
        return result
    def read(self, *args, **kwargs):
        result = super().read(*args, **kwargs)
        print(self._timeStr() + ' RD ' + repr(result))
        return result
    def write(self, data):
        print(self._timeStr() + ' WR ' + repr(data))
        return super().write(data)

def PutDiscard(queue, item):
    '''
    Put something on a queue and discard the oldest entry if it's full. Has a race (consumer might call get() just after this func
    finds the queue is full and we will needlessly discard an item) but this should only happen in the case of CPU starvation
    or data that's not relevant anyway.
    '''
    if queue.full():
        queue.get()
    queue.put(item)

def ELM327IO(port, receive, transmit, cmdResp, promptReady, terminate):
    '''
    Reads input, discards zero bytes (which ELM docs say can sometimes be inserted in error),
    packages completed lines that appear to be CAN frames and places them in the receive queue.
    Lines that are not packets and not empty are placed in the cmdResp queue, and command prompts from the ELM327
    (indicating readiness to receive commands) set the promptReady Event (reception of other data clears this event).
    
    Monitors the transmit queue for packets to be sent
    
    Expects that ELM327 has already received ATL0 (disable linefeed), ATS0 (disable spaces), and ATH1 (enable headers).
    '''
    EOL=b'\r'
    PROMPT=b'>'
    TICKTIME=0.001 # Time between polls of the serial port - need to poll because select() not available to wait on both transmit queue and serial receive on Windows
    
    lineBuffer=b''
    while 1:
        if terminate.is_set():
            if LOGGING:
                print(str(time.time()) + ' ELM327IO(): terminate set')
            port.close()
            return
        
        if LOGGING:
            print(str(time.time()) + ' ELM327IO(): check read')
        try:
            dataRead = port.read(port.inWaiting()).translate(None, b'\0')
        except serial.serialutil.SerialException as exc:
            if str(exc) == 'Attempting to use a port that is not open':
                return  # Port was closed in main thread, gracefully terminate
            else:
                raise
        # First find complete lines and process them
        if EOL in dataRead:
            linesRead = dataRead.splitlines(keepends=True)
            # Add in any buffered data from last iter
            linesRead[0] = lineBuffer + linesRead[0]
            # We now have a list of lines with the CR still on the end, except if the last is not complete it will not have one.
            if not EOL in linesRead[-1]:
                if linesRead[-1] == PROMPT:
                    if LOGGING:
                        print(str(time.time()) + ' promptReady.set()')
                    # Manage the promptReady Event; it's set if and only if there is an incomplete line consisting of a prompt.
                    promptReady.set()
                lineBuffer = linesRead[-1] # Stash an incomplete line in lineBuffer
                del linesRead[-1]
            for rawLine in linesRead:
                # Now parse the line
                print(str(time.time()) + ' rawLine ' + repr(rawLine))
                line = rawLine.strip(EOL)
                # Is it empty?
                if len(line) == 0:
                    pass
                # Does it contain non-hex characters?
                elif any(x for x in line if x not in b'0123456789ABCDEF'):
                    # Command response or a packet received with errors
                    print(str(time.time()) + ' cmdResp ' + repr(line))
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
                        print(str(time.time()) + ' cmdResp ' + repr(line))
        
        if LOGGING:
            print(str(time.time()) + ' ELM327IO(): Check for queued transmit')
        try:
            toSend = transmit.get(timeout=TICKTIME)
            port.write(toSend)
            while 1:
                toSend = transmit.get_nowait()
                port.write(toSend)
        except queue.Empty:
            pass

def identToHex(ident):
    if ident & 0x80000000:
        string = '{:08x}'.format(ident)
    else:
        string = '{:03x}'.format(ident)
    return bytes(string, 'utf-8')
        
class ELM327CANInterface(CANInterface.Interface):
    '''
    Interface using ELM327 via serial. Spawns a thread that manages communications with the device; two queues allow it to communicate with the main thread.
    "Write" queue can request transmission of a frame, set baud rate, set filters, or request that monitoring stop.
    "Read" queue contains messages received from the bus.
    '''
    _QUEUE_MAX_SIZE = 16384
    _POSSIBLE_BAUDRATES = [500000, 115200, 38400, 9600, 230400, 460800, 57600, 28800, 14400, 4800, 2400, 1200]
    
    _slaveAddr = None
    _port = None
    _bitrate = None
    _txAddrStd = False
    _cfgdBitrate = None
    _cfgdTxAddrStd = False
    _baudDivisor = None
    _baud87Mult = None
    _hasSetCSM0 = False
    _tcpTimeout = 1.0
    _serialTimeout = 0.5
    _dumpTraffic = False
    _cfgdHeaderIdent = None
    _filter = None
    _cfgdFilter = None
    
    _receiveQueue = queue.Queue(_QUEUE_MAX_SIZE)
    _transmitQueue = queue.Queue(_QUEUE_MAX_SIZE)
    _cmdRespQueue = queue.Queue(_QUEUE_MAX_SIZE)
    _promptReady = threading.Event()
    _ioThreadTerminate = threading.Event()
    _ioThread = None
    
    def __init__(self, parsedURL):
        if len(parsedURL.netloc):
            # If netloc is present, we're using a TCP connection
            addr = parsedURL.netloc.split(':')
            if len(addr) == 1:
                addr.append(35000)  # use default port
            elif len(addr) != 2:
                raise CANInterface.Error('Interface address invalid')
            s = socket.socket()
            s.create_connection(addr, 0)
            self._port = SocketAsPort(s)
            self._intfcTimeout = self._tcpTimeout
        else:
            if LOGGING:
                port = LoggingPort()
            else:
                port = serial.Serial()
            port.port = parsedURL.path
            port.open()
            foundBaud = False
            for baudRate in self._POSSIBLE_BAUDRATES:
                if LOGGING:
                    print('Trying ' + str(baudRate))
                port.baudrate = baudRate
                port.interCharTimeout = min(10/baudRate, 0.0001)
                port.timeout = self._serialTimeout
                
                # Try sending a CR, if we get a prompt then it's probably the right baudrate
                port.flushInput()
                port.write(b'AT\r')
                time.sleep(0.05)
                port.write(b'AT\r')
                response = port.read(16384)
                if len(response) == 0 or response[-1:] != b'>':
                    continue
                
                # Turn off echo, this also serves as a test to make sure we didn't randomly get a > at the end of some gibberish
                port.flushInput()
                port.write(b'ATE0\r')
                response = port.read(16)
                if not b'OK' in response:
                    continue
                
                # If we made contact at baudrate 500k, we're done
                if baudRate == 500000:
                    foundBaud = True
                    break
                
                # Not at 500k, try to change ELM to that
                port.timeout = 1.28 # Maximum possible timeout for ELM327
                port.flushInput()
                port.write(b'ATBRD08\r')
                response = port.read(2)
                if response == b'?\r':
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
                        port.flushInput()
                        response = port.read(1024)
                        if len(response) == 0 or response[-1:] != b'>':
                            raise UnexpectedResponse('switching baudrate')
                    
                    # Baudrate switched, send a CR to confirm we're on board
                    port.flushInput()
                    port.write(b'\r')
                    response = port.read(2)
                    if response != b'OK':
                        raise UnexpectedResponse('switching baudrate')
                    foundBaud = True
                    break
            
            if not foundBaud:
                raise SerialError('could not find baudrate')
            port.timeout = 0
                
            self._port = port
            self._intfcTimeout = self._serialTimeout
        
        self._port.flushInput()
        
        # Start the I/O thread, which takes over control of the port
        self._ioThread = threading.Thread(target=ELM327IO, args=(self._port, self._receiveQueue, self._transmitQueue, self._cmdRespQueue, self._promptReady, self._ioThreadTerminate))
        self._ioThread.start()
        
        self._promptReady.clear()
        self._transmitQueue.put(b'\r') # Get a prompt so the reader thread knows ELM327 is ready
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
        self.close()
        
    def close(self):
        if self._ioThread != None and self._ioThread.is_alive():
            self._ioThreadTerminate.set()
            self._ioThread.join()
        else:
            if self._port != None:
                self._port.close()
    
    def setBaud(self, bitrate):
        self._bitrate = bitrate
        self._updateBitrateTXType()
    
    def setFilter(self, filt):
        self._filter = filt
        self._doSetFilter(filt)
    
    def _doSetFilter(self, filt):
        # User probably doesn't mean to set a filter that accepts both standard and extended IDs
        if not filt[1] & 0x80000000:
            raise BadFilter((hex(filt[0]), hex(filt[1])))
        if filt[0] & 0x80000000:
            stdFilter = '7ff' # Set a standard ID filter that matches nothing
            stdMask = '000'
            extFilter = '{:08x}'.format(filt[0] & 0x1FFFFFFF)
            extMask = '{:08x}'.format(filt[1] & 0x1FFFFFFF)
        else:
            stdFilter = '{:03x}'.format(filt[0] & 0x7FF)
            stdMask = '{:03x}'.format(filt[1] & 0x7FF)
            extFilter = '1fffffff'
            extMask = '00000000'
            
        self._promptReady.clear()
        self._transmitQueue.put(b'\r')
        self._runCmdWithCheck(b'ATCF' + bytes(stdFilter, 'utf-8'))
        self._runCmdWithCheck(b'ATCM' + bytes(stdMask, 'utf-8'))
        self._runCmdWithCheck(b'ATCF' + bytes(extFilter, 'utf-8'))
        self._runCmdWithCheck(b'ATCM' + bytes(extMask, 'utf-8'))
        self._transmitQueue.put(b'ATMA\r')
        
        self._cfgdFilter = filt
    
    def _setTXTypeByIdent(self, ident):
        if ident & 0x80000000:
            self._txAddrStd = False
        else:
            self._txAddrStd = True
    
    def _updateBitrateTXType(self):
        if self._bitrate != self._cfgdBitrate or self._txAddrStd != self._cfgdTxAddrStd:
            if self._bitrate != self._cfgdBitrate:
                self._calcBaudDivisor()
            self._setBitrateTXType()
            self._cfgdBitrate = self._bitrate
            self._cfgdTxAddrStd = self._txAddrStd
    
    def _calcBaudDivisor(self):
        baudTol = 0.001
        divisor = int(round(500000 / self._bitrate))
        if abs(500000 / divisor / self._bitrate - 1) > baudTol:
            divisor = int(round((500000 * 8 / 7) / self._bitrate))
            if abs((500000 * 8 / 7) / divisor / self._bitrate - 1) > baudTol:
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
        if self._baudDivisor == None:
            raise Error #FIXME
        
        self._promptReady.clear()
        self._transmitQueue.put(b'\r')
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
        if LOGGING:
            print(str(time.time()) + ' _runCmdWithCheck(): Prompt ready')
        self._promptReady.clear()
        while 1:
            try:
                self._cmdRespQueue.get_nowait()
            except queue.Empty:
                break
        self._transmitQueue.put(cmd + b'\r')
        if LOGGING:
            print(str(time.time()) + ' _runCmdWithCheck(): put ' + cmd.decode('utf-8'))
        if not self._promptReady.wait(self._intfcTimeout):
            failAction()
        if checkOK:
            gotOK = False
            while 1:
                try:
                    response = self._cmdRespQueue.get_nowait()
                    print('response ' + repr(response))
                    if b'OK' in response:
                        print('gotOK')
                        gotOK = True
                    elif response == cmd + b'\r':
                        response = self._cmdRespQueue.get_nowait()
                        if b'OK' in response:
                            gotOK = True
                except queue.Empty:
                    break
            print('gotOK ' + repr(gotOK))
            if not gotOK:
                failAction()

    def exactMask(self, ident):
        if ident & 0x80000000:
            return 0x9FFFFFFF
        else:
            return 0x800007FF

    def connect(self, address, dumpTraffic):
        self._slaveAddr = address
        self._dumpTraffic = dumpTraffic
        self._doSetFilter((address, self.exactMask(address)))
        self._runCmdWithCheck(b'ATMA', checkOK=False)
    
    def disconnect(self):
        self._slaveAddr = CANInterface.XCPSlaveCANAddr(0xFFFFFFFF, 0xFFFFFFFF)
        self._doSetFilter(self._filter)
        self._dumpTraffic = False
    
    def _doTransmit(self, data, ident):
        if self._dumpTraffic:
            print('TX ' + CANInterface.ID(ident).getString() + ' ' + CANInterface.getDataHexString(data))
        
        self._setTXTypeByIdent(ident)
        self._updateBitrateTXType()
        if not self._promptReady.wait(self._intfcTimeout):
            raise UnexpectedResponse('abort RX for transmission')
        
        if self._cfgdHeaderIdent != ident:
            self._promptReady.clear()
            self._transmitQueue.put(b'ATSH' + identToHex(ident) + b'\r')
            if not self._promptReady.wait(self._intfcTimeout):
                raise UnexpectedResponse((b'ATSH' + identToHex(ident)).decode('utf-8'))
            self._cfgdHeaderIdent = ident
            
        self._promptReady.clear()
        self._transmitQueue.put(binascii.hexlify(data) + b'\r')
    
    def transmit(self, data):
        assert self._cfgdBitrate != None and self._cfgdFilter != None
        self._doTransmit(data, self._slaveAddr.cmdId.raw)
    
    def transmitTo(self, data, ident):
        assert self._cfgdBitrate != None and self._cfgdFilter != None
        self._doTransmit(data, ident)
    
    def receive(self, timeout):
        assert self._cfgdBitrate != None and self._cfgdFilter != None
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
        assert self._cfgdBitrate != None and self._cfgdFilter != None
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

if __name__ == "__main__":
    import urllib.parse
    parsedurl = urllib.parse.urlparse('elm327:COM8')
    elm327 = ELM327CANInterface(parsedurl)
    elm327.setBaud(250000)
    elm327.setFilter((0x000, 0x80000000))
    elm327.transmitTo(b'1234', 0x7FF)
    time.sleep(1)
    packets = elm327.receivePackets(1)
    for packet in packets:
        print(repr(packet))
    elm327.close()