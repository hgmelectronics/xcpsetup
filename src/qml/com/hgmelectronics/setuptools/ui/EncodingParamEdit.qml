import QtQuick 2.5
import QtQuick.Controls 1.4
import QtQuick.Layouts 1.2
import com.hgmelectronics.setuptools.xcp 1.0
import com.hgmelectronics.setuptools 1.0

GroupBox {
    id: groupBox
    property ScalarMetaParam metaParam
    property string name: metaParam.name
    property ScalarParam param: metaParam.param
    enabled: param.valid
    title: name
    implicitWidth: Math.max(sizeHint.implicitWidth + 16, combo.implicitWidth + label.implicitWidth + 16)
    width: implicitWidth

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
            validator: param.slot.validator
        }

        Label {
            id: label
            text: param.slot.unit
        }

        Text {
            id: sizeHint
            visible: false
            text: name
        }
    }

    function updateCombo() {
        combo.currentIndex = param.slot.engrToEncodingIndex(param.stringVal)
        if (combo.currentIndex == -1)
            combo.editText = param.stringVal
    }

    Connections {
        target: param
        onValChanged: updateCombo()
    }

    Component.onCompleted: updateCombo()
}
