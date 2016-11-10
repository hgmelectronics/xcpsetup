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
    title: qsTr("CDA2 Param Tool")
    width: 1200
    height: 850
    visible: true
    property alias readParametersOnConnect: readParametersOnConnectAction.checked
    property alias saveReadOnlyParameters: saveReadOnlyParametersAction.checked
    property alias saveParametersOnWrite: saveParametersOnWriteAction.checked
    property alias paramFileDir: paramLoadFileDialog.folder
    property alias interfaceSaveUri: mainForm.interfaceSaveUri
    property alias paramLayer: paramLayer

    Settings {
        category: "application"
        property alias readParametersOnConnect: application.readParametersOnConnect
        property alias saveReadOnlyParameters: application.saveReadOnlyParameters
        property alias saveOnWrite: application.saveParametersOnWrite
        property alias paramFileDir: application.paramFileDir
        property alias windowWidth: application.width
        property alias windowHeight: application.height
        property alias windowX: application.x
        property alias windowY: application.y
        property alias interfaceSaveUri: application.interfaceSaveUri
    }

    Parameters {
        id: paramReg
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
            var slaveId = targetCmdId + ":" + targetResId
            paramLayer.slaveId = slaveId
            if(paramLayer.slaveId.toLowerCase() === slaveId.toLowerCase())
                paramLayer.connectSlave()
            else
                errorDialog.show(qsTr("Failed to set slave device ID"))
        }
        onUserDownloadParam: paramLayer.download()
        onUserUploadParam: paramLayer.upload()
        onUserNvWriteParam: paramLayer.nvWrite()
        onUserDisconnectParam: paramLayer.disconnectSlave()
        onUserShowParamEdit: paramWindow.show()
        targetCmdId: "1F000090"
        targetResId: "1F000091"
        registry: paramReg
        paramLayer: application.paramLayer
    }

    ParamLayer {
        id: paramLayer
        registry: paramReg
        intfcUri: mainForm.intfcUri
        slaveTimeout: 100
        slaveNvWriteTimeout: 400

        function checkImmediateWrite() {
            if(slaveConnected && idle && ImmediateWrite.keys.length > 0) {
                var keys = ImmediateWrite.keys
                ImmediateWrite.clear()
                download(keys)
            }
        }

        onConnectSlaveDone: {
            if(result === OpResult.Success) {
                ParamResetNeeded.set = false
                if(slaveConnected && idle && readParametersOnConnect)
                    upload()
            }
            else {
                errorDialog.show(qsTr("Connect failed: %1").arg(
                                     OpResult.asString(result)))
            }
        }
        onDisconnectSlaveDone: {
            ParamResetNeeded.set = false
        }
        onDownloadDone: {
            if(result === OpResult.Success) {
                if(saveParametersOnWrite) {
                    for(var i = 0, end = keys.length; i < end; ++i) {
                        if(paramLayer.registry.saveableParamKeys.indexOf(keys[i]) >= 0) {
                            nvWrite()
                            break
                        }
                    }
                }
            }
            else {
                errorDialog.show(qsTr("Download failed: %1").arg(
                                     OpResult.asString(result)))
            }
        }
        onNvWriteDone: {
            if(result === OpResult.Success) {
                if(ParamResetNeeded.set) {
                    disconnectSlave()
                    resetNeededDialog.open()
                }
            }
            else {
                errorDialog.show(qsTr("Nonvolatile memory write failed: %1").arg(
                                     OpResult.asString(result)))
            }
        }
        onUploadDone: {
            if(result !== OpResult.Success) {
                errorDialog.show(qsTr("Upload failed: %1").arg(
                                     OpResult.asString(result)))
            }
        }

        onIdleChanged: checkImmediateWrite()
        onSlaveConnectedChanged: checkImmediateWrite()
        onFault: {
            logWindow.fault(info)
        }
        onWarn: {
            logWindow.warn(info)
        }
        onInfo: {
            logWindow.info(info)
        }

        Component.onCompleted: AutoRefreshManager.paramLayer = this
    }

    LogWindow {
        id: logWindow
    }

    Connections {
        target: ImmediateWrite
        onTriggered: {
            if(paramLayer.idle && paramLayer.slaveConnected)
                paramLayer.checkImmediateWrite()
        }
    }

    JSONParamFile {
        id: paramFileIo
        onOpComplete: {
            if(result !== JSONParamFile.Ok)
                errorDialog.show(resultString)
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
            paramLayer.setData(paramFileIo.read(), true, ParamLayer.SetToNew)
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

    MessageDialog {
        id: resetNeededDialog
        title: qsTr("Reset Needed")
        text: readParametersOnConnect
                ? qsTr("The CDA2 needs to be restarted to apply the new settings. Please cycle power and reconnect. Then, if you are programming the controller using settings from a file, reload the file and write to the controller again.")
                : qsTr("The CDA2 needs to be restarted to apply the new settings. Please cycle power, reconnect, and read parameters again. Then, if you are programming the controller using settings from a file, reload the file and write to the controller again.")
        standardButtons: StandardButton.Ok
    }


    Action {
        id: fileOpenAction
        text: qsTr("&Open Parameter File")
        iconName: "document-open"
        shortcut: StandardKey.Open
        onTriggered: {
            if (paramLayer.writeCacheDirty) {
                paramOverwriteDialog.open()
            } else {
                paramLoadFileDialog.open()
            }
        }
    }

    Action {
        id: fileSaveAction
        shortcut: StandardKey.Save
        onTriggered: {
            if(paramFileIo.exists)
                paramFileIo.write(paramLayer.saveableData())
            else
                paramSaveFileDialog.open()
        }
    }

    Action {
        id: fileSaveAsAction
        text: qsTr("Save Parameter File &As")
        iconName: "document-save-as"
        onTriggered: {
            paramSaveFileDialog.open()
        }
    }

    Action {
        id: quitAction
        text: qsTr("E&xit")
        iconName: "application-exit"
        shortcut: StandardKey.Quit
        // change to prompt to save file if dirty..
        onTriggered: Qt.quit()
    }

    Action {
        id: helpContentsAction
        text: qsTr("&Contents")
        iconName: "help-contents"
        shortcut: StandardKey.HelpContents
        onTriggered: {
            helpDialog.show()
        }
    }

    Action {
        id: helpAboutAction
        text: qsTr("&About")
        iconName: "help-about"
        onTriggered: {
            aboutDialog.show()
        }
    }

    Action {
        id: showLogAction
        text: qsTr("Show &Log")
        onTriggered: {
            logWindow.show()
        }
    }

    Action {
        id: readParametersOnConnectAction
        text: qsTr("Read parameters after connect")
        tooltip: qsTr("Automatically reads parameters from the controller after connecting.")
        checkable: true
        checked: true
    }

    Action {
        id: saveReadOnlyParametersAction
        text: qsTr("Save read-only parameters to file")
        tooltip: qsTr("Saves read only data to the parameter file for review later.")
        checkable: true
        checked: true
    }

    Action {
        id: saveParametersOnWriteAction
        text: qsTr("Save parameters on controller after write")
        tooltip: qsTr("Automatically saves parameters when they are written to the controller.")
        checkable: true
        checked: true
    }

    Action {
        id: undoAction
        text: qsTr("Undo")
        shortcut: StandardKey.Undo
        enabled: paramReg.currentRevNum > paramReg.minRevNum
        onTriggered: paramReg.currentRevNum = paramReg.currentRevNum - 1
    }

    Action {
        id: redoAction
        text: qsTr("Redo")
        shortcut: StandardKey.Redo
        enabled: paramReg.currentRevNum < paramReg.maxRevNum
        onTriggered: paramReg.currentRevNum = paramReg.currentRevNum + 1
    }

    Action {
        id: enableAllParametersAction
        text: qsTr("Enable all parameters")
        onTriggered: paramReg.setValidAll(true)
    }

    Action {
        id: disableAllParametersAction
        text: qsTr("Disable all parameters")
        onTriggered: paramReg.setValidAll(false)
    }

    menuBar: MenuBar {
        Menu {
            title: qsTr("&File")
            MenuItem {
                action: fileOpenAction
            }
            MenuItem {
                action: fileSaveAction
            }
            MenuItem {
                action: fileSaveAsAction
            }
            MenuSeparator { }
            MenuItem {
                action: quitAction
            }
        }

        Menu {
            title: qsTr("&Edit")
            MenuItem {
                action: undoAction
            }
            MenuItem {
                action: redoAction
            }
            MenuSeparator {}
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
            MenuSeparator {}
            MenuItem {
                action: showLogAction
            }
        }

        Menu {
            title: qsTr("&Settings")
            MenuItem {
                action: readParametersOnConnectAction
            }
            MenuItem {
                action: saveReadOnlyParametersAction
            }
            MenuItem {
                action: saveParametersOnWriteAction
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

    AboutDialog {
        id: aboutDialog
    }

    HelpDialog {
        id: helpDialog
    }

    Component.onCompleted: {
        // make sure the window doesn't completely disappear from the screen due to prefs save with a bigger monitor than current
        x = Math.min(x, Screen.desktopAvailableWidth - 30)
        y = Math.min(y, Screen.desktopAvailableWidth - 30)
    }
}
