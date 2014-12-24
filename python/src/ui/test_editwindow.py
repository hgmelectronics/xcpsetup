
import sys
import unittest

from PyQt4.QtCore import * 
from PyQt4.QtGui import * 

class Test(unittest.TestCase):

    def test_fileio(self):
        app = QApplication(sys.argv) 
        window = EditWindow()
        window.show()
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
