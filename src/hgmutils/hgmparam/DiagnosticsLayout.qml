import QtQuick 2.5
import QtQuick.Controls 1.4
import QtQuick.Layouts 1.2
import QtQuick.Window 2.2
import QtQuick.Dialogs 1.2
import com.hgmelectronics.setuptools.xcp 1.0
import com.hgmelectronics.setuptools 1.0
import com.hgmelectronics.setuptools.ui 1.0

Flow {
    property Parameters parameters
    anchors.fill: parent
    anchors.margins: 10
    spacing: 10

    Button {
        text: "Bus Voltages"
        onClicked: {
            busVoltageDialog.showNormal()
            busVoltageDialog.raise()
        }
    }

    ScalarListDialog {
        id: busVoltageDialog
        title: "Bus Voltages"
        paramLists: [
            ScalarMetaParamList {
                params: [
                    parameters.controllerBus5Voltage,
                    parameters.controllerBus3_3Voltage,
                    parameters.controllerBus1_8Voltage,
                    parameters.controllerBus12Voltage,
                    parameters.controllerBusVoltage
                ]
            }
        ]
    }

    Button {
        text: "Frequency Sensors"
        onClicked: {
            frequencySensorsDialog.showNormal()
            frequencySensorsDialog.raise()
        }
    }

    ScalarListDialog {
        id: frequencySensorsDialog
        title: "Frequency Sensors"
        paramLists: [
            ScalarMetaParamList {
                params: [
                    parameters.controllerTachInputFrequency,
                    parameters.controllerTissInputFrequency,
                    parameters.controllerTossInputFrequency,
                    parameters.controllerSpareInputFrequency
                ]
            }
        ]
    }

    Button {
        text: "Voltage Sensors"
        onClicked: {
            voltageSensorsDialog.showNormal()
            voltageSensorsDialog.raise()
        }
    }

    ScalarListDialog {
        id: voltageSensorsDialog
        title: "Voltage Sensors"
        paramLists: [
            ScalarMetaParamList {
                params: [
                    parameters.controllerThrottlePositionSensorVoltage,
                    parameters.controllerMAPSensorVoltage,
                    parameters.controllerInternalTemperatureSensorVoltage,
                    parameters.controllerInternalTemperature,
                    parameters.controllerEngineTemperatureSensorVoltage,
                    parameters.controllerTransmissionTemperatureSensorVoltage,
                    parameters.controllerMultiplexedSensorVoltage
                ]
            }
        ]
    }

    Button {
        text: "Software"
        onClicked: {
            softwareDialog.showNormal()
            softwareDialog.raise()
        }
    }

    ScalarListDialog {
        id: softwareDialog
        title: "Software"
        paramLists: [
            ScalarMetaParamList {
                params: [
                    parameters.controllerHeapUsed,
                    parameters.controllerHeapSize,
                    parameters.controllerHeapAllocationCount,
                    parameters.controllerHeapReleaseCount
                ]
            }
        ]
    }

    Button {
        text: "Digital I/O"
        onClicked: {
            dioDialog.showNormal()
            dioDialog.raise()
        }
    }

    Window {
        id: dioDialog
        title: "Digital I/O"
        width: 450
        height: Math.max(inputColumn.implicitHeight, outputColumn.implicitHeight) + 40
        RowLayout {
            id: rowLayout
            anchors.fill: parent
            anchors.margins: 10
            spacing: 5
            ColumnLayout {
                id: inputColumn
                Layout.alignment: Qt.AlignTop
                Layout.fillWidth: true
                spacing: 5
                Label {
                    text: "Inputs"
                    font.bold: true
                }
                ScalarParamIndicator {
                    metaParam: parameters.controllerSDCardWriteProtect
                }
                ScalarParamIndicator {
                    metaParam: parameters.controllerSDCardPresent
                }
                ScalarParamIndicator {
                    metaParam: parameters.controllerMasterDriverFault
                }
                ScalarParamIndicator {
                    metaParam: parameters.controllerUSBPower
                }
            }
            ColumnLayout {
                id: outputColumn
                Layout.alignment: Qt.AlignTop
                Layout.fillWidth: true
                spacing: 5
                Label {
                    text: "Outputs"
                    font.bold: true
                }
                ScalarParamCheckBox {
                    metaParam: parameters.controllerGreenLED
                }
                ScalarParamCheckBox {
                    metaParam: parameters.controllerRedLED
                }
                ScalarParamCheckBox {
                    metaParam: parameters.controllerUSBConnect
                }
                ScalarParamCheckBox {
                    metaParam: parameters.controllerTransmissionTemperatureSensorBias
                }
                ScalarParamCheckBox {
                    metaParam: parameters.controllerEngineTemperatureSensorBias
                }
                ScalarParamCheckBox {
                    metaParam: parameters.controllerThrottlePositionSensorGround
                }
                ScalarParamCheckBox {
                    metaParam: parameters.controllerMAPSensorGround
                }
            }
        }

        AutoRefreshArea {
            base: rowLayout
        }
    }

    Button {
        text: "Frequency Outputs"
        onClicked: {
            frequencyOutputDialog.showNormal()
            frequencyOutputDialog.raise()
        }
    }

    ScalarListDialog {
        id: frequencyOutputDialog
        title: "Frequency Outputs"
        paramLists: [
            ScalarMetaParamList {
                params: [
                    parameters.controllerSpeedTimer1Frequency,
                    parameters.controllerSpeedTimer2Frequency
                ]
            }
        ]
    }

    Button {
        text: "PWM Drivers"
        enabled: parameters.controllerPWMDrivers.param.valid
        onClicked: {
            pwmDriversWindow.showNormal()
            pwmDriversWindow.raise()
        }
        Window {
            id: pwmDriversWindow
            title: qsTr("PWM Drivers")
            width: 480
            height: 400

            RowLayout {
                id: pwmRowLayout
                anchors.fill: parent
                MultiroleTableParamEdit {
                    Layout.margins: 10
                    Layout.fillHeight: true
                    Layout.fillWidth: true

                    tableMetaParam: parameters.controllerPWMDrivers
                    roleNames: ["x", "frequency", "dutyCycle", "mode"]
                }
            }

            AutoRefreshArea {
                base: pwmRowLayout
            }
        }
    }
}


//        Tab {
//            title: qsTr("Inputs")
//            active: true
//            Flow {
//                anchors.fill: parent
//                anchors.margins: 10
//                spacing: 10
//                TableParamView {
//                    name: qsTr("Switch Monitor Input")
//                    xLabel: qsTr("Switch #")
//                    valueLabel: qsTr("State")
//                    tableParam: parameters.switchMonitorModel
//                    enabled: parameters.switchMonitorInput.valid
//                }
//            }
//        }

