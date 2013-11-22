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
from util import srec
from collections import namedtuple
   
plugins.load_plugins()

parser = argparse.ArgumentParser(description="programs application code into an IBEM")
parser.add_argument('-t', help="CAN device type", dest="deviceType", default=None)
parser.add_argument('-d', help="CAN device name", dest="deviceName", default=None)
parser.add_argument('-T', help="Target device type (ibem,cda,cs2) for automatic XCP ID selection", dest="targetType", default=None)
parser.add_argument('-i', help="Target ID or range of IDs (e.g. 2, 1-3, recovery) for automatic XCP ID selection", dest="targetID", default=None)
parser.add_argument('-c', help="Force reprogram even if CRC matches what is already in flash", action='count', dest='ignoreCRCMatch')
parser.add_argument('inputFile', type=argparse.FileType('rb'), default=sys.stdin)
args = parser.parse_args()

class ArgError(Exception):
    def __init__(self, value=None):
        self._value = value
    def __str__(self):
        if self._value != None:
            return 'Invalid argument ' + self._value
        else:
            return 'Invalid argument'

class IndexedBoardType(object):
    def __init__(self, broadcastID, recoveryCmdID, recoveryResID, cmdBaseID, resBaseID, idPitch, idRange, regularTimeout, nvWriteTimeout):
        self._broadcastID = broadcastID
        self._broadcastTimeout = 0.2
        self._recoveryCmdID = recoveryCmdID
        self._recoveryResID = recoveryResID
        self._cmdBaseID = cmdBaseID
        self._resBaseID = resBaseID
        self._idPitch = idPitch
        self._idRange = idRange
        self._regularTimeout = regularTimeout
        self._nvWriteTimeout = nvWriteTimeout
    
    def SlaveListFromIDArg(self, arg):
        if arg == None:
            return []
        elif arg == 'recovery':
            return [(CANInterface.XCPSlaveCANAddr(self._recoveryCmdID, self._recoveryResID), 'recovery')]
        elif arg.find('-') >= 0:
            idStrs = arg.split('-')
            if len(idStrs) != 2:
                raise ArgError('ID=\'' + arg + '\'')
            firstID = int(idStrs[0])
            lastID = int(idStrs[1])
            if firstID < self._idRange[0] \
                or firstID >= self._idRange[1] \
                or lastID < self._idRange[0] \
                or lastID >= self._idRange[1]:
                raise ArgError('ID=\'' + arg + '\'')
            targetIDs = range(int(idStrs[0]), int(idStrs[1]) + 1)
            return [(CANInterface.XCPSlaveCANAddr(self._cmdBaseID + self._idPitch * id, self._resBaseID + self._idPitch * id), id) for id in targetIDs];
        else:
            try:
                targetID = int(arg);
            except:
                raise ArgError('ID=\'' + arg + '\'')
            if targetID < self._idRange[0] or targetID >= self._idRange[1]:
                raise ArgError('ID=\'' + arg + '\'')
            return [(CANInterface.XCPSlaveCANAddr(self._cmdBaseID + self._idPitch * targetID, self._resBaseID + self._idPitch * targetID), targetID)];
    
    def GetSlaves(self, intfc):
        # Handle case of singleton devices
        if self._broadcastID == None:
            return CANInterface.XCPSlaveCANAddr(self._cmdBaseID, self._resBaseID)
        
        slaves = XCPConnection.GetCANSlaves(intfc, self._broadcastID, self._broadcastTimeout)
        mySlaves = []
        for slave in slaves:
            if slave.cmdId.raw == self._recoveryCmdID and slave.resId.raw == self._recoveryResID:
                mySlaves.append((slave, 'recovery'))
            else:
                possID = int((slave.cmdId.raw - self._cmdBaseID) / self._idPitch)
                if slave.cmdId.raw == self._cmdBaseID + possID * self._idPitch \
                    and slave.resId.raw == self._resBaseID + possID * self._idPitch \
                    and possID >= self._idRange[0] and possID < self._idRange[1]:
                    mySlaves.append((slave, possID))
        mySlaves.sort(key=lambda slave: slave[1])
        return mySlaves
    
    def Connect(self, intfc, slave):
        intfc.connect(slave[0])
        return XCPConnection.Connection(intfc, self._regularTimeout, self._nvWriteTimeout)

class SingletonBoardType(object):
    def __init__(self, cmdID, resID, regularTimeout, nvWriteTimeout):
        self._addr = CANInterface.XCPSlaveCANAddr(cmdID, resID)
        self._regularTimeout = regularTimeout
        self._nvWriteTimeout = nvWriteTimeout
    
    def SlaveListFromIDArg(self, arg):
        if arg == None:
            return [(self._addr, None)]
        else:
            raise ArgError('ID=\'' + arg + '\'')
    
    def GetSlaves(self, intfc):
        return [(self._addr, None)]
    
    def Connect(self, intfc, slave):
        intfc.connect(slave[0])
        return XCPConnection.Connection(intfc, self._regularTimeout, self._nvWriteTimeout)

if args.targetType == 'ibem':
    boardType = IndexedBoardType(0x9F000000, 0x9F000010, 0x9F000011, 0x9F000100, 0x9F000101, 2, (0,256), 0.5, 2.0)
    maxAttempts=10
elif args.targetType == 'cda':
    boardType = IndexedBoardType(0x9F000000, 0x9F000010, 0x9F000011, 0x9F000080, 0x9F000081, 2, (0,2), 0.5, 2.0)
    maxAttempts=10
elif args.targetType == 'cs2':
    boardType = SingletonBoardType(0xDEADBEEF, 0xDEADBEF0, 2.0, 5.0) #FIXME
    maxAttempts=10
elif args.targetType == None:
    # FIXME read information from user and/or more command line params
    print('Must specify target type')
    sys.exit(1)
else:
    print('Invalid target type \'' + args.targetType + '\'')
    sys.exit(1)

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
        conn = boardType.Connect(interface, targetSlave)
        if targetSlave[1] != None:
            print('Programming target addr ' + targetSlave[0].description() + ', ID ' + str(targetSlave[1]))
        else:
            print('Programming target addr ' + targetSlave[0].description())
        
        if not args.ignoreCRCMatch:
            print('Checking existing code CRC')
            conn.program_start()
            if conn.program_check(XCPConnection.Pointer(dataSingleBlock.baseaddr, 0), len(dataSingleBlock.data), dataCRC):
                print('CRC matched flash contents')
                conn.program_reset()
                # Success, don't need to do anything further with this slave
                continue
            else:
                print('CRC differs from flash contents, reprogramming')
        
        # Either CRC check was not done or it didn't match
        attempts = 1
        while 1:
            try:
                conn.program_start()
                conn.program_clear(XCPConnection.Pointer(dataSingleBlock.baseaddr, 0), len(dataSingleBlock.data))
                for block in dataBlocks:
                    conn.program_range(XCPConnection.Pointer(block.baseaddr, 0), block.data)
                # MTA should now be one past the end of the last block
                conn.program_verify(dataCRC)
                conn.program_reset()
                print('Program OK')
                break
            except XCPConnection.Error as err:
                print('Program failure (' + str(err) + '), retry #' + str(attempts))
                if attempts >= maxAttempts:
                    sys.exit(1)
            attempts = attempts + 1
