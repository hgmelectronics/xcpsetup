import QtQuick 2.5
import QtQuick.Controls 1.4
import QtQuick.Layouts 1.2
import QtQuick.Window 2.2
import QtQuick.Dialogs 1.2
import com.hgmelectronics.setuptools.xcp 1.0
import com.hgmelectronics.setuptools 1.0
import com.hgmelectronics.setuptools.ui 1.0

Flow {
    anchors.fill: parent
    anchors.margins: 10
    spacing: 10

    property Parameters parameters

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
        count: 5
        xLabel: qsTr("Torque")
        valueLabel: qsTr("%")
        tableParam: parameters.transmissionUpshiftApplyPercentage
    }

    TableByShiftEditButtonGroup {
        title: qsTr("Downshift Apply Pressure %")
        count: 4
        isDownshift: true

        xLabel: qsTr("Torque")
        valueLabel: qsTr("%")
        tableParam: parameters.transmissionDownshiftApplyPercentage
    }

    GroupBox {
        title: qsTr("Shift Prefill")
        Row {
            spacing: 10
            TableParamEditButton {
                name: qsTr("Pressure")
                xLabel: qsTr("Shift")
                valueLabel: qsTr("%")
                tableParam: parameters.transmissionShiftPrefillPercentage
            }

            TableParamEditButton {
                name: qsTr("Time")
                xLabel: qsTr("Shift")
                valueLabel: qsTr("ms")
                tableParam: parameters.transmissionShiftPrefillTime
            }
        }
    }

    TableByGearEditButtonGroup {
        title: qsTr("Main Pressure %")
        count: 6
        xLabel: qsTr("Torque")
        valueLabel: qsTr("%")
        tableParam: parameters.transmissionMainPercentage
    }
}
