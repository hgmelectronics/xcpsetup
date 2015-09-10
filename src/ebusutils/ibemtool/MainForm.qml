import QtQuick 2.4
import QtQuick.Controls 1.3
import QtQuick.Layouts 1.1
import QtQuick.Dialogs 1.2
import com.hgmelectronics.setuptools.xcp 1.0
import com.hgmelectronics.setuptools 1.0

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

    ColumnLayout {
        anchors.left: parent.left
        anchors.right: parent.right
        spacing: 5

        InterfaceRegistry {
            id: registry
        }

        Label {
            font.pixelSize: 14
            text: "Interface"
        }

        ComboBox {
            id: intfcComboBox
            model: registry.avail
            textRole: "text"
            visible: true
            anchors.left: parent.left
            anchors.right: parent.right

            property string selectedUri
            selectedUri: (count > 0 && currentIndex < count) ? model[currentIndex].uri : ""
        }

        RowLayout {
            id: intfcActionRow
            anchors.left: parent.left
            anchors.right: parent.right
            Button {
                Layout.alignment: Qt.AlignVCenter | Qt.AlignHCenter
                Layout.fillWidth: true
                id: intfcOpenButton
                text: qsTr("Open")
                onClicked: {
                    if(intfcComboBox.selectedUri !== "") {
                        root.intfcUri = intfcComboBox.selectedUri
                        intfcOpenButton.enabled = false
                    }
                }
            }
            Button {
                Layout.alignment: Qt.AlignVCenter | Qt.AlignHCenter
                Layout.fillWidth: true
                id: intfcCloseButton
                text: qsTr("Close")
                onClicked: {
                    root.intfcUri = ""
                    intfcOpenButton.enabled = true
                }
                enabled: !toolBusy && !intfcOpenButton.enabled
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
}
