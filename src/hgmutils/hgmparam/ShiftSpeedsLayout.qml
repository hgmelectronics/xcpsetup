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
                    tableModel: parameters.upshiftTablesA[0].param.stringModel
                    valid: parameters.upshiftTablesA[0].param.value.valid
                    baseColor: cs2Defaults.preferredPlotColors[0]
                    fill: false
                },
                XYTrace {
                    tableModel: parameters.upshiftTablesA[1].param.stringModel
                    valid: parameters.upshiftTablesA[1].param.value.valid
                    baseColor: cs2Defaults.preferredPlotColors[1]
                    fill: false
                },
                XYTrace {
                    tableModel: parameters.upshiftTablesA[2].param.stringModel
                    valid: parameters.upshiftTablesA[2].param.value.valid
                    baseColor: cs2Defaults.preferredPlotColors[2]
                    fill: false
                },
                XYTrace {
                    tableModel: parameters.upshiftTablesA[3].param.stringModel
                    valid: parameters.upshiftTablesA[3].param.value.valid
                    baseColor: cs2Defaults.preferredPlotColors[3]
                    fill: false
                },
                XYTrace {
                    tableModel: parameters.upshiftTablesA[4].param.stringModel
                    valid: parameters.upshiftTablesA[4].param.value.valid
                    baseColor: cs2Defaults.preferredPlotColors[4]
                    fill: false
                },
                XYTrace {
                    tableModel: parameters.downshiftTablesA[0].param.stringModel
                    valid: parameters.downshiftTablesA[0].param.value.valid && (parameters.shiftTablesDownLockedA.param.floatVal == 0)
                    baseColor: cs2Defaults.preferredPlotColors[5]
                    fill: false
                },
                XYTrace {
                    tableModel: parameters.downshiftTablesA[1].param.stringModel
                    valid: parameters.downshiftTablesA[1].param.value.valid && (parameters.shiftTablesDownLockedA.param.floatVal == 0)
                    baseColor: cs2Defaults.preferredPlotColors[6]
                    fill: false
                },
                XYTrace {
                    tableModel: parameters.downshiftTablesA[2].param.stringModel
                    valid: parameters.downshiftTablesA[2].param.value.valid && (parameters.shiftTablesDownLockedA.param.floatVal == 0)
                    baseColor: cs2Defaults.preferredPlotColors[7]
                    fill: false
                },
                XYTrace {
                    tableModel: parameters.downshiftTablesA[3].param.stringModel
                    valid: parameters.downshiftTablesA[3].param.value.valid && (parameters.shiftTablesDownLockedA.param.floatVal == 0)
                    baseColor: cs2Defaults.preferredPlotColors[8]
                    fill: false
                },
                XYTrace {
                    tableModel: parameters.downshiftTablesA[4].param.stringModel
                    valid: parameters.downshiftTablesA[4].param.value.valid && (parameters.shiftTablesDownLockedA.param.floatVal == 0)
                    baseColor: cs2Defaults.preferredPlotColors[9]
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
                    tableModel: parameters.upshiftTablesB[0].param.stringModel
                    valid: parameters.upshiftTablesB[0].param.value.valid
                    baseColor: cs2Defaults.preferredPlotColors[0]
                    fill: false
                },
                XYTrace {
                    tableModel: parameters.upshiftTablesB[1].param.stringModel
                    valid: parameters.upshiftTablesB[1].param.value.valid
                    baseColor: cs2Defaults.preferredPlotColors[1]
                    fill: false
                },
                XYTrace {
                    tableModel: parameters.upshiftTablesB[2].param.stringModel
                    valid: parameters.upshiftTablesB[2].param.value.valid
                    baseColor: cs2Defaults.preferredPlotColors[2]
                    fill: false
                },
                XYTrace {
                    tableModel: parameters.upshiftTablesB[3].param.stringModel
                    valid: parameters.upshiftTablesB[3].param.value.valid
                    baseColor: cs2Defaults.preferredPlotColors[3]
                    fill: false
                },
                XYTrace {
                    tableModel: parameters.upshiftTablesB[4].param.stringModel
                    valid: parameters.upshiftTablesB[4].param.value.valid
                    baseColor: cs2Defaults.preferredPlotColors[4]
                    fill: false
                },
                XYTrace {
                    tableModel: parameters.downshiftTablesB[0].param.stringModel
                    valid: parameters.downshiftTablesB[0].param.value.valid && (parameters.shiftTablesDownLockedB.param.floatVal == 0)
                    baseColor: cs2Defaults.preferredPlotColors[5]
                    fill: false
                },
                XYTrace {
                    tableModel: parameters.downshiftTablesB[1].param.stringModel
                    valid: parameters.downshiftTablesB[1].param.value.valid && (parameters.shiftTablesDownLockedB.param.floatVal == 0)
                    baseColor: cs2Defaults.preferredPlotColors[6]
                    fill: false
                },
                XYTrace {
                    tableModel: parameters.downshiftTablesB[2].param.stringModel
                    valid: parameters.downshiftTablesB[2].param.value.valid && (parameters.shiftTablesDownLockedB.param.floatVal == 0)
                    baseColor: cs2Defaults.preferredPlotColors[7]
                    fill: false
                },
                XYTrace {
                    tableModel: parameters.downshiftTablesB[3].param.stringModel
                    valid: parameters.downshiftTablesB[3].param.value.valid && (parameters.shiftTablesDownLockedB.param.floatVal == 0)
                    baseColor: cs2Defaults.preferredPlotColors[8]
                    fill: false
                },
                XYTrace {
                    tableModel: parameters.downshiftTablesB[4].param.stringModel
                    valid: parameters.downshiftTablesB[4].param.value.valid && (parameters.shiftTablesDownLockedB.param.floatVal == 0)
                    baseColor: cs2Defaults.preferredPlotColors[9]
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
                    tableModel: parameters.upshiftTablesA[0].param.stringModel
                    valid: parameters.upshiftTablesA[0].param.value.valid
                    baseColor: cs2Defaults.preferredPlotColors[0]
                    fill: false
                },
                XYTrace {
                    tableModel: parameters.upshiftTablesA[1].param.stringModel
                    valid: parameters.upshiftTablesA[1].param.value.valid
                    baseColor: cs2Defaults.preferredPlotColors[1]
                    fill: false
                },
                XYTrace {
                    tableModel: parameters.upshiftTablesA[2].param.stringModel
                    valid: parameters.upshiftTablesA[2].param.value.valid
                    baseColor: cs2Defaults.preferredPlotColors[2]
                    fill: false
                },
                XYTrace {
                    tableModel: parameters.upshiftTablesA[3].param.stringModel
                    valid: parameters.upshiftTablesA[3].param.value.valid
                    baseColor: cs2Defaults.preferredPlotColors[3]
                    fill: false
                },
                XYTrace {
                    tableModel: parameters.upshiftTablesA[4].param.stringModel
                    valid: parameters.upshiftTablesA[4].param.value.valid
                    baseColor: cs2Defaults.preferredPlotColors[4]
                    fill: false
                },
                XYTrace {
                    tableModel: parameters.upshiftTablesB[0].param.stringModel
                    valid: parameters.upshiftTablesB[0].param.value.valid
                    baseColor: cs2Defaults.preferredPlotColors[5]
                    fill: false
                },
                XYTrace {
                    tableModel: parameters.upshiftTablesB[1].param.stringModel
                    valid: parameters.upshiftTablesB[1].param.value.valid
                    baseColor: cs2Defaults.preferredPlotColors[6]
                    fill: false
                },
                XYTrace {
                    tableModel: parameters.upshiftTablesB[2].param.stringModel
                    valid: parameters.upshiftTablesB[2].param.value.valid
                    baseColor: cs2Defaults.preferredPlotColors[7]
                    fill: false
                },
                XYTrace {
                    tableModel: parameters.upshiftTablesB[3].param.stringModel
                    valid: parameters.upshiftTablesB[3].param.value.valid
                    baseColor: cs2Defaults.preferredPlotColors[8]
                    fill: false
                },
                XYTrace {
                    tableModel: parameters.upshiftTablesB[4].param.stringModel
                    valid: parameters.upshiftTablesB[4].param.value.valid
                    baseColor: cs2Defaults.preferredPlotColors[9]
                    fill: false
                },
                XYTrace {
                    tableModel: parameters.downshiftTablesA[0].param.stringModel
                    valid: parameters.downshiftTablesA[0].param.value.valid && (parameters.shiftTablesDownLockedA.param.floatVal == 0)
                    baseColor: cs2Defaults.preferredPlotColors[10]
                    fill: false
                },
                XYTrace {
                    tableModel: parameters.downshiftTablesA[1].param.stringModel
                    valid: parameters.downshiftTablesA[1].param.value.valid && (parameters.shiftTablesDownLockedA.param.floatVal == 0)
                    baseColor: cs2Defaults.preferredPlotColors[11]
                    fill: false
                },
                XYTrace {
                    tableModel: parameters.downshiftTablesA[2].param.stringModel
                    valid: parameters.downshiftTablesA[2].param.value.valid && (parameters.shiftTablesDownLockedA.param.floatVal == 0)
                    baseColor: cs2Defaults.preferredPlotColors[12]
                    fill: false
                },
                XYTrace {
                    tableModel: parameters.downshiftTablesA[3].param.stringModel
                    valid: parameters.downshiftTablesA[3].param.value.valid && (parameters.shiftTablesDownLockedA.param.floatVal == 0)
                    baseColor: cs2Defaults.preferredPlotColors[13]
                    fill: false
                },
                XYTrace {
                    tableModel: parameters.downshiftTablesA[4].param.stringModel
                    valid: parameters.downshiftTablesA[4].param.value.valid && (parameters.shiftTablesDownLockedA.param.floatVal == 0)
                    baseColor: cs2Defaults.preferredPlotColors[14]
                    fill: false
                },
                XYTrace {
                    tableModel: parameters.downshiftTablesB[0].param.stringModel
                    valid: parameters.downshiftTablesB[0].param.value.valid && (parameters.shiftTablesDownLockedB.param.floatVal == 0)
                    baseColor: cs2Defaults.preferredPlotColors[15]
                    fill: false
                },
                XYTrace {
                    tableModel: parameters.downshiftTablesB[1].param.stringModel
                    valid: parameters.downshiftTablesB[1].param.value.valid && (parameters.shiftTablesDownLockedB.param.floatVal == 0)
                    baseColor: cs2Defaults.preferredPlotColors[16]
                    fill: false
                },
                XYTrace {
                    tableModel: parameters.downshiftTablesB[2].param.stringModel
                    valid: parameters.downshiftTablesB[2].param.value.valid && (parameters.shiftTablesDownLockedB.param.floatVal == 0)
                    baseColor: cs2Defaults.preferredPlotColors[17]
                    fill: false
                },
                XYTrace {
                    tableModel: parameters.downshiftTablesB[3].param.stringModel
                    valid: parameters.downshiftTablesB[3].param.value.valid && (parameters.shiftTablesDownLockedB.param.floatVal == 0)
                    baseColor: cs2Defaults.preferredPlotColors[18]
                    fill: false
                },
                XYTrace {
                    tableModel: parameters.downshiftTablesB[4].param.stringModel
                    valid: parameters.downshiftTablesB[4].param.value.valid && (parameters.shiftTablesDownLockedB.param.floatVal == 0)
                    baseColor: cs2Defaults.preferredPlotColors[19]
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

    GroupBox {
        title: "Profile A"
        ColumnLayout {
            RowLayout {
                ShiftTableByShiftEditMenuButton {
                    text: qsTr("Upshift Tables")
                    speedTableParams: parameters.upshiftTablesA
                    rpmTableParams: parameters.rpmUpshiftTablesA
                    gearNumberRatioParam: parameters.transmissionGearNumbersRatios.param
                }
                ShiftTableByShiftEditMenuButton {
                    text: qsTr("Downshift Tables")
                    speedTableParams: parameters.upshiftTablesA
                    rpmTableParams: parameters.rpmUpshiftTablesA
                    gearNumberRatioParam: parameters.transmissionGearNumbersRatios.param
                    isDownshift: true
                    enabled: (parameters.shiftTablesDownLockedA.param.floatVal == 0)
                }
            }
            RowLayout {
                EncodingParamEdit {
                    metaParam: parameters.shiftTablesDownLockedA
                    name: qsTr("Downshift Locked")
                    implicitWidth: 132
                }
                ScalarParamSpinBox {
                    metaParam: parameters.shiftSpeedAdjustA
                    name: qsTr("Shift Speed Adjust")
                    implicitWidth: 132
                }
                ScalarParamSpinBox {
                    metaParam: parameters.shiftDownshiftOffsetA
                    name: qsTr("Downshift Offset")
                    implicitWidth: 132
                }
                ScalarParamSpinBox {
                    metaParam: parameters.shiftMaxEngineSpeedA
                    name: qsTr("Max Engine Speed")
                    implicitWidth: 132
                }
                EncodingParamEdit {
                    metaParam: parameters.shiftManualModeA
                    name: qsTr("Manual Mode")
                    implicitWidth: 132
                }
            }
        }
    }

    GroupBox {
        title: "Profile B"
        ColumnLayout {
            RowLayout {
                ShiftTableByShiftEditMenuButton {
                    text: qsTr("Upshift Tables")
                    speedTableParams: parameters.upshiftTablesB
                    rpmTableParams: parameters.rpmUpshiftTablesB
                    gearNumberRatioParam: parameters.transmissionGearNumbersRatios.param
                }
                ShiftTableByShiftEditMenuButton {
                    text: qsTr("Downshift Tables")
                    speedTableParams: parameters.upshiftTablesB
                    rpmTableParams: parameters.rpmUpshiftTablesB
                    gearNumberRatioParam: parameters.transmissionGearNumbersRatios.param
                    isDownshift: true
                    enabled: (parameters.shiftTablesDownLockedB.param.floatVal == 0)
                }
            }
            RowLayout {
                EncodingParamEdit {
                    metaParam: parameters.shiftTablesDownLockedB
                    name: "Downshift Locked"
                    implicitWidth: 132
                }
                ScalarParamSpinBox {
                    metaParam: parameters.shiftSpeedAdjustB
                    name: qsTr("Shift Speed Adjust")
                    implicitWidth: 132
                }
                ScalarParamSpinBox {
                    metaParam: parameters.shiftDownshiftOffsetB
                    name: qsTr("Downshift Offset")
                    implicitWidth: 132
                }
                ScalarParamSpinBox {
                    metaParam: parameters.shiftMaxEngineSpeedB
                    name: qsTr("Max Engine Speed")
                    implicitWidth: 132
                }
                EncodingParamEdit {
                    metaParam: parameters.shiftManualModeB
                    name: qsTr("Manual Mode")
                    implicitWidth: 132
                }
            }
        }
    }


    RowLayout {
        TableByShiftEditMenuButton {
            Layout.margins: 8
            text: qsTr("Shift Torque Limits")
            xLabel: qsTr("Driver Torque")
            valueLabel: qsTr("Limit")
            tableParam: parameters.shiftTorqueLimits
        }
        Button {
            text: "Torque Transfer Time"
            onClicked: torqueTransferDialog.visible = true
            enabled: torqueTransferDialog.allListsAnyValid
        }
        ScalarListDialog {
            id: torqueTransferDialog
            paramLists: [
                parameters.transmissionShiftTorqueTransferTime
            ]
        }

        ScalarParamSpinBox {
            Layout.alignment: Qt.AlignTop
            metaParam: parameters.reverseLockoutSpeed
        }

        ScalarParamSpinBox {
            Layout.alignment: Qt.AlignTop
            metaParam: parameters.transmissionDownshiftTypeTorqueThreshold
        }
    }
}
