import QtQuick 2.5
import QtQuick.Controls 1.4
import QtQuick.Layouts 1.2
import QtQuick.Window 2.2
import QtQuick.Dialogs 1.2
import QtCharts 2.0
import com.hgmelectronics.setuptools.xcp 1.0
import com.hgmelectronics.setuptools 1.0
import com.hgmelectronics.setuptools.ui 1.0

ColumnLayout {
    property Parameters parameters
    anchors.fill: parent
    anchors.margins: 5
    spacing: 5

    property bool upshiftAVisible0: parameters.upshiftTablesA[0].param.value.valid
    property bool upshiftAVisible1: parameters.upshiftTablesA[1].param.value.valid
    property bool upshiftAVisible2: parameters.upshiftTablesA[2].param.value.valid
    property bool upshiftAVisible3: parameters.upshiftTablesA[3].param.value.valid
    property bool upshiftAVisible4: parameters.upshiftTablesA[4].param.value.valid
    property bool upshiftBVisible0: false
    property bool upshiftBVisible1: false
    property bool upshiftBVisible2: false
    property bool upshiftBVisible3: false
    property bool upshiftBVisible4: false
    property bool downshiftAVisible0: false
    property bool downshiftAVisible1: false
    property bool downshiftAVisible2: false
    property bool downshiftAVisible3: false
    property bool downshiftAVisible4: false
    property bool downshiftBVisible0: false
    property bool downshiftBVisible1: false
    property bool downshiftBVisible2: false
    property bool downshiftBVisible3: false
    property bool downshiftBVisible4: false

    function getShiftVisible(isDownshift, isB, index) {
        if(!isDownshift) {
            if(!isB) {
                switch(index) {
                case 0:
                    return upshiftAVisible0
                case 1:
                    return upshiftAVisible1
                case 2:
                    return upshiftAVisible2
                case 3:
                    return upshiftAVisible3
                case 4:
                    return upshiftAVisible4
                }
            }
            else {
                switch(index) {
                case 0:
                    return upshiftBVisible0
                case 1:
                    return upshiftBVisible1
                case 2:
                    return upshiftBVisible2
                case 3:
                    return upshiftBVisible3
                case 4:
                    return upshiftBVisible4
                }

            }
        }
        else {
            if(!isB) {
                switch(index) {
                case 0:
                    return downshiftAVisible0
                case 1:
                    return downshiftAVisible1
                case 2:
                    return downshiftAVisible2
                case 3:
                    return downshiftAVisible3
                case 4:
                    return downshiftAVisible4
                }
            }
            else {
                switch(index) {
                case 0:
                    return downshiftBVisible0
                case 1:
                    return downshiftBVisible1
                case 2:
                    return downshiftBVisible2
                case 3:
                    return downshiftBVisible3
                case 4:
                    return downshiftBVisible4
                }

            }

        }
    }

    function setShiftVisible(isDownshift, isB, index, value) {
        if(!isDownshift) {
            if(!isB) {
                switch(index) {
                case 0:
                    return upshiftAVisible0 = value
                case 1:
                    return upshiftAVisible1 = value
                case 2:
                    return upshiftAVisible2 = value
                case 3:
                    return upshiftAVisible3 = value
                case 4:
                    return upshiftAVisible4 = value
                }
            }
            else {
                switch(index) {
                case 0:
                    return upshiftBVisible0 = value
                case 1:
                    return upshiftBVisible1 = value
                case 2:
                    return upshiftBVisible2 = value
                case 3:
                    return upshiftBVisible3 = value
                case 4:
                    return upshiftBVisible4 = value
                }

            }
        }
        else {
            if(!isB) {
                switch(index) {
                case 0:
                    return downshiftAVisible0 = value
                case 1:
                    return downshiftAVisible1 = value
                case 2:
                    return downshiftAVisible2 = value
                case 3:
                    return downshiftAVisible3 = value
                case 4:
                    return downshiftAVisible4 = value
                }
            }
            else {
                switch(index) {
                case 0:
                    return downshiftBVisible0 = value
                case 1:
                    return downshiftBVisible1 = value
                case 2:
                    return downshiftBVisible2 = value
                case 3:
                    return downshiftBVisible3 = value
                case 4:
                    return downshiftBVisible4 = value
                }

            }

        }
    }

    RowLayout {
        Layout.fillHeight: true
        Layout.minimumHeight: 150
        ChartView {
            id: plot

            Layout.fillWidth: true
            Layout.fillHeight: true
            anchors.bottom: parent.bottom
            anchors.top: parent.top
            margins.left: 0
            margins.right: 0
            margins.bottom: 0
            margins.top: 0

            antialiasing: true
            legend.visible: false   // FIXME review whether this is a good idea

            RoleModeledLineSeries {
                id: upshiftA0Series
                visible: upshiftAVisible0 && parameters.upshiftTablesA[0].param.value.valid
                model: parameters.upshiftTablesA[0].param.floatModel
                name: qsTr("1-2 A")
                style: Qt.SolidLine
                axisX: autoAxis.xAxis
                axisY: autoAxis.yAxis
            }
            RoleModeledLineSeries {
                id: upshiftA1Series
                visible: upshiftAVisible1 && parameters.upshiftTablesA[1].param.value.valid
                model: parameters.upshiftTablesA[1].param.floatModel
                name: qsTr("2-3 A")
                style: Qt.SolidLine
                axisX: autoAxis.xAxis
                axisY: autoAxis.yAxis
            }
            RoleModeledLineSeries {
                id: upshiftA2Series
                visible: upshiftAVisible2 && parameters.upshiftTablesA[2].param.value.valid
                model: parameters.upshiftTablesA[2].param.floatModel
                name: qsTr("3-4 A")
                style: Qt.SolidLine
                axisX: autoAxis.xAxis
                axisY: autoAxis.yAxis
            }
            RoleModeledLineSeries {
                id: upshiftA3Series
                visible: upshiftAVisible3 && parameters.upshiftTablesA[3].param.value.valid
                model: parameters.upshiftTablesA[3].param.floatModel
                name: qsTr("4-5 A")
                style: Qt.SolidLine
                axisX: autoAxis.xAxis
                axisY: autoAxis.yAxis
            }
            RoleModeledLineSeries {
                id: upshiftA4Series
                visible: upshiftAVisible4 && parameters.upshiftTablesA[4].param.value.valid
                model: parameters.upshiftTablesA[4].param.floatModel
                name: qsTr("5-6 A")
                style: Qt.SolidLine
                axisX: autoAxis.xAxis
                axisY: autoAxis.yAxis
            }
            RoleModeledLineSeries {
                id: downshiftA0Series
                visible: downshiftAVisible0 && parameters.downshiftTablesA[0].param.value.valid
                model: parameters.downshiftTablesA[0].param.floatModel
                name: qsTr("2-1 A")
                color: upshiftA0Series.color
                width: 2
                style: Qt.DashLine
                axisX: autoAxis.xAxis
                axisY: autoAxis.yAxis
            }
            RoleModeledLineSeries {
                id: downshiftA1Series
                visible: downshiftAVisible1 && parameters.downshiftTablesA[1].param.value.valid
                model: parameters.downshiftTablesA[1].param.floatModel
                name: qsTr("3-2 A")
                color: upshiftA1Series.color
                width: 2
                style: Qt.DashLine
                axisX: autoAxis.xAxis
                axisY: autoAxis.yAxis
            }
            RoleModeledLineSeries {
                id: downshiftA2Series
                visible: downshiftAVisible2 && parameters.downshiftTablesA[2].param.value.valid
                model: parameters.downshiftTablesA[2].param.floatModel
                name: qsTr("4-3 A")
                color: upshiftA2Series.color
                width: 2
                style: Qt.DashLine
                axisX: autoAxis.xAxis
                axisY: autoAxis.yAxis
            }
            RoleModeledLineSeries {
                id: downshiftA3Series
                visible: downshiftAVisible3 && parameters.downshiftTablesA[3].param.value.valid
                model: parameters.downshiftTablesA[3].param.floatModel
                name: qsTr("5-4 A")
                color: upshiftA3Series.color
                width: 2
                style: Qt.DashLine
                axisX: autoAxis.xAxis
                axisY: autoAxis.yAxis
            }
            RoleModeledLineSeries {
                id: downshiftA4Series
                visible: downshiftAVisible4 && parameters.downshiftTablesA[4].param.value.valid
                model: parameters.downshiftTablesA[4].param.floatModel
                name: qsTr("6-5 A")
                color: upshiftA4Series.color
                width: 2
                style: Qt.DashLine
                axisX: autoAxis.xAxis
                axisY: autoAxis.yAxis
            }
            RoleModeledLineSeries {
                id: upshiftB0Series
                visible: upshiftBVisible0 && parameters.upshiftTablesB[0].param.value.valid
                model: parameters.upshiftTablesB[0].param.floatModel
                name: qsTr("1-2 B")
                color: upshiftA0Series.color
                width: 2
                style: Qt.DotLine
                axisX: autoAxis.xAxis
                axisY: autoAxis.yAxis
            }
            RoleModeledLineSeries {
                id: upshiftB1Series
                visible: upshiftBVisible1 && parameters.upshiftTablesB[1].param.value.valid
                model: parameters.upshiftTablesB[1].param.floatModel
                name: qsTr("2-3 B")
                color: upshiftA1Series.color
                width: 2
                style: Qt.DotLine
                axisX: autoAxis.xAxis
                axisY: autoAxis.yAxis
            }
            RoleModeledLineSeries {
                id: upshiftB2Series
                visible: upshiftBVisible2 && parameters.upshiftTablesB[2].param.value.valid
                model: parameters.upshiftTablesB[2].param.floatModel
                name: qsTr("3-4 B")
                color: upshiftA2Series.color
                width: 2
                style: Qt.DotLine
                axisX: autoAxis.xAxis
                axisY: autoAxis.yAxis
            }
            RoleModeledLineSeries {
                id: upshiftB3Series
                visible: upshiftBVisible3 && parameters.upshiftTablesB[3].param.value.valid
                model: parameters.upshiftTablesB[3].param.floatModel
                name: qsTr("4-5 B")
                color: upshiftA3Series.color
                width: 2
                style: Qt.DotLine
                axisX: autoAxis.xAxis
                axisY: autoAxis.yAxis
            }
            RoleModeledLineSeries {
                id: upshiftB4Series
                visible: upshiftBVisible4 && parameters.upshiftTablesB[4].param.value.valid
                model: parameters.upshiftTablesB[4].param.floatModel
                name: qsTr("5-6 B")
                color: upshiftA4Series.color
                width: 2
                style: Qt.DotLine
                axisX: autoAxis.xAxis
                axisY: autoAxis.yAxis
            }
            RoleModeledLineSeries {
                id: downshiftB0Series
                visible: downshiftBVisible0 && parameters.downshiftTablesB[0].param.value.valid
                model: parameters.downshiftTablesB[0].param.floatModel
                name: qsTr("2-1 B")
                color: upshiftA0Series.color
                width: 2
                style: Qt.DashDotLine
                axisX: autoAxis.xAxis
                axisY: autoAxis.yAxis
            }
            RoleModeledLineSeries {
                id: downshiftB1Series
                visible: downshiftBVisible1 && parameters.downshiftTablesB[1].param.value.valid
                model: parameters.downshiftTablesB[1].param.floatModel
                name: qsTr("3-2 B")
                color: upshiftA1Series.color
                width: 2
                style: Qt.DashDotLine
                axisX: autoAxis.xAxis
                axisY: autoAxis.yAxis
            }
            RoleModeledLineSeries {
                id: downshiftB2Series
                visible: downshiftBVisible2 && parameters.downshiftTablesB[2].param.value.valid
                model: parameters.downshiftTablesB[2].param.floatModel
                name: qsTr("4-3 B")
                color: upshiftA2Series.color
                width: 2
                style: Qt.DashDotLine
                axisX: autoAxis.xAxis
                axisY: autoAxis.yAxis
            }
            RoleModeledLineSeries {
                id: downshiftB3Series
                visible: downshiftBVisible3 && parameters.downshiftTablesB[3].param.value.valid
                model: parameters.downshiftTablesB[3].param.floatModel
                name: qsTr("5-4 B")
                color: upshiftA3Series.color
                width: 2
                style: Qt.DashDotLine
                axisX: autoAxis.xAxis
                axisY: autoAxis.yAxis
            }
            RoleModeledLineSeries {
                id: downshiftB4Series
                visible: downshiftBVisible4 && parameters.downshiftTablesB[4].param.value.valid
                model: parameters.downshiftTablesB[4].param.floatModel
                name: qsTr("6-5 B")
                color: upshiftA4Series.color
                width: 2
                style: Qt.DashDotLine
                axisX: autoAxis.xAxis
                axisY: autoAxis.yAxis
            }
        }

        XYSeriesAutoAxis {
            id: autoAxis
            series: [
                upshiftA0Series,
                upshiftA1Series,
                upshiftA2Series,
                upshiftA3Series,
                upshiftA4Series,
                downshiftA0Series,
                downshiftA1Series,
                downshiftA2Series,
                downshiftA3Series,
                downshiftA4Series,
                upshiftB0Series,
                upshiftB1Series,
                upshiftB2Series,
                upshiftB3Series,
                upshiftB4Series,
                downshiftB0Series,
                downshiftB1Series,
                downshiftB2Series,
                downshiftB3Series,
                downshiftB4Series,
            ]
            xAxis.titleText: qsTr("Torque ") + parameters.upshiftTablesA[0].param.x.slot.unit
            yAxis.titleText: qsTr("Speed ") + parameters.upshiftTablesA[0].param.value.slot.unit
        }

        GroupBox {
            title: "A"
            RowLayout {
                ColumnLayout {
                    Repeater {
                        id: upshiftAVisible
                        model: parameters.upshiftTablesA.length
                        CheckBox {
                            checked: parameters.upshiftTablesA[index].param.value.valid
                            enabled: parameters.upshiftTablesA[index].param.value.valid
                            text: parameters.upshiftTablesA[index].name.replace(/Shift Speed ([1-9RN]-[1-9RN]).*/, "$1")
                            onCheckedChanged: {
                                setShiftVisible(false, false, index, checked)
                            }
                            Layout.minimumWidth: 40
                        }
                    }
                }
                ColumnLayout {
                    Repeater {
                        model: parameters.downshiftTablesA.length
                        CheckBox {
                            checked: false
                            enabled: parameters.downshiftTablesA[index].param.value.valid && (parameters.shiftTablesDownLockedA.param.floatVal == 0)
                            text: parameters.downshiftTablesA[index].name.replace(/Shift Speed ([1-9RN]-[1-9RN]).*/, "$1")
                            onCheckedChanged: {
                                setShiftVisible(true, false, index, checked)
                            }
                            Layout.minimumWidth: 40
                        }
                    }
                }
            }
        }

        GroupBox {
            title: "B"
            RowLayout {
                ColumnLayout {
                    Repeater {
                        model: parameters.upshiftTablesB.length
                        CheckBox {
                            checked: false
                            enabled: parameters.upshiftTablesB[index].param.value.valid
                            text: parameters.upshiftTablesB[index].name.replace(/Shift Speed ([1-9RN]-[1-9RN]).*/, "$1")
                            onCheckedChanged: {
                                setShiftVisible(false, true, index, checked)
                            }
                            Layout.minimumWidth: 40
                        }
                    }
                }
                ColumnLayout {
                    Repeater {
                        model: parameters.downshiftTablesB.length
                        CheckBox {
                            checked: false
                            enabled: parameters.downshiftTablesB[index].param.value.valid && (parameters.shiftTablesDownLockedB.param.floatVal == 0)
                            text: parameters.downshiftTablesB[index].name.replace(/Shift Speed ([1-9RN]-[1-9RN]).*/, "$1")
                            onCheckedChanged: {
                                setShiftVisible(true, true, index, checked)
                            }
                            Layout.minimumWidth: 40
                        }
                    }
                }
            }
        }

    }

    GroupBox {
        title: "Profile A"
        Layout.fillWidth: true
        ColumnLayout {
            RowLayout {
                ShiftTableByShiftEditMenuButton {
                    text: qsTr("Upshift Tables")
                    speedTableParams: parameters.upshiftTablesA
                    rpmTableParams: parameters.rpmUpshiftTablesA
                    gearNumberRatioParam: parameters.transmissionGearNumbersRatios.param
                }
                ShiftTableByShiftEditMenuButton {
                    text: qsTr("Downshift Tables")
                    speedTableParams: parameters.downshiftTablesA
                    rpmTableParams: parameters.rpmDownshiftTablesA
                    gearNumberRatioParam: parameters.transmissionGearNumbersRatios.param
                    isDownshift: true
                    enabled: (parameters.shiftTablesDownLockedA.param.floatVal == 0 && parameters.shiftTablesDownLockedA.param.valid)
                }
            }
            RowLayout {
                EncodingParamEdit {
                    metaParam: parameters.shiftTablesDownLockedA
                    name: qsTr("Downshift Locked")
                    implicitWidth: 132
                }
                ScalarParamSpinBox {
                    metaParam: parameters.shiftSpeedAdjustA
                    name: qsTr("Shift Speed Adjust")
                    implicitWidth: 132
                }
                ScalarParamSpinBox {
                    metaParam: parameters.shiftDownshiftOffsetA
                    name: qsTr("Downshift Offset")
                    implicitWidth: 132
                }
                ScalarParamSpinBox {
                    metaParam: parameters.shiftMaxEngineSpeedA
                    name: qsTr("Max Engine Speed")
                    implicitWidth: 132
                }
                EncodingParamEdit {
                    metaParam: parameters.shiftManualModeA
                    name: qsTr("Manual Mode")
                    implicitWidth: 132
                }
            }
        }
    }

    GroupBox {
        title: "Profile B"
        Layout.fillWidth: true
        ColumnLayout {
            RowLayout {
                ShiftTableByShiftEditMenuButton {
                    text: qsTr("Upshift Tables")
                    speedTableParams: parameters.upshiftTablesB
                    rpmTableParams: parameters.rpmUpshiftTablesB
                    gearNumberRatioParam: parameters.transmissionGearNumbersRatios.param
                }
                ShiftTableByShiftEditMenuButton {
                    text: qsTr("Downshift Tables")
                    speedTableParams: parameters.downshiftTablesB
                    rpmTableParams: parameters.rpmDownshiftTablesB
                    gearNumberRatioParam: parameters.transmissionGearNumbersRatios.param
                    isDownshift: true
                    enabled: (parameters.shiftTablesDownLockedB.param.floatVal == 0 && parameters.shiftTablesDownLockedA.param.valid)
                }
            }
            RowLayout {
                EncodingParamEdit {
                    metaParam: parameters.shiftTablesDownLockedB
                    name: "Downshift Locked"
                    implicitWidth: 132
                }
                ScalarParamSpinBox {
                    metaParam: parameters.shiftSpeedAdjustB
                    name: qsTr("Shift Speed Adjust")
                    implicitWidth: 132
                }
                ScalarParamSpinBox {
                    metaParam: parameters.shiftDownshiftOffsetB
                    name: qsTr("Downshift Offset")
                    implicitWidth: 132
                }
                ScalarParamSpinBox {
                    metaParam: parameters.shiftMaxEngineSpeedB
                    name: qsTr("Max Engine Speed")
                    implicitWidth: 132
                }
                EncodingParamEdit {
                    metaParam: parameters.shiftManualModeB
                    name: qsTr("Manual Mode")
                    implicitWidth: 132
                }
            }
        }

    }
    GroupBox {
        title: "Common"
        Layout.fillWidth: true
        RowLayout {
            ScalarParamSpinBox {
                Layout.alignment: Qt.AlignTop
                metaParam: parameters.reverseLockoutSpeed
            }
        }
    }
}
