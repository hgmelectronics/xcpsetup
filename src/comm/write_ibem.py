import CANInterface
import XCPConnection
import sys
import struct
import json
import getopt

def printUsage():
    print("Usage: ", sys.argv[0], "[-d <CAN device>] [-i <ID>] <inputfile>")

def CastS16ToShort(i):
    return struct.unpack_from('H',struct.pack('h',i))[0]

def CastFloatToInt(i):
    return struct.unpack_from('L',struct.pack('f',i))[0]
   
targetID = None
canDev = "can0"
if len(sys.argv) < 2:
	printUsage()
	sys.exit(1)
inputPath = sys.argv[len(sys.argv)-1]
try:
    opts, args = getopt.getopt(sys.argv[1:len(sys.argv)-1], "d:i:")
    for opt, arg in opts:
        if opt == "-d":
            canDev = arg
        elif opt == "-i":
            targetID = int(arg)
except (getopt.GetoptError,ValueError):
	printUsage()
	sys.exit(1)

if inputPath == "-":
	data = json.loads(sys.stdin.read())
else:
    inputFile = open(inputPath, 'r')
    data = json.loads(inputFile.read())
    inputFile.close()

try:
    interface = CANInterface.SocketCANInterface(canDev)
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
    conn.download8(XCPConnection.XCPPointer(0, 0), data['boardID'])
    for i in range(0, 8):
        conn.download16(XCPConnection.XCPPointer(4 + 2*i, 0), CastS16ToShort(data['afeCalib']['zeroCts'][i]))
        conn.download32(XCPConnection.XCPPointer(20 + 4*i, 0), CastFloatToInt(data['afeCalib']['scale'][i]))
    for i in range(0, 11):
        conn.download32(XCPConnection.XCPPointer(52 + 4*i, 0), CastFloatToInt(data['cellTypeParam']['vocParam']['soc'][i]))
        conn.download32(XCPConnection.XCPPointer(96 + 4*i, 0), CastFloatToInt(data['cellTypeParam']['vocParam']['voc'][i]))
    conn.download32(XCPConnection.XCPPointer(140, 0), CastFloatToInt(data['cellTypeParam']['riParam']['socBreakpt']))
    conn.download32(XCPConnection.XCPPointer(144, 0), CastFloatToInt(data['cellTypeParam']['riParam']['rAtZeroSOC']))
    conn.download32(XCPConnection.XCPPointer(148, 0), CastFloatToInt(data['cellTypeParam']['riParam']['dRdSOCLow']))
    conn.download32(XCPConnection.XCPPointer(152, 0), CastFloatToInt(data['cellTypeParam']['riParam']['dRdSOCHigh']))
    conn.download32(XCPConnection.XCPPointer(156, 0), CastFloatToInt(data['cellTypeParam']['riParam']['rInterconn']))
    conn.download32(XCPConnection.XCPPointer(160, 0), CastFloatToInt(data['cellTypeParam']['riParam']['rDToRC']))
    
    conn.download32(XCPConnection.XCPPointer(164, 0), CastFloatToInt(data['cellTypeParam']['modelParam']['minR']))
    conn.download32(XCPConnection.XCPPointer(168, 0), CastFloatToInt(data['cellTypeParam']['modelParam']['maxR']))
    conn.download32(XCPConnection.XCPPointer(172, 0), CastFloatToInt(data['cellTypeParam']['modelParam']['srVarI']))
    conn.download32(XCPConnection.XCPPointer(176, 0), CastFloatToInt(data['cellTypeParam']['modelParam']['srVarSOC']))
    conn.download32(XCPConnection.XCPPointer(180, 0), CastFloatToInt(data['cellTypeParam']['modelParam']['srVarRPerI']))
    conn.download32(XCPConnection.XCPPointer(184, 0), CastFloatToInt(data['cellTypeParam']['modelParam']['srVarRMinI']))
    conn.download32(XCPConnection.XCPPointer(188, 0), CastFloatToInt(data['cellTypeParam']['modelParam']['srVarMeasV']))
    conn.download32(XCPConnection.XCPPointer(192, 0), CastFloatToInt(data['cellTypeParam']['modelParam']['srMinBetaV']))
    conn.download32(XCPConnection.XCPPointer(196, 0), CastFloatToInt(data['cellTypeParam']['modelParam']['nomCellCap']))
    conn.download32(XCPConnection.XCPPointer(200, 0), CastFloatToInt(data['cellTypeParam']['modelParam']['nomCellR']))
    conn.download32(XCPConnection.XCPPointer(204, 0), CastFloatToInt(data['cellTypeParam']['modelParam']['usableDischI']))
    conn.download32(XCPConnection.XCPPointer(208, 0), CastFloatToInt(data['cellTypeParam']['modelParam']['usableChgI']))
    conn.download32(XCPConnection.XCPPointer(212, 0), CastFloatToInt(data['cellTypeParam']['modelParam']['capEstHistLength']))
    
    conn.download32(XCPConnection.XCPPointer(216, 0), CastFloatToInt(data['cellTypeParam']['balParam']['qPerVSec']))
    conn.download32(XCPConnection.XCPPointer(220, 0), CastFloatToInt(data['cellTypeParam']['balParam']['minAccQ']))
    conn.download32(XCPConnection.XCPPointer(224, 0), CastFloatToInt(data['cellTypeParam']['balParam']['maxAccQ']))
    conn.download32(XCPConnection.XCPPointer(228, 0), CastFloatToInt(data['cellTypeParam']['balParam']['stopQ']))
    
    conn.download32(XCPConnection.XCPPointer(232, 0), CastFloatToInt(data['cellTypeParam']['protParam']['highTMaxV']))
    conn.download32(XCPConnection.XCPPointer(236, 0), CastFloatToInt(data['cellTypeParam']['protParam']['lowTMaxV']))
    conn.download32(XCPConnection.XCPPointer(240, 0), CastFloatToInt(data['cellTypeParam']['protParam']['highTForMaxV']))
    conn.download32(XCPConnection.XCPPointer(244, 0), CastFloatToInt(data['cellTypeParam']['protParam']['lowTForMaxV']))
    conn.download32(XCPConnection.XCPPointer(248, 0), CastFloatToInt(data['cellTypeParam']['protParam']['highTMinV']))
    conn.download32(XCPConnection.XCPPointer(252, 0), CastFloatToInt(data['cellTypeParam']['protParam']['lowTMinV']))
    conn.download32(XCPConnection.XCPPointer(256, 0), CastFloatToInt(data['cellTypeParam']['protParam']['highTForMinV']))
    conn.download32(XCPConnection.XCPPointer(260, 0), CastFloatToInt(data['cellTypeParam']['protParam']['lowTForMinV']))
    conn.download32(XCPConnection.XCPPointer(264, 0), CastFloatToInt(data['cellTypeParam']['protParam']['rForCellProt']))
    conn.download32(XCPConnection.XCPPointer(268, 0), CastFloatToInt(data['cellTypeParam']['protParam']['thermalMaxI']))
    conn.download32(XCPConnection.XCPPointer(272, 0), CastFloatToInt(data['cellTypeParam']['protParam']['zeroITemp']))
    conn.download32(XCPConnection.XCPPointer(276, 0), CastFloatToInt(data['cellTypeParam']['protParam']['safeMaxT']))
    conn.download32(XCPConnection.XCPPointer(280, 0), CastFloatToInt(data['cellTypeParam']['protParam']['highWarnT']))
    conn.download32(XCPConnection.XCPPointer(284, 0), CastFloatToInt(data['cellTypeParam']['protParam']['safeMinT']))
    conn.download32(XCPConnection.XCPPointer(288, 0), CastFloatToInt(data['cellTypeParam']['protParam']['lowWarnT']))
    
    print("Writing flash")
    conn.nvwrite()
    conn.close()
except (OSError,CANInterface.CANConnectFailed):
    try:
        interface.close()
    except NameError:
        pass
    print("Is interface up? Try \"sudo ip link set " + canDev + "up type can bitrate 250000\"")
    raise
except:
    interface.close()
    raise
interface.close()
