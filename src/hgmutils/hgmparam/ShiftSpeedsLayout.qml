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
        TablePlot {
            id: shiftABPlot
            plots: [
                XYTrace {
                    tableModel: parameters.upshiftTablesA[0].param.stringModel
                    valid: upshiftAVisible0 && parameters.upshiftTablesA[0].param.value.valid
                    baseColor: cs2Defaults.preferredPlotColors[0]
                    fill: false
                },
                XYTrace {
                    tableModel: parameters.upshiftTablesA[1].param.stringModel
                    valid: upshiftAVisible1 && parameters.upshiftTablesA[1].param.value.valid
                    baseColor: cs2Defaults.preferredPlotColors[1]
                    fill: false
                },
                XYTrace {
                    tableModel: parameters.upshiftTablesA[2].param.stringModel
                    valid: upshiftAVisible2 && parameters.upshiftTablesA[2].param.value.valid
                    baseColor: cs2Defaults.preferredPlotColors[2]
                    fill: false
                },
                XYTrace {
                    tableModel: parameters.upshiftTablesA[3].param.stringModel
                    valid: upshiftAVisible3 && parameters.upshiftTablesA[3].param.value.valid
                    baseColor: cs2Defaults.preferredPlotColors[3]
                    fill: false
                },
                XYTrace {
                    tableModel: parameters.upshiftTablesA[4].param.stringModel
                    valid: upshiftAVisible4 && parameters.upshiftTablesA[4].param.value.valid
                    baseColor: cs2Defaults.preferredPlotColors[4]
                    fill: false
                },
                XYTrace {
                    tableModel: parameters.upshiftTablesB[0].param.stringModel
                    valid: upshiftBVisible0 && parameters.upshiftTablesB[0].param.value.valid
                    baseColor: cs2Defaults.preferredPlotColors[5]
                    fill: false
                },
                XYTrace {
                    tableModel: parameters.upshiftTablesB[1].param.stringModel
                    valid: upshiftBVisible1 && parameters.upshiftTablesB[1].param.value.valid
                    baseColor: cs2Defaults.preferredPlotColors[6]
                    fill: false
                },
                XYTrace {
                    tableModel: parameters.upshiftTablesB[2].param.stringModel
                    valid: upshiftBVisible2 && parameters.upshiftTablesB[2].param.value.valid
                    baseColor: cs2Defaults.preferredPlotColors[7]
                    fill: false
                },
                XYTrace {
                    tableModel: parameters.upshiftTablesB[3].param.stringModel
                    valid: upshiftBVisible3 && parameters.upshiftTablesB[3].param.value.valid
                    baseColor: cs2Defaults.preferredPlotColors[8]
                    fill: false
                },
                XYTrace {
                    tableModel: parameters.upshiftTablesB[4].param.stringModel
                    valid: upshiftBVisible4 && parameters.upshiftTablesB[4].param.value.valid
                    baseColor: cs2Defaults.preferredPlotColors[9]
                    fill: false
                },
                XYTrace {
                    tableModel: parameters.downshiftTablesA[0].param.stringModel
                    valid: downshiftAVisible0 && parameters.downshiftTablesA[0].param.value.valid
                    baseColor: cs2Defaults.preferredPlotColors[10]
                    fill: false
                },
                XYTrace {
                    tableModel: parameters.downshiftTablesA[1].param.stringModel
                    valid: downshiftAVisible1 &&parameters.downshiftTablesA[1].param.value.valid
                    baseColor: cs2Defaults.preferredPlotColors[11]
                    fill: false
                },
                XYTrace {
                    tableModel: parameters.downshiftTablesA[2].param.stringModel
                    valid: downshiftAVisible2 && parameters.downshiftTablesA[2].param.value.valid
                    baseColor: cs2Defaults.preferredPlotColors[12]
                    fill: false
                },
                XYTrace {
                    tableModel: parameters.downshiftTablesA[3].param.stringModel
                    valid: downshiftAVisible3 && parameters.downshiftTablesA[3].param.value.valid
                    baseColor: cs2Defaults.preferredPlotColors[13]
                    fill: false
                },
                XYTrace {
                    tableModel: parameters.downshiftTablesA[4].param.stringModel
                    valid: downshiftAVisible4 && parameters.downshiftTablesA[4].param.value.valid
                    baseColor: cs2Defaults.preferredPlotColors[14]
                    fill: false
                },
                XYTrace {
                    tableModel: parameters.downshiftTablesB[0].param.stringModel
                    valid: downshiftBVisible0 && parameters.downshiftTablesB[0].param.value.valid
                    baseColor: cs2Defaults.preferredPlotColors[15]
                    fill: false
                },
                XYTrace {
                    tableModel: parameters.downshiftTablesB[1].param.stringModel
                    valid: downshiftBVisible1 && parameters.downshiftTablesB[1].param.value.valid
                    baseColor: cs2Defaults.preferredPlotColors[16]
                    fill: false
                },
                XYTrace {
                    tableModel: parameters.downshiftTablesB[2].param.stringModel
                    valid: downshiftBVisible2 && parameters.downshiftTablesB[2].param.value.valid
                    baseColor: cs2Defaults.preferredPlotColors[17]
                    fill: false
                },
                XYTrace {
                    tableModel: parameters.downshiftTablesB[3].param.stringModel
                    valid: downshiftBVisible3 && parameters.downshiftTablesB[3].param.value.valid
                    baseColor: cs2Defaults.preferredPlotColors[18]
                    fill: false
                },
                XYTrace {
                    tableModel: parameters.downshiftTablesB[4].param.stringModel
                    valid: downshiftBVisible4 && parameters.downshiftTablesB[4].param.value.valid
                    baseColor: cs2Defaults.preferredPlotColors[19]
                    fill: false
                }
            ]
            Layout.fillWidth: true
            Layout.fillHeight: true
            anchors.bottom: parent.bottom
            anchors.top: parent.top
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
                                shiftABPlot.replot()
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
                                shiftABPlot.replot()
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
                                shiftABPlot.replot()
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
                                shiftABPlot.replot()
                            }
                            Layout.minimumWidth: 40
                        }
                    }
                }
            }
        }

        TableParamView {
            xLabel: "Gear"
            valueLabel: "Ratio"
            xColumnWidth: 60
            valueColumnWidth: 60
            model: parameters.transmissionGearNumbersRatios.param.stringModel
        }
    }

    GroupBox {
        title: "Profile A"
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
                    enabled: (parameters.shiftTablesDownLockedA.param.floatVal == 0)
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
                    enabled: (parameters.shiftTablesDownLockedB.param.floatVal == 0)
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


    RowLayout {
        TableByShiftEditMenuButton {
            Layout.margins: 8
            text: qsTr("Shift Torque Limits")
            xLabel: qsTr("Driver Torque")
            valueLabel: qsTr("Limit")
            tableParam: parameters.shiftTorqueLimits
        }

        Button {
            text: "TS Torque Transfer Time"
            onClicked: {
                tsTorqueTransferDialog.showNormal()
                tsTorqueTransferDialog.raise()
            }
            enabled: tsTorqueTransferDialog.allListsAnyValid
        }
        ScalarListDialog {
            id: tsTorqueTransferDialog
            paramLists: [
                parameters.transmissionTorqueSpeedTransferTime
            ]
        }

        Button {
            text: "ST Torque Transfer Time"
            onClicked: {
                stTorqueTransferDialog.showNormal()
                stTorqueTransferDialog.raise()
            }
            enabled: stTorqueTransferDialog.allListsAnyValid
        }
        ScalarListDialog {
            id: stTorqueTransferDialog
            paramLists: [
                parameters.transmissionSpeedTorqueTransferTime
            ]
        }

    }

    RowLayout {


        ScalarParamSpinBox {
            Layout.alignment: Qt.AlignTop
            metaParam: parameters.reverseLockoutSpeed
        }
        ScalarParamSpinBox {
            Layout.alignment: Qt.AlignTop
            metaParam: parameters.transmissionSTDownshiftTorqueThreshold
        }
        ScalarParamSpinBox {
            Layout.alignment: Qt.AlignTop
            metaParam: parameters.transmissionSTUpshiftTorqueThreshold
        }

    }
}
