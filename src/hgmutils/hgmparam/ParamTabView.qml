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

            Flow {
                anchors.fill: parent
                anchors.margins: 10
                spacing: 10

                TableParamEditDialog {
                    id: shiftTable12Edit
                    name: "Shift Speed 1-2 A"
                    xLabel: "Throttle"
                    valueLabel: "Speed"
                    valueArray: parameters.shiftTablesAArray[0]
                    tableModel: parameters.shiftTablesA[0]
                }

                Button {
                    text: "Shift Speed 1-2 A"
                    onClicked: shiftTable12Edit.visible = true
                }

                TableParamEditDialog {
                    id: shiftTable23Edit
                    name: "Shift Speed 2-3 A"
                    xLabel: "Throttle"
                    valueLabel: "Speed"
                    valueArray: parameters.shiftTablesAArray[1]
                    tableModel: parameters.shiftTablesA[1]
                }

                Button {
                    text: "Shift Speed 2-3 A"
                    onClicked: shiftTable23Edit.visible = true
                }

                TableParamEditDialog {
                    id: shiftTable34Edit
                    name: "Shift Speed 3-4 A"
                    xLabel: "Throttle"
                    valueLabel: "Speed"
                    valueArray: parameters.shiftTablesAArray[2]
                    tableModel: parameters.shiftTablesA[2]
                }

                Button {
                    text: "Shift Speed 3-4 A"
                    onClicked: shiftTable34Edit.visible = true
                }

                TableParamEditDialog {
                    id: shiftTable45Edit
                    name: "Shift Speed 4-5 A"
                    xLabel: "Throttle"
                    valueLabel: "Speed"
                    valueArray: parameters.shiftTablesAArray[3]
                    tableModel: parameters.shiftTablesA[3]
                }

                Button {
                    text: "Shift Speed 4-5 A"
                    onClicked: shiftTable45Edit.visible = true
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
