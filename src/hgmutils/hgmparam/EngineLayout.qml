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
            metaParam: parameters.engineCylinders
        }
        ScalarParamSpinBox {
            metaParam: parameters.shiftMaxEngineSpeedA
        }
        ScalarParamSpinBox {
            metaParam: parameters.shiftMaxEngineSpeedB
        }
        ScalarParamSpinBox {
            metaParam: parameters.engineRunningDetectionSpeed
        }
        ScalarParamSpinBox {
            metaParam: parameters.engineIdleShutdownTime
        }
        ScalarParamCheckBox {
            metaParam: parameters.cs2EngineTempBiasEnable
        }
        TableParamEditButton {
            tableParam: parameters.engineMotorTorqueMap
            xLabel: "RPM"
            valueLabel: "%"
        }
        TableParamEditButton {
            tableParam: parameters.engineBrakeTorqueMap
            xLabel: "RPM"
            valueLabel: "%"
        }
    }

    ColumnLayout {
        Layout.fillHeight: true
        Layout.alignment: Qt.AlignTop
        ScalarParamSpinBox {
            metaParam: parameters.voltageTPSCalibrationHigh
        }
        ScalarParamSpinBox {
            metaParam: parameters.voltageTPSCalibrationLow
        }
        ScalarParamSpinBox {
            metaParam: parameters.voltageTPSFilterOrder
        }
        ScalarParamCheckBox {
            metaParam: parameters.voltageTPSGroundEnable
        }
        ScalarParamCheckBox {
            metaParam: parameters.voltageTPSIsReversed
        }
    }


    ColumnLayout {
        Layout.fillHeight: true
        Layout.alignment: Qt.AlignTop
        ScalarParamSpinBox {
            metaParam: parameters.voltageMAPSensorHighCalibration
        }
        ScalarParamSpinBox {
            metaParam: parameters.voltageMAPSensorLowCalibration
        }
        ScalarParamCheckBox {
            metaParam: parameters.voltageMAPSensorGroundEnable
        }
    }
}
