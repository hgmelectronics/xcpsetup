import QtQuick 2.5
import QtQuick.Controls 1.4
import QtQuick.Layouts 1.1
import com.hgmelectronics.setuptools.xcp 1.0
import com.hgmelectronics.setuptools 1.0

RowLayout {
    id: root

    property ScalarMetaParam metaParam
    property string name: metaParam.name
    property ScalarParam param: metaParam.param
    property double bitMask: 0x00000001
    implicitWidth: checkBox.implicitWidth + rightLabel.implicitWidth + spacing
    property bool boxRight: false
    property alias textTop: leftLabel.top
    property int textTopMargin: leftLabel.y - root.y

    spacing: 10

    Label {
        id: leftLabel
        text: root.name
        font.bold: true
        enabled: param.valid
        Layout.alignment: Qt.AlignVCenter
        visible: boxRight
    }

    CheckBox {
        id: checkBox
//        height: label.implicitHeight
//        width: label.implicitHeight
        checked: (param.floatVal & bitMask)
        enabled: param.valid
        onClicked: param.floatVal = (param.floatVal & ~bitMask) | (checked ? bitMask : 0)
        Layout.alignment: Qt.AlignVCenter
    }

    Label {
        id: rightLabel
        text: root.name
        font.bold: true
        enabled: param.valid
        Layout.alignment: Qt.AlignVCenter
        visible: !boxRight
    }
}
