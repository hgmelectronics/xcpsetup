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
    pass


class Timeout(Error):
    def __init__(self, value=None):
        self._value = value
    def __str__(self):
        if self._value != None:
            return 'Timeout in ' + self._value
        else:
            return 'Timeout'

class InvalidOp(Error):
    def __init__(self, value=None):
        self._value = value
    def __str__(self):
        if self._value != None:
            return 'Invalid operation attempted in ' + self._value
        else:
            return 'Invalid operation attempted'

class BadReply(Error):
    def __init__(self, value=None):
        self._value = value
    def __str__(self):
        if self._value != None:
            return 'Unexpected reply from slave in ' + self._value
        else:
            return 'Unexpected reply from slave'

class PacketLost(Error):
    def __init__(self, value=None):
        self._value = value
    def __str__(self):
        if self._value != None:
            return 'Block mode packet lost in ' + self._value
        else:
            return 'Block mode packet lost'

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
            raise BadReply()
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
            raise BadReply()
        
        self._maxCTO = reply[3]
        
        self._maxDownloadPayload = self.byteToAG(self._maxCTO - 2) * self._addressGranularity
        self._maxUploadPayload = self.byteToAG(self._maxCTO - 1) * self._addressGranularity
        
        if reply[6] != 0x01 or reply[7] != 0x01:
            self.close()
            raise BadReply()
    
    def byteToAG(self, data):
        return int(data / self._addressGranularity)

    def close(self):
        request = struct.pack(self._byteorder + "B", 0xFE)
        reply = self._transaction(request, "B")
        if reply[0] != 0xFF:
            raise BadReply()
        self._pgmStarted = False
    
    def _getReply(self, fmt, timeout):
        received = self._interface.receive(timeout)
        replies = [rep for rep in received if rep[0] == 0xFF or rep[0] == 0xFE]
        if len(replies) < 1:
            raise Timeout()
        if len(replies) > 1:
            raise BadReply()
        try:
            # print('Send ' + repr([hex(elem) for elem in request]) + ' Reply ' + repr([hex(elem) for elem in replies[0]]))
            reply = struct.unpack_from(self._byteorder + fmt, replies[0])
            return reply
        except struct.error:
            raise BadReply()
    
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
            raise BadReply()
    
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
                except Timeout:
                    failures += 1  # If max number of failures is reached, inner loop exits, then so does outer loop
        raise Timeout()
    
    def _setMTA(self, ptr):
        request = struct.pack(self._byteorder + "BBBBL", 0xF6, 1, 0, ptr.ext, ptr.addr)
        try:
            reply = self._transaction(request, "B")
        except Error:
            self._calcMTA = None
            raise
        if reply[0] != 0xFF:
            self._calcMTA = None
            raise BadReply()
        self._calcMTA = ptr
    
    def _action_upload8(self, ptr):
        if self._addressGranularity == 1:
            request = struct.pack(self._byteorder + "BBBBL", 0xF4, 1, 0, ptr.ext, ptr.addr)
            
            try:
                reply = self._transaction(request, "BB")
            except Error:
                self._calcMTA = None
                raise
            
            if reply[0] != 0xFF:
                self._calcMTA = None
                raise BadReply()
            else:
                self._calcMTA = Pointer(ptr.addr + 1, ptr.ext)
                return reply[1]
        else:
            raise InvalidOp()
    
    def upload8(self, ptr):
        return self._query(self._action_upload8, ptr)

    def _action_upload16(self, ptr):
        if self._addressGranularity == 1:
            request = struct.pack(self._byteorder + "BBBBL", 0xF4, 2, 0, ptr.ext, ptr.addr)
            decodeFormat = "BH"
        elif self._addressGranularity == 2:
            request = struct.pack(self._byteorder + "BBBBL", 0xF4, 1, 0, ptr.ext, ptr.addr)
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
            raise BadReply()
        else:
            self._calcMTA = Pointer(ptr.addr + self.byteToAG(2), ptr.ext)
            return reply[1]
    
    def upload16(self, ptr):
        return self._query(self._action_upload16, ptr)
    
    def _action_upload32(self, ptr):
        if self._addressGranularity == 1:
            request = struct.pack(self._byteorder + "BBBBL", 0xF4, 4, 0, ptr.ext, ptr.addr)
            decodeFormat = "BL"
        elif self._addressGranularity == 2:
            request = struct.pack(self._byteorder + "BBBBL", 0xF4, 2, 0, ptr.ext, ptr.addr)
            decodeFormat = "BxL"
        elif self._addressGranularity == 4:
            request = struct.pack(self._byteorder + "BBBBL", 0xF4, 1, 0, ptr.ext, ptr.addr)
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
            raise BadReply()
        else:
            self._calcMTA = Pointer(ptr.addr + self.byteToAG(4), ptr.ext)
            return reply[1]
    
    def upload32(self, ptr):
        return self._query(self._action_upload32, ptr)

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
            raise BadReply()
        else:
            self._calcMTA = Pointer(ptr.addr + 1, ptr.ext)
    
    def download8(self, ptr, data):
        if not self._calPage:
            raise BadReply()
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
            raise BadReply()
        else:
            self._calcMTA = Pointer(ptr.addr + self.byteToAG(2), ptr.ext)
    
    def download16(self, ptr, data):
        if not self._calPage:
            raise BadReply()
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
            raise BadReply()
        else:
            self._calcMTA = Pointer(ptr.addr + self.byteToAG(4), ptr.ext)
    
    def download32(self, ptr, data):
        if not self._calPage:
            raise BadReply()
        return self._query(self._action_download32, ptr, data)
    
    def _action_nvwrite(self):
        request = struct.pack(self._byteorder + "BBH", 0xF9, 0x01, 0)
        reply = self._transaction(request, "B")
        if reply[0] != 0xFF:
            raise BadReply()
        
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
                raise BadReply()
            if not (reply[1] & 0x01):
                return
                
        # Exited loop due to timeout
        raise Timeout()
    
    def nvwrite(self):
        if not self._calPage:
            raise BadReply()
        return self._query(self._action_nvwrite)
    
    def _action_program_start(self):
        request = struct.pack(self._byteorder + "B", 0xD2)
        reply = self._transaction(request, "BxBBBBB")
        if reply[0] != 0xFF or reply[2] < 8:
            raise BadReply()
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
    
    def program_start(self):
        return self._query(self._action_program_start)
    
    def _action_program_clear(self, ptr, length):
        if self._calcMTA != ptr:
            self._setMTA(ptr)
        request = struct.pack(self._byteorder + "BBxxL", 0xD1, 0x00, length)
        self._calcMTA = None  # standard does not define what happens to MTA
        reply = self._transaction(request, "B", self._nvWriteTimeout)
        if reply[0] != 0xFF:
            raise BadReply()
    
    def program_clear(self, ptr, length):
        if not self._pgmStarted:
            raise InvalidOp()
        return self._query(self._action_program_clear, ptr, length)
    
    def _action_program_block(self, ptr, data):
        if (len(data) % self._addressGranularity != 0) or (self.byteToAG(len(data)) > self._pgmMaxBS):
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
                        raise BadReply()  # not ERR_SEQUENCE
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
                    raise BadReply()  # not ERR_SEQUENCE
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
            raise BadReply()
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
                blockBytes = min(remBytes, self._pgmMaxBS * self._addressGranularity)
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
    
    def _action_program_verify(self, ptr, crc):
        request = struct.pack(self._byteorder + "BBHL", 0xC8, 0x01, 0x0002, crc)
        reply = self._transaction(request, "B")
        if reply[0] != 0xFF:
            raise BadReply()

    def program_verify(self, ptr, crc):
        if not self._pgmStarted:
            raise InvalidOp()
        return self._query(self._action_program_verify, ptr, crc)
        
    def _action_program_reset(self):
        request = struct.pack(self._byteorder + "B", 0xCF)
        reply = self._transaction(request, "B")
        if reply[0] != 0xFF:
            raise BadReply()
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
        self.program_verify(ptr, crc)
        self.program_reset()
        pass
