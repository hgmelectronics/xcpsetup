#!/usr/bin/python3.3
import CANInterface
import XCPConnection
import sys
import struct
import getopt

import STCRC

def printUsage():
    print("Usage: ", sys.argv[0], "[-d <CAN device>|ICS] [-i <ID>] <inputfile>")

def CastShortToS16(i):
    return struct.unpack('h',struct.pack('H',i))[0]

def CastIntToFloat(i):
    return struct.unpack('f',struct.pack('I',i))[0]
   
targetID = None
outputPath = None
canDev = "can0"
if len(sys.argv) < 2:
	printUsage()
	sys.exit(1)
inputPath = sys.argv[len(sys.argv)-1]
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

if inputPath == "-":
	data = sys.stdin.buffer.read()
else:
    inputFile = open(inputPath, 'rb')
    data = inputFile.read()
    inputFile.close()

crcCalc = STCRC.Calc()
dataCRC = crcCalc.calc(data)
print("Input file \"" + inputPath + "\"")
print("Size: " + str(len(data)))
print("CRC32-STM32: " + hex(dataCRC))

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
        conn = XCPConnection.XCPConnection(interface, 0.5, 2.0)
        conn.program_app(XCPConnection.XCPPointer(0x08004000, 0), data, dataCRC)
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
