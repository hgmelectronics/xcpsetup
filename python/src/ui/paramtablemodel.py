'''
Created on Jun 15, 2013

@author: gcardwel
'''

'''
Created on Jun 14, 2013

@author: gcardwel
'''
from PyQt4.QtCore import QAbstractTableModel, Qt

 
# this needs to calculate a set of headers from the yslot
# it must iterate through the possible values    
 
 
class ParamTableModel(QAbstractTableModel): 
    
    def __init__(self, param, parent=None): 
        """ datain: a list of lists
            headerdata: a list of strings
        """
        QAbstractTableModel.__init__(self, parent) 
        self.traits = param.traits
        self.value = param.value
        
    def rowCount(self, parent): 
        return len(self.value); 
 
    def columnCount(self, parent): 
        return len(self.value[0])
 
    def toValue(self, slot, data):
        encoding = slot.encoding
        if data in encoding:
            return encoding[data]
        else:
            return ((data * slot.numerator) / slot.denominator) - slot.offset
    
    def fromValue(self, slot, data):
        try:
          key = (key for key,value in slot.encoding.items() if value==data).next()
          return key
        except StopIteration:
          raw = ((data + slot.offset) * slot.denominator) / slot.numerator
          if raw < slot.min or raw > slot.max:
            return None
          else:
            return raw
        
# this needs to convert the index to an offset,
# then call get on the parameter, then scale based on the xslot.

    def data(self, index, role): 
        if not index.isValid(): 
            return None
        elif not (role == Qt.DisplayRole or role == Qt.EditRole): 
            return None
        return self.toValue(self.traits.xslot, self.value[index.row()][index.column()])
    
    def setData(self, index, value, role):
        if not index.isValid(): 
            return False
        elif not (role == Qt.EditRole): 
            return False
        
        raw = self.fromValue(self.traits.xslot, value)
        if raw == None:
          return false
        self.value[index.row()][index.column()] = raw
        return True

    def headerData(self, col, orientation, role):
        if orientation == Qt.Vertical and role == Qt.DisplayRole:
            return self.toValue(self.traits.yslot, col)
        return None

    def flags(self, index):
        flag = QAbstractTableModel.flags(self, index)
        if self.traits.write:
            return flag | Qt.ItemIsEditable
        else:
            return flag 
    
    
