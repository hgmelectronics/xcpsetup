'''
Created on Aug 03, 2013

@author: dbrunner
'''

from collections import namedtuple


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

def getDataHexString(data):
	return ' '.join(format(x, '02x') for x in data)

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
    pass

_interfaceTypes = {}

def addInterface(interfaceType, cls):
    _interfaceTypes[interfaceType] = cls

def MakeInterface(interfaceType, name):
    if interfaceType == None:
        for interfaceType in _interfaceTypes:
            try:
                cls = _interfaceTypes[interfaceType]
                return cls(name)
            except (InterfaceNotSupported,ConnectFailed) as exc:
                print('Connecting to ' + interfaceType + ' interface failed: ' + str(exc))
        raise ConnectFailed('Could not connect to any available type of interface')
    else:
        cls = _interfaceTypes[interfaceType]
        if cls == None:
            raise InterfaceNotSupported
        return cls(name)
