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

    TableByGearEditButtonGroup {
        title: qsTr("Shift Pressure A")
        count: 6
        tableParam: parameters.pressureTablesA
        xLabel: qsTr("Torque")
        valueLabel: qsTr("%")
    }

    TableByGearEditButtonGroup {
        title: qsTr("Shift Pressure B")
        count: 6
        tableParam: parameters.pressureTablesB
        xLabel: qsTr("Torque")
        valueLabel: qsTr("%")
    }

    TableByShiftEditButtonGroup {
        title: qsTr("Upshift Apply Pressure %")
        count: 6
        xLabel: qsTr("Torque")
        valueLabel: qsTr("%")
        tableParam: parameters.transmissionUpshiftApplyPercentage
    }

    TableByShiftEditButtonGroup {
        title: qsTr("Downshift Apply Pressure %")
        count: 5
        isDownshift: true

        xLabel: qsTr("Torque")
        valueLabel: qsTr("%")
        tableParam: parameters.transmissionDownshiftApplyPercentage
    }
    TableByGearEditButtonGroup {
        title: qsTr("Main Pressure %")
        count: 6
        xLabel: qsTr("Torque")
        valueLabel: qsTr("%")
        tableParam: parameters.transmissionMainPercentage
    }
    GroupBox {
        title: "Prefill"
        Button {
            text: "Edit"
            onClicked: prefillDialog.visible = true
            enabled: prefillDialog.anyValid
        }
    }

    ScalarListDialog {
        id: prefillDialog
        paramLists: [
            parameters.transmissionShiftPrefillPercentage,
            parameters.transmissionShiftPrefillTime
        ]
    }
}
