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

                GroupBox {
                    title: "Shift Tables A"
                    Row {
                        spacing: 10
                        Repeater {
                            model: 5

                            TableParamEditButton {
                                function getTitle(i) {
                                    var first = i + 1
                                    var second = i + 2
                                    return "Shift " + first + "-" + second
                                }

                                name: getTitle(index)
                                xLabel: "Throttle"
                                valueLabel: "Speed"
                                valueArray: parameters.shiftTablesAArray[index]
                                tableModel: parameters.shiftTablesA[index]
                            }
                        }
                    }
                }

                GroupBox {
                    title: "Shift Tables B"
                    Row {
                        spacing: 10
                        Repeater {
                            model: 5

                            TableParamEditButton {
                                function getTitle(i) {
                                    var first = i + 1
                                    var second = i + 2
                                    return "Shift " + first + "-" + second
                                }

                                name: getTitle(index)
                                xLabel: "Throttle"
                                valueLabel: "Speed"
                                valueArray: parameters.shiftTablesBArray[index]
                                tableModel: parameters.shiftTablesB[index]
                            }
                        }
                    }
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
            title: "Shift Pressure Tables"

            active: true

            Flow {
                anchors.fill: parent
                anchors.margins: 10
                spacing: 10

                //                GroupBox {
                //                    id: shiftPressureGroupA
                //                    title: "Shift Pressure A"
                //                    Row {
                //                        spacing: 10

                //                        Repeater {
                //                            model: 4

                //                            TableParamEditButton {
                //                                function createTitle(index) {
                //                                    var first = index + 1
                //                                    var second = index + 2
                //                                    return shiftPressureGroupA.title + first + "-" + second
                //                                }
                //                                name: createTitle(index)
                //                                xLabel: "Torque"
                //                                valueLabel: "Pressure"
                //                                valueArray: parameters.pressureTablesAArray[index]
                //                                tableModel: parameters.pressureTablesA[index]
                //                            }
                //                        }
                //                    }
                //                }

                //                GroupBox {
                //                    id: shiftPressureGroupB
                //                    title: "Shift Pressure B"
                //                    Row {
                //                        spacing: 10

                //                        Repeater {
                //                            model: 4

                //                            TableParamEditButton {
                //                                function createTitle(index) {
                //                                    var first = index + 1
                //                                    var second = index + 2
                //                                    return "Shift Pressure " + first + "-" + second + "A"
                //                                }
                //                                name: createTitle(index)
                //                                xLabel: "Torque"
                //                                valueLabel: "Pressure"
                //                                valueArray: parameters.pressureTablesAArray[index]
                //                                tableModel: parameters.pressureTablesA[index]
                //                            }
                //                        }
                //                    }
                //                }
                GroupBox {
                    title: "Upshift Apply Pressure"
                    Row {
                        spacing: 10

                        Repeater {
                            model: 5

                            TableParamEditButton {
                                function getTitle(i) {
                                    var first = i
                                    var second = i + 1
                                    return "Shift " + first + "-" + second
                                }
                                name: getTitle(index)
                                xLabel: "Torque"
                                valueLabel: "Pressure"
                                valueArray: parameters.transmissionUpshiftApplyPressureArray[index]
                                tableModel: parameters.transmissionUpshiftApplyPressure[index]
                            }
                        }
                    }
                }

                GroupBox {
                    title: "Downshift Apply Pressure"
                    Row {
                        spacing: 10

                        Repeater {
                            model: 4

                            TableParamEditButton {
                                function getTitle(i) {
                                    var first = i + 2
                                    var second = i + 1
                                    return "Shift " + first + "-" + second
                                }
                                name: getTitle(index)
                                xLabel: "Torque"
                                valueLabel: "Pressure"
                                valueArray: parameters.transmissionDownshiftApplyPressureArray[index]
                                tableModel: parameters.transmissionDownshiftApplyPressure[index]
                            }
                        }
                    }
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

                GroupBox {
                    title: "Line Pressure"
                    Row {
                        spacing: 10

                        Repeater {
                            model: 5

                            TableParamEditButton {
                                function getTitle() {
                                    var first = index + 1
                                    return "Gear " + first
                                }
                                name: getTitle()
                                xLabel: "Torque"
                                valueLabel: "Pressure"
                                valueArray: parameters.transmissionMainPressureArray[index]
                                tableModel: parameters.transmissionMainPressure[index]
                            }
                        }
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
}
