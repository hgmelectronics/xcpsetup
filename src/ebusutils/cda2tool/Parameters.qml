import QtQuick 2.5
import com.hgmelectronics.setuptools.xcp 1.0
import com.hgmelectronics.setuptools 1.0
import com.hgmelectronics.setuptools.ui 1.0

ParamRegistry {
    id: root

    property ParamId paramId: ParamId {}
    property Slots slots: Slots {}

    property int cbtmCellsPerBoard: 8
    property int cbtmTabsPerBoard: 9
    property int cbtmMaxBoards: 32
    property int tbtMinCellsPerBoard: 23
    property int tbtMaxCellsPerString: 192
    property int tbtMaxSectionsPerString: 16
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
    property SlotArrayModel tbtCellAxisModel: SlotArrayModel {
        slot: slots.raw32
        count: tbtMaxCellsPerString
    }
    property SlotArrayModel tbtSectionAxisModel: SlotArrayModel {
        slot: slots.raw32
        count: tbtMaxSectionsPerString
    }

    property ScalarMetaParam aioVbatEv01: ScalarMetaParam {
        param: ScalarParam {
            registry: root
            dataType: Param.S32
            addr: paramId.aioVbatEv01
            writable: false
            saveable: false
            slot: slots.voltage1
            name: qsTr("")
        }
    }

    property TableParam aioAiCts: TableParam {
        x: aiAxisModel
        value: ArrayParam {
                registry: root
                dataType: Param.S32
                addr: paramId.aioAiCts
                minCount: aiAxisModel.count
                writable: false
                saveable: false
                slot: slots.stAiVolts
                name: qsTr("")
            }
    }

    property ScalarMetaParam canAuxBattCnvtCmdOn: ScalarMetaParam {
        param: ScalarParam {
            registry: root
            dataType: Param.S32
            addr: paramId.canAuxBattCnvtCmdOn
            writable: false
            saveable: false
            slot: slots.bool01
            name: qsTr("")
        }
    }
    property ScalarMetaParam canAuxBattCnvtCmdVolt: ScalarMetaParam {
        param: ScalarParam {
            registry: root
            dataType: Param.S32
            addr: paramId.canAuxBattCnvtCmdVolt
            writable: false
            saveable: false
            slot: slots.voltage1
            name: qsTr("")
        }
    }
    property ScalarMetaParam canCtlMaxMotoringTorque: ScalarMetaParam {
        param: ScalarParam {
            registry: root
            dataType: Param.S32
            addr: paramId.canCtlMaxMotoringTorque
            writable: false
            saveable: false
            slot: slots.saePc06Ext
            name: qsTr("")
        }
    }
    property ScalarMetaParam canCtlMaxRegenTorque: ScalarMetaParam {
        param: ScalarParam {
            registry: root
            dataType: Param.S32
            addr: paramId.canCtlMaxRegenTorque
            writable: false
            saveable: false
            slot: slots.saePc06Ext
            name: qsTr("")
        }
    }
    property ScalarMetaParam canTracMotorSpeed: ScalarMetaParam {
        param: ScalarParam {
            registry: root
            dataType: Param.S32
            addr: paramId.canTracMotorSpeed
            writable: false
            saveable: false
            slot: slots.saeVr01
            name: qsTr("")
        }
    }
    property ScalarMetaParam canLimpHomeCmdOn: ScalarMetaParam {
        param: ScalarParam {
            registry: root
            dataType: Param.S32
            addr: paramId.canLimpHomeCmdOn
            writable: false
            saveable: false
            slot: slots.bool01
            name: qsTr("")
        }
    }
    property ScalarMetaParam canBattMaxDischCurrCmd: ScalarMetaParam {
        param: ScalarParam {
            registry: root
            dataType: Param.S32
            addr: paramId.canBattMaxDischCurrCmd
            writable: false
            saveable: false
            slot: slots.current1
            name: qsTr("")
        }
    }
    property ScalarMetaParam canBattMaxChgCurrCmd: ScalarMetaParam {
        param: ScalarParam {
            registry: root
            dataType: Param.S32
            addr: paramId.canBattMaxChgCurrCmd
            writable: false
            saveable: false
            slot: slots.current1
            name: qsTr("")
        }
    }
    property ScalarMetaParam canAuxBattCnvtState: ScalarMetaParam {
        param: ScalarParam {
            registry: root
            dataType: Param.S32
            addr: paramId.canAuxBattCnvtState
            writable: false
            saveable: false
            slot: slots.auxBattCnvtState
            name: qsTr("")
        }
    }
    property ScalarMetaParam canAuxBattCnvtTemp: ScalarMetaParam {
        param: ScalarParam {
            registry: root
            dataType: Param.S32
            addr: paramId.canAuxBattCnvtTemp
            writable: false
            saveable: false
            slot: slots.saeTp02
            name: qsTr("")
        }
    }
    property ScalarMetaParam canAuxBattCnvtInputVolt: ScalarMetaParam {
        param: ScalarParam {
            registry: root
            dataType: Param.S32
            addr: paramId.canAuxBattCnvtInputVolt
            writable: false
            saveable: false
            slot: slots.voltage1
            name: qsTr("")
        }
    }
    property ScalarMetaParam canAuxBattCnvtOutputVolt: ScalarMetaParam {
        param: ScalarParam {
            registry: root
            dataType: Param.S32
            addr: paramId.canAuxBattCnvtOutputVolt
            writable: false
            saveable: false
            slot: slots.voltage1
            name: qsTr("")
        }
    }
    property ScalarMetaParam canAuxBattCnvtOutputCurr: ScalarMetaParam {
        param: ScalarParam {
            registry: root
            dataType: Param.S32
            addr: paramId.canAuxBattCnvtOutputCurr
            writable: false
            saveable: false
            slot: slots.current1
            name: qsTr("")
        }
    }
    property ScalarMetaParam canExtChgCtcRqst: ScalarMetaParam {
        param: ScalarParam {
            registry: root
            dataType: Param.S32
            addr: paramId.canExtChgCtcRqst
            writable: false
            saveable: false
            slot: slots.bool01
            name: qsTr("")
        }
    }
    property ScalarMetaParam canAuxCtcRqrd: ScalarMetaParam {
        param: ScalarParam {
            registry: root
            dataType: Param.S32
            addr: paramId.canAuxCtcRqrd
            writable: false
            saveable: false
            slot: slots.bool01
            name: qsTr("")
        }
    }
    property ScalarMetaParam canXcpProgramRequested: ScalarMetaParam {
        param: ScalarParam {
            registry: root
            dataType: Param.S32
            addr: paramId.canXcpProgramRequested
            writable: false
            saveable: false
            slot: slots.bool01
            name: qsTr("")
        }
    }
    property ScalarMetaParam canCan1RxErrCount: ScalarMetaParam {
        param: ScalarParam {
            registry: root
            dataType: Param.S32
            addr: paramId.canCan1RxErrCount
            writable: false
            saveable: false
            slot: slots.raw32
            name: qsTr("")
        }
    }
    property ScalarMetaParam canCan1TxErrCount: ScalarMetaParam {
        param: ScalarParam {
            registry: root
            dataType: Param.S32
            addr: paramId.canCan1TxErrCount
            writable: false
            saveable: false
            slot: slots.raw32
            name: qsTr("")
        }
    }
    property ScalarMetaParam canCan2RxErrCount: ScalarMetaParam {
        param: ScalarParam {
            registry: root
            dataType: Param.S32
            addr: paramId.canCan2RxErrCount
            writable: false
            saveable: false
            slot: slots.raw32
            name: qsTr("")
        }
    }
    property ScalarMetaParam canCan2TxErrCount: ScalarMetaParam {
        param: ScalarParam {
            registry: root
            dataType: Param.S32
            addr: paramId.canCan2TxErrCount
            writable: false
            saveable: false
            slot: slots.raw32
            name: qsTr("")
        }
    }
    property ScalarMetaParam canCan1BufferFull: ScalarMetaParam {
        param: ScalarParam {
            registry: root
            dataType: Param.S32
            addr: paramId.canCan1BufferFull
            writable: false
            saveable: false
            slot: slots.raw32
            name: qsTr("")
        }
    }
    property ScalarMetaParam canCan2BufferFull: ScalarMetaParam {
        param: ScalarParam {
            registry: root
            dataType: Param.S32
            addr: paramId.canCan2BufferFull
            writable: false
            saveable: false
            slot: slots.raw32
            name: qsTr("")
        }
    }
    property ScalarMetaParam cbtmFaultDecayCyc: ScalarMetaParam {
        param: ScalarParam {
            registry: root
            dataType: Param.S32
            addr: paramId.cbtmFaultDecayCyc
            writable: true
            saveable: true
            slot: slots.timeCycle
            name: qsTr("")
        }
    }
    property ScalarMetaParam cbtmNonQuiescentTripCyc: ScalarMetaParam {
        param: ScalarParam {
            registry: root
            dataType: Param.S32
            addr: paramId.cbtmNonQuiescentTripCyc
            writable: true
            saveable: true
            slot: slots.timeCycle
            name: qsTr("")
        }
    }
    property ScalarMetaParam cbtmNonQuiescentDecayCyc: ScalarMetaParam {
        param: ScalarParam {
            registry: root
            dataType: Param.S32
            addr: paramId.cbtmNonQuiescentDecayCyc
            writable: true
            saveable: true
            slot: slots.timeCycle
            name: qsTr("")
        }
    }
    property ScalarMetaParam cbtmBalanceOpenDeltaVThresh: ScalarMetaParam {
        param: ScalarParam {
            registry: root
            dataType: Param.S32
            addr: paramId.cbtmBalanceOpenDeltaVThresh
            writable: true
            saveable: true
            slot: slots.ltcCellvExt
            name: qsTr("")
        }
    }
    property ScalarMetaParam cbtmBalanceShortDeltaVThresh: ScalarMetaParam {
        param: ScalarParam {
            registry: root
            dataType: Param.S32
            addr: paramId.cbtmBalanceShortDeltaVThresh
            writable: true
            saveable: true
            slot: slots.ltcCellvExt
            name: qsTr("")
        }
    }
    property ScalarMetaParam cbtmQuiescentDeltaVThresh: ScalarMetaParam {
        param: ScalarParam {
            registry: root
            dataType: Param.S32
            addr: paramId.cbtmQuiescentDeltaVThresh
            writable: true
            saveable: true
            slot: slots.ltcCellvExt
            name: qsTr("")
        }
    }
    property ScalarMetaParam cbtmIsospi1FirstBoard: ScalarMetaParam {
        param: ScalarParam {
            registry: root
            dataType: Param.S32
            addr: paramId.cbtmIsospi1FirstBoard
            writable: true
            saveable: true
            slot: slots.raw32
            name: qsTr("")
        }
    }
    property ScalarMetaParam cbtmIsospi1LastBoard: ScalarMetaParam {
        param: ScalarParam {
            registry: root
            dataType: Param.S32
            addr: paramId.cbtmIsospi1LastBoard
            writable: true
            saveable: true
            slot: slots.raw32
            name: qsTr("")
        }
    }
    property ScalarMetaParam cbtmIsospi2FirstBoard: ScalarMetaParam {
        param: ScalarParam {
            registry: root
            dataType: Param.S32
            addr: paramId.cbtmIsospi2FirstBoard
            writable: true
            saveable: true
            slot: slots.raw32
            name: qsTr("")
        }
    }
    property ScalarMetaParam cbtmIsospi2LastBoard: ScalarMetaParam {
        param: ScalarParam {
            registry: root
            dataType: Param.S32
            addr: paramId.cbtmIsospi2LastBoard
            writable: true
            saveable: true
            slot: slots.raw32
            name: qsTr("")
        }
    }
    property ScalarMetaParam cbtmCommFaultTripCyc: ScalarMetaParam {
        param: ScalarParam {
            registry: root
            dataType: Param.S32
            addr: paramId.cbtmCommFaultTripCyc
            writable: true
            saveable: true
            slot: slots.raw32
            name: qsTr("")
        }
    }
    property ScalarMetaParam cbtmCommFaultClearCyc: ScalarMetaParam {
        param: ScalarParam {
            registry: root
            dataType: Param.S32
            addr: paramId.cbtmCommFaultClearCyc
            writable: true
            saveable: true
            slot: slots.raw32
            name: qsTr("")
        }
    }
    property ScalarMetaParam tbtFaultDecayCyc: ScalarMetaParam {
        param: ScalarParam {
            registry: root
            dataType: Param.S32
            addr: paramId.tbtFaultDecayCyc
            writable: true
            saveable: true
            slot: slots.timeCycle
            name: qsTr("")
        }
    }
    property ScalarMetaParam tbtCommFaultTripCyc: ScalarMetaParam {
        param: ScalarParam {
            registry: root
            dataType: Param.S32
            addr: paramId.tbtCommFaultTripCyc
            writable: true
            saveable: true
            slot: slots.raw32
            name: qsTr("")
        }
    }
    property ScalarMetaParam tbtCommFaultClearCyc: ScalarMetaParam {
        param: ScalarParam {
            registry: root
            dataType: Param.S32
            addr: paramId.tbtCommFaultClearCyc
            writable: true
            saveable: true
            slot: slots.raw32
            name: qsTr("")
        }
    }
    property ScalarMetaParam tbtModulesPerBus: ScalarMetaParam {
        param: ScalarParam {
            registry: root
            dataType: Param.S32
            addr: paramId.tbtModulesPerBus
            writable: true
            saveable: true
            slot: slots.raw32
            name: qsTr("")
        }
    }
    property ScalarMetaParam tbtModuleTypes: ScalarMetaParam {
        param: ScalarParam {
            registry: root
            dataType: Param.S32
            addr: paramId.tbtModuleTypes
            writable: true
            saveable: true
            slot: slots.raw32hex
            name: qsTr("")
        }
    }
    property ScalarMetaParam tbtNBuses: ScalarMetaParam {
        param: ScalarParam {
            registry: root
            dataType: Param.S32
            addr: paramId.tbtNBuses
            writable: true
            saveable: true
            slot: slots.raw32
            name: qsTr("")
        }
    }

    property TableParam cbtmCellVolt: TableParam {
        x: SlotArrayModel {
            slot: slots.raw32
            count: cbtmCellVolt.value.count
        }
        value: ArrayParam {
            registry: root
            dataType: Param.S32
            addr: paramId.cbtmCellVolt
            minCount: cbtmCellsPerBoard
            maxCount: cbtmCellAxisModel.count
            writable: false
            saveable: false
            slot: slots.ltcCellv
            name: qsTr("")
        }
    }
    property TableParam tbtCellVoltString0: TableParam {
        x: tbtCellAxisModel
        value: ArrayParam {
            registry: root
            dataType: Param.S32
            addr: paramId.tbtCellVoltString0
            maxCount: tbtCellAxisModel.count
            writable: false
            saveable: false
            slot: slots.ltcCellv
            name: qsTr("")
        }
    }
    property TableParam tbtCellVoltString1: TableParam {
        x: tbtCellAxisModel
        value: ArrayParam {
            registry: root
            dataType: Param.S32
            addr: paramId.tbtCellVoltString1
            maxCount: tbtCellAxisModel.count
            writable: false
            saveable: false
            slot: slots.ltcCellv
            name: qsTr("")
        }
    }

    property TableParam cbtmTabTemp: TableParam {
        x: SlotArrayModel {
            slot: slots.raw32
            count: cbtmTabTemp.value.count
        }
        value: ArrayParam {
                registry: root
            dataType: Param.S32
            addr: paramId.cbtmTabTemp
            minCount: cbtmTabsPerBoard
            maxCount: cbtmTabAxisModel.count
            writable: false
            saveable: false
            slot: slots.saeTp02
            name: qsTr("")
        }
    }

    property TableParam cbtmDisch: TableParam {
        x: SlotArrayModel {
            slot: slots.raw32
            count: cbtmDisch.value.count
        }
        value: ArrayParam {
            registry: root
            dataType: Param.S32
            addr: paramId.cbtmDisch
            minCount: 1
            maxCount: cbtmBoardAxisModel.count
            writable: true
            saveable: false
            slot: slots.raw32hex
            name: qsTr("")
        }
    }
    property TableParam tbtDischString0: TableParam {
        x: tbtSectionAxisModel
        value: ArrayParam {
            registry: root
            dataType: Param.S32
            addr: paramId.tbtDischString0
            maxCount: tbtSectionAxisModel.count
            writable: true
            saveable: false
            slot: slots.raw32hex
            name: qsTr("")
        }
    }
    property TableParam tbtDischString1: TableParam {
        x: tbtSectionAxisModel
        value: ArrayParam {
            registry: root
            dataType: Param.S32
            addr: paramId.tbtDischString1
            maxCount: tbtSectionAxisModel.count
            writable: true
            saveable: false
            slot: slots.raw32hex
            name: qsTr("")
        }
    }

    property TableParam cbtmStatus: TableParam {
        x: SlotArrayModel {
            slot: slots.raw32
            count: cbtmStatus.value.count
        }
        value: ArrayParam {
            registry: root
            dataType: Param.S32
            addr: paramId.cbtmStatus
            minCount: 1
            maxCount: cbtmBoardAxisModel.count
            writable: false
            saveable: false
            slot: slots.raw32hex
            name: qsTr("")
        }
    }
    property TableParam tbtStatusString0: TableParam {
        x: tbtSectionAxisModel
        value: ArrayParam {
            registry: root
            dataType: Param.S32
            addr: paramId.tbtStatusString0
            maxCount: tbtSectionAxisModel.count
            writable: true
            saveable: false
            slot: slots.raw32hex
            name: qsTr("")
        }
    }
    property TableParam tbtStatusString1: TableParam {
        x: tbtSectionAxisModel
        value: ArrayParam {
            registry: root
            dataType: Param.S32
            addr: paramId.tbtStatusString1
            maxCount: tbtSectionAxisModel.count
            writable: true
            saveable: false
            slot: slots.raw32hex
            name: qsTr("")
        }
    }

    property MultiroleTableMetaParam tbtCellVolt: MultiroleTableMetaParam {
        param: MultiroleTableParam {
            roleMapping: {
                "x": tbtCellAxisModel,
                "v0": tbtCellVoltString0.value,
                "v1": tbtCellVoltString1.value
            }
        }
        isLiveData: true
    }

    property MultiroleTableMetaParam tbtDischAndStatus: MultiroleTableMetaParam {
        param: MultiroleTableParam {
            roleMapping: {
                "x": tbtSectionAxisModel,
                "disch0": tbtDischString0.value,
                "disch1": tbtDischString1.value,
                "status0": tbtStatusString0.value,
                "status1": tbtStatusString1.value
            }
        }
        isLiveData: true
    }

    property ScalarMetaParam ctcMaxSimulPickup: ScalarMetaParam {
        param: ScalarParam {
            registry: root
            dataType: Param.S32
            addr: paramId.ctcMaxSimulPickup
            writable: true
            saveable: true
            slot: slots.raw32
            name: qsTr("")
        }
    }


    property TableParam ctcNFeedbackInput: TableParam {
        x: ctcAxisModel
        value: ArrayParam {
            registry: root
            dataType: Param.S32
            addr: paramId.ctcNFeedbackInput
            minCount: ctcAxisModel.count
            writable: true
            saveable: true
            slot: slots.ctcFeedback
            name: qsTr("")
        }
    }

    property TableParam ctcOn: TableParam {
        x: ctcAxisModel
        value: ArrayParam {
            registry: root
            dataType: Param.S32
            addr: paramId.ctcOn
            minCount: ctcAxisModel.count
            writable: true
            saveable: false
            slot: slots.bool01
            name: qsTr("")
        }
    }
    property TableParam ctcOk: TableParam {
        x: ctcAxisModel
        value: ArrayParam {
            registry: root
            dataType: Param.S32
            addr: paramId.ctcOk
            minCount: ctcAxisModel.count
            writable: false
            saveable: false
            slot: slots.bool01
            name: qsTr("")
        }
    }
    property TableParam ctcAClosed: TableParam {
        x: ctcAxisModel
        value: ArrayParam {
            registry: root
            dataType: Param.S32
            addr: paramId.ctcAClosed
            minCount: ctcAxisModel.count
            writable: false
            saveable: false
            slot: slots.bool01
            name: qsTr("")
        }
    }
    property TableParam ctcBClosed: TableParam {
        x: ctcAxisModel
        value: ArrayParam {
            registry: root
            dataType: Param.S32
            addr: paramId.ctcBClosed
            minCount: ctcAxisModel.count
            writable: false
            saveable: false
            slot: slots.bool01
            name: qsTr("")
        }
    }

    property TableParam dioDi: TableParam {
        x: diAxisModel
        value: ArrayParam {
            registry: root
            dataType: Param.S32
            addr: paramId.dioDi
            minCount: diAxisModel.count
            writable: false
            saveable: false
            slot: slots.bool01
            name: qsTr("")
        }
    }

    property TableParam dioDo: TableParam {
        x: doAxisModel
        value: ArrayParam {
            registry: root
            dataType: Param.S32
            addr: paramId.dioDo
            minCount: doAxisModel.count
            writable: true
            saveable: false
            slot: slots.bool01
            name: qsTr("")
        }
    }

    property TableParam iaiDiffCts: TableParam {
        x: iaiAxisModel
        value: ArrayParam {
            registry: root
            dataType: Param.S32
            addr: paramId.iaiDiffCts
            minCount: iaiAxisModel.count
            writable: false
            saveable: false
            slot: slots.iaiMvScale
            name: qsTr("")
        }
    }

    property TableParam iaiOk: TableParam {
        x: iaiAxisModel
        value: ArrayParam {
            registry: root
            dataType: Param.S32
            addr: paramId.iaiOk
            minCount: iaiAxisModel.count
            writable: false
            saveable: false
            slot: slots.bool01
            name: qsTr("")
        }
    }

    property ScalarMetaParam iai4PosCts: ScalarMetaParam {
        param: ScalarParam {
            registry: root
            dataType: Param.S32
            addr: paramId.iai4PosCts
            writable: false
            saveable: false
            slot: slots.iaiMvScale
            name: qsTr("")
        }
    }
    property ScalarMetaParam iai4NegCts: ScalarMetaParam {
        param: ScalarParam {
            registry: root
            dataType: Param.S32
            addr: paramId.iai4NegCts
            writable: false
            saveable: false
            slot: slots.iaiMvScale
            name: qsTr("")
        }
    }
    property ScalarMetaParam iai4Pullup: ScalarMetaParam {
        param: ScalarParam {
            registry: root
            dataType: Param.S32
            addr: paramId.iai4Pullup
            writable: true
            saveable: false
            slot: slots.bool01
            name: qsTr("")
        }
    }
    property ScalarMetaParam iai4Pulldown: ScalarMetaParam {
        param: ScalarParam {
            registry: root
            dataType: Param.S32
            addr: paramId.iai4Pulldown
            writable: true
            saveable: false
            slot: slots.bool01
            name: qsTr("")
        }
    }

    property ScalarMetaParam auxBattCnvtType: ScalarMetaParam {
        param: ScalarParam {
            registry: root
            dataType: Param.S32
            addr: paramId.auxBattCnvtType
            writable: true
            saveable: true
            slot: slots.auxBattCnvtType
            name: qsTr("")
        }
    }
    property ScalarMetaParam auxBattCnvtInputVoltMin: ScalarMetaParam {
        param: ScalarParam {
            registry: root
            dataType: Param.S32
            addr: paramId.auxBattCnvtInputVoltMin
            writable: true
            saveable: true
            slot: slots.voltage1
            name: qsTr("")
        }
    }
    property ScalarMetaParam auxBattCnvtStartTemp: ScalarMetaParam {
        param: ScalarParam {
            registry: root
            dataType: Param.S32
            addr: paramId.auxBattCnvtStartTemp
            writable: true
            saveable: true
            slot: slots.saeTp02
            name: qsTr("")
        }
    }
    property ScalarMetaParam auxBattCnvtStopTemp: ScalarMetaParam {
        param: ScalarParam {
            registry: root
            dataType: Param.S32
            addr: paramId.auxBattCnvtStopTemp
            writable: true
            saveable: true
            slot: slots.saeTp02
            name: qsTr("")
        }
    }
    property ScalarMetaParam auxBattFloatVolt: ScalarMetaParam {
        param: ScalarParam {
            registry: root
            dataType: Param.S32
            addr: paramId.auxBattFloatVolt
            writable: true
            saveable: true
            slot: slots.voltage1
            name: qsTr("")
        }
    }
    property ScalarMetaParam auxBattFloatVoltTempCoeff: ScalarMetaParam {
        param: ScalarParam {
            registry: root
            dataType: Param.S32
            addr: paramId.auxBattFloatVoltTempCoeff
            writable: true
            saveable: true
            slot: slots.auxBattFloatCoeff
            name: qsTr("")
        }
    }
    property ScalarMetaParam auxBattFloatVoltMin: ScalarMetaParam {
        param: ScalarParam {
            registry: root
            dataType: Param.S32
            addr: paramId.auxBattFloatVoltMin
            writable: true
            saveable: true
            slot: slots.voltage1
            name: qsTr("")
        }
    }
    property ScalarMetaParam auxBattFloatVoltMax: ScalarMetaParam {
        param: ScalarParam {
            registry: root
            dataType: Param.S32
            addr: paramId.auxBattFloatVoltMax
            writable: true
            saveable: true
            slot: slots.voltage1
            name: qsTr("")
        }
    }
    property ScalarMetaParam auxBattFloatVoltFailsafe: ScalarMetaParam {
        param: ScalarParam {
            registry: root
            dataType: Param.S32
            addr: paramId.auxBattFloatVoltFailsafe
            writable: true
            saveable: true
            slot: slots.voltage1
            name: qsTr("")
        }
    }
    property ScalarMetaParam auxBattRestartVoltHysteresis: ScalarMetaParam {
        param: ScalarParam {
            registry: root
            dataType: Param.S32
            addr: paramId.auxBattRestartVoltHysteresis
            writable: true
            saveable: true
            slot: slots.voltage1
            name: qsTr("")
        }
    }
    property ScalarMetaParam auxBattRestartVoltTime: ScalarMetaParam {
        param: ScalarParam {
            registry: root
            dataType: Param.S32
            addr: paramId.auxBattRestartVoltTime
            writable: true
            saveable: true
            slot: slots.timeCycle
            name: qsTr("")
        }
    }
    property ScalarMetaParam auxBattRestartAlwaysTime: ScalarMetaParam {
        param: ScalarParam {
            registry: root
            dataType: Param.S32
            addr: paramId.auxBattRestartAlwaysTime
            writable: true
            saveable: true
            slot: slots.timeCycle
            name: qsTr("")
        }
    }
    property ScalarMetaParam auxBattStopOutCurr: ScalarMetaParam {
        param: ScalarParam {
            registry: root
            dataType: Param.S32
            addr: paramId.auxBattStopOutCurr
            writable: true
            saveable: true
            slot: slots.current1
            name: qsTr("")
        }
    }
    property ScalarMetaParam auxBattStopOutCurrTime: ScalarMetaParam {
        param: ScalarParam {
            registry: root
            dataType: Param.S32
            addr: paramId.auxBattStopOutCurrTime
            writable: true
            saveable: true
            slot: slots.timeCycle
            name: qsTr("")
        }
    }
    property ScalarMetaParam auxBattBattOkTemp: ScalarMetaParam {
        param: ScalarParam {
            registry: root
            dataType: Param.S32
            addr: paramId.auxBattBattOkTemp
            writable: true
            saveable: true
            slot: slots.saeTp02
            name: qsTr("")
        }
    }
    property ScalarMetaParam auxBattBattWarmTemp: ScalarMetaParam {
        param: ScalarParam {
            registry: root
            dataType: Param.S32
            addr: paramId.auxBattBattWarmTemp
            writable: true
            saveable: true
            slot: slots.saeTp02
            name: qsTr("")
        }
    }
    property ScalarMetaParam auxBattBattHotTemp: ScalarMetaParam {
        param: ScalarParam {
            registry: root
            dataType: Param.S32
            addr: paramId.auxBattBattHotTemp
            writable: true
            saveable: true
            slot: slots.saeTp02
            name: qsTr("")
        }
    }
    property ScalarMetaParam auxBattBattTemp0AiChan: ScalarMetaParam {
        param: ScalarParam {
            registry: root
            dataType: Param.S32
            addr: paramId.auxBattBattTemp0AiChan
            writable: true
            saveable: true
            slot: slots.raw32
            name: qsTr("")
        }
    }
    property ScalarMetaParam auxBattBattTemp1AiChan: ScalarMetaParam {
        param: ScalarParam {
            registry: root
            dataType: Param.S32
            addr: paramId.auxBattBattTemp1AiChan
            writable: true
            saveable: true
            slot: slots.raw32
            name: qsTr("")
        }
    }
    property ScalarMetaParam auxBattBattTemp0Curve: ScalarMetaParam {
        param: ScalarParam {
            registry: root
            dataType: Param.S32
            addr: paramId.auxBattBattTemp0Curve
            writable: true
            saveable: true
            slot: slots.thermistorCurve
            name: qsTr("")
        }
    }
    property ScalarMetaParam auxBattBattTemp1Curve: ScalarMetaParam {
        param: ScalarParam {
            registry: root
            dataType: Param.S32
            addr: paramId.auxBattBattTemp1Curve
            writable: true
            saveable: true
            slot: slots.thermistorCurve
            name: qsTr("")
        }
    }
    property ScalarMetaParam auxBattRestartVoltTimeCount: ScalarMetaParam {
        param: ScalarParam {
            registry: root
            dataType: Param.S32
            addr: paramId.auxBattRestartVoltTimeCount
            writable: true
            saveable: true
            slot: slots.timeCycle
            name: qsTr("")
        }
    }
    property ScalarMetaParam auxBattRestartAlwaysTimeCount: ScalarMetaParam {
        param: ScalarParam {
            registry: root
            dataType: Param.S32
            addr: paramId.auxBattRestartAlwaysTimeCount
            writable: true
            saveable: true
            slot: slots.timeCycle
            name: qsTr("")
        }
    }
    property ScalarMetaParam auxBattStopOutCurrTimeCount: ScalarMetaParam {
        param: ScalarParam {
            registry: root
            dataType: Param.S32
            addr: paramId.auxBattStopOutCurrTimeCount
            writable: true
            saveable: true
            slot: slots.timeCycle
            name: qsTr("")
        }
    }

    property ScalarMetaParam auxBattBattTemp0: ScalarMetaParam {
        param: ScalarParam {
            registry: root
            dataType: Param.S32
            addr: paramId.auxBattBattTemp0
            writable: false
            saveable: false
            slot: slots.saeTp02
            name: qsTr("")
        }
    }
    property ScalarMetaParam auxBattBattTemp1: ScalarMetaParam {
        param: ScalarParam {
            registry: root
            dataType: Param.S32
            addr: paramId.auxBattBattTemp1
            writable: false
            saveable: false
            slot: slots.saeTp02
            name: qsTr("")
        }
    }
    property ScalarMetaParam auxBattStatus: ScalarMetaParam {
        param: ScalarParam {
            registry: root
            dataType: Param.S32
            addr: paramId.auxBattStatus
            writable: false
            saveable: false
            slot: slots.raw32hex
            name: qsTr("")
        }
    }

    property ScalarMetaParam motorFailsafeSpeed: ScalarMetaParam {
        param: ScalarParam {
            registry: root
            dataType: Param.S32
            addr: paramId.motorFailsafeSpeed
            writable: true
            saveable: true
            slot: slots.saeVr01
            name: qsTr("")
        }
    }
    property ScalarMetaParam motorMinEffSpeed: ScalarMetaParam {
        param: ScalarParam {
            registry: root
            dataType: Param.S32
            addr: paramId.motorMinEffSpeed
            writable: true
            saveable: true
            slot: slots.saeVr01
            name: qsTr("")
        }
    }
    property ScalarMetaParam motorRatedTorque: ScalarMetaParam {
        param: ScalarParam {
            registry: root
            dataType: Param.S32
            addr: paramId.motorRatedTorque
            writable: true
            saveable: true
            slot: slots.torque1
            name: qsTr("")
        }
    }
    property ScalarMetaParam motorCurrRegPropCoeff: ScalarMetaParam {
        param: ScalarParam {
            registry: root
            dataType: Param.S32
            addr: paramId.motorCurrRegPropCoeff
            writable: true
            saveable: true
            slot: slots.motorCurrRegPropCoeff
            name: qsTr("")
        }
    }
    property ScalarMetaParam motorCurrRegIntCoeff: ScalarMetaParam {
        param: ScalarParam {
            registry: root
            dataType: Param.S32
            addr: paramId.motorCurrRegIntCoeff
            writable: true
            saveable: true
            slot: slots.motorCurrRegIntCoeff
            name: qsTr("")
        }
    }
    property ScalarMetaParam motorMaxTorqueRefErr: ScalarMetaParam {
        param: ScalarParam {
            registry: root
            dataType: Param.S32
            addr: paramId.motorMaxTorqueRefErr
            writable: true
            saveable: true
            slot: slots.saePc06Ext
            name: qsTr("")
        }
    }
    property ScalarMetaParam motorMotoringIntegrator: ScalarMetaParam {
        param: ScalarParam {
            registry: root
            dataType: Param.S32
            addr: paramId.motorMotoringIntegrator
            writable: false
            saveable: false
            slot: slots.current1
            name: qsTr("")
        }
    }
    property ScalarMetaParam motorRegenIntegrator: ScalarMetaParam {
        param: ScalarParam {
            registry: root
            dataType: Param.S32
            addr: paramId.motorRegenIntegrator
            writable: false
            saveable: false
            slot: slots.current1
            name: qsTr("")
        }
    }
    property ScalarMetaParam motorAdjMaxMotoringCurr: ScalarMetaParam {
        param: ScalarParam {
            registry: root
            dataType: Param.S32
            addr: paramId.motorAdjMaxMotoringCurr
            writable: false
            saveable: false
            slot: slots.current1
            name: qsTr("")
        }
    }
    property ScalarMetaParam motorAdjMaxRegenCurr: ScalarMetaParam {
        param: ScalarParam {
            registry: root
            dataType: Param.S32
            addr: paramId.motorAdjMaxRegenCurr
            writable: false
            saveable: false
            slot: slots.current1
            name: qsTr("")
        }
    }

    property ScalarMetaParam packBoardsPerString: ScalarMetaParam {
        param: ScalarParam {
            registry: root
            dataType: Param.S32
            addr: paramId.packBoardsPerString
            writable: false
            saveable: false
            slot: slots.raw32
            name: qsTr("")
        }
    }
    property ScalarMetaParam packIaiFunc: ScalarMetaParam {
        param: ScalarParam {
            registry: root
            dataType: Param.S32
            addr: paramId.packIaiFunc
            writable: true
            saveable: true
            slot: slots.iaiFunc
            name: qsTr("")
        }
    }
    property ScalarMetaParam packIai1Scale: ScalarMetaParam {
        param: ScalarParam {
            registry: root
            dataType: Param.S32
            addr: paramId.packIai1Scale
            writable: true
            saveable: true
            slot: slots.iaiScaleShunt
            name: qsTr("")
        }
    }
    property ScalarMetaParam packIai2Scale: ScalarMetaParam {
        param: ScalarParam {
            registry: root
            dataType: Param.S32
            addr: paramId.packIai2Scale
            writable: true
            saveable: true
            slot: slots.iaiScaleShunt
            name: qsTr("")
        }
    }
    property ScalarMetaParam packIai3Scale: ScalarMetaParam {
        param: ScalarParam {
            registry: root
            dataType: Param.S32
            addr: paramId.packIai3Scale
            writable: true
            saveable: true
            slot: slots.iaiScaleShunt
            name: qsTr("")
        }
    }
    property ScalarMetaParam packIai4Scale: ScalarMetaParam {
        param: ScalarParam {
            registry: root
            dataType: Param.S32
            addr: paramId.packIai4Scale
            writable: true
            saveable: true
            slot: slots.voltage1
            name: qsTr("")
        }
    }
    property ScalarMetaParam packIai1Zero: ScalarMetaParam {
        param: ScalarParam {
            registry: root
            dataType: Param.S32
            addr: paramId.packIai1Zero
            writable: true
            saveable: true
            slot: slots.raw32
            name: qsTr("")
        }
    }
    property ScalarMetaParam packIai2Zero: ScalarMetaParam {
        param: ScalarParam {
            registry: root
            dataType: Param.S32
            addr: paramId.packIai2Zero
            writable: true
            saveable: true
            slot: slots.raw32
            name: qsTr("")
        }
    }
    property ScalarMetaParam packIai3Zero: ScalarMetaParam {
        param: ScalarParam {
            registry: root
            dataType: Param.S32
            addr: paramId.packIai3Zero
            writable: true
            saveable: true
            slot: slots.raw32
            name: qsTr("")
        }
    }
    property ScalarMetaParam packIai4Zero: ScalarMetaParam {
        param: ScalarParam {
            registry: root
            dataType: Param.S32
            addr: paramId.packIai4Zero
            writable: true
            saveable: true
            slot: slots.raw32
            name: qsTr("")
        }
    }
    property ScalarMetaParam packLimpHomeDischCurr: ScalarMetaParam {
        param: ScalarParam {
            registry: root
            dataType: Param.S32
            addr: paramId.packLimpHomeDischCurr
            writable: true
            saveable: true
            slot: slots.current1
            name: qsTr("")
        }
    }
    property ScalarMetaParam packLimpHomeChgCurr: ScalarMetaParam {
        param: ScalarParam {
            registry: root
            dataType: Param.S32
            addr: paramId.packLimpHomeChgCurr
            writable: true
            saveable: true
            slot: slots.current1
            name: qsTr("")
        }
    }
    property ScalarMetaParam packCellProtMarginCurr: ScalarMetaParam {
        param: ScalarParam {
            registry: root
            dataType: Param.S32
            addr: paramId.packCellProtMarginCurr
            writable: true
            saveable: true
            slot: slots.current1
            name: qsTr("")
        }
    }
    property ScalarMetaParam packCurrRegFltTripCyc: ScalarMetaParam {
        param: ScalarParam {
            registry: root
            dataType: Param.S32
            addr: paramId.packCurrRegFltTripCyc
            writable: true
            saveable: true
            slot: slots.timeCycle
            name: qsTr("")
        }
    }
    property ScalarMetaParam packCurrRegFltDecayCyc: ScalarMetaParam {
        param: ScalarParam {
            registry: root
            dataType: Param.S32
            addr: paramId.packCurrRegFltDecayCyc
            writable: true
            saveable: true
            slot: slots.timeCycle
            name: qsTr("")
        }
    }
    property ScalarMetaParam packGndFltDetectAvgCyc: ScalarMetaParam {
        param: ScalarParam {
            registry: root
            dataType: Param.S32
            addr: paramId.packGndFltDetectAvgCyc
            writable: true
            saveable: true
            slot: slots.timeCycle
            name: qsTr("")
        }
    }
    property ScalarMetaParam packGndFltDetectPeriodCyc: ScalarMetaParam {
        param: ScalarParam {
            registry: root
            dataType: Param.S32
            addr: paramId.packGndFltDetectPeriodCyc
            writable: true
            saveable: true
            slot: slots.timeCycle
            name: qsTr("")
        }
    }
    property ScalarMetaParam packGndFltTripConduct: ScalarMetaParam {
        param: ScalarParam {
            registry: root
            dataType: Param.S32
            addr: paramId.packGndFltTripConduct
            writable: true
            saveable: true
            slot: slots.conductance1
            name: qsTr("")
        }
    }
    property ScalarMetaParam packGndFltTripConductExtChg: ScalarMetaParam {
        param: ScalarParam {
            registry: root
            dataType: Param.S32
            addr: paramId.packGndFltTripConductExtChg
            writable: true
            saveable: true
            slot: slots.conductance1
            name: qsTr("")
        }
    }
    property ScalarMetaParam packGndFltTripCyc: ScalarMetaParam {
        param: ScalarParam {
            registry: root
            dataType: Param.S32
            addr: paramId.packGndFltTripCyc
            writable: true
            saveable: true
            slot: slots.raw32
            name: qsTr("")
        }
    }
    property ScalarMetaParam packGndFltDecayCyc: ScalarMetaParam {
        param: ScalarParam {
            registry: root
            dataType: Param.S32
            addr: paramId.packGndFltDecayCyc
            writable: true
            saveable: true
            slot: slots.raw32
            name: qsTr("")
        }
    }
    property ScalarMetaParam packDataLossTripCyc: ScalarMetaParam {
        param: ScalarParam {
            registry: root
            dataType: Param.S32
            addr: paramId.packDataLossTripCyc
            writable: true
            saveable: true
            slot: slots.raw32
            name: qsTr("")
        }
    }
    property ScalarMetaParam packDataLossDecayCyc: ScalarMetaParam {
        param: ScalarParam {
            registry: root
            dataType: Param.S32
            addr: paramId.packDataLossDecayCyc
            writable: true
            saveable: true
            slot: slots.raw32
            name: qsTr("")
        }
    }
    property ScalarMetaParam packHasUqmTracPrechg: ScalarMetaParam {
        param: ScalarParam {
            registry: root
            dataType: Param.S32
            addr: paramId.packHasUqmTracPrechg
            writable: true
            saveable: true
            slot: slots.bool01
            name: qsTr("")
        }
    }
    property ScalarMetaParam packHasAuxBusPrechg: ScalarMetaParam {
        param: ScalarParam {
            registry: root
            dataType: Param.S32
            addr: paramId.packHasAuxBusPrechg
            writable: true
            saveable: true
            slot: slots.bool01
            name: qsTr("")
        }
    }
    property ScalarMetaParam packTracCurrDecayCyc: ScalarMetaParam {
        param: ScalarParam {
            registry: root
            dataType: Param.S32
            addr: paramId.packTracCurrDecayCyc
            writable: true
            saveable: true
            slot: slots.timeCycle
            name: qsTr("")
        }
    }
    property ScalarMetaParam packChgCurrDecayCyc: ScalarMetaParam {
        param: ScalarParam {
            registry: root
            dataType: Param.S32
            addr: paramId.packChgCurrDecayCyc
            writable: true
            saveable: true
            slot: slots.timeCycle
            name: qsTr("")
        }
    }
    property ScalarMetaParam packMaxTracPrechgCyc: ScalarMetaParam {
        param: ScalarParam {
            registry: root
            dataType: Param.S32
            addr: paramId.packMaxTracPrechgCyc
            writable: true
            saveable: true
            slot: slots.timeCycle
            name: qsTr("")
        }
    }
    property ScalarMetaParam packLowStringVoltTrip: ScalarMetaParam {
        param: ScalarParam {
            registry: root
            dataType: Param.S32
            addr: paramId.packLowStringVoltTrip
            writable: true
            saveable: true
            slot: slots.voltage1
            name: qsTr("")
        }
    }
    property ScalarMetaParam packLowStringVoltReset: ScalarMetaParam {
        param: ScalarParam {
            registry: root
            dataType: Param.S32
            addr: paramId.packLowStringVoltReset
            writable: true
            saveable: true
            slot: slots.voltage1
            name: qsTr("")
        }
    }
    property ScalarMetaParam packBalBandVolt: ScalarMetaParam {
        param: ScalarParam {
            registry: root
            dataType: Param.S32
            addr: paramId.packBalBandVolt
            writable: true
            saveable: true
            slot: slots.ltcCellv
            name: qsTr("")
        }
    }
    property ScalarMetaParam packBalDiffVolt: ScalarMetaParam {
        param: ScalarParam {
            registry: root
            dataType: Param.S32
            addr: paramId.packBalDiffVolt
            writable: true
            saveable: true
            slot: slots.ltcCellv
            name: qsTr("")
        }
    }
    property ScalarMetaParam packBalMinVolt: ScalarMetaParam {
        param: ScalarParam {
            registry: root
            dataType: Param.S32
            addr: paramId.packBalMinVolt
            writable: true
            saveable: true
            slot: slots.ltcCellv
            name: qsTr("")
        }
    }
    property ScalarMetaParam packBalSampleWaitCyc: ScalarMetaParam {
        param: ScalarParam {
            registry: root
            dataType: Param.S32
            addr: paramId.packBalSampleWaitCyc
            writable: true
            saveable: true
            slot: slots.timeCycle
            name: qsTr("")
        }
    }
    property ScalarMetaParam packBalDischHighCyc: ScalarMetaParam {
        param: ScalarParam {
            registry: root
            dataType: Param.S32
            addr: paramId.packBalDischHighCyc
            writable: true
            saveable: true
            slot: slots.timeCycle
            name: qsTr("")
        }
    }
    property ScalarMetaParam packBalDischAllCyc: ScalarMetaParam {
        param: ScalarParam {
            registry: root
            dataType: Param.S32
            addr: paramId.packBalDischAllCyc
            writable: true
            saveable: true
            slot: slots.timeCycle
            name: qsTr("")
        }
    }

    property TableParam packMaxCurrDisch: TableParam {
        x: ArrayParam {
            registry: root
            dataType: Param.S32
            addr: paramId.packMaxCurr_DischCellTemp
            minCount: 6
            writable: true
            saveable: true
            slot: slots.saeTp02
            name: qsTr("")
        }
        value: ArrayParam {
            registry: root
            dataType: Param.S32
            addr: paramId.packMaxCurr_DischCurr
            minCount: 6
            writable: true
            saveable: true
            slot: slots.current1
            name: qsTr("")
        }
    }
    property TableParam packMaxCurrChg: TableParam {
        x: ArrayParam {
            registry: root
            dataType: Param.S32
            addr: paramId.packMaxCurr_ChgCellTemp
            minCount: 6
            writable: true
            saveable: true
            slot: slots.saeTp02
            name: qsTr("")
        }
        value: ArrayParam {
            registry: root
            dataType: Param.S32
            addr: paramId.packMaxCurr_ChgCurr
            minCount: 6
            writable: true
            saveable: true
            slot: slots.current1
            name: qsTr("")
        }
    }
    property TableParam packCellVLimitMax: TableParam {
        x: ArrayParam {
            registry: root
            dataType: Param.S32
            addr: paramId.packCellVLimit_MaxTemp
            minCount: 4
            writable: true
            saveable: true
            slot: slots.saeTp02
            name: qsTr("")
        }
        value: ArrayParam {
            registry: root
            dataType: Param.S32
            addr: paramId.packCellVLimit_MaxVolt
            minCount: 4
            writable: true
            saveable: true
            slot: slots.ltcCellv
            name: qsTr("")
        }
    }
    property TableParam packCellVLimitMin: TableParam {
        x: ArrayParam {
            registry: root
            dataType: Param.S32
            addr: paramId.packCellVLimit_MinTemp
            minCount: 4
            writable: true
            saveable: true
            slot: slots.saeTp02
            name: qsTr("")
        }
        value: ArrayParam {
            registry: root
            dataType: Param.S32
            addr: paramId.packCellVLimit_MinVolt
            minCount: 4
            writable: true
            saveable: true
            slot: slots.ltcCellv
            name: qsTr("")
        }
    }
    property TableParam packCellProtResTable: TableParam {
        x: ArrayParam {
            registry: root
            dataType: Param.S32
            addr: paramId.packCellProtRes_Temp
            minCount: 4
            writable: true
            saveable: true
            slot: slots.saeTp02
            name: qsTr("")
        }
        value: ArrayParam {
            registry: root
            dataType: Param.S32
            addr: paramId.packCellProtRes_Res
            minCount: 4
            writable: true
            saveable: true
            slot: slots.cellProtRes
            name: qsTr("")
        }
    }

    property ScalarMetaParam packString1Volt: ScalarMetaParam {
        param: ScalarParam {
            registry: root
            dataType: Param.S32
            addr: paramId.packString1Volt
            writable: false
            saveable: false
            slot: slots.voltage1
            name: qsTr("")
        }
    }
    property ScalarMetaParam packString1Curr: ScalarMetaParam {
        param: ScalarParam {
            registry: root
            dataType: Param.S32
            addr: paramId.packString1Curr
            writable: false
            saveable: false
            slot: slots.current1
            name: qsTr("")
        }
    }
    property ScalarMetaParam packTracMtrCurr: ScalarMetaParam {
        param: ScalarParam {
            registry: root
            dataType: Param.S32
            addr: paramId.packTracMtrCurr
            writable: false
            saveable: false
            slot: slots.current1
            name: qsTr("")
        }
    }
    property ScalarMetaParam packTracAuxCurr: ScalarMetaParam {
        param: ScalarParam {
            registry: root
            dataType: Param.S32
            addr: paramId.packTracAuxCurr
            writable: false
            saveable: false
            slot: slots.current1
            name: qsTr("")
        }
    }
    property ScalarMetaParam packTracTotalCurr: ScalarMetaParam {
        param: ScalarParam {
            registry: root
            dataType: Param.S32
            addr: paramId.packTracTotalCurr
            writable: false
            saveable: false
            slot: slots.current1
            name: qsTr("")
        }
    }
    property ScalarMetaParam packHybrCurr: ScalarMetaParam {
        param: ScalarParam {
            registry: root
            dataType: Param.S32
            addr: paramId.packHybrCurr
            writable: false
            saveable: false
            slot: slots.current1
            name: qsTr("")
        }
    }
    property ScalarMetaParam packNonTracAuxCurr: ScalarMetaParam {
        param: ScalarParam {
            registry: root
            dataType: Param.S32
            addr: paramId.packNonTracAuxCurr
            writable: false
            saveable: false
            slot: slots.current1
            name: qsTr("")
        }
    }
    property ScalarMetaParam packString1MaxDischCurr: ScalarMetaParam {
        param: ScalarParam {
            registry: root
            dataType: Param.S32
            addr: paramId.packString1MaxDischCurr
            writable: false
            saveable: false
            slot: slots.current1
            name: qsTr("")
        }
    }
    property ScalarMetaParam packString1MaxChgCurr: ScalarMetaParam {
        param: ScalarParam {
            registry: root
            dataType: Param.S32
            addr: paramId.packString1MaxChgCurr
            writable: false
            saveable: false
            slot: slots.current1
            name: qsTr("")
        }
    }
    property ScalarMetaParam packTracMaxDischCurr: ScalarMetaParam {
        param: ScalarParam {
            registry: root
            dataType: Param.S32
            addr: paramId.packTracMaxDischCurr
            writable: false
            saveable: false
            slot: slots.current1
            name: qsTr("")
        }
    }
    property ScalarMetaParam packTracMaxChgCurr: ScalarMetaParam {
        param: ScalarParam {
            registry: root
            dataType: Param.S32
            addr: paramId.packTracMaxChgCurr
            writable: false
            saveable: false
            slot: slots.current1
            name: qsTr("")
        }
    }
    property ScalarMetaParam packCellProtMaxVolt: ScalarMetaParam {
        param: ScalarParam {
            registry: root
            dataType: Param.S32
            addr: paramId.packCellProtMaxVolt
            writable: false
            saveable: false
            slot: slots.ltcCellv
            name: qsTr("")
        }
        name: qsTr("")
    }
    property ScalarMetaParam packCellProtMinVolt: ScalarMetaParam {
        param: ScalarParam {
            registry: root
            dataType: Param.S32
            addr: paramId.packCellProtMinVolt
            writable: false
            saveable: false
            slot: slots.ltcCellv
            name: qsTr("")
        }
    }
    property ScalarMetaParam packCellProtRes: ScalarMetaParam {
        param: ScalarParam {
            registry: root
            dataType: Param.S32
            addr: paramId.packCellProtRes
            writable: false
            saveable: false
            slot: slots.cellProtRes
            name: qsTr("")
        }
    }
    property ScalarMetaParam packCellProtVoltageMaxDischCurr: ScalarMetaParam {
        param: ScalarParam {
            registry: root
            dataType: Param.S32
            addr: paramId.packCellProtVoltageMaxDischCurr
            writable: false
            saveable: false
            slot: slots.current1
            name: qsTr("")
        }
    }
    property ScalarMetaParam packCellProtVoltageMaxChgCurr: ScalarMetaParam {
        param: ScalarParam {
            registry: root
            dataType: Param.S32
            addr: paramId.packCellProtVoltageMaxChgCurr
            writable: false
            saveable: false
            slot: slots.current1
            name: qsTr("")
        }
    }
    property ScalarMetaParam packCellProtThermalMaxDischCurr: ScalarMetaParam {
        param: ScalarParam {
            registry: root
            dataType: Param.S32
            addr: paramId.packCellProtThermalMaxDischCurr
            writable: false
            saveable: false
            slot: slots.current1
            name: qsTr("")
        }
    }
    property ScalarMetaParam packCellProtThermalMaxChgCurr: ScalarMetaParam {
        param: ScalarParam {
            registry: root
            dataType: Param.S32
            addr: paramId.packCellProtThermalMaxChgCurr
            writable: false
            saveable: false
            slot: slots.current1
            name: qsTr("")
        }
    }
    property ScalarMetaParam packStatus: ScalarMetaParam {
        param: ScalarParam {
            registry: root
            dataType: Param.S32
            addr: paramId.packStatus
            writable: false
            saveable: false
            slot: slots.raw32hex
            name: qsTr("")
        }
    }
    property ScalarMetaParam packMaxCellVolt: ScalarMetaParam {
        param: ScalarParam {
            registry: root
            dataType: Param.S32
            addr: paramId.packMaxCellVolt
            writable: false
            saveable: false
            slot: slots.ltcCellv
            name: qsTr("")
        }
    }
    property ScalarMetaParam packMeanCellVolt: ScalarMetaParam {
        param: ScalarParam {
            registry: root
            dataType: Param.S32
            addr: paramId.packMeanCellVolt
            writable: false
            saveable: false
            slot: slots.ltcCellv
            name: qsTr("")
        }
    }
    property ScalarMetaParam packMinCellVolt: ScalarMetaParam {
        param: ScalarParam {
            registry: root
            dataType: Param.S32
            addr: paramId.packMinCellVolt
            writable: false
            saveable: false
            slot: slots.ltcCellv
            name: qsTr("")
        }
    }
    property ScalarMetaParam packMaxCellTemp: ScalarMetaParam {
        param: ScalarParam {
            registry: root
            dataType: Param.S32
            addr: paramId.packMaxCellTemp
            writable: false
            saveable: false
            slot: slots.saeTp02
            name: qsTr("")
        }
    }
    property ScalarMetaParam packMeanCellTemp: ScalarMetaParam {
        param: ScalarParam {
            registry: root
            dataType: Param.S32
            addr: paramId.packMeanCellTemp
            writable: false
            saveable: false
            slot: slots.saeTp02
            name: qsTr("")
        }
    }
    property ScalarMetaParam packMinCellTemp: ScalarMetaParam {
        param: ScalarParam {
            registry: root
            dataType: Param.S32
            addr: paramId.packMinCellTemp
            writable: false
            saveable: false
            slot: slots.saeTp02
            name: qsTr("")
        }
    }
    property ScalarMetaParam packGndFltDetectPulldownPosVolt: ScalarMetaParam {
        param: ScalarParam {
            registry: root
            dataType: Param.S32
            addr: paramId.packGndFltDetectPulldownPosVolt
            writable: false
            saveable: false
            slot: slots.voltage1
            name: qsTr("")
        }
    }
    property ScalarMetaParam packGndFltDetectPulldownNegVolt: ScalarMetaParam {
        param: ScalarParam {
            registry: root
            dataType: Param.S32
            addr: paramId.packGndFltDetectPulldownNegVolt
            writable: false
            saveable: false
            slot: slots.voltage1
            name: qsTr("")
        }
    }
    property ScalarMetaParam packGndFltDetectPullupPosVolt: ScalarMetaParam {
        param: ScalarParam {
            registry: root
            dataType: Param.S32
            addr: paramId.packGndFltDetectPullupPosVolt
            writable: false
            saveable: false
            slot: slots.voltage1
            name: qsTr("")
        }
    }
    property ScalarMetaParam packGndFltDetectPullupNegVolt: ScalarMetaParam {
        param: ScalarParam {
            registry: root
            dataType: Param.S32
            addr: paramId.packGndFltDetectPullupNegVolt
            writable: false
            saveable: false
            slot: slots.voltage1
            name: qsTr("")
        }
    }
    property ScalarMetaParam packGndFltCenterVolt: ScalarMetaParam {
        param: ScalarParam {
            registry: root
            dataType: Param.S32
            addr: paramId.packGndFltCenterVolt
            writable: false
            saveable: false
            slot: slots.voltage1
            name: qsTr("")
        }
    }
    property ScalarMetaParam packGndFltFrac: ScalarMetaParam {
        param: ScalarParam {
            registry: root
            dataType: Param.S32
            addr: paramId.packGndFltFrac
            writable: false
            saveable: false
            slot: slots.saePc01
            name: qsTr("")
        }
    }
    property ScalarMetaParam packGndFltConduct: ScalarMetaParam {
        param: ScalarParam {
            registry: root
            dataType: Param.S32
            addr: paramId.packGndFltConduct
            writable: false
            saveable: false
            slot: slots.conductance1
            name: qsTr("")
        }
    }
    property ScalarMetaParam packCtcCtrlStateCode: ScalarMetaParam {
        param: ScalarParam {
            registry: root
            dataType: Param.S32
            addr: paramId.packCtcCtrlStateCode
            writable: false
            saveable: false
            slot: slots.ctcCtrlState
            name: qsTr("")
        }
    }
    property ScalarMetaParam packBalancerStateCode: ScalarMetaParam {
        param: ScalarParam {
            registry: root
            dataType: Param.S32
            addr: paramId.packBalancerStateCode
            writable: false
            saveable: false
            slot: slots.balancerState
            name: qsTr("")
        }
    }

    property ScalarMetaParam sysCycleIdleTicks: ScalarMetaParam {
        param: ScalarParam {
            registry: root
            dataType: Param.S32
            addr: paramId.sysCycleIdleTicks
            writable: false
            saveable: false
            slot: slots.timeSysTick
            name: qsTr("")
        }
    }
    property ScalarMetaParam sysCycleDrvCbtmInTicks: ScalarMetaParam {
        param: ScalarParam {
            registry: root
            dataType: Param.S32
            addr: paramId.sysCycleDrvCbtmInTicks
            writable: false
            saveable: false
            slot: slots.timeSysTick
            name: qsTr("")
        }
    }
    property ScalarMetaParam sysCycleDrvIaiInTicks: ScalarMetaParam {
        param: ScalarParam {
            registry: root
            dataType: Param.S32
            addr: paramId.sysCycleDrvIaiInTicks
            writable: false
            saveable: false
            slot: slots.timeSysTick
            name: qsTr("")
        }
    }
    property ScalarMetaParam sysCycleCtlAuxBattTicks: ScalarMetaParam {
        param: ScalarParam {
            registry: root
            dataType: Param.S32
            addr: paramId.sysCycleCtlAuxBattTicks
            writable: false
            saveable: false
            slot: slots.timeSysTick
            name: qsTr("")
        }
    }
    property ScalarMetaParam sysCycleCtlLampTicks: ScalarMetaParam {
        param: ScalarParam {
            registry: root
            dataType: Param.S32
            addr: paramId.sysCycleCtlLampTicks
            writable: false
            saveable: false
            slot: slots.timeSysTick
            name: qsTr("")
        }
    }
    property ScalarMetaParam sysCycleCtlMotorTicks: ScalarMetaParam {
        param: ScalarParam {
            registry: root
            dataType: Param.S32
            addr: paramId.sysCycleCtlMotorTicks
            writable: false
            saveable: false
            slot: slots.timeSysTick
            name: qsTr("")
        }
    }
    property ScalarMetaParam sysCycleCtlPackTicks: ScalarMetaParam {
        param: ScalarParam {
            registry: root
            dataType: Param.S32
            addr: paramId.sysCycleCtlPackTicks
            writable: false
            saveable: false
            slot: slots.timeSysTick
            name: qsTr("")
        }
    }

    property ScalarMetaParam sysFlags: ScalarMetaParam {
        param: ScalarParam {
            registry: root
            dataType: Param.S32
            addr: paramId.sysFlags
            writable: false
            saveable: false
            slot: slots.raw32
            name: qsTr("")
        }
    }
    property ScalarMetaParam sysHeapAllocBytes: ScalarMetaParam {
        param: ScalarParam {
            registry: root
            dataType: Param.S32
            addr: paramId.sysHeapAllocBytes
            writable: false
            saveable: false
            slot: slots.raw32
            name: qsTr("")
        }
    }
    property ScalarMetaParam sysHeapFreeBytes: ScalarMetaParam {
        param: ScalarParam {
            registry: root
            dataType: Param.S32
            addr: paramId.sysHeapFreeBytes
            writable: false
            saveable: false
            slot: slots.raw32
            name: qsTr("")
        }
    }
    property ScalarMetaParam sysHeapNFrees: ScalarMetaParam {
        param: ScalarParam {
            registry: root
            dataType: Param.S32
            addr: paramId.sysHeapNFrees
            writable: false
            saveable: false
            slot: slots.raw32
            name: qsTr("")
        }
    }
    property ScalarMetaParam sysRtDbRows: ScalarMetaParam {
        param: ScalarParam {
            registry: root
            dataType: Param.S32
            addr: paramId.sysRtDbRows
            writable: false
            saveable: false
            slot: slots.raw32
            name: qsTr("")
        }
    }
}
