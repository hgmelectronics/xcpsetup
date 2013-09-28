#!/usr/bin/python3.3
import CANInterface
import XCPConnection
import sys
import struct
import json
import getopt

def printUsage():
    print("Usage: ", sys.argv[0], "[-d <CAN device>|ICS] [-i <ID>] [-o <outputfile>]")

def CastShortToS16(i):
    return struct.unpack('h',struct.pack('H',i))[0]

def CastIntToFloat(i):
    return struct.unpack('f',struct.pack('I',i))[0]
   
targetID = None
outputPath = None
canDev = None
try:
    opts, args = getopt.getopt(sys.argv[1:], "d:i:o:")
    for opt, arg in opts:
        if opt == "-d":
            canDev = arg
        elif opt == "-i":
            targetID = int(arg)
        elif opt == "-o":
            outputPath = arg
except (getopt.GetoptError,ValueError):
	printUsage()
	sys.exit(1)

try:
    with CANInterface.MakeInterface(canDev) as interface:
        if targetID == None:
            slaves = XCPConnection.XCPGetCANSlaves(interface, 0x9F000000, 0.2)
            for i in range(0, len(slaves)):
                print(str(i) + ': ' + slaves[i].description())
            index = int(input('Slave: '))
            if index >= len(slaves):
                exit
            slave = slaves[index]
        else:
            slave = CANInterface.XCPSlaveCANAddr(0x9F000100 + 2*targetID, 0x9F000101 + 2*targetID)
        interface.connect(slave)
        conn = XCPConnection.XCPConnection(interface, 0.2, 1.0)
        data = {}
        data['boardID'] = conn.upload8(XCPConnection.XCPPointer(0, 0))
        data['afeCalib'] = {'zeroCts': [], 'scale': []}
        for i in range(0, 8):
            data['afeCalib']['zeroCts'].append(CastShortToS16(conn.upload16(XCPConnection.XCPPointer(4 + 2*i, 0))))
            data['afeCalib']['scale'].append(CastIntToFloat(conn.upload32(XCPConnection.XCPPointer(20 + 4*i, 0))))
        data['cellTypeParam'] = {'vocParam': {'soc': [], 'voc': []}, 'riParam': {}, 'modelParam': {}, 'balParam': {}, 'protParam': {}}
        for i in range(0, 11):
            data['cellTypeParam']['vocParam']['soc'].append(CastIntToFloat(conn.upload32(XCPConnection.XCPPointer(52 + 4*i, 0))))
            data['cellTypeParam']['vocParam']['voc'].append(CastIntToFloat(conn.upload32(XCPConnection.XCPPointer(96 + 4*i, 0))))
        data['cellTypeParam']['riParam']['socBreakpt'] = CastIntToFloat(conn.upload32(XCPConnection.XCPPointer(140, 0)))
        data['cellTypeParam']['riParam']['rAtZeroSOC'] = CastIntToFloat(conn.upload32(XCPConnection.XCPPointer(144, 0)))
        data['cellTypeParam']['riParam']['dRdSOCLow'] = CastIntToFloat(conn.upload32(XCPConnection.XCPPointer(148, 0)))
        data['cellTypeParam']['riParam']['dRdSOCHigh'] = CastIntToFloat(conn.upload32(XCPConnection.XCPPointer(152, 0)))
        data['cellTypeParam']['riParam']['rInterconn'] = CastIntToFloat(conn.upload32(XCPConnection.XCPPointer(156, 0)))
        data['cellTypeParam']['riParam']['rDToRC'] = CastIntToFloat(conn.upload32(XCPConnection.XCPPointer(160, 0)))
        
        data['cellTypeParam']['modelParam']['minR'] = CastIntToFloat(conn.upload32(XCPConnection.XCPPointer(164, 0)))
        data['cellTypeParam']['modelParam']['maxR'] = CastIntToFloat(conn.upload32(XCPConnection.XCPPointer(168, 0)))
        data['cellTypeParam']['modelParam']['srVarI'] = CastIntToFloat(conn.upload32(XCPConnection.XCPPointer(172, 0)))
        data['cellTypeParam']['modelParam']['srVarSOC'] = CastIntToFloat(conn.upload32(XCPConnection.XCPPointer(176, 0)))
        data['cellTypeParam']['modelParam']['srVarRPerI'] = CastIntToFloat(conn.upload32(XCPConnection.XCPPointer(180, 0)))
        data['cellTypeParam']['modelParam']['srVarRMinI'] = CastIntToFloat(conn.upload32(XCPConnection.XCPPointer(184, 0)))
        data['cellTypeParam']['modelParam']['srVarMeasV'] = CastIntToFloat(conn.upload32(XCPConnection.XCPPointer(188, 0)))
        data['cellTypeParam']['modelParam']['srMinBetaV'] = CastIntToFloat(conn.upload32(XCPConnection.XCPPointer(192, 0)))
        data['cellTypeParam']['modelParam']['nomCellCap'] = CastIntToFloat(conn.upload32(XCPConnection.XCPPointer(196, 0)))
        data['cellTypeParam']['modelParam']['nomCellR'] = CastIntToFloat(conn.upload32(XCPConnection.XCPPointer(200, 0)))
        data['cellTypeParam']['modelParam']['usableDischI'] = CastIntToFloat(conn.upload32(XCPConnection.XCPPointer(204, 0)))
        data['cellTypeParam']['modelParam']['usableChgI'] = CastIntToFloat(conn.upload32(XCPConnection.XCPPointer(208, 0)))
        data['cellTypeParam']['modelParam']['capEstHistLength'] = CastIntToFloat(conn.upload32(XCPConnection.XCPPointer(212, 0)))
        
        data['cellTypeParam']['balParam']['qPerVSec'] = CastIntToFloat(conn.upload32(XCPConnection.XCPPointer(216, 0)))
        data['cellTypeParam']['balParam']['minAccQ'] = CastIntToFloat(conn.upload32(XCPConnection.XCPPointer(220, 0)))
        data['cellTypeParam']['balParam']['maxAccQ'] = CastIntToFloat(conn.upload32(XCPConnection.XCPPointer(224, 0)))
        data['cellTypeParam']['balParam']['stopQ'] = CastIntToFloat(conn.upload32(XCPConnection.XCPPointer(228, 0)))
        
        data['cellTypeParam']['protParam']['highTMaxV'] = CastIntToFloat(conn.upload32(XCPConnection.XCPPointer(232, 0)))
        data['cellTypeParam']['protParam']['lowTMaxV'] = CastIntToFloat(conn.upload32(XCPConnection.XCPPointer(236, 0)))
        data['cellTypeParam']['protParam']['highTForMaxV'] = CastIntToFloat(conn.upload32(XCPConnection.XCPPointer(240, 0)))
        data['cellTypeParam']['protParam']['lowTForMaxV'] = CastIntToFloat(conn.upload32(XCPConnection.XCPPointer(244, 0)))
        data['cellTypeParam']['protParam']['highTMinV'] = CastIntToFloat(conn.upload32(XCPConnection.XCPPointer(248, 0)))
        data['cellTypeParam']['protParam']['lowTMinV'] = CastIntToFloat(conn.upload32(XCPConnection.XCPPointer(252, 0)))
        data['cellTypeParam']['protParam']['highTForMinV'] = CastIntToFloat(conn.upload32(XCPConnection.XCPPointer(256, 0)))
        data['cellTypeParam']['protParam']['lowTForMinV'] = CastIntToFloat(conn.upload32(XCPConnection.XCPPointer(260, 0)))
        data['cellTypeParam']['protParam']['rForCellProt'] = CastIntToFloat(conn.upload32(XCPConnection.XCPPointer(264, 0)))
        data['cellTypeParam']['protParam']['thermalMaxI'] = CastIntToFloat(conn.upload32(XCPConnection.XCPPointer(268, 0)))
        data['cellTypeParam']['protParam']['zeroITemp'] = CastIntToFloat(conn.upload32(XCPConnection.XCPPointer(272, 0)))
        data['cellTypeParam']['protParam']['safeMaxT'] = CastIntToFloat(conn.upload32(XCPConnection.XCPPointer(276, 0)))
        data['cellTypeParam']['protParam']['highWarnT'] = CastIntToFloat(conn.upload32(XCPConnection.XCPPointer(280, 0)))
        data['cellTypeParam']['protParam']['safeMinT'] = CastIntToFloat(conn.upload32(XCPConnection.XCPPointer(284, 0)))
        data['cellTypeParam']['protParam']['lowWarnT'] = CastIntToFloat(conn.upload32(XCPConnection.XCPPointer(288, 0)))
        
        if outputPath:
            outFile = open(outputPath, "w+")
            outFile.write(json.dumps(data))
            outFile.close()
        else:
            print(json.dumps(data))
            
        conn.close()
except (OSError,CANInterface.CANConnectFailed):
    try:
        interface.close()
    except NameError:
        pass
    raise
except:
    interface.close()
    raise
interface.close()
