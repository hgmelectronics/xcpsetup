#!/usr/bin/python3.3
import json
import struct
import sys
import argparse

sys.path.append('..')

from comm import CANInterface
from comm import XCPConnection
from util import plugins

class Target(object):
    def __init__(self, idOrSlave, inFileName):
        if isinstance(idOrSlave, CANInterface.XCPSlaveCANAddr):
            self.id = None
            self.slave = idOrSlave
        else:
            self.id = idOrSlave
            self.slave = CANInterface.XCPSlaveCANAddr(0x9F000100 + 2 * self.id, 0x9F000101 + 2 * self.id)
        if inFileName == None:
            self.file = sys.stdout
        else:
            self.file = open(inFileName.format(self.id), 'r')

def CastS16ToShort(i):
    return struct.unpack('H', struct.pack('h', i))[0]

def CastFloatToInt(i):
    return struct.unpack('I', struct.pack('f', i))[0]
   
plugins.load_plugins()

parser = argparse.ArgumentParser(description="writes data to an IBEM")
parser.add_argument('-t', help="CAN device type", dest="deviceType", default=None)
parser.add_argument('-d', help="CAN device name", dest="deviceName", default=None)
parser.add_argument('-i', help="Target ID or range of IDs (e.g. 1-3)", dest="targetID", default=None)
parser.add_argument('inputFile', default=None)
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

try:
    with CANInterface.MakeInterface(args.deviceType, args.deviceName) as interface:
        if targetIDs == None:
            slaves = XCPConnection.GetCANSlaves(interface, 0x9F000000, 0.2)
            for i in range(0, len(slaves)):
                print(str(i) + ': ' + slaves[i].description())
            index = int(input('Slave: '))
            if index >= len(slaves):
                exit
            targets = [Target(slaves[index], args.inputFile)]
        else:
            targets = [Target(id, args.inputFile) for id in targetIDs]
        
        for target in targets:
            data = json.loads(target.file.read())
            print('Connecting to ' + target.slave.description())
            interface.connect(target.slave)
            conn = XCPConnection.Connection(interface, 0.2, 1.0)
            if 'boardID' in data:
                conn.download8(XCPConnection.Pointer(0, 0), data['boardID'])
            if 'afeCalib' in data:
                for i in range(0, 8):
                    conn.download16(XCPConnection.Pointer(4 + 2 * i, 0), CastS16ToShort(data['afeCalib']['zeroCts'][i]))
                    conn.download32(XCPConnection.Pointer(20 + 4 * i, 0), CastFloatToInt(data['afeCalib']['scale'][i]))
            if 'cellTypeParam' in data:
                if 'vocParam' in data['cellTypeParam']:
                    for i in range(0, 11):
                        conn.download32(XCPConnection.Pointer(52 + 4 * i, 0), CastFloatToInt(data['cellTypeParam']['vocParam']['soc'][i]))
                        conn.download32(XCPConnection.Pointer(96 + 4 * i, 0), CastFloatToInt(data['cellTypeParam']['vocParam']['voc'][i]))
                
                if 'riParam' in data['cellTypeParam']:
                    if 'socBreakpt' in data['cellTypeParam']['riParam']:
                        conn.download32(XCPConnection.Pointer(140, 0), CastFloatToInt(data['cellTypeParam']['riParam']['socBreakpt']))
                    if 'rAtZeroSOC' in data['cellTypeParam']['riParam']:
                        conn.download32(XCPConnection.Pointer(144, 0), CastFloatToInt(data['cellTypeParam']['riParam']['rAtZeroSOC']))
                    if 'dRdSOCLow' in data['cellTypeParam']['riParam']:
                        conn.download32(XCPConnection.Pointer(148, 0), CastFloatToInt(data['cellTypeParam']['riParam']['dRdSOCLow']))
                    if 'dRdSOCHigh' in data['cellTypeParam']['riParam']:
                        conn.download32(XCPConnection.Pointer(152, 0), CastFloatToInt(data['cellTypeParam']['riParam']['dRdSOCHigh']))
                    if 'rInterconn' in data['cellTypeParam']['riParam']:
                        conn.download32(XCPConnection.Pointer(156, 0), CastFloatToInt(data['cellTypeParam']['riParam']['rInterconn']))
                    if 'rDToRC' in data['cellTypeParam']['riParam']:
                        conn.download32(XCPConnection.Pointer(160, 0), CastFloatToInt(data['cellTypeParam']['riParam']['rDToRC']))
                
                if 'modelParam' in data['cellTypeParam']:
                    conn.download32(XCPConnection.Pointer(164, 0), CastFloatToInt(data['cellTypeParam']['modelParam']['minR']))
                    conn.download32(XCPConnection.Pointer(168, 0), CastFloatToInt(data['cellTypeParam']['modelParam']['maxR']))
                    conn.download32(XCPConnection.Pointer(172, 0), CastFloatToInt(data['cellTypeParam']['modelParam']['srVarI']))
                    conn.download32(XCPConnection.Pointer(176, 0), CastFloatToInt(data['cellTypeParam']['modelParam']['srVarSOC']))
                    conn.download32(XCPConnection.Pointer(180, 0), CastFloatToInt(data['cellTypeParam']['modelParam']['srVarRPerI']))
                    conn.download32(XCPConnection.Pointer(184, 0), CastFloatToInt(data['cellTypeParam']['modelParam']['srVarRMinI']))
                    conn.download32(XCPConnection.Pointer(188, 0), CastFloatToInt(data['cellTypeParam']['modelParam']['srVarMeasV']))
                    conn.download32(XCPConnection.Pointer(192, 0), CastFloatToInt(data['cellTypeParam']['modelParam']['srMinBetaV']))
                    conn.download32(XCPConnection.Pointer(196, 0), CastFloatToInt(data['cellTypeParam']['modelParam']['nomCellCap']))
                    conn.download32(XCPConnection.Pointer(200, 0), CastFloatToInt(data['cellTypeParam']['modelParam']['nomCellR']))
                    conn.download32(XCPConnection.Pointer(204, 0), CastFloatToInt(data['cellTypeParam']['modelParam']['usableDischI']))
                    conn.download32(XCPConnection.Pointer(208, 0), CastFloatToInt(data['cellTypeParam']['modelParam']['usableChgI']))
                    conn.download32(XCPConnection.Pointer(212, 0), CastFloatToInt(data['cellTypeParam']['modelParam']['capEstHistLength']))
                
                if 'balParam' in data['cellTypeParam']:
                    conn.download32(XCPConnection.Pointer(216, 0), CastFloatToInt(data['cellTypeParam']['balParam']['qPerVSec']))
                    conn.download32(XCPConnection.Pointer(220, 0), CastFloatToInt(data['cellTypeParam']['balParam']['minAccQ']))
                    conn.download32(XCPConnection.Pointer(224, 0), CastFloatToInt(data['cellTypeParam']['balParam']['maxAccQ']))
                    conn.download32(XCPConnection.Pointer(228, 0), CastFloatToInt(data['cellTypeParam']['balParam']['stopQ']))
                
                if 'protParam' in data['cellTypeParam']:
                    conn.download32(XCPConnection.Pointer(232, 0), CastFloatToInt(data['cellTypeParam']['protParam']['highTMaxV']))
                    conn.download32(XCPConnection.Pointer(236, 0), CastFloatToInt(data['cellTypeParam']['protParam']['lowTMaxV']))
                    conn.download32(XCPConnection.Pointer(240, 0), CastFloatToInt(data['cellTypeParam']['protParam']['highTForMaxV']))
                    conn.download32(XCPConnection.Pointer(244, 0), CastFloatToInt(data['cellTypeParam']['protParam']['lowTForMaxV']))
                    conn.download32(XCPConnection.Pointer(248, 0), CastFloatToInt(data['cellTypeParam']['protParam']['highTMinV']))
                    conn.download32(XCPConnection.Pointer(252, 0), CastFloatToInt(data['cellTypeParam']['protParam']['lowTMinV']))
                    conn.download32(XCPConnection.Pointer(256, 0), CastFloatToInt(data['cellTypeParam']['protParam']['highTForMinV']))
                    conn.download32(XCPConnection.Pointer(260, 0), CastFloatToInt(data['cellTypeParam']['protParam']['lowTForMinV']))
                    conn.download32(XCPConnection.Pointer(264, 0), CastFloatToInt(data['cellTypeParam']['protParam']['rForCellProt']))
                    conn.download32(XCPConnection.Pointer(268, 0), CastFloatToInt(data['cellTypeParam']['protParam']['thermalMaxI']))
                    conn.download32(XCPConnection.Pointer(272, 0), CastFloatToInt(data['cellTypeParam']['protParam']['zeroITemp']))
                    conn.download32(XCPConnection.Pointer(276, 0), CastFloatToInt(data['cellTypeParam']['protParam']['safeMaxT']))
                    conn.download32(XCPConnection.Pointer(280, 0), CastFloatToInt(data['cellTypeParam']['protParam']['highWarnT']))
                    conn.download32(XCPConnection.Pointer(284, 0), CastFloatToInt(data['cellTypeParam']['protParam']['safeMinT']))
                    conn.download32(XCPConnection.Pointer(288, 0), CastFloatToInt(data['cellTypeParam']['protParam']['lowWarnT']))
            
            print("Writing flash")
            conn.nvwrite()
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
