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
    property bool enableAutoRefreshOverlay: metaParam.isLiveData

    property ScalarParam param: metaParam.param
    enabled: param.valid
    title: name
    implicitWidth: Math.max(sizeHint.implicitWidth + 16, Math.max(combo.maxEncodingStringWidth + 40, 150) + label.implicitWidth + 16)
    width: implicitWidth

    RowLayout {
        id: row
        ComboBox {
            id: combo
            model: param.slot.encodingStringList
            property int maxEncodingStringWidth
            implicitWidth: groupBox.implicitWidth - label.implicitWidth - 16
            width: groupBox.width - label.implicitWidth - 16
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
            function calcMaxEncodingStringWidth() {
                var maxWidth = 0
                for(var i = 0; i < model.length; ++i) {
                    comboSizeHint.text = model[i]
                    maxWidth = Math.max(maxWidth, comboSizeHint.implicitWidth)
                }
                maxEncodingStringWidth = maxWidth
            }

            Component.onCompleted: calcMaxEncodingStringWidth()
            onModelChanged: calcMaxEncodingStringWidth()
        }

        Text {
            id: comboSizeHint
            visible: false
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

        function updateCombo() {
            combo.currentIndex = param.slot.engrToEncodingIndex(param.stringVal)
            if (combo.currentIndex == -1)
                combo.editText = param.stringVal
        }

        Connections {
            target: param
            onValChanged: row.updateCombo()
        }

        Component.onCompleted: updateCombo()

        AutoRefreshOverlay {
            anchors.fill: combo
            key: param.key
            visible: enableAutoRefreshOverlay
            enabled: enableAutoRefreshOverlay
        }
    }
}
