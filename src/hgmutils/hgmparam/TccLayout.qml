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
            metaParam: parameters.tccDownshiftOffsetA
        }
        ScalarParamSpinBox {
            metaParam: parameters.tccDisableTOSSPercentA
        }
        ScalarParamSpinBox {
            metaParam: parameters.tccEnableGearA
        }
        ScalarParamSpinBox {
            metaParam: parameters.tccEnableTOSSA
        }
        ScalarParamSpinBox {
            metaParam: parameters.tccMaxThrottleA
        }
        ScalarParamSpinBox {
            metaParam: parameters.tccMinThrottleA
        }
        EncodingParamEdit {
            metaParam: parameters.tccManualModeA
        }
    }
    ColumnLayout {
        Layout.fillHeight: true
        Layout.alignment: Qt.AlignTop
        ScalarParamSpinBox {
            metaParam: parameters.tccDownshiftOffsetB
        }
        ScalarParamSpinBox {
            metaParam: parameters.tccDisableTOSSPercentB
        }
        ScalarParamSpinBox {
            metaParam: parameters.tccEnableGearB
        }
        ScalarParamSpinBox {
            metaParam: parameters.tccEnableTOSSB
        }
        ScalarParamSpinBox {
            metaParam: parameters.tccMaxThrottleB
        }
        ScalarParamSpinBox {
            metaParam: parameters.tccMinThrottleB
        }
        EncodingParamEdit {
            metaParam: parameters.tccManualModeB
        }
    }
    ColumnLayout {
        Layout.fillHeight: true
        Layout.alignment: Qt.AlignTop
        ScalarParamSpinBox {
            metaParam: parameters.tccPrefillPressure
        }
        ScalarParamSpinBox {
            metaParam: parameters.tccPrefillTime
        }
        TableParamEditButton {
            tableParam: parameters.tccApplyPressure
            xLabel: "Slip"
            valueLabel: "%"
        }
    }
    ColumnLayout {
        Layout.fillHeight: true
        Layout.alignment: Qt.AlignTop
        ScalarParamSpinBox {
            metaParam: parameters.tccPrefillPercentage
        }
        ScalarParamSpinBox {
            metaParam: parameters.tccMaxPercentage
        }
        ScalarParamSpinBox {
            metaParam: parameters.tccProportionalConstant
        }
        ScalarParamSpinBox {
            metaParam: parameters.tccIntegralConstant
        }
        ScalarParamSpinBox {
            metaParam: parameters.tccDerivativeConstant
        }
        ScalarParamSpinBox {
            metaParam: parameters.tccApplyTime
        }
        ScalarParamSpinBox {
            metaParam: parameters.tccSlipCommand
            stepSize: 20
        }
    }
}
