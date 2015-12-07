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
            metaParam: parameters.tccDisableTOSSPercentA
        }
        ScalarParamSpinBox {
            metaParam: parameters.tccEnableGearA
            minimumValue: 1
            maximumValue: 8
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
            metaParam: parameters.tccDisableTOSSPercentB
        }
        ScalarParamSpinBox {
            metaParam: parameters.tccEnableGearB
            minimumValue: 1
            maximumValue: 8
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
            metaParam: parameters.tccPrefillTime
        }
        ScalarParamSpinBox {
            metaParam: parameters.tccApplyTime
        }
        ScalarParamSpinBox {
            metaParam: parameters.tccPrefillPressure
        }
        ScalarParamSpinBox {
            metaParam: parameters.tccPrefillPercentage
        }
        ScalarParamSpinBox {
            metaParam: parameters.tccMaxPressure
        }
        ScalarParamSpinBox {
            metaParam: parameters.tccMaxPercentage
        }
    }
    ColumnLayout {
        Layout.fillHeight: true
        Layout.alignment: Qt.AlignTop
        ScalarParamSpinBox {
            metaParam: parameters.tccProportionalConstant
        }
        ScalarParamSpinBox {
            metaParam: parameters.tccIntegralConstant
        }
        ScalarParamSpinBox {
            metaParam: parameters.tccDerivativeConstant
        }
        TableParamEditButton {
            Layout.margins: 8
            tableParam: parameters.torqueConverterMult
            xLabel: "Speed Ratio"
            valueLabel: "Torque Ratio"
        }
    }
}
