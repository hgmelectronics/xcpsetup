import QtQuick 2.4
import QtQuick.Controls 1.3
import QtQuick.Window 2.2
import QtQuick.Dialogs 1.2
import QtQuick.Layouts 1.1
import com.hgmelectronics.utils.cs2tool 1.0
import com.setuptools 1.0

ApplicationWindow {
    title: qsTr("HGM Flash Tool")
    width: 400
    height: 300
    visible: true

    function opResultStr(opr) {
        switch(opr) {
        case XcpOpResult.Success:                   return "Success";
        case XcpOpResult.NoIntfc:                   return "No interface";
        case XcpOpResult.NotConnected:              return "Not connected";
        case XcpOpResult.WrongMode:                 return "Wrong mode set";
        case XcpOpResult.IntfcConfigError:          return "Interface configuration error";
        case XcpOpResult.IntfcIoError:              return "Interface I/O error";
        case XcpOpResult.IntfcUnexpectedResponse:   return "Unexpected response from interface";
        case XcpOpResult.IntfcNoResponse:           return "No response from interface";
        case XcpOpResult.Timeout:                   return "Timeout";
        case XcpOpResult.InvalidOperation:          return "Invalid operation attempted";
        case XcpOpResult.InvalidArgument:           return "Invalid argument passed";
        case XcpOpResult.BadReply:                  return "Bad XCP reply";
        case XcpOpResult.BadCksum:                  return "Bad checksum";
        case XcpOpResult.PacketLost:                return "XCP packet lost";
        case XcpOpResult.AddrGranError:             return "Address granularity violation";
        case XcpOpResult.MultipleReplies:           return "Unexpected multiple replies";
        case XcpOpResult.SlaveErrorBusy:            return "Slave error: busy";
        case XcpOpResult.SlaveErrorDaqActive:       return "Slave error: DAQ mode active";
        case XcpOpResult.SlaveErrorPgmActive:       return "Slave error: program sequence active";
        case XcpOpResult.SlaveErrorCmdUnknown:      return "Slave error: command unknown";
        case XcpOpResult.SlaveErrorCmdSyntax:       return "Slave error: command syntax invalid";
        case XcpOpResult.SlaveErrorOutOfRange:      return "Slave error: parameter out of range";
        case XcpOpResult.SlaveErrorWriteProtected:  return "Slave error: write protected";
        case XcpOpResult.SlaveErrorAccessDenied:    return "Slave error: access denied";
        case XcpOpResult.SlaveErrorAccessLocked:    return "Slave error: access locked";
        case XcpOpResult.SlaveErrorPageNotValid:    return "Slave error: page not valid";
        case XcpOpResult.SlaveErrorModeNotValid:    return "Slave error: page mode not valid";
        case XcpOpResult.SlaveErrorSegmentNotValid: return "Slave error: page segment not valid";
        case XcpOpResult.SlaveErrorSequence:        return "Slave error: sequence violation";
        case XcpOpResult.SlaveErrorDAQConfig:       return "Slave error: DAQ configuration invalid";
        case XcpOpResult.SlaveErrorMemoryOverflow:  return "Slave error: memory overflow";
        case XcpOpResult.SlaveErrorGeneric:         return "Slave error: generic";
        case XcpOpResult.SlaveErrorVerify:          return "Slave error: verification failed";
        case XcpOpResult.SlaveErrorUndefined:       return "Slave error: undefined error";
        default:                                    return "Untranslated error"
        }
    }

    menuBar: MenuBar {
        property alias fileMenu: fileMenu
        Menu {
            id: fileMenu
            title: qsTr("&File")
            MenuItem {
                text: qsTr("&Open")
                shortcut: StandardKey.Open
                onTriggered: mainForm.selectProg()
            }
            MenuSeparator { }
            MenuItem {
                text: qsTr("E&xit")
                shortcut: StandardKey.Quit
                onTriggered: Qt.quit()
            }
        }
        Menu {
            id: helpMenu
            title: qsTr("&Help")
            MenuItem {
                text: qsTr("&Contents")
                onTriggered: { helpDialog.show() }
                shortcut: StandardKey.HelpContents
            }
            MenuItem {
                text: qsTr("&About")
                onTriggered: { aboutDialog.show() }
            }
        }
    }

    MainForm {
        id: mainForm
        anchors.fill: parent
        toolReady: cs2Tool.programOk && cs2Tool.intfcOk
        toolReadyResetOnly: cs2Tool.intfcOk
        toolBusy: !cs2Tool.idle
        progBaseText: cs2Tool.programOk ? "0x00000000".substr(0, 10 - cs2Tool.programBase.toString(16).length) + cs2Tool.programBase.toString(16).toUpperCase() : ""
        progSizeText: cs2Tool.programOk ? cs2Tool.programSize.toString(10) : ""
        progCksumText: cs2Tool.programOk ? "0x00000000".substr(0, 10 - cs2Tool.programCksum.toString(16).length) + cs2Tool.programCksum.toString(16).toUpperCase() : ""
        progressValue: cs2Tool.progress
        onUserStart: cs2Tool.startProgramming()
        onUserReset: cs2Tool.startReset()
        targetCmdId: cs2Tool.slaveCmdId
        targetResId: cs2Tool.slaveResId
    }

    Cs2Tool {
        id: cs2Tool
        programFilePath: mainForm.progFilePath
        programFileType: mainForm.progFileType
        intfcUri: mainForm.intfcUri
        onProgrammingDone: {
            if(result === XcpOpResult.Success)
                messageDialog.show("Programming complete")
            else
                errorDialog.show("Programming failed: " + opResultStr(result))
        }
        onResetDone: {
            if(result === XcpOpResult.Success)
                messageDialog.show("Reset complete")
            else
                errorDialog.show("Reset failed: " + opResultStr(result))
        }
    }

    MessageDialog {
        id: errorDialog
        title: qsTr("Error")

        function show(caption) {
            errorDialog.text = caption;
            errorDialog.open();
        }
    }

    MessageDialog {
        id: messageDialog
        title: qsTr("Message")

        function show(caption) {
            messageDialog.text = caption;
            messageDialog.open();
        }
    }


    AboutDialog {
        id: aboutDialog
    }

    HelpDialog {
        id: helpDialog
    }
}
