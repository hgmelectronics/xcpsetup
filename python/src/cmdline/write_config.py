#!/usr/bin/python3

import argparse
import json
import sys

if not '..' in sys.path:
    sys.path.append('..')

from comm import BoardTypes
from comm import CANInterface
from comm import XCPConnection
from util import plugins
from util import dictconfig
from util import config

plugins.loadPlugins()
config.loadSysConfigs()

parser = argparse.ArgumentParser(description="reads data from a board using a JSON file to define locations and data formats")
parser.add_argument('-c', nargs='*', help='Extra configuration files to load', dest='configFiles', default=[])
parser.add_argument('-d', help="CAN device URI", dest="deviceURI", required=True)
parser.add_argument('-T', help="Target device type (ibem,cda,cs2) for automatic XCP ID selection", dest="targetType", required=True)
parser.add_argument('-i', help="Target ID or range of IDs (e.g. 2, 1-3, recovery) for automatic XCP ID selection", dest="targetID", default=None)
parser.add_argument('-p', help="Parameter definition file", dest="paramSpecFile", type=argparse.FileType('r'), required=True)
parser.add_argument('-s', help="XCP memory segment in which parameters reside", dest="paramSegment", default=0)
parser.add_argument('-D', help="Dump all XCP traffic, for debugging purposes", dest="dumpTraffic", action="store_true", default=False)
parser.add_argument('-n', help="Write to nonvolatile memory", dest="nvWrite", action="store_true", default=False)
parser.add_argument('inputFile', help="Input file name (if range of IDs specified must contain a {} to be replaced with the ID)", default=None)
args = parser.parse_args()

config.loadConfigs(args.configFiles)
BoardTypes.SetupBoardTypes()
try:
    boardType = BoardTypes.types[args.targetType]
except KeyError:
    print('Could not find board type ' + str(args.targetType))

paramSpec = json.loads(args.paramSpecFile.read())

paramDict = dict()
for param in paramSpec['parameters']:
    paramDict[param['name']] = param

maxAttempts = 10

def OpenInFile(name, idx):
    if name == None:
        return sys.stdin
    else:
        return open(name.format(idx), 'r')

with CANInterface.MakeInterface(args.deviceURI) as interface:
    targetSlaves = boardType.SlaveListFromIdxArg(args.targetID)
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
            sys.stderr.write('Connecting to target addr ' + targetSlave[0].description() + ', ID ' + str(targetSlave[1]) + '\n')
        else:
            sys.stderr.write('Connecting to target addr ' + targetSlave[0].description() + '\n')
        
        inFile = OpenInFile(args.inputFile, targetSlave[1])
        inDict = json.loads(inFile.read())
        inFile.close()
        
        conn = boardType.Connect(interface, targetSlave, args.dumpTraffic)
        
        conn.set_cal_page(args.paramSegment, 0)
        for name in inDict:
            attempts = 0
            while 1:
                try:
                    dictconfig.WriteParam(inDict[name], paramDict[name], paramSpec, conn)
                    break
                except XCPConnection.Error as err:
                    attempts = attempts + 1
                    if attempts == maxAttempts:
                        sys.stderr.write('Write failure (' + str(err) + ')\n')
                        sys.exit(1)
                    else:
                        sys.stderr.write('Write failure (' + str(err) + '), retrying\n')
        
        sys.stderr.write('Write OK\n')
        
        if args.nvWrite:
            conn.nvwrite()
            sys.stderr.write('NV save OK\n')
        
        try:
            conn.close()
        except XCPConnection.Error:
            pass # swallow any errors when closing connection due to bad target implementations - we really don't care
