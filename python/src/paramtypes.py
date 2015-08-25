'''
Created on Jun 16, 2013

@author: gcardwel
'''
from collections import namedtuple

SLOT = namedtuple('SLOT', 'name units numerator denominator offset decimals encoding min max')
Encoding = namedtuple('Encoding', 'name encodings')
ParamTraits = namedtuple('ParamTraits', 'name read write save reset xslot yslot')
Param = namedtuple('Param', 'traits value')
