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
                metaParam: parameters.transmissionType
            }
            ScalarParamCheckBox {
                metaParam: parameters.transmissionTempBiasEnable
            }
            ScalarParamCheckBox {
                metaParam: parameters.transmissionHasLinePressureSensor
            }
            ScalarParamCheckBox {
                metaParam: parameters.transmissionHasLinePressureControl
            }
            ScalarParamCheckBox {
                metaParam: parameters.transmissionHasAccumulatorControl
            }
            ScalarParamCheckBox {
                metaParam: parameters.transmissionHasPWMTCC
            }
        }

        ColumnLayout {
            Layout.fillHeight: true
            Layout.alignment: Qt.AlignTop
            ScalarParamEdit {
                metaParam: parameters.transmissionTurbineShaftSpeedSensorPulseCount
            }
            ScalarParamEdit {
                metaParam: parameters.transmissionInputShaftSpeedSensorPulseCount
            }
            ScalarListDialog {
                id: transShaftSpeedSensorDialog
                paramLists: [
                    parameters.transmissionShaftSpeedSensorPulseCount
                ]
            }
            Button {
                text: "Other Shaft Speed Sensors"
                onClicked: transShaftSpeedSensorDialog.visible = true
            }
        }

        ColumnLayout {
            Layout.fillHeight: true
            Layout.alignment: Qt.AlignTop
            TableParamEditButton {
                tableParam: parameters.transmissionTemperaturePressureCompensation
                xLabel: "Temp"
                valueLabel: "%"
            }
        }
    }

    TableParamEditButton {
        tableParam: parameters.transmissionGearNumbersRatios
        xLabel: "Gear"
        valueLabel: "Ratio"
        hasPlot: false
        hasShapers: false
    }

    TableByClutchEditButtonGroup {
        Layout.alignment: Qt.AlignLeft
        title: qsTr("Clutch Fill Time")
        xLabel: qsTr("Pressure")
        valueLabel: qsTr("Time")
        tableParam: parameters.transmissionClutchFillTime
    }

    TableByClutchEditButtonGroup {
        Layout.alignment: Qt.AlignLeft
        title: qsTr("Clutch Empty Time")
        xLabel: qsTr("Pressure")
        valueLabel: qsTr("Time")
        tableParam: parameters.transmissionClutchEmptyTime
    }
}
