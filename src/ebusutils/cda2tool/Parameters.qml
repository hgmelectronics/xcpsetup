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

    property ScalarMetaParam aioVbatEv01: ScalarMetaParam {
        param: registry.addScalarParam(MemoryRange.S32, paramId.aioVbatEv01, false, false, slots.voltage1)
        name: qsTr("")
    }

    property TableParam aioAiCts: TableParam {
        x: aiAxisModel
        value: registry.addArrayParam(MemoryRange.S32, paramId.aioAiCts, aiAxisModel.count, false, false, slots.stAiVolts)
    }

    property ScalarMetaParam canAuxBattCnvtCmdOn: ScalarMetaParam {
        param: registry.addScalarParam(MemoryRange.S32, paramId.canAuxBattCnvtCmdOn, false, false, slots.bool01)
        name: qsTr("")
    }
    property ScalarMetaParam canAuxBattCnvtCmdVolt: ScalarMetaParam {
        param: registry.addScalarParam(MemoryRange.S32, paramId.canAuxBattCnvtCmdVolt, false, false, slots.voltage1)
        name: qsTr("")
    }
    property ScalarMetaParam canCtlMaxMotoringTorque: ScalarMetaParam {
        param: registry.addScalarParam(MemoryRange.S32, paramId.canCtlMaxMotoringTorque, false, false, slots.saePc06Ext)
        name: qsTr("")
    }
    property ScalarMetaParam canCtlMaxRegenTorque: ScalarMetaParam {
        param: registry.addScalarParam(MemoryRange.S32, paramId.canCtlMaxRegenTorque, false, false, slots.saePc06Ext)
        name: qsTr("")
    }
    property ScalarMetaParam canTracMotorSpeed: ScalarMetaParam {
        param: registry.addScalarParam(MemoryRange.S32, paramId.canTracMotorSpeed, false, false, slots.saeVr01)
        name: qsTr("")
    }
    property ScalarMetaParam canLimpHomeCmdOn: ScalarMetaParam {
        param: registry.addScalarParam(MemoryRange.S32, paramId.canLimpHomeCmdOn, false, false, slots.bool01)
        name: qsTr("")
    }
    property ScalarMetaParam canBattMaxDischCurrCmd: ScalarMetaParam {
        param: registry.addScalarParam(MemoryRange.S32, paramId.canBattMaxDischCurrCmd, false, false, slots.current1)
        name: qsTr("")
    }
    property ScalarMetaParam canBattMaxChgCurrCmd: ScalarMetaParam {
        param: registry.addScalarParam(MemoryRange.S32, paramId.canBattMaxChgCurrCmd, false, false, slots.current1)
        name: qsTr("")
    }
    property ScalarMetaParam canAuxBattCnvtState: ScalarMetaParam {
        param: registry.addScalarParam(MemoryRange.S32, paramId.canAuxBattCnvtState, false, false, slots.auxBattCnvtState)
        name: qsTr("")
    }
    property ScalarMetaParam canAuxBattCnvtTemp: ScalarMetaParam {
        param: registry.addScalarParam(MemoryRange.S32, paramId.canAuxBattCnvtTemp, false, false, slots.saeTp02)
        name: qsTr("")
    }
    property ScalarMetaParam canAuxBattCnvtInputVolt: ScalarMetaParam {
        param: registry.addScalarParam(MemoryRange.S32, paramId.canAuxBattCnvtInputVolt, false, false, slots.voltage1)
        name: qsTr("")
    }
    property ScalarMetaParam canAuxBattCnvtOutputVolt: ScalarMetaParam {
        param: registry.addScalarParam(MemoryRange.S32, paramId.canAuxBattCnvtOutputVolt, false, false, slots.voltage1)
        name: qsTr("")
    }
    property ScalarMetaParam canAuxBattCnvtOutputCurr: ScalarMetaParam {
        param: registry.addScalarParam(MemoryRange.S32, paramId.canAuxBattCnvtOutputCurr, false, false, slots.current1)
        name: qsTr("")
    }
    property ScalarMetaParam canExtChgCtcRqst: ScalarMetaParam {
        param: registry.addScalarParam(MemoryRange.S32, paramId.canExtChgCtcRqst, false, false, slots.bool01)
        name: qsTr("")
    }
    property ScalarMetaParam canAuxCtcRqrd: ScalarMetaParam {
        param: registry.addScalarParam(MemoryRange.S32, paramId.canAuxCtcRqrd, false, false, slots.bool01)
        name: qsTr("")
    }
    property ScalarMetaParam canXcpProgramRequested: ScalarMetaParam {
        param: registry.addScalarParam(MemoryRange.S32, paramId.canXcpProgramRequested, false, false, slots.bool01)
        name: qsTr("")
    }
    property ScalarMetaParam canCan1RxErrCount: ScalarMetaParam {
        param: registry.addScalarParam(MemoryRange.S32, paramId.canCan1RxErrCount, false, false, slots.raw32)
        name: qsTr("")
    }
    property ScalarMetaParam canCan1TxErrCount: ScalarMetaParam {
        param: registry.addScalarParam(MemoryRange.S32, paramId.canCan1TxErrCount, false, false, slots.raw32)
        name: qsTr("")
    }
    property ScalarMetaParam canCan2RxErrCount: ScalarMetaParam {
        param: registry.addScalarParam(MemoryRange.S32, paramId.canCan2RxErrCount, false, false, slots.raw32)
        name: qsTr("")
    }
    property ScalarMetaParam canCan2TxErrCount: ScalarMetaParam {
        param: registry.addScalarParam(MemoryRange.S32, paramId.canCan2TxErrCount, false, false, slots.raw32)
        name: qsTr("")
    }
    property ScalarMetaParam canCan1BufferFull: ScalarMetaParam {
        param: registry.addScalarParam(MemoryRange.S32, paramId.canCan1BufferFull, false, false, slots.raw32)
        name: qsTr("")
    }
    property ScalarMetaParam canCan2BufferFull: ScalarMetaParam {
        param: registry.addScalarParam(MemoryRange.S32, paramId.canCan2BufferFull, false, false, slots.raw32)
        name: qsTr("")
    }
    property ScalarMetaParam cbtmFaultDecayCyc: ScalarMetaParam {
        param: registry.addScalarParam(MemoryRange.S32, paramId.cbtmFaultDecayCyc, true, true, slots.timeCycle)
        name: qsTr("")
    }
    property ScalarMetaParam cbtmNonQuiescentTripCyc: ScalarMetaParam {
        param: registry.addScalarParam(MemoryRange.S32, paramId.cbtmNonQuiescentTripCyc, true, true, slots.timeCycle)
        name: qsTr("")
    }
    property ScalarMetaParam cbtmNonQuiescentDecayCyc: ScalarMetaParam {
        param: registry.addScalarParam(MemoryRange.S32, paramId.cbtmNonQuiescentDecayCyc, true, true, slots.timeCycle)
        name: qsTr("")
    }
    property ScalarMetaParam cbtmBalanceOpenDeltaVThresh: ScalarMetaParam {
        param: registry.addScalarParam(MemoryRange.S32, paramId.cbtmBalanceOpenDeltaVThresh, true, true, slots.ltcCellvExt)
        name: qsTr("")
    }
    property ScalarMetaParam cbtmBalanceShortDeltaVThresh: ScalarMetaParam {
        param: registry.addScalarParam(MemoryRange.S32, paramId.cbtmBalanceShortDeltaVThresh, true, true, slots.ltcCellvExt)
        name: qsTr("")
    }
    property ScalarMetaParam cbtmQuiescentDeltaVThresh: ScalarMetaParam {
        param: registry.addScalarParam(MemoryRange.S32, paramId.cbtmQuiescentDeltaVThresh, true, true, slots.ltcCellvExt)
        name: qsTr("")
    }
    property ScalarMetaParam cbtmIsospi1FirstBoard: ScalarMetaParam {
        param: registry.addScalarParam(MemoryRange.S32, paramId.cbtmIsospi1FirstBoard, true, true, slots.raw32)
        name: qsTr("")
    }
    property ScalarMetaParam cbtmIsospi1LastBoard: ScalarMetaParam {
        param: registry.addScalarParam(MemoryRange.S32, paramId.cbtmIsospi1LastBoard, true, true, slots.raw32)
        name: qsTr("")
    }
    property ScalarMetaParam cbtmIsospi2FirstBoard: ScalarMetaParam {
        param: registry.addScalarParam(MemoryRange.S32, paramId.cbtmIsospi2FirstBoard, true, true, slots.raw32)
        name: qsTr("")
    }
    property ScalarMetaParam cbtmIsospi2LastBoard: ScalarMetaParam {
        param: registry.addScalarParam(MemoryRange.S32, paramId.cbtmIsospi2LastBoard, true, true, slots.raw32)
        name: qsTr("")
    }
    property ScalarMetaParam cbtmCommFaultTripCyc: ScalarMetaParam {
        param: registry.addScalarParam(MemoryRange.S32, paramId.cbtmCommFaultTripCyc, true, true, slots.raw32)
        name: qsTr("")
    }
    property ScalarMetaParam cbtmCommFaultClearCyc: ScalarMetaParam {
        param: registry.addScalarParam(MemoryRange.S32, paramId.cbtmCommFaultClearCyc, true, true, slots.raw32)
        name: qsTr("")
    }

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

    property ScalarMetaParam ctcMaxSimulPickup: ScalarMetaParam {
        param: registry.addScalarParam(MemoryRange.S32, paramId.ctcMaxSimulPickup, true, true, slots.raw32)
        name: qsTr("")
    }


    property TableParam ctcNFeedbackInput: TableParam {
        x: ctcAxisModel
        value: registry.addArrayParam(MemoryRange.S32, paramId.ctcNFeedbackInput, ctcAxisModel.count, true, true, slots.ctcFeedback)
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

    property ScalarMetaParam iai4PosCts: ScalarMetaParam {
        param: registry.addScalarParam(MemoryRange.S32, paramId.iai4PosCts, false, false, slots.iaiMvScale)
        name: qsTr("")
    }
    property ScalarMetaParam iai4NegCts: ScalarMetaParam {
        param: registry.addScalarParam(MemoryRange.S32, paramId.iai4NegCts, false, false, slots.iaiMvScale)
        name: qsTr("")
    }
    property ScalarMetaParam iai4Pullup: ScalarMetaParam {
        param: registry.addScalarParam(MemoryRange.S32, paramId.iai4Pullup, true, false, slots.bool01)
        name: qsTr("")
    }
    property ScalarMetaParam iai4Pulldown: ScalarMetaParam {
        param: registry.addScalarParam(MemoryRange.S32, paramId.iai4Pulldown, true, false, slots.bool01)
        name: qsTr("")
    }

    property ScalarMetaParam auxBattCnvtType: ScalarMetaParam {
        param: registry.addScalarParam(MemoryRange.S32, paramId.auxBattCnvtType, true, true, slots.auxBattCnvtType)
        name: qsTr("")
    }
    property ScalarMetaParam auxBattCnvtInputVoltMin: ScalarMetaParam {
        param: registry.addScalarParam(MemoryRange.S32, paramId.auxBattCnvtInputVoltMin, true, true, slots.voltage1)
        name: qsTr("")
    }
    property ScalarMetaParam auxBattCnvtStartTemp: ScalarMetaParam {
        param: registry.addScalarParam(MemoryRange.S32, paramId.auxBattCnvtStartTemp, true, true, slots.saeTp02)
        name: qsTr("")
    }
    property ScalarMetaParam auxBattCnvtStopTemp: ScalarMetaParam {
        param: registry.addScalarParam(MemoryRange.S32, paramId.auxBattCnvtStopTemp, true, true, slots.saeTp02)
        name: qsTr("")
    }
    property ScalarMetaParam auxBattFloatVolt: ScalarMetaParam {
        param: registry.addScalarParam(MemoryRange.S32, paramId.auxBattFloatVolt, true, true, slots.voltage1)
        name: qsTr("")
    }
    property ScalarMetaParam auxBattFloatVoltTempCoeff: ScalarMetaParam {
        param: registry.addScalarParam(MemoryRange.S32, paramId.auxBattFloatVoltTempCoeff, true, true, slots.auxBattFloatCoeff)
        name: qsTr("")
    }
    property ScalarMetaParam auxBattFloatVoltMin: ScalarMetaParam {
        param: registry.addScalarParam(MemoryRange.S32, paramId.auxBattFloatVoltMin, true, true, slots.voltage1)
        name: qsTr("")
    }
    property ScalarMetaParam auxBattFloatVoltMax: ScalarMetaParam {
        param: registry.addScalarParam(MemoryRange.S32, paramId.auxBattFloatVoltMax, true, true, slots.voltage1)
        name: qsTr("")
    }
    property ScalarMetaParam auxBattFloatVoltFailsafe: ScalarMetaParam {
        param: registry.addScalarParam(MemoryRange.S32, paramId.auxBattFloatVoltFailsafe, true, true, slots.voltage1)
        name: qsTr("")
    }
    property ScalarMetaParam auxBattRestartVoltHysteresis: ScalarMetaParam {
        param: registry.addScalarParam(MemoryRange.S32, paramId.auxBattRestartVoltHysteresis, true, true, slots.voltage1)
        name: qsTr("")
    }
    property ScalarMetaParam auxBattRestartVoltTime: ScalarMetaParam {
        param: registry.addScalarParam(MemoryRange.S32, paramId.auxBattRestartVoltTime, true, true, slots.timeCycle)
        name: qsTr("")
    }
    property ScalarMetaParam auxBattRestartAlwaysTime: ScalarMetaParam {
        param: registry.addScalarParam(MemoryRange.S32, paramId.auxBattRestartAlwaysTime, true, true, slots.timeCycle)
        name: qsTr("")
    }
    property ScalarMetaParam auxBattStopOutCurr: ScalarMetaParam {
        param: registry.addScalarParam(MemoryRange.S32, paramId.auxBattStopOutCurr, true, true, slots.current1)
        name: qsTr("")
    }
    property ScalarMetaParam auxBattStopOutCurrTime: ScalarMetaParam {
        param: registry.addScalarParam(MemoryRange.S32, paramId.auxBattStopOutCurrTime, true, true, slots.timeCycle)
        name: qsTr("")
    }
    property ScalarMetaParam auxBattBattOkTemp: ScalarMetaParam {
        param: registry.addScalarParam(MemoryRange.S32, paramId.auxBattBattOkTemp, true, true, slots.saeTp02)
        name: qsTr("")
    }
    property ScalarMetaParam auxBattBattWarmTemp: ScalarMetaParam {
        param: registry.addScalarParam(MemoryRange.S32, paramId.auxBattBattWarmTemp, true, true, slots.saeTp02)
        name: qsTr("")
    }
    property ScalarMetaParam auxBattBattHotTemp: ScalarMetaParam {
        param: registry.addScalarParam(MemoryRange.S32, paramId.auxBattBattHotTemp, true, true, slots.saeTp02)
        name: qsTr("")
    }
    property ScalarMetaParam auxBattBattTemp0AiChan: ScalarMetaParam {
        param: registry.addScalarParam(MemoryRange.S32, paramId.auxBattBattTemp0AiChan, true, true, slots.raw32)
        name: qsTr("")
    }
    property ScalarMetaParam auxBattBattTemp1AiChan: ScalarMetaParam {
        param: registry.addScalarParam(MemoryRange.S32, paramId.auxBattBattTemp1AiChan, true, true, slots.raw32)
        name: qsTr("")
    }
    property ScalarMetaParam auxBattBattTemp0Curve: ScalarMetaParam {
        param: registry.addScalarParam(MemoryRange.S32, paramId.auxBattBattTemp0Curve, true, true, slots.thermistorCurve)
        name: qsTr("")
    }
    property ScalarMetaParam auxBattBattTemp1Curve: ScalarMetaParam {
        param: registry.addScalarParam(MemoryRange.S32, paramId.auxBattBattTemp1Curve, true, true, slots.thermistorCurve)
        name: qsTr("")
    }
    property ScalarMetaParam auxBattRestartVoltTimeCount: ScalarMetaParam {
        param: registry.addScalarParam(MemoryRange.S32, paramId.auxBattRestartVoltTimeCount, true, true, slots.timeCycle)
        name: qsTr("")
    }
    property ScalarMetaParam auxBattRestartAlwaysTimeCount: ScalarMetaParam {
        param: registry.addScalarParam(MemoryRange.S32, paramId.auxBattRestartAlwaysTimeCount, true, true, slots.timeCycle)
        name: qsTr("")
    }
    property ScalarMetaParam auxBattStopOutCurrTimeCount: ScalarMetaParam {
        param: registry.addScalarParam(MemoryRange.S32, paramId.auxBattStopOutCurrTimeCount, true, true, slots.timeCycle)
        name: qsTr("")
    }

    property ScalarMetaParam auxBattBattTemp0: ScalarMetaParam {
        param: registry.addScalarParam(MemoryRange.S32, paramId.auxBattBattTemp0, false, false, slots.saeTp02)
        name: qsTr("")
    }
    property ScalarMetaParam auxBattBattTemp1: ScalarMetaParam {
        param: registry.addScalarParam(MemoryRange.S32, paramId.auxBattBattTemp1, false, false, slots.saeTp02)
        name: qsTr("")
    }
    property ScalarMetaParam auxBattStatus: ScalarMetaParam {
        param: registry.addScalarParam(MemoryRange.S32, paramId.auxBattStatus, false, false, slots.raw32hex)
        name: qsTr("")
    }

    property ScalarMetaParam motorFailsafeSpeed: ScalarMetaParam {
        param: registry.addScalarParam(MemoryRange.S32, paramId.motorFailsafeSpeed, true, true, slots.saeVr01)
        name: qsTr("")
    }
    property ScalarMetaParam motorMinEffSpeed: ScalarMetaParam {
        param: registry.addScalarParam(MemoryRange.S32, paramId.motorMinEffSpeed, true, true, slots.saeVr01)
        name: qsTr("")
    }
    property ScalarMetaParam motorRatedTorque: ScalarMetaParam {
        param: registry.addScalarParam(MemoryRange.S32, paramId.motorRatedTorque, true, true, slots.torque1)
        name: qsTr("")
    }
    property ScalarMetaParam motorCurrRegPropCoeff: ScalarMetaParam {
        param: registry.addScalarParam(MemoryRange.S32, paramId.motorCurrRegPropCoeff, true, true, slots.motorCurrRegPropCoeff)
        name: qsTr("")
    }
    property ScalarMetaParam motorCurrRegIntCoeff: ScalarMetaParam {
        param: registry.addScalarParam(MemoryRange.S32, paramId.motorCurrRegIntCoeff, true, true, slots.motorCurrRegIntCoeff)
        name: qsTr("")
    }
    property ScalarMetaParam motorMaxTorqueRefErr: ScalarMetaParam {
        param: registry.addScalarParam(MemoryRange.S32, paramId.motorMaxTorqueRefErr, true, true, slots.saePc06Ext)
        name: qsTr("")
    }
    property ScalarMetaParam motorMotoringIntegrator: ScalarMetaParam {
        param: registry.addScalarParam(MemoryRange.S32, paramId.motorMotoringIntegrator, false, false, slots.current1)
        name: qsTr("")
    }
    property ScalarMetaParam motorRegenIntegrator: ScalarMetaParam {
        param: registry.addScalarParam(MemoryRange.S32, paramId.motorRegenIntegrator, false, false, slots.current1)
        name: qsTr("")
    }
    property ScalarMetaParam motorAdjMaxMotoringCurr: ScalarMetaParam {
        param: registry.addScalarParam(MemoryRange.S32, paramId.motorAdjMaxMotoringCurr, false, false, slots.current1)
        name: qsTr("")
    }
    property ScalarMetaParam motorAdjMaxRegenCurr: ScalarMetaParam {
        param: registry.addScalarParam(MemoryRange.S32, paramId.motorAdjMaxRegenCurr, false, false, slots.current1)
        name: qsTr("")
    }

    property ScalarMetaParam packBoardsPerString: ScalarMetaParam {
        param: registry.addScalarParam(MemoryRange.S32, paramId.packBoardsPerString, false, false, slots.raw32)
        name: qsTr("")
    }
    property ScalarMetaParam packIaiFunc: ScalarMetaParam {
        param: registry.addScalarParam(MemoryRange.S32, paramId.packIaiFunc, true, true, slots.iaiFunc)
        name: qsTr("")
    }
    property ScalarMetaParam packIai1Scale: ScalarMetaParam {
        param: registry.addScalarParam(MemoryRange.S32, paramId.packIai1Scale, true, true, slots.iaiScaleShunt)
        name: qsTr("")
    }
    property ScalarMetaParam packIai2Scale: ScalarMetaParam {
        param: registry.addScalarParam(MemoryRange.S32, paramId.packIai2Scale, true, true, slots.iaiScaleShunt)
        name: qsTr("")
    }
    property ScalarMetaParam packIai3Scale: ScalarMetaParam {
        param: registry.addScalarParam(MemoryRange.S32, paramId.packIai3Scale, true, true, slots.iaiScaleShunt)
        name: qsTr("")
    }
    property ScalarMetaParam packIai4Scale: ScalarMetaParam {
        param: registry.addScalarParam(MemoryRange.S32, paramId.packIai4Scale, true, true, slots.voltage1)
        name: qsTr("")
    }
    property ScalarMetaParam packIai1Zero: ScalarMetaParam {
        param: registry.addScalarParam(MemoryRange.S32, paramId.packIai1Zero, true, true, slots.raw32)
        name: qsTr("")
    }
    property ScalarMetaParam packIai2Zero: ScalarMetaParam {
        param: registry.addScalarParam(MemoryRange.S32, paramId.packIai2Zero, true, true, slots.raw32)
        name: qsTr("")
    }
    property ScalarMetaParam packIai3Zero: ScalarMetaParam {
        param: registry.addScalarParam(MemoryRange.S32, paramId.packIai3Zero, true, true, slots.raw32)
        name: qsTr("")
    }
    property ScalarMetaParam packIai4Zero: ScalarMetaParam {
        param: registry.addScalarParam(MemoryRange.S32, paramId.packIai4Zero, true, true, slots.raw32)
        name: qsTr("")
    }
    property ScalarMetaParam packLimpHomeDischCurr: ScalarMetaParam {
        param: registry.addScalarParam(MemoryRange.S32, paramId.packLimpHomeDischCurr, true, true, slots.current1)
        name: qsTr("")
    }
    property ScalarMetaParam packLimpHomeChgCurr: ScalarMetaParam {
        param: registry.addScalarParam(MemoryRange.S32, paramId.packLimpHomeChgCurr, true, true, slots.current1)
        name: qsTr("")
    }
    property ScalarMetaParam packCellProtMarginCurr: ScalarMetaParam {
        param: registry.addScalarParam(MemoryRange.S32, paramId.packCellProtMarginCurr, true, true, slots.current1)
        name: qsTr("")
    }
    property ScalarMetaParam packCurrRegFltTripCyc: ScalarMetaParam {
        param: registry.addScalarParam(MemoryRange.S32, paramId.packCurrRegFltTripCyc, true, true, slots.timeCycle)
        name: qsTr("")
    }
    property ScalarMetaParam packCurrRegFltDecayCyc: ScalarMetaParam {
        param: registry.addScalarParam(MemoryRange.S32, paramId.packCurrRegFltDecayCyc, true, true, slots.timeCycle)
        name: qsTr("")
    }
    property ScalarMetaParam packGndFltDetectAvgCyc: ScalarMetaParam {
        param: registry.addScalarParam(MemoryRange.S32, paramId.packGndFltDetectAvgCyc, true, true, slots.timeCycle)
        name: qsTr("")
    }
    property ScalarMetaParam packGndFltDetectPeriodCyc: ScalarMetaParam {
        param: registry.addScalarParam(MemoryRange.S32, paramId.packGndFltDetectPeriodCyc, true, true, slots.timeCycle)
        name: qsTr("")
    }
    property ScalarMetaParam packGndFltTripConduct: ScalarMetaParam {
        param: registry.addScalarParam(MemoryRange.S32, paramId.packGndFltTripConduct, true, true, slots.conductance1)
        name: qsTr("")
    }
    property ScalarMetaParam packGndFltTripConductExtChg: ScalarMetaParam {
        param: registry.addScalarParam(MemoryRange.S32, paramId.packGndFltTripConductExtChg, true, true, slots.conductance1)
        name: qsTr("")
    }
    property ScalarMetaParam packGndFltTripCyc: ScalarMetaParam {
        param: registry.addScalarParam(MemoryRange.S32, paramId.packGndFltTripCyc, true, true, slots.raw32)
        name: qsTr("")
    }
    property ScalarMetaParam packGndFltDecayCyc: ScalarMetaParam {
        param: registry.addScalarParam(MemoryRange.S32, paramId.packGndFltDecayCyc, true, true, slots.raw32)
        name: qsTr("")
    }
    property ScalarMetaParam packTracCurrDecayCyc: ScalarMetaParam {
        param: registry.addScalarParam(MemoryRange.S32, paramId.packTracCurrDecayCyc, true, true, slots.timeCycle)
        name: qsTr("")
    }
    property ScalarMetaParam packChgCurrDecayCyc: ScalarMetaParam {
        param: registry.addScalarParam(MemoryRange.S32, paramId.packChgCurrDecayCyc, true, true, slots.timeCycle)
        name: qsTr("")
    }
    property ScalarMetaParam packMaxTracPrechgCyc: ScalarMetaParam {
        param: registry.addScalarParam(MemoryRange.S32, paramId.packMaxTracPrechgCyc, true, true, slots.timeCycle)
        name: qsTr("")
    }
    property ScalarMetaParam packLowStringVoltTrip: ScalarMetaParam {
        param: registry.addScalarParam(MemoryRange.S32, paramId.packLowStringVoltTrip, true, true, slots.voltage1)
        name: qsTr("")
    }
    property ScalarMetaParam packLowStringVoltReset: ScalarMetaParam {
        param: registry.addScalarParam(MemoryRange.S32, paramId.packLowStringVoltReset, true, true, slots.voltage1)
        name: qsTr("")
    }
    property ScalarMetaParam packBalBandVolt: ScalarMetaParam {
        param: registry.addScalarParam(MemoryRange.S32, paramId.packBalBandVolt, true, true, slots.ltcCellv)
        name: qsTr("")
    }
    property ScalarMetaParam packBalDiffVolt: ScalarMetaParam {
        param: registry.addScalarParam(MemoryRange.S32, paramId.packBalDiffVolt, true, true, slots.ltcCellv)
        name: qsTr("")
    }
    property ScalarMetaParam packBalMinVolt: ScalarMetaParam {
        param: registry.addScalarParam(MemoryRange.S32, paramId.packBalMinVolt, true, true, slots.ltcCellv)
        name: qsTr("")
    }
    property ScalarMetaParam packBalSampleWaitCyc: ScalarMetaParam {
        param: registry.addScalarParam(MemoryRange.S32, paramId.packBalSampleWaitCyc, true, true, slots.timeCycle)
        name: qsTr("")
    }
    property ScalarMetaParam packBalDischHighCyc: ScalarMetaParam {
        param: registry.addScalarParam(MemoryRange.S32, paramId.packBalDischHighCyc, true, true, slots.timeCycle)
        name: qsTr("")
    }
    property ScalarMetaParam packBalDischAllCyc: ScalarMetaParam {
        param: registry.addScalarParam(MemoryRange.S32, paramId.packBalDischAllCyc, true, true, slots.timeCycle)
        name: qsTr("")
    }

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

    property ScalarMetaParam packString1Volt: ScalarMetaParam {
        param: registry.addScalarParam(MemoryRange.S32, paramId.packString1Volt, false, false, slots.voltage1)
        name: qsTr("")
    }
    property ScalarMetaParam packString1Curr: ScalarMetaParam {
        param: registry.addScalarParam(MemoryRange.S32, paramId.packString1Curr, false, false, slots.current1)
        name: qsTr("")
    }
    property ScalarMetaParam packTracMtrCurr: ScalarMetaParam {
        param: registry.addScalarParam(MemoryRange.S32, paramId.packTracMtrCurr, false, false, slots.current1)
        name: qsTr("")
    }
    property ScalarMetaParam packTracAuxCurr: ScalarMetaParam {
        param: registry.addScalarParam(MemoryRange.S32, paramId.packTracAuxCurr, false, false, slots.current1)
        name: qsTr("")
    }
    property ScalarMetaParam packTracTotalCurr: ScalarMetaParam {
        param: registry.addScalarParam(MemoryRange.S32, paramId.packTracTotalCurr, false, false, slots.current1)
        name: qsTr("")
    }
    property ScalarMetaParam packHybrCurr: ScalarMetaParam {
        param: registry.addScalarParam(MemoryRange.S32, paramId.packHybrCurr, false, false, slots.current1)
        name: qsTr("")
    }
    property ScalarMetaParam packNonTracAuxCurr: ScalarMetaParam {
        param: registry.addScalarParam(MemoryRange.S32, paramId.packNonTracAuxCurr, false, false, slots.current1)
        name: qsTr("")
    }
    property ScalarMetaParam packString1MaxDischCurr: ScalarMetaParam {
        param: registry.addScalarParam(MemoryRange.S32, paramId.packString1MaxDischCurr, false, false, slots.current1)
        name: qsTr("")
    }
    property ScalarMetaParam packString1MaxChgCurr: ScalarMetaParam {
        param: registry.addScalarParam(MemoryRange.S32, paramId.packString1MaxChgCurr, false, false, slots.current1)
        name: qsTr("")
    }
    property ScalarMetaParam packTracMaxDischCurr: ScalarMetaParam {
        param: registry.addScalarParam(MemoryRange.S32, paramId.packTracMaxDischCurr, false, false, slots.current1)
        name: qsTr("")
    }
    property ScalarMetaParam packTracMaxChgCurr: ScalarMetaParam {
        param: registry.addScalarParam(MemoryRange.S32, paramId.packTracMaxChgCurr, false, false, slots.current1)
        name: qsTr("")
    }
    property ScalarMetaParam packCellProtMaxVolt: ScalarMetaParam {
        param: registry.addScalarParam(MemoryRange.S32, paramId.packCellProtMaxVolt, false, false, slots.ltcCellv)
        name: qsTr("")
    }
    property ScalarMetaParam packCellProtMinVolt: ScalarMetaParam {
        param: registry.addScalarParam(MemoryRange.S32, paramId.packCellProtMinVolt, false, false, slots.ltcCellv)
        name: qsTr("")
    }
    property ScalarMetaParam packCellProtRes: ScalarMetaParam {
        param: registry.addScalarParam(MemoryRange.S32, paramId.packCellProtRes, false, false, slots.cellProtRes)
        name: qsTr("")
    }
    property ScalarMetaParam packCellProtVoltageMaxDischCurr: ScalarMetaParam {
        param: registry.addScalarParam(MemoryRange.S32, paramId.packCellProtVoltageMaxDischCurr, false, false, slots.current1)
        name: qsTr("")
    }
    property ScalarMetaParam packCellProtVoltageMaxChgCurr: ScalarMetaParam {
        param: registry.addScalarParam(MemoryRange.S32, paramId.packCellProtVoltageMaxChgCurr, false, false, slots.current1)
        name: qsTr("")
    }
    property ScalarMetaParam packCellProtThermalMaxDischCurr: ScalarMetaParam {
        param: registry.addScalarParam(MemoryRange.S32, paramId.packCellProtThermalMaxDischCurr, false, false, slots.current1)
        name: qsTr("")
    }
    property ScalarMetaParam packCellProtThermalMaxChgCurr: ScalarMetaParam {
        param: registry.addScalarParam(MemoryRange.S32, paramId.packCellProtThermalMaxChgCurr, false, false, slots.current1)
        name: qsTr("")
    }
    property ScalarMetaParam packStatus: ScalarMetaParam {
        param: registry.addScalarParam(MemoryRange.S32, paramId.packStatus, false, false, slots.raw32hex)
        name: qsTr("")
    }
    property ScalarMetaParam packMaxCellVolt: ScalarMetaParam {
        param: registry.addScalarParam(MemoryRange.S32, paramId.packMaxCellVolt, false, false, slots.ltcCellv)
        name: qsTr("")
    }
    property ScalarMetaParam packMeanCellVolt: ScalarMetaParam {
        param: registry.addScalarParam(MemoryRange.S32, paramId.packMeanCellVolt, false, false, slots.ltcCellv)
        name: qsTr("")
    }
    property ScalarMetaParam packMinCellVolt: ScalarMetaParam {
        param: registry.addScalarParam(MemoryRange.S32, paramId.packMinCellVolt, false, false, slots.ltcCellv)
        name: qsTr("")
    }
    property ScalarMetaParam packMaxCellTemp: ScalarMetaParam {
        param: registry.addScalarParam(MemoryRange.S32, paramId.packMaxCellTemp, false, false, slots.saeTp02)
        name: qsTr("")
    }
    property ScalarMetaParam packMeanCellTemp: ScalarMetaParam {
        param: registry.addScalarParam(MemoryRange.S32, paramId.packMeanCellTemp, false, false, slots.saeTp02)
        name: qsTr("")
    }
    property ScalarMetaParam packMinCellTemp: ScalarMetaParam {
        param: registry.addScalarParam(MemoryRange.S32, paramId.packMinCellTemp, false, false, slots.saeTp02)
        name: qsTr("")
    }
    property ScalarMetaParam packGndFltDetectPulldownPosVolt: ScalarMetaParam {
        param: registry.addScalarParam(MemoryRange.S32, paramId.packGndFltDetectPulldownPosVolt, false, false, slots.voltage1)
        name: qsTr("")
    }
    property ScalarMetaParam packGndFltDetectPulldownNegVolt: ScalarMetaParam {
        param: registry.addScalarParam(MemoryRange.S32, paramId.packGndFltDetectPulldownNegVolt, false, false, slots.voltage1)
        name: qsTr("")
    }
    property ScalarMetaParam packGndFltDetectPullupPosVolt: ScalarMetaParam {
        param: registry.addScalarParam(MemoryRange.S32, paramId.packGndFltDetectPullupPosVolt, false, false, slots.voltage1)
        name: qsTr("")
    }
    property ScalarMetaParam packGndFltDetectPullupNegVolt: ScalarMetaParam {
        param: registry.addScalarParam(MemoryRange.S32, paramId.packGndFltDetectPullupNegVolt, false, false, slots.voltage1)
        name: qsTr("")
    }
    property ScalarMetaParam packGndFltCenterVolt: ScalarMetaParam {
        param: registry.addScalarParam(MemoryRange.S32, paramId.packGndFltCenterVolt, false, false, slots.voltage1)
        name: qsTr("")
    }
    property ScalarMetaParam packGndFltFrac: ScalarMetaParam {
        param: registry.addScalarParam(MemoryRange.S32, paramId.packGndFltFrac, false, false, slots.saePc01)
        name: qsTr("")
    }
    property ScalarMetaParam packGndFltConduct: ScalarMetaParam {
        param: registry.addScalarParam(MemoryRange.S32, paramId.packGndFltConduct, false, false, slots.conductance1)
        name: qsTr("")
    }
    property ScalarMetaParam packCtcCtrlStateCode: ScalarMetaParam {
        param: registry.addScalarParam(MemoryRange.S32, paramId.packCtcCtrlStateCode, false, false, slots.ctcCtrlState)
        name: qsTr("")
    }
    property ScalarMetaParam packBalancerStateCode: ScalarMetaParam {
        param: registry.addScalarParam(MemoryRange.S32, paramId.packBalancerStateCode, false, false, slots.balancerState)
        name: qsTr("")
    }

    property ScalarMetaParam sysCycleIdleTicks: ScalarMetaParam {
        param: registry.addScalarParam(MemoryRange.S32, paramId.sysCycleIdleTicks, false, false, slots.timeSysTick)
        name: qsTr("")
    }
    property ScalarMetaParam sysCycleDrvCbtmInTicks: ScalarMetaParam {
        param: registry.addScalarParam(MemoryRange.S32, paramId.sysCycleDrvCbtmInTicks, false, false, slots.timeSysTick)
        name: qsTr("")
    }
    property ScalarMetaParam sysCycleDrvIaiInTicks: ScalarMetaParam {
        param: registry.addScalarParam(MemoryRange.S32, paramId.sysCycleDrvIaiInTicks, false, false, slots.timeSysTick)
        name: qsTr("")
    }
    property ScalarMetaParam sysCycleCtlAuxBattTicks: ScalarMetaParam {
        param: registry.addScalarParam(MemoryRange.S32, paramId.sysCycleCtlAuxBattTicks, false, false, slots.timeSysTick)
        name: qsTr("")
    }
    property ScalarMetaParam sysCycleCtlLampTicks: ScalarMetaParam {
        param: registry.addScalarParam(MemoryRange.S32, paramId.sysCycleCtlLampTicks, false, false, slots.timeSysTick)
        name: qsTr("")
    }
    property ScalarMetaParam sysCycleCtlMotorTicks: ScalarMetaParam {
        param: registry.addScalarParam(MemoryRange.S32, paramId.sysCycleCtlMotorTicks, false, false, slots.timeSysTick)
        name: qsTr("")
    }
    property ScalarMetaParam sysCycleCtlPackTicks: ScalarMetaParam {
        param: registry.addScalarParam(MemoryRange.S32, paramId.sysCycleCtlPackTicks, false, false, slots.timeSysTick)
        name: qsTr("")
    }

    property ScalarMetaParam sysFlags: ScalarMetaParam {
        param: registry.addScalarParam(MemoryRange.S32, paramId.sysFlags, false, false, slots.raw32)
        name: qsTr("")
    }
    property ScalarMetaParam sysHeapAllocBytes: ScalarMetaParam {
        param: registry.addScalarParam(MemoryRange.S32, paramId.sysHeapAllocBytes, false, false, slots.raw32)
        name: qsTr("")
    }
    property ScalarMetaParam sysHeapFreeBytes: ScalarMetaParam {
        param: registry.addScalarParam(MemoryRange.S32, paramId.sysHeapFreeBytes, false, false, slots.raw32)
        name: qsTr("")
    }
    property ScalarMetaParam sysHeapNFrees: ScalarMetaParam {
        param: registry.addScalarParam(MemoryRange.S32, paramId.sysHeapNFrees, false, false, slots.raw32)
        name: qsTr("")
    }
    property ScalarMetaParam sysRtDbRows: ScalarMetaParam {
        param: registry.addScalarParam(MemoryRange.S32, paramId.sysRtDbRows, false, false, slots.raw32)
        name: qsTr("")
    }

    property ScalarMetaParam eventBeginSerial: ScalarMetaParam {
        param: registry.addScalarParam(MemoryRange.S32, paramId.eventBeginSerial, false, false, slots.raw32)
        name: qsTr("")
    }

    property ScalarMetaParam eventEndSerial: ScalarMetaParam {
        param: registry.addScalarParam(MemoryRange.S32, paramId.eventEndSerial, false, false, slots.raw32)
        name: qsTr("")
    }
    property ScalarMetaParam eventClearToSerial: ScalarMetaParam {
        param: registry.addScalarParam(MemoryRange.S32, paramId.eventClearToSerial, true, false, slots.raw32)
        name: qsTr("")
        immediateWrite: true
    }
    property ScalarMetaParam eventViewSerial: ScalarMetaParam {
        param: registry.addScalarParam(MemoryRange.S32, paramId.eventViewSerial, true, false, slots.raw32)
        name: qsTr("")
        immediateWrite: true
    }
    property ScalarMetaParam eventViewKey: ScalarMetaParam {
        param: registry.addScalarParam(MemoryRange.U32, paramId.eventViewKey, false, false, slots.rawu32hex)
        name: qsTr("")
    }
    property ScalarMetaParam eventViewFreezeSize: ScalarMetaParam {
        param: registry.addScalarParam(MemoryRange.U32, paramId.eventViewFreezeSize, false, false, slots.raw32)
        name: qsTr("")
    }
    property TableParam eventViewFreeze: TableParam {
        x: SlotArrayModel {
            slot: slots.raw32
            count: 16
        }
        value: registry.addArrayParam(MemoryRange.U32, paramId.eventViewFreeze, 16, false, false, slots.rawu32hex)
    }
}
