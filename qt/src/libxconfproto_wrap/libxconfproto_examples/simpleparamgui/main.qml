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
        anchors.fill: parent
        openButton.onClicked: {
            if(interfaceComboBox.currentIndex >= interfaceComboBox.count) {
                messageDialog.show("No interface selected!")
                return;
            }

            if(dataLayer.intfcUri !== interfaceComboBox.model[interfaceComboBox.currentIndex].uri) {
                dataLayer.intfcUri = interfaceComboBox.model[interfaceComboBox.currentIndex].uri
            }
            dataLayer.slaveId = slaveIdField.text
            openButton.enabled = false
        }
        closeButton.onClicked: {
            dataLayer.slaveId = ""
            openButton.enabled = true
        }
        readButton.onClicked: {
            dataLayer.uploadUint32(parseInt(addressField.text))
            dataField.text = dataLayer.uploadUint32(parseInt(addressField.text)).toString()
        }
        writeButton.onClicked: {
            dataLayer.downloadUint32(parseInt(addressField.text), parseInt(dataField.text))
        }
        Connections {
            target: dataLayer
            onUploadUint32Done: {
                if(result === XcpOpResult.Success)
                    dataField.text = data.toString()
                else
                    dataField.text = "Error"
            }
            onDownloadUint32Done: {
                if(result !== XcpOpResult.Success)
                    messageDialog.show("Download failed")
            }
        }
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
