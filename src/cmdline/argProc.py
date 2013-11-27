#!/usr/bin/python3.3

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
    try:
        structHeader,structName = name.split(':')
    except (TypeError,ValueError):
        raise ArgError('Invalid struct type \'' + str(name) + '\'')
    
    # Create the parser and process the header without making noise about no cache being available
    structParser = pyclibrary.CParser(structHeader, processAll=False)
    structParser.processAll(noCacheWarning=False)
    # Make the library that will actually contain the type
    structLibrary = pyclibrary.CLibrary(None, structParser)
    return getattr(structLibrary, structName)

def GetStructLocation(arg):
    try:
        segmentStr,baseaddrStr = arg.split(':')
        segment = int(segmentStr)
        baseaddr = int(baseaddrStr)
        return (segment, baseaddr)
    except (TypeError,ValueError):
        raise ArgError('Invalid struct location \'' + str(arg) + '\'')
