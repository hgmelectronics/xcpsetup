#!/usr/bin/python3.3

import time
from comm import CANInterface
from comm import XCPConnection
from util import config

types={}

class InvalidIDArg(Exception):
    def __init__(self, value=None):
        self._value = value
    def __str__(self):
        if self._value != None:
            return 'Invalid ID argument ' + repr(self._value)
        else:
            return 'Invalid ID argument'

class BoardType(object):
    def __init__(self, defDict):
        if 'broadcastId' in defDict:
            self._broadcastId = defDict['broadcastId']
            self._broadcastTimeout = defDict['timeouts']['broadcast']
        else:
            self._broadcastId = None
        self._regularTimeout = defDict['timeouts']['regular']
        self._nvWriteTimeout = defDict['timeouts']['nvWrite']
        self._rebootTime = defDict['timeouts']['reboot']
        self._hasIndexedIds = False
        self._ids = {}
        for idName in defDict['ids']:
            if idName == '_indexed':
                self._hasIndexedIds = True
                self._cmdBaseID = defDict['ids']['_indexed']['cmdBase']
                self._resBaseID = defDict['ids']['_indexed']['resBase']
                self._idPitch = defDict['ids']['_indexed']['idPitch']
                self._idxRange = (defDict['ids']['_indexed']['idxRange'][0], defDict['ids']['_indexed']['idxRange'][1])
            else:
                self._ids[idName] = {}
                self._ids[idName]['cmd'] = defDict['ids'][idName]['cmd']
                self._ids[idName]['res'] = defDict['ids'][idName]['res']

    def SlaveListFromIdxArg(self, arg):
        if arg == None:
            if len(self._ids) == 1:
                idName = list(self._ids.keys())[0]
                return [(CANInterface.XCPSlaveCANAddr(self._ids[idName]['cmd'], self._ids[idName]['res']), idName)]
            raise InvalidIDArg(arg)
        elif arg.find('-') >= 0:
            if not self._hasIndexedIds:
                raise InvalidIDArg(arg)
            idxs = [int(x) for x in arg.split('-')]
            if len(idxs) != 2:
                raise InvalidIDArg(arg)
            if idxs[0] < self._idxRange[0] \
                or idxs[0] >= self._idxRange[1] \
                or idxs[1] < self._idxRange[0] \
                or idxs[1] >= self._idxRange[1]:
                raise InvalidIDArg(arg)
            targetIdxs = range(idxs[0], idxs[1] + 1)
            return [(CANInterface.XCPSlaveCANAddr(self._cmdBaseID + self._idPitch * idx, self._resBaseID + self._idPitch * idx), idx) for idx in targetIdxs]
        else:
            if arg in self._ids:
                return [(CANInterface.XCPSlaveCANAddr(self._ids[arg]['cmd'], self._ids[arg]['res']), arg)]
            elif self._hasIndexedIds:
                try:
                    idx = int(arg)
                    if idx >= self._idxRange[0] and idx < self._idxRange[1]:
                        return [(CANInterface.XCPSlaveCANAddr(self._cmdBaseID + self._idPitch * idx, self._resBaseID + self._idPitch * idx), idx)]
                except ValueError:
                    pass
            raise InvalidIDArg(arg)
    
    def GetSlaves(self, intfc):
        if self._broadcastId == None:
            ret = [(CANInterface.XCPSlaveCANAddr(self._ids[idName]['cmd'], self._ids[idName]['res']), idName) for idName in self._ids]
            if self._hasIndexedIds:
                idxRange = range(self._idxRange[0], self._idxRange[1])
                ret += [(CANInterface.XCPSlaveCANAddr(self._cmdBaseID + self._idPitch * idx, self._resBaseID + self._idPitch * idx), idx) for idx in idxRange]
            return ret
        
        slaves = XCPConnection.GetCANSlaves(intfc, self._broadcastId, self._broadcastTimeout)
        mySlaves = []
        for slave in slaves:
            match = None
            
            if self._hasIndexedIds:
                possID = int((slave.cmdId.raw - self._cmdBaseID) / self._idPitch)
                if slave.cmdId.raw == self._cmdBaseID + possID * self._idPitch \
                    and slave.resId.raw == self._resBaseID + possID * self._idPitch \
                    and possID >= self._idxRange[0] and possID < self._idxRange[1]:
                    match = (slave, possID)
            
            if match == None:
                for idName in self._ids:
                    if {'cmd': slave.cmdId.raw, 'res': slave.resId.raw} == self._ids[idName]:
                        match = (slave, idName)
                        break
            
            if match != None:
                mySlaves.append(match)
        mySlaves.sort(key=lambda slave: '{:010}'.format(slave[1]) if isinstance(slave[1], int) else slave[1])
        return mySlaves
    
    def Connect(self, intfc, slave, dumpTraffic):
        intfc.connect(slave[0], dumpTraffic)
        return XCPConnection.Connection(intfc, self._regularTimeout, self._nvWriteTimeout)
    
    def WaitForReboot(self):
        time.sleep(self._rebootTime)
        
def SetupBoardTypes():
    for typeName in config.configDict['xcptoolsBoardTypes']:
        types[typeName] = BoardType(config.configDict['xcptoolsBoardTypes'][typeName])
        
