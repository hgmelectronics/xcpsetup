'''
Created on Jun 16, 2013

@author: gcardwel
'''

import sys
import unittest

from ui.spinbox import ParamSpinBox
from paramtypes import SLOT
from PyQt4.QtGui import QApplication

class Test(unittest.TestCase):
    def test_ParamSpinBox(self):
        app = QApplication(sys.argv)
        slot = SLOT('decimals2TrueFalse', '%', 1, 1, 0, 2, {0:"false", 1:"true"}, 0, 100)
        w = ParamSpinBox(slot)
        w.show() 
        app.exec_() 
 
    def setUp(self):
        pass


    def tearDown(self):
        pass


    def testName(self):
        pass



if __name__ == "__main__":
    # import sys;sys.argv = ['', 'Test.testName']
    unittest.main()
