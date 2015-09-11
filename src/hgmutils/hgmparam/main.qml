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

    readonly property string programName: qsTr("CS2 Parameter Editor")
    property CS2Defaults defaults: CS2Defaults {
    }


    signal connect

    onConnect: {
        paramLayer.slaveId = targetCmdId.value + ":" + targetResId.value
        paramLayer.connectSlave()
    }

    ParamLayer {
        id: paramLayer
        addrGran: 4
        slaveTimeout: 100
        slaveNvWriteTimeout: 200
        onConnectSlaveDone: forceSlaveSupportCalPage()
    }

    JSONParamFile {
        id: paramFileIo
        onOpComplete: {
            if (result !== JSONParamFile.Ok)
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
                id: saveReadOnly
                text: qsTr("Save read-only data")
                checkable: true
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
            title: qsTr("Edit")

            MenuItem {
                id: unitsMenu
                text: qsTr("Use Metric Units")
                checkable: true
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

        RowLayout {
            Layout.topMargin: 5
            anchors.left: parent.left
            anchors.right: parent.right
            spacing: 0

            InterfaceChooser {
                id: interfaceChooser
                Layout.fillWidth: true
                enabled: !paramLayer.intfcOk
            }

            BitRateChooser {
                id: bitRateChooser
                Layout.fillWidth: true
                enabled: !paramLayer.intfcOk
            }

            HexEntryField {
                id: targetCmdId
                Layout.fillWidth: true
                title: qsTr("Target Command ID")
                value: defaults.targetCmdId
                enabled: !paramLayer.slaveConnected
            }

            HexEntryField {
                id: targetResId
                Layout.fillWidth: true
                title: qsTr("Target Response ID")
                value: defaults.targetResId
                enabled: !paramLayer.slaveConnected
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
                        if (interfaceChooser.uri !== "")
                            paramLayer.intfcUri = interfaceChooser.uri.replace(
                                        /bitrate=[0-9]*/,
                                        "bitrate=" + bitRateChooser.bps.toString(
                                            ))
                    }
                    enabled: !paramLayer.intfcOk
                             && interfaceChooser.uri !== ""
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
        useMetricUnits: unitsMenu.checked
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
        text: qsTr("Some parameters have not yet been saved. Are you sure you want to load new ones?")

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
        id: paramLoadFileDialog
        title: qsTr("Load Parameter File")
        modality: Qt.NonModal
        nameFilters: defaults.parameterFilenameFilters
        folder: shortcuts.home
        selectExisting: true

        property string filePath

        onAccepted: {
            paramSaveFileDialog.folder = folder
            paramFileIo.name = UrlUtil.urlToLocalFile(fileUrl.toString())
            paramLayer.setRawData(paramFileIo.read())
        }
    }

    FileDialog {
        id: paramSaveFileDialog
        title: qsTr("Save Parameter File")
        modality: Qt.NonModal
        nameFilters: defaults.parameterFilenameFilters
        folder: shortcuts.home
        selectExisting: false

        property string filePath

        onAccepted: {
            paramLoadFileDialog.folder = folder
            paramFileIo.name = UrlUtil.urlToLocalFile(fileUrl.toString())
            if(saveReadOnly)
            {
                paramFileIo.write(paramLayer.saveableRawData())
            }
            else
            {
                paramFileIo.write(paramLayer.rawData())
            }
        }
    }

    AboutDialog {
        id: aboutDialog
    }

    HelpDialog {
        id: helpDialog
    }

    Splash {
    }
}
