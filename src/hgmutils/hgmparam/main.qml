import QtQuick 2.4
import QtQuick.Controls 1.4
import QtQuick.Layouts 1.2
import QtQuick.Window 2.2
import QtQuick.Dialogs 1.2
import com.hgmelectronics.setuptools.xcp 1.0
import com.hgmelectronics.setuptools 1.0

ApplicationWindow {
    title: qsTr("CS2 Parameter Editor")
    width: 800
    height: 500
    visible: true

    menuBar: MenuBar {
        property alias fileMenu: fileMenu
        Menu {
            id: fileMenu
            title: qsTr("&File")
            MenuItem {
                text: qsTr("&Open Parameter File")
                shortcut: StandardKey.Open
                onTriggered: {
                    if(paramLayer.writeCacheDirty)
                        paramOverwriteDialog.show()
                    else
                        paramLoadFileDialog.open()
                }
            }
            MenuItem {
                text: qsTr("&Save Parameter File")
                shortcut: StandardKey.Save
                onTriggered: {
                    if(paramFileIo.exists)
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
        intfcOpen: paramLayer.intfcOk
        slaveConnected: paramLayer.slaveConnected
        paramBusy: !paramLayer.idle
        paramWriteCacheDirty: paramLayer.writeCacheDirty
        paramFilePath: paramFileIo.name
        progressValue: paramLayer.opProgress
        onUserConnectParam: {
            paramLayer.slaveId = targetCmdId + ":" + targetResId
            paramLayer.connectSlave()
        }
        onUserDownloadParam: paramLayer.download()
        onUserUploadParam: paramLayer.upload()
        onUserNvWriteParam: paramLayer.nvWrite()
        onUserDisconnectParam: paramLayer.disconnectSlave()
        onUserShowParamEdit: paramWindow.show()
        targetCmdId: "18FCD403"
        targetResId: "18FCD4F9"
        registry: paramLayer.registry
    }

    ParamLayer {
        id: paramLayer
        intfcUri: mainForm.intfcUri
        addrGran: 4
        slaveTimeout: 100
        slaveNvWriteTimeout: 200
        onConnectSlaveDone: forceSlaveSupportCalPage()
    }

    ParamFile {
        id: paramFileIo
        type: ParamFile.Json
        onOpComplete: {
            if(result !== ParamFile.Ok)
                errorDialog.show(resultString)
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
        nameFilters: [ "JSON files (*.json)", "All files (*)" ]
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
        nameFilters: [ "JSON files (*.json)", "All files (*)" ]
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
