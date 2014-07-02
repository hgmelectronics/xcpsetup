import struct

structSpecs = { \
    'uint8': 'B', 'int8': 'b', 'uint16': 'H', 'int16': 'h', \
    'uint32': 'L', 'int32': 'l', 'uint64': 'Q', 'int64': 'q', \
    'float': 'f', 'double': 'd'\
}
pyTypes = { \
    'uint8': int, 'int8': int, 'uint16': int, 'int16': int, \
    'uint32': int, 'int32': int, 'uint64': int, 'int64': int, \
    'float': float, 'double': float\
}
def poly(src, dest, i):
    return struct.unpack_from(structSpecs[src],struct.pack(structSpecs[dest],pyTypes[src](i)))[0]

typeSizes = {'uint8': 1, 'int8': 1, 'uint16': 2, 'int16': 2, 'uint32': 4, 'int32': 4, 'uint64': 8, 'int64': 8, 'float': 4, 'double': 8}

uintTypesFor = {1: 'uint8', 2: 'uint16', 4: 'uint32', 8: 'uint64'}

def sizeof(cast):
    return typeSizes[cast]

def uintTypeFor(cast):
    return uintTypesFor[typeSizes[cast]]

def uint16_to_int16(i):
    return struct.unpack_from('h',struct.pack('H',i))[0]

def uint32_to_float(i):
    return struct.unpack_from('f',struct.pack('L',i))[0]

def int16_to_uint16(i):
    return struct.unpack_from('H',struct.pack('h',i))[0]

def float_to_uint32(i):
    return struct.unpack_from('L',struct.pack('f',i))[0]
