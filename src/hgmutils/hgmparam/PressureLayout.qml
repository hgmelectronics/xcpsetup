import QtQuick 2.5
import QtQuick.Controls 1.4
import QtQuick.Layouts 1.2
import QtQuick.Window 2.2
import QtQuick.Dialogs 1.2
import com.hgmelectronics.setuptools.xcp 1.0
import com.hgmelectronics.setuptools 1.0
import com.hgmelectronics.setuptools.ui 1.0

RowLayout {
    property Parameters parameters
    anchors.fill: parent
    anchors.margins: 5

    GroupBox {
        title: "Absolute"
        Layout.alignment: Qt.AlignTop
        ColumnLayout {
            GroupBox {
                title: "Upshift"

                RowLayout {
                    spacing: 8
                    TableByShiftEditMenuButton {
                        text: qsTr("Apply Pressure")
                        xLabel: qsTr("Torque")
                        valueLabel: qsTr("Pressure")
                        tableParam: parameters.transmissionUpshiftApplyPressure
                    }

                    TableByShiftEditMenuButton {
                        text: qsTr("Release Pressure")
                        xLabel: qsTr("Torque")
                        valueLabel: qsTr("Pressure")
                        tableParam: parameters.transmissionUpshiftReleasePressure
                    }
                }
            }

            GroupBox {
                title: "Downshift"

                RowLayout {
                    spacing: 8
                    TableByShiftEditMenuButton {
                        text: qsTr("Apply Pressure")
                        xLabel: qsTr("Torque")
                        valueLabel: qsTr("Pressure")
                        tableParam: parameters.transmissionDownshiftApplyPressure
                    }

                    TableByShiftEditMenuButton {
                        text: qsTr("Release Pressure")
                        xLabel: qsTr("Torque")
                        valueLabel: qsTr("Pressure")
                        tableParam: parameters.transmissionDownshiftReleasePressure
                    }
                }
            }

            GroupBox {
                title: "Main Pressure"
                TableByGearEditMenuButton {
                    text: qsTr("Edit")
                    xLabel: qsTr("Torque")
                    valueLabel: qsTr("Pressure")
                    tableParam: parameters.transmissionMainPressure
                }
            }

            GroupBox {
                title: "Prefill"
                ColumnLayout {
                    RowLayout {
                        spacing: 8
                        TableParamEditButton {
                            Layout.margins: 0
                            text: "Stroke Time"
                            xLabel: "Clutch"
                            tableParam: parameters.clutchStrokeTime
                            hasPlot: false
                            hasShapers: false
                            enabled: parameters.clutchStrokePressure.param.valid
                        }

                        TableParamEditButton {
                            Layout.margins: 0
                            text: "Stroke Pressure"
                            xLabel: "Clutch"
                            tableParam: parameters.clutchStrokePressure
                            hasPlot: false
                            hasShapers: false
                        }
                    }
                    RowLayout {
                        spacing: 8
                        TableParamEditButton {
                            Layout.margins: 0
                            text: "Prefill Time"
                            xLabel: "Clutch"
                            tableParam: parameters.clutchPrefillTime
                            hasPlot: false
                            hasShapers: false
                            enabled: parameters.clutchPrefillPressure.param.valid
                        }

                        TableParamEditButton {
                            Layout.margins: 0
                            text: "Prefill Pressure"
                            xLabel: "Clutch"
                            tableParam: parameters.clutchPrefillPressure
                            hasPlot: false
                            hasShapers: false
                        }
                        Button {
                            text: "By Shift"
                            onClicked: prefillDialogPress.visible = true
                            enabled: prefillDialogPress.allListsAnyValid
                        }
                    }
                }
            }

            ScalarListDialog {
                id: prefillDialogPress
                paramLists: [
                    parameters.transmissionShiftPrefillPressure,
                    parameters.transmissionShiftPrefillTime
                ]
            }

            GroupBox {
                title: "Release"
                RowLayout {
                    spacing: 8
                    TableParamEditButton {
                        Layout.margins: 0
                        text: "Time"
                        xLabel: "Clutch"
                        tableParam: parameters.clutchReleaseTime
                        hasPlot: false
                        hasShapers: false
                    }
                }
            }

            GroupBox {
                title: "Garage Shift"
                Button {
                    text: "Edit"
                    onClicked: garageShiftDialog.visible = true
                    enabled: parameters.garageShiftMaxPressure.param.valid || parameters.garageShiftProportionalConstant.param.valid
                }
            }
            Window {
                id: garageShiftDialog

                height: 25 + (stalkingHorse.implicitHeight + 5) * 7
                width: 35 + stalkingHorse.implicitWidth + 5

                ColumnLayout {
                    anchors.fill: parent
                    anchors.margins: 10

                    ScalarParamSpinBox {
                        id: stalkingHorse
                        metaParam: parameters.garageShiftMaxPressure
                    }
                    ScalarParamSpinBox {
                        metaParam: parameters.garageShiftProportionalConstant
                    }
                    ScalarParamSpinBox {
                        metaParam: parameters.garageShiftIntegralConstant
                    }
                    ScalarParamSpinBox {
                        metaParam: parameters.garageShiftDerivativeConstant
                    }
                }
            }
        }
    }
    GroupBox {
        title: "Percentage"
        Layout.alignment: Qt.AlignTop
        ColumnLayout {
            GroupBox {
                title: "Shift Pressure"

                RowLayout {
                    spacing: 8
                    TableByShiftEditMenuButton {
                        text: qsTr("A %")
                        xLabel: qsTr("Torque")
                        valueLabel: qsTr("%")
                        tableParam: parameters.pressureTablesA
                    }

                    TableByShiftEditMenuButton {
                        text: qsTr("B %")
                        xLabel: qsTr("Torque")
                        valueLabel: qsTr("%")
                        tableParam: parameters.pressureTablesB
                    }
                }
            }
            GroupBox {
                title: "Upshift"

                RowLayout {
                    spacing: 8
                    TableByShiftEditMenuButton {
                        text: qsTr("Apply Pressure %")
                        xLabel: qsTr("Torque")
                        valueLabel: qsTr("%")
                        tableParam: parameters.transmissionUpshiftApplyPercentage
                    }

                    TableByShiftEditMenuButton {
                        text: qsTr("Release Pressure %")
                        xLabel: qsTr("Torque")
                        valueLabel: qsTr("%")
                        tableParam: parameters.transmissionUpshiftReleasePercentage
                    }
                }
            }

            GroupBox {
                title: "Downshift"

                RowLayout {
                    spacing: 8
                    TableByShiftEditMenuButton {
                        text: qsTr("Apply Pressure %")
                        xLabel: qsTr("Torque")
                        valueLabel: qsTr("%")
                        tableParam: parameters.transmissionDownshiftApplyPercentage
                    }

                    TableByShiftEditMenuButton {
                        text: qsTr("Release Pressure %")
                        xLabel: qsTr("Torque")
                        valueLabel: qsTr("%")
                        tableParam: parameters.transmissionDownshiftReleasePercentage
                    }
                }
            }

            GroupBox {
                title: "Main Pressure %"
                TableByGearEditMenuButton {
                    text: qsTr("Edit")
                    xLabel: qsTr("Torque")
                    valueLabel: qsTr("%")
                    tableParam: parameters.transmissionMainPercentage
                }
            }

            GroupBox {
                title: "Prefill"
                RowLayout {
                    spacing: 8
                    TableParamEditButton {
                        Layout.margins: 0
                        text: "Time"
                        xLabel: "Clutch"
                        tableParam: parameters.clutchPrefillTime
                        hasPlot: false
                        hasShapers: false
                        enabled: parameters.clutchPrefillPercentage.param.valid
                    }

                    TableParamEditButton {
                        Layout.margins: 0
                        text: "Pressure"
                        xLabel: "Clutch"
                        valueLabel: qsTr("%")
                        tableParam: parameters.clutchPrefillPercentage
                        hasPlot: false
                        hasShapers: false
                    }
                    
                    Button {
                        text: "By Shift"
                        onClicked: prefillDialogPct.visible = true
                        enabled: prefillDialogPct.allListsAnyValid
                    }
                }
            }

            ScalarListDialog {
                id: prefillDialogPct
                paramLists: [
                    parameters.transmissionShiftPrefillPercentage,
                    parameters.transmissionShiftPrefillTime
                ]
            }

            GroupBox {
                title: "Garage Shift"
                Button {
                    text: "Edit"
                    onClicked: garageShiftDialogPct.visible = true
                    enabled: parameters.garageShiftMaxPercentage.param.valid || parameters.garageShiftProportionalConstant.param.valid
                }
            }
            Window {
                id: garageShiftDialogPct

                height: 25 + (stalkingHorse2.implicitHeight + 5) * 7
                width: 35 + stalkingHorse2.implicitWidth + 5

                ColumnLayout {
                    anchors.fill: parent
                    anchors.margins: 10

                    ScalarParamSpinBox {
                        id: stalkingHorse2
                        metaParam: parameters.garageShiftMaxPercentage
                    }
                    ScalarParamSpinBox {
                        metaParam: parameters.garageShiftProportionalConstant
                    }
                    ScalarParamSpinBox {
                        metaParam: parameters.garageShiftIntegralConstant
                    }
                    ScalarParamSpinBox {
                        metaParam: parameters.garageShiftDerivativeConstant
                    }
                }
            }
        }
    }
}
