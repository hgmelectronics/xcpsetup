import QtQuick 2.5
import QtQuick.Controls 1.4
import QtQuick.Layouts 1.1
import com.hgmelectronics.setuptools.xcp 1.0

GroupBox {
    id: root
    title: qsTr("Bluetooth Devices")
    property string addr
    property string saveAddr    // Address/UUID saved by QSettings.
    property alias saveList: deviceModel.saveList

    property Action startDiscovery: Action {
        text: qsTr("Search")
        tooltip: qsTr("Start searching for Bluetooth LE devices")
        onTriggered: deviceModel.start()
    }

    property Action stopDiscovery: Action {
        text: qsTr("Stop")
        tooltip: qsTr("Stop searching for Bluetooth LE devices")
        onTriggered: deviceModel.stop()
        enabled: deviceModel.isActive
    }

    XcpBleDeviceModel {
        id: deviceModel
    }

    RowLayout {
        anchors.fill: parent
        ComboBox {
            id: comboBox

            Layout.fillWidth: true

            model: deviceModel
            textRole: "display"
            visible: true

            onCurrentIndexChanged: addr = deviceModel.addr(comboBox.currentIndex)

            Connections {
                target: deviceModel
                onDataChanged: {
                    setIndexFromAddr(saveAddr)
                    addr = deviceModel.addr(comboBox.currentIndex)
                }
            }
        }

        BusyIndicator {
            running: deviceModel.isActive
            height: 20
            width: 20
            implicitHeight: 20
            implicitWidth: 20
        }

        Button {
            action: startDiscovery
            enabled: !deviceModel.isActive
        }

        Button {
            action: stopDiscovery
            enabled: deviceModel.isActive
        }
    }



    function setIndexFromAddr(newAddr) {
        var newAddrIndex = deviceModel.find(newAddr)
        if(newAddrIndex >= 0) { // saveAddr exists in model
            comboBox.currentIndex = newAddrIndex    // set it as the current index, this will also update Addr
        }
        else {
            if(deviceModel.rowCount()) {    // does not exist - if there is anything in the model use that instead
                comboBox.currentIndex = 0
            }
            else {
                comboBox.currentIndex = -1
            }
        }
    }

    onSaveAddrChanged: {
        setIndexFromAddr(saveAddr)
    }

    Component.onCompleted: {
        setIndexFromAddr(saveAddr)
    }
}
