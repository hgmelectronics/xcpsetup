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
        title: "Profile A"
        Layout.alignment: Qt.AlignTop
        ColumnLayout {
            ScalarParamSpinBox {
                name: qsTr("TCC Enable Gear")
                metaParam: parameters.tccEnableGearA
                minimumValue: 1
                maximumValue: 8
            }
            ScalarParamSpinBox {
                name: qsTr("TCC Min Throttle")
                metaParam: parameters.tccMinThrottleA
            }
            ScalarParamSpinBox {
                name: qsTr("TCC Max Throttle")
                metaParam: parameters.tccMaxThrottleA
            }
            ScalarParamSpinBox {
                name: qsTr("TCC Enable Speed")
                metaParam: parameters.tccEnableTOSSA
            }
            ScalarParamSpinBox {
                name: qsTr("TCC Disable Speed %")
                metaParam: parameters.tccDisableTOSSPercentA
            }
            EncodingParamEdit {
                name: qsTr("TCC Disable In Switch Shift")
                metaParam: parameters.tccDisableInSwitchShiftA
            }
            EncodingParamEdit {
                name: qsTr("TCC Manual Mode")
                metaParam: parameters.tccManualModeA
            }
            TableByGearEditMenuButton {
                text: qsTr("Enable Speed Tables")
                xLabel: qsTr("Torque")
                valueLabel: qsTr("Speed")
                tableParam: parameters.tccEnableSpeedTablesA
            }
            TableByGearEditMenuButton {
                text: qsTr("Disable Speed Tables")
                xLabel: qsTr("Torque")
                valueLabel: qsTr("Speed")
                tableParam: parameters.tccDisableSpeedTablesA
            }
        }
    }

    GroupBox {
        title: "Profile B"
        Layout.alignment: Qt.AlignTop
        ColumnLayout {
            ScalarParamSpinBox {
                name: qsTr("TCC Enable Gear")
                metaParam: parameters.tccEnableGearB
                minimumValue: 1
                maximumValue: 8
            }
            ScalarParamSpinBox {
                name: qsTr("TCC Min Throttle")
                metaParam: parameters.tccMinThrottleB
            }
            ScalarParamSpinBox {
                name: qsTr("TCC Max Throttle")
                metaParam: parameters.tccMaxThrottleB
            }
            ScalarParamSpinBox {
                name: qsTr("TCC Enable Speed")
                metaParam: parameters.tccEnableTOSSB
            }
            ScalarParamSpinBox {
                name: qsTr("TCC Disable Speed %")
                metaParam: parameters.tccDisableTOSSPercentB
            }
            EncodingParamEdit {
                name: qsTr("TCC Disable In Switch Shift")
                metaParam: parameters.tccDisableInSwitchShiftB
            }
            EncodingParamEdit {
                name: qsTr("TCC Manual Mode")
                metaParam: parameters.tccManualModeB
            }
            TableByGearEditMenuButton {
                text: qsTr("Enable Speed Tables")
                xLabel: qsTr("Torque")
                valueLabel: qsTr("Speed")
                tableParam: parameters.tccEnableSpeedTablesB
            }
            TableByGearEditMenuButton {
                text: qsTr("Disable Speed Tables")
                xLabel: qsTr("Torque")
                valueLabel: qsTr("Speed")
                tableParam: parameters.tccDisableSpeedTablesB
            }
        }
    }


    GroupBox {
        title: "Common"
        Layout.alignment: Qt.AlignTop
        ColumnLayout {
            Layout.fillHeight: true
            Layout.alignment: Qt.AlignTop
            ScalarParamSpinBox {
                metaParam: parameters.tccPrefillTime
            }
            ScalarParamSpinBox {
                metaParam: parameters.tccStrokeTime
            }
            ScalarParamSpinBox {
                metaParam: parameters.tccApplyTime
            }
            Button {
                Layout.margins: 8
                text: "Percentage and PID"
                onClicked: {
                    percentagePidDialog.showNormal()
                    percentagePidDialog.raise()
                }
                enabled: parameters.tccPrefillPercentage.param.valid
            }
            Button {
                Layout.margins: 8
                text: "Pressure and PID"
                onClicked: {
                    pressurePidDialog.showNormal()
                    pressurePidDialog.raise()
                }
                enabled: parameters.tccPrefillPressure.param.valid
            }
            TableParamEditButton {
                Layout.margins: 8
                tableParam: parameters.torqueConverterMult
                xLabel: "Speed Ratio"
                valueLabel: "Torque Ratio"
            }
        }
    }

    ScalarListDialog {
        id: percentagePidDialog
        paramLists: [
            ScalarMetaParamList {
                params: [
                    parameters.tccPrefillPercentage,
                    parameters.tccStrokePercentage,
                    parameters.tccMaxPercentage,
                    parameters.tccPercentageProportionalConstant,
                    parameters.tccPercentageIntegralConstant,
                    parameters.tccPercentageDerivativeConstant
                ]
            }
        ]
    }

    ScalarListDialog {
        id: pressurePidDialog
        paramLists: [
            ScalarMetaParamList {
                params: [
                    parameters.tccPrefillPressure,
                    parameters.tccStrokePressure,
                    parameters.tccMaxPressure,
                    parameters.tccPressureProportionalConstant,
                    parameters.tccPressureIntegralConstant,
                    parameters.tccPressureDerivativeConstant
                ]
            }
        ]
    }
}
