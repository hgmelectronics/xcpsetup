import QtQuick 2.5
import com.hgmelectronics.setuptools.xcp 1.0
import com.hgmelectronics.setuptools 1.0
import com.hgmelectronics.setuptools.ui 1.0

ParamRegistry {
    id: root
    property bool useMetricUnits

    property ParamId paramId: ParamId {}
    property Slots slots: Slots {
        useMetricUnits: root.useMetricUnits
        tireDiameter: root.tireDiameter.param.floatVal
        finalDriveRatio: root.finalDriveRatio.param.floatVal
    }

    property ScalarMetaParam transmissionTurbineShaftSpeedSensorPulseCount: ScalarMetaParam {
        param: ScalarParam {
            registry: root
            dataType: Param.S32
            addr: paramId.transmission_turbine_shaft_speed_sensor_pulse_count
            writable: true
            saveable: true
            slot: slots.count3
            name: qsTr("Turbine Speed Sensor Pulses")
        }
    }

    property ScalarMetaParam transmissionInputShaftSpeedSensorPulseCount: ScalarMetaParam {
        param: ScalarParam {
            registry: root
            dataType: Param.S32
            addr: paramId.transmission_input_shaft_speed_sensor_pulse_count
            writable: true
            saveable: true
            slot: slots.count3
            name: qsTr("Input Shaft Speed Sensor Pulses")
        }
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

    /*readonly*/ property ArrayParam controllerSoftwareVersionArray: ArrayParam {
        registry: root
        dataType: Param.S32
        addr: paramId.controller_software_version
        minCount: 1
        maxCount: 33
        writable: false
        saveable: false
        slot: slots.count
        name: qsTr("Controller Software Version")
    }
    property ModelStringProxy controllerSoftwareVersionStringProxy : ModelStringProxy {
        source: controllerSoftwareVersionArray.floatModel
        packing: ModelStringProxy.Char
    }
    /*readonly*/ property string controllerSoftwareVersion: controllerSoftwareVersionStringProxy.string

    property ScalarMetaParam controllerHeapUsed: ScalarMetaParam {
        param: ScalarParam {
            registry: root
            dataType: Param.S32
            addr: paramId.controller_heap_used
            writable: false
            saveable: false
            slot: slots.count
            name: qsTr("Heap Used")
        }
    }

    property ScalarMetaParam controllerHeapSize: ScalarMetaParam {
        param: ScalarParam {
            registry: root
            dataType: Param.S32
            addr: paramId.controller_heap_size
            writable: false
            saveable: false
            slot: slots.count
            name: qsTr("Heap Size")
        }
    }

    property ScalarMetaParam controllerHeapAllocationCount: ScalarMetaParam {
        param: ScalarParam {
            registry: root
            dataType: Param.S32
            addr: paramId.controller_heap_allocation_count
            writable: false
            saveable: false
            slot: slots.count
            name: qsTr("Allocation Count")
        }
    }

    property ScalarMetaParam controllerHeapReleaseCount: ScalarMetaParam {
        param: ScalarParam {
            registry: root
            dataType: Param.S32
            addr: paramId.controller_heap_release_count
            writable: false
            saveable: false
            slot: slots.count
            name: qsTr("Release Count")
        }
    }

    property ScalarMetaParam controllerTachInputFrequency: ScalarMetaParam {
        param: ScalarParam {
            registry: root
            dataType: Param.S32
            addr: paramId.controller_tach_input_frequency
            writable: false
            saveable: false
            slot: slots.frequency
            name: qsTr("Tachometer")
        }
    }

    property ScalarMetaParam controllerTissInputFrequency: ScalarMetaParam {
        param: ScalarParam {
            registry: root
            dataType: Param.S32
            addr: paramId.controller_tiss_input_frequency
            writable: false
            saveable: false
            slot: slots.frequency
            name: qsTr("TISS")
        }
    }

    property ScalarMetaParam controllerTossInputFrequency: ScalarMetaParam {
        param: ScalarParam {
            registry: root
            dataType: Param.S32
            addr: paramId.controller_toss_input_frequency
            writable: false
            saveable: false
            slot: slots.frequency
            name: qsTr("TOSS")
        }
    }

    property ScalarMetaParam controllerSpareInputFrequency: ScalarMetaParam {
        param: ScalarParam {
            registry: root
            dataType: Param.S32
            addr: paramId.controller_spare_input_frequency
            writable: false
            saveable: false
            slot: slots.frequency
            name: qsTr("Spare")
        }
    }

    property ScalarMetaParam controllerThrottlePositionSensorVoltage: ScalarMetaParam {
        param: ScalarParam {
            registry: root
            dataType: Param.S32
            addr: paramId.controller_throttle_position_sensor_voltage
            writable: false
            saveable: false
            slot: slots.voltage1
            name: qsTr("Throttle Position")
        }
    }

    property ScalarMetaParam controllerMAPSensorVoltage: ScalarMetaParam {
        param: ScalarParam {
            registry: root
            dataType: Param.S32
            addr: paramId.controller_map_sensor_voltage
            writable: false
            saveable: false
            slot: slots.voltage1
            name: qsTr("MAP")
        }
    }

    property ScalarMetaParam controllerInternalTemperatureSensorVoltage: ScalarMetaParam {
        param: ScalarParam {
            registry: root
            dataType: Param.S32
            addr: paramId.controller_internal_temperature_sensor_voltage
            writable: false
            saveable: false
            slot: slots.voltage1
            name: qsTr("Internal Temp")
        }
    }

    property ScalarMetaParam controllerInternalTemperature: ScalarMetaParam {
        param: ScalarParam {
            registry: root
            dataType: Param.S32
            addr: paramId.controller_internal_temperature
            writable: false
            saveable: false
            slot: slots.temperature1
            name: qsTr("Internal Temp")
        }
    }

    property ScalarMetaParam controllerEngineTemperatureSensorVoltage: ScalarMetaParam {
        param: ScalarParam {
            registry: root
            dataType: Param.S32
            addr: paramId.controller_engine_temperature_sensor_voltage
            writable: false
            saveable: false
            slot: slots.voltage1
            name: qsTr("Engine Temp")
        }
    }

    property ScalarMetaParam controllerTransmissionTemperatureSensorVoltage: ScalarMetaParam {
        param: ScalarParam {
            registry: root
            dataType: Param.S32
            addr: paramId.controller_transmission_temperature_sensor_voltage
            writable: false
            saveable: false
            slot: slots.voltage1
            name: qsTr("Trans Temp")
        }
    }

    property ScalarMetaParam controllerMultiplexedSensorVoltage: ScalarMetaParam {
        param: ScalarParam {
            registry: root
            dataType: Param.S32
            addr: paramId.controller_multiplexed_sensor_voltage
            writable: false
            saveable: false
            slot: slots.voltage1
            name: qsTr("Multiplex")
        }
    }

    property ScalarMetaParam controllerBus5Voltage: ScalarMetaParam {
        param: ScalarParam {
            registry: root
            dataType: Param.S32
            addr: paramId.controller_5_volt_bus_voltage
            writable: false
            saveable: false
            slot: slots.voltage1
            name: qsTr("5V Bus")
        }
    }

    property ScalarMetaParam controllerBus3_3Voltage: ScalarMetaParam {
        param: ScalarParam {
            registry: root
            dataType: Param.S32
            addr: paramId.controller_3_3_volt_bus_voltage
            writable: false
            saveable: false
            slot: slots.voltage1
            name: qsTr("3.3V Bus")
        }
    }

    property ScalarMetaParam controllerBus1_8Voltage: ScalarMetaParam {
        param: ScalarParam {
            registry: root
            dataType: Param.S32
            addr: paramId.controller_1_8_volt_bus_voltage
            writable: false
            saveable: false
            slot: slots.voltage1
            name: qsTr("1.8V Bus")
        }
    }

    property ScalarMetaParam controllerBus12Voltage: ScalarMetaParam {
        param: ScalarParam {
            registry: root
            dataType: Param.S32
            addr: paramId.controller_12_volt_bus_voltage
            writable: false
            saveable: false
            slot: slots.voltage1
            name: qsTr("12V Bus")
        }
    }

    property ScalarMetaParam controllerBusVoltage: ScalarMetaParam {
        param: ScalarParam {
            registry: root
            dataType: Param.S32
            addr: paramId.controller_voltage
            writable: false
            saveable: false
            slot: slots.voltage1
            name: qsTr("Main Bus")
        }
    }

    property ScalarMetaParam controllerSpeedTimer1Frequency: ScalarMetaParam {
        param: ScalarParam {
            registry: root
            dataType: Param.S32
            addr: paramId.controller_speed_timer_1_frequency
            writable: true
            saveable: false
            slot: slots.frequency
            name: qsTr("Speed 1")
        }
        immediateWrite: true
    }

    property ScalarMetaParam controllerSpeedTimer2Frequency: ScalarMetaParam {
        param: ScalarParam {
            registry: root
            dataType: Param.S32
            addr: paramId.controller_speed_timer_2_frequency
            writable: true
            saveable: false
            slot: slots.frequency
            name: qsTr("Speed 2")
        }
        immediateWrite: true
    }

    property TableMetaParam controllerSwitchState: TableMetaParam {
        param: TableParam {
            x: switchIdAxisModel
            value: ArrayParam {
                registry: root
                dataType: Param.S32
                addr: paramId.controller_switch_state
                minCount: switchIdAxisModel.count
                writable: false
                saveable: false
                slot: slots.booleanOnOff1
                name: qsTr("Switch Monitor Input")
            }
        }
    }

    property TableMetaParam controllerSwitchCurrent: TableMetaParam {
        param: TableParam {
            x: switchIdAxisModel
            value: ArrayParam {
                registry: root
                dataType: Param.S32
                addr: paramId.controller_switch_current
                minCount: switchIdAxisModel.count
                writable: false
                saveable: false
                slot: slots.booleanOnOff1
                name: qsTr("Switch Monitor Output")
            }
        }
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
        param: ScalarParam {
            registry: root
            dataType: Param.S32
            addr: paramId.controller_sd_card_write_protect
            writable: false
            saveable: false
            slot: slots.booleanOnOff1
            name: qsTr("SD Card Protect")
        }
    }

    property ScalarMetaParam controllerSDCardPresent: ScalarMetaParam {
        param: ScalarParam {
            registry: root
            dataType: Param.S32
            addr: paramId.controller_sd_card_present
            writable: false
            saveable: false
            slot: slots.booleanOnOff1
            name: qsTr("SD Card Present")
        }
    }

    property ScalarMetaParam controllerMasterDriverFault: ScalarMetaParam {
        param: ScalarParam {
            registry: root
            dataType: Param.S32
            addr: paramId.controller_master_driver_fault
            writable: false
            saveable: false
            slot: slots.booleanOnOff1
            name: qsTr("Master Driver Fault")
        }
    }

    property ScalarMetaParam controllerUSBPower: ScalarMetaParam {
        param: ScalarParam {
            registry: root
            dataType: Param.S32
            addr: paramId.controller_usb_power
            writable: false
            saveable: false
            slot: slots.booleanOnOff1
            name: qsTr("USB Power")
        }
    }

    property ScalarMetaParam controllerUSBConnect: ScalarMetaParam {
        param: ScalarParam {
            registry: root
            dataType: Param.S32
            addr: paramId.controller_usb_connect
            writable: false
            saveable: false
            slot: slots.booleanOnOff1
            name: qsTr("USB Connect")
        }
        immediateWrite: true
    }

    property ScalarMetaParam controllerGreenLED: ScalarMetaParam {
        param: ScalarParam {
            registry: root
            dataType: Param.S32
            addr: paramId.controller_green_led
            writable: false
            saveable: false
            slot: slots.booleanOnOff1
            name: qsTr("Green LED")
        }
        immediateWrite: true
    }

    property ScalarMetaParam controllerRedLED: ScalarMetaParam {
        param: ScalarParam {
            registry: root
            dataType: Param.S32
            addr: paramId.controller_red_led
            writable: false
            saveable: false
            slot: slots.booleanOnOff1
            name: qsTr("Red LED")
        }
        immediateWrite: true
    }

    property ScalarMetaParam controllerTransmissionTemperatureSensorBias: ScalarMetaParam {
        param: ScalarParam {
            registry: root
            dataType: Param.S32
            addr: paramId.controller_transmission_temperature_sensor_bias
            writable: false
            saveable: false
            slot: slots.booleanOnOff1
            name: qsTr("Trans Temperature Sensor Bias")
        }
        immediateWrite: true
    }

    property ScalarMetaParam controllerEngineTemperatureSensorBias: ScalarMetaParam {
        param: ScalarParam {
            registry: root
            dataType: Param.S32
            addr: paramId.controller_engine_temperature_sensor_bias
            writable: false
            saveable: false
            slot: slots.booleanOnOff1
            name: qsTr("Engine Temperature Sensor Bias")
        }
        immediateWrite: true
    }

    property ScalarMetaParam controllerThrottlePositionSensorGround: ScalarMetaParam {
        param: ScalarParam {
            registry: root
            dataType: Param.S32
            addr: paramId.controller_throttle_position_sensor_ground
            writable: false
            saveable: false
            slot: slots.booleanOnOff1
            name: qsTr("Throttle Position Sensor Ground")
        }
        immediateWrite: true
    }

    property ScalarMetaParam controllerMAPSensorGround: ScalarMetaParam {
        param: ScalarParam {
            registry: root
            dataType: Param.S32
            addr: paramId.controller_map_ground
            writable: false
            saveable: false
            slot: slots.booleanOnOff1
            name: qsTr("MAP Sensor Ground")
        }
        immediateWrite: true
    }

    /*readonly*/ property ArrayParam controllerPWMDriverFrequency: ArrayParam {
        registry: root
        dataType: Param.S32
        addr: paramId.controller_pwmdriver_frequency
        minCount: 12
        writable: true
        saveable: false
        slot: slots.frequency
        name: qsTr("")
    }

    /*readonly*/ property ArrayParam controllerPWMDriverDutyCycle: ArrayParam {
        registry: root
        dataType: Param.S32
        addr: paramId.controller_pwmdriver_duty_cycle
        minCount: 12
        writable: true
        saveable: false
        slot: slots.percentage2
        name: qsTr("")
    }

    /*readonly*/ property ArrayParam controllerPWMDriverMode: ArrayParam {
        registry: root
        dataType: Param.S32
        addr: paramId.controller_pwmdriver_mode
        minCount: 12
        writable: true
        saveable: false
        slot: slots.pwmDriverMode
        name: qsTr("")
    }

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

    //    /*readonly*/ property ArrayParam : registry.addScalarParam(MemoryRange.S32, paramId.controller_switch_state, false, false, slots)
    //    /*readonly*/ property ArrayParam : registry.addScalarParam(MemoryRange.S32, paramId.controller_switch_current, false, false, slots)

    property ScalarMetaParamList transmissionShaftSpeedSensorPulseCount: ScalarMetaParamList {
        ScalarMetaParam {
            param: ScalarParam {
                registry: root
                dataType: Param.S32
                addr: paramId.transmission_shaft_1_speed_sensor_pulse_count
                writable: true
                saveable: true
                slot: slots.count3
                name: qsTr("Trans Shaft 1 Pulses")
            }
        }
        ScalarMetaParam {
            param: ScalarParam {
                registry: root
                dataType: Param.S32
                addr: paramId.transmission_shaft_2_speed_sensor_pulse_count
                writable: true
                saveable: true
                slot: slots.count3
                name: qsTr("Trans Shaft 2 Pulses")
            }
        }
        ScalarMetaParam {
            param: ScalarParam {
                registry: root
                dataType: Param.S32
                addr: paramId.transmission_shaft_3_speed_sensor_pulse_count
                writable: true
                saveable: true
                slot: slots.count3
                name: qsTr("Trans Shaft 3 Pulses")
            }
        }
        ScalarMetaParam {
            param: ScalarParam {
                registry: root
                dataType: Param.S32
                addr: paramId.transmission_shaft_4_speed_sensor_pulse_count
                writable: true
                saveable: true
                slot: slots.count3
                name: qsTr("Trans Shaft 4 Pulses")
            }
        }
        ScalarMetaParam {
            param: ScalarParam {
                registry: root
                dataType: Param.S32
                addr: paramId.transmission_shaft_5_speed_sensor_pulse_count
                writable: true
                saveable: true
                slot: slots.count3
                name: qsTr("Trans Shaft 5 Pulses")
            }
        }
        ScalarMetaParam {
            param: ScalarParam {
                registry: root
                dataType: Param.S32
                addr: paramId.transmission_shaft_6_speed_sensor_pulse_count
                writable: true
                saveable: true
                slot: slots.count3
                name: qsTr("Trans Shaft 6 Pulses")
            }
        }
    }

    property ScalarMetaParamList transmissionShiftPrefillTime: ScalarMetaParamList {
        ScalarMetaParam {
            param: ScalarParam {
                registry: root
                dataType: Param.S32
                addr: paramId.transmission_shift_r_n_prefill_time
                writable: true
                saveable: true
                slot: slots.timeMilliseconds1
                name: qsTr("Prefill Time R-N")
            }
        }
        ScalarMetaParam {
            param: ScalarParam {
                registry: root
                dataType: Param.S32
                addr: paramId.transmission_shift_n_r_prefill_time
                writable: true
                saveable: true
                slot: slots.timeMilliseconds1
                name: qsTr("Prefill Time N-R")
            }
        }
        ScalarMetaParam {
            param: ScalarParam {
                registry: root
                dataType: Param.S32
                addr: paramId.transmission_shift_n_1_prefill_time
                writable: true
                saveable: true
                slot: slots.timeMilliseconds1
                name: qsTr("Prefill Time N-1")
            }
        }
        ScalarMetaParam {
            param: ScalarParam {
                registry: root
                dataType: Param.S32
                addr: paramId.transmission_shift_1_n_prefill_time
                writable: true
                saveable: true
                slot: slots.timeMilliseconds1
                name: qsTr("Prefill Time 1-N")
            }
        }
        ScalarMetaParam {
            param: ScalarParam {
                registry: root
                dataType: Param.S32
                addr: paramId.transmission_shift_1_2_prefill_time
                writable: true
                saveable: true
                slot: slots.timeMilliseconds1
                name: qsTr("Prefill Time 1-2")
            }
        }
        ScalarMetaParam {
            param: ScalarParam {
                registry: root
                dataType: Param.S32
                addr: paramId.transmission_shift_2_1_prefill_time
                writable: true
                saveable: true
                slot: slots.timeMilliseconds1
                name: qsTr("Prefill Time 2-1")
            }
        }
        ScalarMetaParam {
            param: ScalarParam {
                registry: root
                dataType: Param.S32
                addr: paramId.transmission_shift_2_3_prefill_time
                writable: true
                saveable: true
                slot: slots.timeMilliseconds1
                name: qsTr("Prefill Time 2-3")
            }
        }
        ScalarMetaParam {
            param: ScalarParam {
                registry: root
                dataType: Param.S32
                addr: paramId.transmission_shift_3_2_prefill_time
                writable: true
                saveable: true
                slot: slots.timeMilliseconds1
                name: qsTr("Prefill Time 3-2")
            }
        }
        ScalarMetaParam {
            param: ScalarParam {
                registry: root
                dataType: Param.S32
                addr: paramId.transmission_shift_3_4_prefill_time
                writable: true
                saveable: true
                slot: slots.timeMilliseconds1
                name: qsTr("Prefill Time 3-4")
            }
        }
        ScalarMetaParam {
            param: ScalarParam {
                registry: root
                dataType: Param.S32
                addr: paramId.transmission_shift_4_3_prefill_time
                writable: true
                saveable: true
                slot: slots.timeMilliseconds1
                name: qsTr("Prefill Time 4-3")
            }
        }
        ScalarMetaParam {
            param: ScalarParam {
                registry: root
                dataType: Param.S32
                addr: paramId.transmission_shift_4_5_prefill_time
                writable: true
                saveable: true
                slot: slots.timeMilliseconds1
                name: qsTr("Prefill Time 4-5")
            }
        }
        ScalarMetaParam {
            param: ScalarParam {
                registry: root
                dataType: Param.S32
                addr: paramId.transmission_shift_5_4_prefill_time
                writable: true
                saveable: true
                slot: slots.timeMilliseconds1
                name: qsTr("Prefill Time 5-4")
            }
        }
        ScalarMetaParam {
            param: ScalarParam {
                registry: root
                dataType: Param.S32
                addr: paramId.transmission_shift_5_6_prefill_time
                writable: true
                saveable: true
                slot: slots.timeMilliseconds1
                name: qsTr("Prefill Time 5-6")
            }
        }
        ScalarMetaParam {
            param: ScalarParam {
                registry: root
                dataType: Param.S32
                addr: paramId.transmission_shift_6_5_prefill_time
                writable: true
                saveable: true
                slot: slots.timeMilliseconds1
                name: qsTr("Prefill Time 6-5")
            }
        }
    }

    property ScalarMetaParamList transmissionShiftPrefillPercentage: ScalarMetaParamList {
        ScalarMetaParam {
            param: ScalarParam {
                registry: root
                dataType: Param.S32
                addr: paramId.transmission_shift_r_n_prefill_percentage
                writable: true
                saveable: true
                slot: slots.percentage1
                name: qsTr("Prefill Pressure R-N")
            }
        }
        ScalarMetaParam {
            param: ScalarParam {
                registry: root
                dataType: Param.S32
                addr: paramId.transmission_shift_n_r_prefill_percentage
                writable: true
                saveable: true
                slot: slots.percentage1
                name: qsTr("Prefill Pressure N-R")
            }
        }
        ScalarMetaParam {
            param: ScalarParam {
                registry: root
                dataType: Param.S32
                addr: paramId.transmission_shift_n_1_prefill_percentage
                writable: true
                saveable: true
                slot: slots.percentage1
                name: qsTr("Prefill Pressure N-1")
            }
        }
        ScalarMetaParam {
            param: ScalarParam {
                registry: root
                dataType: Param.S32
                addr: paramId.transmission_shift_1_n_prefill_percentage
                writable: true
                saveable: true
                slot: slots.percentage1
                name: qsTr("Prefill Pressure 1-N")
            }
        }
        ScalarMetaParam {
            param: ScalarParam {
                registry: root
                dataType: Param.S32
                addr: paramId.transmission_shift_1_2_prefill_percentage
                writable: true
                saveable: true
                slot: slots.percentage1
                name: qsTr("Prefill Pressure 1-2")
            }
        }
        ScalarMetaParam {
            param: ScalarParam {
                registry: root
                dataType: Param.S32
                addr: paramId.transmission_shift_2_1_prefill_percentage
                writable: true
                saveable: true
                slot: slots.percentage1
                name: qsTr("Prefill Pressure 2-1")
            }
        }
        ScalarMetaParam {
            param: ScalarParam {
                registry: root
                dataType: Param.S32
                addr: paramId.transmission_shift_2_3_prefill_percentage
                writable: true
                saveable: true
                slot: slots.percentage1
                name: qsTr("Prefill Pressure 2-3")
            }
        }
        ScalarMetaParam {
            param: ScalarParam {
                registry: root
                dataType: Param.S32
                addr: paramId.transmission_shift_3_2_prefill_percentage
                writable: true
                saveable: true
                slot: slots.percentage1
                name: qsTr("Prefill Pressure 3-2")
            }
        }
        ScalarMetaParam {
            param: ScalarParam {
                registry: root
                dataType: Param.S32
                addr: paramId.transmission_shift_3_4_prefill_percentage
                writable: true
                saveable: true
                slot: slots.percentage1
                name: qsTr("Prefill Pressure 3-4")
            }
        }
        ScalarMetaParam {
            param: ScalarParam {
                registry: root
                dataType: Param.S32
                addr: paramId.transmission_shift_4_3_prefill_percentage
                writable: true
                saveable: true
                slot: slots.percentage1
                name: qsTr("Prefill Pressure 4-3")
            }
        }
        ScalarMetaParam {
            param: ScalarParam {
                registry: root
                dataType: Param.S32
                addr: paramId.transmission_shift_4_5_prefill_percentage
                writable: true
                saveable: true
                slot: slots.percentage1
                name: qsTr("Prefill Pressure 4-5")
            }
        }
        ScalarMetaParam {
            param: ScalarParam {
                registry: root
                dataType: Param.S32
                addr: paramId.transmission_shift_5_4_prefill_percentage
                writable: true
                saveable: true
                slot: slots.percentage1
                name: qsTr("Prefill Pressure 5-4")
            }
        }
        ScalarMetaParam {
            param: ScalarParam {
                registry: root
                dataType: Param.S32
                addr: paramId.transmission_shift_5_6_prefill_percentage
                writable: true
                saveable: true
                slot: slots.percentage1
                name: qsTr("Prefill Pressure 5-6")
            }
        }
        ScalarMetaParam {
            param: ScalarParam {
                registry: root
                dataType: Param.S32
                addr: paramId.transmission_shift_6_5_prefill_percentage
                writable: true
                saveable: true
                slot: slots.percentage1
                name: qsTr("Prefill Pressure 6-5")
            }
        }
    }

    property ScalarMetaParamList transmissionShiftPrefillPressure: ScalarMetaParamList {
        ScalarMetaParam {
            param: ScalarParam {
                registry: root
                dataType: Param.S32
                addr: paramId.transmission_shift_r_n_prefill_pressure
                writable: true
                saveable: true
                slot: slots.pressure
                name: qsTr("Prefill Pressure R-N")
            }
        }
        ScalarMetaParam {
            param: ScalarParam {
                registry: root
                dataType: Param.S32
                addr: paramId.transmission_shift_n_r_prefill_pressure
                writable: true
                saveable: true
                slot: slots.pressure
                name: qsTr("Prefill Pressure N-R")
            }
        }
        ScalarMetaParam {
            param: ScalarParam {
                registry: root
                dataType: Param.S32
                addr: paramId.transmission_shift_n_1_prefill_pressure
                writable: true
                saveable: true
                slot: slots.pressure
                name: qsTr("Prefill Pressure N-1")
            }
        }
        ScalarMetaParam {
            param: ScalarParam {
                registry: root
                dataType: Param.S32
                addr: paramId.transmission_shift_1_n_prefill_pressure
                writable: true
                saveable: true
                slot: slots.pressure
                name: qsTr("Prefill Pressure 1-N")
            }
        }
        ScalarMetaParam {
            param: ScalarParam {
                registry: root
                dataType: Param.S32
                addr: paramId.transmission_shift_1_2_prefill_pressure
                writable: true
                saveable: true
                slot: slots.pressure
                name: qsTr("Prefill Pressure 1-2")
            }
        }
        ScalarMetaParam {
            param: ScalarParam {
                registry: root
                dataType: Param.S32
                addr: paramId.transmission_shift_2_1_prefill_pressure
                writable: true
                saveable: true
                slot: slots.pressure
                name: qsTr("Prefill Pressure 2-1")
            }
        }
        ScalarMetaParam {
            param: ScalarParam {
                registry: root
                dataType: Param.S32
                addr: paramId.transmission_shift_2_3_prefill_pressure
                writable: true
                saveable: true
                slot: slots.pressure
                name: qsTr("Prefill Pressure 2-3")
            }
        }
        ScalarMetaParam {
            param: ScalarParam {
                registry: root
                dataType: Param.S32
                addr: paramId.transmission_shift_3_2_prefill_pressure
                writable: true
                saveable: true
                slot: slots.pressure
                name: qsTr("Prefill Pressure 3-2")
            }
        }
        ScalarMetaParam {
            param: ScalarParam {
                registry: root
                dataType: Param.S32
                addr: paramId.transmission_shift_3_4_prefill_pressure
                writable: true
                saveable: true
                slot: slots.pressure
                name: qsTr("Prefill Pressure 3-4")
            }
        }
        ScalarMetaParam {
            param: ScalarParam {
                registry: root
                dataType: Param.S32
                addr: paramId.transmission_shift_4_3_prefill_pressure
                writable: true
                saveable: true
                slot: slots.pressure
                name: qsTr("Prefill Pressure 4-3")
            }
        }
        ScalarMetaParam {
            param: ScalarParam {
                registry: root
                dataType: Param.S32
                addr: paramId.transmission_shift_4_5_prefill_pressure
                writable: true
                saveable: true
                slot: slots.pressure
                name: qsTr("Prefill Pressure 4-5")
            }
        }
        ScalarMetaParam {
            param: ScalarParam {
                registry: root
                dataType: Param.S32
                addr: paramId.transmission_shift_5_4_prefill_pressure
                writable: true
                saveable: true
                slot: slots.pressure
                name: qsTr("Prefill Pressure 5-4")
            }
        }
        ScalarMetaParam {
            param: ScalarParam {
                registry: root
                dataType: Param.S32
                addr: paramId.transmission_shift_5_6_prefill_pressure
                writable: true
                saveable: true
                slot: slots.pressure
                name: qsTr("Prefill Pressure 5-6")
            }
        }
        ScalarMetaParam {
            param: ScalarParam {
                registry: root
                dataType: Param.S32
                addr: paramId.transmission_shift_6_5_prefill_pressure
                writable: true
                saveable: true
                slot: slots.pressure
                name: qsTr("Prefill Pressure 6-5")
            }
        }
    }

    property ScalarMetaParam transmissionSTDownshiftTorqueThreshold: ScalarMetaParam {
        param: ScalarParam {
            registry: root
            dataType: Param.S32
            addr: paramId.transmission_st_downshift_torque_threshold
            writable: true
            saveable: true
            slot: slots.percentage1
            name: qsTr("ST Downshift Torque Threshold")
        }
    }

    property ScalarMetaParam transmissionSTUpshiftTorqueThreshold: ScalarMetaParam {
        param: ScalarParam {
            registry: root
            dataType: Param.S32
            addr: paramId.transmission_st_upshift_torque_threshold
            writable: true
            saveable: true
            slot: slots.percentage1
            name: qsTr("ST Upshift Torque Threshold")
        }
    }


    property ScalarMetaParamList transmissionTorqueSpeedTransferTime: ScalarMetaParamList {
        ScalarMetaParam {
            param: ScalarParam {
                registry: root
                dataType: Param.S32
                addr: paramId.transmission_shift_r_n_ts_transfer_time
                writable: true
                saveable: true
                slot: slots.timeMilliseconds1
                name: qsTr("TS Transfer Time R-N")
            }
        }
        ScalarMetaParam {
            param: ScalarParam {
                registry: root
                dataType: Param.S32
                addr: paramId.transmission_shift_n_r_ts_transfer_time
                writable: true
                saveable: true
                slot: slots.timeMilliseconds1
                name: qsTr("TS Transfer Time N-R")
            }
        }
        ScalarMetaParam {
            param: ScalarParam {
                registry: root
                dataType: Param.S32
                addr: paramId.transmission_shift_n_1_ts_transfer_time
                writable: true
                saveable: true
                slot: slots.timeMilliseconds1
                name: qsTr("TS Transfer Time N-1")
            }
        }
        ScalarMetaParam {
            param: ScalarParam {
                registry: root
                dataType: Param.S32
                addr: paramId.transmission_shift_1_n_ts_transfer_time
                writable: true
                saveable: true
                slot: slots.timeMilliseconds1
                name: qsTr("TS Transfer Time 1-N")
            }
        }
        ScalarMetaParam {
            param: ScalarParam {
                registry: root
                dataType: Param.S32
                addr: paramId.transmission_shift_1_2_ts_transfer_time
                writable: true
                saveable: true
                slot: slots.timeMilliseconds1
                name: qsTr("TS Transfer Time 1-2")
            }
        }
        ScalarMetaParam {
            param: ScalarParam {
                registry: root
                dataType: Param.S32
                addr: paramId.transmission_shift_2_1_ts_transfer_time
                writable: true
                saveable: true
                slot: slots.timeMilliseconds1
                name: qsTr("TS Transfer Time 2-1")
            }
        }
        ScalarMetaParam {
            param: ScalarParam {
                registry: root
                dataType: Param.S32
                addr: paramId.transmission_shift_2_3_ts_transfer_time
                writable: true
                saveable: true
                slot: slots.timeMilliseconds1
                name: qsTr("TS Transfer Time 2-3")
            }
        }
        ScalarMetaParam {
            param: ScalarParam {
                registry: root
                dataType: Param.S32
                addr: paramId.transmission_shift_3_2_ts_transfer_time
                writable: true
                saveable: true
                slot: slots.timeMilliseconds1
                name: qsTr("TS Transfer Time 3-2")
            }
        }
        ScalarMetaParam {
            param: ScalarParam {
                registry: root
                dataType: Param.S32
                addr: paramId.transmission_shift_3_4_ts_transfer_time
                writable: true
                saveable: true
                slot: slots.timeMilliseconds1
                name: qsTr("TS Transfer Time 3-4")
            }
        }
        ScalarMetaParam {
            param: ScalarParam {
                registry: root
                dataType: Param.S32
                addr: paramId.transmission_shift_4_3_ts_transfer_time
                writable: true
                saveable: true
                slot: slots.timeMilliseconds1
                name: qsTr("TS Transfer Time 4-3")
            }
        }
        ScalarMetaParam {
            param: ScalarParam {
                registry: root
                dataType: Param.S32
                addr: paramId.transmission_shift_4_5_ts_transfer_time
                writable: true
                saveable: true
                slot: slots.timeMilliseconds1
                name: qsTr("TS Transfer Time 4-5")
            }
        }
        ScalarMetaParam {
            param: ScalarParam {
                registry: root
                dataType: Param.S32
                addr: paramId.transmission_shift_5_4_ts_transfer_time
                writable: true
                saveable: true
                slot: slots.timeMilliseconds1
                name: qsTr("TS Transfer Time 5-4")
            }
        }
        ScalarMetaParam {
            param: ScalarParam {
                registry: root
                dataType: Param.S32
                addr: paramId.transmission_shift_5_6_ts_transfer_time
                writable: true
                saveable: true
                slot: slots.timeMilliseconds1
                name: qsTr("TS Transfer Time 5-6")
            }
        }
        ScalarMetaParam {
            param: ScalarParam {
                registry: root
                dataType: Param.S32
                addr: paramId.transmission_shift_6_5_ts_transfer_time
                writable: true
                saveable: true
                slot: slots.timeMilliseconds1
                name: qsTr("TS Transfer Time 6-5")
            }
        }
    }

    property ScalarMetaParamList transmissionSpeedTorqueTransferTime: ScalarMetaParamList {
        ScalarMetaParam {
            param: ScalarParam {
                registry: root
                dataType: Param.S32
                addr: paramId.transmission_shift_r_n_st_transfer_time
                writable: true
                saveable: true
                slot: slots.timeMilliseconds1
                name: qsTr("ST Transfer Time R-N")
            }
        }
        ScalarMetaParam {
            param: ScalarParam {
                registry: root
                dataType: Param.S32
                addr: paramId.transmission_shift_n_r_st_transfer_time
                writable: true
                saveable: true
                slot: slots.timeMilliseconds1
                name: qsTr("ST Transfer Time N-R")
            }
        }
        ScalarMetaParam {
            param: ScalarParam {
                registry: root
                dataType: Param.S32
                addr: paramId.transmission_shift_n_1_st_transfer_time
                writable: true
                saveable: true
                slot: slots.timeMilliseconds1
                name: qsTr("ST Transfer Time N-1")
            }
        }
        ScalarMetaParam {
            param: ScalarParam {
                registry: root
                dataType: Param.S32
                addr: paramId.transmission_shift_1_n_st_transfer_time
                writable: true
                saveable: true
                slot: slots.timeMilliseconds1
                name: qsTr("ST Transfer Time 1-N")
            }
        }
        ScalarMetaParam {
            param: ScalarParam {
                registry: root
                dataType: Param.S32
                addr: paramId.transmission_shift_1_2_st_transfer_time
                writable: true
                saveable: true
                slot: slots.timeMilliseconds1
                name: qsTr("ST Transfer Time 1-2")
            }
        }
        ScalarMetaParam {
            param: ScalarParam {
                registry: root
                dataType: Param.S32
                addr: paramId.transmission_shift_2_1_st_transfer_time
                writable: true
                saveable: true
                slot: slots.timeMilliseconds1
                name: qsTr("ST Transfer Time 2-1")
            }
        }
        ScalarMetaParam {
            param: ScalarParam {
                registry: root
                dataType: Param.S32
                addr: paramId.transmission_shift_2_3_st_transfer_time
                writable: true
                saveable: true
                slot: slots.timeMilliseconds1
                name: qsTr("ST Transfer Time 2-3")
            }
        }
        ScalarMetaParam {
            param: ScalarParam {
                registry: root
                dataType: Param.S32
                addr: paramId.transmission_shift_3_2_st_transfer_time
                writable: true
                saveable: true
                slot: slots.timeMilliseconds1
                name: qsTr("ST Transfer Time 3-2")
            }
        }
        ScalarMetaParam {
            param: ScalarParam {
                registry: root
                dataType: Param.S32
                addr: paramId.transmission_shift_3_4_st_transfer_time
                writable: true
                saveable: true
                slot: slots.timeMilliseconds1
                name: qsTr("ST Transfer Time 3-4")
            }
        }
        ScalarMetaParam {
            param: ScalarParam {
                registry: root
                dataType: Param.S32
                addr: paramId.transmission_shift_4_3_st_transfer_time
                writable: true
                saveable: true
                slot: slots.timeMilliseconds1
                name: qsTr("ST Transfer Time 4-3")
            }
        }
        ScalarMetaParam {
            param: ScalarParam {
                registry: root
                dataType: Param.S32
                addr: paramId.transmission_shift_4_5_st_transfer_time
                writable: true
                saveable: true
                slot: slots.timeMilliseconds1
                name: qsTr("ST Transfer Time 4-5")
            }
        }
        ScalarMetaParam {
            param: ScalarParam {
                registry: root
                dataType: Param.S32
                addr: paramId.transmission_shift_5_4_st_transfer_time
                writable: true
                saveable: true
                slot: slots.timeMilliseconds1
                name: qsTr("ST Transfer Time 5-4")
            }
        }
        ScalarMetaParam {
            param: ScalarParam {
                registry: root
                dataType: Param.S32
                addr: paramId.transmission_shift_5_6_st_transfer_time
                writable: true
                saveable: true
                slot: slots.timeMilliseconds1
                name: qsTr("ST Transfer Time 5-6")
            }
        }
        ScalarMetaParam {
            param: ScalarParam {
                registry: root
                dataType: Param.S32
                addr: paramId.transmission_shift_6_5_st_transfer_time
                writable: true
                saveable: true
                slot: slots.timeMilliseconds1
                name: qsTr("ST Transfer Time 6-5")
            }
        }
    }
    property TableMetaParam transmissionTemperaturePressureCompensation: TableMetaParam {
        param: TableParam {
            x: tempAxisModel
            value: ArrayParam {
                registry: root
                dataType: Param.S32
                addr: paramId.transmission_pressure_temperature_compensation
                minCount: tempAxisModel.count
                writable: true
                saveable: true
                slot: slots.percentage1
                name: qsTr("Trans Temp Pressure Compensation")
            }
        }
    }

    property ScalarMetaParam garageShiftTime: ScalarMetaParam {
        param: ScalarParam {
            registry: root
            dataType: Param.S32
            addr: paramId.garage_shift_time
            writable: true
            saveable: true
            slot: slots.timeMilliseconds1
            name: qsTr("Garage Shift Time")
        }
        immediateWrite: true
    }

    property ScalarMetaParam garageShiftMaxPressure: ScalarMetaParam {
        param: ScalarParam {
            registry: root
            dataType: Param.S32
            addr: paramId.garage_shift_max_pressure
            writable: true
            saveable: true
            slot: slots.pressure
            name: qsTr("Garage Shift Max Pressure")
        }
        immediateWrite: true
    }

    property ScalarMetaParam garageShiftMaxPercentage: ScalarMetaParam {
        param: ScalarParam {
            registry: root
            dataType: Param.S32
            addr: paramId.garage_shift_max_percentage
            writable: true
            saveable: true
            slot: slots.percentage2
            name: qsTr("Garage Shift Max Percentage")
        }
        immediateWrite: true
    }

    property ScalarMetaParam garageShiftProportionalConstant: ScalarMetaParam {
        param: ScalarParam {
            registry: root
            dataType: Param.S32
            addr: paramId.garage_shift_p_const
            writable: true
            saveable: true
            slot: slots.pressurePerRpm
            name: qsTr("Garage Shift P Coeff")
        }
        immediateWrite: true
    }

    property ScalarMetaParam garageShiftIntegralConstant: ScalarMetaParam {
        param: ScalarParam {
            registry: root
            dataType: Param.S32
            addr: paramId.garage_shift_i_const
            writable: true
            saveable: true
            slot: slots.pressurePerRpmSec
            name: qsTr("Garage Shift I Coeff")
        }
        immediateWrite: true
    }

    property ScalarMetaParam garageShiftDerivativeConstant: ScalarMetaParam {
        param: ScalarParam {
            registry: root
            dataType: Param.S32
            addr: paramId.garage_shift_d_const
            writable: true
            saveable: true
            slot: slots.pressurePerRpmPerSec
            name: qsTr("Garage Shift D Coeff")
        }
        immediateWrite: true
    }

    property
    list<TableMetaParam> transmissionUpshiftApplyPressure: [
        TableMetaParam {
            param: TableParam {
                x: pressureAxisModel
                value: ArrayParam {
                    registry: root
                    dataType: Param.S32
                    addr: paramId.transmission_shift_n_1_apply_pressure
                    minCount: pressureAxisModel.count
                    writable: true
                    saveable: true
                    slot: slots.pressure
                    name: qsTr("Shift N-1 Apply")
                }
            }
        },
        TableMetaParam {
            param: TableParam {
                x: pressureAxisModel
                value: ArrayParam {
                    registry: root
                    dataType: Param.S32
                    addr: paramId.transmission_shift_1_2_apply_pressure
                    minCount: pressureAxisModel.count
                    writable: true
                    saveable: true
                    slot: slots.pressure
                    name: qsTr("Shift 1-2 Apply")
                }
            }
        },
        TableMetaParam {
            param: TableParam {
                x: pressureAxisModel
                value: ArrayParam {
                    registry: root
                    dataType: Param.S32
                    addr: paramId.transmission_shift_2_3_apply_pressure
                    minCount: pressureAxisModel.count
                    writable: true
                    saveable: true
                    slot: slots.pressure
                    name: qsTr("Shift 2-3 Apply")
                }
            }
        },
        TableMetaParam {
            param: TableParam {
                x: pressureAxisModel
                value: ArrayParam {
                    registry: root
                    dataType: Param.S32
                    addr: paramId.transmission_shift_3_4_apply_pressure
                    minCount: pressureAxisModel.count
                    writable: true
                    saveable: true
                    slot: slots.pressure
                    name: qsTr("Shift 3-4 Apply")
                }
            }
        },
        TableMetaParam {
            param: TableParam {
                x: pressureAxisModel
                value: ArrayParam {
                    registry: root
                    dataType: Param.S32
                    addr: paramId.transmission_shift_4_5_apply_pressure
                    minCount: pressureAxisModel.count
                    writable: true
                    saveable: true
                    slot: slots.pressure
                    name: qsTr("Shift 4-5 Apply")
                }
            }
        },
        TableMetaParam {
            param: TableParam {
                x: pressureAxisModel
                value: ArrayParam {
                    registry: root
                    dataType: Param.S32
                    addr: paramId.transmission_shift_5_6_apply_pressure
                    minCount: pressureAxisModel.count
                    writable: true
                    saveable: true
                    slot: slots.pressure
                    name: qsTr("Shift 5-6 Apply")
                }
            }
        }
    ]

    property
    list<TableMetaParam> transmissionDownshiftApplyPressure: [
        TableMetaParam {
            param: TableParam {
                x: pressureAxisModel
                value: ArrayParam {
                    registry: root
                    dataType: Param.S32
                    addr: paramId.transmission_shift_2_1_apply_pressure
                    minCount: pressureAxisModel.count
                    writable: true
                    saveable: true
                    slot: slots.pressure
                    name: qsTr("Shift 2-1 Apply")
                }
            }
        },
        TableMetaParam {
            param: TableParam {
                x: pressureAxisModel
                value: ArrayParam {
                    registry: root
                    dataType: Param.S32
                    addr: paramId.transmission_shift_3_2_apply_pressure
                    minCount: pressureAxisModel.count
                    writable: true
                    saveable: true
                    slot: slots.pressure
                    name: qsTr("Shift 3-2 Apply")
                }
            }
        },
        TableMetaParam {
            param: TableParam {
                x: pressureAxisModel
                value: ArrayParam {
                    registry: root
                    dataType: Param.S32
                    addr: paramId.transmission_shift_4_3_apply_pressure
                    minCount: pressureAxisModel.count
                    writable: true
                    saveable: true
                    slot: slots.pressure
                    name: qsTr("Shift 4-3 Apply")
                }
            }
        },
        TableMetaParam {
            param: TableParam {
                x: pressureAxisModel
                value: ArrayParam {
                    registry: root
                    dataType: Param.S32
                    addr: paramId.transmission_shift_5_4_apply_pressure
                    minCount: pressureAxisModel.count
                    writable: true
                    saveable: true
                    slot: slots.pressure
                    name: qsTr("Shift 5-4 Apply")
                }
            }
        },
        TableMetaParam {
            param: TableParam {
                x: pressureAxisModel
                value: ArrayParam {
                    registry: root
                    dataType: Param.S32
                    addr: paramId.transmission_shift_6_5_apply_pressure
                    minCount: pressureAxisModel.count
                    writable: true
                    saveable: true
                    slot: slots.pressure
                    name: qsTr("Shift 6-5 Apply")
                }
            }
        }
    ]

    property
    list<TableMetaParam> transmissionUpshiftReleasePressure: [
        TableMetaParam {
            param: TableParam {
                x: pressureAxisModel
                value: ArrayParam {
                    registry: root
                    dataType: Param.S32
                    addr: paramId.transmission_shift_1_2_release_pressure
                    minCount: pressureAxisModel.count
                    writable: true
                    saveable: true
                    slot: slots.pressure
                    name: qsTr("Shift 1-2 Release")
                }
            }
        },
        TableMetaParam {
            param: TableParam {
                x: pressureAxisModel
                value: ArrayParam {
                    registry: root
                    dataType: Param.S32
                    addr: paramId.transmission_shift_2_3_release_pressure
                    minCount: pressureAxisModel.count
                    writable: true
                    saveable: true
                    slot: slots.pressure
                    name: qsTr("Shift 2-3 Release")
                }
            }
        },
        TableMetaParam {
            param: TableParam {
                x: pressureAxisModel
                value: ArrayParam {
                    registry: root
                    dataType: Param.S32
                    addr: paramId.transmission_shift_3_4_release_pressure
                    minCount: pressureAxisModel.count
                    writable: true
                    saveable: true
                    slot: slots.pressure
                    name: qsTr("Shift 3-4 Release")
                }
            }
        },
        TableMetaParam {
            param: TableParam {
                x: pressureAxisModel
                value: ArrayParam {
                    registry: root
                    dataType: Param.S32
                    addr: paramId.transmission_shift_4_5_release_pressure
                    minCount: pressureAxisModel.count
                    writable: true
                    saveable: true
                    slot: slots.pressure
                    name: qsTr("Shift 4-5 Release")
                }
            }
        },
        TableMetaParam {
            param: TableParam {
                x: pressureAxisModel
                value: ArrayParam {
                    registry: root
                    dataType: Param.S32
                    addr: paramId.transmission_shift_5_6_release_pressure
                    minCount: pressureAxisModel.count
                    writable: true
                    saveable: true
                    slot: slots.pressure
                    name: qsTr("Shift 5-6 Release")
                }
            }
        }
    ]

    property
    list<TableMetaParam> transmissionDownshiftReleasePressure: [
        TableMetaParam {
            param: TableParam {
                x: pressureAxisModel
                value: ArrayParam {
                    registry: root
                    dataType: Param.S32
                    addr: paramId.transmission_shift_2_1_release_pressure
                    minCount: pressureAxisModel.count
                    writable: true
                    saveable: true
                    slot: slots.pressure
                    name: qsTr("Shift 2-1 Release")
                }
            }
        },
        TableMetaParam {
            param: TableParam {
                x: pressureAxisModel
                value: ArrayParam {
                    registry: root
                    dataType: Param.S32
                    addr: paramId.transmission_shift_3_2_release_pressure
                    minCount: pressureAxisModel.count
                    writable: true
                    saveable: true
                    slot: slots.pressure
                    name: qsTr("Shift 3-2 Release")
                }
            }
        },
        TableMetaParam {
            param: TableParam {
                x: pressureAxisModel
                value: ArrayParam {
                    registry: root
                    dataType: Param.S32
                    addr: paramId.transmission_shift_4_3_release_pressure
                    minCount: pressureAxisModel.count
                    writable: true
                    saveable: true
                    slot: slots.pressure
                    name: qsTr("Shift 4-3 Release")
                }
            }
        },
        TableMetaParam {
            param: TableParam {
                x: pressureAxisModel
                value: ArrayParam {
                    registry: root
                    dataType: Param.S32
                    addr: paramId.transmission_shift_5_4_release_pressure
                    minCount: pressureAxisModel.count
                    writable: true
                    saveable: true
                    slot: slots.pressure
                    name: qsTr("Shift 5-4 Release")
                }
            }
        },
        TableMetaParam {
            param: TableParam {
                x: pressureAxisModel
                value: ArrayParam {
                    registry: root
                    dataType: Param.S32
                    addr: paramId.transmission_shift_6_5_release_pressure
                    minCount: pressureAxisModel.count
                    writable: true
                    saveable: true
                    slot: slots.pressure
                    name: qsTr("Shift 6-5 Release")
                }
            }
        }
    ]

    property
    list<TableMetaParam> transmissionMainPressure: [
        TableMetaParam {
            param: TableParam {
                x: pressureAxisModel
                value: ArrayParam {
                    registry: root
                    dataType: Param.S32
                    addr: paramId.transmission_gear_1_main_pressure
                    minCount: pressureAxisModel.count
                    writable: true
                    saveable: true
                    slot: slots.pressure
                    name: qsTr("Gear 1 Main Pressure")
                }
            }
        },
        TableMetaParam {
            param: TableParam {
                x: pressureAxisModel
                value: ArrayParam {
                    registry: root
                    dataType: Param.S32
                    addr: paramId.transmission_gear_2_main_pressure
                    minCount: pressureAxisModel.count
                    writable: true
                    saveable: true
                    slot: slots.pressure
                    name: qsTr("Gear 2 Main Pressure")
                }
            }
        },
        TableMetaParam {
            param: TableParam {
                x: pressureAxisModel
                value: ArrayParam {
                    registry: root
                    dataType: Param.S32
                    addr: paramId.transmission_gear_3_main_pressure
                    minCount: pressureAxisModel.count
                    writable: true
                    saveable: true
                    slot: slots.pressure
                    name: qsTr("Gear 3 Main Pressure")
                }
            }
        },
        TableMetaParam {
            param: TableParam {
                x: pressureAxisModel
                value: ArrayParam {
                    registry: root
                    dataType: Param.S32
                    addr: paramId.transmission_gear_4_main_pressure
                    minCount: pressureAxisModel.count
                    writable: true
                    saveable: true
                    slot: slots.pressure
                    name: qsTr("Gear 4 Main Pressure")
                }
            }
        },
        TableMetaParam {
            param: TableParam {
                x: pressureAxisModel
                value: ArrayParam {
                    registry: root
                    dataType: Param.S32
                    addr: paramId.transmission_gear_5_main_pressure
                    minCount: pressureAxisModel.count
                    writable: true
                    saveable: true
                    slot: slots.pressure
                    name: qsTr("Gear 5 Main Pressure")
                }
            }
        },
        TableMetaParam {
            param: TableParam {
                x: pressureAxisModel
                value: ArrayParam {
                    registry: root
                    dataType: Param.S32
                    addr: paramId.transmission_gear_6_main_pressure
                    minCount: pressureAxisModel.count
                    writable: true
                    saveable: true
                    slot: slots.pressure
                    name: qsTr("Gear 6 Main Pressure")
                }
            }
        }
    ]

    property
    list<TableMetaParam> transmissionUpshiftApplyPercentage: [
        TableMetaParam {
            param: TableParam {
                x: pressureAxisModel
                value: ArrayParam {
                    registry: root
                    dataType: Param.S32
                    addr: paramId.transmission_shift_n_1_apply_percentage
                    minCount: pressureAxisModel.count
                    writable: true
                    saveable: true
                    slot: slots.percentage1
                    name: qsTr("Shift N-1 Apply Pressure")
                }
            }
        },
        TableMetaParam {
            param: TableParam {
                x: pressureAxisModel
                value: ArrayParam {
                    registry: root
                    dataType: Param.S32
                    addr: paramId.transmission_shift_1_2_apply_percentage
                    minCount: pressureAxisModel.count
                    writable: true
                    saveable: true
                    slot: slots.percentage1
                    name: qsTr("Shift 1-2 Apply Pressure")
                }
            }
        },
        TableMetaParam {
            param: TableParam {
                x: pressureAxisModel
                value: ArrayParam {
                    registry: root
                    dataType: Param.S32
                    addr: paramId.transmission_shift_2_3_apply_percentage
                    minCount: pressureAxisModel.count
                    writable: true
                    saveable: true
                    slot: slots.percentage1
                    name: qsTr("Shift 2-3 Apply Pressure")
                }
            }
        },
        TableMetaParam {
            param: TableParam {
                x: pressureAxisModel
                value: ArrayParam {
                    registry: root
                    dataType: Param.S32
                    addr: paramId.transmission_shift_3_4_apply_percentage
                    minCount: pressureAxisModel.count
                    writable: true
                    saveable: true
                    slot: slots.percentage1
                    name: qsTr("Shift 3-4 Apply Pressure")
                }
            }
        },
        TableMetaParam {
            param: TableParam {
                x: pressureAxisModel
                value: ArrayParam {
                    registry: root
                    dataType: Param.S32
                    addr: paramId.transmission_shift_4_5_apply_percentage
                    minCount: pressureAxisModel.count
                    writable: true
                    saveable: true
                    slot: slots.percentage1
                    name: qsTr("Shift 4-5 Apply Pressure")
                }
            }
        },
        TableMetaParam {
            param: TableParam {
                x: pressureAxisModel
                value: ArrayParam {
                    registry: root
                    dataType: Param.S32
                    addr: paramId.transmission_shift_5_6_apply_percentage
                    minCount: pressureAxisModel.count
                    writable: true
                    saveable: true
                    slot: slots.percentage1
                    name: qsTr("Shift 5-6 Apply Pressure")
                }
            }
        }
    ]

    property
    list<TableMetaParam> transmissionDownshiftApplyPercentage: [
        TableMetaParam {
            param: TableParam {
                x: pressureAxisModel
                value: ArrayParam {
                    registry: root
                    dataType: Param.S32
                    addr: paramId.transmission_shift_2_1_apply_percentage
                    minCount: pressureAxisModel.count
                    writable: true
                    saveable: true
                    slot: slots.percentage1
                    name: qsTr("Shift 2-1 Apply Pressure")
                }
            }
        },
        TableMetaParam {
            param: TableParam {
                x: pressureAxisModel
                value: ArrayParam {
                    registry: root
                    dataType: Param.S32
                    addr: paramId.transmission_shift_3_2_apply_percentage
                    minCount: pressureAxisModel.count
                    writable: true
                    saveable: true
                    slot: slots.percentage1
                    name: qsTr("Shift 3-2 Apply Pressure")
                }
            }
        },
        TableMetaParam {
            param: TableParam {
                x: pressureAxisModel
                value: ArrayParam {
                    registry: root
                    dataType: Param.S32
                    addr: paramId.transmission_shift_4_3_apply_percentage
                    minCount: pressureAxisModel.count
                    writable: true
                    saveable: true
                    slot: slots.percentage1
                    name: qsTr("Shift 4-3 Apply Pressure")
                }
            }
        },
        TableMetaParam {
            param: TableParam {
                x: pressureAxisModel
                value: ArrayParam {
                    registry: root
                    dataType: Param.S32
                    addr: paramId.transmission_shift_5_4_apply_percentage
                    minCount: pressureAxisModel.count
                    writable: true
                    saveable: true
                    slot: slots.percentage1
                    name: qsTr("Shift 5-4 Apply Pressure")
                }
            }
        },
        TableMetaParam {
            param: TableParam {
                x: pressureAxisModel
                value: ArrayParam {
                    registry: root
                    dataType: Param.S32
                    addr: paramId.transmission_shift_6_5_apply_percentage
                    minCount: pressureAxisModel.count
                    writable: true
                    saveable: true
                    slot: slots.percentage1
                    name: qsTr("Shift 6-5 Apply Pressure")
                }
            }
        }
    ]


    property
    list<TableMetaParam> transmissionUpshiftReleasePercentage: [
        TableMetaParam {
            param: TableParam {
                x: pressureAxisModel
                value: ArrayParam {
                    registry: root
                    dataType: Param.S32
                    addr: paramId.transmission_shift_1_2_release_percentage
                    minCount: pressureAxisModel.count
                    writable: true
                    saveable: true
                    slot: slots.percentage1
                    name: qsTr("Shift 1-2 Release Pressure")
                }
            }
        },
        TableMetaParam {
            param: TableParam {
                x: pressureAxisModel
                value: ArrayParam {
                    registry: root
                    dataType: Param.S32
                    addr: paramId.transmission_shift_2_3_release_percentage
                    minCount: pressureAxisModel.count
                    writable: true
                    saveable: true
                    slot: slots.percentage1
                    name: qsTr("Shift 2-3 Release Pressure")
                }
            }
        },
        TableMetaParam {
            param: TableParam {
                x: pressureAxisModel
                value: ArrayParam {
                    registry: root
                    dataType: Param.S32
                    addr: paramId.transmission_shift_3_4_release_percentage
                    minCount: pressureAxisModel.count
                    writable: true
                    saveable: true
                    slot: slots.percentage1
                    name: qsTr("Shift 3-4 Release Pressure")
                }
            }
        },
        TableMetaParam {
            param: TableParam {
                x: pressureAxisModel
                value: ArrayParam {
                    registry: root
                    dataType: Param.S32
                    addr: paramId.transmission_shift_4_5_release_percentage
                    minCount: pressureAxisModel.count
                    writable: true
                    saveable: true
                    slot: slots.percentage1
                    name: qsTr("Shift 4-5 Release Pressure")
                }
            }
        },
        TableMetaParam {
            param: TableParam {
                x: pressureAxisModel
                value: ArrayParam {
                    registry: root
                    dataType: Param.S32
                    addr: paramId.transmission_shift_5_6_release_percentage
                    minCount: pressureAxisModel.count
                    writable: true
                    saveable: true
                    slot: slots.percentage1
                    name: qsTr("Shift 5-6 Release Pressure")
                }
            }
        }
    ]

    property
    list<TableMetaParam> transmissionDownshiftReleasePercentage: [
        TableMetaParam {
            param: TableParam {
                x: pressureAxisModel
                value: ArrayParam {
                    registry: root
                    dataType: Param.S32
                    addr: paramId.transmission_shift_2_1_release_percentage
                    minCount: pressureAxisModel.count
                    writable: true
                    saveable: true
                    slot: slots.percentage1
                    name: qsTr("Shift 2-1 Release Pressure")
                }
            }
        },
        TableMetaParam {
            param: TableParam {
                x: pressureAxisModel
                value: ArrayParam {
                    registry: root
                    dataType: Param.S32
                    addr: paramId.transmission_shift_3_2_release_percentage
                    minCount: pressureAxisModel.count
                    writable: true
                    saveable: true
                    slot: slots.percentage1
                    name: qsTr("Shift 3-2 Release Pressure")
                }
            }
        },
        TableMetaParam {
            param: TableParam {
                x: pressureAxisModel
                value: ArrayParam {
                    registry: root
                    dataType: Param.S32
                    addr: paramId.transmission_shift_4_3_release_percentage
                    minCount: pressureAxisModel.count
                    writable: true
                    saveable: true
                    slot: slots.percentage1
                    name: qsTr("Shift 4-3 Release Pressure")
                }
            }
        },
        TableMetaParam {
            param: TableParam {
                x: pressureAxisModel
                value: ArrayParam {
                    registry: root
                    dataType: Param.S32
                    addr: paramId.transmission_shift_5_4_release_percentage
                    minCount: pressureAxisModel.count
                    writable: true
                    saveable: true
                    slot: slots.percentage1
                    name: qsTr("Shift 5-4 Release Pressure")
                }
            }
        },
        TableMetaParam {
            param: TableParam {
                x: pressureAxisModel
                value: ArrayParam {
                    registry: root
                    dataType: Param.S32
                    addr: paramId.transmission_shift_6_5_release_percentage
                    minCount: pressureAxisModel.count
                    writable: true
                    saveable: true
                    slot: slots.percentage1
                    name: qsTr("Shift 6-5 Release Pressure")
                }
            }
        }
    ]

    property
    list<TableMetaParam> transmissionMainPercentage: [
        TableMetaParam {
            param: TableParam {
                x: pressureAxisModel
                value: ArrayParam {
                    registry: root
                    dataType: Param.S32
                    addr: paramId.transmission_gear_1_main_percentage
                    minCount: pressureAxisModel.count
                    writable: true
                    saveable: true
                    slot: slots.percentage1
                    name: qsTr("Gear 1 Main Pressure")
                }
            }
        },
        TableMetaParam {
            param: TableParam {
                x: pressureAxisModel
                value: ArrayParam {
                    registry: root
                    dataType: Param.S32
                    addr: paramId.transmission_gear_2_main_percentage
                    minCount: pressureAxisModel.count
                    writable: true
                    saveable: true
                    slot: slots.percentage1
                    name: qsTr("Gear 2 Main Pressure")
                }
            }
        },
        TableMetaParam {
            param: TableParam {
                x: pressureAxisModel
                value: ArrayParam {
                    registry: root
                    dataType: Param.S32
                    addr: paramId.transmission_gear_3_main_percentage
                    minCount: pressureAxisModel.count
                    writable: true
                    saveable: true
                    slot: slots.percentage1
                    name: qsTr("Gear 3 Main Pressure")
                }
            }
        },
        TableMetaParam {
            param: TableParam {
                x: pressureAxisModel
                value: ArrayParam {
                    registry: root
                    dataType: Param.S32
                    addr: paramId.transmission_gear_4_main_percentage
                    minCount: pressureAxisModel.count
                    writable: true
                    saveable: true
                    slot: slots.percentage1
                    name: qsTr("Gear 4 Main Pressure")
                }
            }
        },
        TableMetaParam {
            param: TableParam {
                x: pressureAxisModel
                value: ArrayParam {
                    registry: root
                    dataType: Param.S32
                    addr: paramId.transmission_gear_5_main_percentage
                    minCount: pressureAxisModel.count
                    writable: true
                    saveable: true
                    slot: slots.percentage1
                    name: qsTr("Gear 5 Main Pressure")
                }
            }
        },
        TableMetaParam {
            param: TableParam {
                x: pressureAxisModel
                value: ArrayParam {
                    registry: root
                    dataType: Param.S32
                    addr: paramId.transmission_gear_6_main_percentage
                    minCount: pressureAxisModel.count
                    writable: true
                    saveable: true
                    slot: slots.percentage1
                    name: qsTr("Gear 6 Main Pressure")
                }
            }
        }
    ]

    property ScalarMetaParam pressureR2LBoostA: ScalarMetaParam {
        param: ScalarParam {
            registry: root
            dataType: Param.S32
            addr: paramId.pressure_r2l_boost_a
            writable: true
            saveable: true
            slot: slots.percentage1
            name: qsTr("Pressure R2L Boost A")
        }
    }

    property ScalarMetaParam pressureR2LBoostB: ScalarMetaParam {
        param: ScalarParam {
            registry: root
            dataType: Param.S32
            addr: paramId.pressure_r2l_boost_b
            writable: true
            saveable: true
            slot: slots.percentage1
            name: qsTr("Pressure R2L Boost B")
        }
    }

    property ScalarMetaParam displayColorRed: ScalarMetaParam {
        param: ScalarParam {
            registry: root
            dataType: Param.S32
            addr: paramId.display_color_red
            writable: true
            saveable: true
            slot: slots.percentage1
            name: qsTr("Display Color Red")
        }
    }

    property ScalarMetaParam displayColorGreen: ScalarMetaParam {
        param: ScalarParam {
            registry: root
            dataType: Param.S32
            addr: paramId.display_color_green
            writable: true
            saveable: true
            slot: slots.percentage1
            name: qsTr("Display Color Green")
        }
    }

    property ScalarMetaParam displayColorBlue: ScalarMetaParam {
        param: ScalarParam {
            registry: root
            dataType: Param.S32
            addr: paramId.display_color_bluew
            writable: true
            saveable: true
            slot: slots.percentage1
            name: qsTr("Display Color Blue")
        }
    }

    property ScalarMetaParam displayBrightness: ScalarMetaParam {
        param: ScalarParam {
            registry: root
            dataType: Param.S32
            addr: paramId.display_brightness
            writable: true
            saveable: true
            slot: slots.percentage1
            name: qsTr("Display Brightness")
        }
    }

    property ScalarMetaParam displayContrast: ScalarMetaParam {
        param: ScalarParam {
            registry: root
            dataType: Param.S32
            addr: paramId.display_contrast
            writable: true
            saveable: true
            slot: slots.percentage1
            name: qsTr("Display Contrast")
        }
    }

    property SlotArrayModel displayMixedMeterModel: SlotArrayModel {
        slot: slots.count
        min: 1
        count: 8
    }

    property TableMetaParam displayMixedMeterConfig1: TableMetaParam {
        param: TableParam {
            x: displayMixedMeterModel
            value: ArrayParam {
                registry: root
                dataType: Param.S32
                addr: paramId.display_mixed_meter_1_config
                minCount: 8
                writable: true
                saveable: true
                slot: slots.count
                name: qsTr("Mixed Meter 1 Config")
            }
        }
    }

    property TableMetaParam displayMixedMeterConfig2: TableMetaParam {
        param: TableParam {
            x: displayMixedMeterModel
            value: ArrayParam {
                registry: root
                dataType: Param.S32
                addr: paramId.display_mixed_meter_2_config
                minCount: 8
                writable: true
                saveable: true
                slot: slots.count
                name: qsTr("Mixed Meter 2 Config")
            }
        }
    }

    property TableMetaParam displayMixedMeterConfig3: TableMetaParam {
        param: TableParam {
            x: displayMixedMeterModel
            value: ArrayParam {
                registry: root
                dataType: Param.S32
                addr: paramId.display_mixed_meter_3_config
                minCount: 8
                writable: true
                saveable: true
                slot: slots.count
                name: qsTr("Mixed Meter 3 Config")
            }
        }
    }

    property TableMetaParam displayMixedMeterConfig4: TableMetaParam {
        param: TableParam {
            x: displayMixedMeterModel
            value: ArrayParam {
                registry: root
                dataType: Param.S32
                addr: paramId.display_mixed_meter_4_config
                minCount: 8
                writable: true
                saveable: true
                slot: slots.count
                name: qsTr("Mixed Meter 4 Config")
            }
        }
    }

    property ScalarMetaParam shiftDownshiftOffsetA: ScalarMetaParam {
        param: ScalarParam {
            registry: root
            dataType: Param.S32
            addr: paramId.shift_downshift_offset_a
            writable: true
            saveable: true
            slot: slots.percentage1
            name: qsTr("Downshift Offset A")
        }
    }

    property ScalarMetaParam shiftDownshiftOffsetB: ScalarMetaParam {
        param: ScalarParam {
            registry: root
            dataType: Param.S32
            addr: paramId.shift_downshift_offset_b
            writable: true
            saveable: true
            slot: slots.percentage1
            name: qsTr("Downshift Offset B")
        }
    }

    property ScalarMetaParam shiftTablesDownLockedA: ScalarMetaParam {
        param: ScalarParam {
            registry: root
            dataType: Param.S32
            addr: paramId.shift_tables_a_down_locked
            writable: true
            saveable: true
            slot: slots.booleanYesNo1
            name: qsTr("Downshift Table Locked A")
        }
    }

    property ScalarMetaParam shiftTablesDownLockedB: ScalarMetaParam {
        param: ScalarParam {
            registry: root
            dataType: Param.S32
            addr: paramId.shift_tables_b_down_locked
            writable: true
            saveable: true
            slot: slots.booleanYesNo1
            name: qsTr("Downshift Table Locked B")
        }
    }

    property ScalarMetaParam engineCylinders: ScalarMetaParam {
        param: ScalarParam {
            registry: root
            dataType: Param.S32
            addr: paramId.engine_cylinders
            writable: true
            saveable: true
            slot: slots.count2
            name: qsTr("Engine Cylinders")
        }
    }

    property ScalarMetaParam engineRunningDetectionSpeed: ScalarMetaParam {
        param: ScalarParam {
            registry: root
            dataType: Param.S32
            addr: paramId.engine_running_detection_speed
            writable: true
            saveable: true
            slot: slots.rpm1
            name: qsTr("Engine Running Detect Speed")
        }
    }

    property ScalarMetaParam engineMapTorqueProportion: ScalarMetaParam {
        param: ScalarParam {
            registry: root
            dataType: Param.S32
            addr: paramId.engine_map_torque_proportion
            writable: true
            saveable: true
            slot: slots.percentage1
            name: qsTr("Engine MAP Torque Proportion")
        }
    }

    property ScalarMetaParam engineMaxTorque: ScalarMetaParam {
        param: ScalarParam {
            registry: root
            dataType: Param.S32
            addr: paramId.engine_max_torque
            writable: true
            saveable: true
            slot: slots.torque
            name: qsTr("Engine Max Torque")
        }
    }

    property ScalarMetaParam engineIdleShutdownTime: ScalarMetaParam {
        param: ScalarParam {
            registry: root
            dataType: Param.S32
            addr: paramId.engine_idle_shutdown_time
            writable: true
            saveable: true
            slot: slots.timeInSecondsZeroIsDisabled
            name: qsTr("Engine Idle Shutdown Time")
        }
    }

    property TableMetaParam engineMotoringMaxTorque: TableMetaParam {
        param: TableParam {
            x: ArrayParam {
                registry: root
                dataType: Param.S32
                addr: paramId.engine_motoring_speed
                minCount: 16
                writable: true
                saveable: true
                slot: slots.rpm1
                name: qsTr("Engine Motoring Torque Speed")
            }
            value: ArrayParam {
                registry: root
                dataType: Param.S32
                addr: paramId.engine_motoring_max_torque
                minCount: 16
                writable: true
                saveable: true
                slot: slots.torque
                name: qsTr("Engine Motoring Torque")
            }
        }
    }

    property TableMetaParam engineBrakingMaxTorque: TableMetaParam {
        param: TableParam {
            x: ArrayParam {
                registry: root
                dataType: Param.S32
                addr: paramId.engine_braking_speed
                minCount: 16
                writable: true
                saveable: true
                slot: slots.rpm1
                name: qsTr("Engine Braking Torque Speed")
            }
            value: ArrayParam {
                registry: root
                dataType: Param.S32
                addr: paramId.engine_braking_max_torque
                minCount: 16
                writable: true
                saveable: true
                slot: slots.torque
                name: qsTr("Engine Braking Torque")
            }
        }
    }

    property ScalarMetaParam finalDriveRatio: ScalarMetaParam {
        param: ScalarParam {
            registry: root
            dataType: Param.S32
            addr: paramId.final_drive_ratio
            writable: true
            saveable: true
            slot: slots.ratio1
            name: qsTr("Final Drive Ratio")
        }
    }

    property ScalarMetaParam can0BaudRate: ScalarMetaParam {
        param: ScalarParam {
            registry: root
            dataType: Param.S32
            addr: paramId.can0_baud_rate
            writable: true
            saveable: true
            slot: slots.canSpeed
            name: qsTr("CAN 0 Baud Rate")
        }
    }

    property ScalarMetaParam can1BaudRate: ScalarMetaParam {
        param: ScalarParam {
            registry: root
            dataType: Param.S32
            addr: paramId.can1_baud_rate
            writable: true
            saveable: true
            slot: slots.canSpeed
            name: qsTr("CAN 1 Baud Rate")
        }
    }

    property ScalarMetaParam j1939TransmissionAddress: ScalarMetaParam {
        param: ScalarParam {
            registry: root
            dataType: Param.S32
            addr: paramId.j1939_transmission_address
            writable: true
            saveable: true
            slot: slots.countByte
            name: qsTr("J1939 Trans Address")
        }
    }

    property ScalarMetaParam j1939EngineAddress: ScalarMetaParam {
        param: ScalarParam {
            registry: root
            dataType: Param.S32
            addr: paramId.j1939_engine_address
            writable: true
            saveable: true
            slot: slots.countByte
            name: qsTr("J1939 Engine Address")
        }
    }

    property ScalarMetaParam j1939ShiftSelectorAddress: ScalarMetaParam {
        param: ScalarParam {
            registry: root
            dataType: Param.S32
            addr: paramId.j1939_shift_selector_address
            writable: true
            saveable: true
            slot: slots.countByte
            name: qsTr("J1939 Shift Selector Address")
        }
    }

    property ScalarMetaParam xcpCTOId: ScalarMetaParam {
        param: ScalarParam {
            registry: root
            dataType: Param.S32
            addr: paramId.xcp_cto_id
            writable: true
            saveable: true
            slot: slots.hex32bit
            name: qsTr("XCP CTO ID")
        }
    }

    property ScalarMetaParam xcpDTOId: ScalarMetaParam {
        param: ScalarParam {
            registry: root
            dataType: Param.S32
            addr: paramId.xcp_dto_id
            writable: true
            saveable: true
            slot: slots.hex32bit
            name: qsTr("XCP DTO ID")
        }
    }

    property ScalarMetaParam shiftManualModeA: ScalarMetaParam {
        param: ScalarParam {
            registry: root
            dataType: Param.S32
            addr: paramId.shift_manual_mode_a
            writable: true
            saveable: true
            slot: slots.booleanYesNo1
            name: qsTr("Manual Shift A")
        }
    }

    property ScalarMetaParam shiftManualModeB: ScalarMetaParam {
        param: ScalarParam {
            registry: root
            dataType: Param.S32
            addr: paramId.shift_manual_mode_b
            writable: true
            saveable: true
            slot: slots.booleanYesNo1
            name: qsTr("Manual Shift B")
        }
    }

    property ScalarMetaParam tccManualModeA: ScalarMetaParam {
        param: ScalarParam {
            registry: root
            dataType: Param.S32
            addr: paramId.tcc_manual_mode_a
            writable: true
            saveable: true
            slot: slots.booleanYesNo1
            name: qsTr("Manual TCC A")
        }
    }

    property ScalarMetaParam tccManualModeB: ScalarMetaParam {
        param: ScalarParam {
            registry: root
            dataType: Param.S32
            addr: paramId.tcc_manual_mode_b
            writable: true
            saveable: true
            slot: slots.booleanYesNo1
            name: qsTr("Manual TCC B")
        }
    }


    property ScalarMetaParam tccDisableInSwitchShiftA: ScalarMetaParam {
        param: ScalarParam {
            registry: root
            dataType: Param.S32
            addr: paramId.tcc_disable_in_switch_shift_a
            writable: true
            saveable: true
            slot: slots.booleanYesNo1
            name: qsTr("TCC Disable In Switch Shift A")
        }
    }

    property ScalarMetaParam tccDisableInSwitchShiftB: ScalarMetaParam {
        param: ScalarParam {
            registry: root
            dataType: Param.S32
            addr: paramId.tcc_disable_in_switch_shift_b
            writable: true
            saveable: true
            slot: slots.booleanYesNo1
            name: qsTr("TCC Disable In Switch Shift B")
        }
    }

    property ScalarMetaParam shiftMaxEngineSpeedA: ScalarMetaParam {
        param: ScalarParam {
            registry: root
            dataType: Param.S32
            addr: paramId.shift_max_engine_speed_a
            writable: true
            saveable: true
            slot: slots.rpm1
            name: qsTr("Max Engine Speed A")
        }
    }

    property ScalarMetaParam shiftMaxEngineSpeedB: ScalarMetaParam {
        param: ScalarParam {
            registry: root
            dataType: Param.S32
            addr: paramId.shift_max_engine_speed_b
            writable: true
            saveable: true
            slot: slots.rpm1
            name: qsTr("Max Engine Speed B")
        }
    }

    property ScalarMetaParam pressureAdjustA: ScalarMetaParam {
        param: ScalarParam {
            registry: root
            dataType: Param.S32
            addr: paramId.pressure_adjust_a
            writable: true
            saveable: true
            slot: slots.percentage1
            name: qsTr("Pressure Adjust A")
        }
    }

    property ScalarMetaParam pressureAdjustB: ScalarMetaParam {
        param: ScalarParam {
            registry: root
            dataType: Param.S32
            addr: paramId.pressure_adjust_b
            writable: true
            saveable: true
            slot: slots.percentage1
            name: qsTr("Pressure Adjust B")
        }
    }

    property
    list<TableMetaParam> pressureTablesA: [
        TableMetaParam {
            param: TableParam {
                x: percentage1AxisModel
                value: ArrayParam {
                    registry: root
                    dataType: Param.S32
                    addr: paramId.pressure_tables_a_1
                    minCount: percentage1AxisModel.count
                    writable: true
                    saveable: true
                    slot: slots.percentage1
                    name: qsTr("Shift Pressure 1 A")
                }
            }
        },
        TableMetaParam {
            param: TableParam {
                x: percentage1AxisModel
                value: ArrayParam {
                    registry: root
                    dataType: Param.S32
                    addr: paramId.pressure_tables_a_2
                    minCount: percentage1AxisModel.count
                    writable: true
                    saveable: true
                    slot: slots.percentage1
                    name: qsTr("Shift Pressure 2 A")
                }
            }
        },
        TableMetaParam {
            param: TableParam {
                x: percentage1AxisModel
                value: ArrayParam {
                    registry: root
                    dataType: Param.S32
                    addr: paramId.pressure_tables_a_3
                    minCount: percentage1AxisModel.count
                    writable: true
                    saveable: true
                    slot: slots.percentage1
                    name: qsTr("Shift Pressure 3 A")
                }
            }
        },
        TableMetaParam {
            param: TableParam {
                x: percentage1AxisModel
                value: ArrayParam {
                    registry: root
                    dataType: Param.S32
                    addr: paramId.pressure_tables_a_4
                    minCount: percentage1AxisModel.count
                    writable: true
                    saveable: true
                    slot: slots.percentage1
                    name: qsTr("Shift Pressure 4 A")
                }
            }
        },
        TableMetaParam {
            param: TableParam {
                x: percentage1AxisModel
                value: ArrayParam {
                    registry: root
                    dataType: Param.S32
                    addr: paramId.pressure_tables_a_5
                    minCount: percentage1AxisModel.count
                    writable: true
                    saveable: true
                    slot: slots.percentage1
                    name: qsTr("Shift Pressure 5 A")
                }
            }
        },
        TableMetaParam {
            param: TableParam {
                x: percentage1AxisModel
                value: ArrayParam {
                    registry: root
                    dataType: Param.S32
                    addr: paramId.pressure_tables_a_6
                    minCount: percentage1AxisModel.count
                    writable: true
                    saveable: true
                    slot: slots.percentage1
                    name: qsTr("Shift Pressure 6 A")
                }
            }
        }
    ]

    property
    list<TableMetaParam> pressureTablesB: [
        TableMetaParam {
            param: TableParam {
                x: percentage1AxisModel
                value: ArrayParam {
                    registry: root
                    dataType: Param.S32
                    addr: paramId.pressure_tables_b_1
                    minCount: percentage1AxisModel.count
                    writable: true
                    saveable: true
                    slot: slots.percentage1
                    name: qsTr("Shift Pressure 1 B")
                }
            }
        },
        TableMetaParam {
            param: TableParam {
                x: percentage1AxisModel
                value: ArrayParam {
                    registry: root
                    dataType: Param.S32
                    addr: paramId.pressure_tables_b_2
                    minCount: percentage1AxisModel.count
                    writable: true
                    saveable: true
                    slot: slots.percentage1
                    name: qsTr("Shift Pressure 2 B")
                }
            }
        },
        TableMetaParam {
            param: TableParam {
                x: percentage1AxisModel
                value: ArrayParam {
                    registry: root
                    dataType: Param.S32
                    addr: paramId.pressure_tables_b_3
                    minCount: percentage1AxisModel.count
                    writable: true
                    saveable: true
                    slot: slots.percentage1
                    name: qsTr("Shift Pressure 3 B")
                }
            }
        },
        TableMetaParam {
            param: TableParam {
                x: percentage1AxisModel
                value: ArrayParam {
                    registry: root
                    dataType: Param.S32
                    addr: paramId.pressure_tables_b_4
                    minCount: percentage1AxisModel.count
                    writable: true
                    saveable: true
                    slot: slots.percentage1
                    name: qsTr("Shift Pressure 4 B")
                }
            }
        },
        TableMetaParam {
            param: TableParam {
                x: percentage1AxisModel
                value: ArrayParam {
                    registry: root
                    dataType: Param.S32
                    addr: paramId.pressure_tables_b_5
                    minCount: percentage1AxisModel.count
                    writable: true
                    saveable: true
                    slot: slots.percentage1
                    name: qsTr("Shift Pressure 5 B")
                }
            }
        },
        TableMetaParam {
            param: TableParam {
                x: percentage1AxisModel
                value: ArrayParam {
                    registry: root
                    dataType: Param.S32
                    addr: paramId.pressure_tables_b_6
                    minCount: percentage1AxisModel.count
                    writable: true
                    saveable: true
                    slot: slots.percentage1
                    name: qsTr("Shift Pressure 6 B")
                }
            }
        }
    ]

    property
    list<TableMetaParam> solenoidPIMap: [
        TableMetaParam {
            param: TableParam {
                x: ArrayParam {
                    registry: root
                    dataType: Param.S32
                    addr: paramId.clutch_1_solenoid_pressure
                    minCount: 16
                    writable: true
                    saveable: true
                    slot: slots.pressure
                    name: qsTr("Sol 1 Pressure")
                }
                value: ArrayParam {
                    registry: root
                    dataType: Param.S32
                    addr: paramId.clutch_1_solenoid_current
                    minCount: 16
                    writable: true
                    saveable: true
                    slot: slots.current
                    name: qsTr("Sol 1 Current")
                }
            }
        },
        TableMetaParam {
            param: TableParam {
                x: ArrayParam {
                    registry: root
                    dataType: Param.S32
                    addr: paramId.clutch_2_solenoid_pressure
                    minCount: 16
                    writable: true
                    saveable: true
                    slot: slots.pressure
                    name: qsTr("Sol 2 Pressure")
                }
                value: ArrayParam {
                    registry: root
                    dataType: Param.S32
                    addr: paramId.clutch_2_solenoid_current
                    minCount: 16
                    writable: true
                    saveable: true
                    slot: slots.current
                    name: qsTr("Sol 2 Current")
                }
            }
        },
        TableMetaParam {
            param: TableParam {
                x: ArrayParam {
                    registry: root
                    dataType: Param.S32
                    addr: paramId.clutch_3_solenoid_pressure
                    minCount: 16
                    writable: true
                    saveable: true
                    slot: slots.pressure
                    name: qsTr("Sol 3 Pressure")
                }
                value: ArrayParam {
                    registry: root
                    dataType: Param.S32
                    addr: paramId.clutch_3_solenoid_current
                    minCount: 16
                    writable: true
                    saveable: true
                    slot: slots.current
                    name: qsTr("Sol 3 Current")
                }
            }
        },
        TableMetaParam {
            param: TableParam {
                x: ArrayParam {
                    registry: root
                    dataType: Param.S32
                    addr: paramId.clutch_4_solenoid_pressure
                    minCount: 16
                    writable: true
                    saveable: true
                    slot: slots.pressure
                    name: qsTr("Sol 4 Pressure")
                }
                value: ArrayParam {
                    registry: root
                    dataType: Param.S32
                    addr: paramId.clutch_4_solenoid_current
                    minCount: 16
                    writable: true
                    saveable: true
                    slot: slots.current
                    name: qsTr("Sol 4 Current")
                }
            }
        },
        TableMetaParam {
            param: TableParam {
                x: ArrayParam {
                    registry: root
                    dataType: Param.S32
                    addr: paramId.clutch_5_solenoid_pressure
                    minCount: 16
                    writable: true
                    saveable: true
                    slot: slots.pressure
                    name: qsTr("Sol 5 Pressure")
                }
                value: ArrayParam {
                    registry: root
                    dataType: Param.S32
                    addr: paramId.clutch_5_solenoid_current
                    minCount: 16
                    writable: true
                    saveable: true
                    slot: slots.current
                    name: qsTr("Sol 5 Current")
                }
            }
        },
        TableMetaParam {
            param: TableParam {
                x: ArrayParam {
                    registry: root
                    dataType: Param.S32
                    addr: paramId.clutch_6_solenoid_pressure
                    minCount: 16
                    writable: true
                    saveable: true
                    slot: slots.pressure
                    name: qsTr("Sol 6 Pressure")
                }
                value: ArrayParam {
                    registry: root
                    dataType: Param.S32
                    addr: paramId.clutch_6_solenoid_current
                    minCount: 16
                    writable: true
                    saveable: true
                    slot: slots.current
                    name: qsTr("Sol 6 Current")
                }
            }
        },
        TableMetaParam {
            param: TableParam {
                x: ArrayParam {
                    registry: root
                    dataType: Param.S32
                    addr: paramId.clutch_7_solenoid_pressure
                    minCount: 16
                    writable: true
                    saveable: true
                    slot: slots.pressure
                    name: qsTr("Sol 7 Pressure")
                }
                value: ArrayParam {
                    registry: root
                    dataType: Param.S32
                    addr: paramId.clutch_7_solenoid_current
                    minCount: 16
                    writable: true
                    saveable: true
                    slot: slots.current
                    name: qsTr("Sol 7 Current")
                }
            }
        },
        TableMetaParam {
            param: TableParam {
                x: ArrayParam {
                    registry: root
                    dataType: Param.S32
                    addr: paramId.clutch_8_solenoid_pressure
                    minCount: 16
                    writable: true
                    saveable: true
                    slot: slots.pressure
                    name: qsTr("Sol 7 Pressure")
                }
                value: ArrayParam {
                    registry: root
                    dataType: Param.S32
                    addr: paramId.clutch_8_solenoid_current
                    minCount: 16
                    writable: true
                    saveable: true
                    slot: slots.current
                    name: qsTr("Sol 8 Current")
                }
            }
        }
    ]

    property ScalarMetaParam reverseLockoutSpeed: ScalarMetaParam {
        param: ScalarParam {
            registry: root
            dataType: Param.S32
            addr: paramId.reverse_lockout_speed
            writable: true
            saveable: true
            slot: slots.tossRPMAsSpeed
            name: qsTr("Reverse Lockout Speed")
        }
    }

    property ScalarMetaParam shiftSpeedAdjustA: ScalarMetaParam {
        param: ScalarParam {
            registry: root
            dataType: Param.S32
            addr: paramId.shift_speed_adjust_a
            writable: true
            saveable: true
            slot: slots.percentage1
            name: qsTr("Shift Speed Adjust A")
        }
    }

    property ScalarMetaParam shiftSpeedAdjustB: ScalarMetaParam {
        param: ScalarParam {
            registry: root
            dataType: Param.S32
            addr: paramId.shift_speed_adjust_b
            writable: true
            saveable: true
            slot: slots.percentage1
            name: qsTr("Shift Speed Adjust B")
        }
    }

    property
    list<TableMetaParam> upshiftTablesA: [
        TableMetaParam {
            param: TableParam {
                x: percentage1AxisModel
                value: ArrayParam {
                    registry: root
                    dataType: Param.S32
                    addr: paramId.shift_tables_a_up_1
                    minCount: percentage1AxisModel.count
                    writable: true
                    saveable: true
                    slot: slots.tossRPMAsSpeed
                    name: qsTr("Shift Speed 1-2 A")
                }
            }
        },
        TableMetaParam {
            param: TableParam {
                x: percentage1AxisModel
                value: ArrayParam {
                    registry: root
                    dataType: Param.S32
                    addr: paramId.shift_tables_a_up_2
                    minCount: percentage1AxisModel.count
                    writable: true
                    saveable: true
                    slot: slots.tossRPMAsSpeed
                    name: qsTr("Shift Speed 2-3 A")
                }
            }
        },
        TableMetaParam {
            param: TableParam {
                x: percentage1AxisModel
                value: ArrayParam {
                    registry: root
                    dataType: Param.S32
                    addr: paramId.shift_tables_a_up_3
                    minCount: percentage1AxisModel.count
                    writable: true
                    saveable: true
                    slot: slots.tossRPMAsSpeed
                    name: qsTr("Shift Speed 3-4 A")
                }
            }
        },
        TableMetaParam {
            param: TableParam {
                x: percentage1AxisModel
                value: ArrayParam {
                    registry: root
                    dataType: Param.S32
                    addr: paramId.shift_tables_a_up_4
                    minCount: percentage1AxisModel.count
                    writable: true
                    saveable: true
                    slot: slots.tossRPMAsSpeed
                    name: qsTr("Shift Speed 4-5 A")
                }
            }
        },
        TableMetaParam {
            param: TableParam {
                x: percentage1AxisModel
                value: ArrayParam {
                    registry: root
                    dataType: Param.S32
                    addr: paramId.shift_tables_a_up_5
                    minCount: percentage1AxisModel.count
                    writable: true
                    saveable: true
                    slot: slots.tossRPMAsSpeed
                    name: qsTr("Shift Speed 5-6 A")
                }
            }
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
                value: ArrayParam {
                    registry: root
                    dataType: Param.S32
                    addr: paramId.shift_tables_b_up_1
                    minCount: percentage1AxisModel.count
                    writable: true
                    saveable: true
                    slot: slots.tossRPMAsSpeed
                    name: qsTr("Shift Speed 1-2 B")
                }
            }
        },
        TableMetaParam {
            param: TableParam {
                x: percentage1AxisModel
                value: ArrayParam {
                    registry: root
                    dataType: Param.S32
                    addr: paramId.shift_tables_b_up_2
                    minCount: percentage1AxisModel.count
                    writable: true
                    saveable: true
                    slot: slots.tossRPMAsSpeed
                    name: qsTr("Shift Speed 2-3 B")
                }
            }
        },
        TableMetaParam {
            param: TableParam {
                x: percentage1AxisModel
                value: ArrayParam {
                    registry: root
                    dataType: Param.S32
                    addr: paramId.shift_tables_b_up_3
                    minCount: percentage1AxisModel.count
                    writable: true
                    saveable: true
                    slot: slots.tossRPMAsSpeed
                    name: qsTr("Shift Speed 3-4 B")
                }
            }
        },
        TableMetaParam {
            param: TableParam {
                x: percentage1AxisModel
                value: ArrayParam {
                    registry: root
                    dataType: Param.S32
                    addr: paramId.shift_tables_b_up_4
                    minCount: percentage1AxisModel.count
                    writable: true
                    saveable: true
                    slot: slots.tossRPMAsSpeed
                    name: qsTr("Shift Speed 4-5 B")
                }
            }
        },
        TableMetaParam {
            param: TableParam {
                x: percentage1AxisModel
                value: ArrayParam {
                    registry: root
                    dataType: Param.S32
                    addr: paramId.shift_tables_b_up_5
                    minCount: percentage1AxisModel.count
                    writable: true
                    saveable: true
                    slot: slots.tossRPMAsSpeed
                    name: qsTr("Shift Speed 5-6 B")
                }
            }
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
                value: ArrayParam {
                    registry: root
                    dataType: Param.S32
                    addr: paramId.shift_tables_a_down_1
                    minCount: percentage1AxisModel.count
                    writable: true
                    saveable: true
                    slot: slots.tossRPMAsSpeed
                    name: qsTr("Shift Speed 2-1 A")
                }
            }
        },
        TableMetaParam {
            param: TableParam {
                x: percentage1AxisModel
                value: ArrayParam {
                    registry: root
                    dataType: Param.S32
                    addr: paramId.shift_tables_a_down_2
                    minCount: percentage1AxisModel.count
                    writable: true
                    saveable: true
                    slot: slots.tossRPMAsSpeed
                    name: qsTr("Shift Speed 3-2 A")
                }
            }
        },
        TableMetaParam {
            param: TableParam {
                x: percentage1AxisModel
                value: ArrayParam {
                    registry: root
                    dataType: Param.S32
                    addr: paramId.shift_tables_a_down_3
                    minCount: percentage1AxisModel.count
                    writable: true
                    saveable: true
                    slot: slots.tossRPMAsSpeed
                    name: qsTr("Shift Speed 4-3 A")
                }
            }
        },
        TableMetaParam {
            param: TableParam {
                x: percentage1AxisModel
                value: ArrayParam {
                    registry: root
                    dataType: Param.S32
                    addr: paramId.shift_tables_a_down_4
                    minCount: percentage1AxisModel.count
                    writable: true
                    saveable: true
                    slot: slots.tossRPMAsSpeed
                    name: qsTr("Shift Speed 5-4 A")
                }
            }
        },
        TableMetaParam {
            param: TableParam {
                x: percentage1AxisModel
                value: ArrayParam {
                    registry: root
                    dataType: Param.S32
                    addr: paramId.shift_tables_a_down_5
                    minCount: percentage1AxisModel.count
                    writable: true
                    saveable: true
                    slot: slots.tossRPMAsSpeed
                    name: qsTr("Shift Speed 6-5 A")
                }
            }
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
                value: ArrayParam {
                    registry: root
                    dataType: Param.S32
                    addr: paramId.shift_tables_b_down_1
                    minCount: percentage1AxisModel.count
                    writable: true
                    saveable: true
                    slot: slots.tossRPMAsSpeed
                    name: qsTr("Shift Speed 2-1 B")
                }
            }
        },
        TableMetaParam {
            param: TableParam {
                x: percentage1AxisModel
                value: ArrayParam {
                    registry: root
                    dataType: Param.S32
                    addr: paramId.shift_tables_b_down_2
                    minCount: percentage1AxisModel.count
                    writable: true
                    saveable: true
                    slot: slots.tossRPMAsSpeed
                    name: qsTr("Shift Speed 3-2 B")
                }
            }
        },
        TableMetaParam {
            param: TableParam {
                x: percentage1AxisModel
                value: ArrayParam {
                    registry: root
                    dataType: Param.S32
                    addr: paramId.shift_tables_b_down_3
                    minCount: percentage1AxisModel.count
                    writable: true
                    saveable: true
                    slot: slots.tossRPMAsSpeed
                    name: qsTr("Shift Speed 4-3 B")
                }
            }
        },
        TableMetaParam {
            param: TableParam {
                x: percentage1AxisModel
                value: ArrayParam {
                    registry: root
                    dataType: Param.S32
                    addr: paramId.shift_tables_b_down_4
                    minCount: percentage1AxisModel.count
                    writable: true
                    saveable: true
                    slot: slots.tossRPMAsSpeed
                    name: qsTr("Shift Speed 5-4 B")
                }
            }
        },
        TableMetaParam {
            param: TableParam {
                x: percentage1AxisModel
                value: ArrayParam {
                    registry: root
                    dataType: Param.S32
                    addr: paramId.shift_tables_b_down_5
                    minCount: percentage1AxisModel.count
                    writable: true
                    saveable: true
                    slot: slots.tossRPMAsSpeed
                    name: qsTr("Shift Speed 6-5 B")
                }
            }
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
                value: ArrayParam {
                    registry: root
                    dataType: Param.S32
                    addr: paramId.shift_torque_limit_1_2
                    minCount: pressureAxisModel.count
                    writable: true
                    saveable: true
                    slot: slots.percentage1
                    name: qsTr("Shift 1-2 Torque Limit")
                }
            }
        },
        TableMetaParam {
            param: TableParam {
                x: pressureAxisModel
                value: ArrayParam {
                    registry: root
                    dataType: Param.S32
                    addr: paramId.shift_torque_limit_2_3
                    minCount: pressureAxisModel.count
                    writable: true
                    saveable: true
                    slot: slots.percentage1
                    name: qsTr("Shift 2-3 Torque Limit")
                }
            }
        },
        TableMetaParam {
            param: TableParam {
                x: pressureAxisModel
                value: ArrayParam {
                    registry: root
                    dataType: Param.S32
                    addr: paramId.shift_torque_limit_3_4
                    minCount: pressureAxisModel.count
                    writable: true
                    saveable: true
                    slot: slots.percentage1
                    name: qsTr("Shift 3-4 Torque Limit")
                }
            }
        },
        TableMetaParam {
            param: TableParam {
                x: pressureAxisModel
                value: ArrayParam {
                    registry: root
                    dataType: Param.S32
                    addr: paramId.shift_torque_limit_4_5
                    minCount: pressureAxisModel.count
                    writable: true
                    saveable: true
                    slot: slots.percentage1
                    name: qsTr("Shift 4-5 Torque Limit")
                }
            }
        },
        TableMetaParam {
            param: TableParam {
                x: pressureAxisModel
                value: ArrayParam {
                    registry: root
                    dataType: Param.S32
                    addr: paramId.shift_torque_limit_5_6
                    minCount: pressureAxisModel.count
                    writable: true
                    saveable: true
                    slot: slots.percentage1
                    name: qsTr("Shift 5-6 Torque Limit")
                }
            }
        },
        TableMetaParam {
            param: TableParam {
                x: pressureAxisModel
                value: ArrayParam {
                    registry: root
                    dataType: Param.S32
                    addr: paramId.shift_torque_limit_2_1
                    minCount: pressureAxisModel.count
                    writable: true
                    saveable: true
                    slot: slots.percentage1
                    name: qsTr("Shift 2-1 Torque Limit")
                }
            }
        },
        TableMetaParam {
            param: TableParam {
                x: pressureAxisModel
                value: ArrayParam {
                    registry: root
                    dataType: Param.S32
                    addr: paramId.shift_torque_limit_3_2
                    minCount: pressureAxisModel.count
                    writable: true
                    saveable: true
                    slot: slots.percentage1
                    name: qsTr("Shift 3-2 Torque Limit")
                }
            }
        },
        TableMetaParam {
            param: TableParam {
                x: pressureAxisModel
                value: ArrayParam {
                    registry: root
                    dataType: Param.S32
                    addr: paramId.shift_torque_limit_4_3
                    minCount: pressureAxisModel.count
                    writable: true
                    saveable: true
                    slot: slots.percentage1
                    name: qsTr("Shift 4-3 Torque Limit")
                }
            }
        },
        TableMetaParam {
            param: TableParam {
                x: pressureAxisModel
                value: ArrayParam {
                    registry: root
                    dataType: Param.S32
                    addr: paramId.shift_torque_limit_5_4
                    minCount: pressureAxisModel.count
                    writable: true
                    saveable: true
                    slot: slots.percentage1
                    name: qsTr("Shift 5-4 Torque Limit")
                }
            }
        },
        TableMetaParam {
            param: TableParam {
                x: pressureAxisModel
                value: ArrayParam {
                    registry: root
                    dataType: Param.S32
                    addr: paramId.shift_torque_limit_6_5
                    minCount: pressureAxisModel.count
                    writable: true
                    saveable: true
                    slot: slots.percentage1
                    name: qsTr("Shift 6-5 Torque Limit")
                }
            }
        }
    ]

    property ScalarMetaParam shiftTorqueLimitGarageShift: ScalarMetaParam {
        param: ScalarParam {
            registry: root
            dataType: Param.S32
            addr: paramId.shift_torque_limit_garage_shift
            writable: true
            saveable: true
            slot: slots.percentage1
            name: qsTr("Garage Shift Torque Limit")
        }
    }

    property ScalarMetaParam tccDisableTOSSPercentA: ScalarMetaParam {
        param: ScalarParam {
            registry: root
            dataType: Param.S32
            addr: paramId.tcc_disable_toss_percent_a
            writable: true
            saveable: true
            slot: slots.percentage1
            name: qsTr("TCC Disable TOSS Percent A")
        }
    }

    property ScalarMetaParam tccDisableTOSSPercentB: ScalarMetaParam {
        param: ScalarParam {
            registry: root
            dataType: Param.S32
            addr: paramId.tcc_disable_toss_percent_b
            writable: true
            saveable: true
            slot: slots.percentage1
            name: qsTr("TCC Disable TOSS Percent B")
        }
    }

    property ScalarMetaParam tccEnableGearA: ScalarMetaParam {
        param: ScalarParam {
            registry: root
            dataType: Param.S32
            addr: paramId.tcc_enable_gear_a
            writable: true
            saveable: true
            slot: slots.gear1
            name: qsTr("TCC Enable Gear A")
        }
    }

    property ScalarMetaParam tccEnableGearB: ScalarMetaParam {
        param: ScalarParam {
            registry: root
            dataType: Param.S32
            addr: paramId.tcc_enable_gear_b
            writable: true
            saveable: true
            slot: slots.gear1
            name: qsTr("TCC Enable Gear B")
        }
    }

    property ScalarMetaParam tccEnableTOSSA: ScalarMetaParam {
        param: ScalarParam {
            registry: root
            dataType: Param.S32
            addr: paramId.tcc_enable_toss_a
            writable: true
            saveable: true
            slot: slots.tossRPMAsSpeed
            name: qsTr("TCC Enable TOSS Speed A")
        }
    }

    property ScalarMetaParam tccEnableTOSSB: ScalarMetaParam {
        param: ScalarParam {
            registry: root
            dataType: Param.S32
            addr: paramId.tcc_enable_toss_b
            writable: true
            saveable: true
            slot: slots.tossRPMAsSpeed
            name: qsTr("TCC Enable TOSS Speed B")
        }
    }

    property ScalarMetaParam tccMaxThrottleA: ScalarMetaParam {
        param: ScalarParam {
            registry: root
            dataType: Param.S32
            addr: paramId.tcc_max_throttle_a
            writable: true
            saveable: true
            slot: slots.percentage1
            name: qsTr("TCC Max Throttle A")
        }
    }

    property ScalarMetaParam tccMaxThrottleB: ScalarMetaParam {
        param: ScalarParam {
            registry: root
            dataType: Param.S32
            addr: paramId.tcc_max_throttle_b
            writable: true
            saveable: true
            slot: slots.percentage1
            name: qsTr("TCC Max Throttle B")
        }
    }

    property ScalarMetaParam tccMinThrottleA: ScalarMetaParam {
        param: ScalarParam {
            registry: root
            dataType: Param.S32
            addr: paramId.tcc_min_throttle_a
            writable: true
            saveable: true
            slot: slots.percentage1
            name: qsTr("TCC Min Throttle A")
        }
    }

    property ScalarMetaParam tccMinThrottleB: ScalarMetaParam {
        param: ScalarParam {
            registry: root
            dataType: Param.S32
            addr: paramId.tcc_min_throttle_b
            writable: true
            saveable: true
            slot: slots.percentage1
            name: qsTr("TCC Min Throttle B")
        }
    }

    property ScalarMetaParam tccPrefillTime: ScalarMetaParam {
        param: ScalarParam {
            registry: root
            dataType: Param.S32
            addr: paramId.tcc_prefill_time
            writable: true
            saveable: true
            slot: slots.timeMilliseconds1
            name: qsTr("TCC Prefill Time")
        }
    }

    property ScalarMetaParam tccApplyTime: ScalarMetaParam {
        param: ScalarParam {
            registry: root
            dataType: Param.S32
            addr: paramId.tcc_apply_time
            writable: true
            saveable: true
            slot: slots.timeMilliseconds1
            name: qsTr("TCC Apply Time")
        }
    }

    property ScalarMetaParam tccPrefillPressure: ScalarMetaParam {
        param: ScalarParam {
            registry: root
            dataType: Param.S32
            addr: paramId.tcc_prefill_pressure
            writable: true
            saveable: true
            slot: slots.pressure
            name: qsTr("TCC Prefill Pressure")
        }
    }

    property ScalarMetaParam tccPrefillPercentage: ScalarMetaParam {
        param: ScalarParam {
            registry: root
            dataType: Param.S32
            addr: paramId.tcc_prefill_percentage
            writable: true
            saveable: true
            slot: slots.percentage2
            name: qsTr("TCC Prefill Percentage")
        }
    }

    property ScalarMetaParam tccMaxPressure: ScalarMetaParam {
        param: ScalarParam {
            registry: root
            dataType: Param.S32
            addr: paramId.tcc_max_pressure
            writable: true
            saveable: true
            slot: slots.pressure
            name: qsTr("TCC Apply Max Pressure")
        }
    }

    property ScalarMetaParam tccMaxPercentage: ScalarMetaParam {
        param: ScalarParam {
            registry: root
            dataType: Param.S32
            addr: paramId.tcc_max_percentage
            writable: true
            saveable: true
            slot: slots.percentage2
            name: qsTr("TCC Apply Max Percentage")
        }
    }

    property ScalarMetaParam tccPercentageProportionalConstant: ScalarMetaParam {
        param: ScalarParam {
            registry: root
            dataType: Param.S32
            addr: paramId.tcc_percentage_proportional_constant
            writable: true
            saveable: true
            slot: slots.percentagePerRpm
            name: qsTr("TCC P Coeff")
        }
    }

    property ScalarMetaParam tccPercentageIntegralConstant: ScalarMetaParam {
        param: ScalarParam {
            registry: root
            dataType: Param.S32
            addr: paramId.tcc_percentage_integral_constant
            writable: true
            saveable: true
            slot: slots.percentagePerRpmSec
            name: qsTr("TCC I Coeff")
        }
    }

    property ScalarMetaParam tccPercentageDerivativeConstant: ScalarMetaParam {
        param: ScalarParam {
            registry: root
            dataType: Param.S32
            addr: paramId.tcc_percentage_derivative_constant
            writable: true
            saveable: true
            slot: slots.percentagePerRpmPerSec
            name: qsTr("TCC D Coeff")
        }
    }

    property ScalarMetaParam tccPressureProportionalConstant: ScalarMetaParam {
        param: ScalarParam {
            registry: root
            dataType: Param.S32
            addr: paramId.tcc_pressure_proportional_constant
            writable: true
            saveable: true
            slot: slots.pressurePerRpm
            name: qsTr("TCC P Coeff")
        }
    }

    property ScalarMetaParam tccPressureIntegralConstant: ScalarMetaParam {
        param: ScalarParam {
            registry: root
            dataType: Param.S32
            addr: paramId.tcc_pressure_integral_constant
            writable: true
            saveable: true
            slot: slots.pressurePerRpmSec
            name: qsTr("TCC I Coeff")
        }
    }

    property ScalarMetaParam tccPressureDerivativeConstant: ScalarMetaParam {
        param: ScalarParam {
            registry: root
            dataType: Param.S32
            addr: paramId.tcc_pressure_derivative_constant
            writable: true
            saveable: true
            slot: slots.pressurePerRpmPerSec
            name: qsTr("TCC D Coeff")
        }
    }

    property ScalarMetaParam tccStrokeTime: ScalarMetaParam {
        param: ScalarParam {
            registry: root
            dataType: Param.S32
            addr: paramId.tcc_stroke_time
            writable: true
            saveable: true
            slot: slots.timeMilliseconds1
            name: qsTr("TCC Stroke Time")
        }
    }

    property ScalarMetaParam tccStrokePressure: ScalarMetaParam {
        param: ScalarParam {
            registry: root
            dataType: Param.S32
            addr: paramId.tcc_stroke_pressure
            writable: true
            saveable: true
            slot: slots.pressure
            name: qsTr("TCC Stroke Pressure")
        }
    }

    property ScalarMetaParam tccStrokePercentage: ScalarMetaParam {
        param: ScalarParam {
            registry: root
            dataType: Param.S32
            addr: paramId.tcc_stroke_percentage
            writable: true
            saveable: true
            slot: slots.percentage2
            name: qsTr("TCC Stroke Percentage")
        }
    }

    property TableMetaParam torqueConverterMult: TableMetaParam {
        param: TableParam {
            x: ArrayParam {
                registry: root
                dataType: Param.S32
                addr: paramId.tc_mult_speedratio
                minCount: 16
                writable: true
                saveable: true
                slot: slots.ratio1
                name: qsTr("Torque Converter Mult Speed Ratio")
            }
            value: ArrayParam {
                registry: root
                dataType: Param.S32
                addr: paramId.tc_mult_torqueratio
                minCount: 16
                writable: true
                saveable: true
                slot: slots.ratio1
                name: qsTr("Torque Converter Multiplication")
            }
        }
    }

    property ScalarMetaParam vehicleVariation: ScalarMetaParam {
        param: ScalarParam {
            registry: root
            dataType: Param.S32
            addr: paramId.variation
            writable: true
            saveable: true
            slot: slots.variationTypes
            name: qsTr("Engine Type")
        }
        resetNeeded: true
    }

    property ScalarMetaParam tireDiameter: ScalarMetaParam {
        param: ScalarParam {
            registry: root
            dataType: Param.S32
            addr: paramId.tire_diameter
            writable: true
            saveable: true
            slot: slots.length
            name: qsTr("Tire Diameter")
        }
    }

    property ScalarMetaParam transferCaseRatio: ScalarMetaParam {
        param: ScalarParam {
            registry: root
            dataType: Param.S32
            addr: paramId.transfer_case_ratio
            writable: true
            saveable: true
            slot: slots.ratio1
            name: qsTr("Transfer Case Ratio")
        }
    }

    property ScalarMetaParam vehicleMass: ScalarMetaParam {
        param: ScalarParam {
            registry: root
            dataType: Param.S32
            addr: paramId.vehicle_mass
            writable: true
            saveable: true
            slot: slots.mass
            name: qsTr("Vehicle Mass")
        }
    }

    property ScalarMetaParam voltageTPSIsReversed: ScalarMetaParam {
        param: ScalarParam {
            registry: root
            dataType: Param.S32
            addr: paramId.voltage_tps_is_reversed
            writable: true
            saveable: true
            slot: slots.booleanNormalReversed
            name: qsTr("TPS Voltage Reversed")
        }
    }

    property ScalarMetaParam voltageTPSCalibrationHigh: ScalarMetaParam {
        param: ScalarParam {
            registry: root
            dataType: Param.S32
            addr: paramId.voltage_tps_calibration_high
            writable: true
            saveable: true
            slot: slots.voltage1
            name: qsTr("TPS Calibration High")
        }
    }

    property ScalarMetaParam voltageTPSCalibrationLow: ScalarMetaParam {
        param: ScalarParam {
            registry: root
            dataType: Param.S32
            addr: paramId.voltage_tps_calibration_low
            writable: true
            saveable: true
            slot: slots.voltage1
            name: qsTr("TPS Calibration Low")
        }
    }

    property ScalarMetaParam voltageTPSGroundEnable: ScalarMetaParam {
        param: ScalarParam {
            registry: root
            dataType: Param.S32
            addr: paramId.voltage_tps_ground_enable
            writable: true
            saveable: true
            slot: slots.booleanOnOff1
            name: qsTr("TPS Ground Enable")
        }
    }

    property ScalarMetaParam voltageTPSFilterOrder: ScalarMetaParam {
        param: ScalarParam {
            registry: root
            dataType: Param.S32
            addr: paramId.voltage_tps_filter_order
            writable: true
            saveable: true
            slot: slots.timeMilliseconds1
            name: qsTr("TPS Filter Order")
        }
    }

    property ScalarMetaParam voltageMAPSensorHighCalibration: ScalarMetaParam {
        param: ScalarParam {
            registry: root
            dataType: Param.S32
            addr: paramId.voltage_map_sensor_high_calibration
            writable: true
            saveable: true
            slot: slots.voltage1
            name: qsTr("MAP Calibration High")
        }
    }

    property ScalarMetaParam voltageMAPSensorLowCalibration: ScalarMetaParam {
        param: ScalarParam {
            registry: root
            dataType: Param.S32
            addr: paramId.voltage_map_sensor_low_calibration
            writable: true
            saveable: true
            slot: slots.voltage1
            name: qsTr("MAP Calibration Low")
        }
    }

    property ScalarMetaParam voltageMAPSensorGroundEnable: ScalarMetaParam {
        param: ScalarParam {
            registry: root
            dataType: Param.S32
            addr: paramId.voltage_map_sensor_ground_enable
            writable: true
            saveable: true
            slot: slots.booleanOnOff1
            name: qsTr("MAP Ground Enable")
        }
    }

    property ScalarMetaParam transmissionType: ScalarMetaParam {
        param: ScalarParam {
            registry: root
            dataType: Param.S32
            addr: paramId.transmission_type
            writable: true
            saveable: true
            slot: slots.transmissionType1
            name: qsTr("Trans Type")
        }
        resetNeeded: true
    }

    property ScalarMetaParam transmissionTempBiasEnable: ScalarMetaParam {
        param: ScalarParam {
            registry: root
            dataType: Param.S32
            addr: paramId.transmission_temp_bias_enable
            writable: true
            saveable: true
            slot: slots.booleanOnOff1
            name: qsTr("Trans Temp Bias Enable")
        }
    }

    property ScalarMetaParam transmissionHasLinePressureSensor: ScalarMetaParam {
        param: ScalarParam {
            registry: root
            dataType: Param.S32
            addr: paramId.transmission_main_pressure_sensor_present
            writable: true
            saveable: true
            slot: slots.booleanYesNo1
            name: qsTr("Trans Has Line Press Sensor")
        }
    }

    property ScalarMetaParam transmissionHasLinePressureControl: ScalarMetaParam {
        param: ScalarParam {
            registry: root
            dataType: Param.S32
            addr: paramId.transmission_has_line_pressure_control
            writable: true
            saveable: true
            slot: slots.booleanYesNo1
            name: qsTr("Trans Has Line Press Control")
        }
    }

    property ScalarMetaParam transmissionHasAccumulatorControl: ScalarMetaParam {
        param: ScalarParam {
            registry: root
            dataType: Param.S32
            addr: paramId.transmission_has_accumulator_control
            writable: true
            saveable: true
            slot: slots.booleanYesNo1
            name: qsTr("Trans Has Accumulator Control")
        }
    }

    property ScalarMetaParam transmissionHasPWMTCC: ScalarMetaParam {
        param: ScalarParam {
            registry: root
            dataType: Param.S32
            addr: paramId.transmission_has_pwm_tcc
            writable: true
            saveable: true
            slot: slots.booleanYesNo1
            name: qsTr("Trans Has PWM TCC")
        }
    }

    property ScalarMetaParam cs2EngineTempBiasEnable: ScalarMetaParam {
        param: ScalarParam {
            registry: root
            dataType: Param.S32
            addr: paramId.cs2_engine_temp_bias_enable
            writable: true
            saveable: true
            slot: slots.booleanOnOff1
            name: qsTr("Engine Temp Bias Enable")
        }
    }

    property ScalarMetaParam pressureControlSource: ScalarMetaParam {
        param: ScalarParam {
            registry: root
            dataType: Param.S32
            addr: paramId.pressure_control_source
            writable: true
            saveable: true
            slot: slots.torqueSignalSource
            name: qsTr("Pressure Control Source")
        }
    }

    property TableMetaParam shiftSelectorGearVoltages: TableMetaParam {
        param: TableParam {
            x: hgmShiftSelectorCalibrationGearAxisModel
            value: ArrayParam {
                registry: root
                dataType: Param.S32
                addr: paramId.shift_selector_gear_voltages
                minCount: hgmShiftSelectorCalibrationGearAxisModel.count
                writable: true
                saveable: true
                slot: slots.hgmShiftSelectorCalibrationSensorVoltage
                name: qsTr("Shift Selector Gear Voltages")
            }
        }
    }

    property ScalarMetaParam shiftSelectorODCancelAtStartup: ScalarMetaParam {
        param: ScalarParam {
            registry: root
            dataType: Param.S32
            addr: paramId.shift_selector_overdrive_cancel_at_startup
            writable: true
            saveable: true
            slot: slots.booleanOnOff1
            name: qsTr("Shift Selector OD Cancel At Startup")
        }
    }

    property ScalarMetaParam displayUnits: ScalarMetaParam {
        param: ScalarParam {
            registry: root
            dataType: Param.S32
            addr: paramId.use_metric_units
            writable: true
            saveable: true
            slot: slots.measurementSystem
            name: qsTr("Display Units")
        }
    }

    property ScalarMetaParam speedometerCalibration: ScalarMetaParam {
        param: ScalarParam {
            registry: root
            dataType: Param.S32
            addr: paramId.speedometer_calibration
            writable: true
            saveable: true
            slot: slots.speedoCalibration
            name: qsTr("Speedometer Calibration")
        }
    }

    property ScalarMetaParam vehicleSpeedSensorPulseCount: ScalarMetaParam {
        param: ScalarParam {
            registry: root
            dataType: Param.S32
            addr: paramId.vehicle_speed_sensor_pulse_count
            writable: true
            saveable: true
            slot: slots.count3
            name: qsTr("Vehicle Speed Sensor Pulses")
        }
    }

    property TableMetaParam transmissionGearNumbersRatios: TableMetaParam {
        param: TableParam {
            x: ArrayParam {
                registry: root
                dataType: Param.S32
                addr: paramId.transmission_gears
                minCount: 3
                maxCount: 8
                writable: false
                saveable: false
                slot: slots.gear1
                name: qsTr("")
            }
            value: ArrayParam {
                registry: root
                dataType: Param.S32
                addr: paramId.transmission_ratios
                minCount: 3
                maxCount: 8
                writable: false
                saveable: false
                slot: slots.ratio1
                name: qsTr("Gear Ratios")
            }
        }
    }

    property ScalarMetaParam evTorqueFilterOrder: ScalarMetaParam {
        param: ScalarParam {
            registry: root
            dataType: Param.S32
            addr: paramId.ev_torque_filter_order
            writable: true
            saveable: true
            slot: slots.timeMilliseconds1
            name: qsTr("Torque Filter Length")
        }
    }
    property ScalarMetaParam evSpeedFilterOrder: ScalarMetaParam {
        param: ScalarParam {
            registry: root
            dataType: Param.S32
            addr: paramId.ev_speed_filter_order
            writable: true
            saveable: true
            slot: slots.timeMilliseconds1
            name: qsTr("Speed Filter Length")
        }
    }
    property ScalarMetaParam evMotorTorqueIdle: ScalarMetaParam {
        param: ScalarParam {
            registry: root
            dataType: Param.S32
            addr: paramId.ev_motor_torque_idle
            writable: true
            saveable: true
            slot: slots.percentage2
            name: qsTr("Motor Torque Idle")
        }
    }
    property ScalarMetaParam evMotorTorqueShift: ScalarMetaParam {
        param: ScalarParam {
            registry: root
            dataType: Param.S32
            addr: paramId.ev_motor_torque_shift
            writable: true
            saveable: true
            slot: slots.percentage2
            name: qsTr("Motor Torque Shift")
        }
    }
    property ScalarMetaParam evMotorSpeedMax: ScalarMetaParam {
        param: ScalarParam {
            registry: root
            dataType: Param.S32
            addr: paramId.ev_motor_speed_max
            writable: true
            saveable: true
            slot: slots.rpm1
            name: qsTr("Max Motor Speed")
        }
    }
    property TableMetaParam evTorqueRampDownTime: TableMetaParam {
        param: TableParam {
            x: SlotArrayModel {
                slot: slots.count
                min: 1
                count: evTorqueRampDownTime.param.value.count
            }
            value: ArrayParam {
                registry: root
                dataType: Param.S32
                addr: paramId.ev_torque_ramp_down_time
                minCount: 1
                maxCount: 8
                writable: true
                saveable: true
                slot: slots.timeMilliseconds1
                name: qsTr("Torque Ramp Down Time")
            }
        }
    }
    property TableMetaParam evTorqueRampUpTime: TableMetaParam {
        param: TableParam {
            x: SlotArrayModel {
                slot: slots.count
                min: 1
                count: evTorqueRampUpTime.param.value.count
            }
            value: ArrayParam {
                registry: root
                dataType: Param.S32
                addr: paramId.ev_torque_ramp_up_time
                minCount: 1
                maxCount: 8
                writable: true
                saveable: true
                slot: slots.timeMilliseconds1
                name: qsTr("Torque Ramp Up Time")
            }
        }
    }
    property TableMetaParam evMotorTorqueMaxA: TableMetaParam {
        param: TableParam {
            x: SlotArrayModel {
                slot: slots.count
                min: 1
                count: evMotorTorqueMaxA.param.value.count
            }
            value: ArrayParam {
                registry: root
                dataType: Param.S32
                addr: paramId.ev_motor_torque_max_a
                minCount: 1
                maxCount: 8
                writable: true
                saveable: true
                slot: slots.percentage1
                name: qsTr("Max Motoring Torque A")
            }
        }
    }
    property TableMetaParam evRegenTorqueMaxA: TableMetaParam {
        param: TableParam {
            x: SlotArrayModel {
                slot: slots.count
                min: 1
                count: evRegenTorqueMaxA.param.value.count
            }
            value: ArrayParam {
                registry: root
                dataType: Param.S32
                addr: paramId.ev_regen_torque_max_a
                minCount: 1
                maxCount: 8
                writable: true
                saveable: true
                slot: slots.percentage1
                name: qsTr("Max Regen Torque A")
            }
        }
    }
    property ScalarMetaParam evMaxRegenSpeedA: ScalarMetaParam {
        param: ScalarParam {
            registry: root
            dataType: Param.S32
            addr: paramId.ev_max_regen_speed_a
            writable: true
            saveable: true
            slot: slots.tossRPMAsSpeed
            name: qsTr("Full Regen Speed A")
        }
    }
    property TableMetaParam evMotorTorqueMaxB: TableMetaParam {
        param: TableParam {
            x: SlotArrayModel {
                slot: slots.count
                min: 1
                count: evMotorTorqueMaxB.param.value.count
            }
            value: ArrayParam {
                registry: root
                dataType: Param.S32
                addr: paramId.ev_motor_torque_max_b
                minCount: 1
                maxCount: 8
                writable: true
                saveable: true
                slot: slots.percentage1
                name: qsTr("Max Motoring Torque B")
            }
        }
    }
    property TableMetaParam evRegenTorqueMaxB: TableMetaParam {
        param: TableParam {
            x: SlotArrayModel {
                slot: slots.count
                min: 1
                count: evRegenTorqueMaxB.param.value.count
            }
            value: ArrayParam {
                registry: root
                dataType: Param.S32
                addr: paramId.ev_regen_torque_max_b
                minCount: 1
                maxCount: 8
                writable: true
                saveable: true
                slot: slots.percentage1
                name: qsTr("Max Regen Torque B")
            }
        }
    }
    property ScalarMetaParam evMaxRegenSpeedB: ScalarMetaParam {
        param: ScalarParam {
            registry: root
            dataType: Param.S32
            addr: paramId.ev_max_regen_speed_b
            writable: true
            saveable: true
            slot: slots.tossRPMAsSpeed
            name: qsTr("Full Regen Speed B")
        }
    }
    property ScalarMetaParam ebusShiftSyncTolerance: ScalarMetaParam {
        param: ScalarParam {
            registry: root
            dataType: Param.S32
            addr: paramId.ebus_shift_synchronization_tolerance
            writable: true
            saveable: true
            slot: slots.rpm1
            name: qsTr("Shift Sync Tolerance")
        }
    }
    property ScalarMetaParam ebusShiftSyncDuration: ScalarMetaParam {
        param: ScalarParam {
            registry: root
            dataType: Param.S32
            addr: paramId.ebus_shift_synchronization_duration
            writable: true
            saveable: true
            slot: slots.timeMilliseconds1
            name: qsTr("Shift Sync Duration")
        }
    }
    property TableMetaParam clutchReleaseTime: TableMetaParam {
        param: TableParam {
            x: SlotArrayModel {
                slot: slots.count
                min: 1
                count: clutchReleaseTime.param.value.count
            }
            value: ArrayParam {
                registry: root
                dataType: Param.S32
                addr: paramId.clutch_release_time
                minCount: 1
                maxCount: 8
                writable: true
                saveable: true
                slot: slots.timeMilliseconds1
                name: qsTr("Clutch Release Time")
            }
        }
    }
    property TableMetaParam clutchPrefillTime: TableMetaParam {
        param: TableParam {
            x: SlotArrayModel {
                slot: slots.count
                min: 1
                count: clutchPrefillTime.param.value.count
            }
            value: ArrayParam {
                registry: root
                dataType: Param.S32
                addr: paramId.clutch_prefill_time
                minCount: 1
                maxCount: 8
                writable: true
                saveable: true
                slot: slots.timeMilliseconds1
                name: qsTr("Clutch Prefill Time")
            }
        }
    }
    property TableMetaParam clutchPrefillPressure: TableMetaParam {
        param: TableParam {
            x: SlotArrayModel {
                slot: slots.count
                min: 1
                count: clutchPrefillPressure.param.value.count
            }
            value: ArrayParam {
                registry: root
                dataType: Param.S32
                addr: paramId.clutch_prefill_pressure
                minCount: 1
                maxCount: 8
                writable: true
                saveable: true
                slot: slots.pressure
                name: qsTr("Clutch Prefill Pressure")
            }
        }
    }
    property TableMetaParam clutchPrefillPercentage: TableMetaParam {
        param: TableParam {
            x: SlotArrayModel {
                slot: slots.count
                min: 1
                count: clutchPrefillPercentage.param.value.count
            }
            value: ArrayParam {
                registry: root
                dataType: Param.S32
                addr: paramId.clutch_prefill_percentage
                minCount: 1
                maxCount: 8
                writable: true
                saveable: true
                slot: slots.percentage2
                name: qsTr("Clutch Prefill Pressure %")
            }
        }
    }
    property TableMetaParam clutchStrokeTime: TableMetaParam {
        param: TableParam {
            x: SlotArrayModel {
                slot: slots.count
                min: 1
                count: clutchStrokeTime.param.value.count
            }
            value: ArrayParam {
                registry: root
                dataType: Param.S32
                addr: paramId.clutch_stroke_time
                minCount: 1
                maxCount: 8
                writable: true
                saveable: true
                slot: slots.timeMilliseconds1
                name: qsTr("Clutch Stroke Time")
            }
        }
    }
    property TableMetaParam clutchStrokePressure: TableMetaParam {
        param: TableParam {
            x: SlotArrayModel {
                slot: slots.count
                min: 1
                count: clutchStrokeTime.param.value.count
            }
            value: ArrayParam {
                registry: root
                dataType: Param.S32
                addr: paramId.clutch_stroke_pressure
                minCount: 1
                maxCount: 8
                writable: true
                saveable: true
                slot: slots.pressure
                name: qsTr("Clutch Stroke Pressure")
            }
        }
    }
    property ScalarMetaParam evJ1939CtlSourceAddress: ScalarMetaParam {
        param: ScalarParam {
            registry: root
            dataType: Param.S32
            addr: paramId.ev_j1939_ctl_source_address
            writable: true
            saveable: true
            slot: slots.hex32bit
            name: qsTr("J1939 CTL Source Address")
        }
    }
    property ScalarMetaParam evDriveFaultCount: ScalarMetaParam {
        param: ScalarParam {
            registry: root
            dataType: Param.S32
            addr: paramId.ev_drive_fault_count
            writable: false
            saveable: false
            slot: slots.count
            name: qsTr("EV Drive Fault Count")
        }
    }
    property ScalarMetaParam evDriveLastFaultType: ScalarMetaParam {
        param: ScalarParam {
            registry: root
            dataType: Param.S32
            addr: paramId.ev_drive_last_fault_type
            writable: false
            saveable: false
            slot: slots.evDriveFault
            name: qsTr("EV Drive Last Fault")
        }
    }

    property ArrayParam dtcSPN: ArrayParam {
        registry: root
        dataType: Param.S32
        addr: paramId.dtc_spn
        minCount: 1
        maxCount: 128
        writable: false
        saveable: false
        slot: slots.hex32bit
        name: qsTr("SPN")
    }

    property ArrayParam dtcFMI: ArrayParam {
        registry: root
        dataType: Param.S32
        addr: paramId.dtc_fmi
        minCount: 1
        maxCount: 128
        writable: false
        saveable: false
        slot: slots.failureModeIndicator
        name: qsTr("FMI")
    }

    property ArrayParam dtcOC: ArrayParam {
        registry: root
        dataType: Param.S32
        addr: paramId.dtc_oc
        minCount: 1
        maxCount: 128
        writable: false
        saveable: false
        slot: slots.count
        name: qsTr("Count")
    }

    property ArrayParam dtcActive: ArrayParam {
        registry: root
        dataType: Param.S32
        addr: paramId.dtc_active
        minCount: 1
        maxCount: 128
        writable: false
        saveable: false
        slot: slots.booleanYesNo1
        name: qsTr("Active")
    }


    property SlotArrayModel dtcIndexModel: SlotArrayModel {
        slot: slots.count
        count: dtcSPN.count
    }

    property MultiroleTableMetaParam dtcList: MultiroleTableMetaParam {
        param: MultiroleTableParam {
            roleMapping: {
                "x": dtcIndexModel,
                        "spn": dtcSPN,
                        "fmi": dtcFMI,
                        "oc": dtcOC,
                        "active": dtcActive
            }
        }
        isLiveData: true
    }
}
