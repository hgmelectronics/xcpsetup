import QtQuick 2.4
import QtQuick.Controls 1.4
import QtQuick.Layouts 1.2
import QtQuick.Window 2.2
import QtQuick.Dialogs 1.2
import Qt.labs.settings 1.0
import com.hgmelectronics.setuptools.xcp 1.0
import com.hgmelectronics.setuptools 1.0
import com.hgmelectronics.setuptools.ui 1.0

ApplicationWindow {
    id: application
    title: qsTr("IBEM Param Tool")
    width: 800
    height: 400
    visible: true
    property alias paramFileDir: paramLoadFileDialog.folder

    Settings {
        category: "application"
        property alias paramFileDir: application.paramFileDir
        property alias windowWidth: application.width
        property alias windowHeight: application.height
        property alias windowX: application.x
        property alias windowY: application.y
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
            id: toolsMenu
            title: qsTr("&Tools")
            MenuItem {
                action: enableAllParametersAction
            }
            MenuItem {
                action: disableAllParametersAction
            }
            MenuItem {
                action: AutoRefreshSelector.modeAction
            }
            MenuItem {
                action: AutoRefreshManager.runningAction
            }
            MenuItem {
                action: AutoRefreshIntervalDialog.openAction
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

    Action {
        id: enableAllParametersAction
        text: qsTr("Enable all parameters")
        onTriggered: paramLayer.registry.setValidAll(true)
    }

    Action {
        id: disableAllParametersAction
        text: qsTr("Disable all parameters")
        onTriggered: paramLayer.registry.setValidAll(false)
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
        onTargetChanged: {
            var cmdId = boardId * 2 + 0x1F000100
            var resId = boardId * 2 + 0x1F000101
            var idString = cmdId.toString(16) + ":" + resId.toString(16)
            paramLayer.slaveId = idString
            console.log(idString)
        }

        onUserConnectParam: {
            var cmdId = boardId * 2 + 0x1F000100    // convert again for luck and on startup
            var resId = boardId * 2 + 0x1F000101
            var idString = cmdId.toString(16) + ":" + resId.toString(16)
            paramLayer.slaveId = idString
            console.log(paramLayer.slaveId)
            paramLayer.connectSlave()
        }
        onUserDownloadParam: paramLayer.download()
        onUserUploadParam: paramLayer.upload()
        onUserNvWriteParam: paramLayer.nvWrite()
        onUserDisconnectParam: paramLayer.disconnectSlave()
        onUserShowParamEdit: paramWindow.show()
        boardId: -120
        registry: paramLayer.registry
    }

    ParamLayer {
        id: paramLayer
        intfcUri: mainForm.intfcUri
        addrGran: 1
        slaveTimeout: 100
        slaveNvWriteTimeout: 200
        Component.onCompleted: AutoRefreshManager.paramLayer = this
        onConnectSlaveDone: paramLayer.setSlaveCalPage()
    }

    JSONParamFile {
        id: paramFileIo
        onOpComplete: {
            if(result !== JSONParamFile.Ok)
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
        folder: shortcuts.documents
        modality: Qt.NonModal
        nameFilters: [ "JSON files (*.json)", "All files (*)" ]
        onAccepted: {
            console.log(folder)
            folder = folder
            paramFileIo.name = UrlUtil.urlToLocalFile(fileUrl.toString())
            paramLayer.setRawData(paramFileIo.read(), true)
        }
        selectExisting: true
    }

    FileDialog {
        property string filePath
        id: paramSaveFileDialog
        title: qsTr("Save Parameter File")
        folder: paramLoadFileDialog.folder
        modality: Qt.NonModal
        nameFilters: [ "JSON files (*.json)", "All files (*)" ]
        onAccepted: {
            paramLoadFileDialog.folder = folder
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
