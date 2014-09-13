#!/usr/bin/python3.3

import argparse
import sys

if not '..' in sys.path:
    sys.path.append('..')

from comm import BoardTypes
from comm import CANInterface
from comm import XCPConnection
from util import config
from util import plugins
import argProc
   
plugins.loadPlugins()
config.loadSysConfigs()

parser = argparse.ArgumentParser(description="uses program mode to reset a target device")
parser.add_argument('-c', nargs='*', help='Extra configuration files to load', dest='configFiles', default=[])
parser.add_argument('-d', help="CAN device URI", dest="deviceURI", default=None)
parser.add_argument('-T', help="Target device type (ibem,cda,cs2) for automatic XCP ID selection", dest="targetType", default=None)
parser.add_argument('-i', help="Target ID or range of IDs (e.g. 2, 1-3, recovery) for automatic XCP ID selection", dest="targetID", default=None)
parser.add_argument('-I', help="Search for targets on the network", action='count', dest='searchTargets')
parser.add_argument('-D', help="Dump all XCP traffic, for debugging purposes", dest="dumpTraffic", action="store_true", default=False)
args = parser.parse_args()
config.loadConfigs(args.configFiles)
BoardTypes.SetupBoardTypes()
try:
    boardType = BoardTypes.types[args.targetType]
except KeyError:
    print('Could not find board type ' + str(args.targetType))
    sys.exit(1)

maxAttempts = 10

# Connect to the bus

with CANInterface.MakeInterface(args.deviceURI) as interface:
    targetSlaves = boardType.SlaveListFromIdxArg(args.targetID)
    if args.searchTargets or len(targetSlaves) == 0:
        slaves = boardType.GetSlaves(interface)
        for i in range(0, len(slaves)):
            print(str(i) + ': ' + slaves[i][0].description() + ', ID ' + str(slaves[i][1]))
        index = int(input('Slave: '))
        if index >= len(slaves):
            exit
        targetSlaves = [slaves[index]]
                
    for targetSlave in targetSlaves:
        if targetSlave[1] != None:
            print('Resetting target addr ' + targetSlave[0].description() + ', ID ' + str(targetSlave[1]))
        else:
            print('Resetting target addr ' + targetSlave[0].description())
        
        for attempt in range(1, maxAttempts + 1):
            try:
                conn = boardType.Connect(interface, targetSlave, args.dumpTraffic)
                conn.program_start()
                conn.program_reset()
                print('Reset OK')
                programOK = True
                break
            except XCPConnection.Error as err:
                print('Reset failure (' + str(err) + '), attempt #' + str(attempt))
                programOK = False
        if not programOK:
            sys.exit(1)
