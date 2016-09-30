import QtQuick 2.5
import QtQuick.Controls 1.4
import QtQuick.Layouts 1.2
import QtQuick.Window 2.2
import QtQuick.Dialogs 1.2
import QtCharts 2.0
import com.hgmelectronics.setuptools.xcp 1.0
import com.hgmelectronics.setuptools 1.0
import com.hgmelectronics.setuptools.ui 1.0

Item {
    id: root
    property Parameters registry
    anchors.left: parent.left
    anchors.right: parent.right
    TabView {
        id: tabView
        anchors.fill: parent

        Tab {
            title: "Analog I/O"
            active: true
            AutoRefreshArea {
                base: this
                ColumnLayout {
                    anchors.left: parent.left
                    anchors.top: parent.top
                    anchors.margins: 10
                    spacing: 10
                    TableParamEdit {
                        tableParam: registry.aioAiCts
                    }
                    ScalarParamEdit {
                        name: "VBat"
                        metaParam: registry.aioVbatEv01
                    }
                }
            }
        }

        Tab {
            title: "CAN"
            active: true
            AutoRefreshArea {
                base: this
                RowLayout {
                    Layout.alignment: Qt.AlignLeft
                    anchors.fill: parent
                    anchors.margins: 10
                    spacing: 10
                    ColumnLayout {
                        Layout.alignment: Qt.AlignTop
                        ScalarParamEdit {
                            name: "AuxBattCnvtCmdOn"
                            metaParam: registry.canAuxBattCnvtCmdOn
                        }
                        ScalarParamEdit {
                            name: "AuxBattCnvtCmdVolt"
                            metaParam: registry.canAuxBattCnvtCmdVolt
                        }
                        ScalarParamEdit {
                            name: "CtlMaxMotoringTorque"
                            metaParam: registry.canCtlMaxMotoringTorque
                        }
                        ScalarParamEdit {
                            name: "CtlMaxRegenTorque"
                            metaParam: registry.canCtlMaxRegenTorque
                        }
                        ScalarParamEdit {
                            name: "TracMotorSpeed"
                            metaParam: registry.canTracMotorSpeed
                        }
                        ScalarParamEdit {
                            name: "LimpHomeCmdOn"
                            metaParam: registry.canLimpHomeCmdOn
                        }
                    }
                    ColumnLayout {
                        Layout.alignment: Qt.AlignTop
                        ScalarParamEdit {
                            name: "BattMaxDischCurrCmd"
                            metaParam: registry.canBattMaxDischCurrCmd
                        }
                        ScalarParamEdit {
                            name: "BattMaxChgCurrCmd"
                            metaParam: registry.canBattMaxChgCurrCmd
                        }
                        ScalarParamEdit {
                            name: "AuxBattCnvtState"
                            metaParam: registry.canAuxBattCnvtState
                        }
                        ScalarParamEdit {
                            name: "AuxBattCnvtTemp"
                            metaParam: registry.canAuxBattCnvtTemp
                        }
                        ScalarParamEdit {
                            name: "AuxBattCnvtInputVolt"
                            metaParam: registry.canAuxBattCnvtInputVolt
                        }
                        ScalarParamEdit {
                            name: "AuxBattCnvtOutputVolt"
                            metaParam: registry.canAuxBattCnvtOutputVolt
                        }
                        ScalarParamEdit {
                            name: "AuxBattCnvtOutputCurr"
                            metaParam: registry.canAuxBattCnvtOutputCurr
                        }
                    }
                    ColumnLayout {
                        Layout.alignment: Qt.AlignTop
                        ScalarParamEdit {
                            name: "ExtChgCtcRqst"
                            metaParam: registry.canExtChgCtcRqst
                        }
                        ScalarParamEdit {
                            name: "AuxCtcRqrd"
                            metaParam: registry.canAuxCtcRqrd
                        }
                        ScalarParamEdit {
                            name: "XcpProgramRequested"
                            metaParam: registry.canXcpProgramRequested
                        }
                        ScalarParamEdit {
                            name: "Can1RxErrCount"
                            metaParam: registry.canCan1RxErrCount
                        }
                        ScalarParamEdit {
                            name: "Can1TxErrCount"
                            metaParam: registry.canCan1TxErrCount
                        }
                        ScalarParamEdit {
                            name: "Can1BufferFull"
                            metaParam: registry.canCan1BufferFull
                        }
                        ScalarParamEdit {
                            name: "Can2RxErrCount"
                            metaParam: registry.canCan2RxErrCount
                        }
                        ScalarParamEdit {
                            name: "Can2TxErrCount"
                            metaParam: registry.canCan2TxErrCount
                        }
                        ScalarParamEdit {
                            name: "Can2BufferFull"
                            metaParam: registry.canCan2BufferFull
                        }
                    }
                }
            }
        }

        Tab {
            title: "CBTM"
            active: true
            AutoRefreshArea {
                base: this
                RowLayout {
                    Layout.alignment: Qt.AlignLeft
                    anchors.fill: parent
                    anchors.margins: 10
                    spacing: 10
                    ColumnLayout {
                        Layout.alignment: Qt.AlignTop
                        ScalarParamEdit {
                            name: "Fault Decay"
                            metaParam: registry.cbtmFaultDecayCyc
                        }
                        ScalarParamEdit {
                            name: "Non-Quiescent Trip"
                            metaParam: registry.cbtmNonQuiescentTripCyc
                        }
                        ScalarParamEdit {
                            name: "Non-Quiescent Decay"
                            metaParam: registry.cbtmNonQuiescentDecayCyc
                        }
                        ScalarParamEdit {
                            name: "Balance Open Delta-V"
                            metaParam: registry.cbtmBalanceOpenDeltaVThresh
                        }
                        ScalarParamEdit {
                            name: "Balance Short Delta-V"
                            metaParam: registry.cbtmBalanceShortDeltaVThresh
                        }
                        ScalarParamEdit {
                            name: "Quiescent Delta-V"
                            metaParam: registry.cbtmQuiescentDeltaVThresh
                        }
                        ScalarParamEdit {
                            name: "IsoSPI #1 First ID"
                            metaParam: registry.cbtmIsospi1FirstBoard
                        }
                        ScalarParamEdit {
                            name: "IsoSPI #1 Last ID"
                            metaParam: registry.cbtmIsospi1LastBoard
                        }
                        ScalarParamEdit {
                            name: "IsoSPI #2 First ID"
                            metaParam: registry.cbtmIsospi2FirstBoard
                        }
                        ScalarParamEdit {
                            name: "IsoSPI #2 Last ID"
                            metaParam: registry.cbtmIsospi2LastBoard
                        }
                        ScalarParamEdit {
                            name: "Comm Fault Trip Cycles"
                            metaParam: registry.cbtmCommFaultTripCyc
                        }
                        ScalarParamEdit {
                            name: "Comm Fault Clear Cycles"
                            metaParam: registry.cbtmCommFaultClearCyc
                        }
                    }
                    ColumnLayout {
                        spacing: 10
                        TableParamEdit {
                            Layout.fillHeight: true
                            xLabel: "Board #"
                            valueLabel: "Disch"
                            tableParam: registry.cbtmDisch
                        }
                        TableParamEdit {
                            Layout.fillHeight: true
                            xLabel: "Board #"
                            valueLabel: "Status"
                            tableParam: registry.cbtmStatus
                        }
                    }

                    TableParamEdit {
                        Layout.fillHeight: true
                        xLabel: "Cell #"
                        tableParam: registry.cbtmCellVolt
                    }
                    TableParamEdit {
                        Layout.fillHeight: true
                        xLabel: "Tab #"
                        tableParam: registry.cbtmTabTemp
                    }
                    ColumnLayout {
                        id: graphsLayout
                        Layout.fillWidth: true
                        Layout.fillHeight: true
                        Label {
                            Layout.alignment: Qt.AlignLeft
                            text: "Cell Voltages"
                            font.bold: true
                        }
                        ChartView {
                            id: cellPlot
                            Layout.fillWidth: true
                            Layout.fillHeight: true
                            antialiasing: true
                            margins.left: 0
                            margins.right: 0
                            margins.bottom: 0
                            margins.top: 0

                            RoleModeledLineSeries {
                                id: cellVoltSeries
                                visible: registry.cbtmCellVolt.value.valid
                                model: registry.cbtmCellVolt.stringModel
                                name: qsTr("Cell Voltage")

                                axisX: ValueAxis {
                                    min: 0
                                    max: registry.cbtmCellVolt.value.count
                                    tickCount: registry.cbtmCellVolt.value.count / 8 + 1
                                    labelFormat: "%d"
                                }

                                axisY: cellVoltAutoAxis.yAxis
                            }

                            RoleModeledLineSeries {
                                id: tabTempSeries
                                visible: registry.cbtmTabTemp.value.valid
                                model: registry.cbtmTabTemp.stringModel
                                name: qsTr("Tab Temp degC")

                                axisX: ValueAxis {
                                    min: 0
                                    max: registry.cbtmTabTemp.value.count
                                    tickCount: registry.cbtmTabTemp.value.count / 9 + 1
                                    labelFormat: "%d"
                                }

                                axisY: tabTempAutoAxis.yAxis
                            }
                        }

                        XYSeriesAutoAxis {
                            id: cellVoltAutoAxis
                            series: [ cellVoltSeries ]
                        }

                        XYSeriesAutoAxis {
                            id: tabTempAutoAxis
                            series: [ tabTempSeries ]
                        }
                    }
                }
            }
        }

        Tab {
            title: "Contactor"
            active: true
            AutoRefreshArea {
                base: this
                Flow {
                    anchors.fill: parent
                    anchors.margins: 10
                    spacing: 10
                    ScalarParamEdit {
                        name: "Max Simul Pickups"
                        metaParam: registry.ctcMaxSimulPickup
                    }
                    TableParamEdit {
                        xLabel: "Ctc #"
                        valueLabel: "Feedback Inputs"
                        tableParam: registry.ctcNFeedbackInput
                    }
                    TableParamEdit {
                        xLabel: "Ctc #"
                        valueLabel: "On"
                        tableParam: registry.ctcOn
                    }
                    TableParamEdit {
                        xLabel: "Ctc #"
                        valueLabel: "OK"
                        tableParam: registry.ctcOk
                    }
                    TableParamEdit {
                        xLabel: "Ctc #"
                        valueLabel: "A Closed"
                        tableParam: registry.ctcAClosed
                    }
                    TableParamEdit {
                        xLabel: "Ctc #"
                        valueLabel: "B Closed"
                        tableParam: registry.ctcBClosed
                    }
                }
            }
        }

        Tab {
            title: "DIO"
            active: true
            AutoRefreshArea {
                base: this
                RowLayout {
                    Layout.alignment: Qt.AlignLeft
                    anchors.fill: parent
                    anchors.margins: 10
                    spacing: 10
                    TableParamEdit {
                        xLabel: "DI #"
                        valueLabel: "On"
                        tableParam: registry.dioDi
                    }
                    TableParamEdit {
                        xLabel: "DO #"
                        valueLabel: "On"
                        tableParam: registry.dioDo
                    }
                }
            }
        }

        Tab {
            title: "IAI"
            active: true
            AutoRefreshArea {
                base: this
                RowLayout {
                    Layout.alignment: Qt.AlignLeft
                    anchors.fill: parent
                    anchors.margins: 10
                    spacing: 10
                    TableParamEdit {
                        xLabel: "IAI #"
                        tableParam: registry.iaiDiffCts
                    }
                    TableParamEdit {
                        xLabel: "IAI #"
                        valueLabel: "OK"
                        tableParam: registry.iaiOk
                    }
                    ScalarParamEdit {
                        name: "IAI #4 Pos"
                        metaParam: registry.iai4PosCts
                    }
                    ScalarParamEdit {
                        name: "IAI #4 Neg"
                        metaParam: registry.iai4NegCts
                    }
                    ScalarParamEdit {
                        name: "IAI #4 Pullup"
                        metaParam: registry.iai4Pullup
                    }
                    ScalarParamEdit {
                        name: "IAI #4 Pulldown"
                        metaParam: registry.iai4Pulldown
                    }
                }
            }
        }

        Tab {
            title: "Aux Batt"
            active: true
            AutoRefreshArea {
                base: this
                RowLayout {
                    Layout.alignment: Qt.AlignLeft
                    anchors.fill: parent
                    anchors.margins: 10
                    spacing: 10
                    ColumnLayout {
                        Layout.alignment: Qt.AlignTop
                        EncodingParamEdit {
                            name: "CnvtType"
                            metaParam: registry.auxBattCnvtType
                        }
                        ScalarParamEdit {
                            name: "CnvtInputVoltMin"
                            metaParam: registry.auxBattCnvtInputVoltMin
                        }
                        ScalarParamEdit {
                            name: "CnvtStartTemp"
                            metaParam: registry.auxBattCnvtStartTemp
                        }
                        ScalarParamEdit {
                            name: "CnvtStopTemp"
                            metaParam: registry.auxBattCnvtStopTemp
                        }
                    }
                    ColumnLayout {
                        Layout.alignment: Qt.AlignTop
                        ScalarParamEdit {
                            name: "FloatVolt"
                            metaParam: registry.auxBattFloatVolt
                        }
                        ScalarParamEdit {
                            name: "FloatVoltTempCoeff"
                            metaParam: registry.auxBattFloatVoltTempCoeff
                        }
                        ScalarParamEdit {
                            name: "FloatVoltMin"
                            metaParam: registry.auxBattFloatVoltMin
                        }
                        ScalarParamEdit {
                            name: "FloatVoltMax"
                            metaParam: registry.auxBattFloatVoltMax
                        }
                        ScalarParamEdit {
                            name: "FloatVoltFailsafe"
                            metaParam: registry.auxBattFloatVoltFailsafe
                        }
                    }
                    ColumnLayout {
                        Layout.alignment: Qt.AlignTop
                        ScalarParamEdit {
                            name: "RestartVoltHysteresis"
                            metaParam: registry.auxBattRestartVoltHysteresis
                        }
                        ScalarParamEdit {
                            name: "RestartVoltTime"
                            metaParam: registry.auxBattRestartVoltTime
                        }
                        ScalarParamEdit {
                            name: "RestartAlwaysTime"
                            metaParam: registry.auxBattRestartAlwaysTime
                        }
                        ScalarParamEdit {
                            name: "StopOutCurr"
                            metaParam: registry.auxBattStopOutCurr
                        }
                        ScalarParamEdit {
                            name: "StopOutCurrTime"
                            metaParam: registry.auxBattStopOutCurrTime
                        }
                    }
                    ColumnLayout {
                        Layout.alignment: Qt.AlignTop
                        ScalarParamEdit {
                            name: "BattOkTemp"
                            metaParam: registry.auxBattBattOkTemp
                        }
                        ScalarParamEdit {
                            name: "BattWarmTemp"
                            metaParam: registry.auxBattBattWarmTemp
                        }
                        ScalarParamEdit {
                            name: "BattHotTemp"
                            metaParam: registry.auxBattBattHotTemp
                        }
                        ScalarParamEdit {
                            name: "BattTemp0AiChan"
                            metaParam: registry.auxBattBattTemp0AiChan
                        }
                        ScalarParamEdit {
                            name: "BattTemp1AiChan"
                            metaParam: registry.auxBattBattTemp1AiChan
                        }
                        EncodingParamEdit {
                            name: "BattTemp0Curve"
                            metaParam: registry.auxBattBattTemp0Curve
                        }
                        EncodingParamEdit {
                            name: "BattTemp1Curve"
                            metaParam: registry.auxBattBattTemp1Curve
                        }
                    }
                    ColumnLayout {
                        Layout.alignment: Qt.AlignTop
                        ScalarParamEdit {
                            name: "RestartVoltTimeCount"
                            metaParam: registry.auxBattRestartVoltTimeCount
                        }
                        ScalarParamEdit {
                            name: "RestartAlwaysTimeCount"
                            metaParam: registry.auxBattRestartAlwaysTimeCount
                        }
                        ScalarParamEdit {
                            name: "StopOutCurrTimeCount"
                            metaParam: registry.auxBattStopOutCurrTimeCount
                        }
                        ScalarParamEdit {
                            name: "BattTemp0"
                            metaParam: registry.auxBattBattTemp0
                        }
                        ScalarParamEdit {
                            name: "BattTemp1"
                            metaParam: registry.auxBattBattTemp1
                        }
                        ScalarParamEdit {
                            name: "Status"
                            metaParam: registry.auxBattStatus
                        }
                    }
                }
            }
        }

        Tab {
            title: "Motor"
            active: true
            AutoRefreshArea {
                base: this
                RowLayout {
                    Layout.alignment: Qt.AlignLeft
                    anchors.fill: parent
                    anchors.margins: 10
                    spacing: 10
                    ColumnLayout {
                        Layout.alignment: Qt.AlignTop
                        ScalarParamEdit {
                            name: "FailsafeSpeed"
                            metaParam: registry.motorFailsafeSpeed
                        }
                        ScalarParamEdit {
                            name: "MinEffSpeed"
                            metaParam: registry.motorMinEffSpeed
                        }
                        ScalarParamEdit {
                            name: "RatedTorque"
                            metaParam: registry.motorRatedTorque
                        }
                        ScalarParamEdit {
                            name: "CurrRegPropCoeff"
                            metaParam: registry.motorCurrRegPropCoeff
                        }
                        ScalarParamEdit {
                            name: "CurrRegIntCoeff"
                            metaParam: registry.motorCurrRegIntCoeff
                        }
                        ScalarParamEdit {
                            name: "MaxTorqueRefErr"
                            metaParam: registry.motorMaxTorqueRefErr
                        }
                    }
                    ColumnLayout {
                        Layout.alignment: Qt.AlignTop
                        ScalarParamEdit {
                            name: "MotoringIntegrator"
                            metaParam: registry.motorMotoringIntegrator
                        }
                        ScalarParamEdit {
                            name: "RegenIntegrator"
                            metaParam: registry.motorRegenIntegrator
                        }
                        ScalarParamEdit {
                            name: "AdjMaxMotoringCurr"
                            metaParam: registry.motorAdjMaxMotoringCurr
                        }
                        ScalarParamEdit {
                            name: "AdjMaxRegenCurr"
                            metaParam: registry.motorAdjMaxRegenCurr
                        }
                    }
                }
            }
        }

        Tab {
            title: "Pack Setup"
            active: true
            RowLayout {
                Layout.alignment: Qt.AlignLeft
                anchors.fill: parent
                anchors.margins: 10
                spacing: 10
                GroupBox {
                    Layout.alignment: Qt.AlignTop
                    title: "IAI"
                    ColumnLayout {
                        EncodingParamEdit {
                            name: "Mapping"
                            metaParam: registry.packIaiFunc
                        }
                        ScalarParamEdit {
                            name: "#1 Scale"
                            metaParam: registry.packIai1Scale
                        }
                        ScalarParamEdit {
                            name: "#2 Scale"
                            metaParam: registry.packIai2Scale
                        }
                        ScalarParamEdit {
                            name: "#3 Scale"
                            metaParam: registry.packIai3Scale
                        }
                        ScalarParamEdit {
                            name: "#4 Scale"
                            metaParam: registry.packIai4Scale
                        }
                        ScalarParamEdit {
                            name: "#1 Zero"
                            metaParam: registry.packIai1Zero
                        }
                        ScalarParamEdit {
                            name: "#2 Zero"
                            metaParam: registry.packIai2Zero
                        }
                        ScalarParamEdit {
                            name: "#3 Zero"
                            metaParam: registry.packIai3Zero
                        }
                        ScalarParamEdit {
                            name: "#4 Zero"
                            metaParam: registry.packIai4Zero
                        }
                    }
                }
                GroupBox {
                    Layout.alignment: Qt.AlignTop
                    title: "Cell Protection"
                    ColumnLayout {
                        ScalarParamEdit {
                            name: "Limp Home Disch"
                            metaParam: registry.packLimpHomeDischCurr
                        }
                        ScalarParamEdit {
                            name: "Limp Home Chg"
                            metaParam: registry.packLimpHomeChgCurr
                        }
                        ScalarParamEdit {
                            name: "Safety Margin"
                            metaParam: registry.packCellProtMarginCurr
                        }
                        ScalarParamEdit {
                            name: "Current Reg Fault Trip"
                            metaParam: registry.packCurrRegFltTripCyc
                        }
                        ScalarParamEdit {
                            name: "Current Reg Fault Decay"
                            metaParam: registry.packCurrRegFltDecayCyc
                        }
                        SimpleTableParamEditButton {
                            name: "Max Disch Current"
                            tableParam: registry.packMaxCurrDisch
                        }
                        SimpleTableParamEditButton {
                            name: "Max Chg Current"
                            tableParam: registry.packMaxCurrChg
                        }
                        SimpleTableParamEditButton {
                            name: "Max Cell V"
                            tableParam: registry.packCellVLimitMax
                        }
                        SimpleTableParamEditButton {
                            name: "Min Cell V"
                            tableParam: registry.packCellVLimitMin
                        }
                        SimpleTableParamEditButton {
                            name: "Cell Prot Resistance"
                            tableParam: registry.packCellProtResTable
                        }
                    }
                }
                GroupBox {
                    Layout.alignment: Qt.AlignTop
                    title: "Balance"
                    ColumnLayout {
                        ScalarParamEdit {
                            name: "Active Band"
                            metaParam: registry.packBalBandVolt
                        }
                        ScalarParamEdit {
                            name: "Minimum Difference"
                            metaParam: registry.packBalDiffVolt
                        }
                        ScalarParamEdit {
                            name: "Minimum Voltage"
                            metaParam: registry.packBalMinVolt
                        }
                        ScalarParamEdit {
                            name: "Sample Wait Time"
                            metaParam: registry.packBalSampleWaitCyc
                        }
                        ScalarParamEdit {
                            name: "High Cell Disch Time"
                            metaParam: registry.packBalDischHighCyc
                        }
                        ScalarParamEdit {
                            name: "All Cell Disch Time"
                            metaParam: registry.packBalDischAllCyc
                        }
                    }
                }
                GroupBox {
                    Layout.alignment: Qt.AlignTop
                    title: "Ground Fault"
                    ColumnLayout {
                        ScalarParamEdit {
                            name: "Sample Time"
                            metaParam: registry.packGndFltDetectAvgCyc
                        }
                        ScalarParamEdit {
                            name: "Cycle Period"
                            metaParam: registry.packGndFltDetectPeriodCyc
                        }
                        ScalarParamEdit {
                            name: "Fault Threshold"
                            metaParam: registry.packGndFltTripConduct
                        }
                        ScalarParamEdit {
                            name: "Fault Threshold Ext Chg"
                            metaParam: registry.packGndFltTripConductExtChg
                        }
                        ScalarParamEdit {
                            name: "Fault Trip Cycles"
                            metaParam: registry.packGndFltTripCyc
                        }
                        ScalarParamEdit {
                            name: "Fault Decay Cycles"
                            metaParam: registry.packGndFltDecayCyc
                        }
                    }
                }
                GroupBox {
                    Layout.alignment: Qt.AlignTop
                    title: "Pack Safety"
                    ColumnLayout {
                        ScalarParamEdit {
                            name: "Traction Current Decay Time"
                            metaParam: registry.packTracCurrDecayCyc
                        }
                        ScalarParamEdit {
                            name: "Charge Current Decay Time"
                            metaParam: registry.packChgCurrDecayCyc
                        }
                        ScalarParamEdit {
                            name: "Max Traction Precharge Time"
                            metaParam: registry.packMaxTracPrechgCyc
                        }
                        ScalarParamEdit {
                            name: "Low Voltage Trip"
                            metaParam: registry.packLowStringVoltTrip
                        }
                        ScalarParamEdit {
                            name: "Low Voltage Reset"
                            metaParam: registry.packLowStringVoltReset
                        }
                    }
                }
            }
        }

        Tab {
            title: "Pack Data"
            active: true
            AutoRefreshArea {
                base: this
                RowLayout {
                    Layout.alignment: Qt.AlignLeft
                    anchors.fill: parent
                    anchors.margins: 10
                    spacing: 10

                    GroupBox {
                        Layout.alignment: Qt.AlignTop
                        title: "Voltages && Currents"
                        ColumnLayout {
                            ScalarParamEdit {
                                name: "Battery Voltage"
                                metaParam: registry.packString1Volt
                            }
                            ScalarParamEdit {
                                name: "Battery Current"
                                metaParam: registry.packString1Curr
                            }
                            ScalarParamEdit {
                                name: "Traction Motor"
                                metaParam: registry.packTracMtrCurr
                            }
                            ScalarParamEdit {
                                name: "Traction Aux"
                                metaParam: registry.packTracAuxCurr
                            }
                            ScalarParamEdit {
                                name: "Traction Total"
                                metaParam: registry.packTracTotalCurr
                            }
                            ScalarParamEdit {
                                name: "Hybrid"
                                metaParam: registry.packHybrCurr
                            }
                            ScalarParamEdit {
                                name: "Non-Traction Aux"
                                metaParam: registry.packNonTracAuxCurr
                            }
                        }
                    }

                    GroupBox {
                        Layout.alignment: Qt.AlignTop
                        title: "Ground Fault"
                        ColumnLayout {
                            ScalarParamEdit {
                                name: "Pulldown Pos Voltage"
                                metaParam: registry.packGndFltDetectPulldownPosVolt
                            }
                            ScalarParamEdit {
                                name: "Pulldown Neg Voltage"
                                metaParam: registry.packGndFltDetectPulldownNegVolt
                            }
                            ScalarParamEdit {
                                name: "Pullup Pos Voltage"
                                metaParam: registry.packGndFltDetectPullupPosVolt
                            }
                            ScalarParamEdit {
                                name: "Pullup Neg Voltage"
                                metaParam: registry.packGndFltDetectPullupNegVolt
                            }
                            ScalarParamEdit {
                                name: "Center Voltage"
                                metaParam: registry.packGndFltCenterVolt
                            }
                            ScalarParamEdit {
                                name: "Location In Pack"
                                metaParam: registry.packGndFltFrac
                            }
                            ScalarParamEdit {
                                name: "Conductance"
                                metaParam: registry.packGndFltConduct
                            }
                        }
                    }

                    GroupBox {
                        Layout.alignment: Qt.AlignTop
                        title: "Cell Statistics"
                        ColumnLayout {
                            ScalarParamEdit {
                                name: "Max Voltage"
                                metaParam: registry.packMaxCellVolt
                            }
                            ScalarParamEdit {
                                name: "Mean Voltage"
                                metaParam: registry.packMeanCellVolt
                            }
                            ScalarParamEdit {
                                name: "Min Voltage"
                                metaParam: registry.packMinCellVolt
                            }
                            ScalarParamEdit {
                                name: "Max Temp"
                                metaParam: registry.packMaxCellTemp
                            }
                            ScalarParamEdit {
                                name: "Mean Temp"
                                metaParam: registry.packMeanCellTemp
                            }
                            ScalarParamEdit {
                                name: "Min Temp"
                                metaParam: registry.packMinCellTemp
                            }
                        }
                    }

                    GroupBox {
                        Layout.alignment: Qt.AlignTop
                        title: "Cell Protection"
                        ColumnLayout {
                            ScalarParamEdit {
                                name: "Max Voltage"
                                metaParam: registry.packCellProtMaxVolt
                            }
                            ScalarParamEdit {
                                name: "Min Voltage"
                                metaParam: registry.packCellProtMinVolt
                            }
                            ScalarParamEdit {
                                name: "Resistance For Calc"
                                metaParam: registry.packCellProtRes
                            }
                            ScalarParamEdit {
                                name: "Max Disch (Voltage)"
                                metaParam: registry.packCellProtVoltageMaxDischCurr
                            }
                            ScalarParamEdit {
                                name: "Max Chg (Voltage)"
                                metaParam: registry.packCellProtVoltageMaxChgCurr
                            }
                            ScalarParamEdit {
                                name: "Max Disch (Thermal)"
                                metaParam: registry.packCellProtThermalMaxDischCurr
                            }
                            ScalarParamEdit {
                                name: "Max Chg (Thermal)"
                                metaParam: registry.packCellProtThermalMaxChgCurr
                            }
                        }
                    }

                    GroupBox {
                        title: "Current Limits"
                        Layout.alignment: Qt.AlignTop
                        ColumnLayout {
                            ScalarParamEdit {
                                name: "String Max Disch"
                                metaParam: registry.packString1MaxDischCurr
                            }
                            ScalarParamEdit {
                                name: "String Max Chg"
                                metaParam: registry.packString1MaxChgCurr
                            }
                            ScalarParamEdit {
                                name: "Trac Max Disch"
                                metaParam: registry.packTracMaxDischCurr
                            }
                            ScalarParamEdit {
                                name: "Trac Max Chg"
                                metaParam: registry.packTracMaxChgCurr
                            }
                        }
                    }

                    GroupBox {
                        title: "State"
                        Layout.alignment: Qt.AlignTop
                        ColumnLayout {
                            ScalarParamEdit {
                                name: "Ctc Ctrl State"
                                metaParam: registry.packCtcCtrlStateCode
                            }
                            ScalarParamEdit {
                                name: "Balancer State"
                                metaParam: registry.packBalancerStateCode
                            }
                            ScalarParamIndicator {
                                name: "CBTM Open Wire"
                                metaParam: registry.packStatus
                                bitMask: 0x00000001
                            }
                            ScalarParamIndicator {
                                name: "CBTM Thermistor Fault"
                                metaParam: registry.packStatus
                                bitMask: 0x00000002
                            }
                            ScalarParamIndicator {
                                name: "CBTM Balance Fault"
                                metaParam: registry.packStatus
                                bitMask: 0x00000004
                            }
                            ScalarParamIndicator {
                                name: "CBTM Internal Fault"
                                metaParam: registry.packStatus
                                bitMask: 0x00000008
                            }
                            ScalarParamIndicator {
                                name: "CBTM Power Supply Fault"
                                metaParam: registry.packStatus
                                bitMask: 0x00000010
                            }
                            ScalarParamIndicator {
                                name: "CBTM I2C Fault"
                                metaParam: registry.packStatus
                                bitMask: 0x00000020
                            }
                            ScalarParamIndicator {
                                name: "CBTM Overtemp"
                                metaParam: registry.packStatus
                                bitMask: 0x00000040
                            }
                            ScalarParamIndicator {
                                name: "CBTM Comm Fault"
                                metaParam: registry.packStatus
                                bitMask: 0x00000100
                            }
                            ScalarParamIndicator {
                                name: "CBTM Open Wire"
                                metaParam: registry.packStatus
                                bitMask: 0x00000100
                            }
                            ScalarParamIndicator {
                                name: "Cell Voltage Sense Lost"
                                metaParam: registry.packStatus
                                bitMask: 0x00000200
                            }
                            ScalarParamIndicator {
                                name: "Cell Temp Sense Lost"
                                metaParam: registry.packStatus
                                bitMask: 0x00000400
                            }
                            ScalarParamIndicator {
                                name: "Adjacent Cell Temp Sense Lost"
                                metaParam: registry.packStatus
                                bitMask: 0x00000800
                            }
                            ScalarParamIndicator {
                                name: "Ground Fault"
                                metaParam: registry.packStatus
                                bitMask: 0x00001000
                            }
                            ScalarParamIndicator {
                                name: "Limp Home Engaged"
                                metaParam: registry.packStatus
                                bitMask: 0x00002000
                            }
                            ScalarParamIndicator {
                                name: "String Current Reg Fault"
                                metaParam: registry.packStatus
                                bitMask: 0x00004000
                            }
                            ScalarParamIndicator {
                                name: "CDA2 Vbat (12/24V) Low"
                                metaParam: registry.packStatus
                                bitMask: 0x00008000
                            }
                            ScalarParamIndicator {
                                name: "Contactor Inoperative"
                                metaParam: registry.packStatus
                                bitMask: 0x00010000
                            }
                            ScalarParamIndicator {
                                name: "Traction Precharge Fault"
                                metaParam: registry.packStatus
                                bitMask: 0x00020000
                            }
                            ScalarParamIndicator {
                                name: "Aux Precharge Fault"
                                metaParam: registry.packStatus
                                bitMask: 0x00040000
                            }
                            ScalarParamIndicator {
                                name: "String Voltage Low"
                                metaParam: registry.packStatus
                                bitMask: 0x00080000
                            }


                            ScalarParamIndicator {
                                name: "CBTM Non-Quiescent"
                                metaParam: registry.packStatus
                                bitMask: 0x40000000
                                color: "yellow"
                            }
                            ScalarParamIndicator {
                                name: "Batt Contactor Closed"
                                metaParam: registry.packStatus
                                bitMask: 0x20000000
                                color: "yellow"
                            }
                            ScalarParamIndicator {
                                name: "Pos Trac Contactor Closed"
                                metaParam: registry.packStatus
                                bitMask: 0x10000000
                                color: "yellow"
                            }
                            ScalarParamIndicator {
                                name: "Pos Aux Contactor Closed"
                                metaParam: registry.packStatus
                                bitMask: 0x08000000
                                color: "yellow"
                            }
                            ScalarParamIndicator {
                                name: "Neg Contactor Closed"
                                metaParam: registry.packStatus
                                bitMask: 0x04000000
                                color: "yellow"
                            }
                            ScalarParamIndicator {
                                name: "HV Present"
                                metaParam: registry.packStatus
                                bitMask: 0x02000000
                                color: "yellow"
                            }
                        }
                    }
                }
            }
        }

        Tab {
            title: "System"
            active: true
            AutoRefreshArea {
                base: this
                RowLayout {
                    Layout.alignment: Qt.AlignLeft
                    anchors.fill: parent
                    anchors.margins: 10
                    spacing: 10
                    ColumnLayout {
                        Layout.alignment: Qt.AlignTop
                        ScalarParamEdit {
                            name: "Idle Time"
                            metaParam: registry.sysCycleIdleTicks
                        }
                        ScalarParamEdit {
                            name: "CBTM Input"
                            metaParam: registry.sysCycleDrvCbtmInTicks
                        }
                        ScalarParamEdit {
                            name: "IAI Input"
                            metaParam: registry.sysCycleDrvIaiInTicks
                        }
                        ScalarParamEdit {
                            name: "Aux Batt Ctrl"
                            metaParam: registry.sysCycleCtlAuxBattTicks
                        }
                        ScalarParamEdit {
                            name: "Lamp Ctrl"
                            metaParam: registry.sysCycleCtlLampTicks
                        }
                        ScalarParamEdit {
                            name: "Motor Ctrl"
                            metaParam: registry.sysCycleCtlMotorTicks
                        }
                        ScalarParamEdit {
                            name: "Pack Ctrl"
                            metaParam: registry.sysCycleCtlPackTicks
                        }
                    }
                    ColumnLayout {
                        Layout.alignment: Qt.AlignTop
                        ScalarParamIndicator {
                            name: "Watchdog Reset"
                            metaParam: registry.sysFlags
                            bitMask: 0x00000001
                        }
                        ScalarParamIndicator {
                            name: "Stack Overflow"
                            metaParam: registry.sysFlags
                            bitMask: 0x00000004
                        }
                        ScalarParamIndicator {
                            name: "Cycle Time Violation"
                            metaParam: registry.sysFlags
                            bitMask: 0x00000002
                        }
                        ScalarParamEdit {
                            name: "Heap Alloc Bytes"
                            metaParam: registry.sysHeapAllocBytes
                        }
                        ScalarParamEdit {
                            name: "Heap Avail Bytes"
                            metaParam: registry.sysHeapFreeBytes
                        }
                        ScalarParamEdit {
                            name: "Heap Free Count"
                            metaParam: registry.sysHeapNFrees
                        }
                        ScalarParamEdit {
                            name: "RTDB rows"
                            metaParam: registry.sysRtDbRows
                        }
                    }
                }
            }
        }

        Tab {
            title: "Event Log"
            active: true
            AutoRefreshArea {
                base: this
                RowLayout {
                    Layout.alignment: Qt.AlignLeft
                    anchors.fill: parent
                    anchors.margins: 10
                    spacing: 10
                    ColumnLayout {
                        Layout.alignment: Qt.AlignTop
                        ScalarParamEdit {
                            name: "Begin Serial"
                            metaParam: registry.eventBeginSerial
                        }
                        ScalarParamEdit {
                            name: "End Serial"
                            metaParam: registry.eventEndSerial
                        }
                        ScalarParamEdit {
                            name: "Clear To Serial"
                            metaParam: registry.eventClearToSerial
                        }
                        ScalarParamEdit {
                            name: "View Serial"
                            metaParam: registry.eventViewSerial
                        }
                        ScalarParamEdit {
                            name: "View Key"
                            metaParam: registry.eventViewKey
                        }
                        ScalarParamEdit {
                            name: "View Freeze Size"
                            metaParam: registry.eventViewFreezeSize
                        }
                        TableParamEdit {
                            tableParam: registry.eventViewFreeze
                        }
                    }
                }
            }
        }
    }
}
