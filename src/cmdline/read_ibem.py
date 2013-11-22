#!/usr/bin/python3.3
import argparse
import json
import struct
import sys

sys.path.append('..')

from comm import CANInterface
from comm import XCPConnection
from util import plugins
import ctypes
from util import ctypesdict

class SeriesRDivVSensorCalib(ctypes.Structure):
    _fields_ = [('zeroCts', ctypes.c_short * 8), \
                ('scale', ctypes.c_float * 8)]

class VocModelParam(ctypes.Structure):
    _fields_ = [('soc', ctypes.c_float * 11), \
                ('voc', ctypes.c_float * 11)]

class PWLRiModelParam(ctypes.Structure):
    _fields_ = [('socBreakpt', ctypes.c_float), \
                ('rAtZeroSOC', ctypes.c_float), \
                ('dRdSOCLow', ctypes.c_float), \
                ('dRdSOCHigh', ctypes.c_float), \
                ('rInterconn', ctypes.c_float), \
                ('rDToRC', ctypes.c_float)]

class SplineRiModelParam(ctypes.Structure):
    _fields_ = [('chgSOC', ctypes.c_float * 11), \
                ('chgR', ctypes.c_float * 11), \
                ('dischSOC', ctypes.c_float * 11), \
                ('dischR', ctypes.c_float * 11), \
                ('tempcoTemp', ctypes.c_float * 11), \
                ('tempcoRatio', ctypes.c_float * 11)]

class ModelParam_SR(ctypes.Structure):
    _fields_ = [('minR', ctypes.c_float), \
                ('maxR', ctypes.c_float), \
                ('srVarI', ctypes.c_float), \
                ('srVarSOC', ctypes.c_float), \
                ('srVarRPerI', ctypes.c_float), \
                ('srVarRMinI', ctypes.c_float), \
                ('srVarMeasV', ctypes.c_float), \
                ('srMinBetaV', ctypes.c_float), \
                ('nomCellCap', ctypes.c_float), \
                ('nomCellR', ctypes.c_float), \
                ('usableDischI', ctypes.c_float), \
                ('usableChgI', ctypes.c_float), \
                ('capEstHistLength', ctypes.c_float)]

class ModelParam_FCL(ctypes.Structure):
    _fields_ = [('minR', ctypes.c_float), \
                ('maxR', ctypes.c_float), \
                ('fclSOCGain', ctypes.c_float), \
                ('fclRGain', ctypes.c_float), \
                ('nomCellCap', ctypes.c_float), \
                ('nomCellR', ctypes.c_float), \
                ('usableDischI', ctypes.c_float), \
                ('usableChgI', ctypes.c_float), \
                ('capEstHistLength', ctypes.c_float)]

class BalParam(ctypes.Structure):
    _fields_ = [('qPerVSec', ctypes.c_float), \
                ('minAccQ', ctypes.c_float), \
                ('maxAccQ', ctypes.c_float), \
                ('stopQ', ctypes.c_float)]

class ProtParam(ctypes.Structure):
    _fields_ = [('highTMaxV', ctypes.c_float), \
                ('lowTMaxV', ctypes.c_float), \
                ('highTForMaxV', ctypes.c_float), \
                ('lowTForMaxV', ctypes.c_float), \
                ('highTMinV', ctypes.c_float), \
                ('lowTMinV', ctypes.c_float), \
                ('highTForMinV', ctypes.c_float), \
                ('lowTForMinV', ctypes.c_float), \
                ('rForCellProt', ctypes.c_float), \
                ('thermalMaxI', ctypes.c_float), \
                ('zeroITemp', ctypes.c_float), \
                ('safeMaxT', ctypes.c_float), \
                ('highWarnT', ctypes.c_float), \
                ('safeMinT', ctypes.c_float), \
                ('lowWarnT', ctypes.c_float)]

class CellTypeParam_1(ctypes.Structure):
    _fields_ = [('vocParam', VocModelParam), \
                ('riParam', PWLRiModelParam), \
                ('modelParam', ModelParam_SR), \
                ('balParam', BalParam), \
                ('protParam', ProtParam)]

class CellTypeParam_2(ctypes.Structure):
    _fields_ = [('vocParam', VocModelParam), \
                ('riParam', SplineRiModelParam), \
                ('modelParam', ModelParam_FCL), \
                ('balParam', BalParam), \
                ('protParam', ProtParam)]

class Config_1(ctypes.Structure):
    _fields_ = [('boardID', ctypes.c_ubyte), \
                ('afeCalib', SeriesRDivVSensorCalib), \
                ('cellTypeParam', CellTypeParam_1)]

class Config_2(ctypes.Structure):
    _fields_ = [('boardID', ctypes.c_ubyte), \
                ('afeCalib', SeriesRDivVSensorCalib), \
                ('cellTypeParam', CellTypeParam_2)]

class Target(object):
    def __init__(self, idOrSlave, outFileName):
        if isinstance(idOrSlave, CANInterface.XCPSlaveCANAddr):
            self.id = None
            self.slave = idOrSlave
        else:
            self.id = idOrSlave
            self.slave = CANInterface.XCPSlaveCANAddr(0x9F000100 + 2 * self.id, 0x9F000101 + 2 * self.id)
        if outFileName == None:
            self.file = sys.stdout
        else:
            self.file = open(outFileName.format(self.id), 'w')

plugins.load_plugins()

parser = argparse.ArgumentParser(description="reads data from an IBEM")
parser.add_argument('-t', help="CAN device type", dest="deviceType", default=None)
parser.add_argument('-d', help="CAN device name", dest="deviceName", default=None)
parser.add_argument('-i', help="Target ID or range of IDs (e.g. 1-3)", dest="targetID", default=None)
parser.add_argument('-v', help="Config structure version", dest="structVersion", default=2)
parser.add_argument('-o', help="Output file name (if range of IDs specified must contain a {} to be replaced with the ID)", dest="outputFile", default=None)
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

if args.structVersion == 1:
    ConfigType = Config_1
elif args.structVersion = 2:
    ConfigType = Config_2
else:
    print('Invalid config struct version ' + str(args.structVersion))
    sys.exit(1)

try:
    with CANInterface.MakeInterface(args.deviceType, args.deviceName) as interface:
        if targetIDs == None:
            slaves = XCPConnection.GetCANSlaves(interface, 0x9F000000, 0.2)
            for i in range(0, len(slaves)):
                print(str(i) + ': ' + slaves[i].description())
            index = int(input('Slave: '))
            if index >= len(slaves):
                exit
            targets = [Target(slaves[index], args.outputFile)]
        else:
            targets = [Target(id, args.outputFile) for id in targetIDs]
        
        for target in targets:
            print('Connecting to ' + target.slave.description())
            interface.connect(target.slave)
            conn = XCPConnection.Connection(interface, 0.2, 1.0)
            data = {}
            conn.set_cal_page(0, 0)
            dataBuffer = conn.upload(XCPConnection.Pointer(0, 0), sizeof(ConfigType))
            dataStruct = ConfigType.from_buffer(dataBuffer)
            data = ctypesdict.getdict(dataStruct)

            target.file.write(json.dumps(data, sort_keys=True, indent=4, separators=(',', ': ')))
            target.file.write('\n')
            conn.close()
except (OSError, CANInterface.ConnectFailed):
    try:
        interface.close()
    except NameError:
        pass
    raise
except:
    interface.close()
    raise
interface.close()
