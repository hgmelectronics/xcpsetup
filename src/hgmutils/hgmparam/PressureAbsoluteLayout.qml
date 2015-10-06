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

    Flow {
        Layout.fillWidth: true
        Layout.fillHeight: true
        spacing: 5

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
        TableByGearEditButtonGroup {
            title: qsTr("Main Pressure")
            count: 6
            xLabel: qsTr("Torque")
            valueLabel: qsTr("Pressure")
            tableParam: parameters.transmissionMainPressure
        }
    }

    ScrollView {
        id: prefillView
        width: 240
        Layout.fillHeight: true
        ColumnLayout {
            Layout.fillWidth: true
            spacing: 5
            Repeater {
                model: parameters.transmissionShiftPrefillPressure.length
                Row {
                    id: prefillRow
                    spacing: 5
                    ScalarParamEdit {
                        width: prefillView.width / 2 - 15
                        metaParam: parameters.transmissionShiftPrefillPressure[index]
                        visible: parameters.transmissionShiftPrefillPressure[index].param.valid
                    }
                    ScalarParamEdit {
                        width: prefillView.width / 2 - 15
                        metaParam: parameters.transmissionShiftPrefillTime[index]
                        visible: parameters.transmissionShiftPrefillTime[index].param.valid
                    }
                }
            }
        }
    }
}

