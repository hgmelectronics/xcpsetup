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
        return 1; 
 
    def columnCount(self, parent): 
        return len(self.value)
 
    def toValue(self, slot, data):
        encoding = slot.encoding
        if data in encoding:
            return encoding[data]
        else:
            return ((data * slot.numerator) / slot.denominator) - slot.offset
        
# this needs to convert the index to an offset,
# then call get on the parameter, then scale based on the xslot.

    def data(self, index, role): 
        if not index.isValid(): 
            return None
        elif role != Qt.DisplayRole: 
            return None
        return self.toValue(self.traits.xslot, self.value[index.column()]) 

    def headerData(self, col, orientation, role):
        if orientation == Qt.Horizontal and role == Qt.DisplayRole:
            return self.toValue(self.traits.yslot, col)
        return None

    def flags(self, index):
        flag = QAbstractTableModel.flags(self, index)
        if self.traits.write:
            return flag | Qt.ItemIsEditable
        else:
            return flag 
    
    
