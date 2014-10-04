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
if not 'plugins' in __name__:
    if not '..' in sys.path:
        sys.path.append('..')
    from comm import CANInterface
else:
    from ..comm import CANInterface
import serial
import socket
import binascii
import time
import threading
import queue
import collections

DEBUG=True

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
    _logLock = threading.Lock()
    def __init__(self, debugLogfile, **kwargs):
        super().__init__(**kwargs)
        self._debugLogfile = debugLogfile
    def _prefix(self):
        return str(time.time()) + ' ' + str(threading.currentThread().ident)
    def open(self, *args, **kwargs):
        result = super().open(*args, **kwargs)
        prefix = self._prefix()
        with self._logLock:
            self._debugLogfile.write(prefix + ' OPEN' + '\n')
        return result
    def close(self, *args, **kwargs):
        result = super().close(*args, **kwargs)
        prefix = self._prefix()
        with self._logLock:
            self._debugLogfile.write(prefix + ' CLOSE' + '\n')
        return result
    def read(self, *args, **kwargs):
        with self._logLock:
            result = super().read(*args, **kwargs)
            prefix = self._prefix()
            if len(result) > 0:
                self._debugLogfile.write(prefix + ' RD ' + repr(result) + '\n')
        return result
    def write(self, data):
        with self._logLock:
            result = super().write(data)
            prefix = self._prefix()
            self._debugLogfile.write(prefix + ' WR ' + repr(data) + '\n')
            return result

def PutDiscard(queue, item):
    '''
    Put something on a queue and discard the oldest entry if it's full. Has a race (consumer might call get() just after this func
    finds the queue is full and we will needlessly discard an item) but this should only happen in the case of CPU starvation
    or data that's not relevant anyway.
    '''
    if queue.full():
        queue.get()
    queue.put(item)

class ELM327IO(object):
    '''
    Reads input, discards zero bytes (which ELM docs say can sometimes be inserted in error),
    packages completed lines that appear to be CAN frames and places them in the receive queue.
    Lines that are not packets and not empty are placed in the cmdResp queue, and command prompts from the ELM327
    (indicating readiness to receive commands) set the promptReady Event.
    
    Expects that ELM327 has already received ATL0 (disable linefeed), ATS0 (disable spaces), and ATH1 (enable headers).
    '''
    
    _QUEUE_MAX_SIZE = 16384
    _TICK_TIME = 0.001
    _ELM_RECOVERY_TIME = 0.002
    _CYCLE_TIMEOUT = 1.0
    _EOL=b'\r'
    _PROMPT=b'>'
    
    def __init__(self, port):
        self._port = None
        self._receive = queue.Queue(self._QUEUE_MAX_SIZE)
        self._transmit = queue.Queue(self._QUEUE_MAX_SIZE)
        self._cmdResp = queue.Queue(self._QUEUE_MAX_SIZE)
        self._promptReady = threading.Event()
        self._pipelineClear = threading.Event()
        self._terminate = threading.Event()
        self._thread = None
        self._lines = collections.deque()
        self._timeToSend = 0
        self._port = port
        self._port.timeout = self._TICK_TIME
        self._thread = threading.Thread(target=self.threadFunc)
        self._thread.daemon = True # In case main thread crashes...
        self._thread.start()
    
    def threadFunc(self):
        while 1:
            if self._terminate.is_set():
                if DEBUG:
                    print(str(time.time()) + ' ELM327IO(): terminate set')
                return
            
            setPipelineClear = (not self._pipelineClear.is_set())
            setPromptReady = False
            linesRead = self._port.read(4096).translate(None, b'\0').splitlines(keepends=True)
            if len(linesRead) > 0:
                if len(self._lines) > 0:
                    self._lines[-1] += linesRead[0]
                    del linesRead[0]
                for lineRead in linesRead:
                    self._lines.append(lineRead)
                
                if self._lines[-1] == self._PROMPT:
                    if DEBUG:
                        print(str(time.time()) + ' promptReady.set(), end of queue')
                    # Manage the promptReady Event; it's set if and only if there is an incomplete line consisting of a prompt.
                    setPromptReady = True
                    del self._lines[-1]
                while self._lines:
                    rawLine = self._lines.popleft()
                    if DEBUG:
                        print(str(time.time()) + ' processing ' + str(rawLine))
                    if self._EOL in rawLine:
                        line = rawLine.strip(self._EOL)
                        # Is it empty?
                        if len(line) == 0:
                            pass
                        # Does it contain non-hex characters?
                        elif any(x for x in line if x not in b'0123456789ABCDEF'):
                            # Command response or a packet received with errors
                            PutDiscard(self._cmdResp, line)
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
                                packet = CANInterface.Packet(ident | mask, data)
                                PutDiscard(self._receive, packet)
                            else:
                                # Too short to be valid
                                PutDiscard(self._cmdResp, line)
                    else:
                        if rawLine == self._PROMPT:
                            if DEBUG:
                                print(str(time.time()) + ' promptReady.set(), not EOQ')
                            # Manage the promptReady Event; it's set if and only if there is an incomplete line consisting of a prompt.
                            setPromptReady = True
                        else:
                            self._lines.appendleft(rawLine)
                            break

            try:
                while 1:
                    timeDelay = self._timeToSend - time.time()
                    if timeDelay > 0:
                        if DEBUG:
                            print(str(time.time()) + ' waiting ' + str(timeDelay) + ' for recovery after TX')
                        time.sleep(timeDelay)
                    toSend = self._transmit.get_nowait()
                    if DEBUG:
                        print(str(time.time()) + ' pulled from TX queue ' + str(toSend))
                    self._port.write(toSend)
                    self._promptReady.clear()
                    self._timeToSend = time.time() + self._ELM_RECOVERY_TIME
            except queue.Empty:
                pass
            
            if setPromptReady:
                self._promptReady.set()
            if setPipelineClear:
                self._pipelineClear.set()
    
    def sync(self):
        self._pipelineClear.clear()
        if not self._pipelineClear.wait(self._CYCLE_TIMEOUT):
            raise Error #FIXME
    
    def syncAndGetPrompt(self, intfcTimeout, retries=5):
        '''
        Synchronize the I/O thread and obtain a prompt. If one is available return immediately; otherwise get one
        by sending CR and waiting for a prompt to come back.
        
        Loop is believed to be the best way of dealing with the race condition: ELM327 is receiving CAN data,
        so isPromptReady() returns False, but just before we send the CR, ELM327 runs into buffer full, stops receive,
        and returns to the prompt. ELM327 then gets the CR and resumes receiving, so the CR was actually
        counterproductive. Buffer full conditions should not be allowed to happen (through appropriate filter settings)
        but we should deal with them somewhat robustly if e.g. there is unexpected traffic on the CAN.
        '''
        self.sync()
        if self.isPromptReady():
            return
        for _ in range(retries):
            self.write(b'\r')
            if self.waitPromptReady(intfcTimeout):
                return
        raise UnexpectedResponse(b'\r')
    
    def getReceived(self, timeout=0):
        if DEBUG:
            print(str(time.time()) + ' waiting ' + str(timeout) + ' for receive')
        ret = self._receive.get(timeout=0)
        if DEBUG:
            print(str(time.time()) + ' received ' + str(ret))
        return ret
    
    def getCmdResp(self, timeout=0):
        return self._cmdResp.get(timeout)
    
    def flushCmdResp(self):
        while 1:
            try:
                self._cmdResp.get_nowait()
            except queue.Empty:
                break
    
    def write(self, data):
        self._transmit.put(data)
        self.sync()
    
    def terminate(self):
        self._terminate.set()
        self._thread.join()
    
    def isPromptReady(self):
        return self._promptReady.is_set()
    
    def waitPromptReady(self, timeout):
        return self._promptReady.wait(timeout)

class ELM327CANInterface(CANInterface.Interface):
    '''
    Interface using ELM327 via serial. Spawns a thread that manages communications with the device; two queues allow it to communicate with the main thread.
    "Write" queue can request transmission of a frame, set baud rate, set filters, or request that monitoring stop.
    "Read" queue contains messages received from the bus.
    '''
    _POSSIBLE_BAUDRATES = [500000, 115200, 38400, 9600, 230400, 460800, 57600, 28800, 14400, 4800, 2400, 1200]
    
    
    def __init__(self, parsedURL, debugLogfile=None):
        self._slaveAddr = None
        self._port = None
        self._bitrate = None
        self._txAddrStd = False
        self._cfgdBitrate = None
        self._cfgdTxAddrStd = False
        self._baudDivisor = None
        self._baud87Mult = None
        self._hasSetCSM0 = False
        self._tcpTimeout = 1.0
        self._serialTimeout = 0.5
        self._dumpTraffic = False
        self._cfgdHeaderIdent = None
        self._filter = None
        self._cfgdFilter = None
        self._noCsmQuirk = False
        
        self._io = None
    
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
            if debugLogfile != None:
                port = LoggingPort(debugLogfile)
            else:
                port = serial.Serial()
            port.port = parsedURL.path
            port.open()
            foundBaud = False
            for baudRate in self._POSSIBLE_BAUDRATES:
                if DEBUG:
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
                    response = port.read(11)
                    if response[0:6] != b'ELM327':
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
                    if response == b'ELM327 v1.5':
                        self._noCsmQuirk = True
                    break
            
            if not foundBaud:
                raise SerialError('could not find baudrate')
            port.timeout = 0
                
            self._port = port
            self._intfcTimeout = self._serialTimeout
        
        self._port.flushInput()
        
        # Start the I/O thread, which takes over control of the port
        self._io = ELM327IO(port)
        
        self._runCmdWithCheck(b'ATWS', checkOK=False, closeOnFail=True) # Software reset
        self._runCmdWithCheck(b'ATE0', closeOnFail=True) # Turn off echo
        self._runCmdWithCheck(b'ATL0', closeOnFail=True) # Turn off newlines
        self._runCmdWithCheck(b'ATS0', closeOnFail=True) # Turn off spaces
        self._runCmdWithCheck(b'ATH1', closeOnFail=True) # Turn on headers
        self._runCmdWithCheck(b'ATSPB', closeOnFail=True) # Switch to protocol B (user defined)
        
        self.setBitrate(CANInterface.URLBitrate(parsedURL))
        
        self._slaveAddr = CANInterface.XCPSlaveCANAddr(0xFFFFFFFF, 0xFFFFFFFF)
    
    def __enter__(self):
        return self

    def __exit__(self, exitType, value, traceback):
        self.close()
        
    def close(self):
        if self._io != None:
            self._io.terminate()
        else:
            if self._port != None:
                self._port.close()
    
    def setBitrate(self, bitrate):
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
            
        self._runCmdWithCheck(b'ATCF' + bytes(stdFilter, 'utf-8'))
        self._runCmdWithCheck(b'ATCM' + bytes(stdMask, 'utf-8'))
        self._runCmdWithCheck(b'ATCF' + bytes(extFilter, 'utf-8'))
        self._runCmdWithCheck(b'ATCM' + bytes(extMask, 'utf-8'))
        self._io.write(b'ATMA\r')
        
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
        
        self._runCmdWithCheck(b'ATPB' + binascii.hexlify(bytearray([canOptions, self._baudDivisor])), closeOnFail=True)
        if not self._hasSetCSM0:
            try:
                self._runCmdWithCheck(b'ATCSM0', closeOnFail=False)
            except UnexpectedResponse:
                if not self._noCsmQuirk:
                    print('Warning: Failed to set CAN silent monitoring to off')
            self._hasSetCSM0 = True
            
    def _runCmdWithCheck(self, cmd, checkOK=True, closeOnFail=False):
        def failAction():
            if closeOnFail:
                self.close()
            raise UnexpectedResponse(cmd)
        
        try:
            self._io.syncAndGetPrompt(self._intfcTimeout)
        except UnexpectedResponse:
            if closeOnFail:
                self.close()
            raise
        if DEBUG:
            print(str(time.time()) + ' _runCmdWithCheck(): Prompt ready')
        self._io.flushCmdResp()
        self._io.write(cmd + b'\r')
        if DEBUG:
            print(str(time.time()) + ' _runCmdWithCheck(): put ' + cmd.decode('utf-8'))
        if not self._io.waitPromptReady(self._intfcTimeout):
            failAction()
        if checkOK:
            gotOK = False
            while 1:
                try:
                    response = self._io.getCmdResp(timeout=0)
                    if DEBUG:
                        print(str(time.time()) + ' pulled cmd response ' + str(response))
                    if b'OK' in response:
                        gotOK = True
                except queue.Empty:
                    break
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
        self._doSetFilter((address.resId.raw, self.exactMask(address.resId.raw)))
    
    def disconnect(self):
        self._slaveAddr = CANInterface.XCPSlaveCANAddr(0xFFFFFFFF, 0xFFFFFFFF)
        self._doSetFilter(self._filter)
        self._dumpTraffic = False
    
    def _doTransmit(self, data, ident):
        if self._dumpTraffic:
            print('TX ' + CANInterface.ID(ident).getString() + ' ' + CANInterface.getDataHexString(data))
        
        self._setTXTypeByIdent(ident)
        self._updateBitrateTXType()
        
        if self._cfgdHeaderIdent != ident:
            if ident & 0x80000000:
                self._runCmdWithCheck(b'ATCP' + bytes('{:02x}'.format((ident >> 24) & 0x1F), 'utf-8'))
                self._runCmdWithCheck(b'ATSH' + bytes('{:06x}'.format(ident & 0xFFFFFF), 'utf-8'))
            else:
                self._runCmdWithCheck(b'ATSH' + bytes('{:03x}'.format(ident & 0x7FF), 'utf-8'))
            self._cfgdHeaderIdent = ident
        else:
            self._io.syncAndGetPrompt(self._intfcTimeout) # Not synchronized by calling _runCmdWithCheck(), so do it here
            
        self._io.write(binascii.hexlify(data) + b'\r')
    
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
                    packet = self._io.getReceived(timeout=0)
                else:
                    newTimeout = endTime - time.time()
                    if newTimeout < 0:
                        packet = self._io.getReceived(timeout=0)
                    else:
                        packet = self._io.getReceived(timeout=newTimeout)
            except queue.Empty:
                print(str(time.time()) + ' Rcv queue empty')
                break

            if DEBUG:
                print(str(time.time()) + ' rcvd pkt ' + repr(packet))

            
            if packet.ident == self._slaveAddr.resId.raw and (packet.data[0] == 0xFF or packet.data[0] == 0xFE):
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
                    packet = self._io.getReceived(timeout=0)
                else:
                    newTimeout = endTime - time.time()
                    if newTimeout < 0:
                        packet = self._io.getReceived(timeout=0)
                    else:
                        packet = self._io.getReceived(timeout=newTimeout)
            except queue.Empty:
                break
            
            if len(packet.data) > 0 and (packet.data[0] == 0xFF or packet.data[0] == 0xFE):
                packets.append(packet)
                if self._dumpTraffic:
                    print('RX ' + CANInterface.ID(packet.ident).getString() + ' ' + CANInterface.getDataHexString(packet.data))
        return packets

CANInterface.addInterface("elm327", ELM327CANInterface)

if __name__ == "__main__":
    import urllib.parse
    parsedurl = urllib.parse.urlparse('elm327:/dev/rfcomm0')
    elm327 = ELM327CANInterface(parsedurl, open('elm327.log', 'w'))
    elm327.setFilter((0x000, 0x80000000))
    elm327.transmitTo(b'1234', 0x9FFFFFFF)
    elm327.transmitTo(b'1234', 0x7FF)
    time.sleep(1)
    packets = elm327.receivePackets(1)
    for packet in packets:
        print(repr(packet))
    elm327.close()
