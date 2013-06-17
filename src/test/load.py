'''
Created on Jun 16, 2013

@author: gcardwel
'''

import json


def main():
    
    jsonencoding= json.load(open("encoding.json","r"))
    parameters = json.load(open("parameters.json","r"))
    jsonslots = json.load(open("slots.json","r"))
    
    for key,value in jsonslots.items():
        print(key,value)

if __name__ == '__main__':
    main()