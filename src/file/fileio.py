'''
Created on Jun 17, 2013

@author: gcardwel
'''

import json
from paramtypes import *

def _loadJSON(filename):
    file = open(filename,'r')
    return json.load(file)

def _parseEncodingList(encodingList):
    encodingDict = {}
    for entry in encodingList:
        text = entry['text']
        value = entry['value']
        encodingDict[value] = text
    return encodingDict
    

def _parseEncoding(jsonEncoding):
    encodingsDict = {}
    for key,value in jsonEncoding.items():
        # key here is the name of the encoding
        # value is the list of encodings
        encodingsDict[key] = _parseEncodingList(value)
    return encodingsDict

def loadEncoding(filename):
    jsonEncoding = _loadJSON(filename)['encoding']
    return _parseEncoding(jsonEncoding)



def _parseSLOTs(jsonslots, encodingsDict):
    slotDict = {}
    
    for key,value in jsonslots.items():
        encodingName = value['encoding']
        if encodingName in encodingsDict:
            encoding = encodingsDict[encodingName]
        else:
            encoding = {}
        slot = SLOT(key,value['units'], value['numerator'], value['denominator'], value['offset'], value['decimals'], encoding, 0, 0)
        slotDict[key] = slot
    return slotDict

def loadSLOTS(filename, encodingsDict):
    jsonslots = _loadJSON(filename)['slots']
    return _parseSLOTs(jsonslots, encodingsDict)
