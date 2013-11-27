#!/usr/bin/python3.3

import argparse
import ctypes
import json
import sys

if not '..' in sys.path:
    sys.path.append('..')

from comm import CANInterface
from comm import XCPConnection
from util import plugins
from util import ctypesdict
import argProc
   
plugins.load_plugins()

parser = argparse.ArgumentParser(description="writes data to a board using a C header file to define layout in memory")
parser.add_argument('-t', help="CAN device type", dest="deviceType", default=None)
parser.add_argument('-d', help="CAN device name", dest="deviceName", default=None)
parser.add_argument('-T', help="Target device type (ibem,cda,cs2) for automatic XCP ID selection", dest="targetType", default=None)
parser.add_argument('-i', help="Target ID or range of IDs (e.g. 2, 1-3, recovery) for automatic XCP ID selection", dest="targetID", default=None)
parser.add_argument('-l', help="Location of config structure in form <segment>:<baseaddr>", default="0:0", dest="structLocation")
parser.add_argument('-s', help="Config structure in form my.h:mystruct", dest="structSpec")
parser.add_argument('inputFile', help="Input file name (if range of IDs specified must contain a {} to be replaced with the ID)", default=None)
args = parser.parse_args()

try:
    boardType = argProc.GetBoardType(args.targetType)
    ConfigType = argProc.GetStructType(args.structSpec)
    structSegment,structBaseaddr = argProc.GetStructLocation(args.structLocation)
except ArgError as exc:
    print(str(exc))
    sys.exit(1)

maxAttempts = 10

def OpenInFile(name, id):
    if name == None:
        return sys.stdin
    else:
        return open(name.format(id), 'r')

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
        
        for attempt in range(1, maxAttempts + 1):
            try:
                inFile = OpenInFile(args.inputFile, targetSlave[1])
                inDict = json.loads(inFile.read())
                inFile.close()
                
                conn = boardType.Connect(interface, targetSlave)
                
                # Read the existing data from the board - in case the dict we have loaded does not cover the entire struct
                conn.set_cal_page(structSegment, 0)
                dataBuffer = conn.upload(XCPConnection.Pointer(structBaseaddr, 0), ctypes.sizeof(ConfigType))
                dataStruct = ConfigType.from_buffer_copy(dataBuffer)
                dataDict = ctypesdict.getdict(dataStruct)
                
                # Merge in data from the loaded dictionary
                dataDict.update(inDict)
                
                # Set the data in the struct from the dict
                writeDataStruct = ConfigType()
                ctypesdict.setfromdict(writeDataStruct, dataDict)
                writeDataBuffer=bytes(memoryview(writeDataStruct))
                
                # Write the new buffer to the board
                conn.download(XCPConnection.Pointer(structBaseaddr, 0), writeDataBuffer)
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

