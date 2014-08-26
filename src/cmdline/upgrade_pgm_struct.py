#!/usr/bin/python3.3

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
from util import STCRC
from util import srec
from . import argProc

plugins.loadPlugins()

parser = argparse.ArgumentParser(description="reads data from a board using a C header file to define layout in memory")
parser.add_argument('-c', nargs='*', help='Extra configuration files to load', dest='configFiles')
parser.add_argument('-d', help="CAN device URI", dest="deviceURI", default=None)
parser.add_argument('-T', help="Target device type (ibem,cda,cs2) for automatic XCP ID selection", dest="targetType", default=None)
parser.add_argument('-i', help="Target ID or range of IDs (e.g. 2, 1-3, recovery) for automatic XCP ID selection", dest="targetID", default=None)
parser.add_argument('-l', help="Location of config structure in form <segment>:<baseaddr>", default="0:0", dest="structLocation")
parser.add_argument('-s', help="Pickled old structure definition", dest="oldStructSpec")
parser.add_argument('-S', help="Pickled new structure definition", dest="newStructSpec")
parser.add_argument('-o', help="Output file name (if range of IDs specified must contain a {} to be replaced with the ID)", dest="outputFile", default="-")
parser.add_argument('-p', help="S-record file to program", dest="srecFile", type=argparse.FileType('rb'))
parser.add_argument('-c', help="Force reprogram even if CRC matches what is already in flash", action='count', dest='ignoreCRCMatch')
parser.add_argument('-D', help="Dump all XCP traffic, for debugging purposes", dest="dumpTraffic", action="store_true", default=False)
parser.add_argument('inputFile', help="Input file name (if range of IDs specified must contain a {} to be replaced with the ID)", default=None)
args = parser.parse_args()

config.loadConfigs(args.configFiles)
BoardTypes.SetupBoardTypes()
if not args.targetType in config.configDict['xcptoolsBoardTypes']:
    print('Could not find board type ' + args.targetType)
    sys.exit(1)
else:
    boardType = config.configDict['xcptoolsBoardTypes'][args.targetType]

try:
    OldConfigType = argProc.GetStructType(args.oldStructSpec)
    NewConfigType = argProc.GetStructType(args.newStructSpec)
    structSegment,structBaseaddr = argProc.GetStructLocation(args.structLocation)
except argProc.ArgError as exc:
    print(str(exc))
    sys.exit(1)

maxAttempts = 10

progBlocks = srec.ReadFile(args.srecFile)
progSingleBlock = srec.MakeSingleBlock(progBlocks, b'\xFF')
args.srecFile.close()
crcCalc = STCRC.Calc()
progCRC = crcCalc.calc(progSingleBlock.data)
for block in progBlocks:
    print("Read block " + hex(block.baseaddr) + "-" + hex(block.baseaddr + len(block.data)))
print("Total input range " + hex(progSingleBlock.baseaddr) + "-" + hex(progSingleBlock.baseaddr + len(progSingleBlock.data)))
print("CRC32-STM32: " + hex(progCRC))

def OpenInFile(name, idx):
    if name == None:
        return sys.stdin
    else:
        return open(name.format(idx), 'r')
def OpenOutFile(name, idx):
    if name == None or name == '-':
        return sys.stdout
    else:
        return open(name.format(idx), 'w')

with CANInterface.MakeInterface(args.deviceURI) as interface:
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
        # Load the new configuration as a dict
        inFile = OpenInFile(args.inputFile, targetSlave[1])
        inDict = json.loads(inFile.read())
        inFile.close()
        
        if targetSlave[1] != None:
            sys.stderr.write('Connecting to target addr ' + targetSlave[0].description() + ', ID ' + str(targetSlave[1]) + '\n')
        else:
            sys.stderr.write('Connecting to target addr ' + targetSlave[0].description() + '\n')
        
        # Connect to the target and read out its old configuration
        for attempt in range(1, maxAttempts + 1):
            try:
                conn = boardType.Connect(interface, targetSlave, args.dumpTraffic)
                
                conn.set_cal_page(structSegment, 0)
                oldBuffer = conn.upload(XCPConnection.Pointer(structBaseaddr, 0), ctypes.sizeof(OldConfigType))
                oldStruct = OldConfigType.from_buffer_copy(oldBuffer)
                oldDict = ctypesdict.getdict(oldStruct)
                
                outFile=OpenOutFile(args.outputFile, targetSlave[1])
                outFile.write(json.dumps(oldDict, sort_keys=True, indent=4, separators=(',', ': ')))
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
        
        # Create the new configuration structure
        writeDataStruct = NewConfigType()
        #  Set all members that still exist from the old structure
        ctypesdict.setfromdict(writeDataStruct, oldDict)
        #  Set members from the new configuration file
        ctypesdict.setfromdict(writeDataStruct, inDict)
        writeDataBuffer=bytes(memoryview(writeDataStruct))
        
        sys.stderr.write('Programming\n')
                
        # Program the target
        for attempt in range(1, maxAttempts + 1):
            try:
                conn = boardType.Connect(interface, targetSlave, args.dumpTraffic)
                conn.program_start()
                
                if not args.ignoreCRCMatch and conn.program_check(XCPConnection.Pointer(progSingleBlock.baseaddr, 0), len(progSingleBlock.data), progCRC):
                    print('CRC matched flash contents')
                    # Success, don't need to do anything further with this slave
                else:
                    # Either CRC check was not done or it didn't match
                    conn.program_clear(XCPConnection.Pointer(progSingleBlock.baseaddr, 0), len(progSingleBlock.data))
                    for block in progBlocks:
                        conn.program_range(XCPConnection.Pointer(block.baseaddr, 0), block.data)
                    # MTA should now be one past the end of the last block
                    conn.program_verify(progCRC)
                conn.program_reset()
                print('Program OK')
                programOK = True
                break
            except XCPConnection.Error as err:
                print('Program failure (' + str(err) + '), attempt #' + str(attempt))
                programOK = False
        if not programOK:
            sys.exit(1)
        
        sys.stderr.write('Waiting for reboot\n')
        # Wait for the target to reboot
        boardType.WaitForReboot()
        
        # Connect to the recovery address
        
        for attempt in range(1, maxAttempts + 1):
            try:
                conn = boardType.Connect(interface, boardType.SlaveListFromIDArg('recovery')[0], args.dumpTraffic)
                print('Connected to recovery address')
                # Write the new buffer to the board
                conn.set_cal_page(structSegment, 0)
                conn.download(XCPConnection.Pointer(structBaseaddr, 0), writeDataBuffer)
                conn.nvwrite()
                print('Write OK')
                conn.program_start()
                conn.program_reset()
                print('Reset target OK')
                
                writeOK = True
                break
            except XCPConnection.Error as err:
                print('Write failure (' + str(err) + '), attempt #' + str(attempt))
                writeOK = False
        if not writeOK:
            sys.exit(1)
        
        # Wait for the target to reboot
        boardType.WaitForReboot()
        
        # Connect to the target at its designated address to make sure it came up
        for attempt in range(1, maxAttempts + 1):
            try:
                conn = boardType.Connect(interface, targetSlave, args.dumpTraffic)
                try:
                    conn.close()
                except XCPConnection.Error:
                    pass # swallow any errors when closing connection due to bad target implementations - we really don't care
                sys.stderr.write('Restarted OK\n')
                restartOK = True
                break
            except XCPConnection.Error as err:
                sys.stderr.write('Restart failure (' + str(err) + '), attempt #' + str(attempt) + '\n')
                restartOK = False
        if not restartOK:
            sys.exit(1)
        
