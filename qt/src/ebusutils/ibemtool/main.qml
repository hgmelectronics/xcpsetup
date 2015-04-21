import QtQuick 2.4
import QtQuick.Controls 1.3
import QtQuick.Window 2.2
import QtQuick.Dialogs 1.2
import QtQuick.Layouts 1.1
import com.ebus.utils.ibemtool 1.0
import com.setuptools 1.0

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
        toolReady: ibemTool.programOk && ibemTool.intfcOk
        toolBusy: !ibemTool.idle
        progBaseText: ibemTool.programOk ? "0x00000000".substr(0, 10 - ibemTool.programBase.toString(16).length) + ibemTool.programBase.toString(16).toUpperCase() : ""
        progSizeText: ibemTool.programOk ? ibemTool.programSize.toString(10) : ""
        progCksumText: ibemTool.programOk ? "0x00000000".substr(0, 10 - ibemTool.programCksum.toString(16).length) + ibemTool.programCksum.toString(16).toUpperCase() : ""
        progressValue: ibemTool.progress
        onUserStart: ibemTool.startProgramming()
        targetsModel: ibemTool.slaveListModel
        onUserAbort: ibemTool.abort()
        onUserPollForSlaves: ibemTool.pollForSlaves()
        //onIntfcUriChanged: ibemTool.intfcUri = intfcUri
    }

    IbemTool {
        id: ibemTool
        programFilePath: mainForm.progFilePath
        programFileType: mainForm.progFileType
        intfcUri: mainForm.intfcUri
        onProgrammingDone: {
            if(ok)
                messageDialog.show("Programming complete")
            else
                errorDialog.show("Programming failed")
        }
    }

    /*  mainForm:

        property alias progFileUrl: progFileDialog.fileUrl
        property alias targetsModel: targetsView.model
        property alias progBaseText: progBaseField.text
        property alias progSizeText: progSizeField.text
        property alias intfcUri: interfaceComboBox.selectedUri
        property bool intfcReady
        signal progFileAccepted()
        signal userStart()
        signal userAbort()
    */

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
                    text: "IBEMTool 1.0"
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
        title: "EjectorConsole help"
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
                    text:   "<h2>Setup Dialog</h2>
<p><b>Interface: </b>The Interface drop-down menu shows the usable serial ports detected on your system. If a port is already in use by another application, it will not appear in this list. The Start button will only be enabled when a valid interface is selected.</p>
<p><b>Sensor Type:</b> Select the voltage range produced by your pressure sensor. The most common is 0.5-4.5V ratiometric, but some sensors may produce 1-5 or 0-5 volt outputs.</p>
<p><b>Sensor Range: </b>Enter the pressure span of your sensor and select your preferred engineering units.</p>
<p><b>Distance Units: </b>Select your preferred engineering units for distance.</p>
<h2>Main Window</h2>
<h3>Process Data area</h3>
<p>Live data from the ejector controller. Pressures are shown in engineering units as specified on the Setup page. Positions are in half-steps of the stepper motor. The integrator value is in the internal fixed point representation used by the ejector controller.</p>
<h3>Parameters area</h3>
<p>Allows the ejector's control parameters to be set. The ejector controller does not have provisions for reading back its parameters, so you must enter appropriate values for all the parameters before writing. The entries shown at application startup are the factory settings for a 50kW class ejector.</p>
<h3>Status bar</h3>
<p>When connected, shows \"Data Received\" with a spinning line that rotates every time a new packet arrives. If no data is received for one second, it will change to \"Communication timed out\".
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

    //Component.onCompleted: ibemTool.intfcUri = mainForm.intfcUri
}
