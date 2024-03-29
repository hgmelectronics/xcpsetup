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
    spacing: 5

    RowLayout {
        Layout.fillWidth: true
        Layout.alignment: Qt.AlignTop | Qt.AlignLeft

        ColumnLayout {
            Layout.fillHeight: true
            Layout.alignment: Qt.AlignTop
            EncodingParamEdit {
                metaParam: parameters.transmissionHasLinePressureSensor
            }
            EncodingParamEdit {
                metaParam: parameters.transmissionHasLinePressureControl
            }
        }
        ColumnLayout {
            Layout.fillHeight: true
            Layout.alignment: Qt.AlignTop
            EncodingParamEdit {
                metaParam: parameters.transmissionHasAccumulatorControl
            }
            EncodingParamEdit {
                metaParam: parameters.transmissionHasPWMTCC
            }
            EncodingParamEdit {
                metaParam: parameters.transmissionTempBiasEnable
            }
        }

        ColumnLayout {
            Layout.fillHeight: true
            Layout.alignment: Qt.AlignTop
            ScalarParamSpinBox {
                metaParam: parameters.transmissionTurbineShaftSpeedSensorPulseCount
            }
            ScalarParamSpinBox {
                metaParam: parameters.transmissionInputShaftSpeedSensorPulseCount
            }
            ScalarListDialog {
                id: transShaftSpeedSensorDialog
                paramLists: [
                    parameters.transmissionShaftSpeedSensorPulseCount
                ]
            }
            Button {
                Layout.margins: 8
                text: "Other Shaft Speed Sensors"
                onClicked: {
                    transShaftSpeedSensorDialog.showNormal()
                    transShaftSpeedSensorDialog.raise()
                }
            }

            TableParamEditButton {
                Layout.margins: 8
                tableParam: parameters.transmissionTemperaturePressureCompensation
                xLabel: "Temp"
                valueLabel: "%"
            }
        }
        TableParamView {
            Layout.alignment: Qt.AlignTop
            name: "Gear Ratios"
            xLabel: "Gear"
            valueLabel: "Ratio"
            xColumnWidth: 60
            valueColumnWidth: 60
            model: parameters.transmissionGearNumbersRatios.param.stringModel
        }
    }

    TableByClutchEditButtonGroup {
        Layout.alignment: Qt.AlignLeft
        title: qsTr("Solenoid PI Curves")
        xLabel: qsTr("Pressure")
        valueLabel: qsTr("Current")
        tableParam: parameters.solenoidPIMap
    }
}
