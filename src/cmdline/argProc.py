#!/usr/bin/python3

import ctypes

from comm import BoardTypes
from comm import XCPConnection
from util import ctypesdict
import pyclibrary

class ArgError(Exception):
    def __init__(self, value=None):
        self._value = value
    def __str__(self):
        if self._value != None:
            return 'Invalid argument: ' + self._value
        else:
            return 'Invalid argument'

def GetBoardType(name):
    try:
        return BoardTypes.ByName[name]
    except KeyError:
        raise ArgError('Invalid target type \'' + str(name) + '\'')

def GetStructType(name):
    # Create the parser 
    structParser = pyclibrary.CParser(processAll=None)
    structParser.loadCache(name)
    # Make the library that will actually contain the type
    structLibrary = pyclibrary.CLibrary(None, structParser)
    return getattr(structLibrary, '_struct')

def GetStructLocation(arg):
    try:
        segmentStr,baseaddrStr = arg.split(':')
        segment = int(segmentStr)
        baseaddr = int(baseaddrStr)
        return (segment, baseaddr)
    except (TypeError,ValueError):
        raise ArgError('Invalid struct location \'' + str(arg) + '\'')
