import QtQuick 2.4
import QtQuick.Controls 1.4
import QtQuick.Layouts 1.2
import QtQuick.Window 2.2
import QtQuick.Dialogs 1.2
import com.hgmelectronics.setuptools.xcp 1.0
import com.hgmelectronics.setuptools 1.0

ApplicationWindow {
    id: app
    title: paramFileIo.name.length === 0 ? programName : paramFileIo.name + " - " + programName
    width: 800
    height: 500
    visible: true

    property string programName: qsTr("CS2 Parameter Editor")
    property string targetCmdId: "18FCD403"
    property string targetResId: "18FCD4F9"

    signal connect

    onConnect: {
        paramLayer.slaveId = targetCmdId + ":" + targetResId
        paramLayer.connectSlave()
    }

    ParamLayer {
        id: paramLayer
        addrGran: 4
        slaveTimeout: 100
        slaveNvWriteTimeout: 200
        onConnectSlaveDone: forceSlaveSupportCalPage()
    }

    ParamFile {
        id: paramFileIo
        type: ParamFile.Json
        onOpComplete: {
            if (result !== ParamFile.Ok)
                errorDialog.show(resultString)
        }
    }

    menuBar: MenuBar {
        property alias fileMenu: fileMenu
        Menu {
            id: fileMenu
            title: qsTr("&File")
            MenuItem {
                text: qsTr("&Open Parameter File")
                shortcut: StandardKey.Open
                onTriggered: {
                    if (paramLayer.writeCacheDirty)
                        paramOverwriteDialog.show()
                    else
                        paramLoadFileDialog.open()
                }
            }
            MenuItem {
                text: qsTr("&Save Parameter File")
                shortcut: StandardKey.Save
                onTriggered: {
                    if (paramFileIo.exists)
                        paramFileIo.write(paramLayer.saveableData())
                    else
                        paramSaveFileDialog.open()
                }
            }
            MenuItem {
                text: qsTr("Save Parameter File &As")
                onTriggered: {
                    paramSaveFileDialog.open()
                }
            }
            MenuSeparator {
            }
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
                onTriggered: {
                    helpDialog.show()
                }
                shortcut: StandardKey.HelpContents
            }
            MenuItem {
                text: qsTr("&About")
                onTriggered: {
                    aboutDialog.show()
                }
            }
        }
    }

    toolBar: ColumnLayout {
        anchors.fill: parent
        InterfaceRegistry {
            id: registry
        }

        RowLayout {
            Layout.topMargin: 5
            anchors.left: parent.left
            anchors.right: parent.right
            spacing: 0
            GroupBox {
                Layout.fillWidth: true
                title: qsTr("Interface")
                ComboBox {
                    id: intfcComboBox
                    anchors.fill: parent
                    model: registry.avail
                    textRole: "text"
                    visible: true
                    property string selectedUri
                    selectedUri: (count > 0
                                  && currentIndex < count) ? model[currentIndex].uri : ""
                }
            }

            GroupBox {
                Layout.fillWidth: true
                title: "Speed (kbps)"
                ComboBox {
                    id: bitrateComboBox
                    property int bps
                    anchors.fill: parent
                    editable: true
                    implicitWidth: 80
                    model: ListModel {
                        id: bitrateItems
                        ListElement {
                            text: "125"
                            bps: 125000
                        }
                        ListElement {
                            text: "250"
                            bps: 250000
                        }
                        ListElement {
                            text: "500"
                            bps: 500000
                        }
                        ListElement {
                            text: "1000"
                            bps: 1000000
                        }
                    }
                    validator: DoubleValidator {
                        bottom: 10
                        top: 1000
                    }
                    onCurrentIndexChanged: {
                        if (currentIndex >= 0)
                            bps = bitrateItems.get(currentIndex).bps
                        console.log("onCurrentIndexChanged, bps=", bps)
                    }
                    onAccepted: {
                        bps = parseFloat(editText) * 1000
                        console.log("onAccepted, bps=", bps)
                    }
                    Component.onCompleted: {
                        currentIndex = find("500")
                    }
                }
            }

            GroupBox {
                Layout.fillWidth: true
                title: qsTr("Target Command ID")
                TextField {
                    id: targetCmdIdField
                    anchors.fill: parent
                    horizontalAlignment: TextInput.AlignRight
                    text: targetCmdId
                    readOnly: paramLayer.slaveConnected
                    validator: RegExpValidator {
                        regExp: /[0-9A-Fa-f]{1,8}/
                    }
                    onAccepted: {
                        targetCmdId = text
                    }
                }
            }

            GroupBox {
                Layout.fillWidth: true
                title: qsTr("Target Response ID")
                TextField {
                    id: targetResIdField
                    anchors.fill: parent
                    horizontalAlignment: TextInput.AlignRight
                    text: targetResId
                    readOnly: paramLayer.slaveConnected
                    validator: RegExpValidator {
                        regExp: /[0-9A-Fa-f]{1,8}/
                    }
                    onAccepted: {
                        targetResId = text
                    }
                }
            }
        }

        GroupBox {
            anchors.left: parent.left
            anchors.right: parent.right
            RowLayout {
                anchors.left: parent.left
                anchors.right: parent.right
                Button {
                    Layout.alignment: Qt.AlignVCenter | Qt.AlignHCenter
                    Layout.fillWidth: true
                    id: intfcOpenButton
                    text: qsTr("Open")
                    onClicked: {
                        if (intfcComboBox.selectedUri !== "")
                            paramLayer.intfcUri = intfcComboBox.selectedUri.replace(
                                        /bitrate=[0-9]*/,
                                        "bitrate=" + bitrateComboBox.bps.toString(
                                            ))
                    }
                    enabled: !paramLayer.intfcOk
                             && intfcComboBox.selectedUri !== ""
                }
                Button {
                    Layout.alignment: Qt.AlignVCenter | Qt.AlignHCenter
                    Layout.fillWidth: true
                    id: intfcCloseButton
                    text: qsTr("Close")
                    onClicked: {
                        paramLayer.intfcUri = ""
                    }
                    enabled: paramLayer.intfcOk && !paramLayer.slaveConnected
                }
                Button {
                    Layout.alignment: Qt.AlignVCenter | Qt.AlignHCenter
                    Layout.fillWidth: true
                    id: paramConnectButton
                    text: qsTr("Connect")
                    onClicked: app.connect()
                    enabled: paramLayer.intfcOk && !paramLayer.slaveConnected
                }
                Button {
                    Layout.alignment: Qt.AlignVCenter | Qt.AlignHCenter
                    Layout.fillWidth: true
                    id: paramUploadButton
                    text: qsTr("Read")
                    onClicked: paramLayer.upload()
                    enabled: paramLayer.slaveConnected && paramLayer.idle
                }
                Button {
                    Layout.alignment: Qt.AlignVCenter | Qt.AlignHCenter
                    Layout.fillWidth: true
                    id: paramDownloadButton
                    text: qsTr("Write")
                    onClicked: paramLayer.download()
                    enabled: paramLayer.slaveConnected && paramLayer.idle
                }
                Button {
                    Layout.alignment: Qt.AlignVCenter | Qt.AlignHCenter
                    Layout.fillWidth: true
                    id: paramNvWriteButton
                    text: qsTr("Save")
                    onClicked: paramLayer.nvWrite()
                    enabled: paramLayer.slaveConnected && paramLayer.idle
                }
                Button {
                    Layout.alignment: Qt.AlignVCenter | Qt.AlignHCenter
                    Layout.fillWidth: true
                    id: paramDisconnectButton
                    text: qsTr("Disconnect")
                    onClicked: paramLayer.disconnectSlave()
                    enabled: paramLayer.slaveConnected
                }
            }
        }
    }

    statusBar: ProgressBar {
        id: progressBar
        anchors.fill: parent
        value: paramLayer.opProgress
    }

    ParamTabView {
        id: paramTabView
        anchors.fill: parent
        registry: paramLayer.registry
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

    MessageDialog {
        id: paramOverwriteDialog
        title: qsTr("Message")
        standardButtons: StandardButton.Yes | StandardButton.Cancel
        text: "Some parameters have not yet been downloaded to the device. Are you sure you want to load new ones?"

        function show() {
            visible = true
        }

        onYes: {
            visible = false
            paramLoadFileDialog.open()
        }

        onRejected: {
            visible = false
        }
    }

    FileDialog {
        property string filePath
        id: paramLoadFileDialog
        title: qsTr("Load Parameter File")
        modality: Qt.NonModal
        nameFilters: ["JSON files (*.json)", "All files (*)"]
        onAccepted: {
            paramFileIo.name = UrlUtil.urlToLocalFile(fileUrl.toString())
            paramLayer.setRawData(paramFileIo.read())
        }
        selectExisting: true
    }

    FileDialog {
        property string filePath
        id: paramSaveFileDialog
        title: qsTr("Save Parameter File")
        modality: Qt.NonModal
        nameFilters: ["JSON files (*.json)", "All files (*)"]
        onAccepted: {
            paramFileIo.name = UrlUtil.urlToLocalFile(fileUrl.toString())
            paramFileIo.write(paramLayer.saveableRawData())
        }
        selectExisting: false
    }

    AboutDialog {
        id: aboutDialog
    }

    HelpDialog {
        id: helpDialog
    }
}
