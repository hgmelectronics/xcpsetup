#!/usr/bin/python3

import argparse
import ctypes
import json
import sys

if not '..' in sys.path:
    sys.path.append('..')

from comm import BoardTypes
from comm import CANInterface
from comm import XCPConnection
from util import plugins
from util import ctypesdict
from util import config
import argProc
   
plugins.loadPlugins()
config.loadSysConfigs()

parser = argparse.ArgumentParser(description="writes data to a board using a preparsed C struct to define layout in memory")
parser.add_argument('-c', nargs='*', help='Extra configuration files to load', dest='configFiles', default=[])
parser.add_argument('-d', help="CAN device URI", dest="deviceURI", default=None)
parser.add_argument('-T', help="Target device type (ibem,cda,cs2) for automatic XCP ID selection", dest="targetType", default=None)
parser.add_argument('-i', help="Target ID or range of IDs (e.g. 2, 1-3, recovery) for automatic XCP ID selection", dest="targetID", default=None)
parser.add_argument('-l', help="Location of config structure in form <segment>:<baseaddr>", default="0:0", dest="structLocation")
parser.add_argument('-s', help="Pickled structure definition", dest="structSpec")
parser.add_argument('-D', help="Dump all XCP traffic, for debugging purposes", dest="dumpTraffic", action="store_true", default=False)
parser.add_argument('-r', help='Maximum times to retry read-modify-write operation', dest='maxAttempts', default=10)
parser.add_argument('inputFile', help="Input file name (if range of IDs specified must contain a {} to be replaced with the ID)", default=None)
args = parser.parse_args()

config.loadConfigs(args.configFiles)
BoardTypes.SetupBoardTypes()
try:
    boardType = BoardTypes.types[args.targetType]
except KeyError:
    print('Could not find board type ' + str(args.targetType))
    sys.exit(1)

try:
    ConfigType = argProc.GetStructType(args.structSpec)
    structSegment,structBaseaddr = argProc.GetStructLocation(args.structLocation)
except argProc.ArgError as exc:
    print(str(exc))
    sys.exit(1)

def OpenInFile(name, idx):
    if name == None:
        return sys.stdin
    else:
        return open(name.format(idx), 'r')

with CANInterface.MakeInterface(args.deviceURI) as interface:
    targetSlaves = boardType.SlaveListFromIdxArg(args.targetID)
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
        
        for attempt in range(1, args.maxAttempts + 1):
            try:
                inFile = OpenInFile(args.inputFile, targetSlave[1])
                inDict = json.loads(inFile.read())
                inFile.close()
                
                conn = boardType.Connect(interface, targetSlave, args.dumpTraffic)
                
                # Read the existing data from the board - in case the dict we have loaded does not cover the entire struct
                conn.set_cal_page(structSegment, 0)
                dataBuffer = conn.upload(XCPConnection.Pointer(structBaseaddr, 0), ctypes.sizeof(ConfigType))
                dataStruct = ConfigType.from_buffer_copy(dataBuffer)
                
                # Set the data in the struct from the existing one
                writeDataStruct = dataStruct
                
                # Merge in data from the loaded dictionary
                ctypesdict.setfromdict(writeDataStruct, inDict)
                
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

