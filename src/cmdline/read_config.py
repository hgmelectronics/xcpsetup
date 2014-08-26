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

def OpenOutFile(name, idx):
    if name == None or name == '-':
        return sys.stdout
    else:
        return open(name.format(idx), 'w')

plugins.loadPlugins()
config.loadSysConfigs()

parser = argparse.ArgumentParser(description="reads data from a board using a JSON file to define locations and data formats")
parser.add_argument('-c', nargs='*', help='Extra configuration files to load', dest='configFiles', default=[])
parser.add_argument('-d', help="CAN device URI", dest="deviceURI", required=True)
parser.add_argument('-T', help="Target device type", dest="targetType", required=True)
parser.add_argument('-i', help="Target ID or range of IDs (e.g. 2, 1-3, recovery) for automatic XCP ID selection", dest="targetID", default=None)
parser.add_argument('-p', help="Parameter definition file", dest="paramSpecFile", type=argparse.FileType('r'), required=True)
parser.add_argument('-s', help="XCP memory segment in which parameters reside", dest="paramSegment", default=0)
parser.add_argument('-o', help="Output file name (if range of IDs specified must contain a {} to be replaced with the ID)", dest="outputFile", default="-")
parser.add_argument('-D', help="Dump all XCP traffic, for debugging purposes", dest="dumpTraffic", action="store_true", default=False)
args = parser.parse_args()

config.loadConfigs(args.configFiles)
BoardTypes.SetupBoardTypes()
try:
    boardType = BoardTypes.types[args.targetType]
except KeyError:
    print('Could not find board type ' + str(args.targetType))
    sys.exit(1)

paramSpec = json.loads(args.paramSpecFile.read())

maxAttempts = 10

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
