import QtQuick 2.5
import com.hgmelectronics.setuptools.xcp 1.0
import com.hgmelectronics.setuptools 1.0
import com.hgmelectronics.setuptools.ui 1.0

QtObject {
    id: parameters
    property ParamRegistry registry;
    property ParamId paramId: ParamId {}
    property Slots slots: Slots {}

    property int cbtmCellsPerBoard: 8
    property int cbtmTabsPerBoard: 9
    property int cbtmMaxBoards: 32
    property SlotArrayModel cbtmCellAxisModel: SlotArrayModel {
        slot: slots.raw32
        count: cbtmCellsPerBoard * cbtmMaxBoards
    }
    property SlotArrayModel cbtmTabAxisModel: SlotArrayModel {
        slot: slots.raw32
        count: cbtmTabsPerBoard * cbtmMaxBoards
    }
    property SlotArrayModel cbtmBoardAxisModel: SlotArrayModel {
        slot: slots.raw32
        count: cbtmMaxBoards
    }
    property SlotArrayModel ctcAxisModel: SlotArrayModel {
        slot: slots.raw32
        count: 4
    }
    property SlotArrayModel aiAxisModel: SlotArrayModel {
        slot: slots.raw32
        count: 4
    }
    property SlotArrayModel diAxisModel: SlotArrayModel {
        slot: slots.raw32
        count: 4
    }
    property SlotArrayModel doAxisModel: SlotArrayModel {
        slot: slots.raw32
        count: 7
    }
    property SlotArrayModel iaiAxisModel: SlotArrayModel {
        slot: slots.raw32
        count: 4
    }

    property ScalarParam aioVbatEv01: registry.addScalarParam(MemoryRange.S32, paramId.aioVbatEv01, false, false, slots.voltage1)
    property TableParam aioAiCts: TableParam {
        x: aiAxisModel
        value: registry.addArrayParam(MemoryRange.S32, paramId.aioAiCts, aiAxisModel.count, false, false, slots.stAiVolts)
    }

    readonly property ScalarParam canAuxBattCnvtCmdOn: registry.addScalarParam(MemoryRange.S32, paramId.canAuxBattCnvtCmdOn, false, false, slots.bool01)
    readonly property ScalarParam canAuxBattCnvtCmdVolt: registry.addScalarParam(MemoryRange.S32, paramId.canAuxBattCnvtCmdVolt, false, false, slots.voltage1)
    readonly property ScalarParam canCtlMaxMotoringTorque: registry.addScalarParam(MemoryRange.S32, paramId.canCtlMaxMotoringTorque, false, false, slots.saePc06Ext)
    readonly property ScalarParam canCtlMaxRegenTorque: registry.addScalarParam(MemoryRange.S32, paramId.canCtlMaxRegenTorque, false, false, slots.saePc06Ext)
    readonly property ScalarParam canTracMotorSpeed: registry.addScalarParam(MemoryRange.S32, paramId.canTracMotorSpeed, false, false, slots.saeVr01)
    readonly property ScalarParam canLimpHomeCmdOn: registry.addScalarParam(MemoryRange.S32, paramId.canLimpHomeCmdOn, false, false, slots.bool01)
    readonly property ScalarParam canBattMaxDischCurrCmd: registry.addScalarParam(MemoryRange.S32, paramId.canBattMaxDischCurrCmd, false, false, slots.current1)
    readonly property ScalarParam canBattMaxChgCurrCmd: registry.addScalarParam(MemoryRange.S32, paramId.canBattMaxChgCurrCmd, false, false, slots.current1)
    readonly property ScalarParam canAuxBattCnvtState: registry.addScalarParam(MemoryRange.S32, paramId.canAuxBattCnvtState, false, false, slots.auxBattCnvtState)
    readonly property ScalarParam canAuxBattCnvtTemp: registry.addScalarParam(MemoryRange.S32, paramId.canAuxBattCnvtTemp, false, false, slots.saeTp02)
    readonly property ScalarParam canAuxBattCnvtInputVolt: registry.addScalarParam(MemoryRange.S32, paramId.canAuxBattCnvtInputVolt, false, false, slots.voltage1)
    readonly property ScalarParam canAuxBattCnvtOutputVolt: registry.addScalarParam(MemoryRange.S32, paramId.canAuxBattCnvtOutputVolt, false, false, slots.voltage1)
    readonly property ScalarParam canAuxBattCnvtOutputCurr: registry.addScalarParam(MemoryRange.S32, paramId.canAuxBattCnvtOutputCurr, false, false, slots.current1)
    readonly property ScalarParam canExtChgCtcRqst: registry.addScalarParam(MemoryRange.S32, paramId.canExtChgCtcRqst, false, false, slots.bool01)
    readonly property ScalarParam canAuxCtcRqrd: registry.addScalarParam(MemoryRange.S32, paramId.canAuxCtcRqrd, false, false, slots.bool01)
    readonly property ScalarParam canXcpProgramRequested: registry.addScalarParam(MemoryRange.S32, paramId.canXcpProgramRequested, false, false, slots.bool01)
    readonly property ScalarParam canCan1RxErrCount: registry.addScalarParam(MemoryRange.S32, paramId.canCan1RxErrCount, false, false, slots.raw32)
    readonly property ScalarParam canCan1TxErrCount: registry.addScalarParam(MemoryRange.S32, paramId.canCan1TxErrCount, false, false, slots.raw32)
    readonly property ScalarParam canCan2RxErrCount: registry.addScalarParam(MemoryRange.S32, paramId.canCan2RxErrCount, false, false, slots.raw32)
    readonly property ScalarParam canCan2TxErrCount: registry.addScalarParam(MemoryRange.S32, paramId.canCan2TxErrCount, false, false, slots.raw32)

    readonly property ScalarParam cbtmFaultDecayCyc: registry.addScalarParam(MemoryRange.S32, paramId.cbtmFaultDecayCyc, true, true, slots.timeCycle)
    readonly property ScalarParam cbtmNonQuiescentTripCyc: registry.addScalarParam(MemoryRange.S32, paramId.cbtmNonQuiescentTripCyc, true, true, slots.timeCycle)
    readonly property ScalarParam cbtmNonQuiescentDecayCyc: registry.addScalarParam(MemoryRange.S32, paramId.cbtmNonQuiescentDecayCyc, true, true, slots.timeCycle)
    readonly property ScalarParam cbtmBalanceOpenDeltaVThresh: registry.addScalarParam(MemoryRange.S32, paramId.cbtmBalanceOpenDeltaVThresh, true, true, slots.ltcCellvExt)
    readonly property ScalarParam cbtmBalanceShortDeltaVThresh: registry.addScalarParam(MemoryRange.S32, paramId.cbtmBalanceShortDeltaVThresh, true, true, slots.ltcCellvExt)
    readonly property ScalarParam cbtmQuiescentDeltaVThresh: registry.addScalarParam(MemoryRange.S32, paramId.cbtmQuiescentDeltaVThresh, true, true, slots.ltcCellvExt)
    readonly property ScalarParam cbtmIsospi1FirstBoard: registry.addScalarParam(MemoryRange.S32, paramId.cbtmIsospi1FirstBoard, true, true, slots.raw32)
    readonly property ScalarParam cbtmIsospi1LastBoard: registry.addScalarParam(MemoryRange.S32, paramId.cbtmIsospi1LastBoard, true, true, slots.raw32)
    readonly property ScalarParam cbtmIsospi2FirstBoard: registry.addScalarParam(MemoryRange.S32, paramId.cbtmIsospi2FirstBoard, true, true, slots.raw32)
    readonly property ScalarParam cbtmIsospi2LastBoard: registry.addScalarParam(MemoryRange.S32, paramId.cbtmIsospi2LastBoard, true, true, slots.raw32)

    property TableParam cbtmCellVolt: TableParam {
        x: SlotArrayModel {
            slot: slots.raw32
            count: cbtmCellVolt.value.count
        }
        value: registry.addVarArrayParam(MemoryRange.S32, paramId.cbtmCellVolt, cbtmCellsPerBoard, cbtmCellAxisModel.count, false, false, slots.ltcCellv)
    }

    property TableParam cbtmTabTemp: TableParam {
        x: SlotArrayModel {
            slot: slots.raw32
            count: cbtmTabTemp.value.count
        }
        value: registry.addVarArrayParam(MemoryRange.S32, paramId.cbtmTabTemp, cbtmTabsPerBoard, cbtmTabAxisModel.count, false, false, slots.saeTp02)
    }

    property TableParam cbtmDisch: TableParam {
        x: SlotArrayModel {
            slot: slots.raw32
            count: cbtmDisch.value.count
        }
        value: registry.addVarArrayParam(MemoryRange.S32, paramId.cbtmDisch, 1, cbtmBoardAxisModel.count, true, false, slots.raw32hex)
    }

    property TableParam cbtmStatus: TableParam {
        x: SlotArrayModel {
            slot: slots.raw32
            count: cbtmStatus.value.count
        }
        value: registry.addVarArrayParam(MemoryRange.S32, paramId.cbtmStatus, 1, cbtmBoardAxisModel.count, false, false, slots.raw32hex)
    }

    readonly property ScalarParam ctcMaxSimulPickup: registry.addScalarParam(MemoryRange.S32, paramId.ctcMaxSimulPickup, true, true, slots.raw32)


    property TableParam ctcHasBInput: TableParam {
        x: ctcAxisModel
        value: registry.addArrayParam(MemoryRange.S32, paramId.ctcHasBInput, ctcAxisModel.count, false, false, slots.bool01)
    }

    property TableParam ctcOn: TableParam {
        x: ctcAxisModel
        value: registry.addArrayParam(MemoryRange.S32, paramId.ctcOn, ctcAxisModel.count, true, false, slots.bool01)
    }
    property TableParam ctcOk: TableParam {
        x: ctcAxisModel
        value: registry.addArrayParam(MemoryRange.S32, paramId.ctcOk, ctcAxisModel.count, false, false, slots.bool01)
    }
    property TableParam ctcAClosed: TableParam {
        x: ctcAxisModel
        value: registry.addArrayParam(MemoryRange.S32, paramId.ctcAClosed, ctcAxisModel.count, false, false, slots.bool01)
    }
    property TableParam ctcBClosed: TableParam {
        x: ctcAxisModel
        value: registry.addArrayParam(MemoryRange.S32, paramId.ctcBClosed, ctcAxisModel.count, false, false, slots.bool01)
    }

    property TableParam dioDi: TableParam {
        x: diAxisModel
        value: registry.addArrayParam(MemoryRange.S32, paramId.dioDi, diAxisModel.count, false, false, slots.bool01)
    }

    property TableParam dioDo: TableParam {
        x: doAxisModel
        value: registry.addArrayParam(MemoryRange.S32, paramId.dioDo, doAxisModel.count, true, false, slots.bool01)
    }

    property TableParam iaiDiffCts: TableParam {
        x: iaiAxisModel
        value: registry.addArrayParam(MemoryRange.S32, paramId.iaiDiffCts, iaiAxisModel.count, false, false, slots.iaiMvScale)
    }

    property TableParam iaiOk: TableParam {
        x: iaiAxisModel
        value: registry.addArrayParam(MemoryRange.S32, paramId.iaiOk, iaiAxisModel.count, false, false, slots.bool01)
    }

    readonly property ScalarParam iai4PosCts: registry.addScalarParam(MemoryRange.S32, paramId.iai4PosCts, false, false, slots.iaiMvScale)
    readonly property ScalarParam iai4NegCts: registry.addScalarParam(MemoryRange.S32, paramId.iai4NegCts, false, false, slots.iaiMvScale)
    readonly property ScalarParam iai4Pullup: registry.addScalarParam(MemoryRange.S32, paramId.iai4Pullup, true, false, slots.bool01)
    readonly property ScalarParam iai4Pulldown: registry.addScalarParam(MemoryRange.S32, paramId.iai4Pulldown, true, false, slots.bool01)

    readonly property ScalarParam auxBattCnvtType: registry.addScalarParam(MemoryRange.S32, paramId.auxBattCnvtType, true, true, slots.auxBattCnvtType)
    readonly property ScalarParam auxBattCnvtInputVoltMin: registry.addScalarParam(MemoryRange.S32, paramId.auxBattCnvtInputVoltMin, true, true, slots.voltage1)
    readonly property ScalarParam auxBattCnvtStartTemp: registry.addScalarParam(MemoryRange.S32, paramId.auxBattCnvtStartTemp, true, true, slots.saeTp02)
    readonly property ScalarParam auxBattCnvtStopTemp: registry.addScalarParam(MemoryRange.S32, paramId.auxBattCnvtStopTemp, true, true, slots.saeTp02)
    readonly property ScalarParam auxBattFloatVolt: registry.addScalarParam(MemoryRange.S32, paramId.auxBattFloatVolt, true, true, slots.voltage1)
    readonly property ScalarParam auxBattFloatVoltTempCoeff: registry.addScalarParam(MemoryRange.S32, paramId.auxBattFloatVoltTempCoeff, true, true, slots.auxBattFloatCoeff)
    readonly property ScalarParam auxBattFloatVoltMin: registry.addScalarParam(MemoryRange.S32, paramId.auxBattFloatVoltMin, true, true, slots.voltage1)
    readonly property ScalarParam auxBattFloatVoltMax: registry.addScalarParam(MemoryRange.S32, paramId.auxBattFloatVoltMax, true, true, slots.voltage1)
    readonly property ScalarParam auxBattFloatVoltFailsafe: registry.addScalarParam(MemoryRange.S32, paramId.auxBattFloatVoltFailsafe, true, true, slots.voltage1)
    readonly property ScalarParam auxBattRestartVoltHysteresis: registry.addScalarParam(MemoryRange.S32, paramId.auxBattRestartVoltHysteresis, true, true, slots.voltage1)
    readonly property ScalarParam auxBattRestartVoltTime: registry.addScalarParam(MemoryRange.S32, paramId.auxBattRestartVoltTime, true, true, slots.timeCycle)
    readonly property ScalarParam auxBattRestartAlwaysTime: registry.addScalarParam(MemoryRange.S32, paramId.auxBattRestartAlwaysTime, true, true, slots.timeCycle)
    readonly property ScalarParam auxBattStopOutCurr: registry.addScalarParam(MemoryRange.S32, paramId.auxBattStopOutCurr, true, true, slots.current1)
    readonly property ScalarParam auxBattStopOutCurrTime: registry.addScalarParam(MemoryRange.S32, paramId.auxBattStopOutCurrTime, true, true, slots.timeCycle)
    readonly property ScalarParam auxBattBattOkTemp: registry.addScalarParam(MemoryRange.S32, paramId.auxBattBattOkTemp, true, true, slots.saeTp02)
    readonly property ScalarParam auxBattBattWarmTemp: registry.addScalarParam(MemoryRange.S32, paramId.auxBattBattWarmTemp, true, true, slots.saeTp02)
    readonly property ScalarParam auxBattBattHotTemp: registry.addScalarParam(MemoryRange.S32, paramId.auxBattBattHotTemp, true, true, slots.saeTp02)
    readonly property ScalarParam auxBattBattTemp0AiChan: registry.addScalarParam(MemoryRange.S32, paramId.auxBattBattTemp0AiChan, true, true, slots.raw32)
    readonly property ScalarParam auxBattBattTemp1AiChan: registry.addScalarParam(MemoryRange.S32, paramId.auxBattBattTemp1AiChan, true, true, slots.raw32)
    readonly property ScalarParam auxBattBattTemp0Curve: registry.addScalarParam(MemoryRange.S32, paramId.auxBattBattTemp0Curve, true, true, slots.thermistorCurve)
    readonly property ScalarParam auxBattBattTemp1Curve: registry.addScalarParam(MemoryRange.S32, paramId.auxBattBattTemp1Curve, true, true, slots.thermistorCurve)
    readonly property ScalarParam auxBattRestartVoltTimeCount: registry.addScalarParam(MemoryRange.S32, paramId.auxBattRestartVoltTimeCount, true, true, slots.timeCycle)
    readonly property ScalarParam auxBattRestartAlwaysTimeCount: registry.addScalarParam(MemoryRange.S32, paramId.auxBattRestartAlwaysTimeCount, true, true, slots.timeCycle)
    readonly property ScalarParam auxBattStopOutCurrTimeCount: registry.addScalarParam(MemoryRange.S32, paramId.auxBattStopOutCurrTimeCount, true, true, slots.timeCycle)

    readonly property ScalarParam auxBattBattTemp0: registry.addScalarParam(MemoryRange.S32, paramId.auxBattBattTemp0, false, false, slots.saeTp02)
    readonly property ScalarParam auxBattBattTemp1: registry.addScalarParam(MemoryRange.S32, paramId.auxBattBattTemp1, false, false, slots.saeTp02)
    readonly property ScalarParam auxBattStatus: registry.addScalarParam(MemoryRange.S32, paramId.auxBattStatus, false, false, slots.raw32hex)

    readonly property ScalarParam motorFailsafeSpeed: registry.addScalarParam(MemoryRange.S32, paramId.motorFailsafeSpeed, true, true, slots.saeVr01)
    readonly property ScalarParam motorMinEffSpeed: registry.addScalarParam(MemoryRange.S32, paramId.motorMinEffSpeed, true, true, slots.saeVr01)
    readonly property ScalarParam motorRatedTorque: registry.addScalarParam(MemoryRange.S32, paramId.motorRatedTorque, true, true, slots.torque1)
    readonly property ScalarParam motorCurrRegPropCoeff: registry.addScalarParam(MemoryRange.S32, paramId.motorCurrRegPropCoeff, true, true, slots.motorCurrRegPropCoeff)
    readonly property ScalarParam motorCurrRegIntCoeff: registry.addScalarParam(MemoryRange.S32, paramId.motorCurrRegIntCoeff, true, true, slots.motorCurrRegIntCoeff)
    readonly property ScalarParam motorMaxTorqueRefErr: registry.addScalarParam(MemoryRange.S32, paramId.motorMaxTorqueRefErr, true, true, slots.saePc06Ext)
    readonly property ScalarParam motorMotoringIntegrator: registry.addScalarParam(MemoryRange.S32, paramId.motorMotoringIntegrator, true, true, slots.current1)
    readonly property ScalarParam motorRegenIntegrator: registry.addScalarParam(MemoryRange.S32, paramId.motorRegenIntegrator, true, true, slots.current1)
    readonly property ScalarParam motorAdjMaxMotoringCurr: registry.addScalarParam(MemoryRange.S32, paramId.motorAdjMaxMotoringCurr, true, true, slots.current1)
    readonly property ScalarParam motorAdjMaxRegenCurr: registry.addScalarParam(MemoryRange.S32, paramId.motorAdjMaxRegenCurr, true, true, slots.current1)

    readonly property ScalarParam packBoardsPerString: registry.addScalarParam(MemoryRange.S32, paramId.packBoardsPerString, false, false, slots.raw32)
    readonly property ScalarParam packIaiFunc: registry.addScalarParam(MemoryRange.S32, paramId.packIaiFunc, true, true, slots.iaiFunc)
    readonly property ScalarParam packIai1Scale: registry.addScalarParam(MemoryRange.S32, paramId.packIai1Scale, true, true, slots.iaiScaleShunt)
    readonly property ScalarParam packIai2Scale: registry.addScalarParam(MemoryRange.S32, paramId.packIai2Scale, true, true, slots.iaiScaleShunt)
    readonly property ScalarParam packIai3Scale: registry.addScalarParam(MemoryRange.S32, paramId.packIai3Scale, true, true, slots.iaiScaleShunt)
    readonly property ScalarParam packIai4Scale: registry.addScalarParam(MemoryRange.S32, paramId.packIai4Scale, true, true, slots.voltage1)
    readonly property ScalarParam packIai1Zero: registry.addScalarParam(MemoryRange.S32, paramId.packIai1Zero, true, true, slots.raw32)
    readonly property ScalarParam packIai2Zero: registry.addScalarParam(MemoryRange.S32, paramId.packIai2Zero, true, true, slots.raw32)
    readonly property ScalarParam packIai3Zero: registry.addScalarParam(MemoryRange.S32, paramId.packIai3Zero, true, true, slots.raw32)
    readonly property ScalarParam packIai4Zero: registry.addScalarParam(MemoryRange.S32, paramId.packIai4Zero, true, true, slots.raw32)
    readonly property ScalarParam packLimpHomeDischCurr: registry.addScalarParam(MemoryRange.S32, paramId.packLimpHomeDischCurr, true, true, slots.current1)
    readonly property ScalarParam packLimpHomeChgCurr: registry.addScalarParam(MemoryRange.S32, paramId.packLimpHomeChgCurr, true, true, slots.current1)
    readonly property ScalarParam packCellProtMarginCurr: registry.addScalarParam(MemoryRange.S32, paramId.packCellProtMarginCurr, true, true, slots.current1)
    readonly property ScalarParam packCurrRegFltTripCyc: registry.addScalarParam(MemoryRange.S32, paramId.packCurrRegFltTripCyc, true, true, slots.timeCycle)
    readonly property ScalarParam packCurrRegFltDecayCyc: registry.addScalarParam(MemoryRange.S32, paramId.packCurrRegFltDecayCyc, true, true, slots.timeCycle)
    readonly property ScalarParam packGndFltDetectAvgCyc: registry.addScalarParam(MemoryRange.S32, paramId.packGndFltDetectAvgCyc, true, true, slots.timeCycle)
    readonly property ScalarParam packGndFltDetectPeriodCyc: registry.addScalarParam(MemoryRange.S32, paramId.packGndFltDetectPeriodCyc, true, true, slots.timeCycle)
    readonly property ScalarParam packGndFltTripConduct: registry.addScalarParam(MemoryRange.S32, paramId.packGndFltTripConduct, true, true, slots.conductance1)
    readonly property ScalarParam packGndFltTripCyc: registry.addScalarParam(MemoryRange.S32, paramId.packGndFltTripCyc, true, true, slots.raw32)
    readonly property ScalarParam packGndFltDecayCyc: registry.addScalarParam(MemoryRange.S32, paramId.packGndFltDecayCyc, true, true, slots.raw32)
    readonly property ScalarParam packTracCurrDecayCyc: registry.addScalarParam(MemoryRange.S32, paramId.packTracCurrDecayCyc, true, true, slots.timeCycle)
    readonly property ScalarParam packChgCurrDecayCyc: registry.addScalarParam(MemoryRange.S32, paramId.packChgCurrDecayCyc, true, true, slots.timeCycle)
    readonly property ScalarParam packMaxTracPrechgCyc: registry.addScalarParam(MemoryRange.S32, paramId.packMaxTracPrechgCyc, true, true, slots.timeCycle)
    readonly property ScalarParam packLowStringVoltTrip: registry.addScalarParam(MemoryRange.S32, paramId.packLowStringVoltTrip, true, true, slots.voltage1)
    readonly property ScalarParam packLowStringVoltReset: registry.addScalarParam(MemoryRange.S32, paramId.packLowStringVoltReset, true, true, slots.voltage1)
    readonly property ScalarParam packBalBandVolt: registry.addScalarParam(MemoryRange.S32, paramId.packBalBandVolt, true, true, slots.ltcCellv)
    readonly property ScalarParam packBalDiffVolt: registry.addScalarParam(MemoryRange.S32, paramId.packBalDiffVolt, true, true, slots.ltcCellv)
    readonly property ScalarParam packBalSampleWaitCyc: registry.addScalarParam(MemoryRange.S32, paramId.packBalSampleWaitCyc, true, true, slots.timeCycle)
    readonly property ScalarParam packBalDischHighCyc: registry.addScalarParam(MemoryRange.S32, paramId.packBalDischHighCyc, true, true, slots.timeCycle)
    readonly property ScalarParam packBalDischAllCyc: registry.addScalarParam(MemoryRange.S32, paramId.packBalDischAllCyc, true, true, slots.timeCycle)

    property TableParam packMaxCurrDisch: TableParam {
        x: registry.addArrayParam(MemoryRange.S32, paramId.packMaxCurr_DischCellTemp, 6, true, true, slots.saeTp02)
        value: registry.addArrayParam(MemoryRange.S32, paramId.packMaxCurr_DischCurr, 6, true, true, slots.current1)
    }
    property TableParam packMaxCurrChg: TableParam {
        x: registry.addArrayParam(MemoryRange.S32, paramId.packMaxCurr_ChgCellTemp, 6, true, true, slots.saeTp02)
        value: registry.addArrayParam(MemoryRange.S32, paramId.packMaxCurr_ChgCurr, 6, true, true, slots.current1)
    }
    property TableParam packCellVLimitMax: TableParam {
        x: registry.addArrayParam(MemoryRange.S32, paramId.packCellVLimit_MaxTemp, 4, true, true, slots.saeTp02)
        value: registry.addArrayParam(MemoryRange.S32, paramId.packCellVLimit_MaxVolt, 4, true, true, slots.ltcCellv)
    }
    property TableParam packCellVLimitMin: TableParam {
        x: registry.addArrayParam(MemoryRange.S32, paramId.packCellVLimit_MinTemp, 4, true, true, slots.saeTp02)
        value: registry.addArrayParam(MemoryRange.S32, paramId.packCellVLimit_MinVolt, 4, true, true, slots.ltcCellv)
    }
    property TableParam packCellProtResTable: TableParam {
        x: registry.addArrayParam(MemoryRange.S32, paramId.packCellProtRes_Temp, 4, true, true, slots.saeTp02)
        value: registry.addArrayParam(MemoryRange.S32, paramId.packCellProtRes_Res, 4, true, true, slots.cellProtRes)
    }

    readonly property ScalarParam packString1Volt: registry.addScalarParam(MemoryRange.S32, paramId.packString1Volt, false, false, slots.voltage1)
    readonly property ScalarParam packString1Curr: registry.addScalarParam(MemoryRange.S32, paramId.packString1Curr, false, false, slots.current1)
    readonly property ScalarParam packTracMtrCurr: registry.addScalarParam(MemoryRange.S32, paramId.packTracMtrCurr, false, false, slots.current1)
    readonly property ScalarParam packTracAuxCurr: registry.addScalarParam(MemoryRange.S32, paramId.packTracAuxCurr, false, false, slots.current1)
    readonly property ScalarParam packTracTotalCurr: registry.addScalarParam(MemoryRange.S32, paramId.packTracTotalCurr, false, false, slots.current1)
    readonly property ScalarParam packHybrCurr: registry.addScalarParam(MemoryRange.S32, paramId.packHybrCurr, false, false, slots.current1)
    readonly property ScalarParam packNonTracAuxCurr: registry.addScalarParam(MemoryRange.S32, paramId.packNonTracAuxCurr, false, false, slots.current1)
    readonly property ScalarParam packString1MaxDischCurr: registry.addScalarParam(MemoryRange.S32, paramId.packString1MaxDischCurr, false, false, slots.current1)
    readonly property ScalarParam packString1MaxChgCurr: registry.addScalarParam(MemoryRange.S32, paramId.packString1MaxChgCurr, false, false, slots.current1)
    readonly property ScalarParam packTracMaxDischCurr: registry.addScalarParam(MemoryRange.S32, paramId.packTracMaxDischCurr, false, false, slots.current1)
    readonly property ScalarParam packTracMaxChgCurr: registry.addScalarParam(MemoryRange.S32, paramId.packTracMaxChgCurr, false, false, slots.current1)
    readonly property ScalarParam packCellProtMaxVolt: registry.addScalarParam(MemoryRange.S32, paramId.packCellProtMaxVolt, false, false, slots.ltcCellv)
    readonly property ScalarParam packCellProtMinVolt: registry.addScalarParam(MemoryRange.S32, paramId.packCellProtMinVolt, false, false, slots.ltcCellv)
    readonly property ScalarParam packCellProtRes: registry.addScalarParam(MemoryRange.S32, paramId.packCellProtRes, false, false, slots.cellProtRes)
    readonly property ScalarParam packCellProtVoltageMaxDischCurr: registry.addScalarParam(MemoryRange.S32, paramId.packCellProtVoltageMaxDischCurr, false, false, slots.current1)
    readonly property ScalarParam packCellProtVoltageMaxChgCurr: registry.addScalarParam(MemoryRange.S32, paramId.packCellProtVoltageMaxChgCurr, false, false, slots.current1)
    readonly property ScalarParam packCellProtThermalMaxDischCurr: registry.addScalarParam(MemoryRange.S32, paramId.packCellProtThermalMaxDischCurr, false, false, slots.current1)
    readonly property ScalarParam packCellProtThermalMaxChgCurr: registry.addScalarParam(MemoryRange.S32, paramId.packCellProtThermalMaxChgCurr, false, false, slots.current1)
    readonly property ScalarParam packStatus: registry.addScalarParam(MemoryRange.S32, paramId.packStatus, false, false, slots.raw32hex)
    readonly property ScalarParam packMaxCellVolt: registry.addScalarParam(MemoryRange.S32, paramId.packMaxCellVolt, false, false, slots.ltcCellv)
    readonly property ScalarParam packMeanCellVolt: registry.addScalarParam(MemoryRange.S32, paramId.packMeanCellVolt, false, false, slots.ltcCellv)
    readonly property ScalarParam packMinCellVolt: registry.addScalarParam(MemoryRange.S32, paramId.packMinCellVolt, false, false, slots.ltcCellv)
    readonly property ScalarParam packMaxCellTemp: registry.addScalarParam(MemoryRange.S32, paramId.packMaxCellTemp, false, false, slots.saeTp02)
    readonly property ScalarParam packMeanCellTemp: registry.addScalarParam(MemoryRange.S32, paramId.packMeanCellTemp, false, false, slots.saeTp02)
    readonly property ScalarParam packMinCellTemp: registry.addScalarParam(MemoryRange.S32, paramId.packMinCellTemp, false, false, slots.saeTp02)
    readonly property ScalarParam packGndFltDetectPulldownPosVolt: registry.addScalarParam(MemoryRange.S32, paramId.packGndFltDetectPulldownPosVolt, false, false, slots.voltage1)
    readonly property ScalarParam packGndFltDetectPulldownNegVolt: registry.addScalarParam(MemoryRange.S32, paramId.packGndFltDetectPulldownNegVolt, false, false, slots.voltage1)
    readonly property ScalarParam packGndFltDetectPullupPosVolt: registry.addScalarParam(MemoryRange.S32, paramId.packGndFltDetectPullupPosVolt, false, false, slots.voltage1)
    readonly property ScalarParam packGndFltDetectPullupNegVolt: registry.addScalarParam(MemoryRange.S32, paramId.packGndFltDetectPullupNegVolt, false, false, slots.voltage1)
    readonly property ScalarParam packGndFltCenterVolt: registry.addScalarParam(MemoryRange.S32, paramId.packGndFltCenterVolt, false, false, slots.voltage1)
    readonly property ScalarParam packGndFltFrac: registry.addScalarParam(MemoryRange.S32, paramId.packGndFltFrac, false, false, slots.saePc01)
    readonly property ScalarParam packGndFltConduct: registry.addScalarParam(MemoryRange.S32, paramId.packGndFltConduct, false, false, slots.conductance1)
    readonly property ScalarParam packCtcCtrlStateCode: registry.addScalarParam(MemoryRange.S32, paramId.packCtcCtrlStateCode, false, false, slots.ctcCtrlState)
    readonly property ScalarParam packBalancerStateCode: registry.addScalarParam(MemoryRange.S32, paramId.packBalancerStateCode, false, false, slots.balancerState)

    readonly property ScalarParam sysCycleIdleTicks: registry.addScalarParam(MemoryRange.S32, paramId.sysCycleIdleTicks, false, false, slots.timeSysTick)
    readonly property ScalarParam sysCycleDrvCbtmInTicks: registry.addScalarParam(MemoryRange.S32, paramId.sysCycleDrvCbtmInTicks, false, false, slots.timeSysTick)
    readonly property ScalarParam sysCycleDrvIaiInTicks: registry.addScalarParam(MemoryRange.S32, paramId.sysCycleDrvIaiInTicks, false, false, slots.timeSysTick)
    readonly property ScalarParam sysCycleCtlAuxBattTicks: registry.addScalarParam(MemoryRange.S32, paramId.sysCycleCtlAuxBattTicks, false, false, slots.timeSysTick)
    readonly property ScalarParam sysCycleCtlLampTicks: registry.addScalarParam(MemoryRange.S32, paramId.sysCycleCtlLampTicks, false, false, slots.timeSysTick)
    readonly property ScalarParam sysCycleCtlMotorTicks: registry.addScalarParam(MemoryRange.S32, paramId.sysCycleCtlMotorTicks, false, false, slots.timeSysTick)
    readonly property ScalarParam sysCycleCtlPackTicks: registry.addScalarParam(MemoryRange.S32, paramId.sysCycleCtlPackTicks, false, false, slots.timeSysTick)
}
