#!/usr/bin/python3.3
import getopt
import struct
import sys

sys.path.append('..')

import argparse
from comm import CANInterface
from comm import XCPConnection
from util import STCRC
from util import plugins
   
plugins.load_plugins()

parser = argparse.ArgumentParser(description="programs application code into an IBEM")
parser.add_argument('-t', help="CAN device type", dest="deviceType", default=None)
parser.add_argument('-d', help="CAN device name", dest="deviceName", default=None)
parser.add_argument('-i', help="Target ID or range of IDs (e.g. 1-3)", dest="targetID", default=None)
args = parser.parse_args()

if args.targetID == None:
    targetIDs = None
elif args.targetID == 'recovery':
    targetIDs = [-1]
elif args.targetID.find('-') >= 0:
    idStrs = args.targetID.split('-')
    if len(idStrs) != 2:
        print('Invalid ID argument \'' + args.targetID + '\'')
        sys.exit(1)
    targetIDs = range(int(idStrs[0]), int(idStrs[1]) + 1)
else:
    targetIDs = [int(args.targetID)]
    if targetIDs[0] < 0:
        print('Invalid ID argument \'' + args.targetID + '\'')
        sys.exit(1)

with CANInterface.MakeInterface(args.deviceType, args.deviceName) as interface:
    if targetIDs == None:
        slaves = XCPConnection.GetCANSlaves(interface, 0x9F000000, 0.2)
        for i in range(0, len(slaves)):
            print(str(i) + ': ' + slaves[i].description())
        index = int(input('Slave: '))
        if index >= len(slaves):
            exit
        targetSlaves = [slaves[index]]
    else:
        targetSlaves = []
        for targetID in targetIDs:
            if targetID >= 0:
                targetSlaves.append(CANInterface.XCPSlaveCANAddr(0x9F000100 + 2 * targetID, 0x9F000101 + 2 * targetID))
            else:
                targetSlaves.append(CANInterface.XCPSlaveCANAddr(0x9F000010, 0x9F000011))
                
    for targetSlave in targetSlaves:
        print('Resetting target addr ' + targetSlave.description())
        attempts = 1
        while 1:
            try:
                interface.connect(targetSlave)
                conn = XCPConnection.Connection(interface, 0.5, 2.0)
                conn.program_start()
                conn.program_reset()
                print('OK')
                break
            except XCPConnection.Error as err:
                print('Failure (' + str(err) + '), retry #' + str(attempts))
                if attempts >= 10:
                    sys.exit(1)
            attempts = attempts + 1
