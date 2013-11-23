#!/usr/bin/python3.3
import json
import struct
import sys
import argparse

sys.path.append('..')

from comm import CANInterface
from comm import XCPConnection
from comm import BoardTypes
from util import plugins
import ctypes
from util import ctypesdict
import pyclibrary

def OpenInFile(name, id):
    if name == None:
        return sys.stdin
    else:
        return open(name.format(id), 'r')
   
plugins.load_plugins()

parser = argparse.ArgumentParser(description="writes data to a board using a C header file to define layout in memory")
parser.add_argument('-t', help="CAN device type", dest="deviceType", default=None)
parser.add_argument('-d', help="CAN device name", dest="deviceName", default=None)
parser.add_argument('-T', help="Target device type (ibem,cda,cs2) for automatic XCP ID selection", dest="targetType", default=None)
parser.add_argument('-i', help="Target ID or range of IDs (e.g. 2, 1-3, recovery) for automatic XCP ID selection", dest="targetID", default=None)
parser.add_argument('-l', help="Location of config structure in form <segment>:<baseaddr>", default="0:0", dest=structLocation)
parser.add_argument('-s', help="Config structure in form my.h:mystruct", dest="structSpec")
parser.add_argument('inputFile', help="Input file name (if range of IDs specified must contain a {} to be replaced with the ID)", default=None)
args = parser.parse_args()

class ArgError(Exception):
    def __init__(self, value=None):
        self._value = value
    def __str__(self):
        if self._value != None:
            return 'Invalid argument ' + self._value
        else:
            return 'Invalid argument'

try:
    boardType = BoardTypes.ByName(args.targetType)
except KeyError:
    raise ArgError('Invalid target type \'' + args.targetType + '\'')
maxAttempts = 10

structHeader,structName=args.structSpec.split(':')
structParser=pyclibrary.CParser(structHeader, processAll=False)
structParser.processAll(noCacheWarning=False)
structLibrary=pyclibrary.CLibrary(None, structParser)
ConfigType=getattr(structLibrary, structName)
structSegment,structBaseaddr=args.structLocation.split(':')

with CANInterface.MakeInterface(args.deviceType, args.deviceName) as interface:
    targetSlaves = boardType.SlaveListFromIDArg(args.targetID)
    # If needed, ask the user to pick a slave from the list
    if len(targetSlaves) == 0:
        slaves = boardType.GetSlaves(interface)
        for i in range(0, len(slaves)):
            print(str(i) + ': ' + slaves[i][0].description() + ', ID ' + str(slaves[i][1]))
        index = int(input('Slave: '))
        if index >= len(slaves):
            exit
        targetSlaves = [slaves[index]]
                
    for targetSlave in targetSlaves:
        if targetSlave[1] != None:
            print('Connecting to target addr ' + targetSlave[0].description() + ', ID ' + str(targetSlave[1]))
        else:
            print('Connecting to target addr ' + targetSlave[0].description())
        
        for attempt in range(1, maxAttempts + 1)
            try:
                inFile = OpenInFile(args.inputFile, targetSlave[1])
                inDict = json.loads(inFile.read())
                inFile.close()
                
                conn = boardType.Connect(interface, targetSlave)
                
                # Read the existing data from the board - in case the dict we have loaded does not cover the entire struct
                conn.set_cal_page(structSegment, 0)
                dataBuffer = conn.upload(XCPConnection.Pointer(structBaseaddr, 0), sizeof(ConfigType))
                dataStruct = ConfigType.from_buffer(dataBuffer)
                dataDict = ctypesdict.getdict(dataStruct)
                
                # Merge in data from the loaded dictionary
                dataDict.update(inDict)
                
                # Set the data in the struct from the dict; since the struct was created with a reference to the buffer, the buffer gets updated
                ctypesdict.setfromdict(dataStruct, dataDict)
                
                # Write the new buffer to the board
                conn.download(XCPConnection.Pointer(structBaseaddr, 0), dataBuffer)
                conn.nvwrite()
                
                try:
                    conn.close()
                except XCPConnection.Error:
                    pass # swallow any errors when closing connection due to bad target implementations - we really don't care
                
                print('Write OK')
                writeOK = True
                break
            except XCPConnection.Error as err:
                print('Write failure (' + str(err) + '), attempt #' + str(attempt))
                writeOK = False
        if not writeOK:
            sys.exit(1)

