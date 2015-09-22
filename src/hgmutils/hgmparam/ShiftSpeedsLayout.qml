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
        Layout.minimumHeight: 200
        TablePlot {
            id: shiftAPlot
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
                    tableModel: parameters.shiftTablesB[0].stringModel
                    valid: parameters.shiftTablesB[0].value.valid
                    baseColor: cs2Defaults.preferredPlotColors[0]
                    fill: false
                },
                XYTrace {
                    tableModel: parameters.shiftTablesB[1].stringModel
                    valid: parameters.shiftTablesB[1].value.valid
                    baseColor: cs2Defaults.preferredPlotColors[1]
                    fill: false
                },
                XYTrace {
                    tableModel: parameters.shiftTablesB[2].stringModel
                    valid: parameters.shiftTablesB[2].value.valid
                    baseColor: cs2Defaults.preferredPlotColors[2]
                    fill: false
                },
                XYTrace {
                    tableModel: parameters.shiftTablesB[3].stringModel
                    valid: parameters.shiftTablesB[3].value.valid
                    baseColor: cs2Defaults.preferredPlotColors[3]
                    fill: false
                },
                XYTrace {
                    tableModel: parameters.shiftTablesB[4].stringModel
                    valid: parameters.shiftTablesB[4].value.valid
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
                },
                XYTrace {
                    tableModel: parameters.shiftTablesB[0].stringModel
                    valid: parameters.shiftTablesB[0].value.valid
                    baseColor: cs2Defaults.preferredPlotColors[5]
                    fill: false
                },
                XYTrace {
                    tableModel: parameters.shiftTablesB[1].stringModel
                    valid: parameters.shiftTablesB[1].value.valid
                    baseColor: cs2Defaults.preferredPlotColors[6]
                    fill: false
                },
                XYTrace {
                    tableModel: parameters.shiftTablesB[2].stringModel
                    valid: parameters.shiftTablesB[2].value.valid
                    baseColor: cs2Defaults.preferredPlotColors[7]
                    fill: false
                },
                XYTrace {
                    tableModel: parameters.shiftTablesB[3].stringModel
                    valid: parameters.shiftTablesB[3].value.valid
                    baseColor: cs2Defaults.preferredPlotColors[8]
                    fill: false
                },
                XYTrace {
                    tableModel: parameters.shiftTablesB[4].stringModel
                    valid: parameters.shiftTablesB[4].value.valid
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
    }

    ShiftTableByShiftEditButtonGroup {
        title: qsTr("Shift Tables A")
        speedTableParams: parameters.shiftTablesA
        rpmTableParams: parameters.rpmShiftTablesA
        gearRatioParams: parameters.transmissionGearRatios
        Layout.minimumHeight: 60
    }

    ShiftTableByShiftEditButtonGroup {
        title: qsTr("Shift Tables B")
        speedTableParams: parameters.shiftTablesB
        rpmTableParams: parameters.rpmShiftTablesB
        gearRatioParams: parameters.transmissionGearRatios
        Layout.minimumHeight: 60
    }

    Row {
        spacing: 5
        ScalarParamSpinBox {
            name: qsTr("Downshift Offset A")
            param: parameters.shiftDownshiftOffsetA
        }
        ScalarParamSpinBox {
            name: qsTr("Downshift Offset B")
            param: parameters.shiftDownshiftOffsetB
        }
        Layout.minimumHeight: 60
        Layout.bottomMargin: 10
    }
}
