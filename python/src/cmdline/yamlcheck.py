#!/usr/bin/python3
'''
Created on Jul 15, 2014

@author: gcardwel
'''
import yaml
import argparse

def yamlcheck():
    'Syntax check a YAML file and dump back the result'
    try:
        parser = argparse.ArgumentParser(description=__doc__)
        parser.add_argument('file', help="YAML file name", type=argparse.FileType("r"), default=None)
        args = parser.parse_args()
        data = yaml.safe_load(args.file)
        print(yaml.safe_dump(data))
    except Exception as e:
        print(e)


if __name__ == '__main__':
    yamlcheck()