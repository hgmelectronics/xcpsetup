#!/usr/bin/python3

import argparse
import sys
import binascii

if not '..' in sys.path:
    sys.path.append('..')

from comm import CANInterface
from util import plugins
   
plugins.loadPlugins()

parser = argparse.ArgumentParser(description="echoes CAN packets for interface testing")
parser.add_argument('-d', help="CAN device URI", dest="deviceURI")
args = parser.parse_args()

# Connect to the bus

with CANInterface.MakeInterface(args.deviceURI) as interface:
    while 1:
        frames = interface.receivePackets(1.0)
        for frame in frames:
            print("Rcvd " + hex(frame.ident) + " " + binascii.hexlify(frame.data).decode("utf-8"))
            if frame.ident % 2 == 0:
                interface.transmitTo(frame.data, frame.ident + 1)
