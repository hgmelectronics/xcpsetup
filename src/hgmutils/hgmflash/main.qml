import QtQuick 2.4
import QtQuick.Controls 1.4
import QtQuick.Layouts 1.2
import QtQuick.Window 2.2
import QtQuick.Dialogs 1.2
import com.hgmelectronics.utils.cs2tool 1.0
import com.hgmelectronics.setuptools.xcp 1.0
import com.hgmelectronics.setuptools 1.0
import com.hgmelectronics.utils 1.0


ApplicationWindow {
    id: application

    readonly property string programName: qsTr("HGM Flash Tool")
    readonly property string programVersion: "1.1"

    title: programName
    width: 400
    height: 300
    visible: true

    menuBar: MenuBar {
        property alias fileMenu: fileMenu
        Menu {
            id: fileMenu
            title: qsTr("&File")
            MenuItem {
                text: qsTr("Open &Program")
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
                shortcut: StandardKey.HelpContents
                onTriggered: helpDialog.show()             }
            MenuItem {
                text: qsTr("&About")
                onTriggered: { aboutDialog.show() }
            }
        }
    }

    MainForm {
        id: mainForm
        anchors.fill: parent
        toolReadyProg: cs2Tool.programOk && cs2Tool.intfcOk && cs2Tool.progReady
        toolReadyReset: cs2Tool.intfcOk && cs2Tool.progReady
        toolBusy: !cs2Tool.idle
        progBaseText: cs2Tool.programData ? "0x00000000".substr(0, 10 - cs2Tool.programBase.toString(16).length) + cs2Tool.programBase.toString(16).toUpperCase() : ""
        progSizeText: cs2Tool.programData ? cs2Tool.programSize.toString(10) : ""
        progCksumText: cs2Tool.programData ? "0x00000000".substr(0, 10 - cs2Tool.programCksum.toString(16).length) + cs2Tool.programCksum.toString(16).toUpperCase() : ""
        progressValue: cs2Tool.progress
        onUserStartProg: cs2Tool.startProgramming()
        onUserResetProg: cs2Tool.startReset()
        targetCmdId: cs2Tool.slaveCmdId
        targetResId: cs2Tool.slaveResId

        onTargetChanged: {
            cs2Tool.slaveCmdId = targetCmdId
            cs2Tool.slaveResId = targetResId
        }
    }

    Cs2Tool {
        id: cs2Tool
        programData: mainForm.progFileData
        intfcUri: mainForm.intfcUri
        onProgrammingDone: {
            if(result === OpResult.Success)
                messageDialog.show(qsTr("Programming complete"))
            else
                errorDialog.show(qsTr("Programming failed: %1").arg(OpResult.asString(result)))
        }
        onResetDone: {
            if(result === OpResult.Success)
                messageDialog.show(qsTr("Reset complete"))
            else
                errorDialog.show(qsTr("Reset failed: %1").arg(OpResult.asString(result)))
        }
    }

    MessageDialog {
        id: errorDialog
        title: qsTr("Error")

        function show(caption) {
            errorDialog.text = caption
            errorDialog.open()
        }
    }

    MessageDialog {
        id: messageDialog
        title: qsTr("Message")

        function show(caption) {
            messageDialog.text = caption
            messageDialog.open()
        }
    }

    AboutDialog {
        id: aboutDialog
        programName: application.programName
        programVersion: application.programVersion
    }

    HelpDialog {
        id: helpDialog
    }

    Splash {
    }

}
