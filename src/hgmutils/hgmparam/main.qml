import QtQuick 2.4
import QtQuick.Controls 1.4
import QtQuick.Layouts 1.2
import QtQuick.Window 2.2
import QtQuick.Dialogs 1.2
import Qt.labs.settings 1.0
import com.hgmelectronics.setuptools.xcp 1.0
import com.hgmelectronics.setuptools 1.0
import com.hgmelectronics.utils 1.0

ApplicationWindow {
    id: application

    readonly property string programName: qsTr("COMPUSHIFT Parameter Editor")
    readonly property string programVersion: "1.1"
    property alias useMetricUnits: paramTabView.useMetricUnits
    property alias saveReadOnlyParameters: saveReadOnlyParametersAction.checked
    property CS2Defaults cs2Defaults: CS2Defaults {
                                      }
    title: paramFileIo.name.length === 0 ? programName : "%1 - %2".arg(paramFileIo.name).arg(programName)
    width: 800
    height: 600
    visible: true

    signal connect

    onConnect: {
        paramLayer.slaveId = "%1:%2".arg(targetCmdId.value).arg(targetResId.value)
        paramLayer.connectSlave()
    }

    Settings {
        category: "application"
        property alias saveReadOnlyParameters: application.saveReadOnlyParameters
        property alias useMetricUnits: application.useMetricUnits
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
        id: fileSaveAction
        text: qsTr("&Save Parameter File")
        iconName: "document-save"
        shortcut: StandardKey.Save
        onTriggered: {
            if (paramFileIo.exists) {
                saveParamFile()
            } else {
                paramFileDialog.save()
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
        id: saveReadOnlyParametersAction
        text: qsTr("Save read-only data")
        tooltip: qsTr("Saves read only data to the parameter file for review later.")
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
        onTriggered: paramLayer.download()
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
        text: qsTr("Enable all parameters")
        onTriggered: paramLayer.registry.setValidAll(true)
    }

    Action {
        id: disableAllParametersAction
        text: qsTr("Disable all parameters")
        onTriggered: paramLayer.registry.setValidAll(false)
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
            MenuSeparator {
            }
            MenuItem {
                action: quitAction
            }
        }

        Menu {
            title: qsTr("Edit")
            MenuItem {
                action: enableAllParametersAction
            }
            MenuItem {
                action: disableAllParametersAction
            }
        }

        Menu {
            title: qsTr("Options")
            Menu {
                title: qsTr("Units")
                MenuItem {
                    action: useMetricUnitsAction
                }
                MenuItem {
                    action: useUSUnitsAction
                }
            }
            MenuItem {
                action: saveReadOnlyParametersAction
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

            InterfaceChooser {
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

    statusBar: ProgressBar {
        id: progressBar
        anchors.fill: parent
        value: paramLayer.opProgress
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
