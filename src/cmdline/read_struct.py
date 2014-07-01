#!/usr/bin/python3

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

parser = argparse.ArgumentParser(description="reads data from a board using a preparsed C struct to define layout in memory")
parser.add_argument('-t', help="CAN device type", dest="deviceType", default=None)
parser.add_argument('-d', help="CAN device name", dest="deviceName", default=None)
parser.add_argument('-T', help="Target device type (ibem,cda,cs2) for automatic XCP ID selection", dest="targetType", default=None)
parser.add_argument('-i', help="Target ID or range of IDs (e.g. 2, 1-3, recovery) for automatic XCP ID selection", dest="targetID", default=None)
parser.add_argument('-l', help="Location of structure in form <segment>:<baseaddr>", default="0:0", dest="structLocation")
parser.add_argument('-s', help="Pickled structure definition", dest="structSpec")
parser.add_argument('-o', help="Output file name (if range of IDs specified must contain a {} to be replaced with the ID)", dest="outputFile", default="-")
args = parser.parse_args()

try:
    boardType = argProc.GetBoardType(args.targetType)
    ConfigType = argProc.GetStructType(args.structSpec)
    structSegment,structBaseaddr = argProc.GetStructLocation(args.structLocation)
except argProc.ArgError as exc:
    print(str(exc))
    sys.exit(1)

maxAttempts = 10

def OpenOutFile(name, id):
    if name == None or name == '-':
        return sys.stdout
    else:
        return open(name.format(id), 'w')

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
        outFile=OpenOutFile(args.outputFile, targetSlave[1])
        if targetSlave[1] != None:
            sys.stderr.write('Connecting to target addr ' + targetSlave[0].description() + ', ID ' + str(targetSlave[1]) + '\n')
        else:
            sys.stderr.write('Connecting to target addr ' + targetSlave[0].description() + '\n')
        
        for attempt in range(1, maxAttempts + 1):
            try:
                conn = boardType.Connect(interface, targetSlave)
                
                conn.set_cal_page(structSegment, 0)
                dataBuffer = conn.upload(XCPConnection.Pointer(structBaseaddr, 0), ctypes.sizeof(ConfigType))
                dataStruct = ConfigType.from_buffer_copy(dataBuffer)
                data = ctypesdict.getdict(dataStruct)
                
                outFile.write(json.dumps(data, sort_keys=True, indent=4, separators=(',', ': ')))
                outFile.write('\n')
                outFile.close()
                try:
                    conn.close()
                except XCPConnection.Error:
                    pass # swallow any errors when closing connection due to bad target implementations - we really don't care
                
                sys.stderr.write('Read OK\n')
                readOK = True
                break
            except XCPConnection.Error as err:
                sys.stderr.write('Read failure (' + str(err) + '), attempt #' + str(attempt) + '\n')
                readOK = False
        if not readOK:
            sys.exit(1)
