#!/usr/bin/python3.3

import argparse
import sys

if not '..' in sys.path:
    sys.path.append('..')

from comm import CANInterface
from comm import XCPConnection
from util import plugins
import argProc
   
plugins.load_plugins()

parser = argparse.ArgumentParser(description="programs application code into an IBEM")
parser.add_argument('-t', help="CAN device type", dest="deviceType", default=None)
parser.add_argument('-d', help="CAN device name", dest="deviceName", default=None)
parser.add_argument('-T', help="Target device type (ibem,cda,cs2) for automatic XCP ID selection", dest="targetType", default=None)
parser.add_argument('-i', help="Target ID or range of IDs (e.g. 2, 1-3, recovery) for automatic XCP ID selection", dest="targetID", default=None)
args = parser.parse_args()

try:
    boardType = argProc.GetBoardType(args.targetType)
except argProc.ArgError as exc:
    print(str(exc))
    sys.exit(1)

maxAttempts = 10

# Connect to the bus

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
            print('Resetting target addr ' + targetSlave[0].description() + ', ID ' + str(targetSlave[1]))
        else:
            print('Resetting target addr ' + targetSlave[0].description())
        
        for attempt in range(1, maxAttempts + 1):
            try:
                conn = boardType.Connect(interface, targetSlave)
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
