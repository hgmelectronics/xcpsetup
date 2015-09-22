import QtQuick 2.5
import QtQuick.Controls 1.4
import QtQuick.Layouts 1.2
import QtQuick.Window 2.2
import QtQuick.Dialogs 1.2
import com.hgmelectronics.setuptools.xcp 1.0
import com.hgmelectronics.setuptools 1.0
import com.hgmelectronics.setuptools.ui 1.0

Flow {
    anchors.fill: parent
    anchors.margins: 10
    spacing: 10

    property Parameters parameters

    GroupBox {
        title: "Bus Voltages"
        Column {
            spacing: 10
            ScalarParamEdit {
                name: "5V Bus"
                param: parameters.controllerBus5Voltage
            }
            ScalarParamEdit {
                name: "3.3V Bus"
                param: parameters.controllerBus3_3Voltage
            }
            ScalarParamEdit {
                name: "1.8V Bus"
                param: parameters.controllerBus1_8Voltage
            }
            ScalarParamEdit {
                name: "12V Bus"
                param: parameters.controllerBus12Voltage
            }
            ScalarParamEdit {
                name: "Main bus"
                param: parameters.controllerBusVoltage
            }
        }
    }
    GroupBox {
        title: "Frequency Sensors"
        Column {
            spacing: 10
            ScalarParamEdit {
                name: "Tachometer"
                param: parameters.controllerTachInputFrequency
            }
            ScalarParamEdit {
                name: "TISS"
                param: parameters.controllerTissInputFrequency
            }
            ScalarParamEdit {
                name: "TOSS"
                param: parameters.controllerTossInputFrequency
            }
            ScalarParamEdit {
                name: "Spare"
                param: parameters.controllerSpareInputFrequency
            }
        }
    }
    GroupBox {
        title: "Voltage Sensors"
        Column {
            spacing: 10
            ScalarParamEdit {
                name: "Throttle Position"
                param: parameters.controllertThrottlePositionSensorVoltage
            }
            ScalarParamEdit {
                name: "MAP"
                param: parameters.controllerMAPSensorVoltage
            }
            ScalarParamEdit {
                name: "Inernal Temperature"
                param: parameters.controllerInternalTemperatureSensorVoltage
            }
            //            ScalarParamEdit {
            //                name: "Internal Temperature"
            //                param: parameters.controllerInternalTemprature
            //            }
            ScalarParamEdit {
                name: "Engine Temperature"
                param: parameters.controllerEngineTempratureSensorVoltage
            }
            ScalarParamEdit {
                name: "Transmission Temperature"
                param: parameters.controllerTransmissionTemperatureSensorVoltage
            }
            ScalarParamEdit {
                name: "Multiplex"
                param: parameters.controllerMultipltexedSensorVoltage
            }
        }
    }

    GroupBox {
        title: "Software"
        Column {
            spacing: 10
            ScalarParamEdit {
                name: "Heap Used"
                param: parameters.controllerHeapUsed
            }
            ScalarParamEdit {
                name: "Heap Size"
                param: parameters.controllerHeapSize
            }

            ScalarParamEdit {
                name: "Allocation Count"
                param: parameters.controllerHeapAllocationCount
            }
            ScalarParamEdit {
                name: "Release Count"
                param: parameters.controllerHeapReleaseCount
            }
        }
    }

    GroupBox {
        title: "Digital Inputs"
        Column {
            ScalarParamCheckBox {
                text: "Green LED"
                param: parameters.controllerGreenLED
            }
            ScalarParamCheckBox {
                name: "Red LED"
                param: parameters.controllerRedLED
            }
            ScalarParamCheckBox {
                name: "USB Connect"
                param: parameters.controllerUSBConnect
            }
            ScalarParamCheckBox {
                name: "Transmission Temperature Sensor Bias"
                param: parameters.controllerTransmissionTemperatureSensorBias
            }
            ScalarParamCheckBox {
                name: "Engine Temperature Sensor Bias"
                param: parameters.controllerEngineTemperatureSensorBias
            }
            ScalarParamCheckBox {
                name: "Throttle Position Sensor Ground"
                param: parameters.controllerThrottlePositionSensorGround
            }
            ScalarParamCheckBox {
                name: "MAP Sensor Ground"
                param: parameters.controllerMAPSensorGround
            }
        }
    }

    GroupBox {
        title: "Digital Outputs"
        Column {

            ScalarParamCheckBox {
                name: "SD Card Protect"
                param: parameters.controllerSDCardWriteProtect
            }
            ScalarParamCheckBox {
                name: "SD Card Present"
                param: parameters.controllerSDCardPresent
            }
            ScalarParamCheckBox {
                name: "Master Driver Fault"
                param: parameters.controllerMasterDriveFault
            }
            ScalarParamCheckBox {
                name: "USB Power"
                param: parameters.controllerUSBPower
            }
        }
    }

    GroupBox {
        title: "Frequency Outputs"
        Column {
            spacing: 10
            ScalarParamSpinBox {
                name: "Speed 1"
                param: parameters.controllerSpeedTimer1Frequency
            }
            ScalarParamSpinBox {
                name: "Speed 2"
                param: parameters.controllerSpeedTimer2Frequency
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
            TableParamEditButton {
                name: "controllerPwmDriverModeTable"
                tableParam: parameters.controllerPwmDriverModeTable
                hasPlot: false
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

