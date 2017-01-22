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
    spacing: 5
    ColumnLayout {
        Layout.fillHeight: true
        Layout.alignment: Qt.AlignTop
        ScalarParamSpinBox {
            metaParam: parameters.tccEnableGearA
            minimumValue: 1
            maximumValue: 8
        }
        ScalarParamSpinBox {
            metaParam: parameters.tccMinThrottleA
        }
        ScalarParamSpinBox {
            metaParam: parameters.tccMaxThrottleA
        }
        ScalarParamSpinBox {
            metaParam: parameters.tccEnableTOSSA
        }
        ScalarParamSpinBox {
            metaParam: parameters.tccDisableTOSSPercentA
        }
        EncodingParamEdit {
            metaParam: parameters.tccDisableInSwitchShiftA
        }
        EncodingParamEdit {
            metaParam: parameters.tccManualModeA
        }
    }
    ColumnLayout {
        Layout.fillHeight: true
        Layout.alignment: Qt.AlignTop
        ScalarParamSpinBox {
            metaParam: parameters.tccEnableGearB
            minimumValue: 1
            maximumValue: 8
        }
        ScalarParamSpinBox {
            metaParam: parameters.tccMinThrottleB
        }
        ScalarParamSpinBox {
            metaParam: parameters.tccMaxThrottleB
        }
        ScalarParamSpinBox {
            metaParam: parameters.tccEnableTOSSB
        }
        ScalarParamSpinBox {
            metaParam: parameters.tccDisableTOSSPercentB
        }
        EncodingParamEdit {
            metaParam: parameters.tccDisableInSwitchShiftB
        }
        EncodingParamEdit {
            metaParam: parameters.tccManualModeB
        }
    }
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
        ScalarParamSpinBox {
            metaParam: parameters.tccUnlockTime
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
