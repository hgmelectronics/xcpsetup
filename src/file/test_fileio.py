'''
Created on Jun 17, 2013

@author: gcardwel
'''
import unittest
import pprint
from . import fileio

class Test(unittest.TestCase):

    def test_fileio(self):
        encodings = fileio.loadEncoding('encoding.json')
        slots = fileio.loadSLOTS('slots.json', encodings)
        
        pp = pprint.PrettyPrinter(indent=4)
        pp.pprint(slots)
    
#        jsonparameters = fileio._loadJSON('parameters.json')['parameters']
        
 
    def setUp(self):
        pass


    def tearDown(self):
        pass


    def testName(self):
        pass


if __name__ == "__main__":
    # import sys;sys.argv = ['', 'Test.testName']
    unittest.main()
