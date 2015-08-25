import QtQuick 2.4
import QtQuick.Controls 1.3
import QtQuick.Window 2.2
import QtQuick.Dialogs 1.2
import com.setuptools.xcp 1.0

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
        id: mainForm
        anchors.fill: parent
        openButton.onClicked: {
            if(interfaceComboBox.currentIndex >= interfaceComboBox.count) {
                messageDialog.show("No interface selected!")
                return;
            }

            if(dataLayer.intfcUri !== interfaceComboBox.model[interfaceComboBox.currentIndex].uri) {
                dataLayer.intfcUri = interfaceComboBox.model[interfaceComboBox.currentIndex].uri
            }
            dataLayer.intfcUri = dataLayer.intfcUri.replace(/bitrate=[0-9]*/, "bitrate=500000")
            dataLayer.slaveId = slaveIdField.text
            openButton.enabled = false
        }
        closeButton.onClicked: {
            dataLayer.slaveId = ""
            openButton.enabled = true
        }
        readButton.onClicked: {
            dataLayer.uploadUint32(parseInt(addressField.text))
        }
        writeButton.onClicked: {
            dataLayer.downloadUint32(parseInt(addressField.text), parseInt(dataField.text))
        }
    }

    SimpleDataLayer {
        id: dataLayer
        onUploadUint32Done: {
            if(result === OpResult.Success)
                mainForm.dataField.text = data.toString()
            else
                mainForm.dataField.text = opResultStr(result)
        }
        onDownloadUint32Done: {
            if(result !== OpResult.Success) {
                messageDialog.show("Download failed: " + OpResult.asString(result))
            }
        }
    }

    MessageDialog {
        id: messageDialog
        title: qsTr("Bad human!")

        function show(caption) {
            messageDialog.text = caption;
            messageDialog.open();
        }
    }
}
