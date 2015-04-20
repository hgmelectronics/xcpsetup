import QtQuick 2.4
import QtQuick.Controls 1.3
import QtQuick.Layouts 1.1
import QtQuick.Dialogs 1.2
import com.setuptools 1.0

ColumnLayout {
    id: root

    spacing: 10
    anchors.fill: parent
    anchors.margins: 10

    property string progFilePath: progFileDialog.filePath
    property int progFileType: progFileDialog.fileType
    property alias targetsModel: targetsView.model
    property alias progBaseText: progBaseField.text
    property alias progSizeText: progSizeField.text
    property alias intfcUri: interfaceComboBox.selectedUri
    property alias progressValue: progressBar.value
    property bool toolReady
    signal progFileAccepted()
    signal userStart()
    signal userAbort()

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
                filePath = decodeURIComponent(fileUrl.toString().replace(/^(file:\/{2})/, ""))
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
                spacing: 10

                Label {
                    text: qsTr("Base address")
                }
                TextField {
                    id: progBaseField
                    readOnly: true
                    implicitWidth: 100
                }
            }

            RowLayout {
                spacing: 10

                Label {
                    text: qsTr("Bytes")
                }
                TextField {
                    id: progSizeField
                    readOnly: true
                    implicitWidth: 100
                }
            }
        }
    }

    ColumnLayout {
        anchors.left: parent.left
        anchors.right: parent.right
        spacing: 5

        XcpInterfaceRegistry {
            id: registry
        }

        Label {
            font.pixelSize: 14
            text: "Interface"
        }

        RowLayout {
            id: intfcRow
            anchors.left: parent.left
            anchors.right: parent.right

            spacing: 20

            ComboBox {
                id: interfaceComboBox
                model: registry.avail
                textRole: "text"
                visible: true
                anchors.left: parent.left
                anchors.right: parent.right

                property string selectedUri
                selectedUri: (currentIndex < count) ? model[currentIndex].uri : ""
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
            enabled: toolReady
        }
    }

    ProgressBar {
        id: progressBar
        anchors.left: parent.left
        anchors.right: parent.right
    }
}
