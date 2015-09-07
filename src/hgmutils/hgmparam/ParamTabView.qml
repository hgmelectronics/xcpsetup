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
            id: shiftTableTab
            title: "Shift Tables"
            active: true
            property int spacing: 0
            property int margins: 10

            ScrollView {
                anchors.fill: parent
                verticalScrollBarPolicy: Qt.ScrollBarAlwaysOn
                GridLayout {
                    columnSpacing: spacing
                    rowSpacing: spacing
                    columns: 3

                    TableView {
                        Layout.columnSpan: 3
                        Layout.margins: margins
                        Layout.minimumWidth: 600

                        model: parameters.shiftTablesAModel

                        TableViewColumn {
                            role: "tps"
                            title: "TPS %"
                            width: 100
                        }
                        TableViewColumn {
                            role: "shift12"
                            title: "Shift 1-2"
                            width: 100
                        }
                        TableViewColumn {
                            role: "shift23"
                            title: "Shift 2-3"
                            width: 100
                        }
                        TableViewColumn {
                            role: "shift34"
                            title: "Shift 3-4"
                            width: 100
                        }
                        TableViewColumn {
                            role: "shift45"
                            title: "Shift 4-5"
                            width: 100
                        }
                    }

                    Row {
                        visible: false
                        Layout.columnSpan: 3
                        Layout.margins: margins
                        spacing: 10
                        id: buttonRow

                        function bump(p) {
                            for (var i = 0; i < p.count; i++) {
                                p.set(i, p.get(i) + 1.0)
                            }
                        }

                        function zero(p) {
                            for (var i = 0; i < p.count; i++) {
                                p.set(i, 0.0)
                            }
                        }

                        Button {
                            text: "Zero"
                            onClicked: {
                                buttonRow.zero(parameters.shiftTablesAArray[0])
                                buttonRow.zero(parameters.shiftTablesAArray[1])
                                buttonRow.zero(parameters.shiftTablesAArray[2])
                                buttonRow.zero(parameters.shiftTablesAArray[3])
                            }
                        }

                        Button {
                            text: "Bump 1-2"
                            onClicked: {
                                buttonRow.bump(parameters.shiftTablesAArray[0])
                            }
                        }

                        Button {
                            text: "Bump 2-3"
                            onClicked: {
                                buttonRow.bump(parameters.shiftTablesAArray[1])
                            }
                        }

                        Button {
                            text: "Bump 3-4"
                            onClicked: {
                                buttonRow.bump(parameters.shiftTablesAArray[2])
                            }
                        }

                        Button {
                            text: "Bump 4-5"
                            onClicked: {
                                buttonRow.bump(parameters.shiftTablesAArray[3])
                            }
                        }
                    }

                    TableParamEdit {
                        id: shift12
                        Layout.margins: margins
                        name: "Shift Speed 1-2 A"
                        xLabel: "Throttle"
                        valueLabel: "Speed"
                        tableModel: parameters.shiftTablesA[0]
                        enabled: parameters.shiftTablesAArray[0].valid
                    }

                    TableParamEdit {
                        name: "Shift Speed 2-3 A"
                        Layout.margins: margins
                        xLabel: "Throttle"
                        valueLabel: "Speed"
                        tableModel: parameters.shiftTablesA[1]
                        enabled: parameters.shiftTablesAArray[1].valid
                    }

                    TableParamEdit {
                        name: "Shift Speed 3-4 A"
                        Layout.margins: margins
                        xLabel: "Throttle"
                        valueLabel: "Speed"
                        tableModel: parameters.shiftTablesA[2]
                        enabled: parameters.shiftTablesAArray[2].valid
                    }
                    TableParamEdit {
                        name: "Shift Speed 4-5 A"
                        Layout.margins: margins
                        xLabel: "Throttle"
                        valueLabel: "Speed"
                        tableModel: parameters.shiftTablesA[3]
                        enabled: parameters.shiftTablesAArray[3].valid
                    }
                }
            }
        }

        Tab {
            title: "Inputs"
            active: true
            Flow {
                anchors.fill: parent
                anchors.margins: 10
                spacing: 10
//                TableParamView {
//                    name: "Switch Monitor Input"
//                    xLabel: "Switch #"
//                    valueLabel: "State"
//                    tableModel: parameters.switchMonitorModel
//                    enabled: parameters.switchMonitorInput.valid
//                }
                EncodingParamEdit {
                    name: "Display Units"
                    param: parameters.useMetricUnits
                }
            }
        }

        Tab {
            title: "Accessories"
            active: true
            Flow {
                anchors.fill: parent
                anchors.margins: 10
                spacing: 10

                ScalarParamSpinBox {
                    // duplicate to illustrate binding
                    name: "Display Brightness"
                    param: parameters.displayBrightness
                }

                ScalarParamSpinBox {
                    // duplicate to illustrate binding
                    name: "Display Contrast"
                    param: parameters.displayBrightness
                }
            }
        }
    }
}
