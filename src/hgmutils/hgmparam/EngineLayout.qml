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
        EncodingParamEdit {
            metaParam: parameters.cs2EngineTempBiasEnable
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
        EncodingParamEdit {
            metaParam: parameters.voltageTPSGroundEnable
        }
        EncodingParamEdit {
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
        EncodingParamEdit {
            metaParam: parameters.voltageMAPSensorGroundEnable
        }
        TableParamEditButton {
            Layout.margins: 8
            tableParam: parameters.engineMotoringMaxTorque
            xLabel: "RPM"
            valueLabel: parameters.slots.torque.unit
        }
        TableParamEditButton {
            Layout.margins: 8
            tableParam: parameters.engineBrakingMaxTorque
            xLabel: "RPM"
            valueLabel: parameters.slots.torque.unit
        }
        ScalarParamSpinBox {
            metaParam: parameters.engineMaxTorqueDuringShift
        }
        ScalarParamSpinBox {
            metaParam: parameters.engineMaxTorqueDuringDriving
        }
    }
}
