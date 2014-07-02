#!/usr/bin/python3.3

import argparse
import sys

if not '..' in sys.path:
    sys.path.append('..')

from comm import CANInterface
from comm import XCPConnection
from util import plugins
from util import STCRC
from util import srec
import argProc
   
plugins.load_plugins()

parser = argparse.ArgumentParser(description="programs application code into an IBEM")
parser.add_argument('-t', help="CAN device type", dest="deviceType", default=None)
parser.add_argument('-d', help="CAN device name", dest="deviceName", default=None)
parser.add_argument('-T', help="Target device type (ibem,cda,cs2) for automatic XCP ID selection", dest="targetType", default=None)
parser.add_argument('-i', help="Target ID or range of IDs (e.g. 2, 1-3, recovery) for automatic XCP ID selection", dest="targetID", default=None)
parser.add_argument('-c', help="Force reprogram even if CRC matches what is already in flash", action='count', dest='ignoreCRCMatch')
parser.add_argument('-D', help="Dump all XCP traffic, for debugging purposes", dest="dumpTraffic", action="store_true", default=False)
parser.add_argument('inputFile', type=argparse.FileType('rb'), default=sys.stdin)
args = parser.parse_args()

try:
    boardType = argProc.GetBoardType(args.targetType)
except argProc.ArgError as exc:
    print(str(exc))
    sys.exit(1)

maxAttempts = 10

# Get input data

dataBlocks = srec.ReadFile(args.inputFile)
dataSingleBlock = srec.MakeSingleBlock(dataBlocks, b'\xFF')
args.inputFile.close()
crcCalc = STCRC.Calc()
dataCRC = crcCalc.calc(dataSingleBlock.data)
for block in dataBlocks:
    print("Read block " + hex(block.baseaddr) + "-" + hex(block.baseaddr + len(block.data)))
print("Total input range " + hex(dataSingleBlock.baseaddr) + "-" + hex(dataSingleBlock.baseaddr + len(dataSingleBlock.data)))
print("CRC32-STM32: " + hex(dataCRC))

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
            print('Programming target addr ' + targetSlave[0].description() + ', ID ' + str(targetSlave[1]))
        else:
            print('Programming target addr ' + targetSlave[0].description())
        
        for attempt in range(1, maxAttempts + 1):
            try:
                conn = boardType.Connect(interface, targetSlave, args.dumpTraffic)
                conn.program_start()
                
                if not args.ignoreCRCMatch and conn.program_check(XCPConnection.Pointer(dataSingleBlock.baseaddr, 0), len(dataSingleBlock.data), dataCRC):
                    print('CRC matched flash contents')
                    # Success, don't need to do anything further with this slave
                else:
                    # Either CRC check was not done or it didn't match
                    conn.program_clear(XCPConnection.Pointer(dataSingleBlock.baseaddr, 0), len(dataSingleBlock.data))
                    for block in dataBlocks:
                        conn.program_range(XCPConnection.Pointer(block.baseaddr, 0), block.data)
                    # MTA should now be one past the end of the last block
                    conn.program_verify(dataCRC)
                conn.program_reset()
                print('Program OK')
                programOK = True
                break
            except XCPConnection.Error as err:
                print('Program failure (' + str(err) + '), attempt #' + str(attempt))
                programOK = False
        if not programOK:
            sys.exit(1)
