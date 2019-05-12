import QtQuick 2.5
import QtQuick.Controls 1.4
import QtQuick.Controls 2.1
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
    property ParamLayer paramLayer
    anchors.left: parent.left
    anchors.right: parent.right

    TabView {
        id: tabView
        anchors.fill: parent

        Tab {
            title: "AIO/DIO/PWM"
            active: true
            AutoRefreshArea {
                base: this
                RowLayout {
                    Layout.alignment: Qt.AlignLeft
                    anchors.fill: parent
                    anchors.margins: 5
                    spacing: 5
                    SplitView {
                        Layout.fillHeight: true
                        orientation: Qt.Vertical
                        TableParamEdit {
                            Layout.fillHeight: true
                            xLabel: "AI #"
                            tableMetaParam: registry.aioAiCts
                        }
                        TableParamEdit {
                            xLabel: "AO #"
                            tableMetaParam: registry.aioAoCts
                        }

                    }
                    ColumnLayout {
                        RowLayout {
                            Layout.alignment: Qt.AlignLeft
                            spacing: 5

//                            ColumnLayout {
//                                Layout.alignment: Qt.AlignTop
//                                ScalarParamEdit {
//                                    metaParam: registry.aioMagneticsTemp
//                                }
//                                ScalarParamEdit {
//                                    metaParam: registry.aioColdplateTemp
//                                }
//                                ScalarParamEdit {
//                                    metaParam: registry.aioIgbt1Temp
//                                }
//                                ScalarParamEdit {
//                                    metaParam: registry.aioIgbt2Temp
//                                }
//                                ScalarParamEdit {
//                                    metaParam: registry.aioVbatVolt
//                                }
//                                ScalarParamEdit {
//                                    metaParam: registry.aioVref2V5Volt
//                                }
//                            }

//                            ColumnLayout {
//                                Layout.alignment: Qt.AlignTop
//                                Label {
//                                    text: "Stage 1 Current"
//                                }
//                                TableParamEdit {
//                                    xLabel: "Phase"
//                                    tableMetaParam: registry.aioDcdcRegCurr
//                                    encodingColumnWidth: 70
//                                }
//                                ScalarParamEdit {
//                                    metaParam: registry.aioDcdcRegInVolt
//                                }
//                                ScalarParamEdit {
//                                    metaParam: registry.aioDcdcRegOutVolt
//                                }
//                                ScalarParamEdit {
//                                    metaParam: registry.aioDcdcLvCapCenterVolt
//                                }
//                                ScalarParamEdit {
//                                    metaParam: registry.aioDcdcRectOutVolt
//                                }
//                                ScalarParamEdit {
//                                    metaParam: registry.aioDcdcLvCtcOutVolt
//                                }
//                            }

                            ColumnLayout {
                                Layout.alignment: Qt.AlignTop
                                ScalarParamEdit {
                                    metaParam: registry.aioCurrZeroCalibStart
                                }
                                ScalarParamEdit {
                                    metaParam: registry.aioCurrZeroCalibDone
                                }
                            }
                            ColumnLayout {
                                Layout.alignment: Qt.AlignTop
                                Label {
                                    text: "Bridge 1 Phase Error"
                                }

                                TableParamEdit {
                                    xLabel: "Phase"
                                    tableMetaParam: registry.dioBrdg1PhsError
                                    encodingColumnWidth: 70
                                }
                                Label {
                                    text: "Bridge 2 Phase Error"
                                }
                                TableParamEdit {
                                    xLabel: "Phase"
                                    tableMetaParam: registry.dioBrdg2PhsError
                                    encodingColumnWidth: 70
                                }
                            }
                            ColumnLayout {
                                Layout.alignment: Qt.AlignTop
                                ScalarParamEdit {
                                    metaParam: registry.dioBrdg1VoltError
                                }
                                ScalarParamEdit {
                                    metaParam: registry.dioBrdg1TempError
                                }
                                ScalarParamEdit {
                                    metaParam: registry.dioBrdg2Overtemp
                                }
                                ScalarParamEdit {
                                    metaParam: registry.dioCtc1Aux
                                }
                                ScalarParamEdit {
                                    metaParam: registry.dioCtc2Aux
                                }
                                ScalarParamEdit {
                                    metaParam: registry.dioCtc3Aux
                                }
                                ScalarParamEdit {
                                    metaParam: registry.dioSpareDi1
                                }
                            }
                            ColumnLayout {
                                Layout.alignment: Qt.AlignTop
                                ScalarParamSpinBox {
                                    metaParam: registry.dioCtc1Coil
                                }
                                ScalarParamSpinBox {
                                    metaParam: registry.dioCtc2Coil
                                }
                                ScalarParamSpinBox {
                                    metaParam: registry.dioCtc3Coil
                                }
                                ScalarParamSpinBox {
                                    metaParam: registry.dioBrdg2FetEnable
                                }
                                ScalarParamSpinBox {
                                    metaParam: registry.dioSpareDo1
                                }
                                ScalarParamSpinBox {
                                    metaParam: registry.dioSoftBaseblock
                                }
                            }
                        }

                        ToolSeparator {
                            Layout.fillWidth: true
                            orientation: Qt.Horizontal
                        }

                        RowLayout {
                            Layout.alignment: Qt.AlignLeft
                            spacing: 5

                            ColumnLayout {
                                Layout.alignment: Qt.AlignTop
                                ScalarParamSpinBox {
                                    metaParam: registry.pwmBridge1Deadband
                                }
                            }
                            ColumnLayout {
                                Layout.alignment: Qt.AlignTop
                                ScalarParamSpinBox {
                                    metaParam: registry.pwmBridge1Freq
                                }
                                EncodingParamEdit {
                                    metaParam: registry.pwmBridge1RotationCba
                                }
                                ScalarParamSpinBox {
                                    metaParam: registry.pwmBridge1Peak
                                }
                                ScalarParamSpinBox {
                                    metaParam: registry.pwmBridge1Zero
                                }
                                ScalarParamSpinBox {
                                    metaParam: registry.pwmBridge1TopForce
                                }
                                ScalarParamSpinBox {
                                    metaParam: registry.pwmBridge1BottomForce
                                }
                            }
                            ColumnLayout {
                                Layout.alignment: Qt.AlignTop
                                Label {
                                    text: "Bridge 1 Phase Peak"
                                }
                                TableParamEdit {
                                    xLabel: "Phase"
                                    tableMetaParam: registry.pwmBridge1PhasePeak
                                    encodingColumnWidth: 70
                                }
                                Label {
                                    text: "Bridge 1 Phase Zero"
                                }
                                TableParamEdit {
                                    xLabel: "Phase"
                                    tableMetaParam: registry.pwmBridge1PhaseZero
                                    encodingColumnWidth: 70
                                }
                            }
                            ColumnLayout {
                                Layout.alignment: Qt.AlignTop
                                ScalarParamSpinBox {
                                    metaParam: registry.pwmBridge2Freq
                                }
                                ScalarParamSpinBox {
                                    metaParam: registry.pwmBridge2Duty
                                }
                                ScalarParamSpinBox {
                                    metaParam: registry.pwmBridge2DutyA
                                }
                                ScalarParamSpinBox {
                                    metaParam: registry.pwmBridge2DutyB
                                }
                                ScalarParamSpinBox {
                                    metaParam: registry.pwmBridge2TopForce
                                }
                                ScalarParamSpinBox {
                                    metaParam: registry.pwmBridge2BottomForce
                                }
                            }
                            ColumnLayout {
                                Layout.alignment: Qt.AlignTop
                                Label {
                                    text: "Bridge 2 Phase Duty A"
                                }
                                TableParamEdit {
                                    xLabel: "Phase"
                                    tableMetaParam: registry.pwmBridge2PhaseDutyA
                                    encodingColumnWidth: 70
                                }
                                Label {
                                    text: "Bridge 2 Phase Duty B"
                                }
                                TableParamEdit {
                                    xLabel: "Phase"
                                    tableMetaParam: registry.pwmBridge2PhaseDutyB
                                    encodingColumnWidth: 70
                                }
                            }
                        }
                    }

                }
            }
        }

        Tab {
            title: "DCDC"
            active: true
            AutoRefreshArea {
                base: this
                RowLayout {
                    Layout.alignment: Qt.AlignLeft
                    anchors.fill: parent
                    anchors.margins: 5
                    spacing: 5

                    ColumnLayout {
                        Layout.alignment: Qt.AlignTop
                        ScalarParamEdit {
                            metaParam: registry.aioMagneticsTemp
                        }
                        ScalarParamEdit {
                            metaParam: registry.aioColdplateTemp
                        }
                        ScalarParamEdit {
                            metaParam: registry.aioIgbt1Temp
                        }
                        ScalarParamEdit {
                            metaParam: registry.aioIgbt2Temp
                        }
                        ScalarParamEdit {
                            metaParam: registry.aioVbatVolt
                        }
                        ScalarParamEdit {
                            metaParam: registry.aioVref2V5Volt
                        }
                    }

                    ColumnLayout {
                        Layout.alignment: Qt.AlignTop
                        Label {
                            text: "Stage 1 Current"
                        }
                        TableParamEdit {
                            xLabel: "Phase"
                            tableMetaParam: registry.aioDcdcRegCurr
                            encodingColumnWidth: 70
                        }
                        TableParamEdit {
                            xLabel: "Phase"
                            tableMetaParam: registry.aioDcdcXfmrAbsCurr
                            encodingColumnWidth: 70
                        }
                        TableParamEdit {
                            xLabel: "Phase"
                            tableMetaParam: registry.aioDcdcXfmrAvgCurr
                            encodingColumnWidth: 70
                        }
                        ScalarParamEdit {
                            metaParam: registry.aioDcdcRegInVolt
                        }
                        ScalarParamEdit {
                            metaParam: registry.aioDcdcRegOutVolt
                        }
                        ScalarParamEdit {
                            metaParam: registry.aioDcdcLvCapCenterVolt
                        }
                        ScalarParamEdit {
                            metaParam: registry.aioDcdcRectOutVolt
                        }
                        ScalarParamEdit {
                            metaParam: registry.aioDcdcLvCtcOutVolt
                        }
                    }
                    ColumnLayout {
                        Layout.alignment: Qt.AlignTop
                        Label {
                            text: "Bridge 1 Phase Error"
                        }

                        TableParamEdit {
                            xLabel: "Phase"
                            tableMetaParam: registry.dioBrdg1PhsError
                            encodingColumnWidth: 70
                        }
                        Label {
                            text: "Bridge 2 Phase Error"
                        }
                        TableParamEdit {
                            xLabel: "Phase"
                            tableMetaParam: registry.dioBrdg2PhsError
                            encodingColumnWidth: 70
                        }
                        ScalarParamEdit {
                            metaParam: registry.dioBrdg2Overtemp
                        }
                        ScalarParamEdit {
                            metaParam: registry.dioCtc1Aux
                        }
                        ScalarParamSpinBox {
                            metaParam: registry.dioCtc1Coil
                        }
                        ScalarParamSpinBox {
                            metaParam: registry.dioBrdg2FetEnable
                        }
                    }
                    ColumnLayout {
                        Layout.alignment: Qt.AlignTop
                        ScalarParamSpinBox {
                            metaParam: registry.pwmBridge1Deadband
                        }
                        ScalarParamSpinBox {
                            metaParam: registry.pwmBridge1TopForce
                        }
                        ScalarParamSpinBox {
                            metaParam: registry.pwmBridge1BottomForce
                        }
                        Label {
                            text: "Bridge 1 Phase Zero"
                        }
                        TableParamEdit {
                            xLabel: "Phase"
                            tableMetaParam: registry.pwmBridge1PhaseZero
                            encodingColumnWidth: 70
                        }
                        ScalarParamSpinBox {
                            metaParam: registry.pwmBridge2Duty
                        }
                        ScalarParamSpinBox {
                            metaParam: registry.pwmBridge2TopForce
                        }
                        ScalarParamSpinBox {
                            metaParam: registry.pwmBridge2BottomForce
                        }
                    }
                    ColumnLayout {
                        Layout.alignment: Qt.AlignTop
                        ScalarParamSpinBox {
                            metaParam: registry.dcdcReducedCurrOutVolt
                        }
                        ScalarParamSpinBox {
                            metaParam: registry.dcdcFullCurrOutVolt
                        }
                        ScalarParamSpinBox {
                            metaParam: registry.dcdcReducedMaxOutCurr
                        }
                        ScalarParamSpinBox {
                            metaParam: registry.dcdcFullMaxOutCurr
                        }
                        ScalarParamSpinBox {
                            metaParam: registry.dcdcCurrLimIntCoeff
                        }
                        ScalarParamSpinBox {
                            metaParam: registry.dcdcOutVoltRegPropCoeff
                        }
                        ScalarParamSpinBox {
                            metaParam: registry.dcdcOutVoltRegIntCoeff
                        }
                        ScalarParamSpinBox {
                            metaParam: registry.dcdcIgbtDrop
                        }
                        ScalarParamSpinBox {
                            metaParam: registry.dcdcLinkVoltRegIntCoeff
                        }
                        ScalarParamSpinBox {
                            metaParam: registry.dcdcStage1CurrBalIntCoeff
                        }
                        ScalarParamSpinBox {
                            metaParam: registry.dcdcStage1CurrBalMaxAdj
                        }
                    }
                    ColumnLayout {
                        Layout.alignment: Qt.AlignTop
                        ScalarParamSpinBox {
                            metaParam: registry.canDcdcOutVoltCmd
                        }
                        ScalarParamSpinBox {
                            metaParam: registry.canDcdcEnableCmd
                        }
                        ScalarParamEdit {
                            metaParam: registry.dcdcState
                        }
                        ScalarParamEdit {
                            metaParam: registry.dcdcOutVoltCmd
                        }
                        ScalarParamEdit {
                            metaParam: registry.dcdcCurrLimIntegrator
                        }
                        ScalarParamEdit {
                            metaParam: registry.dcdcAdjOutVoltCmd
                        }
                        ScalarParamEdit {
                            metaParam: registry.dcdcOutVoltRegIntegrator
                        }
                        ScalarParamEdit {
                            metaParam: registry.dcdcLinkVoltCmd
                        }
                        ScalarParamEdit {
                            metaParam: registry.dcdcStage1AvgPhaseDuty
                        }
                        ScalarParamEdit {
                            metaParam: registry.dcdcLinkVoltRegIntegrator
                        }
                        ScalarParamEdit {
                            metaParam: registry.dcdcLinkPowerBasedOutputCurrent
                        }
                        ScalarParamEdit {
                            metaParam: registry.dcdcXfmrPrimaryBasedOutputCurrent
                        }
                        ScalarParamEdit {
                            metaParam: registry.dcdcLinkPowerBasedInputCurrent
                        }
                    }
                }
            }
        }

        Tab {
            title: "BC I/O"
            active: true
            AutoRefreshArea {
                base: this
                RowLayout {
                    Layout.alignment: Qt.AlignLeft
                    anchors.fill: parent
                    anchors.margins: 5
                    spacing: 5

                    ColumnLayout {
                        ScalarParamEdit {
                            metaParam: registry.aioBcAcVoltageAB
                        }
                        ScalarParamEdit {
                            metaParam: registry.aioBcAcVoltageBC
                        }
                        ScalarParamEdit {
                            metaParam: registry.aioBcAcVoltageCA
                        }
                        Label {
                            text: "Line Volt Phase-Mid"
                        }
                        TableParamEdit {
                            xLabel: "Phase"
                            tableMetaParam: registry.aioBcAcVoltageMid
                            encodingColumnWidth: 70
                        }
                        ScalarParamEdit {
                            metaParam: registry.aioBcDcOutCurr
                        }
                        ScalarParamEdit {
                            metaParam: registry.aioBcConnSizeMon
                        }
                        ScalarParamEdit {
                            metaParam: registry.aioBcRectVoltNeg
                        }
                        ScalarParamEdit {
                            metaParam: registry.aioBcRectVoltPos
                        }
                        ScalarParamEdit {
                            metaParam: registry.aioBcDcOutVolt
                        }
                        ScalarParamEdit {
                            metaParam: registry.aioBcVehDcVolt
                        }
                    }

                    ColumnLayout {
                        Layout.alignment: Qt.AlignTop
                        Label {
                            text: "Line Current"
                        }
                        TableParamEdit {
                            xLabel: "Phase"
                            tableMetaParam: registry.aioBcAcCurrent
                            encodingColumnWidth: 70
                        }
                        Label {
                            text: "Inv Abs Current"
                        }
                        TableParamEdit {
                            xLabel: "Phase"
                            tableMetaParam: registry.aioBcInvAbsCurr
                            encodingColumnWidth: 70
                        }
                        Label {
                            text: "Inv Avg Current"
                        }
                        TableParamEdit {
                            xLabel: "Phase"
                            tableMetaParam: registry.aioBcInvAvgCurr
                            encodingColumnWidth: 70
                        }
                        Label {
                            text: "Trap Abs Current"
                        }
                        TableParamEdit {
                            xLabel: "Phase"
                            tableMetaParam: registry.aioBcTrapAbsCurr
                            encodingColumnWidth: 70
                        }
                    }

                    ColumnLayout {
                        Layout.alignment: Qt.AlignTop
                        ScalarParamEdit {
                            metaParam: registry.aioMagneticsTemp
                        }
                        ScalarParamEdit {
                            metaParam: registry.aioColdplateTemp
                        }
                        ScalarParamEdit {
                            metaParam: registry.aioIgbt1Temp
                        }
                        ScalarParamEdit {
                            metaParam: registry.aioIgbt2Temp
                        }
                        ScalarParamEdit {
                            metaParam: registry.aioVbatVolt
                        }
                        ScalarParamEdit {
                            metaParam: registry.aioVref2V5Volt
                        }
                    }
                    ColumnLayout {
                        Layout.alignment: Qt.AlignTop
                        Label {
                            text: "Bridge 1 Phase Error"
                        }

                        TableParamEdit {
                            xLabel: "Phase"
                            tableMetaParam: registry.dioBrdg1PhsError
                            encodingColumnWidth: 70
                        }
                        Label {
                            text: "Bridge 2 Phase Error"
                        }
                        TableParamEdit {
                            xLabel: "Phase"
                            tableMetaParam: registry.dioBrdg2PhsError
                            encodingColumnWidth: 70
                        }
                        ScalarParamEdit {
                            metaParam: registry.dioBrdg2Overtemp
                        }
                        ScalarParamSpinBox {
                            metaParam: registry.aioCurrZeroCalibStart
                        }
                        ScalarParamSpinBox {
                            metaParam: registry.dioCtc1Coil
                        }
                        ScalarParamSpinBox {
                            metaParam: registry.dioCtc2Coil
                        }
                    }
                    ColumnLayout {
                        Layout.alignment: Qt.AlignTop
                        ScalarParamSpinBox {
                            metaParam: registry.pwmBridge1Deadband
                        }
                        ScalarParamSpinBox {
                            metaParam: registry.pwmBridge1TopForce
                        }
                        ScalarParamSpinBox {
                            metaParam: registry.pwmBridge1BottomForce
                        }
                        Label {
                            text: "Bridge 1 Phase Zero"
                        }
                        TableParamEdit {
                            xLabel: "Phase"
                            tableMetaParam: registry.pwmBridge1PhaseZero
                            encodingColumnWidth: 70
                        }
                        ScalarParamSpinBox {
                            metaParam: registry.pwmBridge2Duty
                        }
                        ScalarParamSpinBox {
                            metaParam: registry.pwmBridge2TopForce
                        }
                        ScalarParamSpinBox {
                            metaParam: registry.pwmBridge2BottomForce
                        }
                    }
                }
            }
        }

        Tab {
            title: "BC"
            active: true
            AutoRefreshArea {
                base: this
                RowLayout {
                    Layout.alignment: Qt.AlignLeft
                    anchors.fill: parent
                    anchors.margins: 5
                    spacing: 5

                    ColumnLayout {
                        Layout.alignment: Qt.AlignTop
                        ScalarParamSpinBox {
                            metaParam: registry.bcNomLineFreq
                        }
                        ScalarParamSpinBox {
                            metaParam: registry.bcMaxLineLockFreqDelta
                        }
                        ScalarParamSpinBox {
                            metaParam: registry.bcSinePllPropCoeff
                        }
                        ScalarParamSpinBox {
                            metaParam: registry.bcSinePllIntCoeff
                        }
                        ScalarParamSpinBox {
                            metaParam: registry.bcSinePllDerivCoeff
                        }
                        ScalarParamSpinBox {
                            metaParam: registry.bcLinkVoltRegPropCoeff
                        }
                        ScalarParamSpinBox {
                            metaParam: registry.bcLinkVoltRegIntCoeff
                        }
                        ScalarParamSpinBox {
                            metaParam: registry.bcLinkVoltRegDerivCoeff
                        }
                        ScalarParamSpinBox {
                            metaParam: registry.bcRealCurrRegPropCoeff
                        }
                        ScalarParamSpinBox {
                            metaParam: registry.bcRealCurrRegIntCoeff
                        }
                        ScalarParamSpinBox {
                            metaParam: registry.bcRealCurrRegDerivCoeff
                        }
                        ScalarParamSpinBox {
                            metaParam: registry.bcReactiveCurrRegPropCoeff
                        }
                        ScalarParamSpinBox {
                            metaParam: registry.bcReactiveCurrRegIntCoeff
                        }
                        ScalarParamSpinBox {
                            metaParam: registry.bcReactiveCurrRegDerivCoeff
                        }
                    }
                    ColumnLayout {
                        Layout.alignment: Qt.AlignTop
                        ScalarParamSpinBox {
                            metaParam: registry.bcLineReactorInductance
                        }
                        ScalarParamSpinBox {
                            metaParam: registry.bcLineReactorResistance
                        }
                        ScalarParamSpinBox {
                            metaParam: registry.bcZeroPhaseAdj
                        }
                        ScalarParamSpinBox {
                            metaParam: registry.bcZeroPeakScale
                        }
                        ScalarParamSpinBox {
                            metaParam: registry.bcLineMaxDcCurr
                        }
                        ScalarParamSpinBox {
                            metaParam: registry.bcLineMaxAcCurr
                        }
                        ScalarParamSpinBox {
                            metaParam: registry.bcOutCurrRegPropCoeff
                        }
                        ScalarParamSpinBox {
                            metaParam: registry.bcOutCurrRegIntCoeff
                        }
                        ScalarParamSpinBox {
                            metaParam: registry.bcOutCurrRegDerivCoeff
                        }
                        ScalarParamSpinBox {
                            metaParam: registry.bcDcOutVoltMin
                        }
                        ScalarParamSpinBox {
                            metaParam: registry.bcDcOutVoltMax
                        }
                        ScalarParamSpinBox {
                            metaParam: registry.bcLineVoltMin
                        }
                        ScalarParamSpinBox {
                            metaParam: registry.bcLineVoltMax
                        }
                    }
                    ColumnLayout {
                        Layout.alignment: Qt.AlignTop
                        ScalarParamSpinBox {
                            metaParam: registry.bcInvDutyRampTime
                        }
                        ScalarParamSpinBox {
                            metaParam: registry.bcInvMaxDuty
                        }
                        ScalarParamSpinBox {
                            metaParam: registry.bcLinkVoltMin
                        }
                        ScalarParamSpinBox {
                            metaParam: registry.bcLinkVoltMax
                        }
                        ScalarParamSpinBox {
                            metaParam: registry.bcLinkVoltFastMax
                        }
                        ScalarParamSpinBox {
                            metaParam: registry.bcIgbt1TempMax
                        }
                        ScalarParamSpinBox {
                            metaParam: registry.bcIgbt2TempMax
                        }
                        ScalarParamSpinBox {
                            metaParam: registry.bcPhaseMeasureCorrD
                        }
                        ScalarParamSpinBox {
                            metaParam: registry.bcPhaseMeasureCorrQ
                        }
                    }
                    ColumnLayout {
                        Layout.alignment: Qt.AlignTop
                        Label {
                            text: "Line Filt DC Curr"
                        }
                        TableParamEdit {
                            xLabel: "Phase"
                            tableMetaParam: registry.bcLineFiltDcCurr
                            encodingColumnWidth: 70
                        }
                        Label {
                            text: "Line Filt AC Curr"
                        }
                        TableParamEdit {
                            xLabel: "Phase"
                            tableMetaParam: registry.bcLineFiltAcCurr
                            encodingColumnWidth: 70
                        }
                        Label {}
                        ScalarParamEdit {
                            metaParam: registry.bcSinePllStartCmd
                        }
                        ScalarParamEdit {
                            metaParam: registry.bcSinePllPhaseAdjCmd
                        }
                        ScalarParamEdit {
                            metaParam: registry.bcSinePllLocked
                        }
                        ScalarParamEdit {
                            metaParam: registry.bcSinePllFreq
                        }
                        Label {

                        }
                        ScalarParamSpinBox {
                            metaParam: registry.bcLineRealCurrentOpenLoopCmd
                        }
                        ScalarParamSpinBox {
                            metaParam: registry.bcLineReactiveCurrentOpenLoopCmd
                        }
                    }
                    ColumnLayout {
                        Layout.alignment: Qt.AlignTop
                        ScalarParamEdit {
                            metaParam: registry.bcFiltLineRealPower
                        }
                        ScalarParamEdit {
                            metaParam: registry.bcFiltLineReactivePower
                        }
                        ScalarParamEdit {
                            metaParam: registry.bcFiltLineRmsVolts
                        }
                        ScalarParamEdit {
                            metaParam: registry.bcFiltLineRmsAmps
                        }
                        ScalarParamSpinBox {
                            metaParam: registry.bcLineRealPowerCmd
                        }
                        ScalarParamSpinBox {
                            metaParam: registry.bcLineReactivePowerCmd
                        }
                        ScalarParamSpinBox {
                            metaParam: registry.bcOutCurrCmd
                        }
                        ScalarParamEdit {
                            metaParam: registry.bcFaultCode
                        }
                        ScalarParamEdit {
                            metaParam: registry.bcCtrlState
                        }
                        ScalarParamSpinBox {
                            metaParam: registry.canBcOutCurrCmd
                        }
                    }
                    ColumnLayout {
                        Layout.alignment: Qt.AlignTop
                        ScalarParamEdit {
                            metaParam: registry.aioBcDcOutCurr
                        }
                        ScalarParamEdit {
                            metaParam: registry.aioBcRectVoltNeg
                        }
                        ScalarParamEdit {
                            metaParam: registry.aioBcRectVoltPos
                        }
                        ScalarParamEdit {
                            metaParam: registry.aioBcDcOutVolt
                        }
                        ScalarParamEdit {
                            metaParam: registry.aioBcVehDcVolt
                        }
                        ScalarParamEdit {
                            metaParam: registry.aioIgbt1Temp
                        }
                        ScalarParamEdit {
                            metaParam: registry.aioIgbt2Temp
                        }
//                        ScalarParamEdit {
//                            metaParam: registry.aioVbatVolt
//                        }
//                        ScalarParamEdit {
//                            metaParam: registry.aioVref2V5Volt
//                        }
                        ScalarParamEdit {
                            metaParam: registry.dioCtc1Coil
                            name: "DC Neg/Precharge Ctc"
                        }
                        ScalarParamEdit {
                            metaParam: registry.dioCtc2Coil
                            name: "DC Pos Ctc"
                        }
                        ScalarParamEdit {
                            metaParam: registry.dioCtc3Coil
                            name: "AC Ctc"
                        }
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
                    anchors.margins: 5
                    spacing: 5
                    ColumnLayout {
                        Layout.alignment: Qt.AlignTop
                        ScalarParamSpinBox {
                            metaParam: registry.canDcdcOutVoltCmd
                        }
                        ScalarParamSpinBox {
                            metaParam: registry.canDcdcEnableCmd
                        }
                    }
                    ColumnLayout {
                        Layout.alignment: Qt.AlignTop
                        ScalarParamSpinBox {
                            metaParam: registry.canDcdcEnabled
                        }
                        ScalarParamSpinBox {
                            metaParam: registry.canDcdcOvertemp
                        }
                        ScalarParamSpinBox {
                            metaParam: registry.canDcdcElecFlt
                        }
                        ScalarParamSpinBox {
                            metaParam: registry.canDcdcOutVolt
                        }
                        ScalarParamSpinBox {
                            metaParam: registry.canDcdcOutCurr
                        }
                        ScalarParamSpinBox {
                            metaParam: registry.canDcdcOutPwr
                        }
                        ScalarParamSpinBox {
                            metaParam: registry.canDcdcInCurr
                        }
                        ScalarParamSpinBox {
                            metaParam: registry.canDcdcHeatsinkTemp
                        }
                    }
//                    ColumnLayout {
//                        Layout.alignment: Qt.AlignTop
//                        ScalarParamSpinBox {
//                            name: "XcpProgramRequested"
//                            metaParam: registry.canXcpProgramRequested
//                        }
//                        ScalarParamSpinBox {
//                            name: "Can1RxErrCount"
//                            metaParam: registry.canCan1RxErrCount
//                        }
//                        ScalarParamSpinBox {
//                            name: "Can1TxErrCount"
//                            metaParam: registry.canCan1TxErrCount
//                        }
//                        ScalarParamSpinBox {
//                            name: "Can2RxErrCount"
//                            metaParam: registry.canCan2RxErrCount
//                        }
//                        ScalarParamSpinBox {
//                            name: "Can2TxErrCount"
//                            metaParam: registry.canCan2TxErrCount
//                        }
//                    }
                }
            }
        }

//        Tab {
//            title: "Trac Inverter"
//            active: true
//            AutoRefreshArea {
//                base: this
//                RowLayout {
//                    Layout.alignment: Qt.AlignLeft
//                    anchors.fill: parent
//                    anchors.margins: 5
//                    spacing: 5
//                    ColumnLayout {
//                        Layout.alignment: Qt.AlignTop
//                        ScalarParamSpinBox {
//                            metaParam: registry.tracInvFwdMotoringTorqueLimit
//                        }
//                        ScalarParamSpinBox {
//                            metaParam: registry.tracInvRevMotoringTorqueLimit
//                        }
//                        ScalarParamSpinBox {
//                            metaParam: registry.tracInvFwdBrakingTorqueLimit
//                        }
//                        ScalarParamSpinBox {
//                            metaParam: registry.tracInvRevBrakingTorqueLimit
//                        }
//                        EncodingParamEdit {
//                            metaParam: registry.tracInvCmdMode
//                        }
//                        ScalarParamSpinBox {
//                            metaParam: registry.tracInvReverseDir
//                        }
//                    }
//                    ColumnLayout {
//                        Layout.alignment: Qt.AlignTop
//                        ScalarParamSpinBox {
//                            metaParam: registry.tracInvFreqRef
//                        }
//                        ScalarParamSpinBox {
//                            metaParam: registry.tracInvMotorSpeed
//                        }
//                        ScalarParamSpinBox {
//                            metaParam: registry.tracInvDcBusVolt
//                        }
//                        ScalarParamSpinBox {
//                            metaParam: registry.tracInvTorqueRef
//                        }
//                        ScalarParamSpinBox {
//                            metaParam: registry.tracInvAlarmCode
//                        }
//                        ScalarParamSpinBox {
//                            metaParam: registry.tracInvFaultCode
//                        }
//                    }
//                    ColumnLayout {
//                        Layout.alignment: Qt.AlignTop
//                        ScalarParamSpinBox {
//                            metaParam: registry.tracInvInputS1
//                        }
//                        ScalarParamSpinBox {
//                            metaParam: registry.tracInvInputS2
//                        }
//                        ScalarParamSpinBox {
//                            metaParam: registry.tracInvInputS3
//                        }
//                        ScalarParamSpinBox {
//                            metaParam: registry.tracInvInputS4
//                        }
//                        ScalarParamSpinBox {
//                            metaParam: registry.tracInvInputA1
//                        }
//                        ScalarParamSpinBox {
//                            metaParam: registry.tracInvInputA2
//                        }
//                    }
//                    ColumnLayout {
//                        Layout.alignment: Qt.AlignTop
//                        ScalarParamSpinBox {
//                            metaParam: registry.tracInvDuringRun
//                        }
//                        ScalarParamSpinBox {
//                            metaParam: registry.tracInvDuringReverse
//                        }
//                        ScalarParamSpinBox {
//                            metaParam: registry.tracInvDuringFaultReset
//                        }
//                        ScalarParamSpinBox {
//                            metaParam: registry.tracInvDriveReady
//                        }
//                        ScalarParamSpinBox {
//                            metaParam: registry.tracInvDuringAlarm
//                        }
//                        ScalarParamSpinBox {
//                            metaParam: registry.tracInvDuringFault
//                        }
//                    }
//                    ColumnLayout {
//                        Layout.alignment: Qt.AlignTop
//                        ScalarParamSpinBox {
//                            metaParam: registry.tracInvStatusUpdateStarted
//                        }
//                        ScalarParamSpinBox {
//                            metaParam: registry.tracInvStatusUpdated
//                        }
//                        ScalarParamSpinBox {
//                            metaParam: registry.tracInvWriteTorqueLimitsResult
//                        }
//                        ScalarParamSpinBox {
//                            metaParam: registry.tracInvWriteAcceptResult
//                        }
//                        ScalarParamSpinBox {
//                            metaParam: registry.tracInvReadStatusResult
//                        }
//                        ScalarParamSpinBox {
//                            metaParam: registry.tracInvReadFaultResult
//                        }
//                        ScalarParamSpinBox {
//                            metaParam: registry.tracInvTorqueLimitsSet
//                        }
//                    }
//                }
//            }
//        }

        Tab {
            title: "System"
            active: true
            AutoRefreshArea {
                base: this
                RowLayout {
                    Layout.alignment: Qt.AlignLeft
                    anchors.fill: parent
                    anchors.margins: 5
                    spacing: 5
                    ColumnLayout {
                        Layout.alignment: Qt.AlignTop
                        ScalarParamSpinBox {
                            metaParam: registry.sysCycleIdle
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
                        ScalarParamSpinBox {
                            name: "Heap Alloc Bytes"
                            metaParam: registry.sysHeapAllocBytes
                        }
                        ScalarParamSpinBox {
                            name: "Heap Avail Bytes"
                            metaParam: registry.sysHeapFreeBytes
                        }
                        ScalarParamSpinBox {
                            name: "Heap Free Count"
                            metaParam: registry.sysHeapNFrees
                        }
                        ScalarParamSpinBox {
                            name: "RTDB rows"
                            metaParam: registry.sysRtDbRows
                        }
                    }
                }
            }
        }

//        Tab {
//            title: "Event Log"
//            active: true

//            EventLogTab {
//                paramLayer: root.paramLayer
//                parameters: root.registry
//            }
//        }
    }
}
