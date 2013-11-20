#!/usr/bin/python
# srec.py
#
# Copyright (C) 2011 Gabriel Tremblay - initnull hat gmail.com
# Copyright (C) 2013 Doug Brunner - dbrunner@ebus.com
#
# This program is free software; you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation; either version 3 of the License, or
# (at your option) any later version.
#
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with this program; if not, write to the Free Software
# Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307  USA

import array
import struct
import zlib
import copy

class Block(object):
    def __init__(self, baseaddr_in, data_in):
        self.baseaddr = baseaddr_in
        self.data = data_in

# Address len in bytes for S* types
# http://www.amelek.gda.pl/avr/uisp/srecord.htm
__ADDR_LEN = {'S0' : 2,
              'S1' : 2,
              'S2' : 3,
              'S3' : 4,
              'S5' : 2,
              'S7' : 4,
              'S8' : 3,
              'S9' : 2}

def compute_srec_checksum(srec):
    """
        Compute the checksum byte of a given S-Record
        Returns: The checksum as a string hex byte (ex: "0C")
    """
    # Get the summable data from srec
    # start at 2 to remove the S* record entry
    data = srec[2:len(srec)]

    sum = 0
    # For each byte, convert to int and add.
    # (step each two character to form a byte)
    for position in range(0, len(data), 2):
        current_byte = data[position : position+2]
        int_value = int(current_byte, 16)
        sum += int_value

    # Extract the Least significant byte from the hex form
    hex_sum = hex(sum)
    least_significant_byte = hex_sum[len(hex_sum)-2:]
    least_significant_byte = least_significant_byte.replace('x', '0')

    # turn back to int and find the 8-bit one's complement
    int_lsb = int(least_significant_byte, 16)
    computed_checksum = (~int_lsb) & 0xff

    return computed_checksum

def validate_srec_checksum(srec):
    """
        Validate if the checksum of the supplied s-record is valid
        Returns: True if valid, False if not
    """
    checksum = srec[len(srec)-2:]

    # Strip the original checksum and compare with the computed one
    if compute_srec_checksum(srec[:len(srec) - 2]) == int(checksum, 16):
        return True
    else:
        return False

def parse_srec(srec):
    """
        Extract the data portion of a given S-Record (without checksum)
        Returns: the record type, the lenght of the data section, the write address, the data itself and the checksum
    """
    record_type = srec[0:2]
    data_len = srec[2:4]
    addr_len = __ADDR_LEN.get(record_type) * 2
    addr = srec[4:4 + addr_len]
    data = srec[4 + addr_len:len(srec)-2]
    checksum = srec[len(srec) - 2:]
    return record_type, data_len, addr, data, checksum

class Error(Exception):
    pass

class ChecksumError(Error):
    def __init__(self, value=None):
        self._value = value
    def __str__(self):
        if self._value != None:
            return 'Checksum error in ' + self._value
        else:
            return 'Checksum error'

def ReadFile(file):
    blocks = []
    for binsrec in file:
        srec = binsrec.decode('ascii')
        srec = srec.strip('\n').strip('\r')
        
        if not validate_srec_checksum(srec):
            raise ChecksumError(srec)
            
        recordTypeStr, dataLenStr, addrStr, dataStr, checksumStr = parse_srec(srec)
        if recordTypeStr == 'S1' or recordTypeStr == 'S2' or recordTypeStr == 'S3':
            addr = int(addrStr, 16)
            data = bytes.fromhex(dataStr)
            
            if len(blocks) > 0 and (blocks[-1].baseaddr + len(blocks[-1].data)) == addr:
                # Append to an existing block
                blocks[-1].data += data
            else:
                blocks.append(Block(addr, data))
    
    return blocks

def MakeSingleBlock(blocks, pad=b'\x00'):
    block = copy.deepcopy(blocks[0])
    for addBlock in blocks[1:]:
        block.data = block.data.ljust(addBlock.baseaddr - block.baseaddr, pad)
        block.data += addBlock.data
    return block

