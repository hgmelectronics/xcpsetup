pragma Singleton
import QtQuick 2.0
import QtQuick.Dialogs 1.2
import QtQuick.Controls 1.2
import QtQuick.Layouts 1.1

import com.hgmelectronics.setuptools 1.0

Dialog {
    property Action openAction: Action {
        text: qsTr("Set Auto-Refresh Interval")
        onTriggered: open()
    }

    title: "Auto-Refresh Interval"
    standardButtons: StandardButton.Ok | StandardButton.Cancel

    SpinBox {
        anchors.horizontalCenter: parent.horizontalCenter
        id: spinBox
        width: 150
        value: AutoRefreshManager.interval
        maximumValue: 1000000
        minimumValue: 0
        stepSize: 100
        suffix: qsTr(" msec")
        onEditingFinished: {
            AutoRefreshManager.interval = spinBox.value
        }
    }

    onAccepted: {
        close()
    }
    onRejected: {
        spinBox.value = Qt.binding(function() { return AutoRefreshManager.interval })
        close()
    }
}

