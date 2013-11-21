#!/usr/bin/python3.3
import argparse
import json
import struct
import sys

sys.path.append('..')

from comm import CANInterface
from comm import XCPConnection
from util import plugins

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

def CastShortToS16(i):
    return struct.unpack('h', struct.pack('H', i))[0]

def CastIntToFloat(i):
    return struct.unpack('f', struct.pack('I', i))[0]

plugins.load_plugins()

parser = argparse.ArgumentParser(description="reads data from an IBEM")
parser.add_argument('-t', help="CAN device type", dest="deviceType", default=None)
parser.add_argument('-d', help="CAN device name", dest="deviceName", default=None)
parser.add_argument('-i', help="Target ID or range of IDs (e.g. 1-3)", dest="targetID", default=None)
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
            data['boardID'] = conn.upload8(XCPConnection.Pointer(0, 0))
            data['afeCalib'] = {'zeroCts': [], 'scale': []}
            for i in range(0, 8):
                data['afeCalib']['zeroCts'].append(CastShortToS16(conn.upload16(XCPConnection.Pointer(4 + 2 * i, 0))))
                data['afeCalib']['scale'].append(CastIntToFloat(conn.upload32(XCPConnection.Pointer(20 + 4 * i, 0))))
            data['cellTypeParam'] = {'vocParam': {'soc': [], 'voc': []}, 'riParam': {}, 'modelParam': {}, 'balParam': {}, 'protParam': {}}
            for i in range(0, 11):
                data['cellTypeParam']['vocParam']['soc'].append(CastIntToFloat(conn.upload32(XCPConnection.Pointer(52 + 4 * i, 0))))
                data['cellTypeParam']['vocParam']['voc'].append(CastIntToFloat(conn.upload32(XCPConnection.Pointer(96 + 4 * i, 0))))
            data['cellTypeParam']['riParam']['socBreakpt'] = CastIntToFloat(conn.upload32(XCPConnection.Pointer(140, 0)))
            data['cellTypeParam']['riParam']['rAtZeroSOC'] = CastIntToFloat(conn.upload32(XCPConnection.Pointer(144, 0)))
            data['cellTypeParam']['riParam']['dRdSOCLow'] = CastIntToFloat(conn.upload32(XCPConnection.Pointer(148, 0)))
            data['cellTypeParam']['riParam']['dRdSOCHigh'] = CastIntToFloat(conn.upload32(XCPConnection.Pointer(152, 0)))
            data['cellTypeParam']['riParam']['rInterconn'] = CastIntToFloat(conn.upload32(XCPConnection.Pointer(156, 0)))
            data['cellTypeParam']['riParam']['rDToRC'] = CastIntToFloat(conn.upload32(XCPConnection.Pointer(160, 0)))
            
            data['cellTypeParam']['modelParam']['minR'] = CastIntToFloat(conn.upload32(XCPConnection.Pointer(164, 0)))
            data['cellTypeParam']['modelParam']['maxR'] = CastIntToFloat(conn.upload32(XCPConnection.Pointer(168, 0)))
            data['cellTypeParam']['modelParam']['srVarI'] = CastIntToFloat(conn.upload32(XCPConnection.Pointer(172, 0)))
            data['cellTypeParam']['modelParam']['srVarSOC'] = CastIntToFloat(conn.upload32(XCPConnection.Pointer(176, 0)))
            data['cellTypeParam']['modelParam']['srVarRPerI'] = CastIntToFloat(conn.upload32(XCPConnection.Pointer(180, 0)))
            data['cellTypeParam']['modelParam']['srVarRMinI'] = CastIntToFloat(conn.upload32(XCPConnection.Pointer(184, 0)))
            data['cellTypeParam']['modelParam']['srVarMeasV'] = CastIntToFloat(conn.upload32(XCPConnection.Pointer(188, 0)))
            data['cellTypeParam']['modelParam']['srMinBetaV'] = CastIntToFloat(conn.upload32(XCPConnection.Pointer(192, 0)))
            data['cellTypeParam']['modelParam']['nomCellCap'] = CastIntToFloat(conn.upload32(XCPConnection.Pointer(196, 0)))
            data['cellTypeParam']['modelParam']['nomCellR'] = CastIntToFloat(conn.upload32(XCPConnection.Pointer(200, 0)))
            data['cellTypeParam']['modelParam']['usableDischI'] = CastIntToFloat(conn.upload32(XCPConnection.Pointer(204, 0)))
            data['cellTypeParam']['modelParam']['usableChgI'] = CastIntToFloat(conn.upload32(XCPConnection.Pointer(208, 0)))
            data['cellTypeParam']['modelParam']['capEstHistLength'] = CastIntToFloat(conn.upload32(XCPConnection.Pointer(212, 0)))
            
            data['cellTypeParam']['balParam']['qPerVSec'] = CastIntToFloat(conn.upload32(XCPConnection.Pointer(216, 0)))
            data['cellTypeParam']['balParam']['minAccQ'] = CastIntToFloat(conn.upload32(XCPConnection.Pointer(220, 0)))
            data['cellTypeParam']['balParam']['maxAccQ'] = CastIntToFloat(conn.upload32(XCPConnection.Pointer(224, 0)))
            data['cellTypeParam']['balParam']['stopQ'] = CastIntToFloat(conn.upload32(XCPConnection.Pointer(228, 0)))
            
            data['cellTypeParam']['protParam']['highTMaxV'] = CastIntToFloat(conn.upload32(XCPConnection.Pointer(232, 0)))
            data['cellTypeParam']['protParam']['lowTMaxV'] = CastIntToFloat(conn.upload32(XCPConnection.Pointer(236, 0)))
            data['cellTypeParam']['protParam']['highTForMaxV'] = CastIntToFloat(conn.upload32(XCPConnection.Pointer(240, 0)))
            data['cellTypeParam']['protParam']['lowTForMaxV'] = CastIntToFloat(conn.upload32(XCPConnection.Pointer(244, 0)))
            data['cellTypeParam']['protParam']['highTMinV'] = CastIntToFloat(conn.upload32(XCPConnection.Pointer(248, 0)))
            data['cellTypeParam']['protParam']['lowTMinV'] = CastIntToFloat(conn.upload32(XCPConnection.Pointer(252, 0)))
            data['cellTypeParam']['protParam']['highTForMinV'] = CastIntToFloat(conn.upload32(XCPConnection.Pointer(256, 0)))
            data['cellTypeParam']['protParam']['lowTForMinV'] = CastIntToFloat(conn.upload32(XCPConnection.Pointer(260, 0)))
            data['cellTypeParam']['protParam']['rForCellProt'] = CastIntToFloat(conn.upload32(XCPConnection.Pointer(264, 0)))
            data['cellTypeParam']['protParam']['thermalMaxI'] = CastIntToFloat(conn.upload32(XCPConnection.Pointer(268, 0)))
            data['cellTypeParam']['protParam']['zeroITemp'] = CastIntToFloat(conn.upload32(XCPConnection.Pointer(272, 0)))
            data['cellTypeParam']['protParam']['safeMaxT'] = CastIntToFloat(conn.upload32(XCPConnection.Pointer(276, 0)))
            data['cellTypeParam']['protParam']['highWarnT'] = CastIntToFloat(conn.upload32(XCPConnection.Pointer(280, 0)))
            data['cellTypeParam']['protParam']['safeMinT'] = CastIntToFloat(conn.upload32(XCPConnection.Pointer(284, 0)))
            data['cellTypeParam']['protParam']['lowWarnT'] = CastIntToFloat(conn.upload32(XCPConnection.Pointer(288, 0)))

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
