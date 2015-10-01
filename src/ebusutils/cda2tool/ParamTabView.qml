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
            Flow {
                anchors.fill: parent
                anchors.margins: 10
                spacing: 10
                TableParamEdit {
                    tableParam: parameters.aioAiCts
                }
                ScalarParamEdit {
                    name: "VBat"
                    param: parameters.aioVbatEv01
                }
            }
        }

        Tab {
            title: "CAN"
            active: true
            Flow {
                anchors.fill: parent
                anchors.margins: 10
                spacing: 10
                ScalarParamEdit {
                    name: "AuxBattCnvtCmdOn"
                    param: parameters.canAuxBattCnvtCmdOn
                }
                ScalarParamEdit {
                    name: "AuxBattCnvtCmdVolt"
                    param: parameters.canAuxBattCnvtCmdVolt
                }
                ScalarParamEdit {
                    name: "CtlMaxMotoringTorque"
                    param: parameters.canCtlMaxMotoringTorque
                }
                ScalarParamEdit {
                    name: "CtlMaxRegenTorque"
                    param: parameters.canCtlMaxRegenTorque
                }
                ScalarParamEdit {
                    name: "TracMotorSpeed"
                    param: parameters.canTracMotorSpeed
                }
                ScalarParamEdit {
                    name: "LimpHomeCmdOn"
                    param: parameters.canLimpHomeCmdOn
                }
                ScalarParamEdit {
                    name: "BattMaxDischCurrCmd"
                    param: parameters.canBattMaxDischCurrCmd
                }
                ScalarParamEdit {
                    name: "BattMaxChgCurrCmd"
                    param: parameters.canBattMaxChgCurrCmd
                }
                ScalarParamEdit {
                    name: "AuxBattCnvtState"
                    param: parameters.canAuxBattCnvtState
                }
                ScalarParamEdit {
                    name: "AuxBattCnvtTemp"
                    param: parameters.canAuxBattCnvtTemp
                }
                ScalarParamEdit {
                    name: "AuxBattCnvtInputVolt"
                    param: parameters.canAuxBattCnvtInputVolt
                }
                ScalarParamEdit {
                    name: "AuxBattCnvtOutputVolt"
                    param: parameters.canAuxBattCnvtOutputVolt
                }
                ScalarParamEdit {
                    name: "AuxBattCnvtOutputCurr"
                    param: parameters.canAuxBattCnvtOutputCurr
                }
                ScalarParamEdit {
                    name: "ExtChgCtcRqst"
                    param: parameters.canExtChgCtcRqst
                }
                ScalarParamEdit {
                    name: "AuxCtcRqrd"
                    param: parameters.canAuxCtcRqrd
                }
                ScalarParamEdit {
                    name: "XcpProgramRequested"
                    param: parameters.canXcpProgramRequested
                }
                ScalarParamEdit {
                    name: "Can1RxErrCount"
                    param: parameters.canCan1RxErrCount
                }
                ScalarParamEdit {
                    name: "Can1TxErrCount"
                    param: parameters.canCan1TxErrCount
                }
                ScalarParamEdit {
                    name: "Can2RxErrCount"
                    param: parameters.canCan2RxErrCount
                }
                ScalarParamEdit {
                    name: "Can2TxErrCount"
                    param: parameters.canCan2TxErrCount
                }
            }
        }

        Tab {
            title: "CBTM"
            active: true
            RowLayout {
                anchors.fill: parent
                anchors.margins: 10
                spacing: 10
                ColumnLayout {
                    Layout.alignment: Qt.AlignTop
                    ScalarParamEdit {
                        name: "Fault Decay"
                        param: parameters.cbtmFaultDecayCyc
                    }
                    ScalarParamEdit {
                        name: "Non-Quiescent Trip"
                        param: parameters.cbtmNonQuiescentTripCyc
                    }
                    ScalarParamEdit {
                        name: "Non-Quiescent Decay"
                        param: parameters.cbtmNonQuiescentDecayCyc
                    }
                    ScalarParamEdit {
                        name: "Balance Open Delta-V"
                        param: parameters.cbtmBalanceOpenDeltaVThresh
                    }
                    ScalarParamEdit {
                        name: "Balance Short Delta-V"
                        param: parameters.cbtmBalanceShortDeltaVThresh
                    }
                    ScalarParamEdit {
                        name: "Quiescent Delta-V"
                        param: parameters.cbtmQuiescentDeltaVThresh
                    }
                    ScalarParamEdit {
                        name: "IsoSPI #1 First ID"
                        param: parameters.cbtmIsospi1FirstBoard
                    }
                    ScalarParamEdit {
                        name: "IsoSPI #1 Last ID"
                        param: parameters.cbtmIsospi1LastBoard
                    }
                    ScalarParamEdit {
                        name: "IsoSPI #2 First ID"
                        param: parameters.cbtmIsospi2FirstBoard
                    }
                    ScalarParamEdit {
                        name: "IsoSPI #2 Last ID"
                        param: parameters.cbtmIsospi2LastBoard
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
                    Layout.fillWidth: true
                    Layout.fillHeight: true
                    GroupBox {
                        Layout.fillWidth: true
                        Layout.fillHeight: true
                        title: "Cell Voltages"
                        TablePlot {
                            XYTrace {
                                tableModel: parameters.cbtmCellVolt.stringModel
                                valid: parameters.cbtmCellVolt.value.valid
                            }
                        }
                    }
                    GroupBox {
                        Layout.fillWidth: true
                        Layout.fillHeight: true
                        title: "Tab Temperatures"
                        TablePlot {
                            XYTrace {
                                tableModel: parameters.cbtmTabTemp.stringModel
                                valid: parameters.cbtmTabTemp.value.valid
                            }
                        }
                    }
                }
            }
        }

        Tab {
            title: "Contactor"
            active: true
            Flow {
                anchors.fill: parent
                anchors.margins: 10
                spacing: 10
                ScalarParamEdit {
                    name: "Max Simul Pickups"
                    param: parameters.ctcMaxSimulPickup
                }
                TableParamEdit {
                    xLabel: "Ctc #"
                    valueLabel: "Has B"
                    tableParam: parameters.ctcHasBInput
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

        Tab {
            title: "DIO"
            active: true
            Flow {
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

        Tab {
            title: "IAI"
            active: true
            Flow {
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
                    param: parameters.iai4PosCts
                }
                ScalarParamEdit {
                    name: "IAI #4 Neg"
                    param: parameters.iai4NegCts
                }
                ScalarParamEdit {
                    name: "IAI #4 Pullup"
                    param: parameters.iai4Pullup
                }
                ScalarParamEdit {
                    name: "IAI #4 Pulldown"
                    param: parameters.iai4Pulldown
                }
            }
        }

        Tab {
            title: "Aux Batt"
            active: true
            Flow {
                anchors.fill: parent
                anchors.margins: 10
                spacing: 10
                EncodingParamEdit {
                    name: "CnvtType"
                    param: parameters.auxBattCnvtType
                }
                ScalarParamEdit {
                    name: "CnvtInputVoltMin"
                    param: parameters.auxBattCnvtInputVoltMin
                }
                ScalarParamEdit {
                    name: "CnvtStartTemp"
                    param: parameters.auxBattCnvtStartTemp
                }
                ScalarParamEdit {
                    name: "CnvtStopTemp"
                    param: parameters.auxBattCnvtStopTemp
                }
                ScalarParamEdit {
                    name: "FloatVolt"
                    param: parameters.auxBattFloatVolt
                }
                ScalarParamEdit {
                    name: "FloatVoltTempCoeff"
                    param: parameters.auxBattFloatVoltTempCoeff
                }
                ScalarParamEdit {
                    name: "FloatVoltMin"
                    param: parameters.auxBattFloatVoltMin
                }
                ScalarParamEdit {
                    name: "FloatVoltMax"
                    param: parameters.auxBattFloatVoltMax
                }
                ScalarParamEdit {
                    name: "FloatVoltFailsafe"
                    param: parameters.auxBattFloatVoltFailsafe
                }
                ScalarParamEdit {
                    name: "RestartVoltHysteresis"
                    param: parameters.auxBattRestartVoltHysteresis
                }
                ScalarParamEdit {
                    name: "RestartVoltTime"
                    param: parameters.auxBattRestartVoltTime
                }
                ScalarParamEdit {
                    name: "RestartAlwaysTime"
                    param: parameters.auxBattRestartAlwaysTime
                }
                ScalarParamEdit {
                    name: "StopOutCurr"
                    param: parameters.auxBattStopOutCurr
                }
                ScalarParamEdit {
                    name: "StopOutCurrTime"
                    param: parameters.auxBattStopOutCurrTime
                }
                ScalarParamEdit {
                    name: "BattOkTemp"
                    param: parameters.auxBattBattOkTemp
                }
                ScalarParamEdit {
                    name: "BattWarmTemp"
                    param: parameters.auxBattBattWarmTemp
                }
                ScalarParamEdit {
                    name: "BattHotTemp"
                    param: parameters.auxBattBattHotTemp
                }
                ScalarParamEdit {
                    name: "BattTemp0AiChan"
                    param: parameters.auxBattBattTemp0AiChan
                }
                ScalarParamEdit {
                    name: "BattTemp1AiChan"
                    param: parameters.auxBattBattTemp1AiChan
                }
                EncodingParamEdit {
                    name: "BattTemp0Curve"
                    param: parameters.auxBattBattTemp0Curve
                }
                EncodingParamEdit {
                    name: "BattTemp1Curve"
                    param: parameters.auxBattBattTemp1Curve
                }
                ScalarParamEdit {
                    name: "RestartVoltTimeCount"
                    param: parameters.auxBattRestartVoltTimeCount
                }
                ScalarParamEdit {
                    name: "RestartAlwaysTimeCount"
                    param: parameters.auxBattRestartAlwaysTimeCount
                }
                ScalarParamEdit {
                    name: "StopOutCurrTimeCount"
                    param: parameters.auxBattStopOutCurrTimeCount
                }
                ScalarParamEdit {
                    name: "BattTemp0"
                    param: parameters.auxBattBattTemp0
                }
                ScalarParamEdit {
                    name: "BattTemp1"
                    param: parameters.auxBattBattTemp1
                }
                ScalarParamEdit {
                    name: "Status"
                    param: parameters.auxBattStatus
                }
            }
        }

        Tab {
            title: "Motor"
            active: true
            Flow {
                anchors.fill: parent
                anchors.margins: 10
                spacing: 10
                ScalarParamEdit {
                    name: "FailsafeSpeed"
                    param: parameters.motorFailsafeSpeed
                }
                ScalarParamEdit {
                    name: "MinEffSpeed"
                    param: parameters.motorMinEffSpeed
                }
                ScalarParamEdit {
                    name: "RatedTorque"
                    param: parameters.motorRatedTorque
                }
                ScalarParamEdit {
                    name: "CurrRegPropCoeff"
                    param: parameters.motorCurrRegPropCoeff
                }
                ScalarParamEdit {
                    name: "CurrRegIntCoeff"
                    param: parameters.motorCurrRegIntCoeff
                }
                ScalarParamEdit {
                    name: "MaxTorqueRefErr"
                    param: parameters.motorMaxTorqueRefErr
                }
                ScalarParamEdit {
                    name: "MotoringIntegrator"
                    param: parameters.motorMotoringIntegrator
                }
                ScalarParamEdit {
                    name: "RegenIntegrator"
                    param: parameters.motorRegenIntegrator
                }
                ScalarParamEdit {
                    name: "AdjMaxMotoringCurr"
                    param: parameters.motorAdjMaxMotoringCurr
                }
                ScalarParamEdit {
                    name: "AdjMaxRegenCurr"
                    param: parameters.motorAdjMaxRegenCurr
                }
            }
        }

        Tab {
            title: "Pack Setup"
            active: true
            RowLayout {
                anchors.fill: parent
                anchors.margins: 10
                spacing: 10
                GroupBox {
                    Layout.alignment: Qt.AlignTop
                    title: "IAI"
                    ColumnLayout {
                        EncodingParamEdit {
                            name: "Mapping"
                            param: parameters.packIaiFunc
                        }
                        ScalarParamEdit {
                            name: "#1 Scale"
                            param: parameters.packIai1Scale
                        }
                        ScalarParamEdit {
                            name: "#2 Scale"
                            param: parameters.packIai2Scale
                        }
                        ScalarParamEdit {
                            name: "#3 Scale"
                            param: parameters.packIai3Scale
                        }
                        ScalarParamEdit {
                            name: "#4 Scale"
                            param: parameters.packIai4Scale
                        }
                        ScalarParamEdit {
                            name: "#1 Zero"
                            param: parameters.packIai1Zero
                        }
                        ScalarParamEdit {
                            name: "#2 Zero"
                            param: parameters.packIai2Zero
                        }
                        ScalarParamEdit {
                            name: "#3 Zero"
                            param: parameters.packIai3Zero
                        }
                        ScalarParamEdit {
                            name: "#4 Zero"
                            param: parameters.packIai4Zero
                        }
                    }
                }
                GroupBox {
                    Layout.alignment: Qt.AlignTop
                    title: "Cell Protection"
                    ColumnLayout {
                        ScalarParamEdit {
                            name: "Limp Home Disch"
                            param: parameters.packLimpHomeDischCurr
                        }
                        ScalarParamEdit {
                            name: "Limp Home Chg"
                            param: parameters.packLimpHomeChgCurr
                        }
                        ScalarParamEdit {
                            name: "Safety Margin"
                            param: parameters.packCellProtMarginCurr
                        }
                        ScalarParamEdit {
                            name: "Current Reg Fault Trip"
                            param: parameters.packCurrRegFltTripCyc
                        }
                        ScalarParamEdit {
                            name: "Current Reg Fault Decay"
                            param: parameters.packCurrRegFltDecayCyc
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
                            param: parameters.packBalBandVolt
                        }
                        ScalarParamEdit {
                            name: "Minimum Difference"
                            param: parameters.packBalDiffVolt
                        }
                        ScalarParamEdit {
                            name: "Sample Wait Time"
                            param: parameters.packBalSampleWaitCyc
                        }
                        ScalarParamEdit {
                            name: "High Cell Disch Time"
                            param: parameters.packBalDischHighCyc
                        }
                        ScalarParamEdit {
                            name: "All Cell Disch Time"
                            param: parameters.packBalDischAllCyc
                        }
                    }
                }
                GroupBox {
                    Layout.alignment: Qt.AlignTop
                    title: "Ground Fault"
                    ColumnLayout {
                        ScalarParamEdit {
                            name: "Sample Time"
                            param: parameters.packGndFltDetectAvgCyc
                        }
                        ScalarParamEdit {
                            name: "Cycle Period"
                            param: parameters.packGndFltDetectPeriodCyc
                        }
                        ScalarParamEdit {
                            name: "Fault Threshold"
                            param: parameters.packGndFltTripConduct
                        }
                        ScalarParamEdit {
                            name: "Fault Trip Cycles"
                            param: parameters.packGndFltTripCyc
                        }
                        ScalarParamEdit {
                            name: "Fault Decay Cycles"
                            param: parameters.packGndFltDecayCyc
                        }
                    }
                }
                GroupBox {
                    Layout.alignment: Qt.AlignTop
                    title: "Pack Safety"
                    ColumnLayout {
                        ScalarParamEdit {
                            name: "Traction Current Decay Time"
                            param: parameters.packTracCurrDecayCyc
                        }
                        ScalarParamEdit {
                            name: "Charge Current Decay Time"
                            param: parameters.packChgCurrDecayCyc
                        }
                        ScalarParamEdit {
                            name: "Max Traction Precharge Time"
                            param: parameters.packMaxTracPrechgCyc
                        }
                        ScalarParamEdit {
                            name: "Low Voltage Trip"
                            param: parameters.packLowStringVoltTrip
                        }
                        ScalarParamEdit {
                            name: "Low Voltage Reset"
                            param: parameters.packLowStringVoltReset
                        }
                    }
                }
            }
        }

        Tab {
            title: "Pack Data"
            active: true
            RowLayout {
                anchors.fill: parent
                anchors.margins: 10
                spacing: 10
                GroupBox {
                    Layout.alignment: Qt.AlignTop
                    title: "Voltages && Currents"
                    ColumnLayout {
                        ScalarParamEdit {
                            name: "Battery Voltage"
                            param: parameters.packString1Volt
                        }
                        ScalarParamEdit {
                            name: "Battery Current"
                            param: parameters.packString1Curr
                        }
                        ScalarParamEdit {
                            name: "Traction Motor"
                            param: parameters.packTracMtrCurr
                        }
                        ScalarParamEdit {
                            name: "Traction Aux"
                            param: parameters.packTracAuxCurr
                        }
                        ScalarParamEdit {
                            name: "Traction Total"
                            param: parameters.packTracTotalCurr
                        }
                        ScalarParamEdit {
                            name: "Hybrid"
                            param: parameters.packHybrCurr
                        }
                        ScalarParamEdit {
                            name: "Non-Traction Aux"
                            param: parameters.packNonTracAuxCurr
                        }
                    }
                }

                GroupBox {
                    Layout.alignment: Qt.AlignTop
                    title: "Ground Fault"
                    ColumnLayout {
                        ScalarParamEdit {
                            name: "Pulldown Pos Voltage"
                            param: parameters.packGndFltDetectPulldownPosVolt
                        }
                        ScalarParamEdit {
                            name: "Pulldown Neg Voltage"
                            param: parameters.packGndFltDetectPulldownNegVolt
                        }
                        ScalarParamEdit {
                            name: "Pullup Pos Voltage"
                            param: parameters.packGndFltDetectPullupPosVolt
                        }
                        ScalarParamEdit {
                            name: "Pullup Neg Voltage"
                            param: parameters.packGndFltDetectPullupNegVolt
                        }
                        ScalarParamEdit {
                            name: "Center Voltage"
                            param: parameters.packGndFltCenterVolt
                        }
                        ScalarParamEdit {
                            name: "Location In Pack"
                            param: parameters.packGndFltFrac
                        }
                        ScalarParamEdit {
                            name: "Conductance"
                            param: parameters.packGndFltConduct
                        }
                    }
                }

                GroupBox {
                    Layout.alignment: Qt.AlignTop
                    title: "Cell Statistics"
                    ColumnLayout {
                        ScalarParamEdit {
                            name: "Max Voltage"
                            param: parameters.packMaxCellVolt
                        }
                        ScalarParamEdit {
                            name: "Mean Voltage"
                            param: parameters.packMeanCellVolt
                        }
                        ScalarParamEdit {
                            name: "Min Voltage"
                            param: parameters.packMinCellVolt
                        }
                        ScalarParamEdit {
                            name: "Max Temp"
                            param: parameters.packMaxCellTemp
                        }
                        ScalarParamEdit {
                            name: "Mean Temp"
                            param: parameters.packMeanCellTemp
                        }
                        ScalarParamEdit {
                            name: "Min Temp"
                            param: parameters.packMinCellTemp
                        }
                    }
                }

                GroupBox {
                    Layout.alignment: Qt.AlignTop
                    title: "Cell Protection"
                    ColumnLayout {
                        ScalarParamEdit {
                            name: "Max Voltage"
                            param: parameters.packCellProtMaxVolt
                        }
                        ScalarParamEdit {
                            name: "Min Voltage"
                            param: parameters.packCellProtMinVolt
                        }
                        ScalarParamEdit {
                            name: "Resistance For Calc"
                            param: parameters.packCellProtRes
                        }
                        ScalarParamEdit {
                            name: "Max Disch (Voltage)"
                            param: parameters.packCellProtVoltageMaxDischCurr
                        }
                        ScalarParamEdit {
                            name: "Max Chg (Voltage)"
                            param: parameters.packCellProtVoltageMaxChgCurr
                        }
                        ScalarParamEdit {
                            name: "Max Disch (Thermal)"
                            param: parameters.packCellProtThermalMaxDischCurr
                        }
                        ScalarParamEdit {
                            name: "Max Chg (Thermal)"
                            param: parameters.packCellProtThermalMaxChgCurr
                        }
                    }
                }

                GroupBox {
                    title: "Current Limits"
                    Layout.alignment: Qt.AlignTop
                    ColumnLayout {
                        ScalarParamEdit {
                            name: "String Max Disch"
                            param: parameters.packString1MaxDischCurr
                        }
                        ScalarParamEdit {
                            name: "String Max Chg"
                            param: parameters.packString1MaxChgCurr
                        }
                        ScalarParamEdit {
                            name: "Trac Max Disch"
                            param: parameters.packTracMaxDischCurr
                        }
                        ScalarParamEdit {
                            name: "Trac Max Chg"
                            param: parameters.packTracMaxChgCurr
                        }
                    }
                }

                GroupBox {
                    title: "State"
                    Layout.alignment: Qt.AlignTop
                    ColumnLayout {
                        ScalarParamEdit {
                            name: "Ctc Ctrl State"
                            param: parameters.packCtcCtrlStateCode
                        }
                        ScalarParamEdit {
                            name: "Balancer State"
                            param: parameters.packBalancerStateCode
                        }
                        ScalarParamIndicator {
                            name: "CBTM Open Wire"
                            param: parameters.packStatus
                            bitMask: 0x00000001
                        }
                        ScalarParamIndicator {
                            name: "CBTM Thermistor Fault"
                            param: parameters.packStatus
                            bitMask: 0x00000002
                        }
                        ScalarParamIndicator {
                            name: "CBTM Balance Fault"
                            param: parameters.packStatus
                            bitMask: 0x00000004
                        }
                        ScalarParamIndicator {
                            name: "CBTM Internal Fault"
                            param: parameters.packStatus
                            bitMask: 0x00000008
                        }
                        ScalarParamIndicator {
                            name: "CBTM Power Supply Fault"
                            param: parameters.packStatus
                            bitMask: 0x00000010
                        }
                        ScalarParamIndicator {
                            name: "CBTM I2C Fault"
                            param: parameters.packStatus
                            bitMask: 0x00000020
                        }
                        ScalarParamIndicator {
                            name: "CBTM Overtemp"
                            param: parameters.packStatus
                            bitMask: 0x00000040
                        }
                        ScalarParamIndicator {
                            name: "CBTM Comm Fault"
                            param: parameters.packStatus
                            bitMask: 0x00000100
                        }
                        ScalarParamIndicator {
                            name: "CBTM Open Wire"
                            param: parameters.packStatus
                            bitMask: 0x00000100
                        }
                        ScalarParamIndicator {
                            name: "Cell Voltage Sense Lost"
                            param: parameters.packStatus
                            bitMask: 0x00000200
                        }
                        ScalarParamIndicator {
                            name: "Cell Temp Sense Lost"
                            param: parameters.packStatus
                            bitMask: 0x00000400
                        }
                        ScalarParamIndicator {
                            name: "Adjacent Cell Temp Sense Lost"
                            param: parameters.packStatus
                            bitMask: 0x00000800
                        }
                        ScalarParamIndicator {
                            name: "Ground Fault"
                            param: parameters.packStatus
                            bitMask: 0x00001000
                        }
                        ScalarParamIndicator {
                            name: "Limp Home Engaged"
                            param: parameters.packStatus
                            bitMask: 0x00002000
                        }
                        ScalarParamIndicator {
                            name: "String Current Reg Fault"
                            param: parameters.packStatus
                            bitMask: 0x00004000
                        }
                        ScalarParamIndicator {
                            name: "CDA2 Vbat (12/24V) Low"
                            param: parameters.packStatus
                            bitMask: 0x00008000
                        }
                        ScalarParamIndicator {
                            name: "Contactor Inoperative"
                            param: parameters.packStatus
                            bitMask: 0x00010000
                        }
                        ScalarParamIndicator {
                            name: "Traction Precharge Fault"
                            param: parameters.packStatus
                            bitMask: 0x00020000
                        }
                        ScalarParamIndicator {
                            name: "Aux Precharge Fault"
                            param: parameters.packStatus
                            bitMask: 0x00040000
                        }
                        ScalarParamIndicator {
                            name: "String Voltage Low"
                            param: parameters.packStatus
                            bitMask: 0x00080000
                        }


                        ScalarParamIndicator {
                            name: "CBTM Non-Quiescent"
                            param: parameters.packStatus
                            bitMask: 0x40000000
                            color: "yellow"
                        }
                        ScalarParamIndicator {
                            name: "Batt Contactor Closed"
                            param: parameters.packStatus
                            bitMask: 0x20000000
                            color: "yellow"
                        }
                        ScalarParamIndicator {
                            name: "Pos Trac Contactor Closed"
                            param: parameters.packStatus
                            bitMask: 0x10000000
                            color: "yellow"
                        }
                        ScalarParamIndicator {
                            name: "Pos Aux Contactor Closed"
                            param: parameters.packStatus
                            bitMask: 0x08000000
                            color: "yellow"
                        }
                        ScalarParamIndicator {
                            name: "Neg Contactor Closed"
                            param: parameters.packStatus
                            bitMask: 0x04000000
                            color: "yellow"
                        }
                        ScalarParamIndicator {
                            name: "HV Present"
                            param: parameters.packStatus
                            bitMask: 0x02000000
                            color: "yellow"
                        }
                    }
                }
            }
        }

        Tab {
            title: "System"
            active: true
            RowLayout {
                anchors.fill: parent
                anchors.margins: 10
                spacing: 10
                ColumnLayout {
                    Layout.alignment: Qt.AlignTop
                    ScalarParamEdit {
                        name: "Idle Time"
                        param: parameters.sysCycleIdleTicks
                    }
                    ScalarParamEdit {
                        name: "CBTM Input"
                        param: parameters.sysCycleDrvCbtmInTicks
                    }
                    ScalarParamEdit {
                        name: "IAI Input"
                        param: parameters.sysCycleDrvIaiInTicks
                    }
                    ScalarParamEdit {
                        name: "Aux Batt Ctrl"
                        param: parameters.sysCycleCtlAuxBattTicks
                    }
                    ScalarParamEdit {
                        name: "Lamp Ctrl"
                        param: parameters.sysCycleCtlLampTicks
                    }
                    ScalarParamEdit {
                        name: "Motor Ctrl"
                        param: parameters.sysCycleCtlMotorTicks
                    }
                    ScalarParamEdit {
                        name: "Pack Ctrl"
                        param: parameters.sysCycleCtlPackTicks
                    }
                }
            }
        }
    }
}
