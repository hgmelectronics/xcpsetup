import QtQuick 2.5
import QtQuick.Controls 1.4
import QtQuick.Layouts 1.2
import QtQuick.Window 2.2
import QtQuick.Dialogs 1.2
import QtCharts 2.0
import com.hgmelectronics.setuptools.xcp 1.0
import com.hgmelectronics.setuptools 1.0
import com.hgmelectronics.setuptools.ui 1.0

RowLayout {
    property Parameters parameters
    anchors.fill: parent
    anchors.margins: 5

    property bool lockAVisible0: parameters.tccEnableSpeedTablesA[0].param.value.valid
    property bool lockAVisible1: parameters.tccEnableSpeedTablesA[1].param.value.valid
    property bool lockAVisible2: parameters.tccEnableSpeedTablesA[2].param.value.valid
    property bool lockAVisible3: parameters.tccEnableSpeedTablesA[3].param.value.valid
    property bool lockAVisible4: parameters.tccEnableSpeedTablesA[4].param.value.valid
    property bool lockAVisible5: parameters.tccEnableSpeedTablesA[5].param.value.valid
    property bool lockBVisible0: false
    property bool lockBVisible1: false
    property bool lockBVisible2: false
    property bool lockBVisible3: false
    property bool lockBVisible4: false
    property bool lockBVisible5: false
    property bool unlockAVisible0: false
    property bool unlockAVisible1: false
    property bool unlockAVisible2: false
    property bool unlockAVisible3: false
    property bool unlockAVisible4: false
    property bool unlockAVisible5: false
    property bool unlockBVisible0: false
    property bool unlockBVisible1: false
    property bool unlockBVisible2: false
    property bool unlockBVisible3: false
    property bool unlockBVisible4: false
    property bool unlockBVisible5: false

    function getTraceVisible(isUnlock, isB, index) {
        if(!isUnlock) {
            if(!isB) {
                switch(index) {
                case 0:
                    return lockAVisible0
                case 1:
                    return lockAVisible1
                case 2:
                    return lockAVisible2
                case 3:
                    return lockAVisible3
                case 4:
                    return lockAVisible4
                case 5:
                    return lockAVisible5
                }
            }
            else {
                switch(index) {
                case 0:
                    return lockBVisible0
                case 1:
                    return lockBVisible1
                case 2:
                    return lockBVisible2
                case 3:
                    return lockBVisible3
                case 4:
                    return lockBVisible4
                case 5:
                    return lockBVisible5
                }

            }
        }
        else {
            if(!isB) {
                switch(index) {
                case 0:
                    return unlockAVisible0
                case 1:
                    return unlockAVisible1
                case 2:
                    return unlockAVisible2
                case 3:
                    return unlockAVisible3
                case 4:
                    return unlockAVisible4
                case 5:
                    return unlockAVisible5
                }
            }
            else {
                switch(index) {
                case 0:
                    return unlockBVisible0
                case 1:
                    return unlockBVisible1
                case 2:
                    return unlockBVisible2
                case 3:
                    return unlockBVisible3
                case 4:
                    return unlockBVisible4
                case 5:
                    return unlockBVisible5
                }

            }

        }
    }

    function setTraceVisible(isUnlock, isB, index, value) {
        if(!isUnlock) {
            if(!isB) {
                switch(index) {
                case 0:
                    return lockAVisible0 = value
                case 1:
                    return lockAVisible1 = value
                case 2:
                    return lockAVisible2 = value
                case 3:
                    return lockAVisible3 = value
                case 4:
                    return lockAVisible4 = value
                case 5:
                    return lockAVisible5 = value
                }
            }
            else {
                switch(index) {
                case 0:
                    return lockBVisible0 = value
                case 1:
                    return lockBVisible1 = value
                case 2:
                    return lockBVisible2 = value
                case 3:
                    return lockBVisible3 = value
                case 4:
                    return lockBVisible4 = value
                case 5:
                    return lockBVisible5 = value
                }

            }
        }
        else {
            if(!isB) {
                switch(index) {
                case 0:
                    return unlockAVisible0 = value
                case 1:
                    return unlockAVisible1 = value
                case 2:
                    return unlockAVisible2 = value
                case 3:
                    return unlockAVisible3 = value
                case 4:
                    return unlockAVisible4 = value
                case 5:
                    return unlockAVisible5 = value
                }
            }
            else {
                switch(index) {
                case 0:
                    return unlockBVisible0 = value
                case 1:
                    return unlockBVisible1 = value
                case 2:
                    return unlockBVisible2 = value
                case 3:
                    return unlockBVisible3 = value
                case 4:
                    return unlockBVisible4 = value
                case 5:
                    return unlockBVisible5 = value
                }
            }
        }
    }

    ColumnLayout {

        Layout.fillWidth: true
        Layout.fillHeight: true

        ChartView {
            id: plot

            Layout.fillWidth: true
            Layout.fillHeight: true
            margins.left: 0
            margins.right: 0
            margins.bottom: 0
            margins.top: 0

            antialiasing: true
            legend.visible: false   // FIXME review whether this is a good idea

            RoleModeledLineSeries {
                id: lockA0Series
                visible: lockAVisible0 && parameters.tccEnableSpeedTablesA[0].param.value.valid
                model: parameters.tccEnableSpeedTablesA[0].param.floatModel
                name: qsTr("Lock 1 A")
                style: Qt.SolidLine
                axisX: autoAxis.xAxis
                axisY: autoAxis.yAxis
            }
            RoleModeledLineSeries {
                id: lockA1Series
                visible: lockAVisible1 && parameters.tccEnableSpeedTablesA[1].param.value.valid
                model: parameters.tccEnableSpeedTablesA[1].param.floatModel
                name: qsTr("Lock 2 A")
                style: Qt.SolidLine
                axisX: autoAxis.xAxis
                axisY: autoAxis.yAxis
            }
            RoleModeledLineSeries {
                id: lockA2Series
                visible: lockAVisible2 && parameters.tccEnableSpeedTablesA[2].param.value.valid
                model: parameters.tccEnableSpeedTablesA[2].param.floatModel
                name: qsTr("Lock 3 A")
                style: Qt.SolidLine
                axisX: autoAxis.xAxis
                axisY: autoAxis.yAxis
            }
            RoleModeledLineSeries {
                id: lockA3Series
                visible: lockAVisible3 && parameters.tccEnableSpeedTablesA[3].param.value.valid
                model: parameters.tccEnableSpeedTablesA[3].param.floatModel
                name: qsTr("Lock 4 A")
                style: Qt.SolidLine
                axisX: autoAxis.xAxis
                axisY: autoAxis.yAxis
            }
            RoleModeledLineSeries {
                id: lockA4Series
                visible: lockAVisible4 && parameters.tccEnableSpeedTablesA[4].param.value.valid
                model: parameters.tccEnableSpeedTablesA[4].param.floatModel
                name: qsTr("Lock 5 A")
                style: Qt.SolidLine
                axisX: autoAxis.xAxis
                axisY: autoAxis.yAxis
            }
            RoleModeledLineSeries {
                id: lockA5Series
                visible: lockAVisible5 && parameters.tccEnableSpeedTablesA[5].param.value.valid
                model: parameters.tccEnableSpeedTablesA[5].param.floatModel
                name: qsTr("Lock 6 A")
                style: Qt.SolidLine
                axisX: autoAxis.xAxis
                axisY: autoAxis.yAxis
            }
            RoleModeledLineSeries {
                id: unlockA0Series
                visible: unlockAVisible0 && parameters.tccDisableSpeedTablesA[0].param.value.valid
                model: parameters.tccDisableSpeedTablesA[0].param.floatModel
                name: qsTr("Unlock 1 A")
                color: lockA0Series.color
                width: 2
                style: Qt.DashLine
                axisX: autoAxis.xAxis
                axisY: autoAxis.yAxis
            }
            RoleModeledLineSeries {
                id: unlockA1Series
                visible: unlockAVisible1 && parameters.tccDisableSpeedTablesA[1].param.value.valid
                model: parameters.tccDisableSpeedTablesA[1].param.floatModel
                name: qsTr("Unlock 2 A")
                color: lockA1Series.color
                width: 2
                style: Qt.DashLine
                axisX: autoAxis.xAxis
                axisY: autoAxis.yAxis
            }
            RoleModeledLineSeries {
                id: unlockA2Series
                visible: unlockAVisible2 && parameters.tccDisableSpeedTablesA[2].param.value.valid
                model: parameters.tccDisableSpeedTablesA[2].param.floatModel
                name: qsTr("Unlock 3 A")
                color: lockA2Series.color
                width: 2
                style: Qt.DashLine
                axisX: autoAxis.xAxis
                axisY: autoAxis.yAxis
            }
            RoleModeledLineSeries {
                id: unlockA3Series
                visible: unlockAVisible3 && parameters.tccDisableSpeedTablesA[3].param.value.valid
                model: parameters.tccDisableSpeedTablesA[3].param.floatModel
                name: qsTr("Unlock 4 A")
                color: lockA3Series.color
                width: 2
                style: Qt.DashLine
                axisX: autoAxis.xAxis
                axisY: autoAxis.yAxis
            }
            RoleModeledLineSeries {
                id: unlockA4Series
                visible: unlockAVisible4 && parameters.tccDisableSpeedTablesA[4].param.value.valid
                model: parameters.tccDisableSpeedTablesA[4].param.floatModel
                name: qsTr("Unlock 5 A")
                color: lockA4Series.color
                width: 2
                style: Qt.DashLine
                axisX: autoAxis.xAxis
                axisY: autoAxis.yAxis
            }
            RoleModeledLineSeries {
                id: unlockA5Series
                visible: unlockAVisible5 && parameters.tccDisableSpeedTablesA[5].param.value.valid
                model: parameters.tccDisableSpeedTablesA[5].param.floatModel
                name: qsTr("Unlock 6 A")
                color: lockA5Series.color
                width: 2
                style: Qt.DashLine
                axisX: autoAxis.xAxis
                axisY: autoAxis.yAxis
            }
            RoleModeledLineSeries {
                id: lockB0Series
                visible: lockBVisible0 && parameters.tccEnableSpeedTablesB[0].param.value.valid
                model: parameters.tccEnableSpeedTablesB[0].param.floatModel
                name: qsTr("Lock 1 B")
                color: lockA0Series.color
                width: 2
                style: Qt.DotLine
                axisX: autoAxis.xAxis
                axisY: autoAxis.yAxis
            }
            RoleModeledLineSeries {
                id: lockB1Series
                visible: lockBVisible1 && parameters.tccEnableSpeedTablesB[1].param.value.valid
                model: parameters.tccEnableSpeedTablesB[1].param.floatModel
                name: qsTr("Lock 2 B")
                color: lockA1Series.color
                width: 2
                style: Qt.DotLine
                axisX: autoAxis.xAxis
                axisY: autoAxis.yAxis
            }
            RoleModeledLineSeries {
                id: lockB2Series
                visible: lockBVisible2 && parameters.tccEnableSpeedTablesB[2].param.value.valid
                model: parameters.tccEnableSpeedTablesB[2].param.floatModel
                name: qsTr("Lock 3 B")
                color: lockA2Series.color
                width: 2
                style: Qt.DotLine
                axisX: autoAxis.xAxis
                axisY: autoAxis.yAxis
            }
            RoleModeledLineSeries {
                id: lockB3Series
                visible: lockBVisible3 && parameters.tccEnableSpeedTablesB[3].param.value.valid
                model: parameters.tccEnableSpeedTablesB[3].param.floatModel
                name: qsTr("Lock 4 B")
                color: lockA3Series.color
                width: 2
                style: Qt.DotLine
                axisX: autoAxis.xAxis
                axisY: autoAxis.yAxis
            }
            RoleModeledLineSeries {
                id: lockB4Series
                visible: lockBVisible4 && parameters.tccEnableSpeedTablesB[4].param.value.valid
                model: parameters.tccEnableSpeedTablesB[4].param.floatModel
                name: qsTr("Lock 5 B")
                color: lockA4Series.color
                width: 2
                style: Qt.DotLine
                axisX: autoAxis.xAxis
                axisY: autoAxis.yAxis
            }
            RoleModeledLineSeries {
                id: lockB5Series
                visible: lockBVisible5 && parameters.tccEnableSpeedTablesB[5].param.value.valid
                model: parameters.tccEnableSpeedTablesB[5].param.floatModel
                name: qsTr("Lock 6 B")
                color: lockA5Series.color
                width: 2
                style: Qt.DotLine
                axisX: autoAxis.xAxis
                axisY: autoAxis.yAxis
            }
            RoleModeledLineSeries {
                id: unlockB0Series
                visible: unlockBVisible0 && parameters.tccDisableSpeedTablesB[0].param.value.valid
                model: parameters.tccDisableSpeedTablesB[0].param.floatModel
                name: qsTr("Unlock 1 B")
                color: lockA0Series.color
                width: 2
                style: Qt.DashDotLine
                axisX: autoAxis.xAxis
                axisY: autoAxis.yAxis
            }
            RoleModeledLineSeries {
                id: unlockB1Series
                visible: unlockBVisible1 && parameters.tccDisableSpeedTablesB[1].param.value.valid
                model: parameters.tccDisableSpeedTablesB[1].param.floatModel
                name: qsTr("Unlock 2 B")
                color: lockA1Series.color
                width: 2
                style: Qt.DashDotLine
                axisX: autoAxis.xAxis
                axisY: autoAxis.yAxis
            }
            RoleModeledLineSeries {
                id: unlockB2Series
                visible: unlockBVisible2 && parameters.tccDisableSpeedTablesB[2].param.value.valid
                model: parameters.tccDisableSpeedTablesB[2].param.floatModel
                name: qsTr("Unlock 3 B")
                color: lockA2Series.color
                width: 2
                style: Qt.DashDotLine
                axisX: autoAxis.xAxis
                axisY: autoAxis.yAxis
            }
            RoleModeledLineSeries {
                id: unlockB3Series
                visible: unlockBVisible3 && parameters.tccDisableSpeedTablesB[3].param.value.valid
                model: parameters.tccDisableSpeedTablesB[3].param.floatModel
                name: qsTr("Unlock 4 B")
                color: lockA3Series.color
                width: 2
                style: Qt.DashDotLine
                axisX: autoAxis.xAxis
                axisY: autoAxis.yAxis
            }
            RoleModeledLineSeries {
                id: unlockB4Series
                visible: unlockBVisible4 && parameters.tccDisableSpeedTablesB[4].param.value.valid
                model: parameters.tccDisableSpeedTablesB[4].param.floatModel
                name: qsTr("Unlock 5 B")
                color: lockA4Series.color
                width: 2
                style: Qt.DashDotLine
                axisX: autoAxis.xAxis
                axisY: autoAxis.yAxis
            }
            RoleModeledLineSeries {
                id: unlockB5Series
                visible: unlockBVisible5 && parameters.tccDisableSpeedTablesB[5].param.value.valid
                model: parameters.tccDisableSpeedTablesB[5].param.floatModel
                name: qsTr("Unlock 6 B")
                color: lockA5Series.color
                width: 2
                style: Qt.DashDotLine
                axisX: autoAxis.xAxis
                axisY: autoAxis.yAxis
            }
        }
        GroupBox {
            title: "Common"
            ColumnLayout {
                RowLayout {
                    ScalarParamSpinBox {
                        metaParam: parameters.tccPrefillTime
                    }
                    ScalarParamSpinBox {
                        metaParam: parameters.tccStrokeTime
                    }
                    ScalarParamSpinBox {
                        metaParam: parameters.tccApplyTime
                    }
                    ScalarParamSpinBox {
                        metaParam: parameters.tccUnlockTime
                    }
                    EncodingParamEdit {
                        name: qsTr("Always Locked")
                        metaParam: parameters.tccAlwaysLocked
                    }
                }
                RowLayout {
                    Button {
                        Layout.margins: 8
                        text: "Percentage and PID"
                        onClicked: {
                            percentagePidDialog.showNormal()
                            percentagePidDialog.raise()
                        }
                        enabled: parameters.tccPrefillPercentage.param.valid
                    }
                    Button {
                        Layout.margins: 8
                        text: "Pressure and PID"
                        onClicked: {
                            pressurePidDialog.showNormal()
                            pressurePidDialog.raise()
                        }
                        enabled: parameters.tccPrefillPressure.param.valid
                    }
                    TableParamEditButton {
                        Layout.margins: 8
                        tableParam: parameters.torqueConverterMult
                        xLabel: "Speed Ratio"
                        valueLabel: "Torque Ratio"
                    }
                }
            }
        }
    }

    XYSeriesAutoAxis {
        id: autoAxis
        series: [
            lockA0Series,
            lockA1Series,
            lockA2Series,
            lockA3Series,
            lockA4Series,
            lockA5Series,
            unlockA0Series,
            unlockA1Series,
            unlockA2Series,
            unlockA3Series,
            unlockA4Series,
            unlockA5Series,
            lockB0Series,
            lockB1Series,
            lockB2Series,
            lockB3Series,
            lockB4Series,
            lockB5Series,
            unlockB0Series,
            unlockB1Series,
            unlockB2Series,
            unlockB3Series,
            unlockB4Series,
            unlockB5Series,
        ]
        xAxis.titleText: qsTr("Torque ") + parameters.tccEnableSpeedTablesA[0].param.x.slot.unit
        yAxis.titleText: qsTr("Speed ") + parameters.tccEnableSpeedTablesA[0].param.value.slot.unit
    }

    ColumnLayout {
        Layout.fillHeight: true
        Layout.alignment: Qt.AlignTop
        RowLayout {
            Layout.fillHeight: true
            Layout.fillWidth: true
            GroupBox {
                title: "Profile A"
                ColumnLayout {
                    GroupBox {
                        title: "Graph"
                        RowLayout {
                            ColumnLayout {
                                Repeater {
                                    model: parameters.tccEnableSpeedTablesA.length
                                    CheckBox {
                                        checked: parameters.tccEnableSpeedTablesA[index].param.value.valid
                                        enabled: parameters.tccEnableSpeedTablesA[index].param.value.valid
                                        text: parameters.tccEnableSpeedTablesA[index].name.replace(/TCC Enable Speed Gear ([1-9RN]).*/, "Lock $1")
                                        onCheckedChanged: {
                                            setTraceVisible(false, false, index, checked)
                                        }
                                        Layout.minimumWidth: 40
                                    }
                                }
                            }
                            ColumnLayout {
                                Repeater {
                                    model: parameters.tccDisableSpeedTablesA.length
                                    CheckBox {
                                        checked: false
                                        enabled: parameters.tccDisableSpeedTablesA[index].param.value.valid
                                        text: parameters.tccDisableSpeedTablesA[index].name.replace(/TCC Disable Speed Gear ([1-9RN]).*/, "Unlock $1")
                                        onCheckedChanged: {
                                            setTraceVisible(true, false, index, checked)
                                        }
                                        Layout.minimumWidth: 40
                                    }
                                }
                            }
                        }
                    }

                    ScalarParamSpinBox {
                        name: qsTr("Enable Gear")
                        metaParam: parameters.tccEnableGearA
                        minimumValue: 1
                        maximumValue: 8
                    }
                    EncodingParamEdit {
                        name: qsTr("Disable In Switch Shift")
                        metaParam: parameters.tccDisableInSwitchShiftA
                    }
                    EncodingParamEdit {
                        name: qsTr("Manual Mode")
                        metaParam: parameters.tccManualModeA
                    }

                    Button {
                        text: qsTr("Throttle/Speed Limits")
                        onClicked: {
                            limitsADialog.showNormal()
                            limitsADialog.raise()
                        }
                    }
                    TableByGearEditMenuButton {
                        text: qsTr("Enable Speed Tables")
                        xLabel: qsTr("Torque")
                        valueLabel: qsTr("Speed")
                        tableParam: parameters.tccEnableSpeedTablesA
                    }
                    TableByGearEditMenuButton {
                        text: qsTr("Disable Speed Tables")
                        xLabel: qsTr("Torque")
                        valueLabel: qsTr("Speed")
                        tableParam: parameters.tccDisableSpeedTablesA
                    }

                    ScalarListDialog {
                        id: limitsADialog
                        paramLists: [
                            ScalarMetaParamList {
                                params: [
                                    parameters.tccMinThrottleA,
                                    parameters.tccMaxThrottleA,
                                    parameters.tccEnableTOSSA,
                                    parameters.tccDisableTOSSPercentA,
                                ]
                            }
                        ]
                    }
                }
            }
            GroupBox {
                title: "Profile B"
                ColumnLayout {
                    GroupBox {
                        title: "Graph"
                        RowLayout {
                            ColumnLayout {
                                Repeater {
                                    model: parameters.tccEnableSpeedTablesB.length
                                    CheckBox {
                                        checked: false
                                        enabled: parameters.tccEnableSpeedTablesB[index].param.value.valid
                                        text: parameters.tccEnableSpeedTablesB[index].name.replace(/TCC Enable Speed Gear ([1-9RN]).*/, "Lock $1")
                                        onCheckedChanged: {
                                            setTraceVisible(false, true, index, checked)
                                        }
                                        Layout.minimumWidth: 40
                                    }
                                }
                            }
                            ColumnLayout {
                                Repeater {
                                    model: parameters.tccDisableSpeedTablesB.length
                                    CheckBox {
                                        checked: false
                                        enabled: parameters.tccDisableSpeedTablesB[index].param.value.valid
                                        text: parameters.tccDisableSpeedTablesB[index].name.replace(/TCC Disable Speed Gear ([1-9RN]).*/, "Unlock $1")
                                        onCheckedChanged: {
                                            setTraceVisible(true, true, index, checked)
                                        }
                                        Layout.minimumWidth: 40
                                    }
                                }
                            }
                        }
                    }

                    ScalarParamSpinBox {
                        name: qsTr("Enable Gear")
                        metaParam: parameters.tccEnableGearB
                        minimumValue: 1
                        maximumValue: 8
                    }
                    EncodingParamEdit {
                        name: qsTr("Disable In Switch Shift")
                        metaParam: parameters.tccDisableInSwitchShiftB
                    }
                    EncodingParamEdit {
                        name: qsTr("Manual Mode")
                        metaParam: parameters.tccManualModeB
                    }

                    Button {
                        text: qsTr("Throttle/TOSS Limits")
                        onClicked: {
                            limitsBDialog.showNormal()
                            limitsBDialog.raise()
                        }
                    }
                    TableByGearEditMenuButton {
                        text: qsTr("Enable Speed Tables")
                        xLabel: qsTr("Torque")
                        valueLabel: qsTr("Speed")
                        tableParam: parameters.tccEnableSpeedTablesB
                    }
                    TableByGearEditMenuButton {
                        text: qsTr("Disable Speed Tables")
                        xLabel: qsTr("Torque")
                        valueLabel: qsTr("Speed")
                        tableParam: parameters.tccDisableSpeedTablesB
                    }

                    ScalarListDialog {
                        id: limitsBDialog
                        paramLists: [
                            ScalarMetaParamList {
                                params: [
                                    parameters.tccMinThrottleB,
                                    parameters.tccMaxThrottleB,
                                    parameters.tccEnableTOSSB,
                                    parameters.tccDisableTOSSPercentB,
                                ]
                            }
                        ]
                    }
                }
            }
        }
    }

    ScalarListDialog {
        id: percentagePidDialog
        paramLists: [
            ScalarMetaParamList {
                params: [
                    parameters.tccPrefillPercentage,
                    parameters.tccStrokePercentage,
                    parameters.tccMaxPercentage,
                    parameters.tccPercentageProportionalConstant,
                    parameters.tccPercentageIntegralConstant,
                    parameters.tccPercentageDerivativeConstant
                ]
            }
        ]
    }

    ScalarListDialog {
        id: pressurePidDialog
        paramLists: [
            ScalarMetaParamList {
                params: [
                    parameters.tccPrefillPressure,
                    parameters.tccStrokePressure,
                    parameters.tccMaxPressure,
                    parameters.tccPressureProportionalConstant,
                    parameters.tccPressureIntegralConstant,
                    parameters.tccPressureDerivativeConstant
                ]
            }
        ]
    }
}
