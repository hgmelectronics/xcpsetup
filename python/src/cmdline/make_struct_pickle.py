#!/usr/bin/python3

import argparse
import sys

if not '..' in sys.path:
    sys.path.append('..')
    
import pyclibrary

parser = argparse.ArgumentParser(description="makes a pickled struct definition file from a C header, for use with read_struct and write_struct")
parser.add_argument('inputFile', help="Input file name; struct to be converted must be called _struct")
parser.add_argument('outputFile', help="Output file name")
args = parser.parse_args()

# Create the parser and process the header
structParser = pyclibrary.CParser(files=args.inputFile, processAll=False)
structParser.processAll(cache=args.outputFile, noCacheWarning=False)
