import QtQuick 2.5
import com.hgmelectronics.setuptools.xcp 1.0
import com.hgmelectronics.setuptools 1.0

QtObject {
    id: parameters
    property ParamRegistry registry;
    property ParamId paramId: ParamId {}
    property Slots slots: Slots {
        useMetricUnits: parameters.useMetricUnits.floatVal !== 0 ? true : false
        tireDiameter: parameters.tireDiameter.floatVal
        finalDriveRatio: parameters.finalDriveRatio.floatVal
    }

    readonly property ScalarParam transmissionTurbineShaftSpeedSensorPulseCount: registry.addScalarParam(MemoryRange.S32, paramId.transmission_turbine_shaft_speed_sensor_pulse_count, true, true, slots.count3)

    readonly property ScalarParam transmissionInputShaftSpeedSensorPulseCount: registry.addScalarParam(MemoryRange.S32, paramId.transmission_input_shaft_speed_sensor_pulse_count, true, true, slots.count3)

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
//        count: 14
//  temporary fix for NAG1.
        count: 12
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
    property SlotArrayModel slipAxisModel: SlotArrayModel {
        slot: slots.count
        count: 16
    }

    readonly property
    var transmissionShaftSpeedSensorPulseCount: [
        registry.addScalarParam(MemoryRange.S32, paramId.transmission_shaft_1_speed_sensor_pulse_count, true, true, slots.count3),
        registry.addScalarParam(MemoryRange.S32, paramId.transmission_shaft_2_speed_sensor_pulse_count, true, true, slots.count3),
        registry.addScalarParam(MemoryRange.S32, paramId.transmission_shaft_3_speed_sensor_pulse_count, true, true, slots.count3),
        registry.addScalarParam(MemoryRange.S32, paramId.transmission_shaft_4_speed_sensor_pulse_count, true, true, slots.count3),
        registry.addScalarParam(MemoryRange.S32, paramId.transmission_shaft_5_speed_sensor_pulse_count, true, true, slots.count3),
        registry.addScalarParam(MemoryRange.S32, paramId.transmission_shaft_6_speed_sensor_pulse_count, true, true, slots.count3)
    ]

    readonly property
    var transmissionClutchFillTimeArray: [
        registry.addArrayParam(MemoryRange.S32, paramId.transmission_clutch_1_fill_time, pressureAxisModel.count, true, true, slots.timeMilliseconds1),
        registry.addArrayParam(MemoryRange.S32, paramId.transmission_clutch_2_fill_time, pressureAxisModel.count, true, true, slots.timeMilliseconds1),
        registry.addArrayParam(MemoryRange.S32, paramId.transmission_clutch_3_fill_time, pressureAxisModel.count, true, true, slots.timeMilliseconds1),
        registry.addArrayParam(MemoryRange.S32, paramId.transmission_clutch_4_fill_time, pressureAxisModel.count, true, true, slots.timeMilliseconds1),
        registry.addArrayParam(MemoryRange.S32, paramId.transmission_clutch_5_fill_time, pressureAxisModel.count, true, true, slots.timeMilliseconds1),
        registry.addArrayParam(MemoryRange.S32, paramId.transmission_clutch_6_fill_time, pressureAxisModel.count, true, true, slots.timeMilliseconds1),
        registry.addArrayParam(MemoryRange.S32, paramId.transmission_clutch_7_fill_time, pressureAxisModel.count, true, true, slots.timeMilliseconds1),
        registry.addArrayParam(MemoryRange.S32, paramId.transmission_clutch_8_fill_time, pressureAxisModel.count, true, true, slots.timeMilliseconds1)
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

    readonly property
    var transmissionClutchEmptyTimeArray: [
        registry.addArrayParam(MemoryRange.S32, paramId.transmission_clutch_1_empty_time, pressureAxisModel.count, true, true, slots.timeMilliseconds1),
        registry.addArrayParam(MemoryRange.S32, paramId.transmission_clutch_2_empty_time, pressureAxisModel.count, true, true, slots.timeMilliseconds1),
        registry.addArrayParam(MemoryRange.S32, paramId.transmission_clutch_3_empty_time, pressureAxisModel.count, true, true, slots.timeMilliseconds1),
        registry.addArrayParam(MemoryRange.S32, paramId.transmission_clutch_4_empty_time, pressureAxisModel.count, true, true, slots.timeMilliseconds1),
        registry.addArrayParam(MemoryRange.S32, paramId.transmission_clutch_5_empty_time, pressureAxisModel.count, true, true, slots.timeMilliseconds1),
        registry.addArrayParam(MemoryRange.S32, paramId.transmission_clutch_6_empty_time, pressureAxisModel.count, true, true, slots.timeMilliseconds1),
        registry.addArrayParam(MemoryRange.S32, paramId.transmission_clutch_7_empty_time, pressureAxisModel.count, true, true, slots.timeMilliseconds1),
        registry.addArrayParam(MemoryRange.S32, paramId.transmission_clutch_8_empty_time, pressureAxisModel.count, true, true, slots.timeMilliseconds1)
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

    readonly property ArrayParam transmissionShiftPrefillTimeArray: registry.addArrayParam(MemoryRange.S32, paramId.transmission_shift_prefill_time, upshiftDownshiftAxisModel.count, true, true, slots.timeMilliseconds1)
    property TableMapperModel transmissionShiftPrefillTime: TableMapperModel { mapping: { "x" : upshiftDownshiftAxisModel, "value": transmissionShiftPrefillTimeArray.stringModel } }

    readonly property ArrayParam transmissionShiftPrefillPercentageArray: registry.addArrayParam(MemoryRange.S32, paramId.transmission_shift_prefill_percentage, upshiftDownshiftAxisModel.count, true, true, slots.percentage1)
    property TableMapperModel transmissionShiftPrefillPercentage: TableMapperModel { mapping: { "x" : upshiftDownshiftAxisModel, "value": transmissionShiftPrefillPercentageArray.stringModel } }

    readonly property ArrayParam transmissionShiftPrefillPressureArray: registry.addArrayParam(MemoryRange.S32, paramId.transmission_shift_prefill_pressure, upshiftDownshiftAxisModel.count, true, true, slots.pressure)
    property TableMapperModel transmissionShiftPrefillPressure: TableMapperModel { mapping: { "x" : upshiftDownshiftAxisModel, "value": transmissionShiftPrefillPressureArray.stringModel } }

    readonly property ArrayParam transmissionShiftOverlapPressureArray: registry.addArrayParam(MemoryRange.S32, paramId.transmission_shift_overlap_pressure, upshiftDownshiftAxisModel.count, true, true, slots.percentage1)
    property TableMapperModel transmissionShiftOverlapPressure: TableMapperModel { mapping: { "x" : upshiftDownshiftAxisModel, "value": transmissionShiftOverlapPressureArray.stringModel } }

    readonly property ArrayParam transmissionTemperaturePressureCompensationArray: registry.addArrayParam(MemoryRange.S32, paramId.transmission_pressure_temperature_compensation, tempAxisModel.count, true, true, slots.percentage1)
    property TableMapperModel transmissionTemperaturePressureCompensation: TableMapperModel { mapping: { "x" : tempAxisModel, "value": transmissionTemperaturePressureCompensationArray.stringModel } }

    readonly property
    var transmissionUpshiftApplyPressureArray: [
        registry.addArrayParam(MemoryRange.S32, paramId.transmission_shift_n_1_apply_pressure, pressureAxisModel.count, true, true, slots.pressure),
        registry.addArrayParam(MemoryRange.S32, paramId.transmission_shift_1_2_apply_pressure, pressureAxisModel.count, true, true, slots.pressure),
        registry.addArrayParam(MemoryRange.S32, paramId.transmission_shift_2_3_apply_pressure, pressureAxisModel.count, true, true, slots.pressure),
        registry.addArrayParam(MemoryRange.S32, paramId.transmission_shift_3_4_apply_pressure, pressureAxisModel.count, true, true, slots.pressure),
        registry.addArrayParam(MemoryRange.S32, paramId.transmission_shift_4_5_apply_pressure, pressureAxisModel.count, true, true, slots.pressure),
        registry.addArrayParam(MemoryRange.S32, paramId.transmission_shift_5_6_apply_pressure, pressureAxisModel.count, true, true, slots.pressure),
        registry.addArrayParam(MemoryRange.S32, paramId.transmission_shift_6_7_apply_pressure, pressureAxisModel.count, true, true, slots.pressure),
        registry.addArrayParam(MemoryRange.S32, paramId.transmission_shift_7_8_apply_pressure, pressureAxisModel.count, true, true, slots.pressure)
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

    readonly property
    var transmissionDownshiftApplyPressureArray: [
        registry.addArrayParam(MemoryRange.S32, paramId.transmission_shift_2_1_apply_pressure, pressureAxisModel.count, true, true, slots.pressure),
        registry.addArrayParam(MemoryRange.S32, paramId.transmission_shift_3_2_apply_pressure, pressureAxisModel.count, true, true, slots.pressure),
        registry.addArrayParam(MemoryRange.S32, paramId.transmission_shift_4_3_apply_pressure, pressureAxisModel.count, true, true, slots.pressure),
        registry.addArrayParam(MemoryRange.S32, paramId.transmission_shift_5_4_apply_pressure, pressureAxisModel.count, true, true, slots.pressure),
        registry.addArrayParam(MemoryRange.S32, paramId.transmission_shift_6_5_apply_pressure, pressureAxisModel.count, true, true, slots.pressure),
        registry.addArrayParam(MemoryRange.S32, paramId.transmission_shift_7_6_apply_pressure, pressureAxisModel.count, true, true, slots.pressure),
        registry.addArrayParam(MemoryRange.S32, paramId.transmission_shift_8_7_apply_pressure, pressureAxisModel.count, true, true, slots.pressure),
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

    readonly property
    var transmissionUpshiftReleasePressureArray: [
        registry.addArrayParam(MemoryRange.S32, paramId.transmission_shift_1_2_release_pressure, pressureAxisModel.count, true, true, slots.pressure),
        registry.addArrayParam(MemoryRange.S32, paramId.transmission_shift_2_3_release_pressure, pressureAxisModel.count, true, true, slots.pressure),
        registry.addArrayParam(MemoryRange.S32, paramId.transmission_shift_3_4_release_pressure, pressureAxisModel.count, true, true, slots.pressure),
        registry.addArrayParam(MemoryRange.S32, paramId.transmission_shift_4_5_release_pressure, pressureAxisModel.count, true, true, slots.pressure),
        registry.addArrayParam(MemoryRange.S32, paramId.transmission_shift_5_6_release_pressure, pressureAxisModel.count, true, true, slots.pressure),
        registry.addArrayParam(MemoryRange.S32, paramId.transmission_shift_6_7_release_pressure, pressureAxisModel.count, true, true, slots.pressure),
        registry.addArrayParam(MemoryRange.S32, paramId.transmission_shift_7_8_release_pressure, pressureAxisModel.count, true, true, slots.pressure),
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

    readonly property
    var transmissionDownshiftReleasePressureArray: [
        registry.addArrayParam(MemoryRange.S32, paramId.transmission_shift_2_1_release_pressure, pressureAxisModel.count, true, true, slots.pressure),
        registry.addArrayParam(MemoryRange.S32, paramId.transmission_shift_3_2_release_pressure, pressureAxisModel.count, true, true, slots.pressure),
        registry.addArrayParam(MemoryRange.S32, paramId.transmission_shift_4_3_release_pressure, pressureAxisModel.count, true, true, slots.pressure),
        registry.addArrayParam(MemoryRange.S32, paramId.transmission_shift_5_4_release_pressure, pressureAxisModel.count, true, true, slots.pressure),
        registry.addArrayParam(MemoryRange.S32, paramId.transmission_shift_6_5_release_pressure, pressureAxisModel.count, true, true, slots.pressure),
        registry.addArrayParam(MemoryRange.S32, paramId.transmission_shift_7_6_release_pressure, pressureAxisModel.count, true, true, slots.pressure),
        registry.addArrayParam(MemoryRange.S32, paramId.transmission_shift_8_7_release_pressure, pressureAxisModel.count, true, true, slots.pressure),
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

    readonly property
    var transmissionMainPressureArray: [
        registry.addArrayParam(MemoryRange.S32, paramId.transmission_gear_1_main_pressure, pressureAxisModel.count, true, true, slots.pressure),
        registry.addArrayParam(MemoryRange.S32, paramId.transmission_gear_2_main_pressure, pressureAxisModel.count, true, true, slots.pressure),
        registry.addArrayParam(MemoryRange.S32, paramId.transmission_gear_3_main_pressure, pressureAxisModel.count, true, true, slots.pressure),
        registry.addArrayParam(MemoryRange.S32, paramId.transmission_gear_4_main_pressure, pressureAxisModel.count, true, true, slots.pressure),
        registry.addArrayParam(MemoryRange.S32, paramId.transmission_gear_5_main_pressure, pressureAxisModel.count, true, true, slots.pressure),
        registry.addArrayParam(MemoryRange.S32, paramId.transmission_gear_6_main_pressure, pressureAxisModel.count, true, true, slots.pressure),
        registry.addArrayParam(MemoryRange.S32, paramId.transmission_gear_7_main_pressure, pressureAxisModel.count, true, true, slots.pressure),
        registry.addArrayParam(MemoryRange.S32, paramId.transmission_gear_8_main_pressure, pressureAxisModel.count, true, true, slots.pressure),
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

    readonly property
    var transmissionUpshiftApplyPercentageArray: [
        registry.addArrayParam(MemoryRange.S32, paramId.transmission_shift_n_1_apply_percentage, pressureAxisModel.count, true, true, slots.percentage1),
        registry.addArrayParam(MemoryRange.S32, paramId.transmission_shift_1_2_apply_percentage, pressureAxisModel.count, true, true, slots.percentage1),
        registry.addArrayParam(MemoryRange.S32, paramId.transmission_shift_2_3_apply_percentage, pressureAxisModel.count, true, true, slots.percentage1),
        registry.addArrayParam(MemoryRange.S32, paramId.transmission_shift_3_4_apply_percentage, pressureAxisModel.count, true, true, slots.percentage1),
        registry.addArrayParam(MemoryRange.S32, paramId.transmission_shift_4_5_apply_percentage, pressureAxisModel.count, true, true, slots.percentage1),
        registry.addArrayParam(MemoryRange.S32, paramId.transmission_shift_5_6_apply_percentage, pressureAxisModel.count, true, true, slots.percentage1),
        registry.addArrayParam(MemoryRange.S32, paramId.transmission_shift_6_7_apply_percentage, pressureAxisModel.count, true, true, slots.percentage1),
        registry.addArrayParam(MemoryRange.S32, paramId.transmission_shift_7_8_apply_percentage, pressureAxisModel.count, true, true, slots.percentage1),
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

    readonly property
    var transmissionDownshiftApplyPercentageArray: [
        registry.addArrayParam(MemoryRange.S32, paramId.transmission_shift_2_1_apply_percentage, pressureAxisModel.count, true, true, slots.percentage1),
        registry.addArrayParam(MemoryRange.S32, paramId.transmission_shift_3_2_apply_percentage, pressureAxisModel.count, true, true, slots.percentage1),
        registry.addArrayParam(MemoryRange.S32, paramId.transmission_shift_4_3_apply_percentage, pressureAxisModel.count, true, true, slots.percentage1),
        registry.addArrayParam(MemoryRange.S32, paramId.transmission_shift_5_4_apply_percentage, pressureAxisModel.count, true, true, slots.percentage1),
        registry.addArrayParam(MemoryRange.S32, paramId.transmission_shift_6_5_apply_percentage, pressureAxisModel.count, true, true, slots.percentage1),
        registry.addArrayParam(MemoryRange.S32, paramId.transmission_shift_7_6_apply_percentage, pressureAxisModel.count, true, true, slots.percentage1),
        registry.addArrayParam(MemoryRange.S32, paramId.transmission_shift_8_7_apply_percentage, pressureAxisModel.count, true, true, slots.percentage1),
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

    readonly property
    var transmissionUpshiftReleasePercentageArray: [
        registry.addArrayParam(MemoryRange.S32, paramId.transmission_shift_1_2_release_percentage, pressureAxisModel.count, true, true, slots.percentage1),
        registry.addArrayParam(MemoryRange.S32, paramId.transmission_shift_2_3_release_percentage, pressureAxisModel.count, true, true, slots.percentage1),
        registry.addArrayParam(MemoryRange.S32, paramId.transmission_shift_3_4_release_percentage, pressureAxisModel.count, true, true, slots.percentage1),
        registry.addArrayParam(MemoryRange.S32, paramId.transmission_shift_4_5_release_percentage, pressureAxisModel.count, true, true, slots.percentage1),
        registry.addArrayParam(MemoryRange.S32, paramId.transmission_shift_5_6_release_percentage, pressureAxisModel.count, true, true, slots.percentage1),
        registry.addArrayParam(MemoryRange.S32, paramId.transmission_shift_6_7_release_percentage, pressureAxisModel.count, true, true, slots.percentage1),
        registry.addArrayParam(MemoryRange.S32, paramId.transmission_shift_7_8_release_percentage, pressureAxisModel.count, true, true, slots.percentage1),
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

    readonly property
    var transmissionDownshiftReleasePercentageArray: [
        registry.addArrayParam(MemoryRange.S32, paramId.transmission_shift_2_1_release_percentage, pressureAxisModel.count, true, true, slots.percentage1),
        registry.addArrayParam(MemoryRange.S32, paramId.transmission_shift_3_2_release_percentage, pressureAxisModel.count, true, true, slots.percentage1),
        registry.addArrayParam(MemoryRange.S32, paramId.transmission_shift_4_3_release_percentage, pressureAxisModel.count, true, true, slots.percentage1),
        registry.addArrayParam(MemoryRange.S32, paramId.transmission_shift_5_4_release_percentage, pressureAxisModel.count, true, true, slots.percentage1),
        registry.addArrayParam(MemoryRange.S32, paramId.transmission_shift_6_5_release_percentage, pressureAxisModel.count, true, true, slots.percentage1),
        registry.addArrayParam(MemoryRange.S32, paramId.transmission_shift_7_6_release_percentage, pressureAxisModel.count, true, true, slots.percentage1),
        registry.addArrayParam(MemoryRange.S32, paramId.transmission_shift_8_7_release_percentage, pressureAxisModel.count, true, true, slots.percentage1),
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

    readonly property
    var transmissionMainPercentageArray: [
        registry.addArrayParam(MemoryRange.S32, paramId.transmission_gear_1_main_percentage, pressureAxisModel.count, true, true, slots.percentage1),
        registry.addArrayParam(MemoryRange.S32, paramId.transmission_gear_2_main_percentage, pressureAxisModel.count, true, true, slots.percentage1),
        registry.addArrayParam(MemoryRange.S32, paramId.transmission_gear_3_main_percentage, pressureAxisModel.count, true, true, slots.percentage1),
        registry.addArrayParam(MemoryRange.S32, paramId.transmission_gear_4_main_percentage, pressureAxisModel.count, true, true, slots.percentage1),
        registry.addArrayParam(MemoryRange.S32, paramId.transmission_gear_5_main_percentage, pressureAxisModel.count, true, true, slots.percentage1),
        registry.addArrayParam(MemoryRange.S32, paramId.transmission_gear_6_main_percentage, pressureAxisModel.count, true, true, slots.percentage1),
        registry.addArrayParam(MemoryRange.S32, paramId.transmission_gear_7_main_percentage, pressureAxisModel.count, true, true, slots.percentage1),
        registry.addArrayParam(MemoryRange.S32, paramId.transmission_gear_8_main_percentage, pressureAxisModel.count, true, true, slots.percentage1),
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

    readonly property ScalarParam powertrainType: registry.addScalarParam(MemoryRange.S32, paramId.transmission_type, true, true, slots.transmissionType1)

    readonly property ScalarParam pressureR2LBoostA: registry.addScalarParam(MemoryRange.S32, paramId.pressure_r2l_boost_a, true, true, slots.percentage1)

    readonly property ScalarParam pressureR2LBoostB: registry.addScalarParam(MemoryRange.S32, paramId.pressure_r2l_boost_b, true, true, slots.percentage1)

    readonly property ArrayParam displayColorArray: registry.addArrayParam(MemoryRange.S32, paramId.display_color, colorIndexAxisModel.count, true, true, slots.percentage1)
    property TableMapperModel displayColor: TableMapperModel { mapping: { "x" : colorIndexAxisModel, "value": displayColorArray.stringModel } }

    readonly property ScalarParam displayBrightness: registry.addScalarParam(MemoryRange.S32, paramId.display_brightness, true, true, slots.percentage1)

    readonly property ScalarParam displayContrast: registry.addScalarParam(MemoryRange.S32, paramId.display_contrast, true, true, slots.percentage1)

    readonly property ScalarParam shiftDownshiftOffsetA: registry.addScalarParam(MemoryRange.S32, paramId.shift_downshift_offset_a, true, true, slots.percentage1)

    readonly property ScalarParam shiftDownshiftOffsetB: registry.addScalarParam(MemoryRange.S32, paramId.shift_downshift_offset_b, true, true, slots.percentage1)

    readonly property ScalarParam engineCylinders: registry.addScalarParam(MemoryRange.S32, paramId.engine_cylinders, true, true, slots.count2)

    readonly property ScalarParam engineRunningDetectionSpeed: registry.addScalarParam(MemoryRange.S32, paramId.engine_running_detection_speed, true, true, slots.rpm1)

    readonly property ScalarParam engineIdleShutdownTime: registry.addScalarParam(MemoryRange.S32, paramId.engine_idle_shutdown_time, true, true, slots.timeInSecondsZeroIsDisabled)

    readonly property ArrayParam engineTorqueMapSpeedsArray: registry.addArrayParam(MemoryRange.S32, paramId.engine_torque_map_speeds, 11, true, true, slots.rpm1)
    readonly property ArrayParam engineMotorTorqueMapArray: registry.addArrayParam(MemoryRange.S32, paramId.engine_motor_torque_map, 11, true, true, slots.percentage2)
    readonly property ArrayParam engineBrakeTorqueMapArray: registry.addArrayParam(MemoryRange.S32, paramId.engine_braking_torque_map, 11, true, true, slots.percentage2)
    property TableMapperModel engineTorqueMap: TableMapperModel {
        mapping: {
            "rpm" : engineTorqueMapSpeedsArray.stringModel,
            "motoring": engineMotorTorqueMapArray.stringModel,
            "braking": engineBrakeTorqueMapArray.stringModel
        }
    }

    readonly property ScalarParam finalDriveRatio: registry.addScalarParam(MemoryRange.S32, paramId.final_drive_ratio, true, true, slots.ratio1)

    readonly property ScalarParam can0BaudRate: registry.addScalarParam(MemoryRange.S32, paramId.can0_baud_rate, true, true, slots.kiloBaud)

    readonly property ScalarParam can1BaudRate: registry.addScalarParam(MemoryRange.S32, paramId.can1_baud_rate, true, true, slots.kiloBaud)

    readonly property ScalarParam j1939TransmissionAddress: registry.addScalarParam(MemoryRange.S32, paramId.j1939_transmission_address, true, true, slots.count3)

    readonly property ScalarParam j1939EngineAddress: registry.addScalarParam(MemoryRange.S32, paramId.j1939_engine_address, true, true, slots.count3)

    readonly property ScalarParam j1939ShiftSelectorAddress: registry.addScalarParam(MemoryRange.S32, paramId.j1939_shift_selector_address, true, true, slots.count3)

    readonly property ScalarParam xcpCTOId: registry.addScalarParam(MemoryRange.S32, paramId.xcp_cto_id, true, true, slots.hex32bit)

    readonly property ScalarParam xcpDTOId: registry.addScalarParam(MemoryRange.S32, paramId.xcp_dto_id, true, true, slots.hex32bit)

    readonly property ScalarParam shiftManualModeA: registry.addScalarParam(MemoryRange.S32, paramId.shift_manual_mode_a, true, true, slots.booleanManualMode)

    readonly property ScalarParam shiftManualModeB: registry.addScalarParam(MemoryRange.S32, paramId.shift_manual_mode_b, true, true, slots.booleanManualMode)

    readonly property ScalarParam tccManualModeA: registry.addScalarParam(MemoryRange.S32, paramId.tcc_manual_mode_a, true, true, slots.booleanManualMode)

    readonly property ScalarParam tccManualModeB: registry.addScalarParam(MemoryRange.S32, paramId.tcc_manual_mode_b, true, true, slots.booleanManualMode)

    readonly property ScalarParam shiftMaxEngineSpeedA: registry.addScalarParam(MemoryRange.S32, paramId.shift_max_engine_speed_a, true, true, slots.rpm1)

    readonly property ScalarParam shiftMaxEngineSpeedB: registry.addScalarParam(MemoryRange.S32, paramId.shift_max_engine_speed_b, true, true, slots.rpm1)

    readonly property ScalarParam pressureAdjustA: registry.addScalarParam(MemoryRange.S32, paramId.pressure_adjust_a, true, true, slots.percentage1)

    readonly property ScalarParam pressureAdjustB: registry.addScalarParam(MemoryRange.S32, paramId.pressure_adjust_b, true, true, slots.percentage1)

    readonly property
    var pressureTablesAArray: [
        registry.addArrayParam(MemoryRange.S32, paramId.pressure_tables_a_1, percentage1AxisModel.count, true, true, slots.percentage1),
        registry.addArrayParam(MemoryRange.S32, paramId.pressure_tables_a_2, percentage1AxisModel.count, true, true, slots.percentage1),
        registry.addArrayParam(MemoryRange.S32, paramId.pressure_tables_a_3, percentage1AxisModel.count, true, true, slots.percentage1),
        registry.addArrayParam(MemoryRange.S32, paramId.pressure_tables_a_4, percentage1AxisModel.count, true, true, slots.percentage1),
        registry.addArrayParam(MemoryRange.S32, paramId.pressure_tables_a_5, percentage1AxisModel.count, true, true, slots.percentage1),
        registry.addArrayParam(MemoryRange.S32, paramId.pressure_tables_a_6, percentage1AxisModel.count, true, true, slots.percentage1)
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
    var pressureTablesBArray: [
        registry.addArrayParam(MemoryRange.S32, paramId.pressure_tables_b_1, percentage1AxisModel.count, true, true, slots.percentage1),
        registry.addArrayParam(MemoryRange.S32, paramId.pressure_tables_b_2, percentage1AxisModel.count, true, true, slots.percentage1),
        registry.addArrayParam(MemoryRange.S32, paramId.pressure_tables_b_3, percentage1AxisModel.count, true, true, slots.percentage1),
        registry.addArrayParam(MemoryRange.S32, paramId.pressure_tables_b_4, percentage1AxisModel.count, true, true, slots.percentage1),
        registry.addArrayParam(MemoryRange.S32, paramId.pressure_tables_b_5, percentage1AxisModel.count, true, true, slots.percentage1),
        registry.addArrayParam(MemoryRange.S32, paramId.pressure_tables_b_6, percentage1AxisModel.count, true, true, slots.percentage1)
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

    readonly property ScalarParam shiftSpeedAdjustA: registry.addScalarParam(MemoryRange.S32, paramId.shift_speed_adjust_a, true, true, slots.percentage1)

    readonly property ScalarParam shiftSpeedAdjustB: registry.addScalarParam(MemoryRange.S32, paramId.shift_speed_adjust_b, true, true, slots.percentage1)

    readonly property
    var shiftTablesAArray: [
        registry.addArrayParam(MemoryRange.S32, paramId.shift_tables_a_1, percentage1AxisModel.count, true, true, slots.tossRPMAsSpeed),
        registry.addArrayParam(MemoryRange.S32, paramId.shift_tables_a_2, percentage1AxisModel.count, true, true, slots.tossRPMAsSpeed),
        registry.addArrayParam(MemoryRange.S32, paramId.shift_tables_a_3, percentage1AxisModel.count, true, true, slots.tossRPMAsSpeed),
        registry.addArrayParam(MemoryRange.S32, paramId.shift_tables_a_4, percentage1AxisModel.count, true, true, slots.tossRPMAsSpeed),
        registry.addArrayParam(MemoryRange.S32, paramId.shift_tables_a_5, percentage1AxisModel.count, true, true, slots.tossRPMAsSpeed)
    ]
    property
    list<TableMapperModel> shiftTablesA: [
        TableMapperModel { mapping: { "x": percentage1AxisModel, "value": shiftTablesAArray[0].stringModel } },
        TableMapperModel { mapping: { "x": percentage1AxisModel, "value": shiftTablesAArray[1].stringModel } },
        TableMapperModel { mapping: { "x": percentage1AxisModel, "value": shiftTablesAArray[2].stringModel } },
        TableMapperModel { mapping: { "x": percentage1AxisModel, "value": shiftTablesAArray[3].stringModel } },
        TableMapperModel { mapping: { "x": percentage1AxisModel, "value": shiftTablesAArray[4].stringModel } }
    ]
    property TableMapperModel shiftTablesAModel: TableMapperModel {
        mapping: {
            "tps": percentage1AxisModel,
            "shift12": shiftTablesAArray[0].stringModel,
            "shift23": shiftTablesAArray[1].stringModel,
            "shift34": shiftTablesAArray[2].stringModel,
            "shift45": shiftTablesAArray[3].stringModel,
            "shift56": shiftTablesAArray[4].stringModel
        }
    }

    readonly property
    var shiftTablesBArray: [
        registry.addArrayParam(MemoryRange.S32, paramId.shift_tables_b_1, percentage1AxisModel.count, true, true, slots.tossRPMAsSpeed),
        registry.addArrayParam(MemoryRange.S32, paramId.shift_tables_b_2, percentage1AxisModel.count, true, true, slots.tossRPMAsSpeed),
        registry.addArrayParam(MemoryRange.S32, paramId.shift_tables_b_3, percentage1AxisModel.count, true, true, slots.tossRPMAsSpeed),
        registry.addArrayParam(MemoryRange.S32, paramId.shift_tables_b_4, percentage1AxisModel.count, true, true, slots.tossRPMAsSpeed),
        registry.addArrayParam(MemoryRange.S32, paramId.shift_tables_b_5, percentage1AxisModel.count, true, true, slots.tossRPMAsSpeed)
    ]
    property
    list<TableMapperModel> shiftTablesB: [
        TableMapperModel { mapping: { "x": percentage1AxisModel, "value": shiftTablesBArray[0].stringModel } },
        TableMapperModel { mapping: { "x": percentage1AxisModel, "value": shiftTablesBArray[1].stringModel } },
        TableMapperModel { mapping: { "x": percentage1AxisModel, "value": shiftTablesBArray[2].stringModel } },
        TableMapperModel { mapping: { "x": percentage1AxisModel, "value": shiftTablesBArray[3].stringModel } },
        TableMapperModel { mapping: { "x": percentage1AxisModel, "value": shiftTablesBArray[4].stringModel } }
    ]
    property TableMapperModel shiftTablesBModel: TableMapperModel {
        mapping: {
            "tps": percentage1AxisModel,
            "shift12": shiftTablesBArray[0].stringModel,
            "shift23": shiftTablesBArray[1].stringModel,
            "shift34": shiftTablesBArray[2].stringModel,
            "shift45": shiftTablesBArray[3].stringModel,
            "shift56": shiftTablesBArray[4].stringModel
        }
    }

    readonly property ScalarParam tccDisableTOSSPercentA: registry.addScalarParam(MemoryRange.S32, paramId.tcc_disable_toss_percent_a, true, true, slots.percentage1)

    readonly property ScalarParam tccDisableTOSSPercentB: registry.addScalarParam(MemoryRange.S32, paramId.tcc_disable_toss_percent_b, true, true, slots.percentage1)

    readonly property ScalarParam tccEnableGearA: registry.addScalarParam(MemoryRange.S32, paramId.tcc_enable_gear_a, true, true, slots.gear1)

    readonly property ScalarParam tccEnableGearB: registry.addScalarParam(MemoryRange.S32, paramId.tcc_enable_gear_b, true, true, slots.gear1)

    readonly property ScalarParam tccEnableTOSSA: registry.addScalarParam(MemoryRange.S32, paramId.tcc_enable_toss_a, true, true, slots.tossRPMAsSpeed)

    readonly property ScalarParam tccEnableTOSSB: registry.addScalarParam(MemoryRange.S32, paramId.tcc_enable_toss_b, true, true, slots.tossRPMAsSpeed)

    readonly property ScalarParam tccMaxThrottleA: registry.addScalarParam(MemoryRange.S32, paramId.tcc_max_throttle_a, true, true, slots.percentage1)

    readonly property ScalarParam tccMaxThrottleB: registry.addScalarParam(MemoryRange.S32, paramId.tcc_max_throttle_b, true, true, slots.percentage1)

    readonly property ScalarParam tccMinThrottleA: registry.addScalarParam(MemoryRange.S32, paramId.tcc_min_throttle_a, true, true, slots.percentage1)

    readonly property ScalarParam tccMinThrottleB: registry.addScalarParam(MemoryRange.S32, paramId.tcc_min_throttle_b, true, true, slots.percentage1)

    readonly property ScalarParam tccPrefillPressure: registry.addScalarParam(MemoryRange.S32, paramId.tcc_prefill_pressure, true, true, slots.percentage1)

    readonly property ScalarParam tccPrefillTime: registry.addScalarParam(MemoryRange.S32, paramId.tcc_prefill_time, true, true, slots.timeMilliseconds1)

    readonly property ArrayParam tccApplyPressureArray: registry.addArrayParam(MemoryRange.S32, paramId.tcc_apply_pressure, slipAxisModel.count, true, true, slots.percentage1)
    property TableMapperModel tccApplyPressure: TableMapperModel { mapping: { "x" : slipAxisModel, "value": tccApplyPressureArray.stringModel } }

    readonly property ScalarParam tireDiameter: registry.addScalarParam(MemoryRange.S32, paramId.tire_diameter, true, true, slots.length)

    readonly property ScalarParam transferCaseRatio: registry.addScalarParam(MemoryRange.S32, paramId.transfer_case_ratio, true, true, slots.ratio1)

    readonly property ScalarParam vehicleMass: registry.addScalarParam(MemoryRange.S32, paramId.vehicle_mass, true, true, slots.mass)

    readonly property ScalarParam voltageTPSIsReversed: registry.addScalarParam(MemoryRange.S32, paramId.voltage_tps_is_reversed, true, true, slots.booleanNormalReversed)

    readonly property ScalarParam voltageTPSCalibrationHigh: registry.addScalarParam(MemoryRange.S32, paramId.voltage_tps_calibration_high, true, true, slots.voltage1)

    readonly property ScalarParam voltageTPSCalibrationLow: registry.addScalarParam(MemoryRange.S32, paramId.voltage_tps_calibration_low, true, true, slots.voltage1)

    readonly property ScalarParam voltageTPSGroundEnable: registry.addScalarParam(MemoryRange.S32, paramId.voltage_tps_ground_enable, true, true, slots.booleanOnOff1)

    readonly property ScalarParam voltageTPSFilterOrder: registry.addScalarParam(MemoryRange.S32, paramId.voltage_tps_filter_order, true, true, slots.timeMilliseconds1)

    readonly property ScalarParam voltageMAPSensorHighCalibration: registry.addScalarParam(MemoryRange.S32, paramId.voltage_map_sensor_high_calibration, true, true, slots.voltage1)

    readonly property ScalarParam voltageMAPSensorLowCalibration: registry.addScalarParam(MemoryRange.S32, paramId.voltage_map_sensor_low_calibration, true, true, slots.voltage1)

    readonly property ScalarParam voltageMAPSensorGroundEnable: registry.addScalarParam(MemoryRange.S32, paramId.voltage_map_sensor_ground_enable, true, true, slots.booleanOnOff1)

    readonly property ScalarParam transmissionTempBiasEnable: registry.addScalarParam(MemoryRange.S32, paramId.transmission_temp_bias_enable, true, true, slots.booleanOnOff1)

    readonly property ScalarParam transmissionHasLinePressureSensor: registry.addScalarParam(MemoryRange.S32, paramId.transmission_main_pressure_sensor_present, true, true, slots.booleanOnOff1)

    readonly property ScalarParam transmissionHasLinePressureControl: registry.addScalarParam(MemoryRange.S32, paramId.transmission_has_line_pressure_control, true, true, slots.booleanYesNo1)

    readonly property ScalarParam transmissionHasAccumulatorControl: registry.addScalarParam(MemoryRange.S32, paramId.transmission_has_accumulator_control, true, true, slots.booleanYesNo1)

    readonly property ScalarParam transmissionHasPWMTCC: registry.addScalarParam(MemoryRange.S32, paramId.transmission_has_pwm_tcc, true, true, slots.booleanYesNo1)

    readonly property ScalarParam cs2EngineTempBiasEnable: registry.addScalarParam(MemoryRange.S32, paramId.cs2_engine_temp_bias_enable, true, true, slots.booleanOnOff1)

    readonly property ScalarParam pressureControlSource: registry.addScalarParam(MemoryRange.S32, paramId.pressure_control_source, true, true, slots.torqueSignalSource)

    readonly property ArrayParam shiftSelectorGearVoltagesArray: registry.addArrayParam(MemoryRange.S32, paramId.shift_selector_gear_voltages, hgmShiftSelectorCalibrationGearAxisModel.count, true, true, slots.hgmShiftSelectorCalibrationSensorVoltage)
    property TableMapperModel shiftSelectorGearVoltages: TableMapperModel { mapping: { "x" : hgmShiftSelectorCalibrationGearAxisModel, "value": shiftSelectorGearVoltagesArray.stringModel } }

    readonly property ScalarParam shiftSelectorODCancelAtStartup: registry.addScalarParam(MemoryRange.S32, paramId.shift_selector_overdrive_cancel_at_startup, true, true, slots.booleanOnOff1)

    readonly property ScalarParam useMetricUnits: registry.addScalarParam(MemoryRange.S32, paramId.use_metric_units, true, true, slots.measurementSystem)

    readonly property ScalarParam speedometerCalibration: registry.addScalarParam(MemoryRange.S32, paramId.speedometer_calibration, true, true, slots.speedoCalibration)

    readonly property ScalarParam startInhibitRelayType: registry.addScalarParam(MemoryRange.S32, paramId.start_inhibit_relay_type, true, true, slots.booleanNormalReversed)

    readonly property ScalarParam vehicleSpeedSensorPulseCount: registry.addScalarParam(MemoryRange.S32, paramId.vehicle_speed_sensor_pulse_count, true, true, slots.count3)
}
