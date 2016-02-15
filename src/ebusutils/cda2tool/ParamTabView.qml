import QtQuick 2.5
import QtQuick.Controls 1.4
import QtQuick.Layouts 1.2
import QtQuick.Window 2.2
import QtQuick.Dialogs 1.2
import com.hgmelectronics.setuptools.xcp 1.0
import com.hgmelectronics.setuptools 1.0
import com.hgmelectronics.setuptools.ui 1.0

Item {
    id: root
    property ParamRegistry registry
    anchors.left: parent.left
    anchors.right: parent.right
    TabView {
        id: tabView
        anchors.fill: parent

        Parameters {
            id: parameters
            registry: root.registry
        }

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
                        tableParam: parameters.aioAiCts
                    }
                    ScalarParamEdit {
                        name: "VBat"
                        metaParam: parameters.aioVbatEv01
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
                            metaParam: parameters.canAuxBattCnvtCmdOn
                        }
                        ScalarParamEdit {
                            name: "AuxBattCnvtCmdVolt"
                            metaParam: parameters.canAuxBattCnvtCmdVolt
                        }
                        ScalarParamEdit {
                            name: "CtlMaxMotoringTorque"
                            metaParam: parameters.canCtlMaxMotoringTorque
                        }
                        ScalarParamEdit {
                            name: "CtlMaxRegenTorque"
                            metaParam: parameters.canCtlMaxRegenTorque
                        }
                        ScalarParamEdit {
                            name: "TracMotorSpeed"
                            metaParam: parameters.canTracMotorSpeed
                        }
                        ScalarParamEdit {
                            name: "LimpHomeCmdOn"
                            metaParam: parameters.canLimpHomeCmdOn
                        }
                    }
                    ColumnLayout {
                        Layout.alignment: Qt.AlignTop
                        ScalarParamEdit {
                            name: "BattMaxDischCurrCmd"
                            metaParam: parameters.canBattMaxDischCurrCmd
                        }
                        ScalarParamEdit {
                            name: "BattMaxChgCurrCmd"
                            metaParam: parameters.canBattMaxChgCurrCmd
                        }
                        ScalarParamEdit {
                            name: "AuxBattCnvtState"
                            metaParam: parameters.canAuxBattCnvtState
                        }
                        ScalarParamEdit {
                            name: "AuxBattCnvtTemp"
                            metaParam: parameters.canAuxBattCnvtTemp
                        }
                        ScalarParamEdit {
                            name: "AuxBattCnvtInputVolt"
                            metaParam: parameters.canAuxBattCnvtInputVolt
                        }
                        ScalarParamEdit {
                            name: "AuxBattCnvtOutputVolt"
                            metaParam: parameters.canAuxBattCnvtOutputVolt
                        }
                        ScalarParamEdit {
                            name: "AuxBattCnvtOutputCurr"
                            metaParam: parameters.canAuxBattCnvtOutputCurr
                        }
                    }
                    ColumnLayout {
                        Layout.alignment: Qt.AlignTop
                        ScalarParamEdit {
                            name: "ExtChgCtcRqst"
                            metaParam: parameters.canExtChgCtcRqst
                        }
                        ScalarParamEdit {
                            name: "AuxCtcRqrd"
                            metaParam: parameters.canAuxCtcRqrd
                        }
                        ScalarParamEdit {
                            name: "XcpProgramRequested"
                            metaParam: parameters.canXcpProgramRequested
                        }
                        ScalarParamEdit {
                            name: "Can1RxErrCount"
                            metaParam: parameters.canCan1RxErrCount
                        }
                        ScalarParamEdit {
                            name: "Can1TxErrCount"
                            metaParam: parameters.canCan1TxErrCount
                        }
                        ScalarParamEdit {
                            name: "Can1BufferFull"
                            metaParam: parameters.canCan1BufferFull
                        }
                        ScalarParamEdit {
                            name: "Can2RxErrCount"
                            metaParam: parameters.canCan2RxErrCount
                        }
                        ScalarParamEdit {
                            name: "Can2TxErrCount"
                            metaParam: parameters.canCan2TxErrCount
                        }
                        ScalarParamEdit {
                            name: "Can2BufferFull"
                            metaParam: parameters.canCan2BufferFull
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
                            metaParam: parameters.cbtmFaultDecayCyc
                        }
                        ScalarParamEdit {
                            name: "Non-Quiescent Trip"
                            metaParam: parameters.cbtmNonQuiescentTripCyc
                        }
                        ScalarParamEdit {
                            name: "Non-Quiescent Decay"
                            metaParam: parameters.cbtmNonQuiescentDecayCyc
                        }
                        ScalarParamEdit {
                            name: "Balance Open Delta-V"
                            metaParam: parameters.cbtmBalanceOpenDeltaVThresh
                        }
                        ScalarParamEdit {
                            name: "Balance Short Delta-V"
                            metaParam: parameters.cbtmBalanceShortDeltaVThresh
                        }
                        ScalarParamEdit {
                            name: "Quiescent Delta-V"
                            metaParam: parameters.cbtmQuiescentDeltaVThresh
                        }
                        ScalarParamEdit {
                            name: "IsoSPI #1 First ID"
                            metaParam: parameters.cbtmIsospi1FirstBoard
                        }
                        ScalarParamEdit {
                            name: "IsoSPI #1 Last ID"
                            metaParam: parameters.cbtmIsospi1LastBoard
                        }
                        ScalarParamEdit {
                            name: "IsoSPI #2 First ID"
                            metaParam: parameters.cbtmIsospi2FirstBoard
                        }
                        ScalarParamEdit {
                            name: "IsoSPI #2 Last ID"
                            metaParam: parameters.cbtmIsospi2LastBoard
                        }
                        ScalarParamEdit {
                            name: "Comm Fault Trip Cycles"
                            metaParam: parameters.cbtmCommFaultTripCyc
                        }
                        ScalarParamEdit {
                            name: "Comm Fault Clear Cycles"
                            metaParam: parameters.cbtmCommFaultClearCyc
                        }
                    }
                    ColumnLayout {
                        spacing: 10
                        TableParamEdit {
                            Layout.fillHeight: true
                            xLabel: "Board #"
                            valueLabel: "Disch"
                            tableParam: parameters.cbtmDisch
                        }
                        TableParamEdit {
                            Layout.fillHeight: true
                            xLabel: "Board #"
                            valueLabel: "Status"
                            tableParam: parameters.cbtmStatus
                        }
                    }

                    TableParamEdit {
                        Layout.fillHeight: true
                        xLabel: "Cell #"
                        tableParam: parameters.cbtmCellVolt
                    }
                    TableParamEdit {
                        Layout.fillHeight: true
                        xLabel: "Tab #"
                        tableParam: parameters.cbtmTabTemp
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
                        TablePlot {
                            id: cellVoltPlot
                            Layout.fillWidth: true
                            Layout.fillHeight: true
                            chartOptions: ({
                                pointDot: false,
                                bezierCurve: false,
                                xScaleOverride: true,
                                xScaleSteps: cellVoltTrace.valueList.length / 8,
                                xScaleStepWidth: 8,
                                xScaleStartValue: 0
                            })

                            plots: [
                                XYTrace {
                                    id: cellVoltTrace
                                    tableModel: parameters.cbtmCellVolt.stringModel
                                    valid: parameters.cbtmCellVolt.value.valid
                                }
                            ]
                        }
                        Label {
                            Layout.alignment: Qt.AlignLeft
                            text: "Tab Temperatures"
                            font.bold: true
                        }
                        TablePlot {
                            Layout.fillWidth: true
                            Layout.fillHeight: true
                            chartOptions: ({
                                pointDot: false,
                                bezierCurve: false,
                                xScaleOverride: true,
                                xScaleSteps: tabTempTrace.valueList.length / 9,
                                xScaleStepWidth: 9,
                                xScaleStartValue: 0
                            })
                            plots: [
                                XYTrace {
                                    id: tabTempTrace
                                    tableModel: parameters.cbtmTabTemp.stringModel
                                    valid: parameters.cbtmTabTemp.value.valid
                                }
                            ]
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
                        metaParam: parameters.ctcMaxSimulPickup
                    }
                    TableParamEdit {
                        xLabel: "Ctc #"
                        valueLabel: "Feedback Inputs"
                        tableParam: parameters.ctcNFeedbackInput
                    }
                    TableParamEdit {
                        xLabel: "Ctc #"
                        valueLabel: "On"
                        tableParam: parameters.ctcOn
                    }
                    TableParamEdit {
                        xLabel: "Ctc #"
                        valueLabel: "OK"
                        tableParam: parameters.ctcOk
                    }
                    TableParamEdit {
                        xLabel: "Ctc #"
                        valueLabel: "A Closed"
                        tableParam: parameters.ctcAClosed
                    }
                    TableParamEdit {
                        xLabel: "Ctc #"
                        valueLabel: "B Closed"
                        tableParam: parameters.ctcBClosed
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
                        tableParam: parameters.dioDi
                    }
                    TableParamEdit {
                        xLabel: "DO #"
                        valueLabel: "On"
                        tableParam: parameters.dioDo
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
                        tableParam: parameters.iaiDiffCts
                    }
                    TableParamEdit {
                        xLabel: "IAI #"
                        valueLabel: "OK"
                        tableParam: parameters.iaiOk
                    }
                    ScalarParamEdit {
                        name: "IAI #4 Pos"
                        metaParam: parameters.iai4PosCts
                    }
                    ScalarParamEdit {
                        name: "IAI #4 Neg"
                        metaParam: parameters.iai4NegCts
                    }
                    ScalarParamEdit {
                        name: "IAI #4 Pullup"
                        metaParam: parameters.iai4Pullup
                    }
                    ScalarParamEdit {
                        name: "IAI #4 Pulldown"
                        metaParam: parameters.iai4Pulldown
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
                            metaParam: parameters.auxBattCnvtType
                        }
                        ScalarParamEdit {
                            name: "CnvtInputVoltMin"
                            metaParam: parameters.auxBattCnvtInputVoltMin
                        }
                        ScalarParamEdit {
                            name: "CnvtStartTemp"
                            metaParam: parameters.auxBattCnvtStartTemp
                        }
                        ScalarParamEdit {
                            name: "CnvtStopTemp"
                            metaParam: parameters.auxBattCnvtStopTemp
                        }
                    }
                    ColumnLayout {
                        Layout.alignment: Qt.AlignTop
                        ScalarParamEdit {
                            name: "FloatVolt"
                            metaParam: parameters.auxBattFloatVolt
                        }
                        ScalarParamEdit {
                            name: "FloatVoltTempCoeff"
                            metaParam: parameters.auxBattFloatVoltTempCoeff
                        }
                        ScalarParamEdit {
                            name: "FloatVoltMin"
                            metaParam: parameters.auxBattFloatVoltMin
                        }
                        ScalarParamEdit {
                            name: "FloatVoltMax"
                            metaParam: parameters.auxBattFloatVoltMax
                        }
                        ScalarParamEdit {
                            name: "FloatVoltFailsafe"
                            metaParam: parameters.auxBattFloatVoltFailsafe
                        }
                    }
                    ColumnLayout {
                        Layout.alignment: Qt.AlignTop
                        ScalarParamEdit {
                            name: "RestartVoltHysteresis"
                            metaParam: parameters.auxBattRestartVoltHysteresis
                        }
                        ScalarParamEdit {
                            name: "RestartVoltTime"
                            metaParam: parameters.auxBattRestartVoltTime
                        }
                        ScalarParamEdit {
                            name: "RestartAlwaysTime"
                            metaParam: parameters.auxBattRestartAlwaysTime
                        }
                        ScalarParamEdit {
                            name: "StopOutCurr"
                            metaParam: parameters.auxBattStopOutCurr
                        }
                        ScalarParamEdit {
                            name: "StopOutCurrTime"
                            metaParam: parameters.auxBattStopOutCurrTime
                        }
                    }
                    ColumnLayout {
                        Layout.alignment: Qt.AlignTop
                        ScalarParamEdit {
                            name: "BattOkTemp"
                            metaParam: parameters.auxBattBattOkTemp
                        }
                        ScalarParamEdit {
                            name: "BattWarmTemp"
                            metaParam: parameters.auxBattBattWarmTemp
                        }
                        ScalarParamEdit {
                            name: "BattHotTemp"
                            metaParam: parameters.auxBattBattHotTemp
                        }
                        ScalarParamEdit {
                            name: "BattTemp0AiChan"
                            metaParam: parameters.auxBattBattTemp0AiChan
                        }
                        ScalarParamEdit {
                            name: "BattTemp1AiChan"
                            metaParam: parameters.auxBattBattTemp1AiChan
                        }
                        EncodingParamEdit {
                            name: "BattTemp0Curve"
                            metaParam: parameters.auxBattBattTemp0Curve
                        }
                        EncodingParamEdit {
                            name: "BattTemp1Curve"
                            metaParam: parameters.auxBattBattTemp1Curve
                        }
                    }
                    ColumnLayout {
                        Layout.alignment: Qt.AlignTop
                        ScalarParamEdit {
                            name: "RestartVoltTimeCount"
                            metaParam: parameters.auxBattRestartVoltTimeCount
                        }
                        ScalarParamEdit {
                            name: "RestartAlwaysTimeCount"
                            metaParam: parameters.auxBattRestartAlwaysTimeCount
                        }
                        ScalarParamEdit {
                            name: "StopOutCurrTimeCount"
                            metaParam: parameters.auxBattStopOutCurrTimeCount
                        }
                        ScalarParamEdit {
                            name: "BattTemp0"
                            metaParam: parameters.auxBattBattTemp0
                        }
                        ScalarParamEdit {
                            name: "BattTemp1"
                            metaParam: parameters.auxBattBattTemp1
                        }
                        ScalarParamEdit {
                            name: "Status"
                            metaParam: parameters.auxBattStatus
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
                            metaParam: parameters.motorFailsafeSpeed
                        }
                        ScalarParamEdit {
                            name: "MinEffSpeed"
                            metaParam: parameters.motorMinEffSpeed
                        }
                        ScalarParamEdit {
                            name: "RatedTorque"
                            metaParam: parameters.motorRatedTorque
                        }
                        ScalarParamEdit {
                            name: "CurrRegPropCoeff"
                            metaParam: parameters.motorCurrRegPropCoeff
                        }
                        ScalarParamEdit {
                            name: "CurrRegIntCoeff"
                            metaParam: parameters.motorCurrRegIntCoeff
                        }
                        ScalarParamEdit {
                            name: "MaxTorqueRefErr"
                            metaParam: parameters.motorMaxTorqueRefErr
                        }
                    }
                    ColumnLayout {
                        Layout.alignment: Qt.AlignTop
                        ScalarParamEdit {
                            name: "MotoringIntegrator"
                            metaParam: parameters.motorMotoringIntegrator
                        }
                        ScalarParamEdit {
                            name: "RegenIntegrator"
                            metaParam: parameters.motorRegenIntegrator
                        }
                        ScalarParamEdit {
                            name: "AdjMaxMotoringCurr"
                            metaParam: parameters.motorAdjMaxMotoringCurr
                        }
                        ScalarParamEdit {
                            name: "AdjMaxRegenCurr"
                            metaParam: parameters.motorAdjMaxRegenCurr
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
                            metaParam: parameters.packIaiFunc
                        }
                        ScalarParamEdit {
                            name: "#1 Scale"
                            metaParam: parameters.packIai1Scale
                        }
                        ScalarParamEdit {
                            name: "#2 Scale"
                            metaParam: parameters.packIai2Scale
                        }
                        ScalarParamEdit {
                            name: "#3 Scale"
                            metaParam: parameters.packIai3Scale
                        }
                        ScalarParamEdit {
                            name: "#4 Scale"
                            metaParam: parameters.packIai4Scale
                        }
                        ScalarParamEdit {
                            name: "#1 Zero"
                            metaParam: parameters.packIai1Zero
                        }
                        ScalarParamEdit {
                            name: "#2 Zero"
                            metaParam: parameters.packIai2Zero
                        }
                        ScalarParamEdit {
                            name: "#3 Zero"
                            metaParam: parameters.packIai3Zero
                        }
                        ScalarParamEdit {
                            name: "#4 Zero"
                            metaParam: parameters.packIai4Zero
                        }
                    }
                }
                GroupBox {
                    Layout.alignment: Qt.AlignTop
                    title: "Cell Protection"
                    ColumnLayout {
                        ScalarParamEdit {
                            name: "Limp Home Disch"
                            metaParam: parameters.packLimpHomeDischCurr
                        }
                        ScalarParamEdit {
                            name: "Limp Home Chg"
                            metaParam: parameters.packLimpHomeChgCurr
                        }
                        ScalarParamEdit {
                            name: "Safety Margin"
                            metaParam: parameters.packCellProtMarginCurr
                        }
                        ScalarParamEdit {
                            name: "Current Reg Fault Trip"
                            metaParam: parameters.packCurrRegFltTripCyc
                        }
                        ScalarParamEdit {
                            name: "Current Reg Fault Decay"
                            metaParam: parameters.packCurrRegFltDecayCyc
                        }
                        SimpleTableParamEditButton {
                            name: "Max Disch Current"
                            tableParam: parameters.packMaxCurrDisch
                        }
                        SimpleTableParamEditButton {
                            name: "Max Chg Current"
                            tableParam: parameters.packMaxCurrChg
                        }
                        SimpleTableParamEditButton {
                            name: "Max Cell V"
                            tableParam: parameters.packCellVLimitMax
                        }
                        SimpleTableParamEditButton {
                            name: "Min Cell V"
                            tableParam: parameters.packCellVLimitMin
                        }
                        SimpleTableParamEditButton {
                            name: "Cell Prot Resistance"
                            tableParam: parameters.packCellProtResTable
                        }
                    }
                }
                GroupBox {
                    Layout.alignment: Qt.AlignTop
                    title: "Balance"
                    ColumnLayout {
                        ScalarParamEdit {
                            name: "Active Band"
                            metaParam: parameters.packBalBandVolt
                        }
                        ScalarParamEdit {
                            name: "Minimum Difference"
                            metaParam: parameters.packBalDiffVolt
                        }
                        ScalarParamEdit {
                            name: "Minimum Voltage"
                            metaParam: parameters.packBalMinVolt
                        }
                        ScalarParamEdit {
                            name: "Sample Wait Time"
                            metaParam: parameters.packBalSampleWaitCyc
                        }
                        ScalarParamEdit {
                            name: "High Cell Disch Time"
                            metaParam: parameters.packBalDischHighCyc
                        }
                        ScalarParamEdit {
                            name: "All Cell Disch Time"
                            metaParam: parameters.packBalDischAllCyc
                        }
                    }
                }
                GroupBox {
                    Layout.alignment: Qt.AlignTop
                    title: "Ground Fault"
                    ColumnLayout {
                        ScalarParamEdit {
                            name: "Sample Time"
                            metaParam: parameters.packGndFltDetectAvgCyc
                        }
                        ScalarParamEdit {
                            name: "Cycle Period"
                            metaParam: parameters.packGndFltDetectPeriodCyc
                        }
                        ScalarParamEdit {
                            name: "Fault Threshold"
                            metaParam: parameters.packGndFltTripConduct
                        }
                        ScalarParamEdit {
                            name: "Fault Threshold Ext Chg"
                            metaParam: parameters.packGndFltTripConductExtChg
                        }
                        ScalarParamEdit {
                            name: "Fault Trip Cycles"
                            metaParam: parameters.packGndFltTripCyc
                        }
                        ScalarParamEdit {
                            name: "Fault Decay Cycles"
                            metaParam: parameters.packGndFltDecayCyc
                        }
                    }
                }
                GroupBox {
                    Layout.alignment: Qt.AlignTop
                    title: "Pack Safety"
                    ColumnLayout {
                        ScalarParamEdit {
                            name: "Traction Current Decay Time"
                            metaParam: parameters.packTracCurrDecayCyc
                        }
                        ScalarParamEdit {
                            name: "Charge Current Decay Time"
                            metaParam: parameters.packChgCurrDecayCyc
                        }
                        ScalarParamEdit {
                            name: "Max Traction Precharge Time"
                            metaParam: parameters.packMaxTracPrechgCyc
                        }
                        ScalarParamEdit {
                            name: "Low Voltage Trip"
                            metaParam: parameters.packLowStringVoltTrip
                        }
                        ScalarParamEdit {
                            name: "Low Voltage Reset"
                            metaParam: parameters.packLowStringVoltReset
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
                                metaParam: parameters.packString1Volt
                            }
                            ScalarParamEdit {
                                name: "Battery Current"
                                metaParam: parameters.packString1Curr
                            }
                            ScalarParamEdit {
                                name: "Traction Motor"
                                metaParam: parameters.packTracMtrCurr
                            }
                            ScalarParamEdit {
                                name: "Traction Aux"
                                metaParam: parameters.packTracAuxCurr
                            }
                            ScalarParamEdit {
                                name: "Traction Total"
                                metaParam: parameters.packTracTotalCurr
                            }
                            ScalarParamEdit {
                                name: "Hybrid"
                                metaParam: parameters.packHybrCurr
                            }
                            ScalarParamEdit {
                                name: "Non-Traction Aux"
                                metaParam: parameters.packNonTracAuxCurr
                            }
                        }
                    }

                    GroupBox {
                        Layout.alignment: Qt.AlignTop
                        title: "Ground Fault"
                        ColumnLayout {
                            ScalarParamEdit {
                                name: "Pulldown Pos Voltage"
                                metaParam: parameters.packGndFltDetectPulldownPosVolt
                            }
                            ScalarParamEdit {
                                name: "Pulldown Neg Voltage"
                                metaParam: parameters.packGndFltDetectPulldownNegVolt
                            }
                            ScalarParamEdit {
                                name: "Pullup Pos Voltage"
                                metaParam: parameters.packGndFltDetectPullupPosVolt
                            }
                            ScalarParamEdit {
                                name: "Pullup Neg Voltage"
                                metaParam: parameters.packGndFltDetectPullupNegVolt
                            }
                            ScalarParamEdit {
                                name: "Center Voltage"
                                metaParam: parameters.packGndFltCenterVolt
                            }
                            ScalarParamEdit {
                                name: "Location In Pack"
                                metaParam: parameters.packGndFltFrac
                            }
                            ScalarParamEdit {
                                name: "Conductance"
                                metaParam: parameters.packGndFltConduct
                            }
                        }
                    }

                    GroupBox {
                        Layout.alignment: Qt.AlignTop
                        title: "Cell Statistics"
                        ColumnLayout {
                            ScalarParamEdit {
                                name: "Max Voltage"
                                metaParam: parameters.packMaxCellVolt
                            }
                            ScalarParamEdit {
                                name: "Mean Voltage"
                                metaParam: parameters.packMeanCellVolt
                            }
                            ScalarParamEdit {
                                name: "Min Voltage"
                                metaParam: parameters.packMinCellVolt
                            }
                            ScalarParamEdit {
                                name: "Max Temp"
                                metaParam: parameters.packMaxCellTemp
                            }
                            ScalarParamEdit {
                                name: "Mean Temp"
                                metaParam: parameters.packMeanCellTemp
                            }
                            ScalarParamEdit {
                                name: "Min Temp"
                                metaParam: parameters.packMinCellTemp
                            }
                        }
                    }

                    GroupBox {
                        Layout.alignment: Qt.AlignTop
                        title: "Cell Protection"
                        ColumnLayout {
                            ScalarParamEdit {
                                name: "Max Voltage"
                                metaParam: parameters.packCellProtMaxVolt
                            }
                            ScalarParamEdit {
                                name: "Min Voltage"
                                metaParam: parameters.packCellProtMinVolt
                            }
                            ScalarParamEdit {
                                name: "Resistance For Calc"
                                metaParam: parameters.packCellProtRes
                            }
                            ScalarParamEdit {
                                name: "Max Disch (Voltage)"
                                metaParam: parameters.packCellProtVoltageMaxDischCurr
                            }
                            ScalarParamEdit {
                                name: "Max Chg (Voltage)"
                                metaParam: parameters.packCellProtVoltageMaxChgCurr
                            }
                            ScalarParamEdit {
                                name: "Max Disch (Thermal)"
                                metaParam: parameters.packCellProtThermalMaxDischCurr
                            }
                            ScalarParamEdit {
                                name: "Max Chg (Thermal)"
                                metaParam: parameters.packCellProtThermalMaxChgCurr
                            }
                        }
                    }

                    GroupBox {
                        title: "Current Limits"
                        Layout.alignment: Qt.AlignTop
                        ColumnLayout {
                            ScalarParamEdit {
                                name: "String Max Disch"
                                metaParam: parameters.packString1MaxDischCurr
                            }
                            ScalarParamEdit {
                                name: "String Max Chg"
                                metaParam: parameters.packString1MaxChgCurr
                            }
                            ScalarParamEdit {
                                name: "Trac Max Disch"
                                metaParam: parameters.packTracMaxDischCurr
                            }
                            ScalarParamEdit {
                                name: "Trac Max Chg"
                                metaParam: parameters.packTracMaxChgCurr
                            }
                        }
                    }

                    GroupBox {
                        title: "State"
                        Layout.alignment: Qt.AlignTop
                        ColumnLayout {
                            ScalarParamEdit {
                                name: "Ctc Ctrl State"
                                metaParam: parameters.packCtcCtrlStateCode
                            }
                            ScalarParamEdit {
                                name: "Balancer State"
                                metaParam: parameters.packBalancerStateCode
                            }
                            ScalarParamIndicator {
                                name: "CBTM Open Wire"
                                metaParam: parameters.packStatus
                                bitMask: 0x00000001
                            }
                            ScalarParamIndicator {
                                name: "CBTM Thermistor Fault"
                                metaParam: parameters.packStatus
                                bitMask: 0x00000002
                            }
                            ScalarParamIndicator {
                                name: "CBTM Balance Fault"
                                metaParam: parameters.packStatus
                                bitMask: 0x00000004
                            }
                            ScalarParamIndicator {
                                name: "CBTM Internal Fault"
                                metaParam: parameters.packStatus
                                bitMask: 0x00000008
                            }
                            ScalarParamIndicator {
                                name: "CBTM Power Supply Fault"
                                metaParam: parameters.packStatus
                                bitMask: 0x00000010
                            }
                            ScalarParamIndicator {
                                name: "CBTM I2C Fault"
                                metaParam: parameters.packStatus
                                bitMask: 0x00000020
                            }
                            ScalarParamIndicator {
                                name: "CBTM Overtemp"
                                metaParam: parameters.packStatus
                                bitMask: 0x00000040
                            }
                            ScalarParamIndicator {
                                name: "CBTM Comm Fault"
                                metaParam: parameters.packStatus
                                bitMask: 0x00000100
                            }
                            ScalarParamIndicator {
                                name: "CBTM Open Wire"
                                metaParam: parameters.packStatus
                                bitMask: 0x00000100
                            }
                            ScalarParamIndicator {
                                name: "Cell Voltage Sense Lost"
                                metaParam: parameters.packStatus
                                bitMask: 0x00000200
                            }
                            ScalarParamIndicator {
                                name: "Cell Temp Sense Lost"
                                metaParam: parameters.packStatus
                                bitMask: 0x00000400
                            }
                            ScalarParamIndicator {
                                name: "Adjacent Cell Temp Sense Lost"
                                metaParam: parameters.packStatus
                                bitMask: 0x00000800
                            }
                            ScalarParamIndicator {
                                name: "Ground Fault"
                                metaParam: parameters.packStatus
                                bitMask: 0x00001000
                            }
                            ScalarParamIndicator {
                                name: "Limp Home Engaged"
                                metaParam: parameters.packStatus
                                bitMask: 0x00002000
                            }
                            ScalarParamIndicator {
                                name: "String Current Reg Fault"
                                metaParam: parameters.packStatus
                                bitMask: 0x00004000
                            }
                            ScalarParamIndicator {
                                name: "CDA2 Vbat (12/24V) Low"
                                metaParam: parameters.packStatus
                                bitMask: 0x00008000
                            }
                            ScalarParamIndicator {
                                name: "Contactor Inoperative"
                                metaParam: parameters.packStatus
                                bitMask: 0x00010000
                            }
                            ScalarParamIndicator {
                                name: "Traction Precharge Fault"
                                metaParam: parameters.packStatus
                                bitMask: 0x00020000
                            }
                            ScalarParamIndicator {
                                name: "Aux Precharge Fault"
                                metaParam: parameters.packStatus
                                bitMask: 0x00040000
                            }
                            ScalarParamIndicator {
                                name: "String Voltage Low"
                                metaParam: parameters.packStatus
                                bitMask: 0x00080000
                            }


                            ScalarParamIndicator {
                                name: "CBTM Non-Quiescent"
                                metaParam: parameters.packStatus
                                bitMask: 0x40000000
                                color: "yellow"
                            }
                            ScalarParamIndicator {
                                name: "Batt Contactor Closed"
                                metaParam: parameters.packStatus
                                bitMask: 0x20000000
                                color: "yellow"
                            }
                            ScalarParamIndicator {
                                name: "Pos Trac Contactor Closed"
                                metaParam: parameters.packStatus
                                bitMask: 0x10000000
                                color: "yellow"
                            }
                            ScalarParamIndicator {
                                name: "Pos Aux Contactor Closed"
                                metaParam: parameters.packStatus
                                bitMask: 0x08000000
                                color: "yellow"
                            }
                            ScalarParamIndicator {
                                name: "Neg Contactor Closed"
                                metaParam: parameters.packStatus
                                bitMask: 0x04000000
                                color: "yellow"
                            }
                            ScalarParamIndicator {
                                name: "HV Present"
                                metaParam: parameters.packStatus
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
                            metaParam: parameters.sysCycleIdleTicks
                        }
                        ScalarParamEdit {
                            name: "CBTM Input"
                            metaParam: parameters.sysCycleDrvCbtmInTicks
                        }
                        ScalarParamEdit {
                            name: "IAI Input"
                            metaParam: parameters.sysCycleDrvIaiInTicks
                        }
                        ScalarParamEdit {
                            name: "Aux Batt Ctrl"
                            metaParam: parameters.sysCycleCtlAuxBattTicks
                        }
                        ScalarParamEdit {
                            name: "Lamp Ctrl"
                            metaParam: parameters.sysCycleCtlLampTicks
                        }
                        ScalarParamEdit {
                            name: "Motor Ctrl"
                            metaParam: parameters.sysCycleCtlMotorTicks
                        }
                        ScalarParamEdit {
                            name: "Pack Ctrl"
                            metaParam: parameters.sysCycleCtlPackTicks
                        }
                    }
                    ColumnLayout {
                        Layout.alignment: Qt.AlignTop
                        ScalarParamIndicator {
                            name: "Watchdog Reset"
                            metaParam: parameters.sysFlags
                            bitMask: 0x00000001
                        }
                        ScalarParamIndicator {
                            name: "Stack Overflow"
                            metaParam: parameters.sysFlags
                            bitMask: 0x00000004
                        }
                        ScalarParamIndicator {
                            name: "Cycle Time Violation"
                            metaParam: parameters.sysFlags
                            bitMask: 0x00000002
                        }
                        ScalarParamEdit {
                            name: "Heap Alloc Bytes"
                            metaParam: parameters.sysHeapAllocBytes
                        }
                        ScalarParamEdit {
                            name: "Heap Avail Bytes"
                            metaParam: parameters.sysHeapFreeBytes
                        }
                        ScalarParamEdit {
                            name: "Heap Free Count"
                            metaParam: parameters.sysHeapNFrees
                        }
                        ScalarParamEdit {
                            name: "RTDB rows"
                            metaParam: parameters.sysRtDbRows
                        }
                    }
                }
            }
        }
    }
}
