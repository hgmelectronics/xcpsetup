#!/usr/bin/python3

import sys
import copy

if not '..' in sys.path:
    sys.path.append('..')

from comm import XCPConnection
from util import casts

def SLOTScaleFactor(slot):
    return float(slot['numerator']) / float(slot['denominator']) / pow(10.0, slot['decimals'])

def WriteScalar(value, param, paramSpec, conn):
    slot = paramSpec['slots'][param['slots'][-1]]
    addr = param['addr']
    addrext = 0 if not 'addrext' in param else param['addrext']
    ptr = XCPConnection.Pointer(addr, addrext)
    unscaledFloat = value / SLOTScaleFactor(slot)
    raw = casts.poly(slot['type'], casts.uintTypeFor(slot['type']), unscaledFloat)
    if casts.sizeof(slot['type']) == 4:
        conn.download32(ptr, raw)
    elif casts.sizeof(slot['type']) == 2:
        conn.download16(ptr, raw)
    elif casts.sizeof(slot['type']) == 1:
        conn.download8(ptr, raw)
    else:
        raise ValueError

def WriteParam(value, param, paramSpec, conn):
    if len(param['slots']) == 1:
        return WriteScalar(value, param, paramSpec, conn)
    else:
        indepSlot = paramSpec['slots'][param['slots'][0]]
        length = indepSlot['max'] - indepSlot['min'] + 1
        paramIt = copy.deepcopy(param)
        subParamSpec = copy.deepcopy(paramSpec)
        del subParamSpec['slots'][0]
        for idx in range(0, length):
            paramIt['addr'] = param['addr'] + idx
            WriteParam(value[idx], paramIt, subParamSpec, conn)

def ReadScalar(param, paramSpec, conn):
    slot = paramSpec['slots'][param['slots'][-1]]
    addr = param['addr']
    addrext = 0 if not 'addrext' in param else param['addrext']
    ptr = XCPConnection.Pointer(addr, addrext)
    if casts.sizeof(slot['type']) == 4:
        raw = conn.upload32(ptr)
    elif casts.sizeof(slot['type']) == 2:
        raw = conn.upload16(ptr)
    elif casts.sizeof(slot['type']) == 1:
        raw = conn.upload8(ptr)
    else:
        raise ValueError
    castRaw = casts.poly(casts.uintTypeFor(slot['type']), slot['type'], raw)
    return float(castRaw) * SLOTScaleFactor(slot)

def ReadParam(param, paramSpec, conn):
    if len(param['slots']) == 1:
        return ReadScalar(param, paramSpec, conn)
    else:
        indepSlot = paramSpec['slots'][param['slots'][0]]
        length = indepSlot['max'] - indepSlot['min'] + 1
        ret = [0.0] * length
        paramIt = copy.deepcopy(param)
        subParamSpec = copy.deepcopy(paramSpec)
        del subParamSpec['slots'][0]
        for idx in range(0, length):
            paramIt['addr'] = param['addr'] + idx
            ret[idx] = ReadParam(paramIt, subParamSpec, conn)
        return ret
