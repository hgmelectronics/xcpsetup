'''
Created on Jun 23, 2013

@author: gcardwel
'''

from collections import namedtuple
import struct
import time
from CANInterface import *

XCPPointer = namedtuple('XCPPointer', ['addr', 'ext'])


def XCPGetCANSlaves(interface, bcastId, timeout):
    request = struct.pack("BBBBBB", 0xF2, 0xFF, 0x58, 0x43, 0x50, 0x00)
    interface.transmitTo(request, bcastId)
    time.sleep(timeout)
    slaves = []
    for packet in interface.receivePackets(0.0):
        try:
            data = struct.unpack("!BBBBL", packet.data)
            if data[0] == 0xFF and data[1] == 0x58 and data[2] == 0x43 and data[3] == 0x50:
                slaves.append(XCPSlaveCANAddr(data[4], packet.ident))
        except struct.error:
            pass
    return slaves
    
    
class XCPError(Exception):
    pass


class XCPTimeout(XCPError):
    pass


class XCPInvalidOp(XCPError):
    pass


class XCPBadReply(XCPError):
    pass


class XCPConnection(object):
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
        #temporarily set byteorder to allow transaction
        self._byteorder = "@"
        request = struct.pack("BB", 0xFF, 0x00)
        reply = self._transaction(request, "BBBBBBBB")
        if reply[0] != 0xFF:
            raise XCPBadReply()
        self._calPage = reply[1] & 0x01
        self._daq = reply[1] & 0x04
        self._stim = reply[1] & 0x08
        self._pgm = reply[1] & 0x10
        if not self._calPage:
            close()
            raise XCPBadReply()
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
            close()
            raise XCPBadReply()
        
        self._maxCTO = reply[3]
        
        if reply[6] != 0x01 or reply[7] != 0x01:
            close()
            raise XCPBadReply()

    def close(self):
        request = struct.pack(self._byteorder + "B", 0xFE)
        try:
            reply = self._transaction(request, "BB")
				    #expect no response, hence timeout
        except XCPTimeout:
            return
        raise XCPBadReply()
    
    def _transaction(self, request, fmt):
        self._interface.transmit(request)
        received = self._interface.receive(self._timeout)
        replies = [rep for rep in received if rep[0] == 0xFF or rep[0] == 0xFE]
        if len(replies) < 1:
            raise XCPTimeout()
        if len(replies) > 1:
            raise XCPBadReply()
        try:
            #print('Send ' + repr([hex(elem) for elem in request]) + ' Reply ' + repr([hex(elem) for elem in replies[0]]))
            reply = struct.unpack_from(self._byteorder + fmt, replies[0])
            return reply
        except struct.error:
            raise XCPBadReply()
    
    def _setMTA(self, ptr):
        request = struct.pack(self._byteorder + "BBBBL", 0xF6, 1, 0, ptr.ext, ptr.addr)
        reply = self._transaction(request, "B")
        if reply[0] != 0xFF:
            raise XCPBadReply()
    
    def upload8(self, ptr):
        if self._addressGranularity == 1:
            request = struct.pack(self._byteorder + "BBBBL", 0xF4, 1, 0, ptr.ext, ptr.addr)
            reply = self._transaction(request, "BB")
            if reply[0] != 0xFF:
                raise XCPBadReply()
            return reply[1]
        else:
            raise XCPInvalidOp()

    def upload16(self, ptr):
        if self._addressGranularity == 1:
            request = struct.pack(self._byteorder + "BBBBL", 0xF4, 2, 0, ptr.ext, ptr.addr)
            reply = self._transaction(request, "BH")
        elif self._addressGranularity == 2:
            request = struct.pack(self._byteorder + "BBBBL", 0xF4, 1, 0, ptr.ext, ptr.addr)
            reply = self._transaction(request, "BxH")
        else:
            raise XCPInvalidOp()
        if reply[0] != 0xFF:
            raise XCPBadReply()
        return reply[1]
    
    def upload32(self, ptr):
        if self._addressGranularity == 1:
            request = struct.pack(self._byteorder + "BBBBL", 0xF4, 4, 0, ptr.ext, ptr.addr)
            reply = self._transaction(request, "BL")
        elif self._addressGranularity == 2:
            request = struct.pack(self._byteorder + "BBBBL", 0xF4, 2, 0, ptr.ext, ptr.addr)
            reply = self._transaction(request, "BxL")
        elif self._addressGranularity == 4:
            request = struct.pack(self._byteorder + "BBBBL", 0xF4, 1, 0, ptr.ext, ptr.addr)
            reply = self._transaction(request, "BxxxL")
        else:
            raise XCPInvalidOp()
        if reply[0] != 0xFF:
            raise XCPBadReply()
        return reply[1]

    def download8(self, ptr, data):
        if self._addressGranularity > 1:
            raise XCPInvalidOp()
        self._setMTA(ptr)
        request = struct.pack(self._byteorder + "BBB", 0xF0, 1, data)
        reply = self._transaction(request, "B")
        if reply[0] != 0xFF:
            raise XCPBadReply()

    def download16(self, ptr, data):
        if self._addressGranularity == 1:
            request = struct.pack(self._byteorder + "BBH", 0xF0, 2, data)
        elif self._addressGranularity == 2:
            request = struct.pack(self._byteorder + "BBH", 0xF0, 1, data)
        else:
            raise XCPInvalidOp()
        self._setMTA(ptr)
        reply = self._transaction(request, "B")
        if reply[0] != 0xFF:
            raise XCPBadReply()

    def download32(self, ptr, data):
        if self._addressGranularity == 1:
            request = struct.pack(self._byteorder + "BBL", 0xF0, 4, data)
        elif self._addressGranularity == 2:
            request = struct.pack(self._byteorder + "BBL", 0xF0, 2, data)
        else:
            request = struct.pack(self._byteorder + "BBxxL", 0xF0, 1, data)
        self._setMTA(ptr)
        reply = self._transaction(request, "B")
        if reply[0] != 0xFF:
            raise XCPBadReply()
    
    def nvwrite(self):
        request = struct.pack(self._byteorder + "BBH", 0xF9, 0x01, 0)
        reply = self._transaction(request, "B")
        if reply[0] != 0xFF:
            raise XCPBadReply()
        
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
                raise XCPBadReply()
            if not (reply[1] & 0x01):
                return
                
        # Exited loop due to timeout
        raise XCPTimeout()
