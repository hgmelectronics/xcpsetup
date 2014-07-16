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
from util import dictconfig
import argProc

def OpenOutFile(name, id):
    if name == None or name == '-':
        return sys.stdout
    else:
        return open(name.format(id), 'w')

plugins.load_plugins()

parser = argparse.ArgumentParser(description="reads data from a board using a JSON file to define locations and data formats")
parser.add_argument('-t', help="CAN device type", dest="deviceType", default=None)
parser.add_argument('-d', help="CAN device name", dest="deviceName", default=None)
parser.add_argument('-T', help="Target device type (ibem,cda,cs2) for automatic XCP ID selection", dest="targetType", default=None)
parser.add_argument('-i', help="Target ID or range of IDs (e.g. 2, 1-3, recovery) for automatic XCP ID selection", dest="targetID", default=None)
parser.add_argument('-p', help="Parameter definition file", dest="paramSpecFile", type=argparse.FileType('r'))
parser.add_argument('-s', help="XCP memory segment in which parameters reside", dest="paramSegment", default=0)
parser.add_argument('-o', help="Output file name (if range of IDs specified must contain a {} to be replaced with the ID)", dest="outputFile", default="-")
parser.add_argument('-D', help="Dump all XCP traffic, for debugging purposes", dest="dumpTraffic", action="store_true", default=False)
args = parser.parse_args()

try:
    boardType = argProc.GetBoardType(args.targetType)
    paramSpec = json.loads(args.paramSpecFile.read())
except argProc.ArgError as exc:
    print(str(exc))
    sys.exit(1)

maxAttempts = 10

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
                conn = boardType.Connect(interface, targetSlave, args.dumpTraffic)
                
                conn.set_cal_page(args.paramSegment, 0)
                data = dict()
                for param in paramSpec['parameters']:
                    data[param['name']] = dictconfig.ReadParam(param, paramSpec, conn)
                
                outFile.write(json.dumps(data, sort_keys=True, indent=4, separators=(',', ': ')))
                outFile.write('\n')
                if outFile != sys.stdout:
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
