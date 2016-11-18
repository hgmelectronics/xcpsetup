import QtQuick 2.5
import QtQuick.Controls 1.4
import QtQuick.Layouts 1.2
import QtQuick.Window 2.2
import QtQuick.Dialogs 1.2
import com.hgmelectronics.setuptools.xcp 1.0
import com.hgmelectronics.setuptools 1.0
import com.hgmelectronics.setuptools.ui 1.0

ColumnLayout {
    property Parameters parameters
    anchors.fill: parent
    anchors.margins: 10
    spacing: 10

    Flow {
        spacing: 10

        Button {
            text: "Bus Voltages"
            onClicked: {
                busVoltageDialog.showNormal()
                busVoltageDialog.raise()
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
        }

        Button {
            text: "Frequency Sensors"
            onClicked: {
                frequencySensorsDialog.showNormal()
                frequencySensorsDialog.raise()
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
        }

        Button {
            text: "Voltage Sensors"
            onClicked: {
                voltageSensorsDialog.showNormal()
                voltageSensorsDialog.raise()
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
        }

        Button {
            text: "Heap"
            onClicked: {
                heapDialog.showNormal()
                heapDialog.raise()
            }

            ScalarListDialog {
                id: heapDialog
                title: "Heap"
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
        }

        Button {
            text: "Digital I/O"
            onClicked: {
                dioDialog.showNormal()
                dioDialog.raise()
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
        }

        Button {
            text: "Frequency Outputs"
            onClicked: {
                frequencyOutputDialog.showNormal()
                frequencyOutputDialog.raise()
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
        }

        Button {
            text: "PWM Drivers"
            enabled: true
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

        Button {
            text: "Switch Monitor"
            enabled: true
            onClicked: {
                switchMonitorWindow.showNormal()
                switchMonitorWindow.raise()
            }
            Window {
                id: switchMonitorWindow
                title: qsTr("Switch Monitor")
                width: 520
                height: 400

                RowLayout {
                    id: switchMonitorRowLayout
                    anchors.fill: parent
                    MultiroleTableParamEdit {
                        Layout.margins: 10
                        Layout.fillHeight: true
                        Layout.fillWidth: true

                        tableMetaParam: parameters.controllerSwitchMonitor
                        roleNames: ["x", "input", "output"]
                        label: ({"x": "Switch", "input": "Input", "output": "Output"})
                    }
                }

                AutoRefreshArea {
                    base: switchMonitorRowLayout
                }
            }
        }

        Button {
            text: qsTr("Pressures")
            onClicked: {
                pressureDialog.showNormal()
                pressureDialog.raise()
            }

            ScalarListDialog {
                id: pressureDialog
                title: qsTr("Pressures")
                paramLists: [
                    ScalarMetaParamList {
                        params: [
                            parameters.transmissionMainLinePressure,
                            parameters.transmissionTccPressure,
                            parameters.transmissionClutch1Pressure,
                            parameters.transmissionClutch2Pressure,
                            parameters.transmissionClutch3Pressure,
                            parameters.transmissionClutch4Pressure,
                            parameters.transmissionClutch5Pressure,
                            parameters.transmissionClutch6Pressure,
                            parameters.transmissionClutch7Pressure,
                            parameters.transmissionClutch8Pressure
                        ]
                    }
                ]
            }
        }

        Button {
            text: qsTr("Shaft Speeds")
            onClicked: {
                shaftSpeedsDialog.showNormal()
                shaftSpeedsDialog.raise()
            }

            ScalarListDialog {
                id: shaftSpeedsDialog
                title: qsTr("Shaft Speeds")
                paramLists: [
                    ScalarMetaParamList {
                        params: [
                            parameters.transmissionInputShaftSpeed,
                            parameters.transmissionTurbineShaftSpeed,
                            parameters.transmissionOutputShaftSpeed,
                            parameters.transmissionShaft1Speed,
                            parameters.transmissionShaft2Speed,
                            parameters.transmissionShaft3Speed,
                            parameters.transmissionShaft4Speed,
                            parameters.transmissionShaft5Speed,
                            parameters.transmissionShaft6Speed,
                            parameters.transmissionShaft7Speed,
                            parameters.transmissionShaft8Speed
                        ]
                    }
                ]
            }
        }

        Button {
            text: qsTr("Wheel Speeds")
            onClicked: {
                wheelSpeedsDialog.showNormal()
                wheelSpeedsDialog.raise()
            }

            ScalarListDialog {
                id: wheelSpeedsDialog
                title: qsTr("Wheel Speeds")
                paramLists: [
                    ScalarMetaParamList {
                        params: [
                            parameters.leftFrontWheelSpeed,
                            parameters.rightFrontWheelSpeed,
                            parameters.leftRearWheelSpeed,
                            parameters.rightRearWheelSpeed
                        ]
                    }
                ]
            }
        }

    }

    Flow {
        spacing: 10
        Layout.alignment: Qt.AlignLeft | Qt.AlignTop
        Layout.fillHeight: true
        GroupBox {
            enabled: parameters.controllerSoftwareVersionArray.valid
            title: "Software Version"
            TextField {
                text: parameters.controllerSoftwareVersion
                enabled: parameters.controllerSoftwareVersionArray.valid
                readOnly: true
                horizontalAlignment: TextInput.AlignLeft
            }
        }
    }
}
