import array
import struct
import zlib


class ByteReverser:
    def __init__(self):
        self._table = [sum(0x80 >> iBit for iBit in range(8) if ((iEntry >> iBit) & 0x01)) for iEntry in range(256)]
    
    def rev(self, inp):
        return self._table[inp]
    
class Calc:
    def __init__(self):
        self._byteRev = ByteReverser()
    
    def calc(self, data):
        words = int(len(data) / 4)
        wordData = [data[4 * i:4 + 4 * i] for i in range(words)]
        endianFlipWordData = [struct.pack('<I', struct.unpack('>I', w)[0]) for w in wordData]
        endianFlipData = b''
        for w in endianFlipWordData:
            endianFlipData += w
        brData = array.array('B', [self._byteRev.rev(b) for b in endianFlipData]).tostring()
        zlibCRC = struct.pack('<I', zlib.crc32(brData))
        cbrZlibCRC = array.array('B', [self._byteRev.rev(b) ^ 0xFF for b in zlibCRC]).tostring()
        intCRC = struct.unpack('>I', cbrZlibCRC)[0]
        return intCRC
