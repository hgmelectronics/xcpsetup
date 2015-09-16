import QtQuick 2.5
import QtQuick.Controls 1.4
import QtQuick.Layouts 1.2
import QtQuick.Window 2.2
import QtQuick.Dialogs 1.2
import com.hgmelectronics.setuptools.xcp 1.0
import com.hgmelectronics.setuptools 1.0
import com.hgmelectronics.setuptools.ui 1.0

Item {
    id: root
    property alias useMetricUnits: parameters.useMetricUnits
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
            title: qsTr("Vehicle")
            active: true
            Flow {
                anchors.fill: parent
                anchors.margins: 10
                spacing: 10
                ScalarParamSpinBox {
                    name: qsTr("Final Drive Ratio")
                    param: parameters.finalDriveRatio
                }
                ScalarParamSpinBox {
                    name: qsTr("Tire Diameter")
                    param: parameters.tireDiameter
                }
                EncodingParamEdit {
                    name: qsTr("Display Units")
                    param: parameters.displayUnits
                }
                ScalarParamSpinBox {
                    name: qsTr("Display Brightness")
                    param: parameters.displayBrightness
                }
                ScalarParamSpinBox {
                    name: qsTr("Display Contrast")
                    param: parameters.displayContrast
                }
            }
        }

        Tab {
            title: qsTr("Engine")
            active: true
            Flow {
                anchors.fill: parent
                anchors.margins: 10
                spacing: 10

                ScalarParamSpinBox {
                    name: qsTr("Engine Cylinders")
                    param: parameters.engineCylinders
                }

                ScalarParamSpinBox {
                    name: qsTr("Max Engine Speed A")
                    param: parameters.shiftMaxEngineSpeedA
                }
                ScalarParamSpinBox {
                    name: qsTr("Max Engine Speed B")
                    param: parameters.shiftMaxEngineSpeedB
                }
            }
        }

        Tab {
            title: qsTr("Shift Tables")
            active: true

            Flow {
                anchors.fill: parent
                anchors.margins: 10
                spacing: 10

                TablePlot {
                    width: 400
                    height: 200
                    plots: [
                        XYTrace {
                            tableModel: parameters.shiftTablesA[0].stringModel
                            valid: parameters.shiftTablesA[0].value.valid
                            baseColor: cs2Defaults.preferredPlotColors[0]
                            fill: false
                        },
                        XYTrace {
                            tableModel: parameters.shiftTablesA[1].stringModel
                            valid: parameters.shiftTablesA[1].value.valid
                            baseColor: cs2Defaults.preferredPlotColors[1]
                            fill: false
                        },
                        XYTrace {
                            tableModel: parameters.shiftTablesA[2].stringModel
                            valid: parameters.shiftTablesA[2].value.valid
                            baseColor: cs2Defaults.preferredPlotColors[2]
                            fill: false
                        },
                        XYTrace {
                            tableModel: parameters.shiftTablesA[3].stringModel
                            valid: parameters.shiftTablesA[3].value.valid
                            baseColor: cs2Defaults.preferredPlotColors[3]
                            fill: false
                        },
                        XYTrace {
                            tableModel: parameters.shiftTablesA[4].stringModel
                            valid: parameters.shiftTablesA[4].value.valid
                            baseColor: cs2Defaults.preferredPlotColors[4]
                            fill: false
                        }
                    ]
                }

                ShiftTableByShiftEditButtonGroup {
                    title: qsTr("Shift Tables A")
                    tableParams: parameters.shiftTablesA
                    gearRatioParams: parameters.transmissionGearRatios
                    rpmSlot: parameters.slots.rpm1
                }

                ShiftTableByShiftEditButtonGroup {
                    title: qsTr("Shift Tables B")
                    tableParams: parameters.shiftTablesB
                    gearRatioParams: parameters.transmissionGearRatios
                    rpmSlot: parameters.slots.rpm1
                }

                Row {
                    spacing: 10
                    ScalarParamSpinBox {
                        name: qsTr("Downshift Offset A")
                        param: parameters.shiftDownshiftOffsetA
                    }
                    ScalarParamSpinBox {
                        name: qsTr("Downshift Offset B")
                        param: parameters.shiftDownshiftOffsetB
                    }
                }
            }
        }

        Tab {
            title: qsTr("Shift Pressure % Tables")

            active: true

            Flow {
                anchors.fill: parent
                anchors.margins: 10
                spacing: 10

                TableByGearEditButtonGroup {
                    title: qsTr("Shift Pressure A")
                    count: 6
                    tableParam: parameters.pressureTablesA
                    xLabel: qsTr("Torque")
                    valueLabel: qsTr("%")
                }

                TableByGearEditButtonGroup {
                    title: qsTr("Shift Pressure B")
                    count: 6
                    tableParam: parameters.pressureTablesB
                    xLabel: qsTr("Torque")
                    valueLabel: qsTr("%")
                }

                TableByShiftEditButtonGroup {
                    title: qsTr("Upshift Apply Pressure %")
                    count: 5
                    xLabel: qsTr("Torque")
                    valueLabel: qsTr("%")
                    tableParam: parameters.transmissionUpshiftApplyPercentage
                }

                TableByShiftEditButtonGroup {
                    title: qsTr("Downshift Apply Pressure %")
                    count: 4
                    isDownshift: true

                    xLabel: qsTr("Torque")
                    valueLabel: qsTr("%")
                    tableParam: parameters.transmissionDownshiftApplyPercentage
                }

                GroupBox {
                    title: qsTr("Shift Prefill")
                    Row {
                        spacing: 10
                        TableParamEditButton {
                            name: qsTr("Pressure")
                            xLabel: qsTr("Shift")
                            valueLabel: qsTr("%")
                            tableParam: parameters.transmissionShiftPrefillPercentage
                        }

                        TableParamEditButton {
                            name: qsTr("Time")
                            xLabel: qsTr("Shift")
                            valueLabel: qsTr("ms")
                            tableParam: parameters.transmissionShiftPrefillTime
                        }
                    }
                }

                TableByGearEditButtonGroup {
                    title: qsTr("Main Pressure %")
                    count: 6
                    xLabel: qsTr("Torque")
                    valueLabel: qsTr("%")
                    tableParam: parameters.transmissionMainPercentage
                }
            }
        }

        Tab {
            title: qsTr("Shift Pressure Tables")
            active: true
            Flow {
                anchors.fill: parent
                anchors.margins: 10
                spacing: 10

                TableByShiftEditButtonGroup {
                    title: qsTr("Upshift Apply Pressure")
                    count: 5
                    xLabel: qsTr("Torque")
                    valueLabel: qsTr("Pressure")
                    tableParam: parameters.transmissionUpshiftApplyPressure
                }

                TableByShiftEditButtonGroup {
                    title: qsTr("Upshift Apply Pressure")
                    count: 5
                    xLabel: qsTr("Torque")
                    valueLabel: qsTr("Pressure")
                    tableParam: parameters.transmissionUpshiftApplyPressure
                }

                TableByShiftEditButtonGroup {
                    title: qsTr("Downshift Apply Pressure")
                    count: 4
                    isDownshift: true

                    xLabel: qsTr("Torque")
                    valueLabel: qsTr("Pressure")
                    tableParam: parameters.transmissionDownshiftApplyPressure
                }

                GroupBox {
                    title: qsTr("Shift Prefill")
                    Row {
                        spacing: 10
                        TableParamEditButton {
                            name: qsTr("Pressure")
                            xLabel: qsTr("Shift")
                            valueLabel: qsTr("Pressure")
                            tableParam: parameters.transmissionShiftPrefillPressure
                        }

                        TableParamEditButton {
                            name: qsTr("Time")
                            xLabel: qsTr("Shift")
                            valueLabel: qsTr("ms")
                            tableParam: parameters.transmissionShiftPrefillTime
                        }
                    }
                }

                TableByGearEditButtonGroup {
                    title: qsTr("Main Pressure")
                    count: 6
                    xLabel: qsTr("Torque")
                    valueLabel: qsTr("Pressure")
                    tableParam: parameters.transmissionMainPressure
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

