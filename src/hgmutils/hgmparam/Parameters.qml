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
        tireDiameter: parameters.tireDiameter.param.floatVal
        finalDriveRatio: parameters.finalDriveRatio.param.floatVal
    }

    property ScalarMetaParam transmissionTurbineShaftSpeedSensorPulseCount: ScalarMetaParam {
        param: registry.addScalarParam(MemoryRange.S32, paramId.transmission_turbine_shaft_speed_sensor_pulse_count, true, true, slots.count3)
        name: qsTr("Turbine Speed Sensor Pulses")
    }

    property ScalarMetaParam transmissionInputShaftSpeedSensorPulseCount: ScalarMetaParam {
        param: registry.addScalarParam(MemoryRange.S32, paramId.transmission_input_shaft_speed_sensor_pulse_count, true, true, slots.count3)
        name: qsTr("Input Shaft Speed Sensor Pulses")
    }

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
    property SlotArrayModel switchIdAxisModel: SlotArrayModel {
        slot: slots.switchId
        count: 22
    }


    //readonly property ArrayParam controllerSoftwareVersion: registry.addArrayParam(MemoryRange.S32, paramId.controller_software_version, false, false, slots)
    property ScalarMetaParam controllerHeapUsed: ScalarMetaParam {
        param: registry.addScalarParam(MemoryRange.S32, paramId.controller_heap_used, false, false, slots.count)
        name: qsTr("Heap Used")
    }

    property ScalarMetaParam controllerHeapSize: ScalarMetaParam {
        param: registry.addScalarParam(MemoryRange.S32, paramId.controller_heap_size, false, false, slots.count)
        name: qsTr("Heap Size")
    }

    property ScalarMetaParam controllerHeapAllocationCount: ScalarMetaParam {
        param: registry.addScalarParam(MemoryRange.S32, paramId.controller_heap_allocation_count, false, false, slots.count)
        name: qsTr("Allocation Count")
    }

    property ScalarMetaParam controllerHeapReleaseCount: ScalarMetaParam {
        param: registry.addScalarParam(MemoryRange.S32, paramId.controller_heap_release_count, false, false, slots.count)
        name: qsTr("Release Count")
    }

    property ScalarMetaParam controllerTachInputFrequency: ScalarMetaParam {
        param: registry.addScalarParam(MemoryRange.S32, paramId.controller_tach_input_frequency, false, false, slots.frequency)
        name: qsTr("Tachometer")
    }

    property ScalarMetaParam controllerTissInputFrequency: ScalarMetaParam {
        param: registry.addScalarParam(MemoryRange.S32, paramId.controller_tiss_input_frequency, false, false, slots.frequency)
        name: qsTr("TISS")
    }

    property ScalarMetaParam controllerTossInputFrequency: ScalarMetaParam {
        param: registry.addScalarParam(MemoryRange.S32, paramId.controller_toss_input_frequency, false, false, slots.frequency)
        name: qsTr("TOSS")
    }

    property ScalarMetaParam controllerSpareInputFrequency: ScalarMetaParam {
        param: registry.addScalarParam(MemoryRange.S32, paramId.controller_spare_input_frequency, false, false, slots.frequency)
        name: qsTr("Spare")
    }

    property ScalarMetaParam controllerThrottlePositionSensorVoltage: ScalarMetaParam {
        param: registry.addScalarParam(MemoryRange.S32, paramId.controller_throttle_position_sensor_voltage, false, false, slots.voltage1)
        name: qsTr("Throttle Position")
    }

    property ScalarMetaParam controllerMAPSensorVoltage: ScalarMetaParam {
        param: registry.addScalarParam(MemoryRange.S32, paramId.controller_map_sensor_voltage, false, false, slots.voltage1)
        name: qsTr("MAP")
    }

    property ScalarMetaParam controllerInternalTemperatureSensorVoltage: ScalarMetaParam {
        param: registry.addScalarParam(MemoryRange.S32, paramId.controller_internal_temperature_sensor_voltage, false, false, slots.voltage1)
        name: qsTr("Internal Temp")
    }

    property ScalarMetaParam controllerInternalTemperature: ScalarMetaParam {
        param: registry.addScalarParam(MemoryRange.S32, paramId.controller_internal_temperature, false, false, slots.temperature1)
        name: qsTr("Internal Temp")
    }

    property ScalarMetaParam controllerEngineTemperatureSensorVoltage: ScalarMetaParam {
        param: registry.addScalarParam(MemoryRange.S32, paramId.controller_engine_temperature_sensor_voltage, false, false, slots.voltage1)
        name: qsTr("Engine Temp")
    }

    property ScalarMetaParam controllerTransmissionTemperatureSensorVoltage: ScalarMetaParam {
        param: registry.addScalarParam(MemoryRange.S32, paramId.controller_transmission_temperature_sensor_voltage, false, false, slots.voltage1)
        name: qsTr("Trans Temp")
    }

    property ScalarMetaParam controllerMultiplexedSensorVoltage: ScalarMetaParam {
        param: registry.addScalarParam(MemoryRange.S32, paramId.controller_multiplexed_sensor_voltage, false, false, slots.voltage1)
        name: qsTr("Multiplex")
    }

    property ScalarMetaParam controllerBus5Voltage: ScalarMetaParam {
        param: registry.addScalarParam(MemoryRange.S32, paramId.controller_5_volt_bus_voltage, false, false, slots.voltage1)
        name: qsTr("5V Bus")
    }

    property ScalarMetaParam controllerBus3_3Voltage: ScalarMetaParam {
        param: registry.addScalarParam(MemoryRange.S32, paramId.controller_3_3_volt_bus_voltage, false, false, slots.voltage1)
        name: qsTr("3.3V Bus")
    }

    property ScalarMetaParam controllerBus1_8Voltage: ScalarMetaParam {
        param: registry.addScalarParam(MemoryRange.S32, paramId.controller_1_8_volt_bus_voltage, false, false, slots.voltage1)
        name: qsTr("1.8V Bus")
    }

    property ScalarMetaParam controllerBus12Voltage: ScalarMetaParam {
        param: registry.addScalarParam(MemoryRange.S32, paramId.controller_12_volt_bus_voltage, false, false, slots.voltage1)
        name: qsTr("12V Bus")
    }

    property ScalarMetaParam controllerBusVoltage: ScalarMetaParam {
        param: registry.addScalarParam(MemoryRange.S32, paramId.controller_voltage, false, false, slots.voltage1)
        name: qsTr("Main Bus")
    }

    property ScalarMetaParam controllerSpeedTimer1Frequency: ScalarMetaParam {
        param: registry.addScalarParam(MemoryRange.S32, paramId.controller_speed_timer_1_frequency, true, false, slots.frequency)
        name: qsTr("Speed 1")
        immediateWrite: true
    }

    property ScalarMetaParam controllerSpeedTimer2Frequency: ScalarMetaParam {
        param: registry.addScalarParam(MemoryRange.S32, paramId.controller_speed_timer_2_frequency, true, false, slots.frequency)
        name: qsTr("Speed 2")
        immediateWrite: true
    }

    property TableMetaParam controllerSwitchState: TableMetaParam {
        param: TableParam {
            x: switchIdAxisModel
            value: registry.addArrayParam(MemoryRange.S32, paramId.controller_switch_state, switchIdAxisModel.count, false, false, slots.booleanOnOff1)
        }
        name: qsTr("Switch Monitor Input")
    }

    property TableMetaParam controllerSwitchCurrent: TableMetaParam {
        param: TableParam {
            x: switchIdAxisModel
            value: registry.addArrayParam(MemoryRange.S32, paramId.controller_switch_current, switchIdAxisModel.count, false, false, slots.booleanOnOff1)
        }
        name: qsTr("Switch Monitor Output")
    }

    property MultiroleTableMetaParam controllerSwitchMonitor: MultiroleTableMetaParam {
        param: MultiroleTableParam {
            roleMapping: {
                "x": switchIdAxisModel,
                "input": controllerSwitchState.param.value,
                "output": controllerSwitchCurrent.param.value
            }
        }
        isLiveData: true
        name: qsTr("Switch Monitor")
    }

    property ScalarMetaParam controllerSDCardWriteProtect: ScalarMetaParam {
        param: registry.addScalarParam(MemoryRange.S32, paramId.controller_sd_card_write_protect, false, false, slots.booleanOnOff1)
        name: qsTr("SD Card Protect")
    }

    property ScalarMetaParam controllerSDCardPresent: ScalarMetaParam {
        param: registry.addScalarParam(MemoryRange.S32, paramId.controller_sd_card_present, false, false, slots.booleanOnOff1)
        name: qsTr("SD Card Present")
    }

    property ScalarMetaParam controllerMasterDriverFault: ScalarMetaParam {
        param: registry.addScalarParam(MemoryRange.S32, paramId.controller_master_driver_fault, false, false, slots.booleanOnOff1)
        name: qsTr("Master Driver Fault")
    }

    property ScalarMetaParam controllerUSBPower: ScalarMetaParam {
        param: registry.addScalarParam(MemoryRange.S32, paramId.controller_usb_power, false, false, slots.booleanOnOff1)
        name: qsTr("USB Power")
    }

    property ScalarMetaParam controllerUSBConnect: ScalarMetaParam {
        param: registry.addScalarParam(MemoryRange.S32, paramId.controller_usb_connect, false, false, slots.booleanOnOff1)
        name: qsTr("USB Connect")
        immediateWrite: true
    }

    property ScalarMetaParam controllerGreenLED: ScalarMetaParam {
        param: registry.addScalarParam(MemoryRange.S32, paramId.controller_green_led, false, false, slots.booleanOnOff1)
        name: qsTr("Green LED")
        immediateWrite: true
    }

    property ScalarMetaParam controllerRedLED: ScalarMetaParam {
        param: registry.addScalarParam( MemoryRange.S32, paramId.controller_red_led, false, false, slots.booleanOnOff1)
        name: qsTr("Red LED")
        immediateWrite: true
    }

    property ScalarMetaParam controllerTransmissionTemperatureSensorBias: ScalarMetaParam {
        param: registry.addScalarParam(MemoryRange.S32, paramId.controller_transmission_temperature_sensor_bias, false, false, slots.booleanOnOff1)
        name: qsTr("Trans Temperature Sensor Bias")
        immediateWrite: true
    }

    property ScalarMetaParam controllerEngineTemperatureSensorBias: ScalarMetaParam {
        param: registry.addScalarParam(MemoryRange.S32, paramId.controller_engine_temperature_sensor_bias, false, false, slots.booleanOnOff1)
        name: qsTr("Engine Temperature Sensor Bias")
        immediateWrite: true
    }

    property ScalarMetaParam controllerThrottlePositionSensorGround: ScalarMetaParam {
        param: registry.addScalarParam(MemoryRange.S32, paramId.controller_throttle_position_sensor_ground, false, false, slots.booleanOnOff1)
        name: qsTr("Throttle Position Sensor Ground")
        immediateWrite: true
    }

    property ScalarMetaParam controllerMAPSensorGround: ScalarMetaParam {
        param: registry.addScalarParam(MemoryRange.S32, paramId.controller_map_ground, false, false, slots.booleanOnOff1)
        name: qsTr("MAP Sensor Ground")
        immediateWrite: true
    }

    readonly property ArrayParam controllerPWMDriverFrequency: registry.addArrayParam(MemoryRange.S32, paramId.controller_pwmdriver_frequency, 12, true, false, slots.frequency)

    readonly property ArrayParam controllerPWMDriverDutyCycle: registry.addArrayParam(MemoryRange.S32, paramId.controller_pwmdriver_duty_cycle, 12, true, false, slots.percentage2)

    readonly property ArrayParam controllerPWMDriverMode: registry.addArrayParam(MemoryRange.S32, paramId.controller_pwmdriver_mode, 12, true, false, slots.pwmDriverMode)

    property SlotArrayModel controllerPWMDriverIdModel: SlotArrayModel {
        slot: slots.pwmDriverId
        count: 12
    }

    property MultiroleTableMetaParam controllerPWMDrivers: MultiroleTableMetaParam {
        param: MultiroleTableParam {
            roleMapping: {
                "x": controllerPWMDriverIdModel,
                "frequency": controllerPWMDriverFrequency,
                "dutyCycle": controllerPWMDriverDutyCycle,
                "mode": controllerPWMDriverMode
            }
        }
        isLiveData: true
    }

//    property ScalarMetaParam controllerAccelerometer: ScalarMetaParam {
//        param: registry.addScalarParam(MemoryRange.S32, paramId.controller_acclerometer, false, false, slots)
//        name: qsTr("")
//    }

    //    readonly property ArrayParam : registry.addScalarParam(MemoryRange.S32, paramId.controller_switch_state, false, false, slots)
    //    readonly property ArrayParam : registry.addScalarParam(MemoryRange.S32, paramId.controller_switch_current, false, false, slots)

    property ScalarMetaParamList transmissionShaftSpeedSensorPulseCount: ScalarMetaParamList {
        ScalarMetaParam {
            param: registry.addScalarParam(MemoryRange.S32, paramId.transmission_shaft_1_speed_sensor_pulse_count, true, true, slots.count3)
            name: qsTr("Trans Shaft 1 Pulses")
        }
        ScalarMetaParam {
            param: registry.addScalarParam(MemoryRange.S32, paramId.transmission_shaft_2_speed_sensor_pulse_count, true, true, slots.count3)
            name: qsTr("Trans Shaft 2 Pulses")
        }
        ScalarMetaParam {
            param: registry.addScalarParam(MemoryRange.S32, paramId.transmission_shaft_3_speed_sensor_pulse_count, true, true, slots.count3)
            name: qsTr("Trans Shaft 3 Pulses")
        }
        ScalarMetaParam {
            param: registry.addScalarParam(MemoryRange.S32, paramId.transmission_shaft_4_speed_sensor_pulse_count, true, true, slots.count3)
            name: qsTr("Trans Shaft 4 Pulses")
        }
        ScalarMetaParam {
            param: registry.addScalarParam(MemoryRange.S32, paramId.transmission_shaft_5_speed_sensor_pulse_count, true, true, slots.count3)
            name: qsTr("Trans Shaft 5 Pulses")
        }
        ScalarMetaParam {
            param: registry.addScalarParam(MemoryRange.S32, paramId.transmission_shaft_6_speed_sensor_pulse_count, true, true, slots.count3)
            name: qsTr("Trans Shaft 6 Pulses")
        }
    }

    property ScalarMetaParamList transmissionShiftPrefillTime: ScalarMetaParamList {
        ScalarMetaParam {
            name: qsTr("Prefill Time R-N")
            param: registry.addScalarParam(MemoryRange.S32, paramId.transmission_shift_r_n_prefill_time, true, true, slots.timeMilliseconds1)
        }
        ScalarMetaParam {
            name: qsTr("Prefill Time N-R")
            param: registry.addScalarParam(MemoryRange.S32, paramId.transmission_shift_n_r_prefill_time, true, true, slots.timeMilliseconds1)
        }
        ScalarMetaParam {
            name: qsTr("Prefill Time N-1")
            param: registry.addScalarParam(MemoryRange.S32, paramId.transmission_shift_n_1_prefill_time, true, true, slots.timeMilliseconds1)
        }
        ScalarMetaParam {
            name: qsTr("Prefill Time 1-N")
            param: registry.addScalarParam(MemoryRange.S32, paramId.transmission_shift_1_n_prefill_time, true, true, slots.timeMilliseconds1)
        }
        ScalarMetaParam {
            name: qsTr("Prefill Time 1-2")
            param: registry.addScalarParam(MemoryRange.S32, paramId.transmission_shift_1_2_prefill_time, true, true, slots.timeMilliseconds1)
        }
        ScalarMetaParam {
            name: qsTr("Prefill Time 2-1")
            param: registry.addScalarParam(MemoryRange.S32, paramId.transmission_shift_2_1_prefill_time, true, true, slots.timeMilliseconds1)
        }
        ScalarMetaParam {
            name: qsTr("Prefill Time 2-3")
            param: registry.addScalarParam(MemoryRange.S32, paramId.transmission_shift_2_3_prefill_time, true, true, slots.timeMilliseconds1)
        }
        ScalarMetaParam {
            name: qsTr("Prefill Time 3-2")
            param: registry.addScalarParam(MemoryRange.S32, paramId.transmission_shift_3_2_prefill_time, true, true, slots.timeMilliseconds1)
        }
        ScalarMetaParam {
            name: qsTr("Prefill Time 3-4")
            param: registry.addScalarParam(MemoryRange.S32, paramId.transmission_shift_3_4_prefill_time, true, true, slots.timeMilliseconds1)
        }
        ScalarMetaParam {
            name: qsTr("Prefill Time 4-3")
            param: registry.addScalarParam(MemoryRange.S32, paramId.transmission_shift_4_3_prefill_time, true, true, slots.timeMilliseconds1)
        }
        ScalarMetaParam {
            name: qsTr("Prefill Time 4-5")
            param: registry.addScalarParam(MemoryRange.S32, paramId.transmission_shift_4_5_prefill_time, true, true, slots.timeMilliseconds1)
        }
        ScalarMetaParam {
            name: qsTr("Prefill Time 5-4")
            param: registry.addScalarParam(MemoryRange.S32, paramId.transmission_shift_5_4_prefill_time, true, true, slots.timeMilliseconds1)
        }
        ScalarMetaParam {
            name: qsTr("Prefill Time 5-6")
            param: registry.addScalarParam(MemoryRange.S32, paramId.transmission_shift_5_6_prefill_time, true, true, slots.timeMilliseconds1)
        }
        ScalarMetaParam {
            name: qsTr("Prefill Time 6-5")
            param: registry.addScalarParam(MemoryRange.S32, paramId.transmission_shift_6_5_prefill_time, true, true, slots.timeMilliseconds1)
        }
    }

    property ScalarMetaParamList transmissionShiftPrefillPercentage: ScalarMetaParamList {
        ScalarMetaParam {
            name: qsTr("Prefill Pressure R-N")
            param: registry.addScalarParam(MemoryRange.S32, paramId.transmission_shift_r_n_prefill_percentage, true, true, slots.percentage1)
        }
        ScalarMetaParam {
            name: qsTr("Prefill Pressure N-R")
            param: registry.addScalarParam(MemoryRange.S32, paramId.transmission_shift_n_r_prefill_percentage, true, true, slots.percentage1)
        }
        ScalarMetaParam {
            name: qsTr("Prefill Pressure N-1")
            param: registry.addScalarParam(MemoryRange.S32, paramId.transmission_shift_n_1_prefill_percentage, true, true, slots.percentage1)
        }
        ScalarMetaParam {
            name: qsTr("Prefill Pressure 1-N")
            param: registry.addScalarParam(MemoryRange.S32, paramId.transmission_shift_1_n_prefill_percentage, true, true, slots.percentage1)
        }
        ScalarMetaParam {
            name: qsTr("Prefill Pressure 1-2")
            param: registry.addScalarParam(MemoryRange.S32, paramId.transmission_shift_1_2_prefill_percentage, true, true, slots.percentage1)
        }
        ScalarMetaParam {
            name: qsTr("Prefill Pressure 2-1")
            param: registry.addScalarParam(MemoryRange.S32, paramId.transmission_shift_2_1_prefill_percentage, true, true, slots.percentage1)
        }
        ScalarMetaParam {
            name: qsTr("Prefill Pressure 2-3")
            param: registry.addScalarParam(MemoryRange.S32, paramId.transmission_shift_2_3_prefill_percentage, true, true, slots.percentage1)
        }
        ScalarMetaParam {
            name: qsTr("Prefill Pressure 3-2")
            param: registry.addScalarParam(MemoryRange.S32, paramId.transmission_shift_3_2_prefill_percentage, true, true, slots.percentage1)
        }
        ScalarMetaParam {
            name: qsTr("Prefill Pressure 3-4")
            param: registry.addScalarParam(MemoryRange.S32, paramId.transmission_shift_3_4_prefill_percentage, true, true, slots.percentage1)
        }
        ScalarMetaParam {
            name: qsTr("Prefill Pressure 4-3")
            param: registry.addScalarParam(MemoryRange.S32, paramId.transmission_shift_4_3_prefill_percentage, true, true, slots.percentage1)
        }
        ScalarMetaParam {
            name: qsTr("Prefill Pressure 4-5")
            param: registry.addScalarParam(MemoryRange.S32, paramId.transmission_shift_4_5_prefill_percentage, true, true, slots.percentage1)
        }
        ScalarMetaParam {
            name: qsTr("Prefill Pressure 5-4")
            param: registry.addScalarParam(MemoryRange.S32, paramId.transmission_shift_5_4_prefill_percentage, true, true, slots.percentage1)
        }
        ScalarMetaParam {
            name: qsTr("Prefill Pressure 5-6")
            param: registry.addScalarParam(MemoryRange.S32, paramId.transmission_shift_5_6_prefill_percentage, true, true, slots.percentage1)
        }
        ScalarMetaParam {
            name: qsTr("Prefill Pressure 6-5")
            param: registry.addScalarParam(MemoryRange.S32, paramId.transmission_shift_6_5_prefill_percentage, true, true, slots.percentage1)
        }
    }

    property ScalarMetaParamList transmissionShiftPrefillPressure: ScalarMetaParamList {
        ScalarMetaParam {
            name: qsTr("Prefill Pressure R-N")
            param: registry.addScalarParam(MemoryRange.S32, paramId.transmission_shift_r_n_prefill_pressure, true, true, slots.pressure)
        }
        ScalarMetaParam {
            name: qsTr("Prefill Pressure N-R")
            param: registry.addScalarParam(MemoryRange.S32, paramId.transmission_shift_n_r_prefill_pressure, true, true, slots.pressure)
        }
        ScalarMetaParam {
            name: qsTr("Prefill Pressure N-1")
            param: registry.addScalarParam(MemoryRange.S32, paramId.transmission_shift_n_1_prefill_pressure, true, true, slots.pressure)
        }
        ScalarMetaParam {
            name: qsTr("Prefill Pressure 1-N")
            param: registry.addScalarParam(MemoryRange.S32, paramId.transmission_shift_1_n_prefill_pressure, true, true, slots.pressure)
        }
        ScalarMetaParam {
            name: qsTr("Prefill Pressure 1-2")
            param: registry.addScalarParam(MemoryRange.S32, paramId.transmission_shift_1_2_prefill_pressure, true, true, slots.pressure)
        }
        ScalarMetaParam {
            name: qsTr("Prefill Pressure 2-1")
            param: registry.addScalarParam(MemoryRange.S32, paramId.transmission_shift_2_1_prefill_pressure, true, true, slots.pressure)
        }
        ScalarMetaParam {
            name: qsTr("Prefill Pressure 2-3")
            param: registry.addScalarParam(MemoryRange.S32, paramId.transmission_shift_2_3_prefill_pressure, true, true, slots.pressure)
        }
        ScalarMetaParam {
            name: qsTr("Prefill Pressure 3-2")
            param: registry.addScalarParam(MemoryRange.S32, paramId.transmission_shift_3_2_prefill_pressure, true, true, slots.pressure)
        }
        ScalarMetaParam {
            name: qsTr("Prefill Pressure 3-4")
            param: registry.addScalarParam(MemoryRange.S32, paramId.transmission_shift_3_4_prefill_pressure, true, true, slots.pressure)
        }
        ScalarMetaParam {
            name: qsTr("Prefill Pressure 4-3")
            param: registry.addScalarParam(MemoryRange.S32, paramId.transmission_shift_4_3_prefill_pressure, true, true, slots.pressure)
        }
        ScalarMetaParam {
            name: qsTr("Prefill Pressure 4-5")
            param: registry.addScalarParam(MemoryRange.S32, paramId.transmission_shift_4_5_prefill_pressure, true, true, slots.pressure)
        }
        ScalarMetaParam {
            name: qsTr("Prefill Pressure 5-4")
            param: registry.addScalarParam(MemoryRange.S32, paramId.transmission_shift_5_4_prefill_pressure, true, true, slots.pressure)
        }
        ScalarMetaParam {
            name: qsTr("Prefill Pressure 5-6")
            param: registry.addScalarParam(MemoryRange.S32, paramId.transmission_shift_5_6_prefill_pressure, true, true, slots.pressure)
        }
        ScalarMetaParam {
            name: qsTr("Prefill Pressure 6-5")
            param: registry.addScalarParam(MemoryRange.S32, paramId.transmission_shift_6_5_prefill_pressure, true, true, slots.pressure)
        }
    }

    property ScalarMetaParam transmissionSTDownshiftTorqueThreshold: ScalarMetaParam {
        name: qsTr("ST Downshift Torque Threshold")
        param: registry.addScalarParam(MemoryRange.S32, paramId.transmission_st_downshift_torque_threshold, true, true, slots.percentage1)
    }

    property ScalarMetaParam transmissionSTUpshiftTorqueThreshold: ScalarMetaParam {
        name: qsTr("ST Upshift Torque Threshold")
        param: registry.addScalarParam(MemoryRange.S32, paramId.transmission_st_upshift_torque_threshold, true, true, slots.percentage1)
    }


    property ScalarMetaParamList transmissionTorqueSpeedTransferTime: ScalarMetaParamList {
        ScalarMetaParam {
            name: qsTr("TS Transfer Time R-N")
            param: registry.addScalarParam(MemoryRange.S32, paramId.transmission_shift_r_n_ts_transfer_time, true, true, slots.timeMilliseconds1)
        }
        ScalarMetaParam {
            name: qsTr("TS Transfer Time N-R")
            param: registry.addScalarParam(MemoryRange.S32, paramId.transmission_shift_n_r_ts_transfer_time, true, true, slots.timeMilliseconds1)
        }
        ScalarMetaParam {
            name: qsTr("TS Transfer Time N-1")
            param: registry.addScalarParam(MemoryRange.S32, paramId.transmission_shift_n_1_ts_transfer_time, true, true, slots.timeMilliseconds1)
        }
        ScalarMetaParam {
            name: qsTr("TS Transfer Time 1-N")
            param: registry.addScalarParam(MemoryRange.S32, paramId.transmission_shift_1_n_ts_transfer_time, true, true, slots.timeMilliseconds1)
        }
        ScalarMetaParam {
            name: qsTr("TS Transfer Time 1-2")
            param: registry.addScalarParam(MemoryRange.S32, paramId.transmission_shift_1_2_ts_transfer_time, true, true, slots.timeMilliseconds1)
        }
        ScalarMetaParam {
            name: qsTr("TS Transfer Time 2-1")
            param: registry.addScalarParam(MemoryRange.S32, paramId.transmission_shift_2_1_ts_transfer_time, true, true, slots.timeMilliseconds1)
        }
        ScalarMetaParam {
            name: qsTr("TS Transfer Time 2-3")
            param: registry.addScalarParam(MemoryRange.S32, paramId.transmission_shift_2_3_ts_transfer_time, true, true, slots.timeMilliseconds1)
        }
        ScalarMetaParam {
            name: qsTr("TS Transfer Time 3-2")
            param: registry.addScalarParam(MemoryRange.S32, paramId.transmission_shift_3_2_ts_transfer_time, true, true, slots.timeMilliseconds1)
        }
        ScalarMetaParam {
            name: qsTr("TS Transfer Time 3-4")
            param: registry.addScalarParam(MemoryRange.S32, paramId.transmission_shift_3_4_ts_transfer_time, true, true, slots.timeMilliseconds1)
        }
        ScalarMetaParam {
            name: qsTr("TS Transfer Time 4-3")
            param: registry.addScalarParam(MemoryRange.S32, paramId.transmission_shift_4_3_ts_transfer_time, true, true, slots.timeMilliseconds1)
        }
        ScalarMetaParam {
            name: qsTr("TS Transfer Time 4-5")
            param: registry.addScalarParam(MemoryRange.S32, paramId.transmission_shift_4_5_ts_transfer_time, true, true, slots.timeMilliseconds1)
        }
        ScalarMetaParam {
            name: qsTr("TS Transfer Time 5-4")
            param: registry.addScalarParam(MemoryRange.S32, paramId.transmission_shift_5_4_ts_transfer_time, true, true, slots.timeMilliseconds1)
        }
        ScalarMetaParam {
            name: qsTr("TS Transfer Time 5-6")
            param: registry.addScalarParam(MemoryRange.S32, paramId.transmission_shift_5_6_ts_transfer_time, true, true, slots.timeMilliseconds1)
        }
        ScalarMetaParam {
            name: qsTr("TS Transfer Time 6-5")
            param: registry.addScalarParam(MemoryRange.S32, paramId.transmission_shift_6_5_ts_transfer_time, true, true, slots.timeMilliseconds1)
        }
    }

    property ScalarMetaParamList transmissionSpeedTorqueTransferTime: ScalarMetaParamList {
        ScalarMetaParam {
            name: qsTr("ST Transfer Time R-N")
            param: registry.addScalarParam(MemoryRange.S32, paramId.transmission_shift_r_n_st_transfer_time, true, true, slots.timeMilliseconds1)
        }
        ScalarMetaParam {
            name: qsTr("ST Transfer Time N-R")
            param: registry.addScalarParam(MemoryRange.S32, paramId.transmission_shift_n_r_st_transfer_time, true, true, slots.timeMilliseconds1)
        }
        ScalarMetaParam {
            name: qsTr("ST Transfer Time N-1")
            param: registry.addScalarParam(MemoryRange.S32, paramId.transmission_shift_n_1_st_transfer_time, true, true, slots.timeMilliseconds1)
        }
        ScalarMetaParam {
            name: qsTr("ST Transfer Time 1-N")
            param: registry.addScalarParam(MemoryRange.S32, paramId.transmission_shift_1_n_st_transfer_time, true, true, slots.timeMilliseconds1)
        }
        ScalarMetaParam {
            name: qsTr("ST Transfer Time 1-2")
            param: registry.addScalarParam(MemoryRange.S32, paramId.transmission_shift_1_2_st_transfer_time, true, true, slots.timeMilliseconds1)
        }
        ScalarMetaParam {
            name: qsTr("ST Transfer Time 2-1")
            param: registry.addScalarParam(MemoryRange.S32, paramId.transmission_shift_2_1_st_transfer_time, true, true, slots.timeMilliseconds1)
        }
        ScalarMetaParam {
            name: qsTr("ST Transfer Time 2-3")
            param: registry.addScalarParam(MemoryRange.S32, paramId.transmission_shift_2_3_st_transfer_time, true, true, slots.timeMilliseconds1)
        }
        ScalarMetaParam {
            name: qsTr("ST Transfer Time 3-2")
            param: registry.addScalarParam(MemoryRange.S32, paramId.transmission_shift_3_2_st_transfer_time, true, true, slots.timeMilliseconds1)
        }
        ScalarMetaParam {
            name: qsTr("ST Transfer Time 3-4")
            param: registry.addScalarParam(MemoryRange.S32, paramId.transmission_shift_3_4_st_transfer_time, true, true, slots.timeMilliseconds1)
        }
        ScalarMetaParam {
            name: qsTr("ST Transfer Time 4-3")
            param: registry.addScalarParam(MemoryRange.S32, paramId.transmission_shift_4_3_st_transfer_time, true, true, slots.timeMilliseconds1)
        }
        ScalarMetaParam {
            name: qsTr("ST Transfer Time 4-5")
            param: registry.addScalarParam(MemoryRange.S32, paramId.transmission_shift_4_5_st_transfer_time, true, true, slots.timeMilliseconds1)
        }
        ScalarMetaParam {
            name: qsTr("ST Transfer Time 5-4")
            param: registry.addScalarParam(MemoryRange.S32, paramId.transmission_shift_5_4_st_transfer_time, true, true, slots.timeMilliseconds1)
        }
        ScalarMetaParam {
            name: qsTr("ST Transfer Time 5-6")
            param: registry.addScalarParam(MemoryRange.S32, paramId.transmission_shift_5_6_st_transfer_time, true, true, slots.timeMilliseconds1)
        }
        ScalarMetaParam {
            name: qsTr("ST Transfer Time 6-5")
            param: registry.addScalarParam(MemoryRange.S32, paramId.transmission_shift_6_5_st_transfer_time, true, true, slots.timeMilliseconds1)
        }
    }
    property TableMetaParam transmissionTemperaturePressureCompensation: TableMetaParam {
        param: TableParam {
            x: tempAxisModel
            value: registry.addArrayParam(MemoryRange.S32, paramId.transmission_pressure_temperature_compensation, tempAxisModel.count, true, true, slots.percentage1)
        }
        name: qsTr("Trans Temp Pressure Compensation")
    }

    property ScalarMetaParam garageShiftTime: ScalarMetaParam {
        param: registry.addScalarParam(MemoryRange.S32, paramId.garage_shift_time, true, true, slots.timeMilliseconds1)
        name: qsTr("Garage Shift Time")
        immediateWrite: true
    }

    property ScalarMetaParam garageShiftMaxPressure: ScalarMetaParam {
        param: registry.addScalarParam(MemoryRange.S32, paramId.garage_shift_max_pressure, true, true, slots.pressure)
        name: qsTr("Garage Shift Max Pressure")
        immediateWrite: true
    }

    property ScalarMetaParam garageShiftMaxPercentage: ScalarMetaParam {
        param: registry.addScalarParam(MemoryRange.S32, paramId.garage_shift_max_percentage, true, true, slots.percentage2)
        name: qsTr("Garage Shift Max Percentage")
        immediateWrite: true
    }

    property ScalarMetaParam garageShiftProportionalConstant: ScalarMetaParam {
        param: registry.addScalarParam(MemoryRange.S32, paramId.garage_shift_p_const, true, true, slots.percentagePerRpm)
        name: qsTr("Garage Shift P Coeff")
        immediateWrite: true
    }

    property ScalarMetaParam garageShiftIntegralConstant: ScalarMetaParam {
        param: registry.addScalarParam(MemoryRange.S32, paramId.garage_shift_i_const, true, true, slots.percentagePerRpmSec)
        name: qsTr("Garage Shift I Coeff")
        immediateWrite: true
    }

    property ScalarMetaParam garageShiftDerivativeConstant: ScalarMetaParam {
        param: registry.addScalarParam(MemoryRange.S32, paramId.garage_shift_d_const, true, true, slots.percentagePerRpmPerSec)
        name: qsTr("Garage Shift D Coeff")
        immediateWrite: true
    }

    property
    list<TableMetaParam> transmissionUpshiftApplyPressure: [
        TableMetaParam {
            param: TableParam {
                x: pressureAxisModel
                value: registry.addArrayParam(MemoryRange.S32, paramId.transmission_shift_n_1_apply_pressure, pressureAxisModel.count, true, true, slots.pressure)
            }
            name: qsTr("Shift N-1 Apply")
        },
        TableMetaParam {
            param: TableParam {
                x: pressureAxisModel
                value: registry.addArrayParam(MemoryRange.S32, paramId.transmission_shift_1_2_apply_pressure, pressureAxisModel.count, true, true, slots.pressure)
            }
            name: qsTr("Shift 1-2 Apply")
        },
        TableMetaParam {
            param: TableParam {
                x: pressureAxisModel
                value: registry.addArrayParam(MemoryRange.S32, paramId.transmission_shift_2_3_apply_pressure, pressureAxisModel.count, true, true, slots.pressure)
            }
            name: qsTr("Shift 2-3 Apply")
        },
        TableMetaParam {
            param: TableParam {
                x: pressureAxisModel
                value: registry.addArrayParam(MemoryRange.S32, paramId.transmission_shift_3_4_apply_pressure, pressureAxisModel.count, true, true, slots.pressure)
            }
            name: qsTr("Shift 3-4 Apply")
        },
        TableMetaParam {
            param: TableParam {
                x: pressureAxisModel
                value: registry.addArrayParam(MemoryRange.S32, paramId.transmission_shift_4_5_apply_pressure, pressureAxisModel.count, true, true, slots.pressure)
            }
            name: qsTr("Shift 4-5 Apply")
        },
        TableMetaParam {
            param: TableParam {
                x: pressureAxisModel
                value: registry.addArrayParam(MemoryRange.S32, paramId.transmission_shift_5_6_apply_pressure, pressureAxisModel.count, true, true, slots.pressure)
            }
            name: qsTr("Shift 5-6 Apply")
        }/*,
        TableMetaParam {
            param: TableParam {
                x: pressureAxisModel
                value: registry.addArrayParam(MemoryRange.S32, paramId.transmission_shift_6_7_apply_pressure, pressureAxisModel.count, true, true, slots.pressure)
            }
            name: qsTr("Shift 6-7 Apply")
        },
        TableMetaParam {
            param: TableParam {
                x: pressureAxisModel
                value: registry.addArrayParam(MemoryRange.S32, paramId.transmission_shift_7_8_apply_pressure, pressureAxisModel.count, true, true, slots.pressure)
            }
            name: qsTr("Shift 7-8 Apply")
        }*/
    ]

    property
    list<TableMetaParam> transmissionDownshiftApplyPressure: [
        TableMetaParam {
            param: TableParam {
                x: pressureAxisModel
                value: registry.addArrayParam(MemoryRange.S32, paramId.transmission_shift_2_1_apply_pressure, pressureAxisModel.count, true, true, slots.pressure)
            }
            name: qsTr("Shift 2-1 Apply")
        },
        TableMetaParam {
            param: TableParam {
                x: pressureAxisModel
                value: registry.addArrayParam(MemoryRange.S32, paramId.transmission_shift_3_2_apply_pressure, pressureAxisModel.count, true, true, slots.pressure)
            }
            name: qsTr("Shift 3-2 Apply")
        },
        TableMetaParam {
            param: TableParam {
                x: pressureAxisModel
                value: registry.addArrayParam(MemoryRange.S32, paramId.transmission_shift_4_3_apply_pressure, pressureAxisModel.count, true, true, slots.pressure)
            }
            name: qsTr("Shift 4-3 Apply")
        },
        TableMetaParam {
            param: TableParam {
                x: pressureAxisModel
                value: registry.addArrayParam(MemoryRange.S32, paramId.transmission_shift_5_4_apply_pressure, pressureAxisModel.count, true, true, slots.pressure)
            }
            name: qsTr("Shift 5-4 Apply")
        },
        TableMetaParam {
            param: TableParam {
                x: pressureAxisModel
                value: registry.addArrayParam(MemoryRange.S32, paramId.transmission_shift_6_5_apply_pressure, pressureAxisModel.count, true, true, slots.pressure)
            }
            name: qsTr("Shift 6-5 Apply")
        }/*,
        TableMetaParam {
            param: TableParam {
                x: pressureAxisModel
                value: registry.addArrayParam(MemoryRange.S32, paramId.transmission_shift_7_6_apply_pressure, pressureAxisModel.count, true, true, slots.pressure)
            }
            name: qsTr("Shift 7-6 Apply")
        },
        TableMetaParam {
            param: TableParam {
                x: pressureAxisModel
                value: registry.addArrayParam(MemoryRange.S32, paramId.transmission_shift_8_7_apply_pressure, pressureAxisModel.count, true, true, slots.pressure)
            }
            name: qsTr("Shift 8-7 Apply")
        }*/
    ]

    property
    list<TableMetaParam> transmissionUpshiftReleasePressure: [
        TableMetaParam {
            param: TableParam {
                x: pressureAxisModel
                value: registry.addArrayParam(MemoryRange.S32, paramId.transmission_shift_1_2_release_pressure, pressureAxisModel.count, true, true, slots.pressure)
            }
            name: qsTr("Shift 1-2 Release")
        },
        TableMetaParam {
            param: TableParam {
                x: pressureAxisModel
                value: registry.addArrayParam(MemoryRange.S32, paramId.transmission_shift_2_3_release_pressure, pressureAxisModel.count, true, true, slots.pressure)
            }
            name: qsTr("Shift 2-3 Release")
        },
        TableMetaParam {
            param: TableParam {
                x: pressureAxisModel
                value: registry.addArrayParam(MemoryRange.S32, paramId.transmission_shift_3_4_release_pressure, pressureAxisModel.count, true, true, slots.pressure)
            }
            name: qsTr("Shift 3-4 Release")
        },
        TableMetaParam {
            param: TableParam {
                x: pressureAxisModel
                value: registry.addArrayParam(MemoryRange.S32, paramId.transmission_shift_4_5_release_pressure, pressureAxisModel.count, true, true, slots.pressure)
            }
            name: qsTr("Shift 4-5 Release")
        },
        TableMetaParam {
            param: TableParam {
                x: pressureAxisModel
                value: registry.addArrayParam(MemoryRange.S32, paramId.transmission_shift_5_6_release_pressure, pressureAxisModel.count, true, true, slots.pressure)
            }
            name: qsTr("Shift 5-6 Release")
        }/*,
        TableMetaParam {
            param: TableParam {
                x: pressureAxisModel
                value: registry.addArrayParam(MemoryRange.S32, paramId.transmission_shift_6_7_release_pressure, pressureAxisModel.count, true, true, slots.pressure)
            }
            name: qsTr("Shift 6-7 Release")
        },
        TableMetaParam {
            param: TableParam {
                x: pressureAxisModel
                value: registry.addArrayParam(MemoryRange.S32, paramId.transmission_shift_7_8_release_pressure, pressureAxisModel.count, true, true, slots.pressure)
            }
            name: qsTr("Shift 7-8 Release")
        }*/
    ]

    property
    list<TableMetaParam> transmissionDownshiftReleasePressure: [
        TableMetaParam {
            param: TableParam {
                x: pressureAxisModel
                value: registry.addArrayParam(MemoryRange.S32, paramId.transmission_shift_2_1_release_pressure, pressureAxisModel.count, true, true, slots.pressure)
            }
            name: qsTr("Shift 2-1 Release")
        },
        TableMetaParam {
            param: TableParam {
                x: pressureAxisModel
                value: registry.addArrayParam(MemoryRange.S32, paramId.transmission_shift_3_2_release_pressure, pressureAxisModel.count, true, true, slots.pressure)
            }
            name: qsTr("Shift 3-2 Release")
        },
        TableMetaParam {
            param: TableParam {
                x: pressureAxisModel
                value: registry.addArrayParam(MemoryRange.S32, paramId.transmission_shift_4_3_release_pressure, pressureAxisModel.count, true, true, slots.pressure)
            }
            name: qsTr("Shift 4-3 Release")
        },
        TableMetaParam {
            param: TableParam {
                x: pressureAxisModel
                value: registry.addArrayParam(MemoryRange.S32, paramId.transmission_shift_5_4_release_pressure, pressureAxisModel.count, true, true, slots.pressure)
            }
            name: qsTr("Shift 5-4 Release")
        },
        TableMetaParam {
            param: TableParam {
                x: pressureAxisModel
                value: registry.addArrayParam(MemoryRange.S32, paramId.transmission_shift_6_5_release_pressure, pressureAxisModel.count, true, true, slots.pressure)
            }
            name: qsTr("Shift 6-5 Release")
        }/*,
        TableMetaParam {
            param: TableParam {
                x: pressureAxisModel
                value: registry.addArrayParam(MemoryRange.S32, paramId.transmission_shift_7_6_release_pressure, pressureAxisModel.count, true, true, slots.pressure)
            }
            name: qsTr("Shift 7-6 Release")
        },
        TableMetaParam {
            param: TableParam {
                x: pressureAxisModel
                value: registry.addArrayParam(MemoryRange.S32, paramId.transmission_shift_8_7_release_pressure, pressureAxisModel.count, true, true, slots.pressure)
            }
            name: qsTr("Shift 8-7 Release")
        }*/
    ]

    property
    list<TableMetaParam> transmissionMainPressure: [
        TableMetaParam {
            param: TableParam {
                x: pressureAxisModel
                value: registry.addArrayParam(MemoryRange.S32, paramId.transmission_gear_1_main_pressure, pressureAxisModel.count, true, true, slots.pressure)
            }
            name: qsTr("Gear 1 Main Pressure")
        },
        TableMetaParam {
            param: TableParam {
                x: pressureAxisModel
                value: registry.addArrayParam(MemoryRange.S32, paramId.transmission_gear_2_main_pressure, pressureAxisModel.count, true, true, slots.pressure)
            }
            name: qsTr("Gear 2 Main Pressure")
        },
        TableMetaParam {
            param: TableParam {
                x: pressureAxisModel
                value: registry.addArrayParam(MemoryRange.S32, paramId.transmission_gear_3_main_pressure, pressureAxisModel.count, true, true, slots.pressure)
            }
            name: qsTr("Gear 3 Main Pressure")
        },
        TableMetaParam {
            param: TableParam {
                x: pressureAxisModel
                value: registry.addArrayParam(MemoryRange.S32, paramId.transmission_gear_4_main_pressure, pressureAxisModel.count, true, true, slots.pressure)
            }
            name: qsTr("Gear 4 Main Pressure")
        },
        TableMetaParam {
            param: TableParam {
                x: pressureAxisModel
                value: registry.addArrayParam(MemoryRange.S32, paramId.transmission_gear_5_main_pressure, pressureAxisModel.count, true, true, slots.pressure)
            }
            name: qsTr("Gear 5 Main Pressure")
        },
        TableMetaParam {
            param: TableParam {
                x: pressureAxisModel
                value: registry.addArrayParam(MemoryRange.S32, paramId.transmission_gear_6_main_pressure, pressureAxisModel.count, true, true, slots.pressure)
            }
            name: qsTr("Gear 6 Main Pressure")
        }/*,
        TableMetaParam {
            param: TableParam {
                x: pressureAxisModel
                value: registry.addArrayParam(MemoryRange.S32, paramId.transmission_gear_7_main_pressure, pressureAxisModel.count, true, true, slots.pressure)
            }
            name: qsTr("Gear 7 Main Pressure")
        },
        TableMetaParam {
            param: TableParam {
                x: pressureAxisModel
                value: registry.addArrayParam(MemoryRange.S32, paramId.transmission_gear_8_main_pressure, pressureAxisModel.count, true, true, slots.pressure)
            }
            name: qsTr("Gear 8 Main Pressure")
        }*/
    ]

    property
    list<TableMetaParam> transmissionUpshiftApplyPercentage: [
        TableMetaParam {
            param: TableParam {
                x: pressureAxisModel
                value: registry.addArrayParam(MemoryRange.S32, paramId.transmission_shift_n_1_apply_percentage, pressureAxisModel.count, true, true, slots.percentage1)
            }
            name: qsTr("Shift N-1 Apply Pressure")
        },
        TableMetaParam {
            param: TableParam {
                x: pressureAxisModel
                value: registry.addArrayParam(MemoryRange.S32, paramId.transmission_shift_1_2_apply_percentage, pressureAxisModel.count, true, true, slots.percentage1)
            }
            name: qsTr("Shift 1-2 Apply Pressure")
        },
        TableMetaParam {
            param: TableParam {
                x: pressureAxisModel
                value: registry.addArrayParam(MemoryRange.S32, paramId.transmission_shift_2_3_apply_percentage, pressureAxisModel.count, true, true, slots.percentage1)
            }
            name: qsTr("Shift 2-3 Apply Pressure")
        },
        TableMetaParam {
            param: TableParam {
                x: pressureAxisModel
                value: registry.addArrayParam(MemoryRange.S32, paramId.transmission_shift_3_4_apply_percentage, pressureAxisModel.count, true, true, slots.percentage1)
            }
            name: qsTr("Shift 3-4 Apply Pressure")
        },
        TableMetaParam {
            param: TableParam {
                x: pressureAxisModel
                value: registry.addArrayParam(MemoryRange.S32, paramId.transmission_shift_4_5_apply_percentage, pressureAxisModel.count, true, true, slots.percentage1)
            }
            name: qsTr("Shift 4-5 Apply Pressure")
        },
        TableMetaParam {
            param: TableParam {
                x: pressureAxisModel
                value: registry.addArrayParam(MemoryRange.S32, paramId.transmission_shift_5_6_apply_percentage, pressureAxisModel.count, true, true, slots.percentage1)
            }
            name: qsTr("Shift 5-6 Apply Pressure")
        }/*,
        TableMetaParam {
            param: TableParam {
                x: pressureAxisModel
                value: registry.addArrayParam(MemoryRange.S32, paramId.transmission_shift_6_7_apply_percentage, pressureAxisModel.count, true, true, slots.percentage1)
            }
            name: qsTr("Shift 6-7 Apply Pressure")
        },
        TableMetaParam {
            param: TableParam {
                x: pressureAxisModel
                value: registry.addArrayParam(MemoryRange.S32, paramId.transmission_shift_7_8_apply_percentage, pressureAxisModel.count, true, true, slots.percentage1)
            }
            name: qsTr("Shift 7-8 Apply Pressure")
        }*/
    ]

    property
    list<TableMetaParam> transmissionDownshiftApplyPercentage: [
        TableMetaParam {
            param: TableParam {
                x: pressureAxisModel
                value: registry.addArrayParam(MemoryRange.S32, paramId.transmission_shift_2_1_apply_percentage, pressureAxisModel.count, true, true, slots.percentage1)
            }
            name: qsTr("Shift 2-1 Apply Pressure")
        },
        TableMetaParam {
            param: TableParam {
                x: pressureAxisModel
                value: registry.addArrayParam(MemoryRange.S32, paramId.transmission_shift_3_2_apply_percentage, pressureAxisModel.count, true, true, slots.percentage1)
            }
            name: qsTr("Shift 3-2 Apply Pressure")
        },
        TableMetaParam {
            param: TableParam {
                x: pressureAxisModel
                value: registry.addArrayParam(MemoryRange.S32, paramId.transmission_shift_4_3_apply_percentage, pressureAxisModel.count, true, true, slots.percentage1)
            }
            name: qsTr("Shift 4-3 Apply Pressure")
        },
        TableMetaParam {
            param: TableParam {
                x: pressureAxisModel
                value: registry.addArrayParam(MemoryRange.S32, paramId.transmission_shift_5_4_apply_percentage, pressureAxisModel.count, true, true, slots.percentage1)
            }
            name: qsTr("Shift 5-4 Apply Pressure")
        },
        TableMetaParam {
            param: TableParam {
                x: pressureAxisModel
                value: registry.addArrayParam(MemoryRange.S32, paramId.transmission_shift_6_5_apply_percentage, pressureAxisModel.count, true, true, slots.percentage1)
            }
            name: qsTr("Shift 6-5 Apply Pressure")
        }/*,
        TableMetaParam {
            param: TableParam {
                x: pressureAxisModel
                value: registry.addArrayParam(MemoryRange.S32, paramId.transmission_shift_7_6_apply_percentage, pressureAxisModel.count, true, true, slots.percentage1)
            }
            name: qsTr("Shift 7-6 Apply Pressure")
        },
        TableMetaParam {
            param: TableParam {
                x: pressureAxisModel
                value: registry.addArrayParam(MemoryRange.S32, paramId.transmission_shift_8_7_apply_percentage, pressureAxisModel.count, true, true, slots.percentage1)
            }
            name: qsTr("Shift 8-7 Apply Pressure")
        }*/
    ]


    property
    list<TableMetaParam> transmissionUpshiftReleasePercentage: [
        TableMetaParam {
            param: TableParam {
                x: pressureAxisModel
                value: registry.addArrayParam(MemoryRange.S32, paramId.transmission_shift_1_2_release_percentage, pressureAxisModel.count, true, true, slots.percentage1)
            }
            name: qsTr("Shift 1-2 Release Pressure")
        },
        TableMetaParam {
            param: TableParam {
                x: pressureAxisModel
                value: registry.addArrayParam(MemoryRange.S32, paramId.transmission_shift_2_3_release_percentage, pressureAxisModel.count, true, true, slots.percentage1)
            }
            name: qsTr("Shift 2-3 Release Pressure")
        },
        TableMetaParam {
            param: TableParam {
                x: pressureAxisModel
                value: registry.addArrayParam(MemoryRange.S32, paramId.transmission_shift_3_4_release_percentage, pressureAxisModel.count, true, true, slots.percentage1)
            }
            name: qsTr("Shift 3-4 Release Pressure")
        },
        TableMetaParam {
            param: TableParam {
                x: pressureAxisModel
                value: registry.addArrayParam(MemoryRange.S32, paramId.transmission_shift_4_5_release_percentage, pressureAxisModel.count, true, true, slots.percentage1)
            }
            name: qsTr("Shift 4-5 Release Pressure")
        },
        TableMetaParam {
            param: TableParam {
                x: pressureAxisModel
                value: registry.addArrayParam(MemoryRange.S32, paramId.transmission_shift_5_6_release_percentage, pressureAxisModel.count, true, true, slots.percentage1)
            }
            name: qsTr("Shift 5-6 Release Pressure")
        }/*,
        TableMetaParam {
            param: TableParam {
                x: pressureAxisModel
                value: registry.addArrayParam(MemoryRange.S32, paramId.transmission_shift_6_7_release_percentage, pressureAxisModel.count, true, true, slots.percentage1)
            }
            name: qsTr("Shift 6-7 Release Pressure")
        },
        TableMetaParam {
            param: TableParam {
                x: pressureAxisModel
                value: registry.addArrayParam(MemoryRange.S32, paramId.transmission_shift_7_8_release_percentage, pressureAxisModel.count, true, true, slots.percentage1)
            }
            name: qsTr("Shift 7-8 Release Pressure")
        }*/
    ]

    property
    list<TableMetaParam> transmissionDownshiftReleasePercentage: [
        TableMetaParam {
            param: TableParam {
                x: pressureAxisModel
                value: registry.addArrayParam(MemoryRange.S32, paramId.transmission_shift_2_1_release_percentage, pressureAxisModel.count, true, true, slots.percentage1)
            }
            name: qsTr("Shift 2-1 Release Pressure")
        },
        TableMetaParam {
            param: TableParam {
                x: pressureAxisModel
                value: registry.addArrayParam(MemoryRange.S32, paramId.transmission_shift_3_2_release_percentage, pressureAxisModel.count, true, true, slots.percentage1)
            }
            name: qsTr("Shift 3-2 Release Pressure")
        },
        TableMetaParam {
            param: TableParam {
                x: pressureAxisModel
                value: registry.addArrayParam(MemoryRange.S32, paramId.transmission_shift_4_3_release_percentage, pressureAxisModel.count, true, true, slots.percentage1)
            }
            name: qsTr("Shift 4-3 Release Pressure")
        },
        TableMetaParam {
            param: TableParam {
                x: pressureAxisModel
                value: registry.addArrayParam(MemoryRange.S32, paramId.transmission_shift_5_4_release_percentage, pressureAxisModel.count, true, true, slots.percentage1)
            }
            name: qsTr("Shift 5-4 Release Pressure")
        },
        TableMetaParam {
            param: TableParam {
                x: pressureAxisModel
                value: registry.addArrayParam(MemoryRange.S32, paramId.transmission_shift_6_5_release_percentage, pressureAxisModel.count, true, true, slots.percentage1)
            }
            name: qsTr("Shift 6-5 Release Pressure")
        }/*,
        TableMetaParam {
            param: TableParam {
                x: pressureAxisModel
                value: registry.addArrayParam(MemoryRange.S32, paramId.transmission_shift_7_6_release_percentage, pressureAxisModel.count, true, true, slots.percentage1)
            }
            name: qsTr("Shift 7-6 Release Pressure")
        },
        TableMetaParam {
            param: TableParam {
                x: pressureAxisModel
                value: registry.addArrayParam(MemoryRange.S32, paramId.transmission_shift_8_7_release_percentage, pressureAxisModel.count, true, true, slots.percentage1)
            }
            name: qsTr("Shift 8-7 Release Pressure")
        }*/
    ]

    property
    list<TableMetaParam> transmissionMainPercentage: [
        TableMetaParam {
            param: TableParam {
                x: pressureAxisModel
                value: registry.addArrayParam(MemoryRange.S32, paramId.transmission_gear_1_main_percentage, pressureAxisModel.count, true, true, slots.percentage1)
            }
            name: qsTr("Gear 1 Main Pressure")
        },
        TableMetaParam {
            param: TableParam {
                x: pressureAxisModel
                value: registry.addArrayParam(MemoryRange.S32, paramId.transmission_gear_2_main_percentage, pressureAxisModel.count, true, true, slots.percentage1)
            }
            name: qsTr("Gear 2 Main Pressure")
        },
        TableMetaParam {
            param: TableParam {
                x: pressureAxisModel
                value: registry.addArrayParam(MemoryRange.S32, paramId.transmission_gear_3_main_percentage, pressureAxisModel.count, true, true, slots.percentage1)
            }
            name: qsTr("Gear 3 Main Pressure")
        },
        TableMetaParam {
            param: TableParam {
                x: pressureAxisModel
                value: registry.addArrayParam(MemoryRange.S32, paramId.transmission_gear_4_main_percentage, pressureAxisModel.count, true, true, slots.percentage1)
            }
            name: qsTr("Gear 4 Main Pressure")
        },
        TableMetaParam {
            param: TableParam {
                x: pressureAxisModel
                value: registry.addArrayParam(MemoryRange.S32, paramId.transmission_gear_5_main_percentage, pressureAxisModel.count, true, true, slots.percentage1)
            }
            name: qsTr("Gear 5 Main Pressure")
        },
        TableMetaParam {
            param: TableParam {
                x: pressureAxisModel
                value: registry.addArrayParam(MemoryRange.S32, paramId.transmission_gear_6_main_percentage, pressureAxisModel.count, true, true, slots.percentage1)
            }
            name: qsTr("Gear 6 Main Pressure")
        }/*,
        TableMetaParam {
            param: TableParam {
                x: pressureAxisModel
                value: registry.addArrayParam(MemoryRange.S32, paramId.transmission_gear_7_main_percentage, pressureAxisModel.count, true, true, slots.percentage1)
            }
            name: qsTr("Gear 7 Main Pressure")
        },
        TableMetaParam {
            param: TableParam {
                x: pressureAxisModel
                value: registry.addArrayParam(MemoryRange.S32, paramId.transmission_gear_8_main_percentage, pressureAxisModel.count, true, true, slots.percentage1)
            }
            name: qsTr("Gear 8 Main Pressure")
        }*/
    ]

    property ScalarMetaParam powertrainType: ScalarMetaParam {
        param: registry.addScalarParam(MemoryRange.S32, paramId.transmission_type, true, true, slots.transmissionType1)
        name: qsTr("Powertrain Type")
    }

    property ScalarMetaParam pressureR2LBoostA: ScalarMetaParam {
        param: registry.addScalarParam(MemoryRange.S32, paramId.pressure_r2l_boost_a, true, true, slots.percentage1)
        name: qsTr("Pressure R2L Boost A")
    }

    property ScalarMetaParam pressureR2LBoostB: ScalarMetaParam {
        param: registry.addScalarParam(MemoryRange.S32, paramId.pressure_r2l_boost_b, true, true, slots.percentage1)
        name: qsTr("Pressure R2L Boost B")
    }

    property ScalarMetaParam displayColorRed: ScalarMetaParam {
        param: registry.addScalarParam(MemoryRange.S32, paramId.display_color + 0, true, true, slots.percentage1)
        name: qsTr("Display Color Red")
    }

    property ScalarMetaParam displayColorGreen: ScalarMetaParam {
        param: registry.addScalarParam(MemoryRange.S32, paramId.display_color + 1, true, true, slots.percentage1)
        name: qsTr("Display Color Green")
    }

    property ScalarMetaParam displayColorBlue: ScalarMetaParam {
        param: registry.addScalarParam(MemoryRange.S32, paramId.display_color + 2, true, true, slots.percentage1)
        name: qsTr("Display Color Blue")
    }

    property ScalarMetaParam displayBrightness: ScalarMetaParam {
        param: registry.addScalarParam(MemoryRange.S32, paramId.display_brightness, true, true, slots.percentage1)
        name: qsTr("Display Brightness")
    }

    property ScalarMetaParam displayContrast: ScalarMetaParam {
        param: registry.addScalarParam(MemoryRange.S32, paramId.display_contrast, true, true, slots.percentage1)
        name: qsTr("Display Contrast")
    }

    property ScalarMetaParam shiftDownshiftOffsetA: ScalarMetaParam {
        param: registry.addScalarParam(MemoryRange.S32, paramId.shift_downshift_offset_a, true, true, slots.percentage1)
        name: qsTr("Downshift Offset A")
    }

    property ScalarMetaParam shiftDownshiftOffsetB: ScalarMetaParam {
        param: registry.addScalarParam(MemoryRange.S32, paramId.shift_downshift_offset_b, true, true, slots.percentage1)
        name: qsTr("Downshift Offset B")
    }

    property ScalarMetaParam shiftTablesDownLockedA: ScalarMetaParam {
        param: registry.addScalarParam(MemoryRange.S32, paramId.shift_tables_a_down_locked, true, true, slots.booleanYesNo1)
        name: qsTr("Downshift Table Locked A")
    }

    property ScalarMetaParam shiftTablesDownLockedB: ScalarMetaParam {
        param: registry.addScalarParam(MemoryRange.S32, paramId.shift_tables_b_down_locked, true, true, slots.booleanYesNo1)
        name: qsTr("Downshift Table Locked B")
    }

    property ScalarMetaParam engineCylinders: ScalarMetaParam {
        param: registry.addScalarParam(MemoryRange.S32, paramId.engine_cylinders, true, true, slots.count2)
        name: qsTr("Engine Cylinders")
    }

    property ScalarMetaParam engineRunningDetectionSpeed: ScalarMetaParam {
        param: registry.addScalarParam(MemoryRange.S32, paramId.engine_running_detection_speed, true, true, slots.rpm1)
        name: qsTr("Engine Running Detect Speed")
    }

    property ScalarMetaParam engineMapTorqueProportion: ScalarMetaParam {
        param: registry.addScalarParam(MemoryRange.S32, paramId.engine_map_torque_proportion, true, true, slots.percentage1)
        name: qsTr("Engine MAP Torque Proportion")
    }

    property ScalarMetaParam engineMaxTorque: ScalarMetaParam {
        param: registry.addScalarParam(MemoryRange.S32, paramId.engine_max_torque, true, true, slots.torque)
        name: qsTr("Engine Max Torque")
    }

    property ScalarMetaParam engineIdleShutdownTime: ScalarMetaParam {
        param: registry.addScalarParam(MemoryRange.S32, paramId.engine_idle_shutdown_time, true, true, slots.timeInSecondsZeroIsDisabled)
        name: qsTr("Engine Idle Shutdown Time")
    }

    property TableMetaParam engineMotoringMaxTorque: TableMetaParam {
        param: TableParam {
            x: registry.addArrayParam(MemoryRange.S32, paramId.engine_motoring_speed, 16, true, true, slots.rpm1)
            value: registry.addArrayParam(MemoryRange.S32, paramId.engine_motoring_max_torque, 16, true, true, slots.torque)
        }
        name: qsTr("Engine Motoring Torque")
    }

    property TableMetaParam engineBrakingMaxTorque: TableMetaParam {
        param: TableParam {
            x: registry.addArrayParam(MemoryRange.S32, paramId.engine_braking_speed, 16, true, true, slots.rpm1)
            value: registry.addArrayParam(MemoryRange.S32, paramId.engine_braking_max_torque, 16, true, true, slots.torque)
        }
        name: qsTr("Engine Braking Torque")
    }

    property ScalarMetaParam finalDriveRatio: ScalarMetaParam {
        param: registry.addScalarParam(MemoryRange.S32, paramId.final_drive_ratio, true, true, slots.ratio1)
        name: qsTr("Final Drive Ratio")
    }

    property ScalarMetaParam can0BaudRate: ScalarMetaParam {
        param: registry.addScalarParam(MemoryRange.S32, paramId.can0_baud_rate, true, true, slots.canSpeed)
        name: qsTr("CAN 0 Baud Rate")
    }

    property ScalarMetaParam can1BaudRate: ScalarMetaParam {
        param: registry.addScalarParam(MemoryRange.S32, paramId.can1_baud_rate, true, true, slots.canSpeed)
        name: qsTr("CAN 1 Baud Rate")
    }

    property ScalarMetaParam j1939TransmissionAddress: ScalarMetaParam {
        param: registry.addScalarParam(MemoryRange.S32, paramId.j1939_transmission_address, true, true, slots.countByte)
        name: qsTr("J1939 Trans Address")
    }

    property ScalarMetaParam j1939EngineAddress: ScalarMetaParam {
        param: registry.addScalarParam(MemoryRange.S32, paramId.j1939_engine_address, true, true, slots.countByte)
        name: qsTr("J1939 Engine Address")
    }

    property ScalarMetaParam j1939ShiftSelectorAddress: ScalarMetaParam {
        param: registry.addScalarParam(MemoryRange.S32, paramId.j1939_shift_selector_address, true, true, slots.countByte)
        name: qsTr("J1939 Shift Selector Address")
    }

    property ScalarMetaParam xcpCTOId: ScalarMetaParam {
        param: registry.addScalarParam(MemoryRange.S32, paramId.xcp_cto_id, true, true, slots.hex32bit)
        name: qsTr("XCP CTO ID")
    }

    property ScalarMetaParam xcpDTOId: ScalarMetaParam {
        param: registry.addScalarParam(MemoryRange.S32, paramId.xcp_dto_id, true, true, slots.hex32bit)
        name: qsTr("XCP DTO ID")
    }

    property ScalarMetaParam shiftManualModeA: ScalarMetaParam {
        param: registry.addScalarParam(MemoryRange.S32, paramId.shift_manual_mode_a, true, true, slots.booleanYesNo1)
        name: qsTr("Manual Shift A")
    }

    property ScalarMetaParam shiftManualModeB: ScalarMetaParam {
        param: registry.addScalarParam(MemoryRange.S32, paramId.shift_manual_mode_b, true, true, slots.booleanYesNo1)
        name: qsTr("Manual Shift B")
    }

    property ScalarMetaParam tccManualModeA: ScalarMetaParam {
        param: registry.addScalarParam(MemoryRange.S32, paramId.tcc_manual_mode_a, true, true, slots.booleanYesNo1)
        name: qsTr("Manual TCC A")
    }

    property ScalarMetaParam tccManualModeB: ScalarMetaParam {
        param: registry.addScalarParam(MemoryRange.S32, paramId.tcc_manual_mode_b, true, true, slots.booleanYesNo1)
        name: qsTr("Manual TCC B")
    }


    property ScalarMetaParam tccDisableInSwitchShiftA: ScalarMetaParam {
        param: registry.addScalarParam(MemoryRange.S32, paramId.tcc_disable_in_switch_shift_a, true, true, slots.booleanYesNo1)
        name: qsTr("TCC Disable In Switch Shift A")
    }

    property ScalarMetaParam tccDisableInSwitchShiftB: ScalarMetaParam {
        param: registry.addScalarParam(MemoryRange.S32, paramId.tcc_disable_in_switch_shift_b, true, true, slots.booleanYesNo1)
        name: qsTr("TCC Disable In Switch Shift B")
    }

    property ScalarMetaParam shiftMaxEngineSpeedA: ScalarMetaParam {
        param: registry.addScalarParam(MemoryRange.S32, paramId.shift_max_engine_speed_a, true, true, slots.rpm1)
        name: qsTr("Max Engine Speed A")
    }

    property ScalarMetaParam shiftMaxEngineSpeedB: ScalarMetaParam {
        param: registry.addScalarParam(MemoryRange.S32, paramId.shift_max_engine_speed_b, true, true, slots.rpm1)
        name: qsTr("Max Engine Speed B")
    }

    property ScalarMetaParam pressureAdjustA: ScalarMetaParam {
        param: registry.addScalarParam(MemoryRange.S32, paramId.pressure_adjust_a, true, true, slots.percentage1)
        name: qsTr("Pressure Adjust A")
    }

    property ScalarMetaParam pressureAdjustB: ScalarMetaParam {
        param: registry.addScalarParam(MemoryRange.S32, paramId.pressure_adjust_b, true, true, slots.percentage1)
        name: qsTr("Pressure Adjust B")
    }

    property
    list<TableMetaParam> pressureTablesA: [
        TableMetaParam {
            param: TableParam {
                x: percentage1AxisModel
                value: registry.addArrayParam(MemoryRange.S32, paramId.pressure_tables_a_1, percentage1AxisModel.count, true, true, slots.percentage1)
            }
            name: qsTr("Shift Pressure 1 A")
        },
        TableMetaParam {
            param: TableParam {
                x: percentage1AxisModel
                value: registry.addArrayParam(MemoryRange.S32, paramId.pressure_tables_a_2, percentage1AxisModel.count, true, true, slots.percentage1)
            }
            name: qsTr("Shift Pressure 2 A")
        },
        TableMetaParam {
            param: TableParam {
                x: percentage1AxisModel
                value: registry.addArrayParam(MemoryRange.S32, paramId.pressure_tables_a_3, percentage1AxisModel.count, true, true, slots.percentage1)
            }
            name: qsTr("Shift Pressure 3 A")
        },
        TableMetaParam {
            param: TableParam {
                x: percentage1AxisModel
                value: registry.addArrayParam(MemoryRange.S32, paramId.pressure_tables_a_4, percentage1AxisModel.count, true, true, slots.percentage1)
            }
            name: qsTr("Shift Pressure 4 A")
        },
        TableMetaParam {
            param: TableParam {
                x: percentage1AxisModel
                value: registry.addArrayParam(MemoryRange.S32, paramId.pressure_tables_a_5, percentage1AxisModel.count, true, true, slots.percentage1)
            }
            name: qsTr("Shift Pressure 5 A")
        },
        TableMetaParam {
            param: TableParam {
                x: percentage1AxisModel
                value: registry.addArrayParam(MemoryRange.S32, paramId.pressure_tables_a_6, percentage1AxisModel.count, true, true, slots.percentage1)
            }
            name: qsTr("Shift Pressure 6 A")
        }
    ]

    property
    list<TableMetaParam> pressureTablesB: [
        TableMetaParam {
            param: TableParam {
                x: percentage1AxisModel
                value: registry.addArrayParam(MemoryRange.S32, paramId.pressure_tables_b_1, percentage1AxisModel.count, true, true, slots.percentage1)
            }
            name: qsTr("Shift Pressure 1 B")
        },
        TableMetaParam {
            param: TableParam {
                x: percentage1AxisModel
                value: registry.addArrayParam(MemoryRange.S32, paramId.pressure_tables_b_2, percentage1AxisModel.count, true, true, slots.percentage1)
            }
            name: qsTr("Shift Pressure 2 B")
        },
        TableMetaParam {
            param: TableParam {
                x: percentage1AxisModel
                value: registry.addArrayParam(MemoryRange.S32, paramId.pressure_tables_b_3, percentage1AxisModel.count, true, true, slots.percentage1)
            }
            name: qsTr("Shift Pressure 3 B")
        },
        TableMetaParam {
            param: TableParam {
                x: percentage1AxisModel
                value: registry.addArrayParam(MemoryRange.S32, paramId.pressure_tables_b_4, percentage1AxisModel.count, true, true, slots.percentage1)
            }
            name: qsTr("Shift Pressure 4 B")
        },
        TableMetaParam {
            param: TableParam {
                x: percentage1AxisModel
                value: registry.addArrayParam(MemoryRange.S32, paramId.pressure_tables_b_5, percentage1AxisModel.count, true, true, slots.percentage1)
            }
            name: qsTr("Shift Pressure 5 B")
        },
        TableMetaParam {
            param: TableParam {
                x: percentage1AxisModel
                value: registry.addArrayParam(MemoryRange.S32, paramId.pressure_tables_b_6, percentage1AxisModel.count, true, true, slots.percentage1)
            }
            name: qsTr("Shift Pressure 6 B")
        }
    ]

    property
    list<TableMetaParam> solenoidPIMap: [
        TableMetaParam {
            param: TableParam {
                x: registry.addArrayParam(MemoryRange.S32, paramId.clutch_1_solenoid_pressure, 16, true, true, slots.pressure)
                value: registry.addArrayParam(MemoryRange.S32, paramId.clutch_1_solenoid_current, 16, true, true, slots.current)
            }
            name: qsTr("Sol 1 Map")
        },
        TableMetaParam {
            param: TableParam {
                x: registry.addArrayParam(MemoryRange.S32, paramId.clutch_2_solenoid_pressure, 16, true, true, slots.pressure)
                value: registry.addArrayParam(MemoryRange.S32, paramId.clutch_2_solenoid_current, 16, true, true, slots.current)
            }
            name: qsTr("Sol 2 Map")
        },
        TableMetaParam {
            param: TableParam {
                x: registry.addArrayParam(MemoryRange.S32, paramId.clutch_3_solenoid_pressure, 16, true, true, slots.pressure)
                value: registry.addArrayParam(MemoryRange.S32, paramId.clutch_3_solenoid_current, 16, true, true, slots.current)
            }
            name: qsTr("Sol 3 Map")
        },
        TableMetaParam {
            param: TableParam {
                x: registry.addArrayParam(MemoryRange.S32, paramId.clutch_4_solenoid_pressure, 16, true, true, slots.pressure)
                value: registry.addArrayParam(MemoryRange.S32, paramId.clutch_4_solenoid_current, 16, true, true, slots.current)
            }
            name: qsTr("Sol 4 Map")
        },
        TableMetaParam {
            param: TableParam {
                x: registry.addArrayParam(MemoryRange.S32, paramId.clutch_5_solenoid_pressure, 16, true, true, slots.pressure)
                value: registry.addArrayParam(MemoryRange.S32, paramId.clutch_5_solenoid_current, 16, true, true, slots.current)
            }
            name: qsTr("Sol 5 Map")
        },
        TableMetaParam {
            param: TableParam {
                x: registry.addArrayParam(MemoryRange.S32, paramId.clutch_6_solenoid_pressure, 16, true, true, slots.pressure)
                value: registry.addArrayParam(MemoryRange.S32, paramId.clutch_6_solenoid_current, 16, true, true, slots.current)
            }
            name: qsTr("Sol 6 Map")
        },
        TableMetaParam {
            param: TableParam {
                x: registry.addArrayParam(MemoryRange.S32, paramId.clutch_7_solenoid_pressure, 16, true, true, slots.pressure)
                value: registry.addArrayParam(MemoryRange.S32, paramId.clutch_7_solenoid_current, 16, true, true, slots.current)
            }
            name: qsTr("Sol 7 Map")
        },
        TableMetaParam {
            param: TableParam {
                x: registry.addArrayParam(MemoryRange.S32, paramId.clutch_8_solenoid_pressure, 16, true, true, slots.pressure)
                value: registry.addArrayParam(MemoryRange.S32, paramId.clutch_8_solenoid_current, 16, true, true, slots.current)
            }
            name: qsTr("Sol 8 Map")
        }
    ]

    property ScalarMetaParam reverseLockoutSpeed: ScalarMetaParam {
        param: registry.addScalarParam(MemoryRange.S32, paramId.reverse_lockout_speed, true, true, slots.tossRPMAsSpeed)
        name: qsTr("Reverse Lockout Speed")
    }

    property ScalarMetaParam shiftSpeedAdjustA: ScalarMetaParam {
        param: registry.addScalarParam(MemoryRange.S32, paramId.shift_speed_adjust_a, true, true, slots.percentage1)
        name: qsTr("Shift Speed Adjust A")
    }

    property ScalarMetaParam shiftSpeedAdjustB: ScalarMetaParam {
        param: registry.addScalarParam(MemoryRange.S32, paramId.shift_speed_adjust_b, true, true, slots.percentage1)
        name: qsTr("Shift Speed Adjust B")
    }

    property
    list<TableMetaParam> upshiftTablesA: [
        TableMetaParam {
            param: TableParam {
                x: percentage1AxisModel
                value: registry.addArrayParam(MemoryRange.S32, paramId.shift_tables_a_up_1, percentage1AxisModel.count, true, true, slots.tossRPMAsSpeed)
            }
            name: qsTr("Shift Speed 1-2 A")
        },
        TableMetaParam {
            param: TableParam {
                x: percentage1AxisModel
                value: registry.addArrayParam(MemoryRange.S32, paramId.shift_tables_a_up_2, percentage1AxisModel.count, true, true, slots.tossRPMAsSpeed)
            }
            name: qsTr("Shift Speed 2-3 A")
        },
        TableMetaParam {
            param: TableParam {
                x: percentage1AxisModel
                value: registry.addArrayParam(MemoryRange.S32, paramId.shift_tables_a_up_3, percentage1AxisModel.count, true, true, slots.tossRPMAsSpeed)
            }
            name: qsTr("Shift Speed 3-4 A")
        },
        TableMetaParam {
            param: TableParam {
                x: percentage1AxisModel
                value: registry.addArrayParam(MemoryRange.S32, paramId.shift_tables_a_up_4, percentage1AxisModel.count, true, true, slots.tossRPMAsSpeed)
            }
            name: qsTr("Shift Speed 4-5 A")
        },
        TableMetaParam {
            param: TableParam {
                x: percentage1AxisModel
                value: registry.addArrayParam(MemoryRange.S32, paramId.shift_tables_a_up_5, percentage1AxisModel.count, true, true, slots.tossRPMAsSpeed)
            }
            name: qsTr("Shift Speed 5-6 A")
        }
    ]
    property
    list<TableMetaParam> rpmUpshiftTablesA: [
        TableMetaParam {
            param: TableParam {
                x: percentage1AxisModel
                value: SlotProxyModel {
                    sourceModel: upshiftTablesA[0].param.value.rawModel
                    slot: slots.rpm1
                }
            }
            name: qsTr("Shift RPM 1-2 A")
        },
        TableMetaParam {
            param: TableParam {
                x: percentage1AxisModel
                value: SlotProxyModel {
                    sourceModel: upshiftTablesA[1].param.value.rawModel
                    slot: slots.rpm1
                }
            }
            name: qsTr("Shift RPM 2-3 A")
        },
        TableMetaParam {
            param: TableParam {
                x: percentage1AxisModel
                value: SlotProxyModel {
                    sourceModel: upshiftTablesA[2].param.value.rawModel
                    slot: slots.rpm1
                }
            }
            name: qsTr("Shift RPM 3-4 A")
        },
        TableMetaParam {
            param: TableParam {
                x: percentage1AxisModel
                value: SlotProxyModel {
                    sourceModel: upshiftTablesA[3].param.value.rawModel
                    slot: slots.rpm1
                }
            }
            name: qsTr("Shift RPM 4-5 A")
        },
        TableMetaParam {
            param: TableParam {
                x: percentage1AxisModel
                value: SlotProxyModel {
                    sourceModel: upshiftTablesA[4].param.value.rawModel
                    slot: slots.rpm1
                }
            }
            name: qsTr("Shift RPM 5-6 A")
        }
    ]

    property
    list<TableMetaParam> upshiftTablesB: [
        TableMetaParam {
            param: TableParam {
                x: percentage1AxisModel
                value: registry.addArrayParam(MemoryRange.S32, paramId.shift_tables_b_up_1, percentage1AxisModel.count, true, true, slots.tossRPMAsSpeed)
            }
            name: qsTr("Shift Speed 1-2 B")
        },
        TableMetaParam {
            param: TableParam {
                x: percentage1AxisModel
                value: registry.addArrayParam(MemoryRange.S32, paramId.shift_tables_b_up_2, percentage1AxisModel.count, true, true, slots.tossRPMAsSpeed)
            }
            name: qsTr("Shift Speed 2-3 B")
        },
        TableMetaParam {
            param: TableParam {
                x: percentage1AxisModel
                value: registry.addArrayParam(MemoryRange.S32, paramId.shift_tables_b_up_3, percentage1AxisModel.count, true, true, slots.tossRPMAsSpeed)
            }
            name: qsTr("Shift Speed 3-4 B")
        },
        TableMetaParam {
            param: TableParam {
                x: percentage1AxisModel
                value: registry.addArrayParam(MemoryRange.S32, paramId.shift_tables_b_up_4, percentage1AxisModel.count, true, true, slots.tossRPMAsSpeed)
            }
            name: qsTr("Shift Speed 4-5 B")
        },
        TableMetaParam {
            param: TableParam {
                x: percentage1AxisModel
                value: registry.addArrayParam(MemoryRange.S32, paramId.shift_tables_b_up_5, percentage1AxisModel.count, true, true, slots.tossRPMAsSpeed)
            }
            name: qsTr("Shift Speed 5-6 B")
        }
    ]
    property
    list<TableMetaParam> rpmUpshiftTablesB: [
        TableMetaParam {
            param: TableParam {
                x: percentage1AxisModel
                value: SlotProxyModel {
                    sourceModel: upshiftTablesB[0].param.value.rawModel
                    slot: slots.rpm1
                }
            }
            name: qsTr("Shift RPM 1-2 B")
        },
        TableMetaParam {
            param: TableParam {
                x: percentage1AxisModel
                value: SlotProxyModel {
                    sourceModel: upshiftTablesB[1].param.value.rawModel
                    slot: slots.rpm1
                }
            }
            name: qsTr("Shift RPM 2-3 B")
        },
        TableMetaParam {
            param: TableParam {
                x: percentage1AxisModel
                value: SlotProxyModel {
                    sourceModel: upshiftTablesB[2].param.value.rawModel
                    slot: slots.rpm1
                }
            }
            name: qsTr("Shift RPM 3-4 B")
        },
        TableMetaParam {
            param: TableParam {
                x: percentage1AxisModel
                value: SlotProxyModel {
                    sourceModel: upshiftTablesB[3].param.value.rawModel
                    slot: slots.rpm1
                }
            }
            name: qsTr("Shift RPM 4-5 B")
        },
        TableMetaParam {
            param: TableParam {
                x: percentage1AxisModel
                value: SlotProxyModel {
                    sourceModel: upshiftTablesB[4].param.value.rawModel
                    slot: slots.rpm1
                }
            }
            name: qsTr("Shift RPM 5-6 B")
        }
    ]

    property
    list<TableMetaParam> downshiftTablesA: [
        TableMetaParam {
            param: TableParam {
                x: percentage1AxisModel
                value: registry.addArrayParam(MemoryRange.S32, paramId.shift_tables_a_down_1, percentage1AxisModel.count, true, true, slots.tossRPMAsSpeed)
            }
            name: qsTr("Shift Speed 2-1 A")
        },
        TableMetaParam {
            param: TableParam {
                x: percentage1AxisModel
                value: registry.addArrayParam(MemoryRange.S32, paramId.shift_tables_a_down_2, percentage1AxisModel.count, true, true, slots.tossRPMAsSpeed)
            }
            name: qsTr("Shift Speed 3-2 A")
        },
        TableMetaParam {
            param: TableParam {
                x: percentage1AxisModel
                value: registry.addArrayParam(MemoryRange.S32, paramId.shift_tables_a_down_3, percentage1AxisModel.count, true, true, slots.tossRPMAsSpeed)
            }
            name: qsTr("Shift Speed 4-3 A")
        },
        TableMetaParam {
            param: TableParam {
                x: percentage1AxisModel
                value: registry.addArrayParam(MemoryRange.S32, paramId.shift_tables_a_down_4, percentage1AxisModel.count, true, true, slots.tossRPMAsSpeed)
            }
            name: qsTr("Shift Speed 5-4 A")
        },
        TableMetaParam {
            param: TableParam {
                x: percentage1AxisModel
                value: registry.addArrayParam(MemoryRange.S32, paramId.shift_tables_a_down_5, percentage1AxisModel.count, true, true, slots.tossRPMAsSpeed)
            }
            name: qsTr("Shift Speed 6-5 A")
        }
    ]
    property
    list<TableMetaParam> rpmDownshiftTablesA: [
        TableMetaParam {
            param: TableParam {
                x: percentage1AxisModel
                value: SlotProxyModel {
                    sourceModel: downshiftTablesA[0].param.value.rawModel
                    slot: slots.rpm1
                }
            }
            name: qsTr("Shift RPM 2-1 A")
        },
        TableMetaParam {
            param: TableParam {
                x: percentage1AxisModel
                value: SlotProxyModel {
                    sourceModel: downshiftTablesA[1].param.value.rawModel
                    slot: slots.rpm1
                }
            }
            name: qsTr("Shift RPM 3-2 A")
        },
        TableMetaParam {
            param: TableParam {
                x: percentage1AxisModel
                value: SlotProxyModel {
                    sourceModel: downshiftTablesA[2].param.value.rawModel
                    slot: slots.rpm1
                }
            }
            name: qsTr("Shift RPM 4-3 A")
        },
        TableMetaParam {
            param: TableParam {
                x: percentage1AxisModel
                value: SlotProxyModel {
                    sourceModel: downshiftTablesA[3].param.value.rawModel
                    slot: slots.rpm1
                }
            }
            name: qsTr("Shift RPM 5-4 A")
        },
        TableMetaParam {
            param: TableParam {
                x: percentage1AxisModel
                value: SlotProxyModel {
                    sourceModel: downshiftTablesA[4].param.value.rawModel
                    slot: slots.rpm1
                }
            }
            name: qsTr("Shift RPM 6-5 A")
        }
    ]

    property
    list<TableMetaParam> downshiftTablesB: [
        TableMetaParam {
            param: TableParam {
                x: percentage1AxisModel
                value: registry.addArrayParam(MemoryRange.S32, paramId.shift_tables_b_down_1, percentage1AxisModel.count, true, true, slots.tossRPMAsSpeed)
            }
            name: qsTr("Shift Speed 2-1 B")
        },
        TableMetaParam {
            param: TableParam {
                x: percentage1AxisModel
                value: registry.addArrayParam(MemoryRange.S32, paramId.shift_tables_b_down_2, percentage1AxisModel.count, true, true, slots.tossRPMAsSpeed)
            }
            name: qsTr("Shift Speed 3-2 B")
        },
        TableMetaParam {
            param: TableParam {
                x: percentage1AxisModel
                value: registry.addArrayParam(MemoryRange.S32, paramId.shift_tables_b_down_3, percentage1AxisModel.count, true, true, slots.tossRPMAsSpeed)
            }
            name: qsTr("Shift Speed 4-3 B")
        },
        TableMetaParam {
            param: TableParam {
                x: percentage1AxisModel
                value: registry.addArrayParam(MemoryRange.S32, paramId.shift_tables_b_down_4, percentage1AxisModel.count, true, true, slots.tossRPMAsSpeed)
            }
            name: qsTr("Shift Speed 5-4 B")
        },
        TableMetaParam {
            param: TableParam {
                x: percentage1AxisModel
                value: registry.addArrayParam(MemoryRange.S32, paramId.shift_tables_b_down_5, percentage1AxisModel.count, true, true, slots.tossRPMAsSpeed)
            }
            name: qsTr("Shift Speed 6-5 B")
        }
    ]
    property
    list<TableMetaParam> rpmDownshiftTablesB: [
        TableMetaParam {
            param: TableParam {
                x: percentage1AxisModel
                value: SlotProxyModel {
                    sourceModel: downshiftTablesB[0].param.value.rawModel
                    slot: slots.rpm1
                }
            }
            name: qsTr("Shift RPM 2-1 B")
        },
        TableMetaParam {
            param: TableParam {
                x: percentage1AxisModel
                value: SlotProxyModel {
                    sourceModel: downshiftTablesB[1].param.value.rawModel
                    slot: slots.rpm1
                }
            }
            name: qsTr("Shift RPM 3-2 B")
        },
        TableMetaParam {
            param: TableParam {
                x: percentage1AxisModel
                value: SlotProxyModel {
                    sourceModel: downshiftTablesB[2].param.value.rawModel
                    slot: slots.rpm1
                }
            }
            name: qsTr("Shift RPM 4-3 B")
        },
        TableMetaParam {
            param: TableParam {
                x: percentage1AxisModel
                value: SlotProxyModel {
                    sourceModel: downshiftTablesB[3].param.value.rawModel
                    slot: slots.rpm1
                }
            }
            name: qsTr("Shift RPM 5-4 B")
        },
        TableMetaParam {
            param: TableParam {
                x: percentage1AxisModel
                value: SlotProxyModel {
                    sourceModel: downshiftTablesB[4].param.value.rawModel
                    slot: slots.rpm1
                }
            }
            name: qsTr("Shift RPM 6-5 B")
        }
    ]

    property
    list<TableMetaParam> shiftTorqueLimits: [
        TableMetaParam {
            param: TableParam {
                x: pressureAxisModel
                value: registry.addArrayParam(MemoryRange.S32, paramId.shift_torque_limit_1_2, pressureAxisModel.count, true, true, slots.percentage1)
            }
            name: qsTr("Shift 1-2 Torque Limit")
        },
        TableMetaParam {
            param: TableParam {
                x: pressureAxisModel
                value: registry.addArrayParam(MemoryRange.S32, paramId.shift_torque_limit_2_3, pressureAxisModel.count, true, true, slots.percentage1)
            }
            name: qsTr("Shift 2-3 Torque Limit")
        },
        TableMetaParam {
            param: TableParam {
                x: pressureAxisModel
                value: registry.addArrayParam(MemoryRange.S32, paramId.shift_torque_limit_3_4, pressureAxisModel.count, true, true, slots.percentage1)
            }
            name: qsTr("Shift 3-4 Torque Limit")
        },
        TableMetaParam {
            param: TableParam {
                x: pressureAxisModel
                value: registry.addArrayParam(MemoryRange.S32, paramId.shift_torque_limit_4_5, pressureAxisModel.count, true, true, slots.percentage1)
            }
            name: qsTr("Shift 4-5 Torque Limit")
        },
        TableMetaParam {
            param: TableParam {
                x: pressureAxisModel
                value: registry.addArrayParam(MemoryRange.S32, paramId.shift_torque_limit_5_6, pressureAxisModel.count, true, true, slots.percentage1)
            }
            name: qsTr("Shift 5-6 Torque Limit")
        },/*
        TableMetaParam {
            param: TableParam {
                x: pressureAxisModel
                value: registry.addArrayParam(MemoryRange.S32, paramId.shift_torque_limit_6_7, pressureAxisModel.count, true, true, slots.percentage1)
            }
            name: qsTr("Shift 6-7 Torque Limit")
        },
        TableMetaParam {
            param: TableParam {
                x: pressureAxisModel
                value: registry.addArrayParam(MemoryRange.S32, paramId.shift_torque_limit_7_8, pressureAxisModel.count, true, true, slots.percentage1)
            }
            name: qsTr("Shift 7-8 Torque Limit")
        },*/
        TableMetaParam {
            param: TableParam {
                x: pressureAxisModel
                value: registry.addArrayParam(MemoryRange.S32, paramId.shift_torque_limit_2_1, pressureAxisModel.count, true, true, slots.percentage1)
            }
            name: qsTr("Shift 2-1 Torque Limit")
        },
        TableMetaParam {
            param: TableParam {
                x: pressureAxisModel
                value: registry.addArrayParam(MemoryRange.S32, paramId.shift_torque_limit_3_2, pressureAxisModel.count, true, true, slots.percentage1)
            }
            name: qsTr("Shift 3-2 Torque Limit")
        },
        TableMetaParam {
            param: TableParam {
                x: pressureAxisModel
                value: registry.addArrayParam(MemoryRange.S32, paramId.shift_torque_limit_4_3, pressureAxisModel.count, true, true, slots.percentage1)
            }
            name: qsTr("Shift 4-3 Torque Limit")
        },
        TableMetaParam {
            param: TableParam {
                x: pressureAxisModel
                value: registry.addArrayParam(MemoryRange.S32, paramId.shift_torque_limit_5_4, pressureAxisModel.count, true, true, slots.percentage1)
            }
            name: qsTr("Shift 5-4 Torque Limit")
        },
        TableMetaParam {
            param: TableParam {
                x: pressureAxisModel
                value: registry.addArrayParam(MemoryRange.S32, paramId.shift_torque_limit_6_5, pressureAxisModel.count, true, true, slots.percentage1)
            }
            name: qsTr("Shift 6-5 Torque Limit")
        }/*,
        TableMetaParam {
            param: TableParam {
                x: pressureAxisModel
                value: registry.addArrayParam(MemoryRange.S32, paramId.shift_torque_limit_7_6, pressureAxisModel.count, true, true, slots.percentage1)
            }
            name: qsTr("Shift 7-6 Torque Limit")
        },
        TableMetaParam {
            param: TableParam {
                x: pressureAxisModel
                value: registry.addArrayParam(MemoryRange.S32, paramId.shift_torque_limit_8_7, pressureAxisModel.count, true, true, slots.percentage1)
            }
            name: qsTr("Shift 8-7 Torque Limit")
        }*/
    ]

    property
    list<TableMetaParam> downshiftTorqueLimit: [
        TableMetaParam {
            param: TableParam {
                x: pressureAxisModel
                value: registry.addArrayParam(MemoryRange.S32, paramId.shift_torque_limit_2_1, pressureAxisModel.count, true, true, slots.percentage1)
            }
            name: qsTr("Shift 2-1 Torque Limit")
        },
        TableMetaParam {
            param: TableParam {
                x: pressureAxisModel
                value: registry.addArrayParam(MemoryRange.S32, paramId.shift_torque_limit_3_2, pressureAxisModel.count, true, true, slots.percentage1)
            }
            name: qsTr("Shift 3-2 Torque Limit")
        },
        TableMetaParam {
            param: TableParam {
                x: pressureAxisModel
                value: registry.addArrayParam(MemoryRange.S32, paramId.shift_torque_limit_4_3, pressureAxisModel.count, true, true, slots.percentage1)
            }
            name: qsTr("Shift 4-3 Torque Limit")
        },
        TableMetaParam {
            param: TableParam {
                x: pressureAxisModel
                value: registry.addArrayParam(MemoryRange.S32, paramId.shift_torque_limit_5_4, pressureAxisModel.count, true, true, slots.percentage1)
            }
            name: qsTr("Shift 5-4 Torque Limit")
        },
        TableMetaParam {
            param: TableParam {
                x: pressureAxisModel
                value: registry.addArrayParam(MemoryRange.S32, paramId.shift_torque_limit_6_5, pressureAxisModel.count, true, true, slots.percentage1)
            }
            name: qsTr("Shift 6-5 Torque Limit")
        }/*,
        TableMetaParam {
            param: TableParam {
                x: pressureAxisModel
                value: registry.addArrayParam(MemoryRange.S32, paramId.shift_torque_limit_7_6, pressureAxisModel.count, true, true, slots.percentage1)
            }
            name: qsTr("Shift 7-6 Torque Limit")
        },
        TableMetaParam {
            param: TableParam {
                x: pressureAxisModel
                value: registry.addArrayParam(MemoryRange.S32, paramId.shift_torque_limit_8_7, pressureAxisModel.count, true, true, slots.percentage1)
            }
            name: qsTr("Shift 8-7 Torque Limit")
        }*/
    ]

    property ScalarMetaParam shiftTorqueLimitGarageShift: ScalarMetaParam {
        name: qsTr("Garage Shift Torque Limit")
        param: registry.addScalarParam(MemoryRange.S32, paramId.shift_torque_limit_garage_shift, true, true, slots.percentage1)
    }

    property ScalarMetaParam tccDisableTOSSPercentA: ScalarMetaParam {
        param: registry.addScalarParam(MemoryRange.S32, paramId.tcc_disable_toss_percent_a, true, true, slots.percentage1)
        name: qsTr("TCC Disable TOSS Percent A")
    }

    property ScalarMetaParam tccDisableTOSSPercentB: ScalarMetaParam {
        param: registry.addScalarParam(MemoryRange.S32, paramId.tcc_disable_toss_percent_b, true, true, slots.percentage1)
        name: qsTr("TCC Disable TOSS Percent B")
    }

    property ScalarMetaParam tccEnableGearA: ScalarMetaParam {
        param: registry.addScalarParam(MemoryRange.S32, paramId.tcc_enable_gear_a, true, true, slots.gear1)
        name: qsTr("TCC Enable Gear A")
    }

    property ScalarMetaParam tccEnableGearB: ScalarMetaParam {
        param: registry.addScalarParam(MemoryRange.S32, paramId.tcc_enable_gear_b, true, true, slots.gear1)
        name: qsTr("TCC Enable Gear B")
    }

    property ScalarMetaParam tccEnableTOSSA: ScalarMetaParam {
        param: registry.addScalarParam(MemoryRange.S32, paramId.tcc_enable_toss_a, true, true, slots.tossRPMAsSpeed)
        name: qsTr("TCC Enable TOSS Speed A")
    }

    property ScalarMetaParam tccEnableTOSSB: ScalarMetaParam {
        param: registry.addScalarParam(MemoryRange.S32, paramId.tcc_enable_toss_b, true, true, slots.tossRPMAsSpeed)
        name: qsTr("TCC Enable TOSS Speed B")
    }

    property ScalarMetaParam tccMaxThrottleA: ScalarMetaParam {
        param: registry.addScalarParam(MemoryRange.S32, paramId.tcc_max_throttle_a, true, true, slots.percentage1)
        name: qsTr("TCC Max Throttle A")
    }

    property ScalarMetaParam tccMaxThrottleB: ScalarMetaParam {
        param: registry.addScalarParam(MemoryRange.S32, paramId.tcc_max_throttle_b, true, true, slots.percentage1)
        name: qsTr("TCC Max Throttle B")
    }

    property ScalarMetaParam tccMinThrottleA: ScalarMetaParam {
        param: registry.addScalarParam(MemoryRange.S32, paramId.tcc_min_throttle_a, true, true, slots.percentage1)
        name: qsTr("TCC Min Throttle A")
    }

    property ScalarMetaParam tccMinThrottleB: ScalarMetaParam {
        param: registry.addScalarParam(MemoryRange.S32, paramId.tcc_min_throttle_b, true, true, slots.percentage1)
        name: qsTr("TCC Min Throttle B")
    }

    property ScalarMetaParam tccPrefillTime: ScalarMetaParam {
        param: registry.addScalarParam(MemoryRange.S32, paramId.tcc_prefill_time, true, true, slots.timeMilliseconds1)
        name: qsTr("TCC Prefill Time")
    }

    property ScalarMetaParam tccApplyTime: ScalarMetaParam {
        param: registry.addScalarParam(MemoryRange.S32, paramId.tcc_apply_time, true, true, slots.timeMilliseconds1)
        name: qsTr("TCC Apply Time")
    }

    property ScalarMetaParam tccPrefillPressure: ScalarMetaParam {
        param: registry.addScalarParam(MemoryRange.S32, paramId.tcc_prefill_pressure, true, true, slots.pressure)
        name: qsTr("TCC Prefill Pressure")
    }

    property ScalarMetaParam tccPrefillPercentage: ScalarMetaParam {
        param: registry.addScalarParam(MemoryRange.S32, paramId.tcc_prefill_percentage, true, true, slots.percentage2)
        name: qsTr("TCC Prefill Percentage")
    }

    property ScalarMetaParam tccMaxPressure: ScalarMetaParam {
        param: registry.addScalarParam(MemoryRange.S32, paramId.tcc_max_pressure, true, true, slots.pressure)
        name: qsTr("TCC Apply Max Pressure")
    }

    property ScalarMetaParam tccMaxPercentage: ScalarMetaParam {
        param: registry.addScalarParam(MemoryRange.S32, paramId.tcc_max_percentage, true, true, slots.percentage2)
        name: qsTr("TCC Apply Max Percentage")
    }

    property ScalarMetaParam tccPercentageProportionalConstant: ScalarMetaParam {
        param: registry.addScalarParam(MemoryRange.S32, paramId.tcc_percentage_proportional_constant, true, true, slots.percentagePerRpm)
        name: qsTr("TCC P Coeff")
    }

    property ScalarMetaParam tccPercentageIntegralConstant: ScalarMetaParam {
        param: registry.addScalarParam(MemoryRange.S32, paramId.tcc_percentage_integral_constant, true, true, slots.percentagePerRpmSec)
        name: qsTr("TCC I Coeff")
    }

    property ScalarMetaParam tccPercentageDerivativeConstant: ScalarMetaParam {
        param: registry.addScalarParam(MemoryRange.S32, paramId.tcc_percentage_derivative_constant, true, true, slots.percentagePerRpmPerSec)
        name: qsTr("TCC D Coeff")
    }

    property ScalarMetaParam tccPressureProportionalConstant: ScalarMetaParam {
        param: registry.addScalarParam(MemoryRange.S32, paramId.tcc_pressure_proportional_constant, true, true, slots.pressurePerRpm)
        name: qsTr("TCC P Coeff")
    }

    property ScalarMetaParam tccPressureIntegralConstant: ScalarMetaParam {
        param: registry.addScalarParam(MemoryRange.S32, paramId.tcc_pressure_integral_constant, true, true, slots.pressurePerRpmSec)
        name: qsTr("TCC I Coeff")
    }

    property ScalarMetaParam tccPressureDerivativeConstant: ScalarMetaParam {
        param: registry.addScalarParam(MemoryRange.S32, paramId.tcc_pressure_derivative_constant, true, true, slots.pressurePerRpmPerSec)
        name: qsTr("TCC D Coeff")
    }

    property ScalarMetaParam tccStrokeTime: ScalarMetaParam {
        param: registry.addScalarParam(MemoryRange.S32, paramId.tcc_stroke_time, true, true, slots.timeMilliseconds1)
        name: qsTr("TCC Stroke Time")
    }

    property ScalarMetaParam tccStrokePressure: ScalarMetaParam {
        param: registry.addScalarParam(MemoryRange.S32, paramId.tcc_stroke_pressure, true, true, slots.pressure)
        name: qsTr("TCC Stroke Pressure")
    }

    property ScalarMetaParam tccStrokePercentage: ScalarMetaParam {
        param: registry.addScalarParam(MemoryRange.S32, paramId.tcc_stroke_percentage, true, true, slots.percentage2)
        name: qsTr("TCC Stroke Percentage")
    }

    property TableMetaParam torqueConverterMult: TableMetaParam {
        param: TableParam {
            x: registry.addArrayParam(MemoryRange.S32, paramId.tc_mult_speedratio, 16, true, true, slots.ratio1)
            value: registry.addArrayParam(MemoryRange.S32, paramId.tc_mult_torqueratio, 16, true, true, slots.ratio1)
        }
        name: qsTr("Torque Converter Multiplication")
    }

    property ScalarMetaParam vehicleVariation: ScalarMetaParam {
        param: registry.addScalarParam(MemoryRange.S32, paramId.variation, true, true, slots.variationTypes)
        name: qsTr("Engine Type")
        resetNeeded: true
    }

    property ScalarMetaParam tireDiameter: ScalarMetaParam {
        param: registry.addScalarParam(MemoryRange.S32, paramId.tire_diameter, true, true, slots.length)
        name: qsTr("Tire Diameter")
    }

    property ScalarMetaParam transferCaseRatio: ScalarMetaParam {
        param: registry.addScalarParam(MemoryRange.S32, paramId.transfer_case_ratio, true, true, slots.ratio1)
        name: qsTr("Transfer Case Ratio")
    }

    property ScalarMetaParam vehicleMass: ScalarMetaParam {
        param: registry.addScalarParam(MemoryRange.S32, paramId.vehicle_mass, true, true, slots.mass)
        name: qsTr("Vehicle Mass")
    }

    property ScalarMetaParam voltageTPSIsReversed: ScalarMetaParam {
        param: registry.addScalarParam(MemoryRange.S32, paramId.voltage_tps_is_reversed, true, true, slots.booleanNormalReversed)
        name: qsTr("TPS Voltage Reversed")
    }

    property ScalarMetaParam voltageTPSCalibrationHigh: ScalarMetaParam {
        param: registry.addScalarParam(MemoryRange.S32, paramId.voltage_tps_calibration_high, true, true, slots.voltage1)
        name: qsTr("TPS Calibration High")
    }

    property ScalarMetaParam voltageTPSCalibrationLow: ScalarMetaParam {
        param: registry.addScalarParam(MemoryRange.S32, paramId.voltage_tps_calibration_low, true, true, slots.voltage1)
        name: qsTr("TPS Calibration Low")
    }

    property ScalarMetaParam voltageTPSGroundEnable: ScalarMetaParam {
        param: registry.addScalarParam(MemoryRange.S32, paramId.voltage_tps_ground_enable, true, true, slots.booleanOnOff1)
        name: qsTr("TPS Ground Enable")
    }

    property ScalarMetaParam voltageTPSFilterOrder: ScalarMetaParam {
        param: registry.addScalarParam(MemoryRange.S32, paramId.voltage_tps_filter_order, true, true, slots.timeMilliseconds1)
        name: qsTr("TPS Filter Order")
    }

    property ScalarMetaParam voltageMAPSensorHighCalibration: ScalarMetaParam {
        param: registry.addScalarParam(MemoryRange.S32, paramId.voltage_map_sensor_high_calibration, true, true, slots.voltage1)
        name: qsTr("MAP Calibration High")
    }

    property ScalarMetaParam voltageMAPSensorLowCalibration: ScalarMetaParam {
        param: registry.addScalarParam(MemoryRange.S32, paramId.voltage_map_sensor_low_calibration, true, true, slots.voltage1)
        name: qsTr("MAP Calibration Low")
    }

    property ScalarMetaParam voltageMAPSensorGroundEnable: ScalarMetaParam {
        param: registry.addScalarParam(MemoryRange.S32, paramId.voltage_map_sensor_ground_enable, true, true, slots.booleanOnOff1)
        name: qsTr("MAP Ground Enable")
    }

    property ScalarMetaParam transmissionType: ScalarMetaParam {
        param: registry.addScalarParam(MemoryRange.S32, paramId.transmission_type, true, true, slots.transmissionType1)
        name: qsTr("Trans Type")
        resetNeeded: true
    }

    property ScalarMetaParam transmissionTempBiasEnable: ScalarMetaParam {
        param: registry.addScalarParam(MemoryRange.S32, paramId.transmission_temp_bias_enable, true, true, slots.booleanOnOff1)
        name: qsTr("Trans Temp Bias Enable")
    }

    property ScalarMetaParam transmissionHasLinePressureSensor: ScalarMetaParam {
        param: registry.addScalarParam(MemoryRange.S32, paramId.transmission_main_pressure_sensor_present, true, true, slots.booleanYesNo1)
        name: qsTr("Trans Has Line Press Sensor")
    }

    property ScalarMetaParam transmissionHasLinePressureControl: ScalarMetaParam {
        param: registry.addScalarParam(MemoryRange.S32, paramId.transmission_has_line_pressure_control, true, true, slots.booleanYesNo1)
        name: qsTr("Trans Has Line Press Control")
    }

    property ScalarMetaParam transmissionHasAccumulatorControl: ScalarMetaParam {
        param: registry.addScalarParam(MemoryRange.S32, paramId.transmission_has_accumulator_control, true, true, slots.booleanYesNo1)
        name: qsTr("Trans Has Accumulator Control")
    }

    property ScalarMetaParam transmissionHasPWMTCC: ScalarMetaParam {
        param: registry.addScalarParam(MemoryRange.S32, paramId.transmission_has_pwm_tcc, true, true, slots.booleanYesNo1)
        name: qsTr("Trans Has PWM TCC")
    }

    property ScalarMetaParam cs2EngineTempBiasEnable: ScalarMetaParam {
        param: registry.addScalarParam(MemoryRange.S32, paramId.cs2_engine_temp_bias_enable, true, true, slots.booleanOnOff1)
        name: qsTr("Engine Temp Bias Enable")
    }

    property ScalarMetaParam pressureControlSource: ScalarMetaParam {
        param: registry.addScalarParam(MemoryRange.S32, paramId.pressure_control_source, true, true, slots.torqueSignalSource)
        name: qsTr("Pressure Control Source")
    }

    property TableMetaParam shiftSelectorGearVoltages: TableMetaParam {
        param: TableParam {
            x: hgmShiftSelectorCalibrationGearAxisModel
            value: registry.addArrayParam(MemoryRange.S32, paramId.shift_selector_gear_voltages, hgmShiftSelectorCalibrationGearAxisModel.count, true, true, slots.hgmShiftSelectorCalibrationSensorVoltage)
        }
        name: qsTr("Shift Selector Gear Voltages")
    }

    property ScalarMetaParam shiftSelectorODCancelAtStartup: ScalarMetaParam {
        param: registry.addScalarParam(MemoryRange.S32, paramId.shift_selector_overdrive_cancel_at_startup, true, true, slots.booleanOnOff1)
        name: qsTr("Shift Selector OD Cancel At Startup")
    }

    property ScalarMetaParam displayUnits: ScalarMetaParam {
        param: registry.addScalarParam(MemoryRange.S32, paramId.use_metric_units, true, true, slots.measurementSystem)
        name: qsTr("Display Units")
    }

    property ScalarMetaParam speedometerCalibration: ScalarMetaParam {
        param: registry.addScalarParam(MemoryRange.S32, paramId.speedometer_calibration, true, true, slots.speedoCalibration)
        name: qsTr("Speedometer Calibration")
    }

    property ScalarMetaParam startInhibitRelayType: ScalarMetaParam {
        param: registry.addScalarParam(MemoryRange.S32, paramId.start_inhibit_relay_type, true, true, slots.booleanNormalReversed)
        name: qsTr("Start Inhibit Relay Type")
    }

    property ScalarMetaParam vehicleSpeedSensorPulseCount: ScalarMetaParam {
        param: registry.addScalarParam(MemoryRange.S32, paramId.vehicle_speed_sensor_pulse_count, true, true, slots.count3)
        name: qsTr("Vehicle Speed Sensor Pulses")
    }

    property TableMetaParam transmissionGearNumbersRatios: TableMetaParam {
        param: TableParam {
            x: registry.addVarArrayParam(MemoryRange.S32, paramId.transmission_gears, 3, 8, false, false, slots.gear1)
            value: registry.addVarArrayParam(MemoryRange.S32, paramId.transmission_ratios, 3, 8, false, false, slots.ratio1)
        }
        name: qsTr("Gear Ratios")
    }

    property ScalarMetaParam evTorqueFilterOrder: ScalarMetaParam {
        param: registry.addScalarParam(MemoryRange.S32, paramId.ev_torque_filter_order, true, true, slots.timeMilliseconds1)
        name: qsTr("Torque Filter Length")
    }
    property ScalarMetaParam evSpeedFilterOrder: ScalarMetaParam {
        param: registry.addScalarParam(MemoryRange.S32, paramId.ev_speed_filter_order, true, true, slots.timeMilliseconds1)
        name: qsTr("Speed Filter Length")
    }
    property ScalarMetaParam evMotorTorqueIdle: ScalarMetaParam {
        param: registry.addScalarParam(MemoryRange.S32, paramId.ev_motor_torque_idle, true, true, slots.percentage2)
        name: qsTr("Motor Torque Idle")
    }
    property ScalarMetaParam evMotorTorqueShift: ScalarMetaParam {
        param: registry.addScalarParam(MemoryRange.S32, paramId.ev_motor_torque_shift, true, true, slots.percentage2)
        name: qsTr("Motor Torque Shift")
    }
    property ScalarMetaParam evMotorSpeedMax: ScalarMetaParam {
        param: registry.addScalarParam(MemoryRange.S32, paramId.ev_motor_speed_max, true, true, slots.rpm1)
        name: qsTr("Max Motor Speed")
    }
    property TableMetaParam evTorqueRampDownTime: TableMetaParam {
        param: TableParam {
            x: SlotArrayModel {
                slot: slots.count
                min: 1
                count: evTorqueRampDownTime.param.value.count
            }
            value: registry.addVarArrayParam(MemoryRange.S32, paramId.ev_torque_ramp_down_time, 1, 8, true, true, slots.timeMilliseconds1)
        }
        name: qsTr("Torque Ramp Down Time")
    }
    property TableMetaParam evTorqueRampUpTime: TableMetaParam {
        param: TableParam {
            x: SlotArrayModel {
                slot: slots.count
                min: 1
                count: evTorqueRampUpTime.param.value.count
            }
            value: registry.addVarArrayParam(MemoryRange.S32, paramId.ev_torque_ramp_up_time, 1, 8, true, true, slots.timeMilliseconds1)
        }
        name: qsTr("Torque Ramp Up Time")
    }
    property TableMetaParam evMotorTorqueMaxA: TableMetaParam {
        param: TableParam {
            x: SlotArrayModel {
                slot: slots.count
                min: 1
                count: evMotorTorqueMaxA.param.value.count
            }
            value: registry.addVarArrayParam(MemoryRange.S32, paramId.ev_motor_torque_max_a, 1, 8, true, true, slots.percentage1)
        }
        name: qsTr("Max Motoring Torque A")
    }
    property TableMetaParam evRegenTorqueMaxA: TableMetaParam {
        param: TableParam {
            x: SlotArrayModel {
                slot: slots.count
                min: 1
                count: evRegenTorqueMaxA.param.value.count
            }
            value: registry.addVarArrayParam(MemoryRange.S32, paramId.ev_regen_torque_max_a, 1, 8, true, true, slots.percentage1)
        }
        name: qsTr("Max Regen Torque A")
    }
    property ScalarMetaParam evMaxRegenSpeedA: ScalarMetaParam {
        param: registry.addScalarParam(MemoryRange.S32, paramId.ev_max_regen_speed_a, true, true, slots.tossRPMAsSpeed)
        name: qsTr("Full Regen Speed A")
    }
    property TableMetaParam evMotorTorqueMaxB: TableMetaParam {
        param: TableParam {
            x: SlotArrayModel {
                slot: slots.count
                min: 1
                count: evMotorTorqueMaxB.param.value.count
            }
            value: registry.addVarArrayParam(MemoryRange.S32, paramId.ev_motor_torque_max_b, 1, 8, true, true, slots.percentage1)
        }
        name: qsTr("Max Motoring Torque B")
    }
    property TableMetaParam evRegenTorqueMaxB: TableMetaParam {
        param: TableParam {
            x: SlotArrayModel {
                slot: slots.count
                min: 1
                count: evRegenTorqueMaxB.param.value.count
            }
            value: registry.addVarArrayParam(MemoryRange.S32, paramId.ev_regen_torque_max_b, 1, 8, true, true, slots.percentage1)
        }
        name: qsTr("Max Regen Torque B")
    }
    property ScalarMetaParam evMaxRegenSpeedB: ScalarMetaParam {
        param: registry.addScalarParam(MemoryRange.S32, paramId.ev_max_regen_speed_b, true, true, slots.tossRPMAsSpeed)
        name: qsTr("Full Regen Speed B")
    }
    property ScalarMetaParam ebusShiftSyncTolerance: ScalarMetaParam {
        param: registry.addScalarParam(MemoryRange.S32, paramId.ebus_shift_synchronization_tolerance, true, true, slots.rpm1)
        name: qsTr("Shift Sync Tolerance")
    }
    property ScalarMetaParam ebusShiftSyncDuration: ScalarMetaParam {
        param: registry.addScalarParam(MemoryRange.S32, paramId.ebus_shift_synchronization_duration, true, true, slots.timeMilliseconds1)
        name: qsTr("Shift Sync Duration")
    }
    property TableMetaParam clutchReleaseTime: TableMetaParam {
        param: TableParam {
            x: SlotArrayModel {
                slot: slots.count
                min: 1
                count: clutchReleaseTime.param.value.count
            }
            value: registry.addVarArrayParam(MemoryRange.S32, paramId.clutch_release_time, 1, 8, true, true, slots.timeMilliseconds1)
        }
        name: qsTr("Clutch Release Time")
    }
    property TableMetaParam clutchPrefillTime: TableMetaParam {
        param: TableParam {
            x: SlotArrayModel {
                slot: slots.count
                min: 1
                count: clutchPrefillTime.param.value.count
            }
            value: registry.addVarArrayParam(MemoryRange.S32, paramId.clutch_prefill_time, 1, 8, true, true, slots.timeMilliseconds1)
        }
        name: qsTr("Clutch Prefill Time")
    }
    property TableMetaParam clutchPrefillPressure: TableMetaParam {
        param: TableParam {
            x: SlotArrayModel {
                slot: slots.count
                min: 1
                count: clutchPrefillPressure.param.value.count
            }
            value: registry.addVarArrayParam(MemoryRange.S32, paramId.clutch_prefill_pressure, 1, 8, true, true, slots.pressure)
        }
        name: qsTr("Clutch Prefill Pressure")
    }
    property TableMetaParam clutchPrefillPercentage: TableMetaParam {
        param: TableParam {
            x: SlotArrayModel {
                slot: slots.count
                min: 1
                count: clutchPrefillPercentage.param.value.count
            }
            value: registry.addVarArrayParam(MemoryRange.S32, paramId.clutch_prefill_percentage, 1, 8, true, true, slots.percentage2)
        }
        name: qsTr("Clutch Prefill Pressure %")
    }
    property TableMetaParam clutchStrokeTime: TableMetaParam {
        param: TableParam {
            x: SlotArrayModel {
                slot: slots.count
                min: 1
                count: clutchStrokeTime.param.value.count
            }
            value: registry.addVarArrayParam(MemoryRange.S32, paramId.clutch_stroke_time, 1, 8, true, true, slots.timeMilliseconds1)
        }
        name: qsTr("Clutch Stroke Time")
    }
    property TableMetaParam clutchStrokePressure: TableMetaParam {
        param: TableParam {
            x: SlotArrayModel {
                slot: slots.count
                min: 1
                count: clutchStrokeTime.param.value.count
            }
            value: registry.addVarArrayParam(MemoryRange.S32, paramId.clutch_stroke_pressure, 1, 8, true, true, slots.pressure)
        }
        name: qsTr("Clutch Stroke Pressure")
    }
    property ScalarMetaParam evJ1939CtlSourceAddress: ScalarMetaParam {
        param: registry.addScalarParam(MemoryRange.S32, paramId.ev_j1939_ctl_source_address, true, true, slots.hex32bit)
        name: qsTr("J1939 CTL Source Address")
    }
    property ScalarMetaParam evDriveFaultCount: ScalarMetaParam {
        param: registry.addScalarParam(MemoryRange.S32, paramId.ev_drive_fault_count, false, false, slots.count)
        name: qsTr("EV Drive Fault Count")
    }
    property ScalarMetaParam evDriveLastFaultType: ScalarMetaParam {
        param: registry.addScalarParam(MemoryRange.S32, paramId.ev_drive_last_fault_type, false, false, slots.evDriveFault)
        name: qsTr("EV Drive Last Fault")
    }
}
