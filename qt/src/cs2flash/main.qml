import QtQuick 2.4
import QtQuick.Controls 1.3
import QtQuick.Window 2.2
import QtQuick.Dialogs 1.2
import QtQuick.Layouts 1.1
import com.hgmelectronics.utils.cs2tool 1.0
import com.setuptools.xcp 1.0

ApplicationWindow {
    title: qsTr("HGM Flash Tool")
    width: 400
    height: 300
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
            if(result === OpResult.Success)
                messageDialog.show("Programming complete")
            else
                errorDialog.show("Programming failed: " + OpResult.asString(result))
        }
        onResetDone: {
            if(result === OpResult.Success)
                messageDialog.show("Reset complete")
            else
                errorDialog.show("Reset failed: " + OpResult.asString(result))
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
