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
                title: "Apply"

                RowLayout {
                    spacing: 8
                    TableParamEditButton {
                        Layout.margins: 0
                        text: "Torques"
                        xLabel: "Index"
                        valueLabel: "Torque"
                        tableParam: parameters.transmissionShiftApplyPressureTorque
                        hasPlot: true
                        hasShapers: true
                    }
                    TableByShiftEditMenuButton {
                        text: qsTr("Pressures")
                        xLabel: qsTr("Torque")
                        valueLabel: qsTr("Pressure")
                        tableParam: parameters.transmissionShiftApplyPressure
                    }
                }
            }
            GroupBox {
                title: "Release"

                RowLayout {
                    spacing: 8
                    TableParamEditButton {
                        Layout.margins: 0
                        text: "Torques"
                        xLabel: "Index"
                        valueLabel: "Torque"
                        tableParam: parameters.transmissionShiftReleasePressureTorque
                        hasPlot: true
                        hasShapers: true
                    }
                    TableByShiftEditMenuButton {
                        text: qsTr("Pressures")
                        xLabel: qsTr("Torque")
                        valueLabel: qsTr("Pressure")
                        tableParam: parameters.transmissionShiftReleasePressure
                    }
                }
            }
            GroupBox {
                title: "Main Line"

                RowLayout {
                    spacing: 8
                    TableParamEditButton {
                        Layout.margins: 0
                        text: "Torques"
                        xLabel: "Index"
                        valueLabel: "Torque"
                        tableParam: parameters.transmissionLinePressureTorque
                        hasPlot: true
                        hasShapers: true
                    }
                    TableByShiftEditMenuButton {
                        text: qsTr("Pressures")
                        xLabel: qsTr("Torque")
                        valueLabel: qsTr("Pressure")
                        tableParam: parameters.transmissionLinePressure
                    }
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
                            onClicked: {
                                prefillDialogPress.showNormal()
                                prefillDialogPress.raise()
                            }
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
                    onClicked: {
                        garageShiftDialog.showNormal()
                        garageShiftDialog.raise()
                    }
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
                        metaParam: parameters.garageShiftTime
                    }
                    ScalarParamSpinBox {
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
                        onClicked: {
                            prefillDialogPct.showNormal()
                            prefillDialogPct.raise()
                        }
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
                    onClicked: {
                        garageShiftDialogPct.showNormal()
                        garageShiftDialogPct.raise()
                    }
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
    GroupBox {
        title: "Common"
        Layout.alignment: Qt.AlignTop
        ColumnLayout {
            ScalarParamSpinBox {
                metaParam: parameters.pressureAdjustA
            }

            ScalarParamSpinBox {
                metaParam: parameters.pressureAdjustB
            }

            ScalarParamSpinBox {
                Layout.alignment: Qt.AlignTop
                metaParam: parameters.transmissionSTDownshiftTorqueThreshold
            }

            ScalarParamSpinBox {
                Layout.alignment: Qt.AlignTop
                metaParam: parameters.transmissionSTUpshiftTorqueThreshold
            }

            Button {
                text: "TS Torque Transfer Time"
                onClicked: {
                    tsTorqueTransferDialog.showNormal()
                    tsTorqueTransferDialog.raise()
                }
                enabled: tsTorqueTransferDialog.allListsAnyValid
            }
            ScalarListDialog {
                id: tsTorqueTransferDialog
                paramLists: [
                    parameters.transmissionTorqueSpeedTransferTime
                ]
            }

            Button {
                text: "ST Torque Transfer Time"
                onClicked: {
                    stTorqueTransferDialog.showNormal()
                    stTorqueTransferDialog.raise()
                }
                enabled: stTorqueTransferDialog.allListsAnyValid
            }
            ScalarListDialog {
                id: stTorqueTransferDialog
                paramLists: [
                    parameters.transmissionSpeedTorqueTransferTime
                ]
            }

            TableByShiftEditMenuButton {
                text: qsTr("Shift Torque Limits")
                xLabel: qsTr("Driver Torque")
                valueLabel: qsTr("Limit")
                tableParam: parameters.shiftTorqueLimits
            }
        }
    }
}


