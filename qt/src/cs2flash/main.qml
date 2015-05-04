import QtQuick 2.4
import QtQuick.Controls 1.3
import QtQuick.Window 2.2
import QtQuick.Dialogs 1.2
import QtQuick.Layouts 1.1
import com.hgmelectronics.utils.cs2tool 1.0
import com.setuptools 1.0

ApplicationWindow {
    title: qsTr("CS2 Flash Tool")
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
                onTriggered: { helpDialog.visible = true }
                shortcut: StandardKey.HelpContents
            }
            MenuItem {
                text: qsTr("&About")
                onTriggered: { aboutDialog.visible = true }
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

    Window {
        id: aboutDialog
        title: "About CS2Flash"
        width: col.implicitWidth + 20
        height: col.implicitHeight + 20
        maximumWidth: col.implicitWidth + 20
        maximumHeight: col.implicitHeight + 20
        minimumWidth: col.implicitWidth + 20
        minimumHeight: col.implicitHeight + 20
        Rectangle {
            anchors.fill: parent
            ColumnLayout {
                id: col
                anchors.fill: parent
                anchors.margins: 10
                spacing: 5
                Label {
                    font.pixelSize: 18
                    text: "CS2Flash 1.0"
                }
                Label {
                    text: "Copyright \u00A9 2015 HGM Automotive Electronics Inc."
                }
                Label {
                    textFormat: Text.RichText
                    text:   "This program is free software: you can redistribute it and/or modify<br>" +
                            "it under the terms of the GNU General Public License as published by<br>"+
                            "the Free Software Foundation, either version 3 of the License, or<br>" +
                            "(at your option) any later version.<br>" +
                            "<br>" +
                            "This program is distributed in the hope that it will be useful, <br>" +
                            "but WITHOUT ANY WARRANTY; without even the implied warranty of <br>" +
                            "MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the <br>" +
                            "GNU General Public License for more details.<br>" +
                            "<br>" +
                            "You should have received a copy of the GNU General Public License <br>" +
                            "along with this program.  If not, see <a href=\"http://www.gnu.org/licenses/\">http://www.gnu.org/licenses/</a>."
                }
                Button {
                    anchors.right: parent.right
                    text: "Close"
                    isDefault: true
                    onClicked: { aboutDialog.visible = false }
                }
            }
        }
    }

    Window {
        id: helpDialog
        title: "CS2Flash help"
            width: helpCol.implicitWidth + 20
            height: helpCol.implicitHeight + 20
            Column {
                id: helpCol
                anchors.fill: parent
                anchors.margins: 10
                spacing: 5
                Label {
                    width: 500
                    wrapMode: Text.WordWrap
                    text:   "<h2>Program</h2>
<p>Use the Open command in the File menu to select an S-record program file to load on the target CS2. Once it is successfully loaded, the fields in the Program area will show information about the file.</p>
<h2>Interface</h2>
<p>Select an interface from the drop-down menu. If you have built-in serial ports on your system, you will see an entry for each one, even though only one corresponds to the ELM327 compatible interface. You can try each port in turn, or look at your system's Device Manager or equivalent to find which port to use. If you do not see the port you are looking for, try closing and reopening the program.</p>
<p>Note: the FTDI USB to serial adapter chips in many ELM327 compatible interfaces have a timing delay that can greatly slow programming on Windows machines. There is a setting that can be changed to fix this problem; this only has to be done once for each unique ELM327 adapter you use with your computer. To do so, follow these steps:</p>
<ol><li>Open <i>Device Manager</i> from the Control Panel.</li>
    <li>Click on the <i>Ports (COM and LPT)</i> section label to expand it.</li>
    <li>Locate the entry for the USB serial port corresponding to your ELM327 adapter.</li>
    <li>Double-click on the entry to open the <i>Properties</i> dialog.</li>
    <li>Select the <i>Port Settings</i> tab.</li>
    <li>Click on the <i>Advanced...</i> button.</li>
    <li>Find the section labeled <i>Latency Timer (msec)</i>, and click on the drop-down menu.</li>
    <li>Change the value from 16 (the default) to 1.</li>
    <li>Click OK to save the change.</li>
    <li>Close the <i>Properties</i> window and the <i>Device Manager</i> window.</li>
</ol>
<p>Once you have selected an interface, click the Open button. You only need to use the Close button if you wish to switch to another interface; it is safe to simply quit the program when you are done.</p>
<p>To begin programming, click the Start button. A dialog box will appear when the process is done. If you see an error message, please contact HGM for further instructions.</p>
"
                }
                Button {
                    anchors.right: parent.right
                    text: "Close"
                    isDefault: true
                    onClicked: { helpDialog.visible = false }
                }
            }
    }
}
