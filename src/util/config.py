'''
Created on Aug 9, 2014

@author: dbrunner
'''

import yaml
import os

configDict = {}

def recursiveUpdateDict(old, new):
    for key in new:
        if key in old and isinstance(old[key], dict) and isinstance(new[key], dict):
            recursiveUpdateDict(old[key], new[key])
        else:
            old[key] = new[key]

def loadSysConfigs():
    '''
    Loads config files from the system location ($XCPTOOLS_ROOT/config/*.yaml)
    '''
    localDir = os.path.dirname(os.path.realpath(__file__))
    configDir = os.path.join(os.path.dirname(localDir), 'config')
    configFiles = [configDir + '/' + x for x in os.listdir(configDir) if x.endswith('.yaml')]
    loadConfigs(configFiles)

def loadConfigs(files):
    '''
    Loads YAML config files into the system configuration dict.
    '''
    for file in files:
        with open(file, 'r') as fd:
            fileDict = yaml.safe_load(fd)
            recursiveUpdateDict(configDict, fileDict)
    