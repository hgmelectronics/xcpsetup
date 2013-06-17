'''
Created on Jun 14, 2013

@author: gcardwel
'''
from PyQt4 import QtGui
from ui.flowlayout import FlowLayout


class Window(QtGui.QWidget):
    def __init__(self):
        super(Window, self).__init__()

        flowLayout = FlowLayout()
        flowLayout.addWidget(QtGui.QPushButton("Short"))
        flowLayout.addWidget(QtGui.QPushButton("Longer"))
        flowLayout.addWidget(QtGui.QPushButton("Different text"))
        flowLayout.addWidget(QtGui.QPushButton("More text"))
        flowLayout.addWidget(QtGui.QPushButton("Even longer button text"))
        self.setLayout(flowLayout)

        self.setWindowTitle("Flow Layout")


if __name__ == '__main__':

    import sys

    app = QtGui.QApplication(sys.argv)
    mainWin = Window()
    mainWin.show()
    sys.exit(app.exec_())