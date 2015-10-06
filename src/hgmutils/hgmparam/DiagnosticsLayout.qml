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

    GroupBox {
        title: "Bus Voltages"
        Column {
            spacing: 5
            ScalarParamEdit {
                metaParam: parameters.controllerBus5Voltage
            }
            ScalarParamEdit {
                metaParam: parameters.controllerBus3_3Voltage
            }
            ScalarParamEdit {
                metaParam: parameters.controllerBus1_8Voltage
            }
            ScalarParamEdit {
                metaParam: parameters.controllerBus12Voltage
            }
            ScalarParamEdit {
                metaParam: parameters.controllerBusVoltage
            }
        }
    }
    GroupBox {
        title: "Frequency Sensors"
        Column {
            spacing: 5
            ScalarParamEdit {
                metaParam: parameters.controllerTachInputFrequency
            }
            ScalarParamEdit {
                metaParam: parameters.controllerTissInputFrequency
            }
            ScalarParamEdit {
                metaParam: parameters.controllerTossInputFrequency
            }
            ScalarParamEdit {
                metaParam: parameters.controllerSpareInputFrequency
            }
        }
    }
    GroupBox {
        title: "Voltage Sensors"
        Column {
            spacing: 5
            ScalarParamEdit {
                metaParam: parameters.controllerThrottlePositionSensorVoltage
            }
            ScalarParamEdit {
                metaParam: parameters.controllerMAPSensorVoltage
            }
            ScalarParamEdit {
                metaParam: parameters.controllerInternalTemperatureSensorVoltage
            }
            //            ScalarParamEdit {
            //                metaParam: parameters.controllerInternalTemprature
            //            }
            ScalarParamEdit {
                metaParam: parameters.controllerEngineTempratureSensorVoltage
            }
            ScalarParamEdit {
                metaParam: parameters.controllerTransmissionTemperatureSensorVoltage
            }
            ScalarParamEdit {
                metaParam: parameters.controllerMultiplexedSensorVoltage
            }
        }
    }

    GroupBox {
        title: "Software"
        Column {
            spacing: 5
            ScalarParamEdit {
                metaParam: parameters.controllerHeapUsed
            }
            ScalarParamEdit {
                metaParam: parameters.controllerHeapSize
            }
            ScalarParamEdit {
                metaParam: parameters.controllerHeapAllocationCount
            }
            ScalarParamEdit {
                metaParam: parameters.controllerHeapReleaseCount
            }
        }
    }

    GroupBox {
        title: "Digital Outputs"
        Column {
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

    GroupBox {
        title: "Digital Inputs"
        Column {
            ScalarParamCheckBox {
                metaParam: parameters.controllerSDCardWriteProtect
            }
            ScalarParamCheckBox {
                metaParam: parameters.controllerSDCardPresent
            }
            ScalarParamCheckBox {
                metaParam: parameters.controllerMasterDriverFault
            }
            ScalarParamCheckBox {
                metaParam: parameters.controllerUSBPower
            }
        }
    }

    GroupBox {
        title: "Frequency Outputs"
        Column {
            spacing: 5
            ScalarParamSpinBox {
                metaParam: parameters.controllerSpeedTimer1Frequency
            }
            ScalarParamSpinBox {
                metaParam: parameters.controllerSpeedTimer2Frequency
            }
            Button {
                text: "PWM Drivers"
                enabled: parameters.controllerPWMDriverFrequency.range.valid
                onClicked: {
                    pwmDriversWindow.visible = true
                }
                PWMDriversWindow {
                    id: pwmDriversWindow
                    model: parameters.controllerPWMDriverModel
                }
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

