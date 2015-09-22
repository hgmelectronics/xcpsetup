import QtQuick 2.5
import QtQuick.Controls 1.4
import QtQuick.Layouts 1.2
import QtQuick.Window 2.2
import QtQuick.Dialogs 1.2
import com.hgmelectronics.setuptools.xcp 1.0
import com.hgmelectronics.setuptools 1.0
import com.hgmelectronics.setuptools.ui 1.0

Flow {
    property Parameters parameters
    anchors.fill: parent
    anchors.margins: 5
    spacing: 5

    TableByShiftEditButtonGroup {
        title: qsTr("Upshift Apply Pressure")
        count: 5
        xLabel: qsTr("Torque")
        valueLabel: qsTr("Pressure")
        tableParam: parameters.transmissionUpshiftApplyPressure
    }

    TableByShiftEditButtonGroup {
        title: qsTr("Upshift Apply Pressure")
        count: 5
        xLabel: qsTr("Torque")
        valueLabel: qsTr("Pressure")
        tableParam: parameters.transmissionUpshiftApplyPressure
    }

    TableByShiftEditButtonGroup {
        title: qsTr("Downshift Apply Pressure")
        count: 4
        isDownshift: true

        xLabel: qsTr("Torque")
        valueLabel: qsTr("Pressure")
        tableParam: parameters.transmissionDownshiftApplyPressure
    }

    GroupBox {
        title: qsTr("Shift Prefill")
        Row {
            spacing: 5
            TableParamEditButton {
                name: qsTr("Pressure")
                xLabel: qsTr("Shift")
                valueLabel: qsTr("Pressure")
                tableParam: parameters.transmissionShiftPrefillPressure
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
        title: qsTr("Main Pressure")
        count: 6
        xLabel: qsTr("Torque")
        valueLabel: qsTr("Pressure")
        tableParam: parameters.transmissionMainPressure
    }
}

