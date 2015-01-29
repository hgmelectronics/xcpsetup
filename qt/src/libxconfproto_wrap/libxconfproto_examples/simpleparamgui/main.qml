import QtQuick 2.4
import QtQuick.Controls 1.3
import QtQuick.Window 2.2
import QtQuick.Dialogs 1.2
import com.setuptools 1.0

ApplicationWindow {
    title: qsTr("XCP Connection Test Application")
    width: 640
    height: 480
    visible: true

    menuBar: MenuBar {
        Menu {
            title: qsTr("&File")
            MenuItem {
                text: qsTr("E&xit")
                onTriggered: Qt.quit();
            }
        }
    }

    MainForm {
        property XcpInterface intfc
        property int intfcInfoIdx
        intfcInfoIdx: -1
        anchors.fill: parent
        openButton.onClicked: {
            if(interfaceComboBox.currentIndex >= interfaceComboBox.count) {
                messageDialog.show("No interface selected!")
                return;
            }

            if(intfcInfoIdx != interfaceComboBox.currentIndex) {
                intfcInfoIdx = interfaceComboBox.currentIndex
                intfc = XcpCanInterfaceRegistry.avail[intfcInfoIdx].make()
            }
            xcpConnection.intfc = intfc
            openButton.enabled = false

            xcpConnection.open()
            dataLayer.conn = xcpConnection
        }
        closeButton.onClicked: {
            xcpConnection.close()
            openButton.enabled = true
        }
        readButton.onClicked: {
            dataField.text = dataLayer.uploadUint32(parseInt(addressField.text)).toString()
        }
        writeButton.onClicked: {
            dataLayer.downloadUint32(parseInt(addressField.text), parseInt(dataField.text))
        }
    }

    XcpConnection {
        id: xcpConnection
    }

    XcpSimpleDataLayer {
        id: dataLayer
    }

    MessageDialog {
        id: messageDialog
        title: qsTr("May I have your attention, please?")

        function show(caption) {
            messageDialog.text = caption;
            messageDialog.open();
        }
    }
}
