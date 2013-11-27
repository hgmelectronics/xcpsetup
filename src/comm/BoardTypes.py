#!/usr/bin/python3.3

from comm import CANInterface
from comm import XCPConnection

class Indexed(object):
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

class Singleton(object):
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

ByName = {  'ibem': Indexed(0x9F000000, 0x9F000010, 0x9F000011, 0x9F000100, 0x9F000101, 2, (0,256), 0.5, 2.0),\
            'cda': Indexed(0x9F000000, 0x9F000010, 0x9F000011, 0x9F000080, 0x9F000081, 2, (0,2), 0.5, 2.0),\
            'cs2': Singleton(0xDEADBEEF, 0xDEADBEF0, 2.0, 5.0) } #FIXME


