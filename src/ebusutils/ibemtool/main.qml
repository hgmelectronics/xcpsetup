import QtQuick 2.4
import QtQuick.Controls 1.3
import QtQuick.Window 2.2
import QtQuick.Dialogs 1.2
import QtQuick.Layouts 1.1
import com.ebus.utils.ibemtool 1.0
import com.hgmelectronics.setuptools.xcp 1.0
import com.hgmelectronics.setuptools 1.0
import com.hgmelectronics.setuptools.ui 1.0

ApplicationWindow {
    title: qsTr("IBEM Flash Tool")
    width: 400
    height: 600
    visible: true


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
        intfcOpen: ibemTool.intfcOk
        toolReady: ibemTool.programOk && ibemTool.intfcOk
        toolBusy: !ibemTool.idle
        progBaseText: ibemTool.programData ? "0x00000000".substr(0, 10 - ibemTool.programBase.toString(16).length) + ibemTool.programBase.toString(16).toUpperCase() : ""
        progSizeText: ibemTool.programData ? ibemTool.programSize.toString(10) : ""
        progCksumText: ibemTool.programData ? "0x00000000".substr(0, 10 - ibemTool.programCksum.toString(16).length) + ibemTool.programCksum.toString(16).toUpperCase() : ""
        progressValue: ibemTool.progress
        onUserStart: ibemTool.startProgramming()
        targetsModel: ibemTool.slaveListModel
        onUserAbort: ibemTool.abort()
        onUserPollForSlaves: ibemTool.pollForSlaves()
        //onIntfcUriChanged: ibemTool.intfcUri = intfcUri
    }

    IbemTool {
        id: ibemTool
        programData: mainForm.progFileData
        intfcUri: mainForm.intfcUri
        onProgrammingDone: {
            if(ok)
                messageDialog.show(qsTr("Programming complete"))
            else
                errorDialog.show(qsTr("Programming failed"))
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
        title: "About IBEMTool"
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
                    text: "IBEMTool 1.3"
                }
                Label {
                    text: "Copyright \u00A9 2015 Ebus Inc."
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
        title: "IBEMTool help"
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
<p>Use the Open command in the File menu to select an S-record program file to load on the target boards. Once it is successfully loaded, the fields in the Program area will show information about the file.</p>
<h2>Interface</h2>
<p>Select an interface from the drop-down menu. If you have built-in serial ports on your system, you will see an entry for each one, even though only one corresponds to the ELM327 compatible interface. You can try each port in turn, or look at your system's Device Manager or equivalent to find which port to use. If you do not see the port you are looking for, try closing and reopening the program.</p>
<p>Once you have selected an interface, click the Open button. This will automatically scan for targets on the vehicle's network. You only need to use the Close button if you wish to switch to another interface; it is safe to simply quit the program when you are done.</p>
<h2>Targets</h2>
<p>Targets detected on the network appear in the list area. If you wish to repeat the process of scanning for targets, use the Re-Poll button.</p>
<p>To flash only one board, select it by clicking on its ID number. To select multiple boards, hold down the Control key while clicking, or click on the first board you wish to flash and then hold down the Shift key while clicking on the last board you wish to flash to select the entire range.</p>
<p>Once you have selected the boards you wish to flash, click the Start button. The progress bar at the bottom of the window will show how many of the boards have been completed; in addition, each board will be deselected as it is completed. The Abort button will deselect all boards and stop the reflash process after the board presently being reflashed is complete. A dialog box will appear when the process is done. If you see an error message, please contact Ebus for further instructions.</p>
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
