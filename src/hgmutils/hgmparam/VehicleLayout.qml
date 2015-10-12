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
        EncodingParamEdit {
            metaParam: parameters.vehicleVariation
        }
        ScalarParamSpinBox {
            metaParam: parameters.vehicleMass
        }
        ScalarParamSpinBox {
            metaParam: parameters.transferCaseRatio
        }
        ScalarParamSpinBox {
            metaParam: parameters.finalDriveRatio
        }
        ScalarParamSpinBox {
            metaParam: parameters.tireDiameter
        }
    }

    ColumnLayout {
        Layout.fillHeight: true
        Layout.alignment: Qt.AlignTop
        EncodingParamEdit {
            metaParam: parameters.speedometerCalibration
        }
        ScalarParamSpinBox {
            metaParam: parameters.vehicleSpeedSensorPulseCount
        }
        EncodingParamEdit {
            metaParam: parameters.startInhibitRelayType
        }
        ScalarParamCheckBox {
            metaParam: parameters.shiftSelectorODCancelAtStartup
            boxRight: true
        }
        TableParamEditButton {
            tableParam: parameters.shiftSelectorGearVoltages
            xLabel: "Gear"
            valueLabel: "Position"
        }
    }
}
