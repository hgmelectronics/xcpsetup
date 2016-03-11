import QtQuick 2.4
import QtQuick.Controls 1.4
import QtQuick.Controls.Styles 1.4
import QtQuick.Layouts 1.2
import QtQuick.Window 2.2
import QtQuick.Dialogs 1.2
import Qt.labs.settings 1.0
import com.hgmelectronics.setuptools.xcp 1.0
import com.hgmelectronics.setuptools 1.0
import com.hgmelectronics.setuptools.ui 1.0
import com.hgmelectronics.utils 1.0

ApplicationWindow {
    id: application
    property string programName: qsTr("COMPUSHIFT Parameter Editor")
    property string programVersion: ""
    property alias useMetricUnits: paramTabView.useMetricUnits
    property alias readParametersOnConnect: readParametersOnConnectAction.checked
    property alias saveReadOnlyParameters: saveReadOnlyParametersAction.checked
    property alias saveParametersOnWrite: saveParametersOnWriteAction.checked
    property CS2Defaults cs2Defaults:  CS2Defaults {
                                      }

    title: programName
    width: 800
    height: 600
    visible: true

    signal connect

    onConnect: {
        paramLayer.slaveId = "%1:%2".arg(targetCmdId.value).arg(
                    targetResId.value)
        paramLayer.connectSlave()
    }

    Settings {
        category: "application"
        property alias saveReadOnlyParameters: application.saveReadOnlyParameters
        property alias useMetricUnits: application.useMetricUnits
        property alias saveOnWrite: application.saveParametersOnWrite
    }

    ParamLayer {
        id: paramLayer
        addrGran: 4
        slaveTimeout: 100
        slaveNvWriteTimeout: 1000

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
                forceSlaveSupportCalPage()
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
                if(saveParametersOnWrite)
                    nvWrite()
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
            if (result !== JSONParamFile.Ok)
                errorDialog.show(resultString)
        }
    }

    FileDialog {
        id: paramFileDialog
        title: selectExisting ? qsTr("Load Parameter File") : qsTr(
                                    "Save Parameter File as")
        nameFilters: cs2Defaults.parameterFilenameFilters
        folder: shortcuts.home

        function load() {
            selectExisting = true
            open()
        }

        function save() {
            selectExisting = false
            open()
        }

        onAccepted: {
            paramFileIo.name = UrlUtil.urlToLocalFile(fileUrl.toString())
            if (selectExisting) {
                paramLayer.setRawData(paramFileIo.read())
            } else {
                saveParamFile()
            }
        }
    }

    MessageDialog {
        id: resetNeededDialog
        title: qsTr("Reset Needed")
        text: readParametersOnConnect
                ? qsTr("The CS2 needs to be restarted to apply the new settings. Please cycle power and reconnect. Then, if you are programming the controller using settings from a file, reload the file and write to the controller again.")
                : qsTr("The CS2 needs to be restarted to apply the new settings. Please cycle power, reconnect, and read parameters again. Then, if you are programming the controller using settings from a file, reload the file and write to the controller again.")
        standardButtons: StandardButton.Ok
    }
    function saveParamFile() {
        if (saveReadOnlyParameters) {
            paramFileIo.write(paramLayer.rawData())
        } else {
            paramFileIo.write(paramLayer.saveableRawData())
        }
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
                paramFileDialog.load()
            }
        }
    }

    Action {
        id: fileSaveAsAction
        text: qsTr("Save Parameter File &As")
        iconName: "document-save-as"
        onTriggered: {
            paramFileDialog.save()
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

    ExclusiveGroup {
        id: useUnitsGroup
        Action {
            id: useMetricUnitsAction
            text: qsTr("Metric")
            tooltip: qsTr("Units will be displayed in metric units")
            checkable: true
            checked: useMetricUnits
            onTriggered: useMetricUnits = true
        }

        Action {
            id: useUSUnitsAction
            text: qsTr("US")
            tooltip: qsTr("Units will be displayed in US customary units")
            checkable: true
            checked: !useMetricUnits
            onTriggered: useMetricUnits = false
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
        text: qsTr("Save read-only parameters")
        tooltip: qsTr("Saves read only data to the parameter file for review later.")
        checkable: true
        checked: true
    }

    Action {
        id: saveParametersOnWriteAction
        text: qsTr("Save parameters after write")
        tooltip: qsTr("Automatically saves parameters when they are written to the controller.")
        checkable: true
        checked: true
    }

    Action {
        id: intfcOpenAction
        text: qsTr("Open")
        tooltip: qsTr("Opens the CAN network adapter")
        onTriggered: {
            if (interfaceChooser.uri !== "")
                paramLayer.intfcUri = interfaceChooser.uri.replace(
                            /bitrate=[0-9]*/,
                            "bitrate=%1".arg(bitRateChooser.bps))
        }
        enabled: !paramLayer.intfcOk && interfaceChooser.uri !== ""
    }

    Action {
        id: intfcCloseAction
        text: qsTr("Close")
        tooltip: qsTr("Closes the CAN network adapter")
        onTriggered: {
            paramLayer.intfcUri = ""
        }
        enabled: paramLayer.intfcOk && !paramLayer.slaveConnected
    }

    Action {
        id: paramConnectAction
        text: qsTr("Connect")
        tooltip: qsTr("Connects to the COMPUSHIFT")
        onTriggered: application.connect()
        enabled: paramLayer.intfcOk && !paramLayer.slaveConnected
    }

    Action {
        id: paramUploadAction
        text: qsTr("Read")
        tooltip: qsTr("Reads all parameters from COMPUSHIFT")
        onTriggered: paramLayer.upload()
        enabled: paramLayer.slaveConnected && paramLayer.idle
    }

    Action {
        id: paramDownloadAction
        text: qsTr("Write")
        tooltip: qsTr("Writes modified parameters to the COMPUSHIFT")
        onTriggered: {
            paramLayer.download()
        }
        enabled: paramLayer.slaveConnected && paramLayer.idle
    }

    Action {
        id: paramNvWriteAction
        text: qsTr("Save")
        tooltip: qsTr("Makes modified parameters permanent")
        onTriggered: paramLayer.nvWrite()
        enabled: paramLayer.slaveConnected && paramLayer.idle
    }

    Action {
        id: paramDisconnectAction
        text: qsTr("Disconnect")
        tooltip: qsTr("Disconnects from the COMPUSHIFT")
        onTriggered: paramLayer.disconnectSlave()
        enabled: paramLayer.slaveConnected
    }

    Action {
        id: enableAllParametersAction
        text: qsTr("Enable All Parameters")
        onTriggered: paramLayer.registry.setValidAll(true)
    }

    Action {
        id: disableAllParametersAction
        text: qsTr("Disable All Parameters")
        onTriggered: paramLayer.registry.setValidAll(false)
    }

    menuBar: MenuBar {
        Menu {
            title: qsTr("&File")
            MenuItem {
                action: fileOpenAction
            }
            MenuItem {
                action: fileSaveAsAction
            }
            MenuSeparator {
            }
            MenuItem {
                action: quitAction
            }
        }

        Menu {
            title: qsTr("&Edit")
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
            Menu {
                title: qsTr("&Units")
                MenuItem {
                    action: useMetricUnitsAction
                }
                MenuItem {
                    action: useUSUnitsAction
                }
            }
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

    toolBar: ColumnLayout {
        anchors.fill: parent

        RowLayout {
            Layout.topMargin: 5
            Layout.fillWidth: true
            Layout.leftMargin: 5
            Layout.rightMargin: 5
            spacing: 0

            XcpInterfaceChooser {
                id: interfaceChooser
                Layout.fillWidth: true
                enabled: !paramLayer.intfcOk
            }

            BitRateChooser {
                id: bitRateChooser
                width: 100
                enabled: !paramLayer.intfcOk
            }

            HexEntryField {
                id: targetCmdId
                width: 150
                title: qsTr("Command ID")
                value: cs2Defaults.targetCmdId
                enabled: !paramLayer.slaveConnected
            }

            HexEntryField {
                id: targetResId
                width: 150
                title: qsTr("Response ID")
                value: cs2Defaults.targetResId
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
                    action: intfcOpenAction
                }
                Button {
                    Layout.alignment: Qt.AlignVCenter | Qt.AlignHCenter
                    Layout.fillWidth: true
                    action: intfcCloseAction
                }
                Button {
                    Layout.alignment: Qt.AlignVCenter | Qt.AlignHCenter
                    Layout.fillWidth: true
                    action: paramConnectAction
                }
                Button {
                    Layout.alignment: Qt.AlignVCenter | Qt.AlignHCenter
                    Layout.fillWidth: true
                    action: paramUploadAction
                }
                Button {
                    Layout.alignment: Qt.AlignVCenter | Qt.AlignHCenter
                    Layout.fillWidth: true
                    action: paramDownloadAction
                }
                Button {
                    Layout.alignment: Qt.AlignVCenter | Qt.AlignHCenter
                    Layout.fillWidth: true
                    action: paramNvWriteAction
                }
                Button {
                    Layout.alignment: Qt.AlignVCenter | Qt.AlignHCenter
                    Layout.fillWidth: true
                    action: paramDisconnectAction
                }
            }
        }
    }

    ParamTabView {
        id: paramTabView
        anchors.fill: parent
        registry: paramLayer.registry
    }

    statusBar: StatusBar {
        RowLayout {
            anchors.fill: parent
            ProgressBar {
                id: progressBar
                Layout.fillHeight: true
                Layout.fillWidth: true
                value: paramLayer.opProgress
            }
            ShowLogButton {
                window: logWindow
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
        text: qsTr("Some parameters have not yet been saved. Are you sure you want to load new ones?")

        onYes: {
            visible = false
            paramFileDialog.load()
        }

        onRejected: {
            visible = false
        }
    }

    AboutDialog {
        id: aboutDialog
        programName: application.programName
        programVersion: application.programVersion
    }

    HelpDialog {
        id: helpDialog
    }

    Splash {
    }
}
