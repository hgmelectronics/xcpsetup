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
parser.add_argument('-c', help="If CRC matches what is already in flash, do not reprogram", action='count', dest='crcMatch')
parser.add_argument('inputFile', type=argparse.FileType('rb'), default=sys.stdin)
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

data = args.inputFile.read()
args.inputFile.close()
crcCalc = STCRC.Calc()
dataCRC = crcCalc.calc(data)
print("Input size: " + str(len(data)))
print("CRC32-STM32: " + hex(dataCRC))

with CANInterface.MakeInterface(args.deviceType, args.deviceName) as interface:
    if targetIDs == None:
        slaves = XCPConnection.GetCANSlaves(interface, 0x9F000000, 0.2)
        for i in range(0, len(slaves)):
            print(str(i) + ': ' + slaves[i].description())
        index = int(input('Slave: '))
        if index >= len(slaves):
            exit
        targetSlaves = [(slaves[index], None)]
    else:
        targetSlaves = []
        for targetID in targetIDs:
            if targetID >= 0:
                targetSlaves.append((CANInterface.XCPSlaveCANAddr(0x9F000100 + 2 * targetID, 0x9F000101 + 2 * targetID), targetID))
            else:
                targetSlaves.append((CANInterface.XCPSlaveCANAddr(0x9F000010, 0x9F000011), None))
                
    for targetSlave in targetSlaves:
        if targetSlave[1] != None:
            print('Programming target addr ' + targetSlave[0].description() + ', ID ' + str(targetSlave[1]))
        else:
            print('Programming target addr ' + targetSlave[0].description())
        
        attempts = 1
        while 1:
            try:
                interface.connect(targetSlave[0])
                conn = XCPConnection.Connection(interface, 0.5, 2.0)
                if args.crcMatch:
                    print('Checking existing code CRC')
                    conn.program_start()
                    if conn.program_check(XCPConnection.Pointer(0x08004000, 0), len(data), dataCRC):
                        print('CRC matched flash contents')
                        conn.program_reset()
                        break
                conn.program_app(XCPConnection.Pointer(0x08004000, 0), data, dataCRC)
                print('Program OK')
                break
            except XCPConnection.Error as err:
                print('Program failure (' + str(err) + '), retry #' + str(attempts))
                if attempts >= 10:
                    sys.exit(1)
            attempts = attempts + 1
