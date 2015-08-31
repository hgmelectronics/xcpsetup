import QtQuick 2.5
import com.setuptools.xcp 1.0
import com.setuptools 1.0

QtObject {
    property ParamRegistry registry;
    property Slots slots: Slots{}
    property Axes axes: Axes{}

    property LinearSlot nothing

    property LinearSlot rpmToKPH: LinearSlot
    {
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


    readonly property ScalarParam engineCylinders: registry.addScalarParam(MemoryRange.U32, 0x0B000000, true, true, slots.cylinderCount);

    readonly property ScalarParam finalDriveRatio: registry.addScalarParam(MemoryRange.U32, 0x0A000000, true, true, slots.ratio1);
    readonly property ScalarParam displayBrightness: registry.addScalarParam(MemoryRange.U32, 0x01020000, true, true, slots.percentage1)
    readonly property ScalarParam tireDiameter: registry.addScalarParam(MemoryRange.U32, 0x02020000, true, true, slots.length)

    readonly property ScalarParam maxEngineSpeedA: registry.addScalarParam(MemoryRange.U32, 0x04230000, true, true, slots.rpm1)
    readonly property ScalarParam maxEngineSpeedB: registry.addScalarParam(MemoryRange.U32, 0x04430000, true, true, slots.rpm1)

    readonly property TableParam shiftTable12A: registry.addTableParam(MemoryRange.U32, 0x04240000, true, true, rpmToKPH, axes.percentage1);
    readonly property TableParam shiftTable23A: registry.addTableParam(MemoryRange.U32, 0x04250000, true, true, rpmToKPH, axes.percentage1);
    readonly property TableParam shiftTable34A: registry.addTableParam(MemoryRange.U32, 0x04260000, true, true, rpmToKPH, axes.percentage1);
    readonly property TableParam shiftTable45A: registry.addTableParam(MemoryRange.U32, 0x04270000, true, true, rpmToKPH, axes.percentage1);
    readonly property TableParam shiftTable56A: registry.addTableParam(MemoryRange.U32, 0x04280000, true, true, rpmToKPH, axes.percentage1);

    readonly property TableParam shiftTable12B: registry.addTableParam(MemoryRange.U32, 0x04440000, true, true, rpmToKPH, axes.percentage1);
    readonly property TableParam shiftTable23B: registry.addTableParam(MemoryRange.U32, 0x04450000, true, true, rpmToKPH, axes.percentage1);
    readonly property TableParam shiftTable34B: registry.addTableParam(MemoryRange.U32, 0x04460000, true, true, rpmToKPH, axes.percentage1);
    readonly property TableParam shiftTable45B: registry.addTableParam(MemoryRange.U32, 0x04470000, true, true, rpmToKPH, axes.percentage1);
    readonly property TableParam shiftTable56B: registry.addTableParam(MemoryRange.U32, 0x04480000, true, true, rpmToKPH, axes.percentage1);

    readonly property TableParam switchMonitorInput: registry.addTableParam(MemoryRange.U32, 0x80500000, false, false, slots.booleanOnOff1, axes.switchMonitorId)


}


