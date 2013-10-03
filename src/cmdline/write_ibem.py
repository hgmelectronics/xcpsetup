#!/usr/bin/python3.3
import getopt
import json
import struct
import sys
from comm import CANInterface
from comm import XCPConnection


def printUsage():
    print("Usage: ", sys.argv[0], "[-d <CAN device>|ICS] [-i <ID>] <inputfile>")

def CastS16ToShort(i):
    return struct.unpack('H', struct.pack('h', i))[0]

def CastFloatToInt(i):
    return struct.unpack('I', struct.pack('f', i))[0]
   
targetID = None
canDev = None
if len(sys.argv) < 2:
    printUsage()
    sys.exit(1)
inputPath = sys.argv[len(sys.argv) - 1]
try:
    opts, args = getopt.getopt(sys.argv[1:len(sys.argv) - 1], "d:i:")
    for opt, arg in opts:
        if opt == "-d":
            canDev = arg
        elif opt == "-i":
            targetID = int(arg)
except (getopt.GetoptError, ValueError):
    printUsage()
    sys.exit(1)

if inputPath == "-":
    data = json.loads(sys.stdin.read())
else:
    inputFile = open(inputPath, 'r')
    data = json.loads(inputFile.read())
    inputFile.close()

try:
    with CANInterface.MakeInterface(canDev) as interface:
        if targetID == None:
            slaves = XCPConnection.GetCANSlaves(interface, 0x9F000000, 0.2)
            for i in range(0, len(slaves)):
                print(str(i) + ': ' + slaves[i].description())
            index = int(input('Slave: '))
            if index >= len(slaves):
                exit
            slave = slaves[index]
        else:
            slave = CANInterface.XCPSlaveCANAddr(0x9F000100 + 2 * targetID, 0x9F000101 + 2 * targetID)
        interface.connect(slave)
        conn = XCPConnection.XCPConnection(interface, 0.2, 1.0)
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
