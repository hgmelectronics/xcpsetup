import QtQuick 2.5
import com.hgmelectronics.setuptools.xcp 1.0
import com.hgmelectronics.setuptools 1.0

QtObject {
    property ParamRegistry registry;
    property Slots slots: Slots{}

    property LinearSlot nothing

    property LinearSlot rpmToKPH: LinearSlot {
        rawA: 0
        engrA: 0
        rawB: 15000
        engrB: (15000 * 3.14 * tireDiameter.floatVal * 60)/ ( 100 * finalDriveRatio.floatVal * 1000)
        unit: "KPH"
        precision: 1
    }

//SHIFT_SPEED_ADJUST_A = 0x0420,
//SHIFT_DOWNSHIFT_OFFSET_A = 0x0421,
//SHIFT_MANUAL_MODE_A = 0x0422,
//SHIFT_MAX_ENGINE_SPEED_A = 0x0423,

//SHIFT_DOWNSHIFT_OFFSET_B = 0x0440,
//SHIFT_MANUAL_MODE_B = 0x0441,
//SHIFT_SPEED_ADJUST_B = 0x0442,
//SHIFT_MAX_ENGINE_SPEED_B = 0x0443,


    readonly property ScalarParam engineCylinders: registry.addScalarParam(MemoryRange.U32, 0x0B000000, true, true, slots.cylinderCount)

    readonly property ScalarParam finalDriveRatio: registry.addScalarParam(MemoryRange.U32, 0x0A000000, true, true, slots.ratio1)
    readonly property ScalarParam displayBrightness: registry.addScalarParam(MemoryRange.U32, 0x01020000, true, true, slots.percentage1)
    readonly property ScalarParam tireDiameter: registry.addScalarParam(MemoryRange.U32, 0x02020000, true, true, slots.length)

    readonly property ScalarParam maxEngineSpeedA: registry.addScalarParam(MemoryRange.U32, 0x04230000, true, true, slots.rpm1)
    readonly property ScalarParam maxEngineSpeedB: registry.addScalarParam(MemoryRange.U32, 0x04430000, true, true, slots.rpm1)

    readonly property ArrayParam shiftTable12A: registry.addArrayParam(MemoryRange.U32, 0x04240000, 101, true, true, rpmToKPH)
    readonly property ArrayParam shiftTable23A: registry.addArrayParam(MemoryRange.U32, 0x04250000, 101, true, true, rpmToKPH)
    readonly property ArrayParam shiftTable34A: registry.addArrayParam(MemoryRange.U32, 0x04260000, 101, true, true, rpmToKPH)
    readonly property ArrayParam shiftTable45A: registry.addArrayParam(MemoryRange.U32, 0x04270000, 101, true, true, rpmToKPH)
    readonly property ArrayParam shiftTable56A: registry.addArrayParam(MemoryRange.U32, 0x04280000, 101, true, true, rpmToKPH)

    readonly property ArrayParam shiftTable12B: registry.addArrayParam(MemoryRange.U32, 0x04440000, 101, true, true, rpmToKPH)
    readonly property ArrayParam shiftTable23B: registry.addArrayParam(MemoryRange.U32, 0x04450000, 101, true, true, rpmToKPH)
    readonly property ArrayParam shiftTable34B: registry.addArrayParam(MemoryRange.U32, 0x04460000, 101, true, true, rpmToKPH)
    readonly property ArrayParam shiftTable45B: registry.addArrayParam(MemoryRange.U32, 0x04470000, 101, true, true, rpmToKPH)
    readonly property ArrayParam shiftTable56B: registry.addArrayParam(MemoryRange.U32, 0x04480000, 101, true, true, rpmToKPH)

    property SlotArrayModel tps: SlotArrayModel {
        slot: percentage1
        count: 101
    }

    property TableMapperModel shiftTableA: TableMapperModel {
        mapping: {
            "tps": tps,
            "shift12": shiftTable12A,
            "shift23": shiftTable23A,
            "shift34": shiftTable34A,
            "shift45": shiftTable45A,
            "shift56": shiftTable56A
        }
    }

    readonly property ArrayParam switchMonitorInput: registry.addArrayParam(MemoryRange.U32, 0x80500000, 22, false, false, slots.booleanOnOff1)


}


