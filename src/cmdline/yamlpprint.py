'''
Created on Jul 15, 2014

@author: gcardwel
'''
import yaml
import pprint
import argparse

def yamlpprint():
    'Syntax check a YAML file and pritty print the resulting object'
    try:
        parser = argparse.ArgumentParser(description=__doc__)
        parser.add_argument('file', help="YAML file name", type=argparse.FileType("r"), default=None)
        args = parser.parse_args()
        data = yaml.safe_load(args.file)
        pprint.pprint(data)
    except Exception as e:
        print(e)


if __name__ == '__main__':
    yamlpprint()