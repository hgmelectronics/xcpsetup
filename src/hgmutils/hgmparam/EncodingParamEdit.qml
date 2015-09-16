import QtQuick 2.5
import QtQuick.Controls 1.4
import QtQuick.Layouts 1.2
import com.hgmelectronics.setuptools.xcp 1.0
import com.hgmelectronics.setuptools 1.0

GroupBox {
    id: groupBox

    property alias name: groupBox.title
    property ScalarParam param

    enabled: param.valid


    RowLayout {
        id: row
        ComboBox {
            id: combo
            model: param.slot.encodingStringList
            editable: true
            onActivated: {
                if (index == -1)
                    param.stringVal = editText
                else
                    param.stringVal = model[index]
            }
            onAccepted: {
                param.stringVal = editText
            }
        }

        Label {
            text: param.slot.unit
        }
    }

    Connections {
        target: param
        onValChanged: {
            combo.currentIndex = param.slot.engrToEncodingIndex(param.stringVal)
            if (combo.currentIndex == -1)
                combo.editText = param.stringVal
        }
    }
}
