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

    TablePlot {
        width: 400
        height: 200
        plots: []
    }

    TableByShiftEditButtonGroup {
        title: qsTr("Shift Tables A")
        count: 5
        tableParam: parameters.shiftTablesA
        xLabel: qsTr("Throttle")
        valueLabel: qsTr("Speed")
    }

    TableByShiftEditButtonGroup {
        title: qsTr("Shift Tables B")
        count: 5
        tableParam: parameters.shiftTablesB
        xLabel: qsTr("Throttle")
        valueLabel: qsTr("Speed")
    }

    Row {
        spacing: 10
        ScalarParamSpinBox {
            name: qsTr("Downshift Offset A")
            param: parameters.shiftDownshiftOffsetA
        }
        ScalarParamSpinBox {
            name: qsTr("Downshift Offset B")
            param: parameters.shiftDownshiftOffsetB
        }
    }
}
