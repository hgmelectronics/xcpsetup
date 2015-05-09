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

    function opResultStr(opr) {
        switch(opr) {
        case OpResult.Success:                   return "Success";
        case OpResult.NoIntfc:                   return "No interface";
        case OpResult.NotConnected:              return "Not connected";
        case OpResult.WrongMode:                 return "Wrong mode set";
        case OpResult.IntfcConfigError:          return "Interface configuration error";
        case OpResult.IntfcUnexpectedResponse:   return "Unexpected response from interface";
        case OpResult.IntfcNoResponse:           return "No response from interface";
        case OpResult.Timeout:                   return "Timeout";
        case OpResult.InvalidOperation:          return "Invalid operation attempted";
        case OpResult.BadReply:                  return "Bad XCP reply";
        case OpResult.PacketLost:                return "XCP packet lost";
        case OpResult.AddrGranError:             return "Address granularity violation";
        case OpResult.MultipleReplies:           return "Unexpected multiple replies";
        default:                                    return "Untranslated error"
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
                messageDialog.show("Download failed: " + opResultStr(result))
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
