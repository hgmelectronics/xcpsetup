#!/usr/bin/python3

import argparse
import ctypes
import json
import sys
import copy

if not '..' in sys.path:
    sys.path.append('..')

from comm import CANInterface
from comm import XCPConnection
from util import plugins
from util import casts
import argProc

plugins.load_plugins()

parser = argparse.ArgumentParser(description="reads data from a board using a JSON file to define locations and data formats")
parser.add_argument('-t', help="CAN device type", dest="deviceType", default=None)
parser.add_argument('-d', help="CAN device name", dest="deviceName", default=None)
parser.add_argument('-T', help="Target device type (ibem,cda,cs2) for automatic XCP ID selection", dest="targetType", default=None)
parser.add_argument('-i', help="Target ID or range of IDs (e.g. 2, 1-3, recovery) for automatic XCP ID selection", dest="targetID", default=None)
parser.add_argument('-p', help="Parameter definition file", dest="paramSpecFile", type=argparse.FileType('r'))
parser.add_argument('-s', help="XCP memory segment in which parameters reside", dest="paramSegment", default=0)
parser.add_argument('-D', help="Dump all XCP traffic, for debugging purposes", dest="dumpTraffic", action="store_true", default=False)
parser.add_argument('inputFile', help="Input file name (if range of IDs specified must contain a {} to be replaced with the ID)", default=None)
args = parser.parse_args()

try:
    boardType = argProc.GetBoardType(args.targetType)
    paramSpec = json.loads(args.paramSpecFile.read())
except argProc.ArgError as exc:
    print(str(exc))
    sys.exit(1)

paramDict = dict()
for param in paramSpec['parameters']:
    paramDict[param['name']] = param

maxAttempts = 10

def OpenInFile(name, id):
    if name == None:
        return sys.stdin
    else:
        return open(name.format(id), 'r')

def SLOTScaleFactor(slot):
    return float(slot['numerator']) / float(slot['denominator']) / pow(10.0, slot['decimals'])

def WriteScalar(value, param, paramSpec, conn):
    slot = paramSpec['slots'][param['slots'][-1]]
    addr = param['addr']
    addrext = 0 if not 'addrext' in param else param['addrext']
    ptr = XCPConnection.Pointer(addr, addrext)
    type = 'uint32' if not 'type' in slot else slot['type']
    unscaledFloat = value / SLOTScaleFactor(slot)
    raw = casts.poly(type, casts.uintTypeFor(type), unscaledFloat)
    if casts.sizeof(type) == 4:
        conn.download32(ptr, raw)
    elif casts.sizeof(type) == 2:
        conn.download16(ptr, raw)
    elif casts.sizeof(type) == 1:
        conn.download8(ptr, raw)
    else:
        raise ValueError

def WriteParam(value, param, paramSpec, conn):
    if len(param['slots']) == 1:
        return WriteScalar(value, param, paramSpec, conn)
    elif len(param['slots']) == 2:
        indepSlot = paramSpec['slots'][param['slots'][0]]
        length = indepSlot['max'] - indepSlot['min'] + 1
        ret = [0.0] * length
        paramIt = copy.deepcopy(param)
        for idx in range(0, length):
            paramIt['addr'] = param['addr'] + idx
            ret[idx] = WriteScalar(value[idx], paramIt, paramSpec, conn)
        return ret
    else:
        raise ValueError

with CANInterface.MakeInterface(args.deviceType, args.deviceName) as interface:
    targetSlaves = boardType.SlaveListFromIDArg(args.targetID)
    # If needed, ask the user to pick a slave from the list
    if len(targetSlaves) == 0:
        slaves = boardType.GetSlaves(interface)
        for i in range(0, len(slaves)):
            print(str(i) + ': ' + slaves[i][0].description() + ', ID ' + str(slaves[i][1]))
        index = int(input('Slave: '))
        if index >= len(slaves):
            exit
        targetSlaves = [slaves[index]]
                
    for targetSlave in targetSlaves:
        if targetSlave[1] != None:
            sys.stderr.write('Connecting to target addr ' + targetSlave[0].description() + ', ID ' + str(targetSlave[1]) + '\n')
        else:
            sys.stderr.write('Connecting to target addr ' + targetSlave[0].description() + '\n')
        
        inFile = OpenInFile(args.inputFile, targetSlave[1])
        inDict = json.loads(inFile.read())
        inFile.close()
        
        for attempt in range(1, maxAttempts + 1):
            try:
                conn = boardType.Connect(interface, targetSlave, args.dumpTraffic)
                
                conn.set_cal_page(args.paramSegment, 0)
                for name in inDict:
                    WriteParam(inDict[name], paramDict[name], paramSpec, conn)
                
                try:
                    conn.close()
                except XCPConnection.Error:
                    pass # swallow any errors when closing connection due to bad target implementations - we really don't care
                
                sys.stderr.write('Write OK\n')
                writeOK = True
                break
            except XCPConnection.Error as err:
                sys.stderr.write('Write failure (' + str(err) + '), attempt #' + str(attempt) + '\n')
                writeOK = False
        if not writeOK:
            sys.exit(1)
