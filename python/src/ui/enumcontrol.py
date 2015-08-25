'''
Created on Jun 15, 2013

@author: gcardwel
'''


# #include <QWidget>
# #include <QVariant>
# 
# class QString;
# class QGroupBox;
# class QComboBox;
# class QLabel;
# 
# 
# class EnumControl : public QWidget
# {
#     Q_OBJECT
#     Q_PROPERTY(QString name READ getName WRITE setName)
#     Q_PROPERTY(QString description READ getDescription WRITE setDescription)
#     Q_PROPERTY(QVariantMap values READ getValues WRITE setValues)
#     Q_PROPERTY(QVariant value READ getValue WRITE setValue NOTIFY valueChanged)
# public:
#     explicit EnumControl(QWidget *parent = 0);
# 
#     void setValues(const QVariantMap& map);
#     const QVariantMap& getValues() const ;
# 
#     void setValue(const QVariant& value);
#     QVariant getValue() const;
# 
#     void setName(const QString& name);
#     QString getName() const;
# 
#     void setDescription(const QString& desc);
#     QString getDescription() const;
# 
# signals:
#     void valueChanged(const QVariant& newValue);
# 
# public slots:
# 
# private slots:
#     void comboBoxIndexChanged(const QString& text);
# 
# private:
#     QVariantMap mValuesMap;
#     QGroupBox* mGroupBox;
#     QComboBox* mComboBox;
#     QLabel* mLabel;
# };

from PyQt4 import QtGui
from PyQt4.QtCore import pyqtSignal

class EnumControl(QtGui.QWidget):
    '''
    classdocs
    '''
    name = ''
    value = 0
    description = ''
    valueDict = {}
    

    def __init__(self, parent=None):
        '''
        Constructor
        '''
        super(EnumControl, self, parent).__init__(parent)
        self.sortedKeys = sorted(self.valueDict.keys())
        self.groupBox = QtGui.QGroupBox(self)
        layout = QtGui.QVBoxLayout();
        self.comboBox = QtGui.QComboBox()
        layout.addWidget(self.comboBox)
        self.label = QtGui.QLabel()
        layout.addWidget(self.label)
        self.groupBox.setLayout(layout)


    def setName(self, name):
        self.groupBox.setTitle(name)

    def getName(self):
        return self.groupBox.title()

    def setValue(self, value):
        self.comboBox.setCurrentIndex(self.sortedKeys.index(value))
                
    def getValue(self):
        return self.valueDict.get(self.comboBox.currentText())
                
    def getDescription(self):
        return self.label.text()
    

    def setDescription(self, description):
        self.label.setText(description)
        self.description = description
        
                  
    def setValues(self, valueDict):
        self.valueDict = valueDict;
        self.sortedKeys = sorted(self.valueDict.keys())
        self.comboBox.clear()
        self.comboBox.insertItems(0,valueDict.keys())

    def getValues(self):
        return self.valueDict


                