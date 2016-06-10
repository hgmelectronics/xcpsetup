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
            metaParam: parameters.evTorqueFilterOrder
        }
        ScalarParamSpinBox {
            metaParam: parameters.evSpeedFilterOrder
        }
        ScalarParamSpinBox {
            metaParam: parameters.evMotorTorqueIdle
        }
        ScalarParamSpinBox {
            metaParam: parameters.evMotorTorqueShift
        }
        ScalarParamSpinBox {
            metaParam: parameters.evMotorSpeedMax
        }
//        TableParamEditButton {
//            tableParam: parameters.evTorqueRampDownTime
//            xLabel: "Gear"
//            valueLabel: "Time"
//            hasPlot: false
//            hasShapers: false
//        }
//        TableParamEditButton {
//            tableParam: parameters.evTorqueRampUpTime
//            xLabel: "Gear"
//            valueLabel: "Time"
//            hasPlot: false
//            hasShapers: false
//        }
    }

    ColumnLayout {
        Layout.fillHeight: true
        Layout.alignment: Qt.AlignTop
//        TableParamEditButton {
//            tableParam: parameters.evMotorTorqueMaxA
//            xLabel: "Gear"
//            valueLabel: "Torque %"
//            hasPlot: false
//            hasShapers: false
//        }
//        TableParamEditButton {
//            tableParam: parameters.evRegenTorqueMaxA
//            xLabel: "Gear"
//            valueLabel: "Torque %"
//            hasPlot: false
//            hasShapers: false
//        }
        ScalarParamSpinBox {
            metaParam: parameters.evMaxRegenSpeedA
        }
//        TableParamEditButton {
//            tableParam: parameters.evMotorTorqueMaxB
//            xLabel: "Gear"
//            valueLabel: "Torque %"
//            hasPlot: false
//            hasShapers: false
//        }
//        TableParamEditButton {
//            tableParam: parameters.evRegenTorqueMaxB
//            xLabel: "Gear"
//            valueLabel: "Torque %"
//            hasPlot: false
//            hasShapers: false
//        }
        ScalarParamSpinBox {
            metaParam: parameters.evMaxRegenSpeedB
        }
    }


    ColumnLayout {
        Layout.fillHeight: true
        Layout.alignment: Qt.AlignTop
        ScalarParamSpinBox {
            metaParam: parameters.ebusShiftSyncTolerance
        }
        ScalarParamSpinBox {
            metaParam: parameters.ebusShiftSyncDuration
        }
        /*ScalarParamEdit {
            metaParam: parameters.evJ1939CtlSourceAddress
        }
        ScalarParamEdit {
            metaParam: parameters.evDriveFaultCount
        }
        ScalarParamEdit {
            metaParam: parameters.evDriveLastFaultType
        }*/
    }
}
