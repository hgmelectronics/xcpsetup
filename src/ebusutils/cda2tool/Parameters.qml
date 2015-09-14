import QtQuick 2.5
import com.hgmelectronics.setuptools.xcp 1.0
import com.hgmelectronics.setuptools 1.0

QtObject {
    id: parameters
    property ParamRegistry registry;
    property ParamId paramId: ParamId {}
    property Slots slots: Slots {}

    property SlotArrayModel cbtmCellAxisModel: SlotArrayModel {
        slot: slots.raw32
        count: 256
    }
    property SlotArrayModel cbtmTabAxisModel: SlotArrayModel {
        slot: slots.raw32
        count: 288
    }
    property SlotArrayModel cbtmBoardAxisModel: SlotArrayModel {
        slot: slots.raw32
        count: 32
    }
    property SlotArrayModel ctcAxisModel: SlotArrayModel {
        slot: slots.raw32
        count: 4
    }

    readonly property ArrayParam cbtmCellVoltArray: registry.addArrayParam(MemoryRange.S32, paramId.cbtmCellVolt, cbtmCellAxisModel.count, false, false, slots.ltcCellv)
    property TableMapperModel cbtmCellVolt: TableMapperModel { mapping: { "x" : cbtmCellAxisModel, "value": cbtmCellVoltArray.stringModel } }

    readonly property ArrayParam cbtmTabTempArray: registry.addArrayParam(MemoryRange.S32, paramId.cbtmTabTemp, cbtmTabAxisModel.count, false, false, slots.ltcTemp)
    property TableMapperModel cbtmTabTemp: TableMapperModel { mapping: { "x" : cbtmTabAxisModel, "value": cbtmTabTempArray.stringModel } }

    readonly property ArrayParam cbtmDischArray: registry.addArrayParam(MemoryRange.S32, paramId.cbtmDisch, cbtmBoardAxisModel.count, true, false, slots.raw32hex)
    property TableMapperModel cbtmDisch: TableMapperModel { mapping: { "x" : cbtmBoardAxisModel, "value": cbtmDischArray.stringModel } }

    readonly property ArrayParam cbtmStatusArray: registry.addArrayParam(MemoryRange.S32, paramId.cbtmStatus, cbtmBoardAxisModel.count, false, false, slots.raw32hex)
    property TableMapperModel cbtmStatus: TableMapperModel { mapping: { "x" : cbtmBoardAxisModel, "value": cbtmStatusArray.stringModel } }

    readonly property ScalarParam ctcMaxSimulPickup: registry.addScalarParam(MemoryRange.S32, paramId.ctcMaxSimulPickup, true, true, slots.raw32)

    readonly property ArrayParam ctcHasBInputArray: registry.addArrayParam(MemoryRange.S32, paramId.ctcHasBInput, ctcAxisModel.count, false, false, slots.raw32)
    property TableMapperModel ctcHasBInput: TableMapperModel { mapping: { "x" : ctcAxisModel, "value": ctcHasBInputArray.stringModel } }

    readonly property ArrayParam ctcOnArray: registry.addArrayParam(MemoryRange.S32, paramId.ctcOn, ctcAxisModel.count, false, false, slots.raw32)
    property TableMapperModel ctcOn: TableMapperModel { mapping: { "x" : ctcAxisModel, "value": ctcOnArray.stringModel } }

    readonly property ArrayParam ctcOkArray: registry.addArrayParam(MemoryRange.S32, paramId.ctcOk, ctcAxisModel.count, false, false, slots.raw32)
    property TableMapperModel ctcOk: TableMapperModel { mapping: { "x" : ctcAxisModel, "value": ctcOkArray.stringModel } }

    readonly property ArrayParam ctcAClosedArray: registry.addArrayParam(MemoryRange.S32, paramId.ctcAClosed, ctcAxisModel.count, false, false, slots.raw32)
    property TableMapperModel ctcAClosed: TableMapperModel { mapping: { "x" : ctcAxisModel, "value": ctcAClosedArray.stringModel } }

    readonly property ArrayParam ctcBClosedArray: registry.addArrayParam(MemoryRange.S32, paramId.ctcBClosed, ctcAxisModel.count, false, false, slots.raw32)
    property TableMapperModel ctcBClosed: TableMapperModel { mapping: { "x" : ctcAxisModel, "value": ctcBClosedArray.stringModel } }
}
