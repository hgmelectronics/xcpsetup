import QtQuick 2.5
import QtQuick.Controls 1.4
import QtQuick.Layouts 1.2
import QtQuick.Window 2.2
import QtQuick.Dialogs 1.2
import com.hgmelectronics.setuptools.xcp 1.0
import com.hgmelectronics.setuptools 1.0
import com.hgmelectronics.setuptools.ui 1.0

ColumnLayout {
    property Parameters parameters
    anchors.fill: parent
    anchors.margins: 5
    spacing: 5

    RowLayout {
        Layout.fillHeight: true
        Layout.minimumHeight: 150
        TablePlot {
            id: shiftAPlot
            plots: [
                XYTrace {
                    tableModel: parameters.shiftTablesA[0].param.stringModel
                    valid: parameters.shiftTablesA[0].param.value.valid
                    baseColor: cs2Defaults.preferredPlotColors[0]
                    fill: false
                },
                XYTrace {
                    tableModel: parameters.shiftTablesA[1].param.stringModel
                    valid: parameters.shiftTablesA[1].param.value.valid
                    baseColor: cs2Defaults.preferredPlotColors[1]
                    fill: false
                },
                XYTrace {
                    tableModel: parameters.shiftTablesA[2].param.stringModel
                    valid: parameters.shiftTablesA[2].param.value.valid
                    baseColor: cs2Defaults.preferredPlotColors[2]
                    fill: false
                },
                XYTrace {
                    tableModel: parameters.shiftTablesA[3].param.stringModel
                    valid: parameters.shiftTablesA[3].param.value.valid
                    baseColor: cs2Defaults.preferredPlotColors[3]
                    fill: false
                },
                XYTrace {
                    tableModel: parameters.shiftTablesA[4].param.stringModel
                    valid: parameters.shiftTablesA[4].param.value.valid
                    baseColor: cs2Defaults.preferredPlotColors[4]
                    fill: false
                }
            ]
            visible: shiftASelectButton.checked
            Layout.fillWidth: true
            Layout.fillHeight: true
            anchors.bottom: parent.bottom
            anchors.top: parent.top
        }

        TablePlot {
            id: shiftBPlot
            plots: [
                XYTrace {
                    tableModel: parameters.shiftTablesB[0].param.stringModel
                    valid: parameters.shiftTablesB[0].param.value.valid
                    baseColor: cs2Defaults.preferredPlotColors[0]
                    fill: false
                },
                XYTrace {
                    tableModel: parameters.shiftTablesB[1].param.stringModel
                    valid: parameters.shiftTablesB[1].param.value.valid
                    baseColor: cs2Defaults.preferredPlotColors[1]
                    fill: false
                },
                XYTrace {
                    tableModel: parameters.shiftTablesB[2].param.stringModel
                    valid: parameters.shiftTablesB[2].param.value.valid
                    baseColor: cs2Defaults.preferredPlotColors[2]
                    fill: false
                },
                XYTrace {
                    tableModel: parameters.shiftTablesB[3].param.stringModel
                    valid: parameters.shiftTablesB[3].param.value.valid
                    baseColor: cs2Defaults.preferredPlotColors[3]
                    fill: false
                },
                XYTrace {
                    tableModel: parameters.shiftTablesB[4].param.stringModel
                    valid: parameters.shiftTablesB[4].param.value.valid
                    baseColor: cs2Defaults.preferredPlotColors[4]
                    fill: false
                }
            ]
            visible: shiftBSelectButton.checked
            Layout.fillWidth: true
            Layout.fillHeight: true
        }

        TablePlot {
            id: shiftABPlot
            plots: [
                XYTrace {
                    tableModel: parameters.shiftTablesA[0].param.stringModel
                    valid: parameters.shiftTablesA[0].param.value.valid
                    baseColor: cs2Defaults.preferredPlotColors[0]
                    fill: false
                },
                XYTrace {
                    tableModel: parameters.shiftTablesA[1].param.stringModel
                    valid: parameters.shiftTablesA[1].param.value.valid
                    baseColor: cs2Defaults.preferredPlotColors[1]
                    fill: false
                },
                XYTrace {
                    tableModel: parameters.shiftTablesA[2].param.stringModel
                    valid: parameters.shiftTablesA[2].param.value.valid
                    baseColor: cs2Defaults.preferredPlotColors[2]
                    fill: false
                },
                XYTrace {
                    tableModel: parameters.shiftTablesA[3].param.stringModel
                    valid: parameters.shiftTablesA[3].param.value.valid
                    baseColor: cs2Defaults.preferredPlotColors[3]
                    fill: false
                },
                XYTrace {
                    tableModel: parameters.shiftTablesA[4].param.stringModel
                    valid: parameters.shiftTablesA[4].param.value.valid
                    baseColor: cs2Defaults.preferredPlotColors[4]
                    fill: false
                },
                XYTrace {
                    tableModel: parameters.shiftTablesB[0].param.stringModel
                    valid: parameters.shiftTablesB[0].param.value.valid
                    baseColor: cs2Defaults.preferredPlotColors[5]
                    fill: false
                },
                XYTrace {
                    tableModel: parameters.shiftTablesB[1].param.stringModel
                    valid: parameters.shiftTablesB[1].param.value.valid
                    baseColor: cs2Defaults.preferredPlotColors[6]
                    fill: false
                },
                XYTrace {
                    tableModel: parameters.shiftTablesB[2].param.stringModel
                    valid: parameters.shiftTablesB[2].param.value.valid
                    baseColor: cs2Defaults.preferredPlotColors[7]
                    fill: false
                },
                XYTrace {
                    tableModel: parameters.shiftTablesB[3].param.stringModel
                    valid: parameters.shiftTablesB[3].param.value.valid
                    baseColor: cs2Defaults.preferredPlotColors[8]
                    fill: false
                },
                XYTrace {
                    tableModel: parameters.shiftTablesB[4].param.stringModel
                    valid: parameters.shiftTablesB[4].param.value.valid
                    baseColor: cs2Defaults.preferredPlotColors[9]
                    fill: false
                }
            ]
            visible: shiftABSelectButton.checked
            Layout.fillWidth: true
            Layout.fillHeight: true
        }

        ColumnLayout {
            ExclusiveGroup { id: shiftPlotSelectGroup }

            RadioButton {
                id: shiftASelectButton
                text: "A"
                checked: true
                exclusiveGroup: shiftPlotSelectGroup
                Layout.minimumWidth: 60
            }
            RadioButton {
                id: shiftBSelectButton
                text: "B"
                exclusiveGroup: shiftPlotSelectGroup
                Layout.minimumWidth: 60
            }
            RadioButton {
                id: shiftABSelectButton
                text: "A + B"
                exclusiveGroup: shiftPlotSelectGroup
                Layout.minimumWidth: 60
            }
        }

        TableParamView {
            xLabel: "Gear"
            valueLabel: "Ratio"
            xColumnWidth: 60
            valueColumnWidth: 60
            model: parameters.transmissionGearNumbersRatios.param.stringModel
        }
    }

    RowLayout {
        ShiftTableByShiftEditMenuButton {
            Layout.margins: 8
            text: qsTr("Shift Tables A")
            speedTableParams: parameters.shiftTablesA
            rpmTableParams: parameters.rpmShiftTablesA
            gearNumberRatioParam: parameters.transmissionGearNumbersRatios.param
        }

        ShiftTableByShiftEditMenuButton {
            Layout.margins: 8
            text: qsTr("Shift Tables B")
            speedTableParams: parameters.shiftTablesB
            rpmTableParams: parameters.rpmShiftTablesB
            gearNumberRatioParam: parameters.transmissionGearNumbersRatios.param
        }

        TableByShiftEditMenuButton {
            Layout.margins: 8
            text: qsTr("Shift Torque Limits")
            xLabel: qsTr("Driver Torque")
            valueLabel: qsTr("Limit")
            tableParam: parameters.shiftTorqueLimits
        }

        Button {
            text: "TS Torque Transfer Time"
            onClicked: tsTorqueTransferDialog.visible = true
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
            onClicked: stTorqueTransferDialog.visible = true
            enabled: stTorqueTransferDialog.allListsAnyValid
        }
        ScalarListDialog {
            id: stTorqueTransferDialog
            paramLists: [
                parameters.transmissionSpeedTorqueTransferTime
            ]
        }

    }

    RowLayout {


        ScalarParamSpinBox {
            Layout.alignment: Qt.AlignTop
            metaParam: parameters.reverseLockoutSpeed
        }
        ScalarParamSpinBox {
            Layout.alignment: Qt.AlignTop
            metaParam: parameters.transmissionDownshiftTypeTorqueThreshold
        }

    }


    RowLayout {
        spacing: 5
        ScalarParamSpinBox {
            metaParam: parameters.shiftSpeedAdjustA
        }
        ScalarParamSpinBox {
            metaParam: parameters.shiftDownshiftOffsetA
        }
        ScalarParamSpinBox {
            metaParam: parameters.shiftMaxEngineSpeedA
        }
        EncodingParamEdit {
            metaParam: parameters.shiftManualModeA
        }

        Layout.minimumHeight: 40
    }
    RowLayout {
        spacing: 5
        ScalarParamSpinBox {
            metaParam: parameters.shiftSpeedAdjustB
        }
        ScalarParamSpinBox {
            metaParam: parameters.shiftDownshiftOffsetB
        }
        ScalarParamSpinBox {
            metaParam: parameters.shiftMaxEngineSpeedB
        }
        EncodingParamEdit {
            metaParam: parameters.shiftManualModeB
        }

        Layout.minimumHeight: 40
    }
}
