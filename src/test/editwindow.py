
import operator
import sys
from collections import namedtuple 
from PyQt4.QtCore import * 
from PyQt4.QtGui import * 

from PyQt4 import QtCore, QtGui

def main(): 
    app = QApplication(sys.argv) 
    window = EditWindow()
    window.show()
    sys.exit(app.exec_())
    

if __name__ == "__main__": 
    main()