'''
Created on Aug 03, 2013

@author: dbrunner
'''

from collections import namedtuple

class CANID(object):
    '''
    CAN identifier
    '''
    
    def __init__(self, raw):
        self.raw = raw
    
    def getString(self):
        if rawid & 0x80000000:
            return "x%x" % self.raw
        else
            return "%x" % self.raw


CANPacket = namedtuple('ident', 'data')
