import QtQuick 2.4
import QtQuick.Controls 1.3
import QtQuick.Layouts 1.1
import QtQuick.Dialogs 1.2
import com.hgmelectronics.setuptools.xcp 1.0
import com.hgmelectronics.setuptools 1.0
import com.hgmelectronics.setuptools.ui 1.0

ColumnLayout {
    id: root

    spacing: 10
    anchors.fill: parent
    anchors.margins: 10

    property string progFilePath: progFileDialog.filePath
    property FlashProg progFileData
    property alias targetsModel: targetsView.model
    property alias progBaseText: progBaseField.text
    property alias progSizeText: progSizeField.text
    property alias progCksumText: progCksumField.text
    property string intfcUri: ""
    property alias progressValue: progressBar.value
    property bool toolReady
    property bool toolBusy
    signal progFileAccepted()
    signal userStart()
    signal userAbort()
    signal userPollForSlaves()

    function selectProg() { progFileDialog.open() }

    ColumnLayout {
        anchors.left: parent.left
        anchors.right: parent.right
        spacing: 5
        Label {
            font.pixelSize: 14
            text: "Program"
        }

        FileDialog {
            property string filePath
            id: progFileDialog
            title: qsTr("Select program file")
            modality: Qt.NonModal
            nameFilters: [ "S-record files (*.srec)", "All files (*)" ]
            onAccepted: {
                filePath = UrlUtil.urlToLocalFile(fileUrl.toString())
                if(selectedNameFilter == "S-record files (*.srec)")
                    root.progFileData = ProgFile.readSrec(filePath)
                else
                    root.progFileData = ProgFile.readSrec(filePath) // default to S-record
                root.progFileAccepted()
            }
        }

        RowLayout {
            id: progRow1
            spacing: 10
            anchors.left: parent.left
            anchors.right: parent.right

            TextField {
                id: progFileNameField
                text: progFilePath
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
                }
            }
        }
    }

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
                enabled: !ibemTool.intfcOk
            }
            BitRateChooser {
                id: bitRateChooser
                width: 100
                enabled: !ibemTool.intfcOk
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

    ColumnLayout {
        anchors.left: parent.left
        anchors.right: parent.right
        spacing: 5

        Label {
            font.pixelSize: 14
            text: "Targets"
        }

        Button {
            id: pollForSlavesButton
            onClicked: root.userPollForSlaves()
            text: qsTr("Re-Poll")
        }

        MultiselectListView {
            id: targetsView
            anchors.left: parent.left
            anchors.right: parent.right
            rowHeight: 20
            height: rowHeight * 12.5
        }
    }


    GridLayout {
        id: actionRow
        anchors.left: parent.left
        anchors.right: parent.right
        columns: 2
        Button {
            Layout.alignment: Qt.AlignVCenter | Qt.AlignHCenter
            Layout.fillWidth: true
            id: startButton
            text: qsTr("Start")
            onClicked: root.userStart()
            enabled: toolReady
        }
        Button {
            Layout.alignment: Qt.AlignVCenter | Qt.AlignHCenter
            Layout.fillWidth: true
            id: abortButton
            text: qsTr("Abort")
            onClicked: root.userAbort()
            enabled: toolBusy
        }
    }

    ProgressBar {
        id: progressBar
        anchors.left: parent.left
        anchors.right: parent.right
    }

    Action {
        id: intfcOpenAction
        text: qsTr("Open")
        enabled: !ibemTool.intfcOk
        onTriggered: {
            if (interfaceChooser.uri !== "") {
                root.intfcUri = interfaceChooser.uri.replace(
                            /bitrate=[0-9]*/,
                            "bitrate=%1".arg(bitRateChooser.bps))
            }
        }
    }

    Action {
        id: intfcCloseAction
        text: qsTr("Close")
        onTriggered: {
            root.intfcUri = ""
        }
        enabled: ibemTool.intfcOk && ibemTool.idle
    }
}
