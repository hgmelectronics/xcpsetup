import QtQuick 2.5

QtObject {
    readonly property double aioAiCts:                          4*0x00011000
    readonly property double aioAoCts:                          4*0x00011010
    readonly property double aioVbatEv01:                       4*0x00011020


    readonly property double canAuxBattCnvtCmdOn:               4*0x00021000
    readonly property double canAuxBattCnvtCmdVolt:             4*0x00021001
    readonly property double canCtlMaxMotoringTorque:           4*0x00021002
    readonly property double canCtlMaxRegenTorque:              4*0x00021003
    readonly property double canTracMotorSpeed:                 4*0x00022000
    readonly property double canLimpHomeCmdOn:                  4*0x00022001
    readonly property double canBattMaxDischCurrCmd:            4*0x00022002
    readonly property double canBattMaxChgCurrCmd:              4*0x00022003
    readonly property double canAuxBattCnvtState:               4*0x00022004
    readonly property double canAuxBattCnvtTemp:                4*0x00022005
    readonly property double canAuxBattCnvtInputVolt:           4*0x00022006
    readonly property double canAuxBattCnvtOutputVolt:          4*0x00022007
    readonly property double canAuxBattCnvtOutputCurr:          4*0x00022008
    readonly property double canExtChgCtcRqst:                  4*0x00022009
    readonly property double canAuxCtcRqrd:                     4*0x0002200A
    readonly property double canXcpProgramRequested:            4*0x0002200B
    readonly property double canCan1RxErrCount:                 4*0x0002200C
    readonly property double canCan1TxErrCount:                 4*0x0002200D
    readonly property double canCan2RxErrCount:                 4*0x0002200E
    readonly property double canCan2TxErrCount:                 4*0x0002200F
    readonly property double canCan1BufferFull:                 4*0x00022010
    readonly property double canCan2BufferFull:                 4*0x00022011


    readonly property double cbtmFaultDecayCyc:                 4*0x00030000
    readonly property double cbtmNonQuiescentTripCyc:           4*0x00030001
    readonly property double cbtmNonQuiescentDecayCyc:          4*0x00030002
    readonly property double cbtmBalanceOpenDeltaVThresh:       4*0x00030003
    readonly property double cbtmBalanceShortDeltaVThresh:      4*0x00030004
    readonly property double cbtmQuiescentDeltaVThresh:         4*0x00030005
    readonly property double cbtmIsospi1FirstBoard:             4*0x00030006
    readonly property double cbtmIsospi1LastBoard:              4*0x00030007
    readonly property double cbtmIsospi2FirstBoard:             4*0x00030008
    readonly property double cbtmIsospi2LastBoard:              4*0x00030009
    readonly property double cbtmCommFaultTripCyc:              4*0x0003000A
    readonly property double cbtmCommFaultClearCyc:             4*0x0003000B
    readonly property double cbtmCellVolt:                      4*0x00031000
    readonly property double cbtmTabTemp:                       4*0x00032000
    readonly property double cbtmDisch:                         4*0x00033000
    readonly property double cbtmStatus:                        4*0x00033100


    readonly property double ctcMaxSimulPickup:                 4*0x00040000
    readonly property double ctcLowVbatTripVolt:                4*0x00040001
    readonly property double ctcLowVbatOkVolt:                  4*0x00040002
    readonly property double ctcNFeedbackInput:                 4*0x00040010
    readonly property double ctcOn:                             4*0x00041010
    readonly property double ctcOk:                             4*0x00041020
    readonly property double ctcAClosed:                        4*0x00041030
    readonly property double ctcBClosed:                        4*0x00041040


    readonly property double dioDi:                             4*0x00051000
    readonly property double dioDo:                             4*0x00051100
    readonly property double dioDs:                             4*0x00051200


    readonly property double iaiDiffCts:                        4*0x00061000
    readonly property double iaiOk:                             4*0x00061010
    readonly property double iai4PosCts:                        4*0x00061020
    readonly property double iai4NegCts:                        4*0x00061021
    readonly property double iai4Pullup:                        4*0x00061030
    readonly property double iai4Pulldown:                      4*0x00061031


    readonly property double auxBattCnvtType:                   4*0x00070000
    readonly property double auxBattCnvtInputVoltMin:           4*0x00070001
    readonly property double auxBattCnvtStartTemp:              4*0x00070002
    readonly property double auxBattCnvtStopTemp:               4*0x00070003
    readonly property double auxBattFloatVolt:                  4*0x00070004
    readonly property double auxBattFloatVoltTempCoeff:         4*0x00070005
    readonly property double auxBattFloatVoltMin:               4*0x00070006
    readonly property double auxBattFloatVoltMax:               4*0x00070007
    readonly property double auxBattFloatVoltFailsafe:          4*0x00070008
    readonly property double auxBattRestartVoltHysteresis:      4*0x00070009
    readonly property double auxBattRestartVoltTime:            4*0x0007000A
    readonly property double auxBattRestartAlwaysTime:          4*0x0007000B
    readonly property double auxBattStopOutCurr:                4*0x0007000C
    readonly property double auxBattStopOutCurrTime:            4*0x0007000D
    readonly property double auxBattBattOkTemp:                 4*0x0007000E
    readonly property double auxBattBattWarmTemp:               4*0x0007000F
    readonly property double auxBattBattHotTemp:                4*0x00070010
    readonly property double auxBattBattTemp0AiChan:            4*0x00070011
    readonly property double auxBattBattTemp1AiChan:            4*0x00070012
    readonly property double auxBattBattTemp0Curve:             4*0x00070013
    readonly property double auxBattBattTemp1Curve:             4*0x00070014
    readonly property double auxBattRestartVoltTimeCount:       4*0x00070015
    readonly property double auxBattRestartAlwaysTimeCount:     4*0x00070016
    readonly property double auxBattStopOutCurrTimeCount:       4*0x00070017

    readonly property double auxBattBattTemp0:                  4*0x00071000
    readonly property double auxBattBattTemp1:                  4*0x00071001
    readonly property double auxBattStatus:                     4*0x00071002


    readonly property double motorFailsafeSpeed:                4*0x00080000
    readonly property double motorMinEffSpeed:                  4*0x00080001
    readonly property double motorRatedTorque:                  4*0x00080002
    readonly property double motorCurrRegPropCoeff:             4*0x00080003
    readonly property double motorCurrRegIntCoeff:              4*0x00080004
    readonly property double motorMaxTorqueRefErr:              4*0x00080005
    readonly property double motorMotoringIntegrator:           4*0x00081000
    readonly property double motorRegenIntegrator:              4*0x00081001
    readonly property double motorAdjMaxMotoringCurr:           4*0x00081002
    readonly property double motorAdjMaxRegenCurr:              4*0x00081003


    readonly property double packBoardsPerString:               4*0x00090000
    readonly property double packIaiFunc:                       4*0x00090001
    readonly property double packIai1Scale:                     4*0x00090002
    readonly property double packIai2Scale:                     4*0x00090003
    readonly property double packIai3Scale:                     4*0x00090004
    readonly property double packIai4Scale:                     4*0x00090005
    readonly property double packIai1Zero:                      4*0x00090006
    readonly property double packIai2Zero:                      4*0x00090007
    readonly property double packIai3Zero:                      4*0x00090008
    readonly property double packIai4Zero:                      4*0x00090009
    readonly property double packLimpHomeDischCurr:             4*0x0009000A
    readonly property double packLimpHomeChgCurr:               4*0x0009000B
    readonly property double packCellProtMarginCurr:            4*0x0009000C
    readonly property double packCurrRegFltTripCyc:             4*0x0009000D
    readonly property double packCurrRegFltDecayCyc:            4*0x0009000E
    readonly property double packGndFltDetectAvgCyc:            4*0x0009000F
    readonly property double packGndFltDetectPeriodCyc:         4*0x00090010
    readonly property double packGndFltTripConduct:             4*0x00090011
    readonly property double packGndFltTripCyc:                 4*0x00090012
    readonly property double packGndFltDecayCyc:                4*0x00090013
    readonly property double packTracCurrDecayCyc:              4*0x00090014
    readonly property double packChgCurrDecayCyc:               4*0x00090015
    readonly property double packMaxTracPrechgCyc:              4*0x00090016
    readonly property double packLowStringVoltTrip:             4*0x00090017
    readonly property double packLowStringVoltReset:            4*0x00090018
    readonly property double packBalBandVolt:                   4*0x00090019
    readonly property double packBalDiffVolt:                   4*0x0009001A
    readonly property double packBalSampleWaitCyc:              4*0x0009001B
    readonly property double packBalDischHighCyc:               4*0x0009001C
    readonly property double packBalDischAllCyc:                4*0x0009001D
    readonly property double packBalMinVolt:                    4*0x0009001E
    readonly property double packGndFltTripConductExtChg:       4*0x0009001F
    readonly property double packMaxCurr_DischCellTemp:         4*0x00090110
    readonly property double packMaxCurr_DischCurr:             4*0x00090120
    readonly property double packMaxCurr_ChgCellTemp:           4*0x00090130
    readonly property double packMaxCurr_ChgCurr:               4*0x00090140
    readonly property double packCellVLimit_MaxTemp:            4*0x00090150
    readonly property double packCellVLimit_MaxVolt:            4*0x00090160
    readonly property double packCellVLimit_MinTemp:            4*0x00090170
    readonly property double packCellVLimit_MinVolt:            4*0x00090180
    readonly property double packCellProtRes_Temp:              4*0x00090190
    readonly property double packCellProtRes_Res:               4*0x000901A0

    readonly property double packString1Volt:                   4*0x00091000
    readonly property double packString1Curr:                   4*0x00091001
    readonly property double packTracMtrCurr:                   4*0x00091002
    readonly property double packTracAuxCurr:                   4*0x00091003
    readonly property double packTracTotalCurr:                 4*0x00091004
    readonly property double packHybrCurr:                      4*0x00091005
    readonly property double packNonTracAuxCurr:                4*0x00091006
    readonly property double packString1MaxDischCurr:           4*0x00091007
    readonly property double packString1MaxChgCurr:             4*0x00091008
    readonly property double packTracMaxDischCurr:              4*0x00091009
    readonly property double packTracMaxChgCurr:                4*0x0009100A
    readonly property double packCellProtMaxVolt:               4*0x0009100B
    readonly property double packCellProtMinVolt:               4*0x0009100C
    readonly property double packCellProtRes:                   4*0x0009100D
    readonly property double packCellProtVoltageMaxDischCurr:   4*0x0009100E
    readonly property double packCellProtVoltageMaxChgCurr:     4*0x0009100F
    readonly property double packCellProtThermalMaxDischCurr:   4*0x00091010
    readonly property double packCellProtThermalMaxChgCurr:     4*0x00091011
    readonly property double packStatus:                        4*0x00091012
    readonly property double packMaxCellVolt:                   4*0x00091013
    readonly property double packMeanCellVolt:                  4*0x00091014
    readonly property double packMinCellVolt:                   4*0x00091015
    readonly property double packMaxCellTemp:                   4*0x00091016
    readonly property double packMeanCellTemp:                  4*0x00091017
    readonly property double packMinCellTemp:                   4*0x00091018
    readonly property double packGndFltDetectPulldownPosVolt:   4*0x00091019
    readonly property double packGndFltDetectPulldownNegVolt:   4*0x0009101A
    readonly property double packGndFltDetectPullupPosVolt:     4*0x0009101B
    readonly property double packGndFltDetectPullupNegVolt:     4*0x0009101C
    readonly property double packGndFltCenterVolt:              4*0x0009101D
    readonly property double packGndFltFrac:                    4*0x0009101E
    readonly property double packGndFltConduct:                 4*0x0009101F
    readonly property double packCtcCtrlStateCode:              4*0x00091020
    readonly property double packBalancerStateCode:             4*0x00091021


    readonly property double sysCycleIdleTicks:                 4*0x000A1000
    readonly property double sysCycleDrvAioInTicks:             4*0x000A1001
    readonly property double sysCycleDrvAioOutTicks:            4*0x000A1002
    readonly property double sysCycleDrvCanInTicks:             4*0x000A1003
    readonly property double sysCycleDrvCanOutTicks:            4*0x000A1004
    readonly property double sysCycleDrvCbtmInTicks:            4*0x000A1005
    readonly property double sysCycleDrvCbtmOutTicks:           4*0x000A1006
    readonly property double sysCycleDrvCtcInTicks:             4*0x000A1007
    readonly property double sysCycleDrvCtcOutTicks:            4*0x000A1008
    readonly property double sysCycleDrvDioInTicks:             4*0x000A1009
    readonly property double sysCycleDrvDioOutTicks:            4*0x000A100A
    readonly property double sysCycleDrvIaiInTicks:             4*0x000A100B
    readonly property double sysCycleDrvIaiOutTicks:            4*0x000A100C
    readonly property double sysCycleCtlAuxBattTicks:           4*0x000A100D
    readonly property double sysCycleCtlLampTicks:              4*0x000A100E
    readonly property double sysCycleCtlMotorTicks:             4*0x000A100F
    readonly property double sysCycleCtlPackTicks:              4*0x000A1010
    readonly property double sysFlags:                          4*0x000A1011
    readonly property double sysHeapAllocBytes:                 4*0x000A1012
    readonly property double sysHeapFreeBytes:                  4*0x000A1013
    readonly property double sysHeapNFrees:                     4*0x000A1014
    readonly property double sysRtDbRows:                       4*0x000A1015

    readonly property double eventBeginSerial:                  0x10000000
    readonly property double eventEndSerial:                    0x10000008
    readonly property double eventClearToSerial:                0x10000010
    readonly property double eventViewSerial:                   0x10000018
    readonly property double eventViewKey:                      0x10000020
    readonly property double eventViewFreezeSize:               0x10000038
    readonly property double eventViewFreeze:                   0x10000040
}
