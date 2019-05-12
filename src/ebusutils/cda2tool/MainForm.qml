import QtQuick 2.4
import QtQuick.Controls 1.4
import QtQuick.Layouts 1.2
import QtQuick.Window 2.2
import QtQuick.Dialogs 1.2
import com.hgmelectronics.setuptools.xcp 1.0
import com.hgmelectronics.setuptools 1.0
import com.hgmelectronics.setuptools.ui 1.0

ColumnLayout {
    id: root

    spacing: 10
    anchors.fill: parent
    anchors.margins: 10

    property string paramFilePath
    property string targetCmdId
    property string targetResId
    property string intfcUri: ""
    property alias progressValue: progressBar.value
    property alias paramLayer: paramTabView.paramLayer
    property alias registry: paramTabView.registry
    property alias interfaceSaveUri: interfaceChooser.saveUri
    property bool intfcOpen
    property bool slaveConnected
    property bool paramBusy
    property bool paramWriteCacheDirty
    signal userConnectParam
    signal userDownloadParam
    signal userUploadParam
    signal userNvWriteParam
    signal userDisconnectParam
    signal userShowParamEdit
    signal targetChanged

    function selectLoadParam() {
        paramLoadFileDialog.open()
    }

    ParamTabView {
        id: paramTabView
        anchors.left: parent.left
        anchors.right: parent.right
        Layout.fillHeight: true
    }

    RowLayout {
        id: commandsRow
        anchors.left: parent.left
        anchors.right: parent.right
        spacing: 5
        ColumnLayout {
            spacing: 5

            InterfaceRegistry {
                id: registry
            }

            RowLayout {
                id: intfcConfigRow
                anchors.left: parent.left
                anchors.right: parent.right
                spacing: 5

                XcpInterfaceChooser {
                    id: interfaceChooser
                    Layout.fillWidth: true
                    enabled: !intfcOpen
                }

                BitRateChooser {
                    id: bitRateChooser
                    enabled: !intfcOpen
                }
            }
            RowLayout {
                id: intfcActionRow
                anchors.left: parent.left
                anchors.right: parent.right
                Button {
                    Layout.alignment: Qt.AlignVCenter | Qt.AlignHCenter
                    Layout.fillWidth: true
                    id: intfcOpenButton
                    text: qsTr("Open")
                    onClicked: {
                        if (interfaceChooser.uri !== "") {
                            interfaceChooser.saveUri = interfaceChooser.uri
                            root.intfcUri = interfaceChooser.uri + "?bitrate=%1".arg(bitRateChooser.bps)
                        }
                    }
                    enabled: !intfcOpen
                }
                Button {
                    Layout.alignment: Qt.AlignVCenter | Qt.AlignHCenter
                    Layout.fillWidth: true
                    id: intfcCloseButton
                    text: qsTr("Close")
                    onClicked: {
                        root.intfcUri = ""
                    }
                    enabled: intfcOpen && !slaveConnected
                }
            }
        }

        GroupBox {
            title: "Target"
            ColumnLayout {
                spacing: 5

                RowLayout {
                    id: targetConfigRow
                    anchors.left: parent.left
                    anchors.right: parent.right

                    Label {
                        text: qsTr("Command ID")
                    }
                    TextField {
                        id: targetCmdIdField
                        text: targetCmdId
                        readOnly: slaveConnected
                        validator: RegExpValidator {
                            regExp: /[0-9A-Fa-f]{1,8}/
                        }
                        onAccepted: {
                            targetCmdId = text
                            root.targetChanged()
                        }
                    }

                    Label {
                        text: qsTr("Response ID")
                    }
                    TextField {
                        id: targetResIdField
                        text: targetResId
                        readOnly: slaveConnected
                        validator: RegExpValidator {
                            regExp: /[0-9A-Fa-f]{1,8}/
                        }
                        onAccepted: {
                            targetResId = text
                            root.targetChanged()
                        }
                    }
                }

                RowLayout {
                    id: paramActionRow
                    Button {
                        Layout.alignment: Qt.AlignVCenter | Qt.AlignHCenter
                        Layout.fillWidth: true
                        id: paramConnectButton
                        text: qsTr("Connect")
                        onClicked: root.userConnectParam()
                        enabled: intfcOpen && !slaveConnected
                    }
                    Button {
                        Layout.alignment: Qt.AlignVCenter | Qt.AlignHCenter
                        Layout.fillWidth: true
                        id: paramUploadButton
                        text: qsTr("Read")
                        onClicked: root.userUploadParam()
                        enabled: slaveConnected && !paramBusy
                    }
                    Button {
                        Layout.alignment: Qt.AlignVCenter | Qt.AlignHCenter
                        Layout.fillWidth: true
                        id: paramDownloadButton
                        text: qsTr("Write")
                        onClicked: root.userDownloadParam()
                        enabled: slaveConnected && !paramBusy
                    }
                    Button {
                        Layout.alignment: Qt.AlignVCenter | Qt.AlignHCenter
                        Layout.fillWidth: true
                        id: paramNvWriteButton
                        text: qsTr("Save")
                        onClicked: root.userNvWriteParam()
                        enabled: slaveConnected && !paramBusy
                    }
                    Button {
                        Layout.alignment: Qt.AlignVCenter | Qt.AlignHCenter
                        Layout.fillWidth: true
                        id: paramDisconnectButton
                        text: qsTr("Disconnect")
                        onClicked: root.userDisconnectParam()
                        enabled: slaveConnected
                    }
                }
            }
        }
    }

    ProgressBar {
        id: progressBar
        anchors.left: parent.left
        anchors.right: parent.right
    }
}
