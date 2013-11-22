'''
Created on Aug 03, 2013

@author: dbrunner
'''
from collections import namedtuple
from urllib.parse import urlparse

class ID(object):
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

Packet = namedtuple('Packet', ['ident', 'data'])

class XCPSlaveCANAddr(object):
    '''
    XCP slave that exists on the CAN network.
    '''
    
    def __init__(self, cmdId, resId):
        self.cmdId = ID(cmdId)
        self.resId = ID(resId)
    
    def description(self):
        return "CAN %(cmd)s / %(res)s" % {'cmd': self.cmdId.getString(), 'res': self.resId.getString()}

class Error(Exception):
    def __init__(self, value=None):
        self._value = value
    def __str__(self):
        return repr(self._value)

class ConnectFailed(Exception):
    def __init__(self, value=None):
        self._value = value
    def __str__(self):
        return repr(self._value)

class InterfaceNotSupported(Exception):
    def __init__(self, value=None):
        self._value = value
    def __str__(self):
        return repr(self._value)

class Interface(object):
    def __init__(self, parsedURL):
        pass
    
    def close(self):
        pass
    
    def connect(self, address):
        pass
    
    def disconnect(self):
        pass

    def transmit(self, data):
        pass
        
    def transmitTo(self, data, ident):
        pass
    
    def receive(self, timeout):
        pass
        
    def receivePackets(self, timeout):
        pass
    
_interfaceTypes = {}

def addInterface(interfaceType, cls):
    _interfaceTypes[interfaceType] = cls

def MakeInterface(url):
    parsedURL = urllib.urlparse(url)
    cls = _interfaceTypes[parsedURL.scheme]
            try:
                cls = _interfaceTypes[interfaceType]
                return cls(name)
            except (InterfaceNotSupported,ConnectFailed) as exc:
                print('Connecting to ' + interfaceType + ' interface failed: ' + str(exc))
        raise ConnectFailed('Could not connect to any available type of interface')
    else:
        if cls == None:
            raise InterfaceNotSupported
    return cls(parsedURL)
