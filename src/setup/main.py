'''
Created on Jun 14, 2013

@author: gcardwel
'''

import json
from paramtypes import SLOT


encodings = {}

encodings['boolean'] = { 0:'none', 1:''}



slots = {}
paramtraits = {}

slots['percent1'] = SLOT('percent1', '%', 1, 1, 0, 0, 'boolean1')
slots['boolean1'] = SLOT('boolean1', '', 1, 1, 0, 0, '')

params = {}

setup = {}
setup['encodings'] = encodings
setup['slots'] = slots
setup['params'] = params

print(json.dumps(setup))

if __name__ == '__main__':
    pass
