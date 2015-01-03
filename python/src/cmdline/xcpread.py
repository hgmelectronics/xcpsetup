#!/usr/bin/python3
import argparse

from comm import CANInterface
from comm import XCPConnection
from util import plugins


class UploadDelegate8:
    def upload(self, connection, pointer):
        return connection.upload8(pointer)

class UploadDelegate16:
    def upload(self, connection, pointer):
        return connection.upload16(pointer)


class UploadDelegate32:
    def upload(self, connection, pointer):
        return connection.upload32(pointer)


def hexInt(param):
    return int(param, 0)

plugins.loadPlugins()

readTimeout = .2
writeTimeout = 1.0

parser = argparse.ArgumentParser(description="read data from an XCP slave at a given address")
parser.add_argument('-d', help="CAN device URI", dest="deviceURI", default=None)
parser.add_argument('commandId', help='command id', type=hexInt)
parser.add_argument('responseId', help='response id', type=hexInt)
parser.add_argument('address', help='address', type=hexInt)
parser.add_argument('-e', help='address extension', type=hexInt, dest='extension', default=0)
parser.add_argument('size', help='word size', type=int, choices=[1, 2, 4])
parser.add_argument('words', help='number of words to read', type=hexInt, default=1)
args = parser.parse_args()

if args.size == 1:
    uploadDelegate = UploadDelegate8()
elif args.size == 2:
    uploadDelegate = UploadDelegate16()
elif args.size == 4:
    uploadDelegate = UploadDelegate32()

try:
    with CANInterface.MakeInterface(args.deviceURI) as interface:
        slave = CANInterface.XCPSlaveCANAddr(args.commandId, args.responseId)
        interface.connect(slave)
        connection = XCPConnection.Connection(interface, readTimeout, writeTimeout)

        
        for address in range(args.address, args.address + args.words):
            pointer = XCPConnection.Pointer(address, args.extension)
            print(uploadDelegate.upload(connection, pointer))
        connection.close()
        
        
except (OSError, CANInterface.ConnectFailed):
    try:
        interface.close()
    except NameError:
        pass
    raise
except:
    interface.close()
    raise
