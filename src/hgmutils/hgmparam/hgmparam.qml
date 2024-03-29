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
    property alias enableBetaFeatures: enableBetaFeaturesAction.checked
    property alias useMetricUnits: paramReg.useMetricUnits
    property alias readParametersOnConnect: readParametersOnConnectAction.checked
    property alias saveReadOnlyParameters: saveReadOnlyParametersAction.checked
    property alias saveParametersOnWrite: saveParametersOnWriteAction.checked
    property alias paramFileDir: paramFileDialog.folder
    property alias interfaceUri: interfaceChooser.saveUri
    property alias bleDeviceSaveAddr: bleDeviceChooser.saveAddr
    property alias bleDeviceSaveList: bleDeviceChooser.saveList
    property CS2Defaults cs2Defaults:  CS2Defaults {
    }

    title: programName
    width: 800
    height: 600
    visible: true

    signal connect


    function setStandardUnits() {
        var save = { metric: useMetricUnits }
        useMetricUnits = true
        return save
    }

    function restoreUnits(save) {
        useMetricUnits = save.metric
    }

    function isJsonParamFile(filename) {
        return filename.search(/\.hgp$/i) !== -1
    }

    function loadFileFromCommandLine() {
        var arguments = Qt.application.arguments

        if(arguments.length < 2) {
            return
        }

        var filename = arguments[1]

        if(isJsonParamFile(filename)) {
            jsonParamFileIo.name = filename
            loadJsonParamFile()
        }

    }


    Component.onCompleted: {
        // make sure the window doesn't completely disappear from the screen due to prefs save with a bigger monitor than current
        x = Math.min(x, Screen.desktopAvailableWidth - 30)
        y = Math.min(y, Screen.desktopAvailableWidth - 30)
        loadFileFromCommandLine()
    }

    onClosing: {
        Qt.quit()
    }


    onConnect: {
        paramLayer.slaveId = targetChooser.addr
    }

    Settings {
        category: "application"
        property alias enableBetaFeatures: application.enableBetaFeatures
        property alias readParametersOnConnect: application.readParametersOnConnect
        property alias saveReadOnlyParameters: application.saveReadOnlyParameters
        property alias useMetricUnits: application.useMetricUnits
        property alias saveOnWrite: application.saveParametersOnWrite
        property alias paramFileDir: application.paramFileDir
        property alias windowWidth: application.width
        property alias windowHeight: application.height
        property alias windowX: application.x
        property alias windowY: application.y
        property alias interfaceSaveUri: application.interfaceUri
        property alias bleDeviceSaveList: application.bleDeviceSaveList
        property alias bleDeviceSaveAddr: application.bleDeviceSaveAddr
    }

    Parameters {
        id: paramReg
    }

    ParamLayer {
        id: paramLayer
        slaveTimeout: interfaceChooser.selectedIsBle ? 120000 : 100;
        slaveNvWriteTimeout: 1000
        slaveBootDelay: 2000
        slaveProgResetIsAcked: false
        registry: paramReg

        function checkImmediateWrite() {
            if(slaveConnected && idle && ImmediateWrite.keys.length > 0) {
                var keys = ImmediateWrite.keys
                ImmediateWrite.clear()
                download(keys)
            }
        }

        onSlaveIdChanged: {
            if(targetChooser.addr.toLowerCase() === paramLayer.slaveId.toLowerCase())
                connectSlave()
        }

        onSetSlaveIdDone: {
            if(result !== OpResult.Success) {
                paramLayer.slaveId = ""
                errorDialog.show(qsTr("Setting slave ID failed: %1").arg(OpResult.asString(result)))
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
                slaveId = ""
            }
        }
        onDisconnectSlaveDone: {
            ParamResetNeeded.set = false
            paramLayer.slaveId = ""
        }
        onDownloadDone: {
            if(saveParametersOnWrite)
                nvWrite()
            if(result !== OpResult.Success)
                errorDialog.show(qsTr("Download failed: %1").arg(OpResult.asString(result)))
        }
        onNvWriteDone: {
            if(result === OpResult.Success) {
                if(ParamResetNeeded.set) {
                    paramLayer.calResetSlave()
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
        onProgramResetSlaveDone: {
            ParamResetNeeded.set = false
            paramLayer.slaveId = ""
            if(result !== OpResult.Success) {
                errorDialog.show(qsTr("Program mode reset failed: %1").arg(
                                     OpResult.asString(result)))
            }
        }
        onCalResetSlaveDone: {
            ParamResetNeeded.set = false
            paramLayer.slaveId = ""
            if(result === OpResult.Success) {
                paramLayer.programResetSlave()
            }
            else {
                errorDialog.show(qsTr("Cal mode reset failed: %1").arg(
                                     OpResult.asString(result)))
            }
        }
        onCopyCalPageDone: {
            if(result === OpResult.Success) {
                paramLayer.calResetSlave()
                resetNeededDialog.open()
            }
            else {
                errorDialog.show(qsTr("Calibration page copy failed: %1").arg(
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
        id: jsonParamFileIo
        onOpComplete: {
            if (result !== JSONParamFile.Ok)
                errorDialog.show(resultString)
        }
    }

    CSVParamFile {
        id: csvParamFileIo
        onOpComplete: {
            if (result !== CSVParamFile.Ok)
                errorDialog.show(resultString)
        }
    }

    FileDialog {
        id: paramFileDialog
        title: selectExisting ? qsTr("Load Parameter File") : qsTr(
                                    "Save Parameter File as")
        nameFilters: cs2Defaults.parameterFilenameFilters
        folder: shortcuts.documents

        function load() {
            selectExisting = true
            open()
        }

        function save() {
            selectExisting = false
            open()
        }

        onAccepted: {
            folder = folder // dark magicks: documentation says folder is updated when dialog is closed, but if you don't do this it resets to the value bound above for next invocation
            var filename = UrlUtil.urlToLocalFile(fileUrl.toString())
            if(isJsonParamFile(filename)) {
                jsonParamFileIo.name = filename
                if (selectExisting) {
                    loadJsonParamFile()
                } else {
                    saveJsonParamFile()
                }
            }
            else {
                csvParamFileIo.name = filename
                if (selectExisting) {
                    loadCsvParamFile()
                } else {
                    saveCsvParamFile()
                }
            }
        }
    }

    function loadJsonParamFile() {
        var rawData = jsonParamFileIo.read()
        paramReg.beginHistoryElide()
        if(paramLayer.slaveConnected) {
            paramLayer.setData(rawData, true, ParamLayer.KeepExisting)
        }
        else {
            paramLayer.setData(rawData, true, ParamLayer.Union)
            paramLayer.setData(rawData, true, ParamLayer.SetToNew)    // second time in case of param dependencies in wrong order
        }
        paramReg.endHistoryElide()

    }


    function saveJsonParamFile() {
        if (saveReadOnlyParameters) {
            jsonParamFileIo.write(paramLayer.rawData())
        } else {
            jsonParamFileIo.write(paramLayer.saveableRawData())
        }
    }

    function loadCsvParamFile() {

        var saveUnits = setStandardUnits()
        var data = csvParamFileIo.read()

        paramReg.beginHistoryElide()
        if(paramLayer.slaveConnected) {
            paramLayer.setData(data, false, ParamLayer.KeepExisting)
        }
        else {
            paramLayer.setData(data, false, ParamLayer.Union)
            paramLayer.setData(data, false, ParamLayer.SetToNew)    // second time in case of param dependencies in wrong order
        }
        paramReg.endHistoryElide()

        restoreUnits(saveUnits)
    }

    function saveCsvParamFile() {
        var data
        var saveUnits = setStandardUnits()
        if (saveReadOnlyParameters)
            data = paramLayer.data()
        else
            data = paramLayer.saveableData()
        restoreUnits(saveUnits)

        csvParamFileIo.write(data, paramLayer.names())
    }

    MessageDialog {
        id: resetNeededDialog
        title: qsTr("Reset Needed")
        text: readParametersOnConnect
              ? qsTr("The CS2 will be restarted to apply the new settings. Please wait for this to complete and then reconnect. Then, if you are programming the controller using settings from a file, reload the file and write to the controller again.")
              : qsTr("The CS2 will be restarted to apply the new settings. Please wait for this to complete, reconnect, and read parameters again. Then, if you are programming the controller using settings from a file, reload the file and write to the controller again.")

        standardButtons: StandardButton.Ok
    }

    MessageDialog {
        id: confirmRestoreCalDialog
        title: qsTr("Confirm Restore Calibration")
        text: qsTr("This will erase all custom settings on the CS2 and restore the factory calibration. Are you sure you want to do this?")
        standardButtons: StandardButton.Ok | StandardButton.Cancel
        onAccepted: paramLayer.copyCalPage(0, 1, 0, 0)
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
        id: enableBetaFeaturesAction
        text: qsTr("Enable beta features");
        tooltip: qsTr("Enables features for beta testing.")
        checkable: true
        checked: false
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
            interfaceChooser.saveUri = interfaceChooser.uri
            paramLayer.intfcUri = interfaceChooser.uri + "?bitrate=%1".arg(bitRateChooser.bps)
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
        onTriggered: {
            if(interfaceChooser.selectedIsBle)
                bleDeviceChooser.saveAddr = bleDeviceChooser.addr
            application.connect()
        }
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
        text: qsTr("Enable All Parameters")
        onTriggered: paramReg.setValidAll(true)
    }

    Action {
        id: disableAllParametersAction
        text: qsTr("Disable All Parameters")
        onTriggered: paramReg.setValidAll(false)
    }

    Action {
        id: resetSlaveAction
        text: qsTr("Reset Slave")
        onTriggered: paramLayer.calResetSlave()
        enabled: paramLayer.slaveConnected
    }

    Action {
        id: restoreFactoryCalAction
        text: qsTr("Restore Factory Calibration")
        onTriggered: confirmRestoreCalDialog.open()
        enabled: paramLayer.slaveConnected
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
                action: resetSlaveAction
            }
            MenuItem {
                action: restoreFactoryCalAction
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
            MenuItem {
                action: enableBetaFeaturesAction
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
        id: targetChooser
        property string addr: interfaceChooser.selectedIsCan ? "%1:%2".arg(targetCmdId.value).arg(targetResId.value) :
                              interfaceChooser.selectedIsBle ? bleDeviceChooser.addr : ""

        RowLayout {
            Layout.topMargin: 5
            Layout.fillWidth: true
            Layout.leftMargin: 5
            Layout.rightMargin: 5
            spacing: 5

            XcpInterfaceChooser {
                id: interfaceChooser
                Layout.fillWidth: true
                enabled: !paramLayer.intfcOk
            }

            BitRateChooser {
                id: bitRateChooser
                width: 100
                enabled: !paramLayer.intfcOk
                visible: interfaceChooser.selectedIsCan
            }

            HexEntryField {
                id: targetCmdId
                width: 150
                title: qsTr("Command ID")
                value: cs2Defaults.targetCmdId
                enabled: !paramLayer.slaveConnected
                visible: interfaceChooser.selectedIsCan
            }

            HexEntryField {
                id: targetResId
                width: 150
                title: qsTr("Response ID")
                value: cs2Defaults.targetResId
                enabled: !paramLayer.slaveConnected
                visible: interfaceChooser.selectedIsCan
            }

            BleDeviceChooser {
                visible: interfaceChooser.selectedIsBle
                id: bleDeviceChooser
                width: 500
                Layout.fillWidth: true
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
        registry: paramReg
        enableBetaFeatures: application.enableBetaFeatures
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

}
