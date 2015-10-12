import QtQuick 2.5
import QtQuick.Controls 1.4
import QtQuick.Layouts 1.2
import com.hgmelectronics.setuptools.xcp 1.0
import com.hgmelectronics.setuptools 1.0

GroupBox {
    id: groupBox
    enabled: param.valid
    property alias horizontalAlignment: textField.horizontalAlignment
    property ScalarMetaParam metaParam
    property string name: metaParam.name
    property ScalarParam param: metaParam.param
    title: name
    implicitWidth: Math.max(sizeHint.implicitWidth + 6, textField.implicitWidth + label.implicitWidth + 10)

    Text {
        id: sizeHint
        visible: false
        text: name
        font.bold: true
    }

    RowLayout {
        anchors.fill: parent
        TextField {
            id: textField
            text: param.stringVal
            readOnly: !param.range.writable
            horizontalAlignment: TextInput.AlignRight
            onEditingFinished: {
                if(param.stringVal != text)
                    param.stringVal = text
            }
            validator: param.slot.validator
            Layout.fillWidth: true
        }
        Label {
            id: label
            text: param.slot.unit
        }
    }
}
