#!/usr/bin/python3.3
import CANInterface
import XCPConnection
import sys
import struct
import argparse
 
from comm.XCPConnection import XCPPointer

    
class UploadDelegate8:
    def upload(self, connection, pointer):
        return connection.upload8(pointer)

class UploadDelegate16:
    def upload(self, connection, pointer):
        return connection.upload16(pointer)


class UploadDelegate32:
    def upload(self, connection, pointer):
        return connection.upload32(pointer)


readTimeout = .2
writeTimeout = 1.0

parser = argparse.ArgumentParser(description="read data from an XCP slave at a given address")
parser.add_argument('device', help='CAN device')
parser.add_argument('commandId', help='command id', type=int)
parser.add_argument('responseId', help='response id', type=int)
parser.add_argument('address', help='address', type=int)
parser.add_argument('-e', help='address extension', type=int, dest='extension', default=0)
parser.add_argument('size', help='word size', type=int, choices=[1,2,4])
parser.add_argument('words', help='number of words to read', type=int)
args=parser.parse_args()

if args.size == 1:
    uploadDelegate = UploadDelegate8()
elif args.size == 2:
    uploadDelegate = UploadDelegate16()
elif args.size == 4:
    uploadDelegate = UploadDelegate32()

try:
    with CANInterface.MakeInterface(args.device) as interface:
        slave = CANInterface.XCPSlaveCANAddr(args.commandId, args.responseId)
        interface.connect(slave)
        connection = XCPConnection.XCPConnection(interface, readTimeout, writeTimeout)

        pointer = XCPConnection.XCPPointer(args.address, args.extension)
        print(uploadDelegate.upload(connection, pointer))
        connection.close()
        
        
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
