import QtQuick 2.5
import com.hgmelectronics.setuptools.xcp 1.0
import com.hgmelectronics.setuptools 1.0
import com.hgmelectronics.setuptools.ui 1.0

QtObject {
    id: parameters
    property bool useMetricUnits
    property ParamRegistry registry
    property ParamId paramId: ParamId {}
    property Slots slots: Slots {
        useMetricUnits: parameters.useMetricUnits
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


    //readonly property ArrayParam controllerSoftwareVersion: registry.addArrayParam(MemoryRange.S32, paramId.controller_software_version, false, false, slots)
    readonly property ScalarParam controllerHeapUsed: registry.addScalarParam(MemoryRange.S32, paramId.controller_heap_used, false, false, slots.count)

    readonly property ScalarParam controllerHeapSize: registry.addScalarParam(
                                                          MemoryRange.S32,
                                                          paramId.controller_heap_size,
                                                          false,
                                                          false,
                                                          slots.count)

    readonly property ScalarParam controllerHeapAllocationCount: registry.addScalarParam(MemoryRange.S32, paramId.controller_heap_allocation_count, false, false, slots.count)

    readonly property ScalarParam controllerHeapReleaseCount: registry.addScalarParam(MemoryRange.S32, paramId.controller_heap_release_count, false, false, slots.count)

    readonly property ScalarParam controllerTachInputFrequency: registry.addScalarParam(MemoryRange.S32, paramId.controller_tach_input_frequency, false, false, slots.frequency)

    readonly property ScalarParam controllerTissInputFrequency: registry.addScalarParam(MemoryRange.S32, paramId.controller_tiss_input_frequency, false, false, slots.frequency)

    readonly property ScalarParam controllerTossInputFrequency: registry.addScalarParam(MemoryRange.S32, paramId.controller_toss_input_frequency, false, false, slots.frequency)

    readonly property ScalarParam controllerSpareInputFrequency: registry.addScalarParam(MemoryRange.S32, paramId.controller_spare_input_frequency, false, false, slots.frequency)

    readonly property ScalarParam controllertThrottlePositionSensorVoltage: registry.addScalarParam(MemoryRange.S32, paramId.controller_throttle_position_sensor_voltage, false, false, slots.voltage1)

    readonly property ScalarParam controllerMAPSensorVoltage: registry.addScalarParam(MemoryRange.S32, paramId.controller_map_sensor_voltage, false, false, slots.voltage1)

    readonly property ScalarParam controllerInternalTemperatureSensorVoltage: registry.addScalarParam(MemoryRange.S32, paramId.controller_internal_temperature_sensor_voltage, false, false, slots.voltage1)

    readonly property ScalarParam controllerInternalTemprature: registry.addScalarParam(MemoryRange.S32, paramId.controller_internal_temperature, false, false, slots.temperature1)

    readonly property ScalarParam controllerEngineTempratureSensorVoltage: registry.addScalarParam(MemoryRange.S32, paramId.controller_engine_temperature_sensor_voltage, false, false, slots.voltage1)

    readonly property ScalarParam controllerTransmissionTemperatureSensorVoltage: registry.addScalarParam(MemoryRange.S32, paramId.controller_transmission_temperature_sensor_voltage, false, false, slots.voltage1)

    readonly property ScalarParam controllerMultipltexedSensorVoltage: registry.addScalarParam(MemoryRange.S32, paramId.controller_multiplexed_sensor_voltage, false, false, slots.voltage1)

    readonly property ScalarParam controllerBus5Voltage: registry.addScalarParam(
                                                             MemoryRange.S32,
                                                             paramId.controller_5_volt_bus_voltage,
                                                             false,
                                                             false,
                                                             slots.voltage1)

    readonly property ScalarParam controllerBus3_3Voltage: registry.addScalarParam(MemoryRange.S32, paramId.controller_3_3_volt_bus_voltage, false, false, slots.voltage1)

    readonly property ScalarParam controllerBus1_8Voltage: registry.addScalarParam(MemoryRange.S32, paramId.controller_1_8_volt_bus_voltage, false, false, slots.voltage1)

    readonly property ScalarParam controllerBus12Voltage: registry.addScalarParam(
                                                              MemoryRange.S32,
                                                              paramId.controller_12_volt_bus_voltage,
                                                              false, false,
                                                              slots.voltage1)

    readonly property ScalarParam controllerBusVoltage: registry.addScalarParam(
                                                            MemoryRange.S32,
                                                            paramId.controller_voltage,
                                                            false,
                                                            false,
                                                            slots.voltage1)

    readonly property ScalarParam controllerSpeedTimer1Frequency: registry.addScalarParam(MemoryRange.S32, paramId.controller_speed_timer_1_frequency, true, false, slots.frequency)

    readonly property ScalarParam controllerSpeedTimer2Frequency: registry.addScalarParam(MemoryRange.S32, paramId.controller_speed_timer_2_frequency, true, false, slots.frequency)

    readonly property ScalarParam controllerSDCardWriteProtect: registry.addScalarParam(MemoryRange.S32, paramId.controller_sd_card_write_protect, false, false, slots.booleanOnOff1)

    readonly property ScalarParam controllerSDCardPresent: registry.addScalarParam(MemoryRange.S32, paramId.controller_sd_card_present, false, false, slots.booleanOnOff1)

    readonly property ScalarParam controllerMasterDriveFault: registry.addScalarParam(MemoryRange.S32, paramId.controller_master_driver_fault, false, false, slots.booleanOnOff1)

    readonly property ScalarParam controllerUSBPower: registry.addScalarParam(
                                                          MemoryRange.S32,
                                                          paramId.controller_usb_power,
                                                          false,
                                                          false,
                                                          slots.booleanOnOff1)

    readonly property ScalarParam controllerUSBConnect: registry.addScalarParam(
                                                            MemoryRange.S32,
                                                            paramId.controller_usb_connect,
                                                            false,
                                                            false,
                                                            slots.booleanOnOff1)

    readonly property ScalarParam controllerGreenLED: registry.addScalarParam(
                                                          MemoryRange.S32,
                                                          paramId.controller_greed_led,
                                                          false,
                                                          false,
                                                          slots.booleanOnOff1)

    readonly property ScalarParam controllerRedLED: registry.addScalarParam(
                                                        MemoryRange.S32,
                                                        paramId.controller_red_led,
                                                        false,
                                                        false,
                                                        slots.booleanOnOff1)

    readonly property ScalarParam controllerTransmissionTemperatureSensorBias: registry.addScalarParam(MemoryRange.S32, paramId.controller_transmission_temperature_sensor_bias, false, false, slots.booleanOnOff1)

    readonly property ScalarParam controllerEngineTemperatureSensorBias: registry.addScalarParam(MemoryRange.S32, paramId.controller_engine_temperature_sensor_bias, false, false, slots.booleanOnOff1)

    readonly property ScalarParam controllerThrottlePositionSensorGround: registry.addScalarParam(MemoryRange.S32, paramId.controller_throttle_position_sensor_ground, false, false, slots.booleanOnOff1)

    readonly property ScalarParam controllerMAPSensorGround: registry.addScalarParam(MemoryRange.S32, paramId.controller_map_ground, false, false, slots.booleanOnOff1)

    readonly property ArrayParam controllerPWMDriverFrequency: registry.addArrayParam(MemoryRange.S32, paramId.controller_pwmdriver_frequency, 12, true, false, slots.frequency)

    readonly property ArrayParam controllerPWMDriverDutyCycle: registry.addArrayParam(MemoryRange.S32, paramId.controller_pwmdriver_duty_cycle, 12, true, false, slots.percentage2)

    readonly property ArrayParam controllerPWMDriverMode: registry.addArrayParam(
                                                              MemoryRange.S32,
                                                              paramId.controller_pwmdriver_mode,
                                                              12,
                                                              true, false,
                                                              slots.pwmDriverMode)

    property SlotArrayModel controllerPWMDriverIdModel: SlotArrayModel {
        slot: slots.pwmDriverId
        count: 12
    }


    property TableMapperModel controllerPWMDriverModel: TableMapperModel {
        mapping: {
            "x": controllerPWMDriverIdModel,
                    "frequency": controllerPWMDriverFrequency.stringModel,
                    "dutyCycle": controllerPWMDriverDutyCycle.stringModel,
                    "mode": controllerPWMDriverMode.stringModel
        }
    }

    //    readonly property ScalarParam : registry.addScalarParam(MemoryRange.S32, paramId.controller_acclerometer, false, false, slots)

    //    readonly property ArrayParam : registry.addScalarParam(MemoryRange.S32, paramId.controller_switch_state, false, false, slots)
    //    readonly property ArrayParam : registry.addScalarParam(MemoryRange.S32, paramId.controller_switch_current, false, false, slots)



    readonly property
    var transmissionShaftSpeedSensorPulseCount: [
        registry.addScalarParam(MemoryRange.S32, paramId.transmission_shaft_1_speed_sensor_pulse_count, true, true, slots.count3),
        registry.addScalarParam(MemoryRange.S32, paramId.transmission_shaft_2_speed_sensor_pulse_count, true, true, slots.count3),
        registry.addScalarParam(MemoryRange.S32, paramId.transmission_shaft_3_speed_sensor_pulse_count, true, true, slots.count3),
        registry.addScalarParam(MemoryRange.S32, paramId.transmission_shaft_4_speed_sensor_pulse_count, true, true, slots.count3),
        registry.addScalarParam(MemoryRange.S32, paramId.transmission_shaft_5_speed_sensor_pulse_count, true, true, slots.count3),
        registry.addScalarParam(MemoryRange.S32, paramId.transmission_shaft_6_speed_sensor_pulse_count, true, true, slots.count3)
    ]

    property
    list<TableParam> transmissionClutchFillTime: [
        TableParam {
            x: pressureAxisModel
            value: registry.addArrayParam(MemoryRange.S32, paramId.transmission_clutch_1_fill_time, pressureAxisModel.count, true, true, slots.timeMilliseconds1)
        },
        TableParam {
            x: pressureAxisModel
            value: registry.addArrayParam(MemoryRange.S32, paramId.transmission_clutch_2_fill_time, pressureAxisModel.count, true, true, slots.timeMilliseconds1)
        },
        TableParam {
            x: pressureAxisModel
            value: registry.addArrayParam(MemoryRange.S32, paramId.transmission_clutch_3_fill_time, pressureAxisModel.count, true, true, slots.timeMilliseconds1)
        },
        TableParam {
            x: pressureAxisModel
            value: registry.addArrayParam(MemoryRange.S32, paramId.transmission_clutch_4_fill_time, pressureAxisModel.count, true, true, slots.timeMilliseconds1)
        },
        TableParam {
            x: pressureAxisModel
            value: registry.addArrayParam(MemoryRange.S32, paramId.transmission_clutch_5_fill_time, pressureAxisModel.count, true, true, slots.timeMilliseconds1)
        },
        TableParam {
            x: pressureAxisModel
            value: registry.addArrayParam(MemoryRange.S32, paramId.transmission_clutch_6_fill_time, pressureAxisModel.count, true, true, slots.timeMilliseconds1)
        },
        TableParam {
            x: pressureAxisModel
            value: registry.addArrayParam(MemoryRange.S32, paramId.transmission_clutch_7_fill_time, pressureAxisModel.count, true, true, slots.timeMilliseconds1)
        },
        TableParam {
            x: pressureAxisModel
            value: registry.addArrayParam(MemoryRange.S32, paramId.transmission_clutch_8_fill_time, pressureAxisModel.count, true, true, slots.timeMilliseconds1)
        }
    ]

    property
    list<TableParam> transmissionClutchEmptyTime: [
        TableParam {
            x: pressureAxisModel
            value: registry.addArrayParam(MemoryRange.S32, paramId.transmission_clutch_1_empty_time, pressureAxisModel.count, true, true, slots.timeMilliseconds1)
        },
        TableParam {
            x: pressureAxisModel
            value: registry.addArrayParam(MemoryRange.S32, paramId.transmission_clutch_2_empty_time, pressureAxisModel.count, true, true, slots.timeMilliseconds1)
        },
        TableParam {
            x: pressureAxisModel
            value: registry.addArrayParam(MemoryRange.S32, paramId.transmission_clutch_3_empty_time, pressureAxisModel.count, true, true, slots.timeMilliseconds1)
        },
        TableParam {
            x: pressureAxisModel
            value: registry.addArrayParam(MemoryRange.S32, paramId.transmission_clutch_4_empty_time, pressureAxisModel.count, true, true, slots.timeMilliseconds1)
        },
        TableParam {
            x: pressureAxisModel
            value: registry.addArrayParam(MemoryRange.S32, paramId.transmission_clutch_5_empty_time, pressureAxisModel.count, true, true, slots.timeMilliseconds1)
        },
        TableParam {
            x: pressureAxisModel
            value: registry.addArrayParam(MemoryRange.S32, paramId.transmission_clutch_6_empty_time, pressureAxisModel.count, true, true, slots.timeMilliseconds1)
        },
        TableParam {
            x: pressureAxisModel
            value: registry.addArrayParam(MemoryRange.S32, paramId.transmission_clutch_7_empty_time, pressureAxisModel.count, true, true, slots.timeMilliseconds1)
        },
        TableParam {
            x: pressureAxisModel
            value: registry.addArrayParam(MemoryRange.S32, paramId.transmission_clutch_8_empty_time, pressureAxisModel.count, true, true, slots.timeMilliseconds1)
        }
    ]

    property list<ScalarMetaParam> transmissionShiftPrefillTime: [
        ScalarMetaParam {
            name: "Prefill Time R-N"
            param: registry.addScalarParam(MemoryRange.S32, paramId.transmission_shift_r_n_prefill_time, true, true, slots.timeMilliseconds1)
        },
        ScalarMetaParam {
            name: "Prefill Time N-R"
            param: registry.addScalarParam(MemoryRange.S32, paramId.transmission_shift_n_r_prefill_time, true, true, slots.timeMilliseconds1)
        },
        ScalarMetaParam {
            name: "Prefill Time N-1"
            param: registry.addScalarParam(MemoryRange.S32, paramId.transmission_shift_n_1_prefill_time, true, true, slots.timeMilliseconds1)
        },
        ScalarMetaParam {
            name: "Prefill Time 1-N"
            param: registry.addScalarParam(MemoryRange.S32, paramId.transmission_shift_1_n_prefill_time, true, true, slots.timeMilliseconds1)
        },
        ScalarMetaParam {
            name: "Prefill Time 1-2"
            param: registry.addScalarParam(MemoryRange.S32, paramId.transmission_shift_1_2_prefill_time, true, true, slots.timeMilliseconds1)
        },
        ScalarMetaParam {
            name: "Prefill Time 2-1"
            param: registry.addScalarParam(MemoryRange.S32, paramId.transmission_shift_2_1_prefill_time, true, true, slots.timeMilliseconds1)
        },
        ScalarMetaParam {
            name: "Prefill Time 2-3"
            param: registry.addScalarParam(MemoryRange.S32, paramId.transmission_shift_2_3_prefill_time, true, true, slots.timeMilliseconds1)
        },
        ScalarMetaParam {
            name: "Prefill Time 3-2"
            param: registry.addScalarParam(MemoryRange.S32, paramId.transmission_shift_3_2_prefill_time, true, true, slots.timeMilliseconds1)
        },
        ScalarMetaParam {
            name: "Prefill Time 3-4"
            param: registry.addScalarParam(MemoryRange.S32, paramId.transmission_shift_3_4_prefill_time, true, true, slots.timeMilliseconds1)
        },
        ScalarMetaParam {
            name: "Prefill Time 4-3"
            param: registry.addScalarParam(MemoryRange.S32, paramId.transmission_shift_4_3_prefill_time, true, true, slots.timeMilliseconds1)
        },
        ScalarMetaParam {
            name: "Prefill Time 4-5"
            param: registry.addScalarParam(MemoryRange.S32, paramId.transmission_shift_4_5_prefill_time, true, true, slots.timeMilliseconds1)
        },
        ScalarMetaParam {
            name: "Prefill Time 5-4"
            param: registry.addScalarParam(MemoryRange.S32, paramId.transmission_shift_5_4_prefill_time, true, true, slots.timeMilliseconds1)
        },
        ScalarMetaParam {
            name: "Prefill Time 5-6"
            param: registry.addScalarParam(MemoryRange.S32, paramId.transmission_shift_5_6_prefill_time, true, true, slots.timeMilliseconds1)
        },
        ScalarMetaParam {
            name: "Prefill Time 6-5"
            param: registry.addScalarParam(MemoryRange.S32, paramId.transmission_shift_6_5_prefill_time, true, true, slots.timeMilliseconds1)
        }
    ]

    property list<ScalarMetaParam> transmissionShiftPrefillPercentage: [
        ScalarMetaParam {
            name: "Prefill Pressure R-N"
            param: registry.addScalarParam(MemoryRange.S32, paramId.transmission_shift_r_n_prefill_percentage, true, true, slots.percentage1)
        },
        ScalarMetaParam {
            name: "Prefill Pressure N-R"
            param: registry.addScalarParam(MemoryRange.S32, paramId.transmission_shift_n_r_prefill_percentage, true, true, slots.percentage1)
        },
        ScalarMetaParam {
            name: "Prefill Pressure N-1"
            param: registry.addScalarParam(MemoryRange.S32, paramId.transmission_shift_n_1_prefill_percentage, true, true, slots.percentage1)
        },
        ScalarMetaParam {
            name: "Prefill Pressure 1-N"
            param: registry.addScalarParam(MemoryRange.S32, paramId.transmission_shift_1_n_prefill_percentage, true, true, slots.percentage1)
        },
        ScalarMetaParam {
            name: "Prefill Pressure 1-2"
            param: registry.addScalarParam(MemoryRange.S32, paramId.transmission_shift_1_2_prefill_percentage, true, true, slots.percentage1)
        },
        ScalarMetaParam {
            name: "Prefill Pressure 2-1"
            param: registry.addScalarParam(MemoryRange.S32, paramId.transmission_shift_2_1_prefill_percentage, true, true, slots.percentage1)
        },
        ScalarMetaParam {
            name: "Prefill Pressure 2-3"
            param: registry.addScalarParam(MemoryRange.S32, paramId.transmission_shift_2_3_prefill_percentage, true, true, slots.percentage1)
        },
        ScalarMetaParam {
            name: "Prefill Pressure 3-2"
            param: registry.addScalarParam(MemoryRange.S32, paramId.transmission_shift_3_2_prefill_percentage, true, true, slots.percentage1)
        },
        ScalarMetaParam {
            name: "Prefill Pressure 3-4"
            param: registry.addScalarParam(MemoryRange.S32, paramId.transmission_shift_3_4_prefill_percentage, true, true, slots.percentage1)
        },
        ScalarMetaParam {
            name: "Prefill Pressure 4-3"
            param: registry.addScalarParam(MemoryRange.S32, paramId.transmission_shift_4_3_prefill_percentage, true, true, slots.percentage1)
        },
        ScalarMetaParam {
            name: "Prefill Pressure 4-5"
            param: registry.addScalarParam(MemoryRange.S32, paramId.transmission_shift_4_5_prefill_percentage, true, true, slots.percentage1)
        },
        ScalarMetaParam {
            name: "Prefill Pressure 5-4"
            param: registry.addScalarParam(MemoryRange.S32, paramId.transmission_shift_5_4_prefill_percentage, true, true, slots.percentage1)
        },
        ScalarMetaParam {
            name: "Prefill Pressure 5-6"
            param: registry.addScalarParam(MemoryRange.S32, paramId.transmission_shift_5_6_prefill_percentage, true, true, slots.percentage1)
        },
        ScalarMetaParam {
            name: "Prefill Pressure 6-5"
            param: registry.addScalarParam(MemoryRange.S32, paramId.transmission_shift_6_5_prefill_percentage, true, true, slots.percentage1)
        }
    ]

    property list<ScalarMetaParam> transmissionShiftPrefillPressure: [
        ScalarMetaParam {
            name: "Prefill Pressure R-N"
            param: registry.addScalarParam(MemoryRange.S32, paramId.transmission_shift_r_n_prefill_pressure, true, true, slots.pressure)
        },
        ScalarMetaParam {
            name: "Prefill Pressure N-R"
            param: registry.addScalarParam(MemoryRange.S32, paramId.transmission_shift_n_r_prefill_pressure, true, true, slots.pressure)
        },
        ScalarMetaParam {
            name: "Prefill Pressure N-1"
            param: registry.addScalarParam(MemoryRange.S32, paramId.transmission_shift_n_1_prefill_pressure, true, true, slots.pressure)
        },
        ScalarMetaParam {
            name: "Prefill Pressure 1-N"
            param: registry.addScalarParam(MemoryRange.S32, paramId.transmission_shift_1_n_prefill_pressure, true, true, slots.pressure)
        },
        ScalarMetaParam {
            name: "Prefill Pressure 1-2"
            param: registry.addScalarParam(MemoryRange.S32, paramId.transmission_shift_1_2_prefill_pressure, true, true, slots.pressure)
        },
        ScalarMetaParam {
            name: "Prefill Pressure 2-1"
            param: registry.addScalarParam(MemoryRange.S32, paramId.transmission_shift_2_1_prefill_pressure, true, true, slots.pressure)
        },
        ScalarMetaParam {
            name: "Prefill Pressure 2-3"
            param: registry.addScalarParam(MemoryRange.S32, paramId.transmission_shift_2_3_prefill_pressure, true, true, slots.pressure)
        },
        ScalarMetaParam {
            name: "Prefill Pressure 3-2"
            param: registry.addScalarParam(MemoryRange.S32, paramId.transmission_shift_3_2_prefill_pressure, true, true, slots.pressure)
        },
        ScalarMetaParam {
            name: "Prefill Pressure 3-4"
            param: registry.addScalarParam(MemoryRange.S32, paramId.transmission_shift_3_4_prefill_pressure, true, true, slots.pressure)
        },
        ScalarMetaParam {
            name: "Prefill Pressure 4-3"
            param: registry.addScalarParam(MemoryRange.S32, paramId.transmission_shift_4_3_prefill_pressure, true, true, slots.pressure)
        },
        ScalarMetaParam {
            name: "Prefill Pressure 4-5"
            param: registry.addScalarParam(MemoryRange.S32, paramId.transmission_shift_4_5_prefill_pressure, true, true, slots.pressure)
        },
        ScalarMetaParam {
            name: "Prefill Pressure 5-4"
            param: registry.addScalarParam(MemoryRange.S32, paramId.transmission_shift_5_4_prefill_pressure, true, true, slots.pressure)
        },
        ScalarMetaParam {
            name: "Prefill Pressure 5-6"
            param: registry.addScalarParam(MemoryRange.S32, paramId.transmission_shift_5_6_prefill_pressure, true, true, slots.pressure)
        },
        ScalarMetaParam {
            name: "Prefill Pressure 6-5"
            param: registry.addScalarParam(MemoryRange.S32, paramId.transmission_shift_6_5_prefill_pressure, true, true, slots.pressure)
        }
    ]

    property list<ScalarMetaParam> transmissionShiftOverlapPressure: [
        ScalarMetaParam {
            name: "Overlap Pressure R-N"
            param: registry.addScalarParam(MemoryRange.S32, paramId.transmission_shift_r_n_overlap_pressure, true, true, slots.percentage1)
        },
        ScalarMetaParam {
            name: "Overlap Pressure N-R"
            param: registry.addScalarParam(MemoryRange.S32, paramId.transmission_shift_n_r_overlap_pressure, true, true, slots.percentage1)
        },
        ScalarMetaParam {
            name: "Overlap Pressure N-1"
            param: registry.addScalarParam(MemoryRange.S32, paramId.transmission_shift_n_1_overlap_pressure, true, true, slots.percentage1)
        },
        ScalarMetaParam {
            name: "Overlap Pressure 1-N"
            param: registry.addScalarParam(MemoryRange.S32, paramId.transmission_shift_1_n_overlap_pressure, true, true, slots.percentage1)
        },
        ScalarMetaParam {
            name: "Overlap Pressure 1-2"
            param: registry.addScalarParam(MemoryRange.S32, paramId.transmission_shift_1_2_overlap_pressure, true, true, slots.percentage1)
        },
        ScalarMetaParam {
            name: "Overlap Pressure 2-1"
            param: registry.addScalarParam(MemoryRange.S32, paramId.transmission_shift_2_1_overlap_pressure, true, true, slots.percentage1)
        },
        ScalarMetaParam {
            name: "Overlap Pressure 2-3"
            param: registry.addScalarParam(MemoryRange.S32, paramId.transmission_shift_2_3_overlap_pressure, true, true, slots.percentage1)
        },
        ScalarMetaParam {
            name: "Overlap Pressure 3-2"
            param: registry.addScalarParam(MemoryRange.S32, paramId.transmission_shift_3_2_overlap_pressure, true, true, slots.percentage1)
        },
        ScalarMetaParam {
            name: "Overlap Pressure 3-4"
            param: registry.addScalarParam(MemoryRange.S32, paramId.transmission_shift_3_4_overlap_pressure, true, true, slots.percentage1)
        },
        ScalarMetaParam {
            name: "Overlap Pressure 4-3"
            param: registry.addScalarParam(MemoryRange.S32, paramId.transmission_shift_4_3_overlap_pressure, true, true, slots.percentage1)
        },
        ScalarMetaParam {
            name: "Overlap Pressure 4-5"
            param: registry.addScalarParam(MemoryRange.S32, paramId.transmission_shift_4_5_overlap_pressure, true, true, slots.percentage1)
        },
        ScalarMetaParam {
            name: "Overlap Pressure 5-4"
            param: registry.addScalarParam(MemoryRange.S32, paramId.transmission_shift_5_4_overlap_pressure, true, true, slots.percentage1)
        },
        ScalarMetaParam {
            name: "Overlap Pressure 5-6"
            param: registry.addScalarParam(MemoryRange.S32, paramId.transmission_shift_5_6_overlap_pressure, true, true, slots.percentage1)
        },
        ScalarMetaParam {
            name: "Overlap Pressure 6-5"
            param: registry.addScalarParam(MemoryRange.S32, paramId.transmission_shift_6_5_overlap_pressure, true, true, slots.percentage1)
        }
    ]

    property TableParam transmissionTemperaturePressureCompensation: TableParam {
        x: tempAxisModel
        value: registry.addArrayParam(MemoryRange.S32, paramId.transmission_pressure_temperature_compensation, tempAxisModel.count, true, true, slots.percentage1)
    }

    property
    list<TableParam> transmissionUpshiftApplyPressure: [
        TableParam {
            x: pressureAxisModel
            value: registry.addArrayParam(MemoryRange.S32, paramId.transmission_shift_n_1_apply_pressure, pressureAxisModel.count, true, true, slots.pressure)
        },
        TableParam {
            x: pressureAxisModel
            value: registry.addArrayParam(MemoryRange.S32, paramId.transmission_shift_1_2_apply_pressure, pressureAxisModel.count, true, true, slots.pressure)
        },
        TableParam {
            x: pressureAxisModel
            value: registry.addArrayParam(MemoryRange.S32, paramId.transmission_shift_2_3_apply_pressure, pressureAxisModel.count, true, true, slots.pressure)
        },
        TableParam {
            x: pressureAxisModel
            value: registry.addArrayParam(MemoryRange.S32, paramId.transmission_shift_3_4_apply_pressure, pressureAxisModel.count, true, true, slots.pressure)
        },
        TableParam {
            x: pressureAxisModel
            value: registry.addArrayParam(MemoryRange.S32, paramId.transmission_shift_4_5_apply_pressure, pressureAxisModel.count, true, true, slots.pressure)
        },
        TableParam {
            x: pressureAxisModel
            value: registry.addArrayParam(MemoryRange.S32, paramId.transmission_shift_5_6_apply_pressure, pressureAxisModel.count, true, true, slots.pressure)
        },
        TableParam {
            x: pressureAxisModel
            value: registry.addArrayParam(MemoryRange.S32, paramId.transmission_shift_6_7_apply_pressure, pressureAxisModel.count, true, true, slots.pressure)
        },
        TableParam {
            x: pressureAxisModel
            value: registry.addArrayParam(MemoryRange.S32, paramId.transmission_shift_7_8_apply_pressure, pressureAxisModel.count, true, true, slots.pressure)
        }
    ]

    property
    list<TableParam> transmissionDownshiftApplyPressure: [
        TableParam {
            x: pressureAxisModel
            value: registry.addArrayParam(MemoryRange.S32, paramId.transmission_shift_2_1_apply_pressure, pressureAxisModel.count, true, true, slots.pressure)
        },
        TableParam {
            x: pressureAxisModel
            value: registry.addArrayParam(MemoryRange.S32, paramId.transmission_shift_3_2_apply_pressure, pressureAxisModel.count, true, true, slots.pressure)
        },
        TableParam {
            x: pressureAxisModel
            value: registry.addArrayParam(MemoryRange.S32, paramId.transmission_shift_4_3_apply_pressure, pressureAxisModel.count, true, true, slots.pressure)
        },
        TableParam {
            x: pressureAxisModel
            value: registry.addArrayParam(MemoryRange.S32, paramId.transmission_shift_5_4_apply_pressure, pressureAxisModel.count, true, true, slots.pressure)
        },
        TableParam {
            x: pressureAxisModel
            value: registry.addArrayParam(MemoryRange.S32, paramId.transmission_shift_6_5_apply_pressure, pressureAxisModel.count, true, true, slots.pressure)
        },
        TableParam {
            x: pressureAxisModel
            value: registry.addArrayParam(MemoryRange.S32, paramId.transmission_shift_7_6_apply_pressure, pressureAxisModel.count, true, true, slots.pressure)
        },
        TableParam {
            x: pressureAxisModel
            value: registry.addArrayParam(MemoryRange.S32, paramId.transmission_shift_8_7_apply_pressure, pressureAxisModel.count, true, true, slots.pressure)
        }
    ]

    property
    list<TableParam> transmissionUpshiftReleasePressure: [
        TableParam {
            x: pressureAxisModel
            value: registry.addArrayParam(MemoryRange.S32, paramId.transmission_shift_1_2_release_pressure, pressureAxisModel.count, true, true, slots.pressure)
        },
        TableParam {
            x: pressureAxisModel
            value: registry.addArrayParam(MemoryRange.S32, paramId.transmission_shift_2_3_release_pressure, pressureAxisModel.count, true, true, slots.pressure)
        },
        TableParam {
            x: pressureAxisModel
            value: registry.addArrayParam(MemoryRange.S32, paramId.transmission_shift_3_4_release_pressure, pressureAxisModel.count, true, true, slots.pressure)
        },
        TableParam {
            x: pressureAxisModel
            value: registry.addArrayParam(MemoryRange.S32, paramId.transmission_shift_4_5_release_pressure, pressureAxisModel.count, true, true, slots.pressure)
        },
        TableParam {
            x: pressureAxisModel
            value: registry.addArrayParam(MemoryRange.S32, paramId.transmission_shift_5_6_release_pressure, pressureAxisModel.count, true, true, slots.pressure)
        },
        TableParam {
            x: pressureAxisModel
            value: registry.addArrayParam(MemoryRange.S32, paramId.transmission_shift_6_7_release_pressure, pressureAxisModel.count, true, true, slots.pressure)
        },
        TableParam {
            x: pressureAxisModel
            value: registry.addArrayParam(MemoryRange.S32, paramId.transmission_shift_7_8_release_pressure, pressureAxisModel.count, true, true, slots.pressure)
        }
    ]

    property
    list<TableParam> transmissionDownshiftReleasePressure: [
        TableParam {
            x: pressureAxisModel
            value: registry.addArrayParam(MemoryRange.S32, paramId.transmission_shift_2_1_release_pressure, pressureAxisModel.count, true, true, slots.pressure)
        },
        TableParam {
            x: pressureAxisModel
            value: registry.addArrayParam(MemoryRange.S32, paramId.transmission_shift_3_2_release_pressure, pressureAxisModel.count, true, true, slots.pressure)
        },
        TableParam {
            x: pressureAxisModel
            value: registry.addArrayParam(MemoryRange.S32, paramId.transmission_shift_4_3_release_pressure, pressureAxisModel.count, true, true, slots.pressure)
        },
        TableParam {
            x: pressureAxisModel
            value: registry.addArrayParam(MemoryRange.S32, paramId.transmission_shift_5_4_release_pressure, pressureAxisModel.count, true, true, slots.pressure)
        },
        TableParam {
            x: pressureAxisModel
            value: registry.addArrayParam(MemoryRange.S32, paramId.transmission_shift_6_5_release_pressure, pressureAxisModel.count, true, true, slots.pressure)
        },
        TableParam {
            x: pressureAxisModel
            value: registry.addArrayParam(MemoryRange.S32, paramId.transmission_shift_7_6_release_pressure, pressureAxisModel.count, true, true, slots.pressure)
        },
        TableParam {
            x: pressureAxisModel
            value: registry.addArrayParam(MemoryRange.S32, paramId.transmission_shift_8_7_release_pressure, pressureAxisModel.count, true, true, slots.pressure)
        }
    ]

    property
    list<TableParam> transmissionMainPressure: [
        TableParam {
            x: pressureAxisModel
            value: registry.addArrayParam(MemoryRange.S32, paramId.transmission_gear_1_main_pressure, pressureAxisModel.count, true, true, slots.pressure)
        },
        TableParam {
            x: pressureAxisModel
            value: registry.addArrayParam(MemoryRange.S32, paramId.transmission_gear_2_main_pressure, pressureAxisModel.count, true, true, slots.pressure)
        },
        TableParam {
            x: pressureAxisModel
            value: registry.addArrayParam(MemoryRange.S32, paramId.transmission_gear_3_main_pressure, pressureAxisModel.count, true, true, slots.pressure)
        },
        TableParam {
            x: pressureAxisModel
            value: registry.addArrayParam(MemoryRange.S32, paramId.transmission_gear_4_main_pressure, pressureAxisModel.count, true, true, slots.pressure)
        },
        TableParam {
            x: pressureAxisModel
            value: registry.addArrayParam(MemoryRange.S32, paramId.transmission_gear_5_main_pressure, pressureAxisModel.count, true, true, slots.pressure)
        },
        TableParam {
            x: pressureAxisModel
            value: registry.addArrayParam(MemoryRange.S32, paramId.transmission_gear_6_main_pressure, pressureAxisModel.count, true, true, slots.pressure)
        },
        TableParam {
            x: pressureAxisModel
            value: registry.addArrayParam(MemoryRange.S32, paramId.transmission_gear_7_main_pressure, pressureAxisModel.count, true, true, slots.pressure)
        },
        TableParam {
            x: pressureAxisModel
            value: registry.addArrayParam(MemoryRange.S32, paramId.transmission_gear_8_main_pressure, pressureAxisModel.count, true, true, slots.pressure)
        }
    ]

    property
    list<TableParam> transmissionUpshiftApplyPercentage: [
        TableParam {
            x: pressureAxisModel
            value: registry.addArrayParam(MemoryRange.S32, paramId.transmission_shift_n_1_apply_percentage, pressureAxisModel.count, true, true, slots.percentage1)
        },
        TableParam {
            x: pressureAxisModel
            value: registry.addArrayParam(MemoryRange.S32, paramId.transmission_shift_1_2_apply_percentage, pressureAxisModel.count, true, true, slots.percentage1)
        },
        TableParam {
            x: pressureAxisModel
            value: registry.addArrayParam(MemoryRange.S32, paramId.transmission_shift_2_3_apply_percentage, pressureAxisModel.count, true, true, slots.percentage1)
        },
        TableParam {
            x: pressureAxisModel
            value: registry.addArrayParam(MemoryRange.S32, paramId.transmission_shift_3_4_apply_percentage, pressureAxisModel.count, true, true, slots.percentage1)
        },
        TableParam {
            x: pressureAxisModel
            value: registry.addArrayParam(MemoryRange.S32, paramId.transmission_shift_4_5_apply_percentage, pressureAxisModel.count, true, true, slots.percentage1)
        },
        TableParam {
            x: pressureAxisModel
            value: registry.addArrayParam(MemoryRange.S32, paramId.transmission_shift_5_6_apply_percentage, pressureAxisModel.count, true, true, slots.percentage1)
        },
        TableParam {
            x: pressureAxisModel
            value: registry.addArrayParam(MemoryRange.S32, paramId.transmission_shift_6_7_apply_percentage, pressureAxisModel.count, true, true, slots.percentage1)
        },
        TableParam {
            x: pressureAxisModel
            value: registry.addArrayParam(MemoryRange.S32, paramId.transmission_shift_7_8_apply_percentage, pressureAxisModel.count, true, true, slots.percentage1)
        }
    ]

    property
    list<TableParam> transmissionDownshiftApplyPercentage: [
        TableParam {
            x: pressureAxisModel
            value: registry.addArrayParam(MemoryRange.S32, paramId.transmission_shift_2_1_apply_percentage, pressureAxisModel.count, true, true, slots.percentage1)
        },
        TableParam {
            x: pressureAxisModel
            value: registry.addArrayParam(MemoryRange.S32, paramId.transmission_shift_3_2_apply_percentage, pressureAxisModel.count, true, true, slots.percentage1)
        },
        TableParam {
            x: pressureAxisModel
            value: registry.addArrayParam(MemoryRange.S32, paramId.transmission_shift_4_3_apply_percentage, pressureAxisModel.count, true, true, slots.percentage1)
        },
        TableParam {
            x: pressureAxisModel
            value: registry.addArrayParam(MemoryRange.S32, paramId.transmission_shift_5_4_apply_percentage, pressureAxisModel.count, true, true, slots.percentage1)
        },
        TableParam {
            x: pressureAxisModel
            value: registry.addArrayParam(MemoryRange.S32, paramId.transmission_shift_6_5_apply_percentage, pressureAxisModel.count, true, true, slots.percentage1)
        },
        TableParam {
            x: pressureAxisModel
            value: registry.addArrayParam(MemoryRange.S32, paramId.transmission_shift_7_6_apply_percentage, pressureAxisModel.count, true, true, slots.percentage1)
        },
        TableParam {
            x: pressureAxisModel
            value: registry.addArrayParam(MemoryRange.S32, paramId.transmission_shift_8_7_apply_percentage, pressureAxisModel.count, true, true, slots.percentage1)
        }
    ]


    property
    list<TableParam> transmissionUpshiftReleasePercentage: [
        TableParam {
            x: pressureAxisModel
            value: registry.addArrayParam(MemoryRange.S32, paramId.transmission_shift_1_2_release_percentage, pressureAxisModel.count, true, true, slots.percentage1)
        },
        TableParam {
            x: pressureAxisModel
            value: registry.addArrayParam(MemoryRange.S32, paramId.transmission_shift_2_3_release_percentage, pressureAxisModel.count, true, true, slots.percentage1)
        },
        TableParam {
            x: pressureAxisModel
            value: registry.addArrayParam(MemoryRange.S32, paramId.transmission_shift_3_4_release_percentage, pressureAxisModel.count, true, true, slots.percentage1)
        },
        TableParam {
            x: pressureAxisModel
            value: registry.addArrayParam(MemoryRange.S32, paramId.transmission_shift_4_5_release_percentage, pressureAxisModel.count, true, true, slots.percentage1)
        },
        TableParam {
            x: pressureAxisModel
            value: registry.addArrayParam(MemoryRange.S32, paramId.transmission_shift_5_6_release_percentage, pressureAxisModel.count, true, true, slots.percentage1)
        },
        TableParam {
            x: pressureAxisModel
            value: registry.addArrayParam(MemoryRange.S32, paramId.transmission_shift_6_7_release_percentage, pressureAxisModel.count, true, true, slots.percentage1)
        },
        TableParam {
            x: pressureAxisModel
            value: registry.addArrayParam(MemoryRange.S32, paramId.transmission_shift_7_8_release_percentage, pressureAxisModel.count, true, true, slots.percentage1)
        }
    ]

    property
    list<TableParam> transmissionDownshiftReleasePercentage: [
        TableParam {
            x: pressureAxisModel
            value: registry.addArrayParam(MemoryRange.S32, paramId.transmission_shift_2_1_release_percentage, pressureAxisModel.count, true, true, slots.percentage1)
        },
        TableParam {
            x: pressureAxisModel
            value: registry.addArrayParam(MemoryRange.S32, paramId.transmission_shift_3_2_release_percentage, pressureAxisModel.count, true, true, slots.percentage1)
        },
        TableParam {
            x: pressureAxisModel
            value: registry.addArrayParam(MemoryRange.S32, paramId.transmission_shift_4_3_release_percentage, pressureAxisModel.count, true, true, slots.percentage1)
        },
        TableParam {
            x: pressureAxisModel
            value: registry.addArrayParam(MemoryRange.S32, paramId.transmission_shift_5_4_release_percentage, pressureAxisModel.count, true, true, slots.percentage1)
        },
        TableParam {
            x: pressureAxisModel
            value: registry.addArrayParam(MemoryRange.S32, paramId.transmission_shift_6_5_release_percentage, pressureAxisModel.count, true, true, slots.percentage1)
        },
        TableParam {
            x: pressureAxisModel
            value: registry.addArrayParam(MemoryRange.S32, paramId.transmission_shift_7_6_release_percentage, pressureAxisModel.count, true, true, slots.percentage1)
        },
        TableParam {
            x: pressureAxisModel
            value: registry.addArrayParam(MemoryRange.S32, paramId.transmission_shift_8_7_release_percentage, pressureAxisModel.count, true, true, slots.percentage1)
        }
    ]

    property
    list<TableParam> transmissionMainPercentage: [
        TableParam {
            x: pressureAxisModel
            value: registry.addArrayParam(MemoryRange.S32, paramId.transmission_gear_1_main_percentage, pressureAxisModel.count, true, true, slots.percentage1)
        },
        TableParam {
            x: pressureAxisModel
            value: registry.addArrayParam(MemoryRange.S32, paramId.transmission_gear_2_main_percentage, pressureAxisModel.count, true, true, slots.percentage1)
        },
        TableParam {
            x: pressureAxisModel
            value: registry.addArrayParam(MemoryRange.S32, paramId.transmission_gear_3_main_percentage, pressureAxisModel.count, true, true, slots.percentage1)
        },
        TableParam {
            x: pressureAxisModel
            value: registry.addArrayParam(MemoryRange.S32, paramId.transmission_gear_4_main_percentage, pressureAxisModel.count, true, true, slots.percentage1)
        },
        TableParam {
            x: pressureAxisModel
            value: registry.addArrayParam(MemoryRange.S32, paramId.transmission_gear_5_main_percentage, pressureAxisModel.count, true, true, slots.percentage1)
        },
        TableParam {
            x: pressureAxisModel
            value: registry.addArrayParam(MemoryRange.S32, paramId.transmission_gear_6_main_percentage, pressureAxisModel.count, true, true, slots.percentage1)
        },
        TableParam {
            x: pressureAxisModel
            value: registry.addArrayParam(MemoryRange.S32, paramId.transmission_gear_7_main_percentage, pressureAxisModel.count, true, true, slots.percentage1)
        },
        TableParam {
            x: pressureAxisModel
            value: registry.addArrayParam(MemoryRange.S32, paramId.transmission_gear_8_main_percentage, pressureAxisModel.count, true, true, slots.percentage1)
        }
    ]

    readonly property ScalarParam powertrainType: registry.addScalarParam(MemoryRange.S32, paramId.transmission_type, true, true, slots.transmissionType1)

    readonly property ScalarParam pressureR2LBoostA: registry.addScalarParam(MemoryRange.S32, paramId.pressure_r2l_boost_a, true, true, slots.percentage1)

    readonly property ScalarParam pressureR2LBoostB: registry.addScalarParam(MemoryRange.S32, paramId.pressure_r2l_boost_b, true, true, slots.percentage1)

    property TableParam displayColor: TableParam {
        x: colorIndexAxisModel
        value: registry.addArrayParam(MemoryRange.S32, paramId.display_color, colorIndexAxisModel.count, true, true, slots.percentage1)
    }

    readonly property ScalarParam displayBrightness: registry.addScalarParam(MemoryRange.S32, paramId.display_brightness, true, true, slots.percentage1)

    readonly property ScalarParam displayContrast: registry.addScalarParam(MemoryRange.S32, paramId.display_contrast, true, true, slots.percentage1)

    readonly property ScalarParam shiftDownshiftOffsetA: registry.addScalarParam(MemoryRange.S32, paramId.shift_downshift_offset_a, true, true, slots.percentage1)

    readonly property ScalarParam shiftDownshiftOffsetB: registry.addScalarParam(MemoryRange.S32, paramId.shift_downshift_offset_b, true, true, slots.percentage1)

    readonly property ScalarParam engineCylinders: registry.addScalarParam(MemoryRange.S32, paramId.engine_cylinders, true, true, slots.count2)

    readonly property ScalarParam engineRunningDetectionSpeed: registry.addScalarParam(MemoryRange.S32, paramId.engine_running_detection_speed, true, true, slots.rpm1)

    readonly property ScalarParam engineIdleShutdownTime: registry.addScalarParam(MemoryRange.S32, paramId.engine_idle_shutdown_time, true, true, slots.timeInSecondsZeroIsDisabled)

    readonly property ArrayParam engineTorqueMapSpeedsArray: registry.addArrayParam(MemoryRange.S32, paramId.engine_torque_map_speeds, 11, true, true, slots.rpm1)
    property TableParam engineMotorTorqueMap: TableParam {
        x: engineTorqueMapSpeedsArray
        value: registry.addArrayParam(MemoryRange.S32, paramId.engine_motor_torque_map, 11, true, true, slots.percentage2)
    }
    property TableParam engineBrakeTorqueMap: TableParam {
        x: engineTorqueMapSpeedsArray
        value: registry.addArrayParam(MemoryRange.S32, paramId.engine_braking_torque_map, 11, true, true, slots.percentage2)
    }
    property TableMapperModel engineTorqueMap: TableMapperModel {
        mapping: {
            "rpm" : engineTorqueMapSpeedsArray.stringModel,
                    "motoring": engineMotorTorqueMap.value.stringModel,
                    "braking": engineBrakeTorqueMap.value.stringModel
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

    property
    list<TableParam> pressureTablesA: [
        TableParam {
            x: percentage1AxisModel
            value: registry.addArrayParam(MemoryRange.S32, paramId.pressure_tables_a_1, percentage1AxisModel.count, true, true, slots.percentage1)
        },
        TableParam {
            x: percentage1AxisModel
            value: registry.addArrayParam(MemoryRange.S32, paramId.pressure_tables_a_2, percentage1AxisModel.count, true, true, slots.percentage1)
        },
        TableParam {
            x: percentage1AxisModel
            value: registry.addArrayParam(MemoryRange.S32, paramId.pressure_tables_a_3, percentage1AxisModel.count, true, true, slots.percentage1)
        },
        TableParam {
            x: percentage1AxisModel
            value: registry.addArrayParam(MemoryRange.S32, paramId.pressure_tables_a_4, percentage1AxisModel.count, true, true, slots.percentage1)
        },
        TableParam {
            x: percentage1AxisModel
            value: registry.addArrayParam(MemoryRange.S32, paramId.pressure_tables_a_5, percentage1AxisModel.count, true, true, slots.percentage1)
        },
        TableParam {
            x: percentage1AxisModel
            value: registry.addArrayParam(MemoryRange.S32, paramId.pressure_tables_a_6, percentage1AxisModel.count, true, true, slots.percentage1)
        }
    ]

    property
    list<TableParam> pressureTablesB: [
        TableParam {
            x: percentage1AxisModel
            value: registry.addArrayParam(MemoryRange.S32, paramId.pressure_tables_b_1, percentage1AxisModel.count, true, true, slots.percentage1)
        },
        TableParam {
            x: percentage1AxisModel
            value: registry.addArrayParam(MemoryRange.S32, paramId.pressure_tables_b_2, percentage1AxisModel.count, true, true, slots.percentage1)
        },
        TableParam {
            x: percentage1AxisModel
            value: registry.addArrayParam(MemoryRange.S32, paramId.pressure_tables_b_3, percentage1AxisModel.count, true, true, slots.percentage1)
        },
        TableParam {
            x: percentage1AxisModel
            value: registry.addArrayParam(MemoryRange.S32, paramId.pressure_tables_b_4, percentage1AxisModel.count, true, true, slots.percentage1)
        },
        TableParam {
            x: percentage1AxisModel
            value: registry.addArrayParam(MemoryRange.S32, paramId.pressure_tables_b_5, percentage1AxisModel.count, true, true, slots.percentage1)
        },
        TableParam {
            x: percentage1AxisModel
            value: registry.addArrayParam(MemoryRange.S32, paramId.pressure_tables_b_6, percentage1AxisModel.count, true, true, slots.percentage1)
        }
    ]

    readonly property ScalarParam shiftSpeedAdjustA: registry.addScalarParam(MemoryRange.S32, paramId.shift_speed_adjust_a, true, true, slots.percentage1)

    readonly property ScalarParam shiftSpeedAdjustB: registry.addScalarParam(MemoryRange.S32, paramId.shift_speed_adjust_b, true, true, slots.percentage1)

    property
    list<TableParam> shiftTablesA: [
        TableParam {
            x: percentage1AxisModel
            value: registry.addArrayParam(MemoryRange.S32, paramId.shift_tables_a_1, percentage1AxisModel.count, true, true, slots.tossRPMAsSpeed)
        },
        TableParam {
            x: percentage1AxisModel
            value: registry.addArrayParam(MemoryRange.S32, paramId.shift_tables_a_2, percentage1AxisModel.count, true, true, slots.tossRPMAsSpeed)
        },
        TableParam {
            x: percentage1AxisModel
            value: registry.addArrayParam(MemoryRange.S32, paramId.shift_tables_a_3, percentage1AxisModel.count, true, true, slots.tossRPMAsSpeed)
        },
        TableParam {
            x: percentage1AxisModel
            value: registry.addArrayParam(MemoryRange.S32, paramId.shift_tables_a_4, percentage1AxisModel.count, true, true, slots.tossRPMAsSpeed)
        },
        TableParam {
            x: percentage1AxisModel
            value: registry.addArrayParam(MemoryRange.S32, paramId.shift_tables_a_5, percentage1AxisModel.count, true, true, slots.tossRPMAsSpeed)
        }
    ]
    property
    list<TableParam> rpmShiftTablesA: [
        TableParam {
            x: percentage1AxisModel
            value: SlotProxyModel {
                sourceModel: shiftTablesA[0].value.rawModel
                slot: slots.rpm1
            }
        },
        TableParam {
            x: percentage1AxisModel
            value: SlotProxyModel {
                sourceModel: shiftTablesA[1].value.rawModel
                slot: slots.rpm1
            }
        },
        TableParam {
            x: percentage1AxisModel
            value: SlotProxyModel {
                sourceModel: shiftTablesA[2].value.rawModel
                slot: slots.rpm1
            }
        },
        TableParam {
            x: percentage1AxisModel
            value: SlotProxyModel {
                sourceModel: shiftTablesA[3].value.rawModel
                slot: slots.rpm1
            }
        },
        TableParam {
            x: percentage1AxisModel
            value: SlotProxyModel {
                sourceModel: shiftTablesA[4].value.rawModel
                slot: slots.rpm1
            }
        }
    ]
    property TableMapperModel shiftTablesAModel: TableMapperModel {
        mapping: {
            "tps": percentage1AxisModel,
                    "shift12": shiftTablesA[0].value.stringModel,
                    "shift23": shiftTablesA[1].value.stringModel,
                    "shift34": shiftTablesA[2].value.stringModel,
                    "shift45": shiftTablesA[3].value.stringModel,
                    "shift56": shiftTablesA[4].value.stringModel
        }
    }

    property
    list<TableParam> shiftTablesB: [
        TableParam {
            x: percentage1AxisModel
            value: registry.addArrayParam(MemoryRange.S32, paramId.shift_tables_b_1, percentage1AxisModel.count, true, true, slots.tossRPMAsSpeed)
        },
        TableParam {
            x: percentage1AxisModel
            value: registry.addArrayParam(MemoryRange.S32, paramId.shift_tables_b_2, percentage1AxisModel.count, true, true, slots.tossRPMAsSpeed)
        },
        TableParam {
            x: percentage1AxisModel
            value: registry.addArrayParam(MemoryRange.S32, paramId.shift_tables_b_3, percentage1AxisModel.count, true, true, slots.tossRPMAsSpeed)
        },
        TableParam {
            x: percentage1AxisModel
            value: registry.addArrayParam(MemoryRange.S32, paramId.shift_tables_b_4, percentage1AxisModel.count, true, true, slots.tossRPMAsSpeed)
        },
        TableParam {
            x: percentage1AxisModel
            value: registry.addArrayParam(MemoryRange.S32, paramId.shift_tables_b_5, percentage1AxisModel.count, true, true, slots.tossRPMAsSpeed)
        }
    ]
    property
    list<TableParam> rpmShiftTablesB: [
        TableParam {
            x: percentage1AxisModel
            value: SlotProxyModel {
                sourceModel: shiftTablesB[0].value.rawModel
                slot: slots.rpm1
            }
        },
        TableParam {
            x: percentage1AxisModel
            value: SlotProxyModel {
                sourceModel: shiftTablesB[1].value.rawModel
                slot: slots.rpm1
            }
        },
        TableParam {
            x: percentage1AxisModel
            value: SlotProxyModel {
                sourceModel: shiftTablesB[2].value.rawModel
                slot: slots.rpm1
            }
        },
        TableParam {
            x: percentage1AxisModel
            value: SlotProxyModel {
                sourceModel: shiftTablesB[3].value.rawModel
                slot: slots.rpm1
            }
        },
        TableParam {
            x: percentage1AxisModel
            value: SlotProxyModel {
                sourceModel: shiftTablesB[4].value.rawModel
                slot: slots.rpm1
            }
        }
    ]
    property TableMapperModel shiftTablesBModel: TableMapperModel {
        mapping: {
            "tps": percentage1AxisModel,
                    "shift12": shiftTablesB[0].value.stringModel,
                    "shift23": shiftTablesB[1].value.stringModel,
                    "shift34": shiftTablesB[2].value.stringModel,
                    "shift45": shiftTablesB[3].value.stringModel,
                    "shift56": shiftTablesB[4].value.stringModel
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

    property TableParam tccApplyPressure: TableParam {
        x: slipAxisModel
        value: registry.addArrayParam(MemoryRange.S32, paramId.tcc_apply_pressure, slipAxisModel.count, true, true, slots.percentage1)
    }

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

    property TableParam shiftSelectorGearVoltages: TableParam {
        x: hgmShiftSelectorCalibrationGearAxisModel
        value: registry.addArrayParam(MemoryRange.S32, paramId.shift_selector_gear_voltages, hgmShiftSelectorCalibrationGearAxisModel.count, true, true, slots.hgmShiftSelectorCalibrationSensorVoltage)
    }

    readonly property ScalarParam shiftSelectorODCancelAtStartup: registry.addScalarParam(MemoryRange.S32, paramId.shift_selector_overdrive_cancel_at_startup, true, true, slots.booleanOnOff1)

    readonly property ScalarParam displayUnits: registry.addScalarParam(MemoryRange.S32, paramId.use_metric_units, true, true, slots.measurementSystem)

    readonly property ScalarParam speedometerCalibration: registry.addScalarParam(MemoryRange.S32, paramId.speedometer_calibration, true, true, slots.speedoCalibration)

    readonly property ScalarParam startInhibitRelayType: registry.addScalarParam(MemoryRange.S32, paramId.start_inhibit_relay_type, true, true, slots.booleanNormalReversed)

    readonly property ScalarParam vehicleSpeedSensorPulseCount: registry.addScalarParam(MemoryRange.S32, paramId.vehicle_speed_sensor_pulse_count, true, true, slots.count3)

    readonly property ScalarParam transmissionGear0Number: registry.addScalarParam(MemoryRange.S32, paramId.transmission_gears + 0, false, false, slots.count2)
    readonly property ScalarParam transmissionGear1Number: registry.addScalarParam(MemoryRange.S32, paramId.transmission_gears + 1, false, false, slots.count2)
    readonly property ScalarParam transmissionGear2Number: registry.addScalarParam(MemoryRange.S32, paramId.transmission_gears + 2, false, false, slots.count2)
    readonly property ScalarParam transmissionGear3Number: registry.addScalarParam(MemoryRange.S32, paramId.transmission_gears + 3, false, false, slots.count2)
    readonly property ScalarParam transmissionGear4Number: registry.addScalarParam(MemoryRange.S32, paramId.transmission_gears + 4, false, false, slots.count2)
    readonly property ScalarParam transmissionGear5Number: registry.addScalarParam(MemoryRange.S32, paramId.transmission_gears + 5, false, false, slots.count2)
    readonly property ScalarParam transmissionGear6Number: registry.addScalarParam(MemoryRange.S32, paramId.transmission_gears + 6, false, false, slots.count2)
    readonly property ScalarParam transmissionGear7Number: registry.addScalarParam(MemoryRange.S32, paramId.transmission_gears + 7, false, false, slots.count2)

    readonly property ScalarParam transmissionGear0Ratio: registry.addScalarParam(MemoryRange.S32, paramId.transmission_ratios + 0, false, false, slots.ratio1)
    readonly property ScalarParam transmissionGear1Ratio: registry.addScalarParam(MemoryRange.S32, paramId.transmission_ratios + 1, false, false, slots.ratio1)
    readonly property ScalarParam transmissionGear2Ratio: registry.addScalarParam(MemoryRange.S32, paramId.transmission_ratios + 2, false, false, slots.ratio1)
    readonly property ScalarParam transmissionGear3Ratio: registry.addScalarParam(MemoryRange.S32, paramId.transmission_ratios + 3, false, false, slots.ratio1)
    readonly property ScalarParam transmissionGear4Ratio: registry.addScalarParam(MemoryRange.S32, paramId.transmission_ratios + 4, false, false, slots.ratio1)
    readonly property ScalarParam transmissionGear5Ratio: registry.addScalarParam(MemoryRange.S32, paramId.transmission_ratios + 5, false, false, slots.ratio1)
    readonly property ScalarParam transmissionGear6Ratio: registry.addScalarParam(MemoryRange.S32, paramId.transmission_ratios + 6, false, false, slots.ratio1)
    readonly property ScalarParam transmissionGear7Ratio: registry.addScalarParam(MemoryRange.S32, paramId.transmission_ratios + 7, false, false, slots.ratio1)

    property var transmissionGearNumbers: [
        transmissionGear0Number,
        transmissionGear1Number,
        transmissionGear2Number,
        transmissionGear3Number,
        transmissionGear4Number,
        transmissionGear5Number,
        transmissionGear6Number,
        transmissionGear7Number
    ]

    property var transmissionGearRatios: [
        transmissionGear0Ratio,
        transmissionGear1Ratio,
        transmissionGear2Ratio,
        transmissionGear3Ratio,
        transmissionGear4Ratio,
        transmissionGear5Ratio,
        transmissionGear6Ratio,
        transmissionGear7Ratio
    ]
}

