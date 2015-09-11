import QtQuick 2.5
import QtQuick.Controls 1.4
import QtQuick.Layouts 1.2
import QtQuick.Window 2.2
import QtQuick.Dialogs 1.2
import com.hgmelectronics.setuptools.xcp 1.0
import com.hgmelectronics.setuptools 1.0

Item {
    id: root
    property ParamRegistry registry
    anchors.left: parent.left
    anchors.right: parent.right
    TabView {
        id: tabView
        anchors.fill: parent

        Parameters {
            id: parameters
            registry: root.registry
        }

        Tab {
            title: "Vehicle"
            active: true
            Flow {
                anchors.fill: parent
                anchors.margins: 10
                spacing: 10
                ScalarParamSpinBox {
                    name: "Final Drive Ratio"
                    param: parameters.finalDriveRatio
                }
                ScalarParamSpinBox {
                    name: "Tire Diameter"
                    param: parameters.tireDiameter
                }
                EncodingParamEdit {
                    name: "Display Units"
                    param: parameters.useMetricUnits
                }
                ScalarParamSpinBox {
                    name: "Display Brightness"
                    param: parameters.displayBrightness
                }
                ScalarParamSpinBox {
                    name: "Display Contrast"
                    param: parameters.displayContrast
                }
            }
        }

        Tab {
            title: "Engine"
            active: true
            Flow {
                anchors.fill: parent
                anchors.margins: 10
                spacing: 10

                ScalarParamSpinBox {
                    name: "Engine Cylinders"
                    param: parameters.engineCylinders
                }

                ScalarParamSpinBox {
                    name: "Max Engine Speed A"
                    param: parameters.shiftMaxEngineSpeedA
                }
                ScalarParamSpinBox {
                    name: "Max Engine Speed B"
                    param: parameters.shiftMaxEngineSpeedB
                }
            }
        }

        Tab {
            title: "Shift Tables"
            active: true

            Flow {
                anchors.fill: parent
                anchors.margins: 10
                spacing: 10

                TableByShiftEditButtonGroup {
                    title: "Shift Tables A"
                    count: 5
                    valueArray: parameters.shiftTablesAArray
                    tableModel: parameters.shiftTablesA
                    xLabel: "Throttle"
                    valueLabel: "Speed"
                }

                TableByShiftEditButtonGroup {
                    title: "Shift Tables B"
                    count: 5
                    valueArray: parameters.shiftTablesBArray
                    tableModel: parameters.shiftTablesB
                    xLabel: "Throttle"
                    valueLabel: "Speed"
                }

                Row {
                    spacing: 10
                    ScalarParamEdit {
                        name: "Downshift Offset A"
                        param: parameters.shiftDownshiftOffsetA
                    }
                    ScalarParamEdit {
                        name: "Downshift Offset A"
                        param: parameters.shiftDownshiftOffsetA
                    }
                }
            }
        }

        Tab {
            title: "Shift Pressure % Tables"

            active: true

            Flow {
                anchors.fill: parent
                anchors.margins: 10
                spacing: 10

                TableByGearEditButtonGroup {
                    title: "Shift Pressure A"
                    count: 6
                    valueArray: parameters.pressureTablesAArray
                    tableModel: parameters.pressureTablesA
                    xLabel: "Torque"
                    valueLabel: "%"
                }

                TableByGearEditButtonGroup {
                    title: "Shift Pressure B"
                    count: 6
                    valueArray: parameters.pressureTablesBArray
                    tableModel: parameters.pressureTablesB
                    xLabel: "Torque"
                    valueLabel: "%"
                }

                TableByShiftEditButtonGroup {
                    title: "Upshift Apply Pressure %"
                    count: 5
                    xLabel: "Torque"
                    valueLabel: "%"
                    valueArray: parameters.transmissionUpshiftApplyPercentageArray
                    tableModel: parameters.transmissionUpshiftApplyPercentage
                }

                TableByShiftEditButtonGroup {
                    title: "Downshift Apply Pressure %"
                    count: 4
                    isDownshift: true

                    xLabel: "Torque"
                    valueLabel: "%"
                    valueArray: parameters.transmissionDownshiftApplyPercentageArray
                    tableModel: parameters.transmissionDownshiftApplyPercentage
                }

                GroupBox {
                    title: "Shift Prefill"
                    Row {
                        spacing: 10
                        TableParamEditButton {
                            name: "Pressure"
                            xLabel: "Shift"
                            valueLabel: "%"
                            valueArray: parameters.transmissionShiftPrefillPercentageArray
                            tableModel: parameters.transmissionShiftPrefillPercentage
                        }

                        TableParamEditButton {
                            name: "Time"
                            xLabel: "Shift"
                            valueLabel: "ms"
                            valueArray: parameters.transmissionShiftPrefillTimeArray
                            tableModel: parameters.transmissionShiftPrefillTime
                        }
                    }
                }

                TableByGearEditButtonGroup {
                    title: "Main Pressure %"
                    count: 6
                    xLabel: "Torque"
                    valueLabel: "%"
                    valueArray: parameters.transmissionMainPercentageArray
                    tableModel: parameters.transmissionMainPercentage
                }
            }
        }

        Tab {
            title: "Shift Pressure Tables"
            active: true
            Flow {
                anchors.fill: parent
                anchors.margins: 10
                spacing: 10

                TableByShiftEditButtonGroup {
                    title: "Upshift Apply Pressure"
                    count: 5
                    xLabel: "Torque"
                    valueLabel: "Pressure"
                    valueArray: parameters.transmissionUpshiftApplyPressureArray
                    tableModel: parameters.transmissionUpshiftApplyPressure
                }

                TableByShiftEditButtonGroup {
                    title: "Upshift Apply Pressure"
                    count: 5
                    xLabel: "Torque"
                    valueLabel: "Pressure"
                    valueArray: parameters.transmissionUpshiftApplyPressureArray
                    tableModel: parameters.transmissionUpshiftApplyPressure
                }

                TableByShiftEditButtonGroup {
                    title: "Downshift Apply Pressure"
                    count: 4
                    isDownshift: true

                    xLabel: "Torque"
                    valueLabel: "Pressure"
                    valueArray: parameters.transmissionDownshiftApplyPressureArray
                    tableModel: parameters.transmissionDownshiftApplyPressure
                }

                GroupBox {
                    title: "Shift Prefill"
                    Row {
                        spacing: 10
                        TableParamEditButton {
                            name: "Pressure"
                            xLabel: "Shift"
                            valueLabel: "Pressure"
                            valueArray: parameters.transmissionShiftPrefillPressureArray
                            tableModel: parameters.transmissionShiftPrefillPressure
                        }

                        TableParamEditButton {
                            name: "Time"
                            xLabel: "Shift"
                            valueLabel: "ms"
                            valueArray: parameters.transmissionShiftPrefillTimeArray
                            tableModel: parameters.transmissionShiftPrefillTime
                        }
                    }
                }

                TableByGearEditButtonGroup {
                    title: "Main Pressure"
                    count: 6
                    xLabel: "Torque"
                    valueLabel: "Pressure"
                    valueArray: parameters.transmissionMainPressureArray
                    tableModel: parameters.transmissionMainPressure
                }
            }
        }
    }
}
//        Tab {
//            title: "Inputs"
//            active: true
//            Flow {
//                anchors.fill: parent
//                anchors.margins: 10
//                spacing: 10
//                TableParamView {
//                    name: "Switch Monitor Input"
//                    xLabel: "Switch #"
//                    valueLabel: "State"
//                    tableModel: parameters.switchMonitorModel
//                    enabled: parameters.switchMonitorInput.valid
//                }
//            }
//        }

