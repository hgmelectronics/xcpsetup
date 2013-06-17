'''
Created on Jun 14, 2013

@author: gcardwel
'''

from PyQt4 import QtCore, QtGui
from PyQt4.QtCore import *
from PyQt4.QtGui import *
from editor.sloteditdialog import SLOTEditDialog
from ui.sortedtablemodel import SortedTableModel

import operator
import sys

 
def main(): 
    app = QApplication(sys.argv) 
    w = MyWindow() 
    w.show() 
    window = SLOTEditDialog()
    window.show()

    sys.exit(app.exec_()) 
 
class MyWindow(QWidget): 
    def __init__(self, *args): 
        QWidget.__init__(self, *args) 

        # create table
        self.get_table_data()
        table = self.createTable() 
         
        # layout
        layout = QVBoxLayout()
        layout.addWidget(table) 
        self.setLayout(layout) 

    def get_table_data(self):
        
        self.tabledata = [SLOT('percent1', '%', 1, 1, 0, 0, 'boolean1'),SLOT('boolean1', '', 1, 1, 0, 0, '')] 

    def createTable(self):
        # create the view
        tv = QTableView()

        # set the table model
        headerDict = vars(self.tabledata[0])
        header = list(headerDict.keys())
        tm = SortedTableModel(self.tabledata, header, self) 
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

        # set row height
        nrows = len(self.tabledata)
        for row in range(nrows):
            tv.setRowHeight(row, 18)

        # enable sorting
        tv.setSortingEnabled(True)

        return tv
    
    
    

if __name__ == "__main__": 
    main()