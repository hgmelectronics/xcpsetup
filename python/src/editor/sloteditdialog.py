
from PyQt5 import QtGui

class SLOTEditDialog(QtGui.QWidget):
    def __init__(self, parent=None, model, encodingModel):
        super(SLOTEditDialog, self).__init__(parent)

        self.model = model
        self.encodingModel = encodingModel

        # Set up the widgets.
        nameLabel = QtGui.QLabel("Name")
        nameEdit = QtGui.QLineEdit()

        symbolLabel = QtGui.QLabel("Symbol")
        symbolEdit = QtGui.QLineEdit()
        symbolLabel.setBuddy(symbolEdit)

        numeratorLabel = QtGui.QLabel("Numerator")
        numeratorEdit = QtGui.QLineEdit()
        numeratorLabel.setBuddy(numeratorEdit)

        denominatorLabel = QtGui.QLabel("Denominator")
        denominatorEdit = QtGui.QLineEdit()
        denominatorLabel.setBuddy(denominatorEdit)

        offsetLabel = QtGui.QLabel("Offset")
        offsetEdit = QtGui.QLineEdit()
        offsetLabel.setBuddy(offsetEdit)

        encodingLabel = QtGui.QLabel("Encoding")
        encodingComboBox = QtGui.QComboBox()
        encodingLabel.setBuddy(encodingComboBox)

        self.nextButton = QtGui.QPushButton("&Next")
        self.previousButton = QtGui.QPushButton("&Previous")

        encodingComboBox.setModel(self.encodingModel)

        # Set up the mapper.
        self.mapper = QtGui.QDataWidgetMapper(self)
        self.mapper.setModel(self.model)
        self.mapper.addMapping(nameEdit, 0)
        self.mapper.addMapping(symbolEdit, 1)
        self.mapper.addMapping(numeratorEdit,2)
        self.mapper.addMapping(denominatorEdit,3)
        self.mapper.addMapping(offsetEdit,4)
        self.mapper.addMapping(encodingComboBox, 6)

        # Set up connections and layouts.
        self.previousButton.clicked.connect(self.mapper.toPrevious)
        self.nextButton.clicked.connect(self.mapper.toNext)
        self.mapper.currentIndexChanged.connect(self.updateButtons)

        layout = QtGui.QGridLayout()
        layout.addWidget(nameLabel, 0, 0, 1, 1)
        layout.addWidget(nameEdit, 0, 1, 1, 1)
        layout.addWidget(self.previousButton, 0, 2, 1, 1)
        layout.addWidget(symbolLabel, 1, 0, 1, 1)
        layout.addWidget(symbolEdit, 1, 1, 2, 1)
        layout.addWidget(self.nextButton, 1, 2, 1, 1)
        layout.addWidget(encodingLabel, 3, 0, 1, 1)
        layout.addWidget(encodingComboBox, 3, 1, 1, 1)
        self.setLayout(layout)

        self.mapper.toFirst()

    def updateButtons(self, row):
        self.previousButton.setEnabled(row > 0)
        self.nextButton.setEnabled(row < self.model.rowCount() - 1)


