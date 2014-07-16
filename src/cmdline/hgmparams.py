#!/usr/bin/python3

import argparse
import json
import sys

parser = argparse.ArgumentParser(description='makes a parameter JSON file suitable for read_config and write_config from HGM parameter definition files')
parser.add_argument('inputFile', help='input JSON with param IDs, params, and SLOTs', type=argparse.FileType('r'))
parser.add_argument('-o', help='Output file name', dest='outputJSONFile', type=argparse.FileType('w'))
args = parser.parse_args()

paramSpec = json.loads(args.inputFile.read())

for param in paramSpec['parameters']:
    param['addr'] = int(paramSpec['globalEnums'][param['id']], 16) * 65536
    del param['id']
    param['addrext'] = 0
    param['type'] = 'int32'

del paramSpec['globalEnums']

args.outputJSONFile.write(json.dumps(paramSpec, sort_keys=True, indent=4, separators=(',', ': ')))
