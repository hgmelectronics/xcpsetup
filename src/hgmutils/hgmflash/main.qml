import QtQuick 2.4
import QtQuick.Controls 1.4
import QtQuick.Layouts 1.2
import QtQuick.Window 2.2
import QtQuick.Dialogs 1.2
import com.hgmelectronics.utils.cs2tool 1.0
import com.hgmelectronics.setuptools.xcp 1.0
import com.hgmelectronics.setuptools 1.0
import com.hgmelectronics.setuptools.ui 1.0
import com.hgmelectronics.utils 1.0

ApplicationWindow {
    id: application

    property string programName: qsTr("HGM Flash Tool")
    property string programVersion: ""

    property FlashProg progFileData

    property alias targetCmdId: cs2Tool.slaveCmdId
    property alias targetResId: cs2Tool.slaveResId
    property string intfcUri: ""

    title: programName
    visible: true

    Cs2Tool {
        id: cs2Tool
        programData: application.progFileData
        intfcUri: application.intfcUri
        onProgrammingDone: {
            if (result === OpResult.Success)
                messageDialog.show(qsTr("Programming complete"))
            else
                errorDialog.show(qsTr("Programming failed: %1").arg(
                                     OpResult.asString(result)))
        }
        onResetDone: {
            if (result === OpResult.Success)
                messageDialog.show(qsTr("Reset complete"))
            else
                errorDialog.show(qsTr("Reset failed: %1").arg(
                                     OpResult.asString(result)))
        }
        onFault: {
            logWindow.fault(info)
        }
        onWarn: {
            logWindow.warn(info)
        }
        onInfo: {
            logWindow.info(info)
        }
    }

    FileDialog {
        id: progFileDialog
        property string filePath

        title: qsTr("Select program file")
        modality: Qt.NonModal
        nameFilters: ["S-record files (*.srec)", "All files (*)"]
        folder: shortcuts.home
        onAccepted: {
            filePath = UrlUtil.urlToLocalFile(fileUrl.toString())
            if (selectedNameFilter == "S-record files (*.srec)")
                application.progFileData = ProgFile.readSrec(filePath)
            else
                application.progFileData = ProgFile.readSrec(
                            filePath) // default to S-record
        }
    }

    Action {
        id: openProgramAction
        text: qsTr("Open &Program")
        shortcut: StandardKey.Open
        onTriggered: progFileDialog.open()
    }

    Action {
        id: exitAction
        text: qsTr("E&xit")
        shortcut: StandardKey.Quit
        onTriggered: Qt.quit()
    }

    Action {
        id: helpContentsAction
        text: qsTr("&Contents")
        shortcut: StandardKey.HelpContents
        onTriggered: helpDialog.show()
    }

    Action {
        id: helpAboutAction
        text: qsTr("&About")
        onTriggered: aboutDialog.show()
    }

    Action {
        id: showLogAction
        text: qsTr("Show &Log")
        onTriggered: {
            logWindow.show()
        }
    }

    Action {
        id: intfcOpenAction
        text: qsTr("Open")
        enabled: !cs2Tool.intfcOk
        onTriggered: {
            if (interfaceChooser.uri !== "") {
                application.intfcUri = interfaceChooser.uri.replace(
                            /bitrate=[0-9]*/,
                            "bitrate=%1".arg(bitRateChooser.bps))
            }
        }
    }

    Action {
        id: intfcCloseAction
        text: qsTr("Close")
        onTriggered: {
            application.intfcUri = ""
        }
        enabled: cs2Tool.intfcOk && cs2Tool.idle
    }

    Action {
        id: progStartAction
        text: qsTr("Start")
        onTriggered: cs2Tool.startProgramming()
        enabled: cs2Tool.programOk && cs2Tool.intfcOk && cs2Tool.progReady
                 && cs2Tool.idle
    }

    Action {
        id: progResetAction
        text: qsTr("Reset Target")
        onTriggered: cs2Tool.startReset()
        enabled: cs2Tool.intfcOk && cs2Tool.progReady && cs2Tool.idle
    }

    menuBar: MenuBar {
        Menu {
            title: qsTr("&File")
            MenuItem {
                action: openProgramAction
            }
            MenuSeparator {
            }
            MenuItem {
                action: exitAction
            }
        }

        Menu {
            title: qsTr("&Edit")
            MenuItem {
                action: showLogAction
            }
        }
        Menu {
            title: qsTr("&Help")
            MenuItem {
                action: helpContentsAction
            }
            MenuItem {
                action: helpAboutAction
            }
        }
    }

    ColumnLayout {
        id: root
        anchors.fill: parent
        anchors.margins: 5
        spacing: 0

        InterfaceRegistry {
            id: registry
        }

        ColumnLayout {
            anchors.left: parent.left
            anchors.right: parent.right

            RowLayout {
                id: intfcConfigRow
                anchors.left: parent.left
                anchors.right: parent.right
                spacing: 5
                XcpInterfaceChooser {
                    id: interfaceChooser
                    Layout.fillWidth: true
                    enabled: !cs2Tool.intfcOk
                }
                BitRateChooser {
                    id: bitRateChooser
                    width: 100
                    enabled: !cs2Tool.intfcOk
                }

                Label {
                    text: qsTr("kbps")
                }
            }

            RowLayout {
                id: intfcActionRow
                anchors.left: parent.left
                anchors.right: parent.right
                Button {
                    Layout.alignment: Qt.AlignVCenter | Qt.AlignHCenter
                    Layout.fillWidth: true
                    action: intfcOpenAction
                }
                Button {
                    Layout.alignment: Qt.AlignVCenter | Qt.AlignHCenter
                    Layout.fillWidth: true
                    action: intfcCloseAction
                }
            }
        }
        GroupBox {
            title: qsTr("Target")
            anchors.left: parent.left
            anchors.right: parent.right
            ColumnLayout {
                anchors.fill: parent

                RowLayout {
                    id: targetConfigRow
                    anchors.left: parent.left
                    anchors.right: parent.right

                    Label {
                        text: qsTr("Command ID")
                    }
                    TextField {
                        id: targetCmdIdField
                        text: targetCmdId
                        validator: RegExpValidator {
                            regExp: /[0-9A-Fa-f]{1,8}/
                        }
                        onAccepted: {
                            targetCmdId = text
                            application.targetChanged()
                        }
                    }

                    Label {
                        text: qsTr("Response ID")
                    }
                    TextField {
                        id: targetResIdField
                        text: targetResId
                        validator: RegExpValidator {
                            regExp: /[0-9A-Fa-f]{1,8}/
                        }
                        onAccepted: {
                            targetResId = text
                            application.targetChanged()
                        }
                    }
                }
            }
        }
        GroupBox {
            title: qsTr("Program")
            anchors.left: parent.left
            anchors.right: parent.right
            ColumnLayout {
                anchors.fill: parent
                RowLayout {
                    id: progRow1
                    spacing: 10
                    anchors.left: parent.left
                    anchors.right: parent.right

                    TextField {
                        id: progFileNameField
                        text: progFileDialog.filePath
                        readOnly: true
                        anchors.left: parent.left
                        anchors.right: parent.right
                    }
                }

                RowLayout {
                    id: progRow2
                    spacing: 10
                    anchors.left: parent.left
                    anchors.right: parent.right

                    RowLayout {
                        spacing: 5

                        Label {
                            text: qsTr("Base")
                        }
                        TextField {
                            id: progBaseField
                            readOnly: true
                            implicitWidth: 90
                            text: cs2Tool.programData ? "0x00000000".substr(
                                                            0,
                                                            10 - cs2Tool.programBase.toString(
                                                                16).length)
                                                        + cs2Tool.programBase.toString(
                                                            16).toUpperCase(
                                                            ) : ""
                        }
                    }

                    RowLayout {
                        spacing: 5

                        Label {
                            text: qsTr("Size")
                        }
                        TextField {
                            id: progSizeField
                            readOnly: true
                            implicitWidth: 70
                            text: cs2Tool.programData ? cs2Tool.programSize.toString(
                                                            10) : ""
                        }
                    }

                    RowLayout {
                        spacing: 5

                        Label {
                            text: qsTr("CRC")
                        }
                        TextField {
                            id: progCksumField
                            readOnly: true
                            implicitWidth: 90
                            text: cs2Tool.programData ? "0x00000000".substr(
                                                            0,
                                                            10 - cs2Tool.programCksum.toString(
                                                                16).length)
                                                        + cs2Tool.programCksum.toString(
                                                            16).toUpperCase(
                                                            ) : ""
                        }
                    }
                }

                RowLayout {
                    id: progActionRow
                    anchors.left: parent.left
                    anchors.right: parent.right
                    Button {
                        Layout.alignment: Qt.AlignVCenter | Qt.AlignHCenter
                        Layout.fillWidth: true
                        action: progStartAction
                    }
                    Button {
                        Layout.alignment: Qt.AlignVCenter | Qt.AlignHCenter
                        Layout.fillWidth: true
                        action: progResetAction
                    }
                }
            }
        }
    }

    statusBar: StatusBar {
        RowLayout {
            anchors.fill: parent
            ProgressBar {
                id: progressBar
                Layout.fillHeight: true
                Layout.fillWidth: true
                value: cs2Tool.progress
            }
            ShowLogButton {
                window: logWindow
            }
        }
    }

    LogWindow {
        id: logWindow
    }

    MessageDialog {
        id: errorDialog
        title: qsTr("Error")
        icon: StandardIcon.Warning
        function show(caption) {
            errorDialog.text = caption
            errorDialog.open()
        }
    }

    MessageDialog {
        id: messageDialog
        title: qsTr("Message")
        icon: StandardIcon.Information
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
