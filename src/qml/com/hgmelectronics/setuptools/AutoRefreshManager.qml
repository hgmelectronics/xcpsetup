pragma Singleton
import QtQuick 2.0
import QtQuick.Controls 1.4
import com.hgmelectronics.setuptools 1.0
import com.hgmelectronics.setuptools.xcp 1.0

Item {
    id: root
    property ParamLayer paramLayer
    property alias running: refreshTimer.running
    property int interval: 1000
    property Action runningAction: Action {
        text: qsTr("Enable Auto-Refresh")
        checkable: true
        onToggled: running = checked
    }

    property bool inProgress: false
    property bool deferredTrigger: false

    Timer {
        id: refreshTimer
        triggeredOnStart: true
        repeat: true
        interval: Math.max(root.interval, 16)
        onTriggered: {
            if(!paramLayer.slaveConnected) {
                inProgress = false
                deferredTrigger = false
            }
            else if(inProgress) {
                deferredTrigger = true
            }
            else {
                if(paramLayer.idle && AutoRefreshSelector.keys.length > 0) {
                    paramLayer.upload(AutoRefreshSelector.keys)
                    inProgress = true
                }
                deferredTrigger = false
            }
        }
    }

    Connections {
        target: paramLayer

        onUploadDone: {
            inProgress = false

            if(!paramLayer.slaveConnected)
                deferredTrigger = false

            if(deferredTrigger) {
                deferredTrigger = false
                if(paramLayer.slaveConnected && paramLayer.idle && AutoRefreshSelector.keys.length > 0)
                    paramLayer.upload(AutoRefreshSelector.keys)
            }
        }
    }

    Component.onCompleted: interval = refreshTimer.interval
}

