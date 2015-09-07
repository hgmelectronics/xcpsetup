import QtQuick 2.5
import com.hgmelectronics.setuptools.xcp 1.0
import com.hgmelectronics.setuptools 1.0

QtObject {
    property ParamRegistry registry;
    property ParamId paramId: ParamId {}
    property Slots slots: Slots {
        useMetricUnits: parent.useMetricUnits.floatVal !== 0 ? true : false
        tireDiameter: parent.tireDiameter.floatVal
        finalDriveRatio: parent.finalDriveRatio.floatVal
    }

    readonly property Param transmissionTurbineShaftSpeedSensorPulseCount: registry.addParam(MemoryRange.S32, paramId.transmission_turbine_shaft_speed_sensor_pulse_count, true, true, slots.count3)

    readonly property Param transmissionInputShaftSpeedSensorPulseCount: registry.addParam(MemoryRange.S32, paramId.transmission_input_shaft_speed_sensor_pulse_count, true, true, slots.count3)

    property SlotArrayModel percentage1AxisModel: SlotArrayModel {
        slot: slots.percentage1
        count: 101
    }
    property SlotArrayModel pressureAxisModel: SlotArrayModel {
        slot: slots.pressureTableAxis
        count: 11
    }
    property SlotArrayModel upshiftDownshiftAxisModel: SlotArrayModel {
        slot: slots.upshiftDownShiftTableIndex
        count: 14
    }
    property SlotArrayModel tempAxisModel: SlotArrayModel {
        slot: slots.tempTableIndex1
        count: 11
    }
    property SlotArrayModel colorIndexAxisModel: SlotArrayModel {
        slot: slots.colorIndex
        count: 3
    }
    property SlotArrayModel hgmShiftSelectorCalibrationGearAxisModel: SlotArrayModel {
        slot: slots.hgmShiftSelectorCalibrationGear
        count: 11
    }

    readonly property
    var transmissionShaftSpeedSensorPulseCount: [
        registry.addParam(MemoryRange.S32, paramId.transmission_shaft_1_speed_sensor_pulse_count, true, true, slots.count3),
        registry.addParam(MemoryRange.S32, paramId.transmission_shaft_2_speed_sensor_pulse_count, true, true, slots.count3),
        registry.addParam(MemoryRange.S32, paramId.transmission_shaft_3_speed_sensor_pulse_count, true, true, slots.count3),
        registry.addParam(MemoryRange.S32, paramId.transmission_shaft_4_speed_sensor_pulse_count, true, true, slots.count3),
        registry.addParam(MemoryRange.S32, paramId.transmission_shaft_5_speed_sensor_pulse_count, true, true, slots.count3),
        registry.addParam(MemoryRange.S32, paramId.transmission_shaft_6_speed_sensor_pulse_count, true, true, slots.count3)
    ]

    readonly property
    var transmissionClutchFillTimeArray: [
        registry.addParam(MemoryRange.S32, paramId.transmission_clutch_1_fill_time, true, true, slots.timeMilliseconds1),
        registry.addParam(MemoryRange.S32, paramId.transmission_clutch_2_fill_time, true, true, slots.timeMilliseconds1),
        registry.addParam(MemoryRange.S32, paramId.transmission_clutch_3_fill_time, true, true, slots.timeMilliseconds1),
        registry.addParam(MemoryRange.S32, paramId.transmission_clutch_4_fill_time, true, true, slots.timeMilliseconds1),
        registry.addParam(MemoryRange.S32, paramId.transmission_clutch_5_fill_time, true, true, slots.timeMilliseconds1),
        registry.addParam(MemoryRange.S32, paramId.transmission_clutch_6_fill_time, true, true, slots.timeMilliseconds1),
        registry.addParam(MemoryRange.S32, paramId.transmission_clutch_7_fill_time, true, true, slots.timeMilliseconds1),
        registry.addParam(MemoryRange.S32, paramId.transmission_clutch_8_fill_time, true, true, slots.timeMilliseconds1)
    ]
    property
    list<TableMapperModel> transmissionClutchFillTime: [
        TableMapperModel { mapping: { "x": pressureAxisModel, "value": transmissionClutchFillTimeArray[0].stringModel } },
        TableMapperModel { mapping: { "x": pressureAxisModel, "value": transmissionClutchFillTimeArray[1].stringModel } },
        TableMapperModel { mapping: { "x": pressureAxisModel, "value": transmissionClutchFillTimeArray[2].stringModel } },
        TableMapperModel { mapping: { "x": pressureAxisModel, "value": transmissionClutchFillTimeArray[3].stringModel } },
        TableMapperModel { mapping: { "x": pressureAxisModel, "value": transmissionClutchFillTimeArray[4].stringModel } },
        TableMapperModel { mapping: { "x": pressureAxisModel, "value": transmissionClutchFillTimeArray[5].stringModel } },
        TableMapperModel { mapping: { "x": pressureAxisModel, "value": transmissionClutchFillTimeArray[6].stringModel } },
        TableMapperModel { mapping: { "x": pressureAxisModel, "value": transmissionClutchFillTimeArray[7].stringModel } }
    ]

    readonly property Param transmissionClutchEmptyTimeArray: [
        registry.addParam(MemoryRange.S32, paramId.transmission_clutch_1_empty_time, true, true, slots.timeMilliseconds1),
        registry.addParam(MemoryRange.S32, paramId.transmission_clutch_2_empty_time, true, true, slots.timeMilliseconds1),
        registry.addParam(MemoryRange.S32, paramId.transmission_clutch_3_empty_time, true, true, slots.timeMilliseconds1),
        registry.addParam(MemoryRange.S32, paramId.transmission_clutch_4_empty_time, true, true, slots.timeMilliseconds1),
        registry.addParam(MemoryRange.S32, paramId.transmission_clutch_5_empty_time, true, true, slots.timeMilliseconds1),
        registry.addParam(MemoryRange.S32, paramId.transmission_clutch_6_empty_time, true, true, slots.timeMilliseconds1),
        registry.addParam(MemoryRange.S32, paramId.transmission_clutch_7_empty_time, true, true, slots.timeMilliseconds1),
        registry.addParam(MemoryRange.S32, paramId.transmission_clutch_8_empty_time, true, true, slots.timeMilliseconds1)
    ]
    property
    list<TableMapperModel> transmissionClutchEmptyTime: [
        TableMapperModel { mapping: { "x": pressureAxisModel, "value": transmissionClutchEmptyTimeArray[0].stringModel } },
        TableMapperModel { mapping: { "x": pressureAxisModel, "value": transmissionClutchEmptyTimeArray[1].stringModel } },
        TableMapperModel { mapping: { "x": pressureAxisModel, "value": transmissionClutchEmptyTimeArray[2].stringModel } },
        TableMapperModel { mapping: { "x": pressureAxisModel, "value": transmissionClutchEmptyTimeArray[3].stringModel } },
        TableMapperModel { mapping: { "x": pressureAxisModel, "value": transmissionClutchEmptyTimeArray[4].stringModel } },
        TableMapperModel { mapping: { "x": pressureAxisModel, "value": transmissionClutchEmptyTimeArray[5].stringModel } },
        TableMapperModel { mapping: { "x": pressureAxisModel, "value": transmissionClutchEmptyTimeArray[6].stringModel } },
        TableMapperModel { mapping: { "x": pressureAxisModel, "value": transmissionClutchEmptyTimeArray[7].stringModel } }
    ]

    readonly property Param transmissionShiftPrefillTimeArray: registry.addParam(MemoryRange.S32, paramId.transmission_shift_prefill_time, true, true, slots.timeMilliseconds1)
    property TableMapperModel transmissionShiftPrefillTime: TableMapperModel { mapping: { "x" : upshiftDownshiftAxisModel, "value": transmissionShiftPrefillTimeArray } }

    readonly property Param transmissionShiftPrefillPercentageArray: registry.addParam(MemoryRange.S32, paramId.transmission_shift_prefill_percentage, true, true, slots.percentage1)
    property TableMapperModel transmissionShiftPrefillPercentage: TableMapperModel { mapping: { "x" : upshiftDownshiftAxisModel, "value": transmissionShiftPrefillPercentageArray } }

    readonly property Param transmissionShiftPrefillPressureArray: registry.addParam(MemoryRange.S32, paramId.transmission_shift_prefill_pressure, true, true, slots.pressure)
    property TableMapperModel transmissionShiftPrefillPressure: TableMapperModel { mapping: { "x" : upshiftDownshiftAxisModel, "value": transmissionShiftPrefillPressureArray } }

    readonly property Param transmissionShiftOverlapPressureArray: registry.addParam(MemoryRange.S32, paramId.transmission_shift_overlap_pressure, true, true, slots.percentage1)
    property TableMapperModel transmissionShiftOverlapPressure: TableMapperModel { mapping: { "x" : upshiftDownshiftAxisModel, "value": transmissionShiftOverlapPressureArray } }

    readonly property Param transmissionTemperaturePressureCompensationArray: registry.addParam(MemoryRange.S32, paramId.transmission_pressure_temperature_compensation, true, true, slots.percentage1)
    property TableMapperModel transmissionTemperaturePressureCompensation: TableMapperModel { mapping: { "x" : tempAxisModel, "value": transmissionTemperaturePressureCompensationArray } }

    readonly property Param transmissionUpshiftApplyPressureArray: [
        registry.addParam(MemoryRange.S32, paramId.transmission_shift_n_1_apply_pressure, pressureAxisModel.count, true, true, slots.pressure),
        registry.addParam(MemoryRange.S32, paramId.transmission_shift_1_2_apply_pressure, pressureAxisModel.count, true, true, slots.pressure),
        registry.addParam(MemoryRange.S32, paramId.transmission_shift_2_3_apply_pressure, pressureAxisModel.count, true, true, slots.pressure),
        registry.addParam(MemoryRange.S32, paramId.transmission_shift_3_4_apply_pressure, pressureAxisModel.count, true, true, slots.pressure),
        registry.addParam(MemoryRange.S32, paramId.transmission_shift_4_5_apply_pressure, pressureAxisModel.count, true, true, slots.pressure),
        registry.addParam(MemoryRange.S32, paramId.transmission_shift_5_6_apply_pressure, pressureAxisModel.count, true, true, slots.pressure),
        registry.addParam(MemoryRange.S32, paramId.transmission_shift_6_7_apply_pressure, pressureAxisModel.count, true, true, slots.pressure),
        registry.addParam(MemoryRange.S32, paramId.transmission_shift_7_8_apply_pressure, pressureAxisModel.count, true, true, slots.pressure)
    ]
    property
    list<TableMapperModel> transmissionUpshiftApplyPressure: [
        TableMapperModel { mapping: { "x": pressureAxisModel, "value": transmissionUpshiftApplyPressureArray[0].stringModel } },
        TableMapperModel { mapping: { "x": pressureAxisModel, "value": transmissionUpshiftApplyPressureArray[1].stringModel } },
        TableMapperModel { mapping: { "x": pressureAxisModel, "value": transmissionUpshiftApplyPressureArray[2].stringModel } },
        TableMapperModel { mapping: { "x": pressureAxisModel, "value": transmissionUpshiftApplyPressureArray[3].stringModel } },
        TableMapperModel { mapping: { "x": pressureAxisModel, "value": transmissionUpshiftApplyPressureArray[4].stringModel } },
        TableMapperModel { mapping: { "x": pressureAxisModel, "value": transmissionUpshiftApplyPressureArray[5].stringModel } },
        TableMapperModel { mapping: { "x": pressureAxisModel, "value": transmissionUpshiftApplyPressureArray[6].stringModel } },
        TableMapperModel { mapping: { "x": pressureAxisModel, "value": transmissionUpshiftApplyPressureArray[7].stringModel } }
    ]

    readonly property Param transmissionDownshiftApplyPressureArray: [
        registry.addParam(MemoryRange.S32, paramId.transmission_shift_2_1_apply_pressure, pressureAxisModel.count, true, true, slots.pressure),
        registry.addParam(MemoryRange.S32, paramId.transmission_shift_3_2_apply_pressure, pressureAxisModel.count, true, true, slots.pressure),
        registry.addParam(MemoryRange.S32, paramId.transmission_shift_4_3_apply_pressure, pressureAxisModel.count, true, true, slots.pressure),
        registry.addParam(MemoryRange.S32, paramId.transmission_shift_5_4_apply_pressure, pressureAxisModel.count, true, true, slots.pressure),
        registry.addParam(MemoryRange.S32, paramId.transmission_shift_6_5_apply_pressure, pressureAxisModel.count, true, true, slots.pressure),
        registry.addParam(MemoryRange.S32, paramId.transmission_shift_7_6_apply_pressure, pressureAxisModel.count, true, true, slots.pressure),
        registry.addParam(MemoryRange.S32, paramId.transmission_shift_8_7_apply_pressure, pressureAxisModel.count, true, true, slots.pressure),
    ]
    property
    list<TableMapperModel> transmissionDownshiftApplyPressure: [
        TableMapperModel { mapping: { "x": pressureAxisModel, "value": transmissionDownshiftApplyPressureArray[0].stringModel } },
        TableMapperModel { mapping: { "x": pressureAxisModel, "value": transmissionDownshiftApplyPressureArray[1].stringModel } },
        TableMapperModel { mapping: { "x": pressureAxisModel, "value": transmissionDownshiftApplyPressureArray[2].stringModel } },
        TableMapperModel { mapping: { "x": pressureAxisModel, "value": transmissionDownshiftApplyPressureArray[3].stringModel } },
        TableMapperModel { mapping: { "x": pressureAxisModel, "value": transmissionDownshiftApplyPressureArray[4].stringModel } },
        TableMapperModel { mapping: { "x": pressureAxisModel, "value": transmissionDownshiftApplyPressureArray[5].stringModel } },
        TableMapperModel { mapping: { "x": pressureAxisModel, "value": transmissionDownshiftApplyPressureArray[6].stringModel } }
    ]

    readonly property Param transmissionUpshiftReleasePressureArray: [
        registry.addParam(MemoryRange.S32, paramId.transmission_shift_1_2_release_pressure, pressureAxisModel.count, true, true, slots.pressure),
        registry.addParam(MemoryRange.S32, paramId.transmission_shift_2_3_release_pressure, pressureAxisModel.count, true, true, slots.pressure),
        registry.addParam(MemoryRange.S32, paramId.transmission_shift_3_4_release_pressure, pressureAxisModel.count, true, true, slots.pressure),
        registry.addParam(MemoryRange.S32, paramId.transmission_shift_4_5_release_pressure, pressureAxisModel.count, true, true, slots.pressure),
        registry.addParam(MemoryRange.S32, paramId.transmission_shift_5_6_release_pressure, pressureAxisModel.count, true, true, slots.pressure),
        registry.addParam(MemoryRange.S32, paramId.transmission_shift_6_7_release_pressure, pressureAxisModel.count, true, true, slots.pressure),
        registry.addParam(MemoryRange.S32, paramId.transmission_shift_7_8_release_pressure, pressureAxisModel.count, true, true, slots.pressure),
    ]
    property
    list<TableMapperModel> transmissionUpshiftReleasePressure: [
        TableMapperModel { mapping: { "x": pressureAxisModel, "value": transmissionUpshiftReleasePressureArray[0].stringModel } },
        TableMapperModel { mapping: { "x": pressureAxisModel, "value": transmissionUpshiftReleasePressureArray[1].stringModel } },
        TableMapperModel { mapping: { "x": pressureAxisModel, "value": transmissionUpshiftReleasePressureArray[2].stringModel } },
        TableMapperModel { mapping: { "x": pressureAxisModel, "value": transmissionUpshiftReleasePressureArray[3].stringModel } },
        TableMapperModel { mapping: { "x": pressureAxisModel, "value": transmissionUpshiftReleasePressureArray[4].stringModel } },
        TableMapperModel { mapping: { "x": pressureAxisModel, "value": transmissionUpshiftReleasePressureArray[5].stringModel } },
        TableMapperModel { mapping: { "x": pressureAxisModel, "value": transmissionUpshiftReleasePressureArray[6].stringModel } }
    ]

    readonly property Param transmissionDownshiftReleasePressureArray: [
        registry.addParam(MemoryRange.S32, paramId.transmission_shift_2_1_release_pressure, pressureAxisModel.count, true, true, slots.pressure),
        registry.addParam(MemoryRange.S32, paramId.transmission_shift_3_2_release_pressure, pressureAxisModel.count, true, true, slots.pressure),
        registry.addParam(MemoryRange.S32, paramId.transmission_shift_4_3_release_pressure, pressureAxisModel.count, true, true, slots.pressure),
        registry.addParam(MemoryRange.S32, paramId.transmission_shift_5_4_release_pressure, pressureAxisModel.count, true, true, slots.pressure),
        registry.addParam(MemoryRange.S32, paramId.transmission_shift_6_5_release_pressure, pressureAxisModel.count, true, true, slots.pressure),
        registry.addParam(MemoryRange.S32, paramId.transmission_shift_7_6_release_pressure, pressureAxisModel.count, true, true, slots.pressure),
        registry.addParam(MemoryRange.S32, paramId.transmission_shift_8_7_release_pressure, pressureAxisModel.count, true, true, slots.pressure),
    ]
    property
    list<TableMapperModel> transmissionDownshiftReleasePressure: [
        TableMapperModel { mapping: { "x": pressureAxisModel, "value": transmissionDownshiftReleasePressureArray[0].stringModel } },
        TableMapperModel { mapping: { "x": pressureAxisModel, "value": transmissionDownshiftReleasePressureArray[1].stringModel } },
        TableMapperModel { mapping: { "x": pressureAxisModel, "value": transmissionDownshiftReleasePressureArray[2].stringModel } },
        TableMapperModel { mapping: { "x": pressureAxisModel, "value": transmissionDownshiftReleasePressureArray[3].stringModel } },
        TableMapperModel { mapping: { "x": pressureAxisModel, "value": transmissionDownshiftReleasePressureArray[4].stringModel } },
        TableMapperModel { mapping: { "x": pressureAxisModel, "value": transmissionDownshiftReleasePressureArray[5].stringModel } },
        TableMapperModel { mapping: { "x": pressureAxisModel, "value": transmissionDownshiftReleasePressureArray[6].stringModel } }
    ]

    readonly property Param transmissionMainPressureArray: [
        registry.addParam(MemoryRange.S32, paramId.transmission_gear_1_main_pressure, pressureAxisModel.count, true, true, slots.pressure),
        registry.addParam(MemoryRange.S32, paramId.transmission_gear_2_main_pressure, pressureAxisModel.count, true, true, slots.pressure),
        registry.addParam(MemoryRange.S32, paramId.transmission_gear_3_main_pressure, pressureAxisModel.count, true, true, slots.pressure),
        registry.addParam(MemoryRange.S32, paramId.transmission_gear_4_main_pressure, pressureAxisModel.count, true, true, slots.pressure),
        registry.addParam(MemoryRange.S32, paramId.transmission_gear_5_main_pressure, pressureAxisModel.count, true, true, slots.pressure),
        registry.addParam(MemoryRange.S32, paramId.transmission_gear_6_main_pressure, pressureAxisModel.count, true, true, slots.pressure),
        registry.addParam(MemoryRange.S32, paramId.transmission_gear_7_main_pressure, pressureAxisModel.count, true, true, slots.pressure),
        registry.addParam(MemoryRange.S32, paramId.transmission_gear_8_main_pressure, pressureAxisModel.count, true, true, slots.pressure),
    ]
    property
    list<TableMapperModel> transmissionMainPressure: [
        TableMapperModel { mapping: { "x": pressureAxisModel, "value": transmissionMainPressureArray[0].stringModel } },
        TableMapperModel { mapping: { "x": pressureAxisModel, "value": transmissionMainPressureArray[1].stringModel } },
        TableMapperModel { mapping: { "x": pressureAxisModel, "value": transmissionMainPressureArray[2].stringModel } },
        TableMapperModel { mapping: { "x": pressureAxisModel, "value": transmissionMainPressureArray[3].stringModel } },
        TableMapperModel { mapping: { "x": pressureAxisModel, "value": transmissionMainPressureArray[4].stringModel } },
        TableMapperModel { mapping: { "x": pressureAxisModel, "value": transmissionMainPressureArray[5].stringModel } },
        TableMapperModel { mapping: { "x": pressureAxisModel, "value": transmissionMainPressureArray[6].stringModel } },
        TableMapperModel { mapping: { "x": pressureAxisModel, "value": transmissionMainPressureArray[7].stringModel } }
    ]

    readonly property Param transmissionUpshiftApplyPercentageArray: [
        registry.addParam(MemoryRange.S32, paramId.transmission_shift_n_1_apply_percentage, pressureAxisModel.count, true, true, slots.percentage1),
        registry.addParam(MemoryRange.S32, paramId.transmission_shift_1_2_apply_percentage, pressureAxisModel.count, true, true, slots.percentage1),
        registry.addParam(MemoryRange.S32, paramId.transmission_shift_2_3_apply_percentage, pressureAxisModel.count, true, true, slots.percentage1),
        registry.addParam(MemoryRange.S32, paramId.transmission_shift_3_4_apply_percentage, pressureAxisModel.count, true, true, slots.percentage1),
        registry.addParam(MemoryRange.S32, paramId.transmission_shift_4_5_apply_percentage, pressureAxisModel.count, true, true, slots.percentage1),
        registry.addParam(MemoryRange.S32, paramId.transmission_shift_5_6_apply_percentage, pressureAxisModel.count, true, true, slots.percentage1),
        registry.addParam(MemoryRange.S32, paramId.transmission_shift_6_7_apply_percentage, pressureAxisModel.count, true, true, slots.percentage1),
        registry.addParam(MemoryRange.S32, paramId.transmission_shift_7_8_apply_percentage, pressureAxisModel.count, true, true, slots.percentage1),
    ]
    property
    list<TableMapperModel> transmissionUpshiftApplyPercentage: [
        TableMapperModel { mapping: { "x": pressureAxisModel, "value": transmissionUpshiftApplyPercentageArray[0].stringModel } },
        TableMapperModel { mapping: { "x": pressureAxisModel, "value": transmissionUpshiftApplyPercentageArray[1].stringModel } },
        TableMapperModel { mapping: { "x": pressureAxisModel, "value": transmissionUpshiftApplyPercentageArray[2].stringModel } },
        TableMapperModel { mapping: { "x": pressureAxisModel, "value": transmissionUpshiftApplyPercentageArray[3].stringModel } },
        TableMapperModel { mapping: { "x": pressureAxisModel, "value": transmissionUpshiftApplyPercentageArray[4].stringModel } },
        TableMapperModel { mapping: { "x": pressureAxisModel, "value": transmissionUpshiftApplyPercentageArray[5].stringModel } },
        TableMapperModel { mapping: { "x": pressureAxisModel, "value": transmissionUpshiftApplyPercentageArray[6].stringModel } },
        TableMapperModel { mapping: { "x": pressureAxisModel, "value": transmissionUpshiftApplyPercentageArray[7].stringModel } }
    ]

    readonly property Param transmissionDownshiftApplyPercentageArray: [
        registry.addParam(MemoryRange.S32, paramId.transmission_shift_2_1_apply_percentage, pressureAxisModel.count, true, true, slots.percentage1),
        registry.addParam(MemoryRange.S32, paramId.transmission_shift_3_2_apply_percentage, pressureAxisModel.count, true, true, slots.percentage1),
        registry.addParam(MemoryRange.S32, paramId.transmission_shift_4_3_apply_percentage, pressureAxisModel.count, true, true, slots.percentage1),
        registry.addParam(MemoryRange.S32, paramId.transmission_shift_5_4_apply_percentage, pressureAxisModel.count, true, true, slots.percentage1),
        registry.addParam(MemoryRange.S32, paramId.transmission_shift_6_5_apply_percentage, pressureAxisModel.count, true, true, slots.percentage1),
        registry.addParam(MemoryRange.S32, paramId.transmission_shift_7_6_apply_percentage, pressureAxisModel.count, true, true, slots.percentage1),
        registry.addParam(MemoryRange.S32, paramId.transmission_shift_8_7_apply_percentage, pressureAxisModel.count, true, true, slots.percentage1),
    ]
    property
    list<TableMapperModel> transmissionDownshiftApplyPercentage: [
        TableMapperModel { mapping: { "x": pressureAxisModel, "value": transmissionDownshiftApplyPercentageArray[0].stringModel } },
        TableMapperModel { mapping: { "x": pressureAxisModel, "value": transmissionDownshiftApplyPercentageArray[1].stringModel } },
        TableMapperModel { mapping: { "x": pressureAxisModel, "value": transmissionDownshiftApplyPercentageArray[2].stringModel } },
        TableMapperModel { mapping: { "x": pressureAxisModel, "value": transmissionDownshiftApplyPercentageArray[3].stringModel } },
        TableMapperModel { mapping: { "x": pressureAxisModel, "value": transmissionDownshiftApplyPercentageArray[4].stringModel } },
        TableMapperModel { mapping: { "x": pressureAxisModel, "value": transmissionDownshiftApplyPercentageArray[5].stringModel } },
        TableMapperModel { mapping: { "x": pressureAxisModel, "value": transmissionDownshiftApplyPercentageArray[6].stringModel } }
    ]

    readonly property Param transmissionUpshiftReleasePercentageArray: [
        registry.addParam(MemoryRange.S32, paramId.transmission_shift_1_2_release_percentage, pressureAxisModel.count, true, true, slots.percentage1),
        registry.addParam(MemoryRange.S32, paramId.transmission_shift_2_3_release_percentage, pressureAxisModel.count, true, true, slots.percentage1),
        registry.addParam(MemoryRange.S32, paramId.transmission_shift_3_4_release_percentage, pressureAxisModel.count, true, true, slots.percentage1),
        registry.addParam(MemoryRange.S32, paramId.transmission_shift_4_5_release_percentage, pressureAxisModel.count, true, true, slots.percentage1),
        registry.addParam(MemoryRange.S32, paramId.transmission_shift_5_6_release_percentage, pressureAxisModel.count, true, true, slots.percentage1),
        registry.addParam(MemoryRange.S32, paramId.transmission_shift_6_7_release_percentage, pressureAxisModel.count, true, true, slots.percentage1),
        registry.addParam(MemoryRange.S32, paramId.transmission_shift_7_8_release_percentage, pressureAxisModel.count, true, true, slots.percentage1),
    ]
    property
    list<TableMapperModel> transmissionUpshiftReleasePercentage: [
        TableMapperModel { mapping: { "x": pressureAxisModel, "value": transmissionUpshiftReleasePercentageArray[0].stringModel } },
        TableMapperModel { mapping: { "x": pressureAxisModel, "value": transmissionUpshiftReleasePercentageArray[1].stringModel } },
        TableMapperModel { mapping: { "x": pressureAxisModel, "value": transmissionUpshiftReleasePercentageArray[2].stringModel } },
        TableMapperModel { mapping: { "x": pressureAxisModel, "value": transmissionUpshiftReleasePercentageArray[3].stringModel } },
        TableMapperModel { mapping: { "x": pressureAxisModel, "value": transmissionUpshiftReleasePercentageArray[4].stringModel } },
        TableMapperModel { mapping: { "x": pressureAxisModel, "value": transmissionUpshiftReleasePercentageArray[5].stringModel } },
        TableMapperModel { mapping: { "x": pressureAxisModel, "value": transmissionUpshiftReleasePercentageArray[6].stringModel } }
    ]

    readonly property Param transmissionDownshiftReleasePercentageArray: [
        registry.addParam(MemoryRange.S32, paramId.transmission_shift_2_1_release_percentage, pressureAxisModel.count, true, true, slots.percentage1),
        registry.addParam(MemoryRange.S32, paramId.transmission_shift_3_2_release_percentage, pressureAxisModel.count, true, true, slots.percentage1),
        registry.addParam(MemoryRange.S32, paramId.transmission_shift_4_3_release_percentage, pressureAxisModel.count, true, true, slots.percentage1),
        registry.addParam(MemoryRange.S32, paramId.transmission_shift_5_4_release_percentage, pressureAxisModel.count, true, true, slots.percentage1),
        registry.addParam(MemoryRange.S32, paramId.transmission_shift_6_5_release_percentage, pressureAxisModel.count, true, true, slots.percentage1),
        registry.addParam(MemoryRange.S32, paramId.transmission_shift_7_6_release_percentage, pressureAxisModel.count, true, true, slots.percentage1),
        registry.addParam(MemoryRange.S32, paramId.transmission_shift_8_7_release_percentage, pressureAxisModel.count, true, true, slots.percentage1),
    ]
    property
    list<TableMapperModel> transmissionDownshiftReleasePercentage: [
        TableMapperModel { mapping: { "x": pressureAxisModel, "value": transmissionDownshiftReleasePercentageArray[0].stringModel } },
        TableMapperModel { mapping: { "x": pressureAxisModel, "value": transmissionDownshiftReleasePercentageArray[1].stringModel } },
        TableMapperModel { mapping: { "x": pressureAxisModel, "value": transmissionDownshiftReleasePercentageArray[2].stringModel } },
        TableMapperModel { mapping: { "x": pressureAxisModel, "value": transmissionDownshiftReleasePercentageArray[3].stringModel } },
        TableMapperModel { mapping: { "x": pressureAxisModel, "value": transmissionDownshiftReleasePercentageArray[4].stringModel } },
        TableMapperModel { mapping: { "x": pressureAxisModel, "value": transmissionDownshiftReleasePercentageArray[5].stringModel } },
        TableMapperModel { mapping: { "x": pressureAxisModel, "value": transmissionDownshiftReleasePercentageArray[6].stringModel } }
    ]

    readonly property Param transmissionMainPercentageArray: [
        registry.addParam(MemoryRange.S32, paramId.transmission_gear_1_main_percentage, pressureAxisModel.count, true, true, slots.percentage1),
        registry.addParam(MemoryRange.S32, paramId.transmission_gear_2_main_percentage, pressureAxisModel.count, true, true, slots.percentage1),
        registry.addParam(MemoryRange.S32, paramId.transmission_gear_3_main_percentage, pressureAxisModel.count, true, true, slots.percentage1),
        registry.addParam(MemoryRange.S32, paramId.transmission_gear_4_main_percentage, pressureAxisModel.count, true, true, slots.percentage1),
        registry.addParam(MemoryRange.S32, paramId.transmission_gear_5_main_percentage, pressureAxisModel.count, true, true, slots.percentage1),
        registry.addParam(MemoryRange.S32, paramId.transmission_gear_6_main_percentage, pressureAxisModel.count, true, true, slots.percentage1),
        registry.addParam(MemoryRange.S32, paramId.transmission_gear_7_main_percentage, pressureAxisModel.count, true, true, slots.percentage1),
        registry.addParam(MemoryRange.S32, paramId.transmission_gear_8_main_percentage, pressureAxisModel.count, true, true, slots.percentage1),
    ]
    property
    list<TableMapperModel> transmissionMainPercentage: [
        TableMapperModel { mapping: { "x": pressureAxisModel, "value": transmissionMainPercentageArray[0].stringModel } },
        TableMapperModel { mapping: { "x": pressureAxisModel, "value": transmissionMainPercentageArray[1].stringModel } },
        TableMapperModel { mapping: { "x": pressureAxisModel, "value": transmissionMainPercentageArray[2].stringModel } },
        TableMapperModel { mapping: { "x": pressureAxisModel, "value": transmissionMainPercentageArray[3].stringModel } },
        TableMapperModel { mapping: { "x": pressureAxisModel, "value": transmissionMainPercentageArray[4].stringModel } },
        TableMapperModel { mapping: { "x": pressureAxisModel, "value": transmissionMainPercentageArray[5].stringModel } },
        TableMapperModel { mapping: { "x": pressureAxisModel, "value": transmissionMainPercentageArray[6].stringModel } },
        TableMapperModel { mapping: { "x": pressureAxisModel, "value": transmissionMainPercentageArray[7].stringModel } }
    ]

    readonly property Param powertrainType: registry.addParam(MemoryRange.S32, paramId.transmission_type, true, true, slots.transmissionType1)

    readonly property Param pressureR2LBoostA: registry.addParam(MemoryRange.S32, paramId.pressure_r2l_boost_a, true, true, slots.percentage1)

    readonly property Param pressureR2LBoostB: registry.addParam(MemoryRange.S32, paramId.pressure_r2l_boost_b, true, true, slots.percentage1)

    readonly property Param displayColorArray: registry.addParam(MemoryRange.S32, paramId.display_color, true, true, slots.percentage1)
    property TableMapperModel displayColor: TableMapperModel { mapping: { "x" : colorIndexAxisModel, "value": displayColorArray } }

    readonly property Param displayBrightness: registry.addParam(MemoryRange.S32, paramId.display_brightness, true, true, slots.percentage1)

    readonly property Param displayContrast: registry.addParam(MemoryRange.S32, paramId.display_contrast, true, true, slots.percentage1)

    readonly property Param shiftDownshiftOffsetA: registry.addParam(MemoryRange.S32, paramId.shift_downshift_offset_a, true, true, slots.percentage1)

    readonly property Param shiftDownshiftOffsetB: registry.addParam(MemoryRange.S32, paramId.shift_downshift_offset_b, true, true, slots.percentage1)

    readonly property Param engineCylinders: registry.addParam(MemoryRange.S32, paramId.engine_cylinders, true, true, slots.count2)

    readonly property Param engineRunningDetectionSpeed: registry.addParam(MemoryRange.S32, paramId.engine_running_detection_speed, true, true, slots.rpm1)

    readonly property Param engineIdleShutdownTime: registry.addParam(MemoryRange.S32, paramId.engine_idle_shutdown_time, true, true, slots.timeInSecondsZeroIsDisabled)

    readonly property Param engineTorqueMapSpeedsArray: registry.addParam(MemoryRange.S32, paramId.engine_torque_map_speeds, 11, true, true, slots.rpm1)
    readonly property Param engineMotorTorqueMapArray: registry.addParam(MemoryRange.S32, paramId.engine_motor_torque_map, 11, true, true, slots.percentage2)
    readonly property Param engineBrakeTorqueMapArray: registry.addParam(MemoryRange.S32, paramId.engine_braking_torque_map, 11, true, true, slots.percentage2)
    property TableMapperModel engineTorqueMap: TableMapperModel {
        mapping: {
            "rpm" : engineTorqueMapSpeedsArray.stringModel,
            "motoring": engineMotorTorqueMapArray.stringModel,
            "braking": engineBrakeTorqueMapArray.stringModel
        }
    }

    readonly property Param finalDriveRatio: registry.addParam(MemoryRange.S32, paramId.final_drive_ratio, true, true, slots.ratio1)

    readonly property Param can0BaudRate: registry.addParam(MemoryRange.S32, paramId.can0_baud_rate, true, true, slots.kiloBaud)

    readonly property Param can1BaudRate: registry.addParam(MemoryRange.S32, paramId.can1_baud_rate, true, true, slots.kiloBaud)

    readonly property Param j1939TransmissionAddress: registry.addParam(MemoryRange.S32, paramId.j1939_transmission_address, true, true, slots.count3)

    readonly property Param j1939EngineAddress: registry.addParam(MemoryRange.S32, paramId.j1939_engine_address, true, true, slots.count3)

    readonly property Param j1939ShiftSelectorAddress: registry.addParam(MemoryRange.S32, paramId.j1939_shift_selector_address, true, true, slots.count3)

    readonly property Param xcpCTOId: registry.addParam(MemoryRange.S32, paramId.xcp_cto_id, true, true, slots.hex32bit)

    readonly property Param xcpDTOId: registry.addParam(MemoryRange.S32, paramId.xcp_dto_id, true, true, slots.hex32bit)

    readonly property Param shiftManualModeA: registry.addParam(MemoryRange.S32, paramId.shift_manual_mode_a, true, true, slots.booleanManualMode)

    readonly property Param shiftManualModeB: registry.addParam(MemoryRange.S32, paramId.shift_manual_mode_b, true, true, slots.booleanManualMode)

    readonly property Param tccManualModeA: registry.addParam(MemoryRange.S32, paramId.tcc_manual_mode_a, true, true, slots.booleanManualMode)

    readonly property Param tccManualModeB: registry.addParam(MemoryRange.S32, paramId.tcc_manual_mode_b, true, true, slots.booleanManualMode)

    readonly property Param shiftMaxEngineSpeedA: registry.addParam(MemoryRange.S32, paramId.shift_max_engine_speed_a, true, true, slots.rpm1)

    readonly property Param shiftMaxEngineSpeedB: registry.addParam(MemoryRange.S32, paramId.shift_max_engine_speed_b, true, true, slots.rpm1)

    readonly property Param pressureAdjustA: registry.addParam(MemoryRange.S32, paramId.pressure_adjust_a, true, true, slots.percentage1)

    readonly property Param pressureAdjustB: registry.addParam(MemoryRange.S32, paramId.pressure_adjust_b, true, true, slots.percentage1)

    readonly property
    var pressureTablesAArray: [
        registry.addParam(MemoryRange.S32, paramId.pressure_tables_a_1, percentage1AxisModel.count, true, true, slots.percentage1),
        registry.addParam(MemoryRange.S32, paramId.pressure_tables_a_2, percentage1AxisModel.count, true, true, slots.percentage1),
        registry.addParam(MemoryRange.S32, paramId.pressure_tables_a_3, percentage1AxisModel.count, true, true, slots.percentage1),
        registry.addParam(MemoryRange.S32, paramId.pressure_tables_a_4, percentage1AxisModel.count, true, true, slots.percentage1),
        registry.addParam(MemoryRange.S32, paramId.pressure_tables_a_5, percentage1AxisModel.count, true, true, slots.percentage1),
        registry.addParam(MemoryRange.S32, paramId.pressure_tables_a_6, percentage1AxisModel.count, true, true, slots.percentage1)
    ]
    property
    list<TableMapperModel> pressureTablesA: [
        TableMapperModel { mapping: { "x": percentage1AxisModel, "value": pressureTablesAArray[0].stringModel } },
        TableMapperModel { mapping: { "x": percentage1AxisModel, "value": pressureTablesAArray[1].stringModel } },
        TableMapperModel { mapping: { "x": percentage1AxisModel, "value": pressureTablesAArray[2].stringModel } },
        TableMapperModel { mapping: { "x": percentage1AxisModel, "value": pressureTablesAArray[3].stringModel } },
        TableMapperModel { mapping: { "x": percentage1AxisModel, "value": pressureTablesAArray[4].stringModel } },
        TableMapperModel { mapping: { "x": percentage1AxisModel, "value": pressureTablesAArray[5].stringModel } }
    ]

    readonly property
    var pressureTablesB: [
        registry.addParam(MemoryRange.S32, paramId.pressure_tables_b_1, percentage1AxisModel.count, true, true, slots.percentage1),
        registry.addParam(MemoryRange.S32, paramId.pressure_tables_b_2, percentage1AxisModel.count, true, true, slots.percentage1),
        registry.addParam(MemoryRange.S32, paramId.pressure_tables_b_3, percentage1AxisModel.count, true, true, slots.percentage1),
        registry.addParam(MemoryRange.S32, paramId.pressure_tables_b_4, percentage1AxisModel.count, true, true, slots.percentage1),
        registry.addParam(MemoryRange.S32, paramId.pressure_tables_b_5, percentage1AxisModel.count, true, true, slots.percentage1),
        registry.addParam(MemoryRange.S32, paramId.pressure_tables_b_6, percentage1AxisModel.count, true, true, slots.percentage1)
    ]
    property
    list<TableMapperModel> pressureTablesB: [
        TableMapperModel { mapping: { "x": percentage1AxisModel, "value": pressureTablesBArray[0].stringModel } },
        TableMapperModel { mapping: { "x": percentage1AxisModel, "value": pressureTablesBArray[1].stringModel } },
        TableMapperModel { mapping: { "x": percentage1AxisModel, "value": pressureTablesBArray[2].stringModel } },
        TableMapperModel { mapping: { "x": percentage1AxisModel, "value": pressureTablesBArray[3].stringModel } },
        TableMapperModel { mapping: { "x": percentage1AxisModel, "value": pressureTablesBArray[4].stringModel } },
        TableMapperModel { mapping: { "x": percentage1AxisModel, "value": pressureTablesBArray[5].stringModel } }
    ]

    readonly property Param shiftSpeedAdjustA: registry.addParam(MemoryRange.S32, paramId.shift_speed_adjust_a, true, true, slots.percentage1)

    readonly property Param shiftSpeedAdjustB: registry.addParam(MemoryRange.S32, paramId.shift_speed_adjust_b, true, true, slots.percentage1)

    readonly property
    var shiftTablesAArray: [
        registry.addParam(MemoryRange.S32, paramId.shift_tables_a_1, percentage1AxisModel.count, true, true, slots.tossRPMAsSpeed, slots.percentage1),
        registry.addParam(MemoryRange.S32, paramId.shift_tables_a_2, percentage1AxisModel.count, true, true, slots.tossRPMAsSpeed, slots.percentage1),
        registry.addParam(MemoryRange.S32, paramId.shift_tables_a_3, percentage1AxisModel.count, true, true, slots.tossRPMAsSpeed, slots.percentage1),
        registry.addParam(MemoryRange.S32, paramId.shift_tables_a_4, percentage1AxisModel.count, true, true, slots.tossRPMAsSpeed, slots.percentage1),
        registry.addParam(MemoryRange.S32, paramId.shift_tables_a_5, percentage1AxisModel.count, true, true, slots.tossRPMAsSpeed, slots.percentage1)
    ]
    property
    list<TableMapperModel> shiftTablesA: [
        TableMapperModel { mapping: { "x": percentage1AxisModel, "value": shiftTablesAArray[0].stringModel } },
        TableMapperModel { mapping: { "x": percentage1AxisModel, "value": shiftTablesAArray[1].stringModel } },
        TableMapperModel { mapping: { "x": percentage1AxisModel, "value": shiftTablesAArray[2].stringModel } },
        TableMapperModel { mapping: { "x": percentage1AxisModel, "value": shiftTablesAArray[3].stringModel } },
        TableMapperModel { mapping: { "x": percentage1AxisModel, "value": shiftTablesAArray[4].stringModel } }
    ]

    readonly property
    var shiftTablesBArray: [
        registry.addParam(MemoryRange.S32, paramId.shift_tables_b_1, percentage1AxisModel.count, true, true, slots.tossRPMAsSpeed, slots.percentage1),
        registry.addParam(MemoryRange.S32, paramId.shift_tables_b_2, percentage1AxisModel.count, true, true, slots.tossRPMAsSpeed, slots.percentage1),
        registry.addParam(MemoryRange.S32, paramId.shift_tables_b_3, percentage1AxisModel.count, true, true, slots.tossRPMAsSpeed, slots.percentage1),
        registry.addParam(MemoryRange.S32, paramId.shift_tables_b_4, percentage1AxisModel.count, true, true, slots.tossRPMAsSpeed, slots.percentage1),
        registry.addParam(MemoryRange.S32, paramId.shift_tables_b_5, percentage1AxisModel.count, true, true, slots.tossRPMAsSpeed, slots.percentage1)
    ]
    property
    list<TableMapperModel> shiftTablesB: [
        TableMapperModel { mapping: { "x": percentage1AxisModel, "value": shiftTablesBArray[0].stringModel } },
        TableMapperModel { mapping: { "x": percentage1AxisModel, "value": shiftTablesBArray[1].stringModel } },
        TableMapperModel { mapping: { "x": percentage1AxisModel, "value": shiftTablesBArray[2].stringModel } },
        TableMapperModel { mapping: { "x": percentage1AxisModel, "value": shiftTablesBArray[3].stringModel } },
        TableMapperModel { mapping: { "x": percentage1AxisModel, "value": shiftTablesBArray[4].stringModel } }
    ]

    readonly property Param tccDisableTOSSPercentA: registry.addParam(MemoryRange.S32, paramId.tcc_disable_toss_percent_a, true, true, slots.percentage1)

    readonly property Param tccDisableTOSSPercentB: registry.addParam(MemoryRange.S32, paramId.tcc_disable_toss_percent_b, true, true, slots.percentage1)

    readonly property Param tccEnableGearA: registry.addParam(MemoryRange.S32, paramId.tcc_enable_gear_a, true, true, slots.gear1)

    readonly property Param tccEnableGearB: registry.addParam(MemoryRange.S32, paramId.tcc_enable_gear_b, true, true, slots.gear1)

    readonly property Param tccEnableTOSSA: registry.addParam(MemoryRange.S32, paramId.tcc_enable_toss_a, true, true, slots.tossRPMAsSpeed)

    readonly property Param tccEnableTOSSB: registry.addParam(MemoryRange.S32, paramId.tcc_enable_toss_b, true, true, slots.tossRPMAsSpeed)

    readonly property Param tccMaxThrottleA: registry.addParam(MemoryRange.S32, paramId.tcc_max_throttle_a, true, true, slots.percentage1)

    readonly property Param tccMaxThrottleB: registry.addParam(MemoryRange.S32, paramId.tcc_max_throttle_b, true, true, slots.percentage1)

    readonly property Param tccMinThrottleA: registry.addParam(MemoryRange.S32, paramId.tcc_min_throttle_a, true, true, slots.percentage1)

    readonly property Param tccMinThrottleB: registry.addParam(MemoryRange.S32, paramId.tcc_min_throttle_b, true, true, slots.percentage1)

    readonly property Param tccPrefillPressure: registry.addParam(MemoryRange.S32, paramId.tcc_prefill_pressure, true, true, slots.percentage1)

    readonly property Param tccPrefillTime: registry.addParam(MemoryRange.S32, paramId.tcc_prefill_time, true, true, slots.timeMilliseconds1)

    readonly property Param tccApplyPressure: registry.addParam(MemoryRange.S32, paramId.tcc_apply_pressure, true, true, slots.percentage1, slots.count)

    readonly property Param tireDiameter: registry.addParam(MemoryRange.S32, paramId.tire_diameter, true, true, slots.length)

    readonly property Param transferCaseRatio: registry.addParam(MemoryRange.S32, paramId.transfer_case_ratio, true, true, slots.ratio1)

    readonly property Param vehicleMass: registry.addParam(MemoryRange.S32, paramId.vehicle_mass, true, true, slots.mass)

    readonly property Param voltageTPSIsReversed: registry.addParam(MemoryRange.S32, paramId.voltage_tps_is_reversed, true, true, slots.booleanNormalReversed)

    readonly property Param voltageTPSCalibrationHigh: registry.addParam(MemoryRange.S32, paramId.voltage_tps_calibration_high, true, true, slots.voltage1)

    readonly property Param voltageTPSCalibrationLow: registry.addParam(MemoryRange.S32, paramId.voltage_tps_calibration_low, true, true, slots.voltage1)

    readonly property Param voltageTPSGroundEnable: registry.addParam(MemoryRange.S32, paramId.voltage_tps_ground_enable, true, true, slots.booleanOnOff1)

    readonly property Param voltageTPSFilterOrder: registry.addParam(MemoryRange.S32, paramId.voltage_tps_filter_order, true, true, slots.timeMilliseconds1)

    readonly property Param voltageMAPSensorHighCalibration: registry.addParam(MemoryRange.S32, paramId.voltage_map_sensor_high_calibration, true, true, slots.voltage1)

    readonly property Param voltageMAPSensorLowCalibration: registry.addParam(MemoryRange.S32, paramId.voltage_map_sensor_low_calibration, true, true, slots.voltage1)

    readonly property Param voltageMAPSensorGroundEnable: registry.addParam(MemoryRange.S32, paramId.voltage_map_sensor_ground_enable, true, true, slots.booleanOnOff1)

    readonly property Param transmissionTempBiasEnable: registry.addParam(MemoryRange.S32, paramId.transmission_temp_bias_enable, true, true, slots.booleanOnOff1)

    readonly property Param transmissionHasLinePressureSensor: registry.addParam(MemoryRange.S32, paramId.transmission_main_pressure_sensor_present, true, true, slots.booleanOnOff1)

    readonly property Param transmissionHasLinePressureControl: registry.addParam(MemoryRange.S32, paramId.transmission_has_line_pressure_control, true, true, slots.booleanYesNo1)

    readonly property Param transmissionHasAccumulatorControl: registry.addParam(MemoryRange.S32, paramId.transmission_has_accumulator_control, true, true,
        slots.booleanYesNo1)

    readonly property Param transmissionHasPWMTCC: registry.addParam(MemoryRange.S32, paramId.transmission_has_pwm_tcc, true, true, slots.booleanYesNo1)

    readonly property Param cs2EngineTempBiasEnable: registry.addParam(MemoryRange.S32, paramId.cs2_engine_temp_bias_enable, true, true, slots.booleanOnOff1)

    readonly property Param pressureControlSource: registry.addParam(MemoryRange.S32, paramId.pressure_control_source, true, true, slots.torqueSignalSource)

    readonly property Param shiftSelectorGearVoltagesArray: registry.addParam(MemoryRange.S32, paramId.shift_selector_gear_voltages, hgmShiftSelectorCalibrationGearAxisModel.count, true, true, slots.hgmShiftSelectorCalibrationSensorVoltage)
    property TableMapperModel shiftSelectorGearVoltages: TableMapperModel { mapping: { "x" : hgmShiftSelectorCalibrationGearAxisModel, "value": shiftSelectorGearVoltagesArray } }

    readonly property Param shiftSelectorODCancelAtStartup: registry.addParam(MemoryRange.S32, paramId.shift_selector_overdrive_cancel_at_startup, true, true, slots.booleanOnOff1)

    readonly property Param useMetricUnits: registry.addParam(MemoryRange.S32, paramId.use_metric_units, true, true, slots.measurementSystem)

    readonly property Param speedometerCalibration: registry.addParam(MemoryRange.S32, paramId.speedometer_calibration, true, true, slots.speedoCalibration)

    readonly property Param startInhibitRelayType: registry.addParam(MemoryRange.S32, paramId.start_inhibit_relay_type, true, true, slots.booleanNormalReversed)

    readonly property Param vehicleSpeedSensorPulseCount: registry.addParam(MemoryRange.S32, paramId.vehicle_speed_sensor_pulse_count, true, true, slots.count3)
}
