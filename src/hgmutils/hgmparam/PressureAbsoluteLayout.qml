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

    TableByShiftEditButtonGroup {
        title: qsTr("Upshift Apply Pressure")
        xLabel: qsTr("Torque")
        valueLabel: qsTr("Pressure")
        tableParam: parameters.transmissionUpshiftApplyPressure
    }

    TableByShiftEditButtonGroup {
        title: qsTr("Downshift Apply Pressure")
        xLabel: qsTr("Torque")
        valueLabel: qsTr("Pressure")
        tableParam: parameters.transmissionDownshiftApplyPressure
    }
    TableByGearEditButtonGroup {
        title: qsTr("Main Pressure")
        xLabel: qsTr("Torque")
        valueLabel: qsTr("Pressure")
        tableParam: parameters.transmissionMainPressure
    }

    GroupBox {
        title: "Prefill"
        Button {
            text: "Edit"
            onClicked: prefillDialog.visible = true
            enabled: prefillDialog.allListsAnyValid
        }
    }

    ScalarListDialog {
        id: prefillDialog
        paramLists: [
            parameters.transmissionShiftPrefillPressure,
            parameters.transmissionShiftPrefillTime
        ]
    }

    GroupBox {
        title: "Garage Shift"
        Button {
            text: "Edit"
            onClicked: garageShiftDialog.visible = true
            enabled: parameters.garageShiftPrefillPressure.param.valid
        }
    }
    Window {
        id: garageShiftDialog

        height: 25 + (stalkingHorse.implicitHeight + 5) * 7
        width: 35 + stalkingHorse.implicitWidth + 5

        ColumnLayout {
            anchors.fill: parent
            anchors.margins: 10

            ScalarParamSpinBox {
                id: stalkingHorse
                metaParam: parameters.garageShiftPrefillTime
            }
            ScalarParamSpinBox {
                metaParam: parameters.garageShiftApplyTime
            }
            ScalarParamSpinBox {
                metaParam: parameters.garageShiftPrefillPressure
            }
            ScalarParamSpinBox {
                metaParam: parameters.garageShiftMaxPressure
            }
            ScalarParamSpinBox {
                metaParam: parameters.garageShiftProportionalConstant
            }
            ScalarParamSpinBox {
                metaParam: parameters.garageShiftIntegralConstant
            }
            ScalarParamSpinBox {
                metaParam: parameters.garageShiftDerivativeConstant
            }
        }
    }
}

