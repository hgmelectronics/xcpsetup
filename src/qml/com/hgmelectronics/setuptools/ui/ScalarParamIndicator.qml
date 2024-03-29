import QtQuick 2.5
import QtQuick.Controls 1.4
import QtQuick.Layouts 1.1
import QtQuick.Extras 1.4
import com.hgmelectronics.setuptools.xcp 1.0
import com.hgmelectronics.setuptools 1.0
import com.hgmelectronics.setuptools.ui 1.0

RowLayout {
    id: root

    property ScalarMetaParam metaParam
    property string name: metaParam.name
    property double bitMask: 0x00000001
    property alias color: indicator.color
    property bool indicatorRight: false
    property bool enableAutoRefreshOverlay: metaParam.isLiveData

    property ScalarParam param: metaParam.param
    spacing: 10

    Label {
        id: leftLabel
        text: root.name
        font.bold: true
        enabled: param.valid
        visible: indicatorRight
    }

    Rectangle {
        height: leftLabel.implicitHeight
        width: leftLabel.implicitHeight
        StatusIndicator {
            id: indicator
            anchors.fill: parent
            active: (param.floatVal & bitMask)
            enabled: param.valid
        }
    }

    Label {
        id: rightLabel
        text: root.name
        font.bold: true
        enabled: param.valid
        visible: !indicatorRight
    }
    AutoRefreshOverlay {
        key: param.key
        visible: enableAutoRefreshOverlay
        enabled: enableAutoRefreshOverlay
    }
}


