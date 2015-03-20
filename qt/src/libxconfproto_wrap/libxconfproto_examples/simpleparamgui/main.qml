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

    function opResultStr(opr) {
        switch(opr) {
        case XcpOpResult.Success:                   return "Success";
        case XcpOpResult.NoIntfc:                   return "No interface";
        case XcpOpResult.NotConnected:              return "Not connected";
        case XcpOpResult.WrongMode:                 return "Wrong mode set";
        case XcpOpResult.IntfcConfigError:          return "Interface configuration error";
        case XcpOpResult.IntfcUnexpectedResponse:   return "Unexpected response from interface";
        case XcpOpResult.IntfcNoResponse:           return "No response from interface";
        case XcpOpResult.Timeout:                   return "Timeout";
        case XcpOpResult.InvalidOperation:          return "Invalid operation attempted";
        case XcpOpResult.BadReply:                  return "Bad XCP reply";
        case XcpOpResult.PacketLost:                return "XCP packet lost";
        case XcpOpResult.AddrGranError:             return "Address granularity violation";
        case XcpOpResult.MultipleReplies:           return "Unexpected multiple replies";
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

    XcpSimpleDataLayer {
        id: dataLayer
        onUploadUint32Done: {
            if(result === XcpOpResult.Success)
                mainForm.dataField.text = data.toString()
            else
                mainForm.dataField.text = "Error"
        }
        onDownloadUint32Done: {
            if(result !== XcpOpResult.Success) {
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
