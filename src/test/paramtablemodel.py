'''
Created on Jun 15, 2013

@author: gcardwel
'''

'''
Created on Jun 14, 2013

@author: gcardwel
'''

from PyQt4.QtGui import QWidget, QVBoxLayout, QLabel, QTableView, QFont, \
    QApplication

from paramtypes import SLOT,Param,ParamTraits
from ui.paramtablemodel import ParamTableModel
import sys
    

 
def main(): 
    app = QApplication(sys.argv) 
    w = MyWindow() 
    w.show() 
    sys.exit(app.exec_()) 
 
class MyWindow(QWidget): 
    def __init__(self, *args): 
        QWidget.__init__(self, *args) 

        # create table
        table = self.createTable() 
         
        # layout
        layout = QVBoxLayout()
        label = QLabel()
        label.setText("Table");
        layout.addWidget(QLabel())
        layout.addWidget(table) 
        self.setLayout(layout) 

    def createParam(self):
        xslot = SLOT('percent1', '%', 1, 1, 0, 0, { 0:'Disabled' }, 0, 100)
        yslot = SLOT('count1', '', 1, 1, 0, 0, { }, 0, 100)
        traits = ParamTraits('curve', True, False, True, True, xslot, yslot)
        param = Param(traits, [0] * 100)
        return param
    
    def createTable(self):
        # create the view
        tv = QTableView()
                
        tm = ParamTableModel(self.createParam(), self)
        tv.setModel(tm)

        # set the minimum size
        tv.setMinimumSize(400, 300)

        # hide grid
        tv.setShowGrid(False)

        # set the font
        font = QFont("Courier New", 8)
        tv.setFont(font)

        # hide vertical header
        vh = tv.verticalHeader()
        vh.setVisible(False)

        # set horizontal header properties
        hh = tv.horizontalHeader()
        hh.setStretchLastSection(True)

        # set column width to fit contents
        tv.resizeColumnsToContents()

        return tv
    
    
    

if __name__ == "__main__": 
    main()
