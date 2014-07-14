'''
Created on Jun 23, 2013

@author: gcardwel
'''

from collections import namedtuple
import struct
import time
from . import CANInterface


Pointer = namedtuple('Pointer', ['addr', 'ext'])


def GetCANSlaves(interface, bcastId, timeout):
    request = struct.pack("BBBBBB", 0xF2, 0xFF, 0x58, 0x43, 0x50, 0x00)
    interface.transmitTo(request, bcastId)
    time.sleep(timeout)
    slaves = []
    for packet in interface.receivePackets(0.0):
        try:
            data = struct.unpack("!BBBBL", packet.data)
            if data[0] == 0xFF and data[1] == 0x58 and data[2] == 0x43 and data[3] == 0x50:
                slaves.append(CANInterface.XCPSlaveCANAddr(data[4], packet.ident))
        except struct.error:
            pass
    return slaves
    
class Error(Exception):
    def __init__(self):
        self._desc = ''
        self._value = None
    def __str(self):
        if self._value != None:
            return self.desc + ' ' + self._value
        else:
            return self.desc

class Timeout(Error):
    def __init__(self, value=None):
        self._desc = 'Timeout'
        self._value = value

class InvalidOp(Error):
    def __init__(self, value=None):
        self._desc = 'Invalid operation attempted'
        self._value = value

class BadReply(Error):
    def __init__(self, value=None):
        self._desc = 'Unexpected reply from slave'
        self._value = value

class Timeout(Error):
    def __init__(self, value=None):
        self._desc = 'Block mode packet lost'
        self._value = value

class SlaveError(Error):
    pass

class SlaveErrorBusy(SlaveError):
    def __init__(self, value=None):
        self._desc = 'Slave error (busy)'
        self._value = value

class SlaveErrorDAQActive(SlaveError):
    def __init__(self, value=None):
        self._desc = 'Slave error (DAQ active)'
        self._value = value

class SlaveErrorPgmActive(SlaveError):
    def __init__(self, value=None):
        self._desc = 'Slave error (program active)'
        self._value = value

class SlaveErrorCmdUnknown(SlaveError):
    def __init__(self, value=None):
        self._desc = 'Slave error (Command unknown)'
        self._value = value

class SlaveErrorCmdSyntax(SlaveError):
    def __init__(self, value=None):
        self._desc = 'Slave error (command syntax)'
        self._value = value

class SlaveErrorOutOfRange(SlaveError):
    def __init__(self, value=None):
        self._desc = 'Slave error (out of range)'
        self._value = value

class SlaveErrorWriteProtected(SlaveError):
    def __init__(self, value=None):
        self._desc = 'Slave error (write protected)'
        self._value = value

class SlaveErrorAccessDenied(SlaveError):
    def __init__(self, value=None):
        self._desc = 'Slave error (access denied)'
        self._value = value

class SlaveErrorAccessLocked(SlaveError):
    def __init__(self, value=None):
        self._desc = 'Slave error (access locked)'
        self._value = value

class SlaveErrorPageNotValid(SlaveError):
    def __init__(self, value=None):
        self._desc = 'Slave error (page not valid)'
        self._value = value

class SlaveErrorModeNotValid(SlaveError):
    def __init__(self, value=None):
        self._desc = 'Slave error (page mode not valid)'
        self._value = value

class SlaveErrorSegmentNotValid(SlaveError):
    def __init__(self, value=None):
        self._desc = 'Slave error (segment not valid)'
        self._value = value

class SlaveErrorSequence(SlaveError):
    def __init__(self, value=None):
        self._desc = 'Slave error (sequence)'
        self._value = value

class SlaveErrorDAQConfig(SlaveError):
    def __init__(self, value=None):
        self._desc = 'Slave error (DAQ config invalid)'
        self._value = value

class SlaveErrorMemoryOverflow(SlaveError):
    def __init__(self, value=None):
        self._desc = 'Slave error (memory overflow)'
        self._value = value

class SlaveErrorGeneric(SlaveError):
    def __init__(self, value=None):
        self._desc = 'Slave error (generic)'
        self._value = value

class SlaveErrorVerify(SlaveError):
    def __init__(self, value=None):
        self._desc = 'Slave error (program verify) '
        self._value = value

xcpErrCodes = { \
    0x10: SlaveErrorBusy, \
    0x11: SlaveErrorDAQActive, \
    0x12: SlaveErrorPgmActive, \
    0x20: SlaveErrorCmdUnknown, \
    0x21: SlaveErrorCmdSyntax, \
    0x22: SlaveErrorOutOfRange, \
    0x23: SlaveErrorWriteProtected, \
    0x24: SlaveErrorAccessDenied, \
    0x25: SlaveErrorAccessLocked, \
    0x26: SlaveErrorPageNotValid, \
    0x27: SlaveErrorModeNotValid, \
    0x28: SlaveErrorSegmentNotValid, \
    0x29: SlaveErrorSequence, \
    0x2A: SlaveErrorDAQConfig, \
    0x30: SlaveErrorMemoryOverflow, \
    0x31: SlaveErrorGeneric, \
    0x32: SlaveErrorVerify \
}

def RaiseReply(reply, msg = None):
    print(repr(reply))
    if reply[0] == 0xFE and reply[1] in xcpErrCodes:
        raise xcpErrCodex[reply[1]](msg)
    else:
        raise BadReply(msg)
    
class Connection(object):
    '''
    classdocs

    
    '''
    def __init__(self, interface, timeout, nvWriteTimeout):
        '''
        Constructor - assumes interface is already connected (knows target device address)
        Performs XCP connection sequence
        '''
        self._interface = interface
        self._timeout = timeout
        self._nvWriteTimeout = nvWriteTimeout
        # temporarily set byteorder to allow transaction
        self._byteorder = "@"
        request = struct.pack("BB", 0xFF, 0x00)
        reply = self._transaction(request, "BBBBBBBB")
        if reply[0] != 0xFF:
            RaiseReply(reply, 'connecting to slave')
        self._calPage = reply[1] & 0x01
        self._daq = reply[1] & 0x04
        self._stim = reply[1] & 0x08
        self._pgm = reply[1] & 0x10
        self._pgmStarted = False
        self._pgmMasterBlockMode = False
        self._calcMTA = None
        if reply[2] & 0x01:
            self._byteorder = ">"
            self._maxDTO = reply[4] << 8 | reply[5]
        else:
            self._byteorder = "<"
            self._maxDTO = reply[5] << 8 | reply[4]
        
        if (reply[2] & 0x06) == 0x00:
            self._addressGranularity = 1
        elif (reply[2] & 0x06) == 0x02:
            self._addressGranularity = 2
        elif (reply[2] & 0x06) == 0x04:
            self._addressGranularity = 4
        else:
            self.close()
            RaiseReply(reply, 'connecting to slave')
        
        self._maxCTO = reply[3]
        
        self._maxDownloadPayload = self.byteToAG(self._maxCTO - 2) * self._addressGranularity
        self._maxUploadPayload = self.byteToAG(self._maxCTO - 1) * self._addressGranularity
        
        if reply[6] != 0x01 or reply[7] != 0x01:
            self.close()
            RaiseReply(reply, 'connecting to slave')
    
    def byteToAG(self, data):
        return int(data / self._addressGranularity)

    def close(self):
        request = struct.pack(self._byteorder + "B", 0xFE)
        reply = self._transaction(request, "B")
        if reply[0] != 0xFF:
            RaiseReply(reply, 'closing connection to slave')
        self._pgmStarted = False
    
    def _getReply(self, fmt, timeout):
        received = self._interface.receive(timeout)
        replies = [rep for rep in received if rep[0] == 0xFF or rep[0] == 0xFE]
        if len(replies) < 1:
            raise Timeout()
        if len(replies) > 1:
            RaiseReply(reply, 'multiple replies')
        try:
            #print('Send ' + repr([hex(elem) for elem in request]) + ' Reply ' + repr([hex(elem) for elem in replies[0]]))
            reply = struct.unpack_from(self._byteorder + fmt, replies[0])
            return reply
        except struct.error:
            RaiseReply(reply, 'reply wrong length')
    
    def _transaction(self, request, fmt, timeout=-1):
        self._interface.transmit(request)
        if timeout < 0:
            return self._getReply(fmt, self._timeout)
        else:
            return self._getReply(fmt, timeout)
    
    def _synch(self):
        request = struct.pack(self._byteorder + "B", 0xFC)
        reply = self._transaction(request, "BB")
        if reply[0] != 0xFE or reply[1] != 0x00:
            RaiseReply(reply, 'resynchronization')
    
    def _query(self, action_func, *args):
        failures = 0
        maxFailures = 2
        while failures <= maxFailures:
            try:
                return action_func(*args)  # Jumps out if the action succeeds
            except (Timeout, PacketLost):
                failures += 1
                
            while failures <= maxFailures:
                try:
                    self._synch()
                    break
                except Timeout:
                    failures += 1  # If max number of failures is reached, inner loop exits, then so does outer loop
        raise Timeout()
    
    def _setMTA(self, ptr):
        request = struct.pack(self._byteorder + "BxxBL", 0xF6, ptr.ext, ptr.addr)
        try:
            reply = self._transaction(request, "B")
        except Error:
            self._calcMTA = None
            raise
        if reply[0] != 0xFF:
            self._calcMTA = None
            RaiseReply(reply, 'set MTA')
        self._calcMTA = ptr
    
    def _action_upload8(self, ptr):
        if self._addressGranularity == 1:
            request = struct.pack(self._byteorder + "BBxBL", 0xF4, 1, ptr.ext, ptr.addr)
            
            try:
                reply = self._transaction(request, "BB")
            except Error:
                self._calcMTA = None
                raise
            
            if reply[0] != 0xFF:
                self._calcMTA = None
                RaiseReply(reply, 'uploading 1 byte')
            else:
                self._calcMTA = Pointer(ptr.addr + 1, ptr.ext)
                return reply[1]
        else:
            raise InvalidOp()
    
    def upload8(self, ptr):
        return self._query(self._action_upload8, ptr)

    def _action_upload16(self, ptr):
        if self._addressGranularity == 1:
            request = struct.pack(self._byteorder + "BBxBL", 0xF4, 2, ptr.ext, ptr.addr)
            decodeFormat = "BH"
        elif self._addressGranularity == 2:
            request = struct.pack(self._byteorder + "BBxBL", 0xF4, 1, ptr.ext, ptr.addr)
            decodeFormat = "BxH"
        else:
            raise InvalidOp()
        
        try:
            reply = self._transaction(request, decodeFormat)
        except Error:
            self._calcMTA = None
            raise
            
        if reply[0] != 0xFF:
            self._calcMTA = None
            RaiseReply(reply, 'uploading 2 bytes')
        else:
            self._calcMTA = Pointer(ptr.addr + self.byteToAG(2), ptr.ext)
            return reply[1]
    
    def upload16(self, ptr):
        return self._query(self._action_upload16, ptr)
    
    def _action_upload32(self, ptr):
        if self._addressGranularity == 1:
            request = struct.pack(self._byteorder + "BBxBL", 0xF4, 4, ptr.ext, ptr.addr)
            decodeFormat = "BL"
        elif self._addressGranularity == 2:
            request = struct.pack(self._byteorder + "BBxBL", 0xF4, 2, ptr.ext, ptr.addr)
            decodeFormat = "BxL"
        elif self._addressGranularity == 4:
            request = struct.pack(self._byteorder + "BBxBL", 0xF4, 1, ptr.ext, ptr.addr)
            decodeFormat = "BxxxL"
        else:
            raise InvalidOp()
        
        try:
            reply = self._transaction(request, decodeFormat)
        except Error:
            self._calcMTA = None
            raise
        
        if reply[0] != 0xFF:
            self._calcMTA = None
            RaiseReply(reply, 'uploading 4 bytes')
        else:
            self._calcMTA = Pointer(ptr.addr + self.byteToAG(4), ptr.ext)
            return reply[1]
    
    def upload32(self, ptr):
        return self._query(self._action_upload32, ptr)
    
    def _action_upload(self, ptr, size):
        if self._calcMTA == ptr:
            request = struct.pack(self._byteorder + "BB", 0xF5, int(size / self._addressGranularity))
        else:
            request = struct.pack(self._byteorder + "BBxBL", 0xF4, int(size / self._addressGranularity), ptr.ext, ptr.addr)
        
        if self._addressGranularity == 1:
            decodeFormat = 'B' + str(size) + 's'
        elif self._addressGranularity == 2:
            decodeFormat = 'Bx' + str(size) + 's'
        elif self._addressGranularity == 4:
            decodeFormat = 'Bxxx' + str(size) + 's'
        else:
            raise InvalidOp()
        
        try:
            reply = self._transaction(request, decodeFormat)
        except Error:
            self._calcMTA = None
            raise
        
        if reply[0] != 0xFF:
            self._calcMTA = None
            RaiseReply(reply, 'uploading data')
        else:
            self._calcMTA = Pointer(ptr.addr + self.byteToAG(size), ptr.ext)
            return bytes(reply[1])
    
    def upload(self, ptr, size):
        data = b''
        remBytes = size
        packetPtr = ptr
        while remBytes > 0:
            packetBytes = min(remBytes, self._maxUploadPayload)
            remBytes -= packetBytes
            data = data + self._query(self._action_upload, packetPtr, packetBytes)
            packetPtr = Pointer(packetPtr.addr + self.byteToAG(packetBytes), ptr.ext)
        return data

    def _action_download8(self, ptr, data):
        if self._addressGranularity > 1:
            raise InvalidOp()
        if self._calcMTA != ptr:
            self._setMTA(ptr)
        request = struct.pack(self._byteorder + "BBB", 0xF0, 1, data)
        
        try:
            reply = self._transaction(request, "B")
        except Error:
            self._calcMTA = None
            raise
        
        if reply[0] != 0xFF:
            self._calcMTA = None
            RaiseReply(reply, 'downloading 1 byte')
        else:
            self._calcMTA = Pointer(ptr.addr + 1, ptr.ext)
    
    def download8(self, ptr, data):
        if not self._calPage:
            raise InvalidOp('downloading 1 byte, calibration page not set')
        return self._query(self._action_download8, ptr, data)

    def _action_download16(self, ptr, data):
        if self._addressGranularity == 1:
            request = struct.pack(self._byteorder + "BBH", 0xF0, 2, data)
        elif self._addressGranularity == 2:
            request = struct.pack(self._byteorder + "BBH", 0xF0, 1, data)
        else:
            raise InvalidOp()
        if self._calcMTA != ptr:
            self._setMTA(ptr)
        try:
            reply = self._transaction(request, "B")
        except Error:
            self._calcMTA = None
            raise
        
        if reply[0] != 0xFF:
            self._calcMTA = None
            RaiseReply(reply, 'downloading 2 bytes')
        else:
            self._calcMTA = Pointer(ptr.addr + self.byteToAG(2), ptr.ext)
    
    def download16(self, ptr, data):
        if not self._calPage:
            raise InvalidOp('downloading 2 bytes, calibration page not set')
        return self._query(self._action_download16, ptr, data)

    def _action_download32(self, ptr, data):
        if self._addressGranularity == 1:
            request = struct.pack(self._byteorder + "BBL", 0xF0, 4, data)
        elif self._addressGranularity == 2:
            request = struct.pack(self._byteorder + "BBL", 0xF0, 2, data)
        else:
            request = struct.pack(self._byteorder + "BBxxL", 0xF0, 1, data)
        if self._calcMTA != ptr:
            self._setMTA(ptr)
        try:
            reply = self._transaction(request, "B")
        except Error:
            self._calcMTA = None
            raise
        
        if reply[0] != 0xFF:
            self._calcMTA = None
            RaiseReply(reply, 'downloading 4 bytes')
        else:
            self._calcMTA = Pointer(ptr.addr + self.byteToAG(4), ptr.ext)
    
    def download32(self, ptr, data):
        if not self._calPage:
            raise InvalidOp('downloading 4 bytes, calibration page not set')
        return self._query(self._action_download32, ptr, data)
        
    
    def _action_download(self, ptr, data):
        if len(data) > self._maxDownloadPayload or (len(data) % self._addressGranularity) != 0:
            raise InvalidOp()
        
        if self._calcMTA != ptr:
            self._setMTA(ptr)
            
        lenDataAG = int(len(data) % self._addressGranularity)
        
        if self._addressGranularity < 4:
            request = struct.pack(self._byteorder + "BB", 0xF0, lenDataAG) + data
        else:
            request = struct.pack(self._byteorder + "BBxx", 0xF4, lenDataAG) + data
        
        decodeFormat = "B"
        
        try:
            reply = self._transaction(request, decodeFormat)
        except Error:
            self._calcMTA = None
            raise
        
        if reply[0] != 0xFF:
            self._calcMTA = None
            RaiseReply(reply, 'downloading data')
        else:
            self._calcMTA = Pointer(ptr.addr + self.byteToAG(len(data)), ptr.ext)
    
    def download(self, ptr, data):
        remBytes = len(data)
        dataStart = 0
        packetPtr = ptr
        while remBytes > 0:
            packetBytes = min(remBytes, self._maxDownloadPayload)
            remBytes -= packetBytes
            self._query(self._action_download, packetPtr, data[dataStart:(dataStart + packetBytes)])
            dataStart = dataStart + packetBytes
            packetPtr = Pointer(packetPtr.addr + self.byteToAG(packetBytes), ptr.ext)
    
    def _action_nvwrite(self):
        request = struct.pack(self._byteorder + "BBH", 0xF9, 0x01, 0)
        reply = self._transaction(request, "B")
        if reply[0] != 0xFF:
            RaiseReply(reply, 'writing nonvolatile memory')
        
        # Fixed turndown ratio of 10
        pollInterval = self._nvWriteTimeout / 10
        
        for i in range(10):
            time.sleep(pollInterval)
            request = struct.pack(self._byteorder + "B", 0xFD)
            reply = self._transaction(request, "BBBBH")
            if reply[0] == 0xFD:
                if reply[1] == 0x03:
                    # EV_STORE_CAL: we're done
                    return
            if reply[0] != 0xFF:
                RaiseReply(reply, 'waiting for nonvolatile memory write to finish')
            if not (reply[1] & 0x01):
                return
                
        # Exited loop due to timeout
        raise Timeout()
    
    def nvwrite(self):
        if not self._calPage:
            RaiseReply(reply, 'writing nonvolatile memory, calibration page not set')
        return self._query(self._action_nvwrite)
    
    def _action_set_cal_page(self, segment, page):
        request = struct.pack(self._byteorder + "BBBB", 0xEB, 0x03, segment, page)  # Both slave device and application can access area
        self._calcMTA = None  # standard does not define what happens to MTA
        reply = self._transaction(request, "B", self._nvWriteTimeout)
        if reply[0] != 0xFF:
            RaiseReply(reply, 'setting calibration page')
    
    def set_cal_page(self, segment, page):
        if not self._calPage:
            raise InvalidOp()
        return self._query(self._action_set_cal_page, segment, page)
    
    def _action_program_start(self):
        request = struct.pack(self._byteorder + "B", 0xD2)
        reply = self._transaction(request, "BxBBBBB")
        if reply[0] != 0xFF or reply[2] < 8:
            RaiseReply(reply, 'starting program')
        if reply[1] & 0x01:
            self._pgmMasterBlockMode = True
        else:
            self._pgmMasterBlockMode = False
        self._pgmMaxCTO = reply[2]
        self._pgmMaxBS = reply[3]
        self._pgmMinST = reply[4]
        self._pgmMaxDownloadPayload = self.byteToAG(self._pgmMaxCTO - 2) * self._addressGranularity
        self._calcMTA = None
        self._pgmStarted = True
        # Compensate for erroneous implementations that gave BS as a number of bytes, not number of packets
        if self._pgmMaxBS > int(255/self._pgmMaxDownloadPayload):
            self._pgmMaxBS = int(self._pgmMaxBS / self._pgmMaxDownloadPayload)
            
    
    def program_start(self):
        return self._query(self._action_program_start)
    
    def _action_program_clear(self, ptr, length):
        if self._calcMTA != ptr:
            self._setMTA(ptr)
        request = struct.pack(self._byteorder + "BBxxL", 0xD1, 0x00, length)
        self._calcMTA = None  # standard does not define what happens to MTA
        reply = self._transaction(request, "B", self._nvWriteTimeout)
        if reply[0] != 0xFF:
            RaiseReply(reply, 'erasing program')
    
    def program_clear(self, ptr, length):
        if not self._pgmStarted:
            raise InvalidOp()
        return self._query(self._action_program_clear, ptr, length)
    
    def _action_program_block(self, ptr, data):
        if (len(data) % self._addressGranularity != 0) or (self.byteToAG(len(data)) > self._pgmMaxBS * self._pgmMaxDownloadPayload):
            raise InvalidOp()
        
        if self._calcMTA != ptr:
            self._setMTA(ptr)
        remBytes = len(data)
        firstPacket = True
        
        while remBytes > 0:
            # check for a pre-existing error (from a previous operation, or a previous iter of this operation)
            replies = self._interface.receive(0)
            # if no replies, everything is OK
            if len(replies) > 0:
                self._calcMTA = None
                # if a reply that is not ERR_SEQUENCE, raise bad reply
                for reply in replies:
                    if len(reply) < 2 or reply[0] != 0xFE or reply[1] != 0x29:
                        RaiseReply(reply, 'writing program block')  # not ERR_SEQUENCE
                # if replies are all ERR_SEQUENCE, raise packet lost (and potentially try again)
                raise PacketLost()
            
            if firstPacket:
                cmdCode = 0xD0
                firstPacket = False
            else:
                cmdCode = 0xCA
            
            payloadBytes = min(remBytes, self._pgmMaxDownloadPayload)
            if self._addressGranularity == 1 or self._addressGranularity == 2:
                reqHdr = struct.pack(self._byteorder + "BB", cmdCode, self.byteToAG(remBytes))
            else:
                reqHdr = struct.pack(self._byteorder + "BBxx", cmdCode, self.byteToAG(remBytes))
            
            startOffset = len(data) - remBytes
            endOffset = startOffset + payloadBytes
            request = reqHdr + data[startOffset:endOffset]
            self._interface.transmit(request)
            remBytes -= payloadBytes
            self._calcMTA = Pointer(self._calcMTA.addr + self.byteToAG(payloadBytes), self._calcMTA.ext)
        
        replies = self._interface.receive(self._timeout)
        if len(replies) == 0:
            self._calcMTA = None
            raise Timeout()
        elif len(replies) > 1 or len(replies[0]) < 1 or replies[0][0] != 0xFF:
            # some kind of error
            self._calcMTA = None
            # if a reply that is not ERR_SEQUENCE, raise bad reply
            for reply in replies:
                if len(reply) < 2 or reply[0] != 0xFE or reply[1] != 0x29:
                    RaiseReply(reply, 'writing program block')  # not ERR_SEQUENCE
            # if replies are all ERR_SEQUENCE, raise packet lost (and potentially try again)
            raise PacketLost()
    def _program_block(self, ptr, data):
        return self._query(self._action_program_block, ptr, data)
    
    def _action_program_packet(self, ptr, data):
        if (len(data) % self._addressGranularity != 0) or (len(data) > self._pgmMaxDownloadPayload):
            raise InvalidOp()
        
        if self._calcMTA != ptr:
            self._setMTA(ptr)
            
        if self._addressGranularity == 1 or self._addressGranularity == 2:
            request = struct.pack(self._byteorder + "BB", 0xD0, len(data)) + data
        else:
            request = struct.pack(self._byteorder + "BBxx", 0xD0, len(data)) + data
        try:
            reply = self._transaction(request, "B")
        except Error:
            self._calcMTA = None
            raise
        
        if reply[0] != 0xFF:
            self._calcMTA = None
            RaiseReply(reply, 'writing program packet')
        else:
            self._calcMTA = Pointer(ptr.addr + self.byteToAG(len(data)), ptr.ext)
    
    def _program_packet(self, ptr, data):
        return self._query(self._action_program_packet, ptr, data)
    
    def program_range(self, ptr, data):
        if not self._pgmStarted:
            raise InvalidOp()
        if len(data) % self._addressGranularity != 0:
            raise InvalidOp()
        remBytes = len(data)
        if self._pgmMasterBlockMode:
            while remBytes > 0:
                blockBytes = min(remBytes, self._pgmMaxBS * self._pgmMaxDownloadPayload)
                blockStartBytes = len(data) - remBytes
                blockEndBytes = blockStartBytes + blockBytes
                blockStartPtr = Pointer(ptr.addr + self.byteToAG(blockStartBytes), ptr.ext)
                self._program_block(blockStartPtr, data[blockStartBytes:blockEndBytes])
                remBytes -= blockBytes
        else:
            while remBytes > 0:
                packetStartBytes = len(data) - remBytes
                packetBytes = min(remBytes, self._pgmMaxDownloadPayload)
                packetEndBytes = packetStartBytes + packetBytes
                packetStartPtr = Pointer(ptr.addr + self.byteToAG(packetStartBytes), ptr.ext)
                self._program_packet(packetStartPtr, data[packetStartBytes:packetEndBytes])
                remBytes -= packetBytes
    
    def _action_program_verify(self, crc):
        request = struct.pack(self._byteorder + "BBHL", 0xC8, 0x01, 0x0002, crc)
        reply = self._transaction(request, "B")
        if reply[0] != 0xFF:
            RaiseReply(reply, 'verifying program')

    def program_verify(self, crc):
        if not self._pgmStarted:
            raise InvalidOp()
        return self._query(self._action_program_verify, crc)
        
    def _action_program_reset(self):
        request = struct.pack(self._byteorder + "B", 0xCF)
        reply = self._transaction(request, "B")
        if reply[0] != 0xFF:
            RaiseReply(reply, 'resetting slave')
        self._pgmStarted = False

    def program_reset(self):
        if not self._pgmStarted:
            raise InvalidOp()
        return self._query(self._action_program_reset)
        pass

    def program_app(self, ptr, data, crc):  # high level function that performs the whole sequence
        self.program_start()
        self.program_clear(ptr, len(data))
        self.program_range(ptr, data)
        self.program_verify(crc)
        self.program_reset()
        pass
    
    def program_check(self, ptr, dataLength, crc):
        self.program_start()
        self._setMTA(Pointer(ptr.addr + dataLength, ptr.ext))
        try:
            self.program_verify(crc)
            return True
        except BadReply:
            return False
