import QtQuick 2.4
import QtQuick.Controls 1.4
import QtQuick.Layouts 1.2
import QtQuick.Window 2.2
import QtQuick.Dialogs 1.2
import com.ebus.utils.cda2tool 1.0
import com.setuptools.xcp 1.0
import com.setuptools 1.0

ApplicationWindow {
    title: qsTr("HGM Flash Tool")
    width: 400
    height: 300
    visible: true

    menuBar: MenuBar {
        property alias fileMenu: fileMenu
        Menu {
            id: fileMenu
            title: qsTr("&File")
            MenuItem {
                text: qsTr("Open &Program")
                onTriggered: mainForm.selectProg()
            }
            MenuSeparator { }
            MenuItem {
                text: qsTr("&Open Parameter File")
                shortcut: StandardKey.Open
                onTriggered: {
                    if(cda2Tool.paramWriteCacheDirty)
                        paramOverwriteDialog.show()
                    else
                        paramLoadFileDialog.open()
                }
            }
            MenuItem {
                text: qsTr("&Save Parameter File")
                shortcut: StandardKey.Save
                onTriggered: {
                    if(cda2Tool.paramFileExists)
                        cda2Tool.saveParamFile()
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
        toolReadyProg: cda2Tool.programOk && cda2Tool.intfcOk && cda2Tool.progReady
        toolReadyReset: cda2Tool.intfcOk && cda2Tool.progReady
        toolReadyParam: cda2Tool.intfcOk && cda2Tool.paramReady
        toolBusy: !cda2Tool.idle
        paramWriteCacheDirty: cda2Tool.paramWriteCacheDirty
        progBaseText: cda2Tool.programData ? "0x00000000".substr(0, 10 - cda2Tool.programBase.toString(16).length) + cda2Tool.programBase.toString(16).toUpperCase() : ""
        progSizeText: cda2Tool.programData ? cda2Tool.programSize.toString(10) : ""
        progCksumText: cda2Tool.programData ? "0x00000000".substr(0, 10 - cda2Tool.programCksum.toString(16).length) + cda2Tool.programCksum.toString(16).toUpperCase() : ""
        progressValue: cda2Tool.progress
        paramFilePath: cda2Tool.paramFilePath
        onUserStartProg: cda2Tool.startProgramming()
        onUserResetProg: cda2Tool.startReset()
        onUserConnectParam: cda2Tool.startParamConnect()
        onUserDownloadParam: cda2Tool.startParamDownload()
        onUserUploadParam: cda2Tool.startParamUpload()
        onUserNvWriteParam: cda2Tool.startParamNvWrite()
        onUserDisconnectParam: cda2Tool.startParamDisconnect()
        onUserShowParamEdit: paramWindow.show()
        targetCmdId: cda2Tool.slaveCmdId
        targetResId: cda2Tool.slaveResId

        onTargetChanged: {
            cda2Tool.slaveCmdId = targetCmdId
            cda2Tool.slaveResId = targetResId
        }
    }

    Cda2Tool {
        id: cda2Tool
        programData: mainForm.progFileData
        intfcUri: mainForm.intfcUri
        onProgrammingDone: {
            if(result === OpResult.Success)
                messageDialog.show("Programming complete")
            else
                errorDialog.show("Programming failed: " + OpResult.asString(result))
        }
        onResetDone: {
            if(result === OpResult.Success)
                messageDialog.show("Reset complete")
            else
                errorDialog.show("Reset failed: " + OpResult.asString(result))
        }
        onParamConnectDone: {
            if(result != OpResult.Success)
                errorDialog.show("Calibration mode connect failed: " + OpResult.asString(result))
        }
        onSaveParamFileDone: {
            if(result != OpResult.Success)
                errorDialog.show("Parameter save failed: " + OpResult.asString(result))
        }
        onLoadParamFileDone: {
            if(result === OpResult.WarnKeyLoadFailure)
                errorDialog.show("Some keys were not recognized; the rest of the file has been loaded") // FIXME make another dialog that shows the unmatched keys?
            else if(result != OpResult.Success)
                errorDialog.show("Parameter load failed: " + OpResult.asString(result))
        }
        onParamDownloadDone: {
            if(result != OpResult.Success)
                errorDialog.show("Parameter download failed: " + OpResult.asString(result))
        }
        onParamUploadDone: {
            if(result != OpResult.Success)
                errorDialog.show("Parameter upload failed: " + OpResult.asString(result))
        }
        onParamNvWriteDone: {
            if(result == OpResult.Success)
                messageDialog.show("Nonvolatile memory write complete")
            else
                errorDialog.show("Nonvolatile memory write failed: " + OpResult.asString(result))
        }
        onParamDisconnectDone: {
            if(result != OpResult.Success)
                errorDialog.show("Calibration mode disconnect failed: " + OpResult.asString(result))
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
            cda2Tool.paramFilePath = UrlUtil.urlToLocalFile(fileUrl.toString())
            cda2Tool.loadParamFile()
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
            cda2Tool.paramFilePath = UrlUtil.urlToLocalFile(fileUrl.toString())
            cda2Tool.saveParamFile()
        }
        selectExisting: false
    }

    AboutDialog {
        id: aboutDialog
    }

    HelpDialog {
        id: helpDialog
    }

    ParamWindow {
        id: paramWindow
        registry: cda2Tool.paramLayer.registry
    }
}
