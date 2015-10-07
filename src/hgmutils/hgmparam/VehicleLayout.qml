import QtQuick 2.5
import QtQuick.Controls 1.4
import QtQuick.Layouts 1.2
import QtQuick.Window 2.2
import QtQuick.Dialogs 1.2
import com.hgmelectronics.setuptools.xcp 1.0
import com.hgmelectronics.setuptools 1.0
import com.hgmelectronics.setuptools.ui 1.0

GridLayout {
    property Parameters parameters
    anchors.fill: parent
    anchors.margins: 5
    columnSpacing: 5
    rowSpacing: 5
    rows: 6
    flow: GridLayout.TopToBottom

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
    EncodingParamEdit {
        metaParam: parameters.speedometerCalibration
    }
    EncodingParamEdit {
        metaParam: parameters.startInhibitRelayType
    }
    ScalarParamSpinBox {
        metaParam: parameters.vehicleSpeedSensorPulseCount
    }
    TableParamEditButton {
        tableParam: parameters.shiftSelectorGearVoltages
        xLabel: "Gear"
        valueLabel: "Position"
    }
    ScalarParamCheckBox {
        metaParam: parameters.shiftSelectorODCancelAtStartup
    }
}
