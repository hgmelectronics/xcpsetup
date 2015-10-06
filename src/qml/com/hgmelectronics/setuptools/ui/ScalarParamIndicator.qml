import QtQuick 2.5
import QtQuick.Controls 1.4
import QtQuick.Extras 1.4
import com.hgmelectronics.setuptools.xcp 1.0
import com.hgmelectronics.setuptools 1.0

Row {
    id: root

    property ScalarMetaParam metaParam
    property string name: metaParam.name
    property ScalarParam param: metaParam.param
    property double bitMask: 0x00000001
    property alias color: indicator.color
    property bool indicatorRight: false

    spacing: 10

    Label {
        id: leftLabel
        text: root.name
        font.bold: true
        enabled: param.valid
        visible: indicatorRight
    }

    StatusIndicator {
        id: indicator
        height: leftLabel.implicitHeight
        width: leftLabel.implicitHeight
        active: (param.floatVal & bitMask)
        enabled: param.valid
    }

    Label {
        id: rightLabel
        text: root.name
        font.bold: true
        enabled: param.valid
        visible: !indicatorRight
    }
}


