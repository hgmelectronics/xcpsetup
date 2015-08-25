'''
Created on Jun 16, 2013

@author: gcardwel
'''
from PyQt4 import QtCore, QtGui
import math


class ParamSpinBox(QtGui.QDoubleSpinBox):
    '''
    classdocs
    '''
    

    def __init__(self, slot, parent=None, *args):
        '''
        Constructor
        '''
        QtGui.QDoubleSpinBox.__init__(self, parent)
        self.slot = slot
        self.setMaximum(self.valueFromInt(slot.max))
        self.setMinimum(self.valueFromInt(slot.min))
        self.setDecimals(slot.decimals)
        increment = float(slot.numerator)/float(slot.denominator) / math.pow(10,slot.decimals)
        self.setSingleStep(increment)

    def intFromValue(self, value):
        slot = self.slot
        intValue = int(float(value) * math.pow(10,slot.decimals))
        intValue = ((intValue-slot.offset) * slot.denominator) / slot.numerator;
        return intValue
        
    def valueFromInt(self, intValue):
        slot = self.slot
        number = ((intValue * slot.numerator) / slot.denominator) - slot.offset
        number = float(number) / math.pow(10,slot.decimals)
        return number
        
    def validate(self, value, position):
        slot = self.slot
        for possible in slot.encoding.values():
            if possible == value:
                return (QtGui.QValidator.Acceptable,value,position)
            elif possible.startswith(value):
                return (QtGui.QValidator.Intermediate,value,position)
        return QtGui.QDoubleSpinBox.validate(self,value,position)
        
    def textFromValue(self, value):
        slot = self.slot
        encoding = slot.encoding
        intValue = self.intFromValue(value)
        if intValue in encoding:
            return encoding[intValue]
        return QtGui.QDoubleSpinBox.textFromValue(self, value)
        
    
    def valueFromText(self, text):
        slot=self.slot
        for key, value in slot.encoding.items():
            if value == text:
                return key
        return QtGui.QDoubleSpinBox.valueFromText(self,text)
    

class SpinBoxDelegate(QtGui.QStyledItemDelegate):
    def __init__(self, slot, parent=None, *args):
        QtGui.QStyledItemDelegate.__init__(self, parent)
        self.slot = slot
    
    def createEditor(self, parent, option, index):
        editor = ParamSpinBox(self.slot, parent)
        editor.setMinimum(0)
        editor.setMaximum(100)

        return editor

    def setEditorData(self, spinBox, index):
        value = index.model().data(index, QtCore.Qt.EditRole)
        spinBox.setValue(value)

    def setModelData(self, spinBox, model, index):
        spinBox.interpretText()
        value = spinBox.value()

        model.setData(index, value, QtCore.Qt.EditRole)

    def updateEditorGeometry(self, editor, option, index):
        editor.setGeometry(option.rect)


