'''
Created on Jun 16, 2013

@author: gcardwel
'''

import sys
from ui.spinbox import ParamSpinBox
from paramtypes import SLOT

from PyQt4.QtGui import QApplication

def main(): 
    app = QApplication(sys.argv)
    slot = SLOT('decimals2TrueFalse', '%', 1, 1, 0, 2, {0:"false", 1:"true"}, 0, 100)
    w = ParamSpinBox(slot)
    w.show() 

    sys.exit(app.exec_()) 
    
    

if __name__ == "__main__":
    main()
    
