'''
Created on Jun 23, 2013

@author: gcardwel
'''

from collections import namedtuple
import struct
import time
from CANInterface import *

XCPPointer = namedtuple('addr', 'ext')

class XCPSlaveCANAddr(object):
    '''
    XCP slave that exists on the CAN network.
    '''
    
    def __init__(self, cmdId, resId):
        self.cmdId = CANID(cmdId)
        self.resId = CANID(cmdId)
    
    def description(self):
        return "CAN %s / %s" % cmdId.getString() % resId.getString()


def XCPGetCANSlaves(interface, bcastId, timeout):
    request = struct.pack("BBBBBB", 0xF2, 0xFF, 0x58, 0x43, 0x50, 0x00)
    interface.sendto(request, bcastId)
    time.sleep(timeout)
    slaves = []
    for packet in interface.recv(0):
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
    def __init__(self, interface, timeout):
        '''
        Constructor - assumes interface is already connected (knows target device address)
        Performs XCP connection sequence
        '''
        _interface = interface
        _timeout = timeout
        '''temporarily set byteorder to allow transaction'''
        _byteorder = "@"
        request = struct.pack("BB", [0xFF, 0x00])
        reply = _transaction(request, "BBBBBBBB")
        if reply[0] != 0xFF
            raise XCPBadReply()
        _calPage = reply[1] & 0x01
        _daq = reply[1] & 0x04
        _stim = reply[1] & 0x08
        _pgm = reply[1] & 0x10
        if not _calPage:
            close()
            raise XCPBadReply()
        if reply[2] & 0x01:
            _byteorder = ">"
            _maxDTO = reply[4] << 8 | reply[5]
        else:
            _byteorder = "<"
            _maxDTO = reply[5] << 8 | reply[4]
        
        if (reply[2] & 0x06) == 0x00:
            _addressGranularity = 1
        else if (reply[2] & 0x06) == 0x02:
            _addressGranularity = 2
        else if (reply[2] & 0x06) == 0x04:
            _addressGranularity = 4
        else
            close()
            raise XCPBadReply()
        
        _maxCTO = reply[3]
        
        if reply[6] != 0x01 or reply[7] != 0x01
            close()
            raise XCPBadReply()

    def close(self):
        request = struct.pack(_byteorder + "B", [0xFE])
        try:
            reply = _transaction(request, "BB")
        '''expect no response, hence timeout'''
        except XCPTimeout:
            return
        raise XCPBadReply()
    
    def _transaction(self, request, fmt):
        _interface.send(request)
        replies = _interface.recv(_timeout)
        if length(replies) < 1
            raise XCPTimeout()
        if length(replies) > 1
            raise XCPBadReply()
        try:
            reply = struct.unpack_from(_byteorder + fmt, replies[0])
        except struct.error:
            raise XCPBadReply()
    
    def _setMTA(self, ptr):
        request = struct.pack(_byteorder + "BBBBL", [0xF6, 1, 0, ptr.ext, ptr.addr])
        reply = _transaction(request, "B")
        if reply[0] != 0xFF
            raise XCPBadReply()
    
    def upload8(self, ptr, data):
        if _addressGranularity == 1:
            request = struct.pack(_byteorder + "BBBBL", [0xF4, 1, 0, ptr.ext, ptr.addr)
            reply = _transaction(request, "BB")
            if reply[0] != 0xFF
                raise XCPBadReply()
            return reply[1]
        else:
            raise XCPInvalidOp()

    def upload16(self, ptr, buffer):
        if _addressGranularity == 1:
            request = struct.pack(_byteorder + "BBBBL", [0xF4, 2, 0, ptr.ext, ptr.addr)
            reply = _transaction(request, "BH")
        else if _addressGranularity == 2:
            request = struct.pack(_byteorder + "BBBBL", [0xF4, 1, 0, ptr.ext, ptr.addr)
            reply = _transaction(request, "BxH")
        else:
            raise XCPInvalidOp()
        if reply[0] != 0xFF
            raise XCPBadReply()
        return reply[1]
    
    def upload32(self, ptr, buffer):
        if _addressGranularity == 1:
            request = struct.pack(_byteorder + "BBBBL", [0xF4, 4, 0, ptr.ext, ptr.addr)
            reply = _transaction(request, "BL")
        else if _addressGranularity == 2:
            request = struct.pack(_byteorder + "BBBBL", [0xF4, 2, 0, ptr.ext, ptr.addr)
            reply = _transaction(request, "BxL")
        else if _addressGranularity == 4:
            request = struct.pack(_byteorder + "BBBBL", [0xF4, 1, 0, ptr.ext, ptr.addr)
            reply = _transaction(request, "BxxxL")
        else:
            raise XCPInvalidOp()
        if reply[0] != 0xFF
            raise XCPBadReply()
        return reply[1]

    def download8(self, ptr, data):
        if _addressGranularity > 1:
            raise XCPInvalidOp()
        _setMTA(ptr)
        request = struct.pack(_byteorder + "BBB", [0xF0, 1, data])
        reply = _transaction(request, "B")
        if reply[0] != 0xFF
            raise XCPBadReply()

    def download16(self, ptr, data):
        if _addressGranularity == 1:
            request = struct.pack(_byteorder + "BBH", [0xF0, 2, data])
        else if _addressGranularity == 2:
            request = struct.pack(_byteorder + "BBH", [0xF0, 1, data])
        else:
            raise XCPInvalidOp()
        _setMTA(ptr)
        reply = _transaction(request, "B")
        if reply[0] != 0xFF
            raise XCPBadReply()

    def download32(self, ptr, data):
        if _addressGranularity == 1:
            request = struct.pack(_byteorder + "BBL", [0xF0, 4, data])
        else if _addressGranularity == 2:
            request = struct.pack(_byteorder + "BBL", [0xF0, 2, data])
        else:
            request = struct.pack(_byteorder + "BBxxL", [0xF0, 1, data])
        _setMTA(ptr)
        reply = _transaction(request, "B")
        if reply[0] != 0xFF
            raise XCPBadReply()
