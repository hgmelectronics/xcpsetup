import array
import struct
import zlib

'''
Classes to implement the ST CRC32, which uses the regular CRC32 polynomial but omits the reflect-in, reflect-out, and complement used by zlib CRC32
'''

class ByteReverser:
    def __init__(self):
        self._table = [sum(0x80 >> iBit for iBit in range(8) if ((iEntry >> iBit) & 0x01)) for iEntry in range(256)]
    
    def rev(self, inp):
        return self._table[inp]
    
class Calc:
    def __init__(self):
        self._byteRev = ByteReverser()
    
    def calc(self, data):
        # Reflect each 32-bit word in the incoming data
        #  Convert data into an array of bytestrings with length 4
        words = int(len(data) / 4)
        wordData = [data[4 * i:4 + 4 * i] for i in range(words)]
        #  Reverse the order of the bytes in each byte string (endian flip)
        endianFlipWordData = [struct.pack('<I', struct.unpack('>I', w)[0]) for w in wordData]
        endianFlipData = b''
        for w in endianFlipWordData:
            endianFlipData += w
        #  Reverse the bits in each byte
        brData = array.array('B', [self._byteRev.rev(b) for b in endianFlipData]).tostring()
        # Compute standard CRC32 on the reflected data
        zlibCRC = struct.pack('<I', zlib.crc32(brData))
        # Complement the CRC32 and reflect its bits
        cbrZlibCRC = array.array('B', [self._byteRev.rev(b) ^ 0xFF for b in zlibCRC]).tostring()
        intCRC = struct.unpack('>I', cbrZlibCRC)[0]
        return intCRC
