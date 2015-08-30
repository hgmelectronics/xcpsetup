import QtQuick 2.5
import QtQuick.Controls 1.4
import QtQuick.Layouts 1.2
import com.setuptools.xcp 1.0

ColumnLayout {
    property string name
    property ScalarParam param

    Label {
        text: name
    }

    RowLayout {
        ComboBox {
            id: combo
            model: param.slot.encodingStringList
            editable: true
            onActivated: {
                if(index == -1)
                    param.stringVal = editText
                else
                    param.stringVal = model[index]
            }
            onAccepted: {
                param.stringVal = editText
            }
        }

        Label {
            text: param.unit
        }
    }

    Connections {
        target: param
        onValChanged: {
            combo.currentIndex = param.slot.engrToEncodingIndex(param.stringVal)
            if(combo.currentIndex == -1)
                combo.editText = param.stringVal
            console.log(combo.currentIndex)
            console.log(param.stringVal)
        }
    }
}