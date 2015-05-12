import QtQuick 2.4
import QtQuick.Controls 1.3
import QtQuick.Layouts 1.1
import QtQuick.Dialogs 1.2
import com.setuptools.xcp 1.0

ColumnLayout {
    id: root

    spacing: 10
    anchors.fill: parent
    anchors.margins: 10

    property string progFilePath: progFileDialog.filePath
    property int progFileType: progFileDialog.fileType
    property alias progBaseText: progBaseField.text
    property alias progSizeText: progSizeField.text
    property alias progCksumText: progCksumField.text
    property string targetCmdId
    property string targetResId
    property string intfcUri: ""
    property alias progressValue: progressBar.value
    property bool toolReady
    property bool toolReadyResetOnly
    property bool toolBusy
    signal progFileAccepted()
    signal userStart()
    signal userReset()

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
            property int fileType: ProgFile.Invalid
            id: progFileDialog
            title: qsTr("Select program file")
            modality: Qt.NonModal
            nameFilters: [ "S-record files (*.srec)", "Foobar (*)" ]
            onAccepted: {
                filePath = UrlUtil.urlToLocalFile(fileUrl.toString())
                if(selectedNameFilter == "S-record files (*.srec)")
                    fileType = ProgFile.Srec;
                else
                    fileType = ProgFile.Invalid;
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

        RowLayout {
            id: intfcConfigRow
            anchors.left: parent.left
            anchors.right: parent.right
            spacing: 5
            ComboBox {
                id: intfcComboBox
                model: registry.avail
                textRole: "text"
                visible: true
                Layout.fillWidth: true

                property string selectedUri
                selectedUri: (count > 0 && currentIndex < count) ? model[currentIndex].uri : ""
            }

            ComboBox {
                property int bps
                id: bitrateComboBox
                editable: true
                implicitWidth: 80
                model: ListModel {
                    id: bitrateItems
                    ListElement { text: "125" }
                    ListElement { text: "250" }
                    ListElement { text: "500" }
                    ListElement { text: "1000" }
                }
                validator: DoubleValidator {
                    bottom: 10
                    top: 1000
                }
                onCurrentIndexChanged: {
                    if(currentIndex >= 0)
                        bps = parseFloat(bitrateItems.get(currentIndex).text) * 1000
                    console.log("onCurrentIndexChanged, bps=", bps);
                }
                onAccepted: {
                    bps = parseFloat(editText) * 1000
                    console.log("onAccepted, bps=", bps);
                }
                Component.onCompleted:  {
                    currentIndex = find("500")
                }
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
                id: intfcOpenButton
                text: qsTr("Open")
                onClicked: {
                    if(intfcComboBox.selectedUri !== "") {
                        root.intfcUri = intfcComboBox.selectedUri.replace(/bitrate=[0-9]*/, "bitrate=" + bitrateComboBox.bps.toString())
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
            text: "Target"
        }

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
            }
        }

        RowLayout {
            id: actionRow
            anchors.left: parent.left
            anchors.right: parent.right
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
                id: resetButton
                text: qsTr("Reset Target")
                onClicked: root.userReset()
                enabled: toolReadyResetOnly
            }
        }
    }

    ProgressBar {
        id: progressBar
        anchors.left: parent.left
        anchors.right: parent.right
    }
}
