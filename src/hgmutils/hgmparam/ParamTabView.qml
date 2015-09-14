import QtQuick 2.5
import QtQuick.Controls 1.4
import QtQuick.Layouts 1.2
import QtQuick.Window 2.2
import QtQuick.Dialogs 1.2
import com.hgmelectronics.setuptools.xcp 1.0
import com.hgmelectronics.setuptools 1.0

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

                TableByShiftEditButtonGroup {
                    title: qsTr("Shift Tables A")
                    count: 5
                    tableParam: parameters.shiftTablesA
                    xLabel: qsTr("Throttle")
                    valueLabel: qsTr("Speed")
                }

                TableByShiftEditButtonGroup {
                    title: qsTr("Shift Tables B")
                    count: 5
                    tableParam: parameters.shiftTablesB
                    xLabel: qsTr("Throttle")
                    valueLabel: qsTr("Speed")
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

