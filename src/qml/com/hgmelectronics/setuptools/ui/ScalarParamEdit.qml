import QtQuick 2.5
import QtQuick.Controls 1.4
import QtQuick.Layouts 1.2
import com.hgmelectronics.setuptools.xcp 1.0
import com.hgmelectronics.setuptools 1.0
import com.hgmelectronics.setuptools.ui 1.0

GroupBox {
    id: groupBox

    property ScalarMetaParam metaParam
    property string name: metaParam.name
    property alias horizontalAlignment: textField.horizontalAlignment
    property bool enableAutoRefreshOverlay: metaParam.isLiveData

    enabled: param.valid
    property ScalarParam param: metaParam.param
    title: name
    implicitWidth: 166
    width: implicitWidth

    RowLayout {
        id: rowLayout
        anchors.fill: parent
        TextField {
            id: textField
            implicitWidth: groupBox.implicitWidth - label.implicitWidth - 16
            width: groupBox.width - label.implicitWidth - 16
            Layout.fillWidth: true
            text: param.stringVal
            readOnly: !param.range.writable
            horizontalAlignment: TextInput.AlignRight
            onEditingFinished: {
                if(param.stringVal != text) {
                    param.stringVal = text
                    if(metaParam.immediateWrite)
                        ImmediateWrite.trigger(param.key)
                }
            }
            validator: param.slot.validator
            AutoRefreshOverlay {
                key: param.key
                visible: enableAutoRefreshOverlay
                enabled: enableAutoRefreshOverlay
            }
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
}
