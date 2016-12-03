import QtQuick 2.5

QtObject {
    readonly property string controller_software_version: "80010000"
    readonly property string controller_heap_used: "80080000"
    readonly property string controller_heap_size: "80090000"
    readonly property string controller_heap_allocation_count: "800a0000"
    readonly property string controller_heap_release_count: "800b0000"

    readonly property string controller_tach_input_frequency: "80100000"
    readonly property string controller_tiss_input_frequency: "80110000"
    readonly property string controller_toss_input_frequency: "80120000"
    readonly property string controller_spare_input_frequency: "80130000"

    readonly property string controller_throttle_position_sensor_voltage: "80200000"
    readonly property string controller_map_sensor_voltage: "80210000"
    readonly property string controller_internal_temperature_sensor_voltage: "80220000"
    readonly property string controller_internal_temperature: "80230000"
    readonly property string controller_engine_temperature_sensor_voltage: "80240000"
    readonly property string controller_transmission_temperature_sensor_voltage: "80250000"
    readonly property string controller_multiplexed_sensor_voltage: "80260000"

    readonly property string controller_5_volt_bus_voltage: "80270000"
    readonly property string controller_3_3_volt_bus_voltage: "80280000"
    readonly property string controller_1_8_volt_bus_voltage: "80290000"
    readonly property string controller_12_volt_bus_voltage: "802a0000"
    readonly property string controller_voltage: "802c0000"

    readonly property string controller_acclerometer: "80300000"

    readonly property string controller_speed_timer_1_frequency: "80400000"
    readonly property string controller_speed_timer_2_frequency: "80410000"

    readonly property string controller_switch_state: "80500000"
    readonly property string controller_switch_current: "80510000"

    readonly property string controller_sd_card_write_protect: "80600000"
    readonly property string controller_sd_card_present: "80610000"
    readonly property string controller_master_driver_fault: "80620000"

    readonly property string controller_usb_power: "80700000"
    readonly property string controller_green_led: "80710000"
    readonly property string controller_red_led: "80720000"
    readonly property string controller_transmission_temperature_sensor_bias: "80730000"
    readonly property string controller_engine_temperature_sensor_bias: "80740000"
    readonly property string controller_throttle_position_sensor_ground: "80750000"
    readonly property string controller_map_ground: "80760000"
    readonly property string controller_usb_connect: "80770000"

    readonly property string controller_pwmdriver_frequency: "80800000"

    readonly property string controller_pwmdriver_duty_cycle: "80900000"

    readonly property string controller_pwmdriver_mode: "80a00000"

    readonly property string controller_pwmdriver_spn_1: "80b00000"
    readonly property string controller_pwmdriver_spn_2: "80b10000"
    readonly property string controller_pwmdriver_spn_3: "80b20000"
    readonly property string controller_pwmdriver_spn_4: "80b30000"
    readonly property string controller_pwmdriver_spn_5: "80b40000"
    readonly property string controller_pwmdriver_spn_6: "80b50000"
    readonly property string controller_pwmdriver_spn_7: "80b60000"
    readonly property string controller_pwmdriver_spn_8: "80b70000"
    readonly property string controller_pwmdriver_spn_9: "80b80000"
    readonly property string controller_pwmdriver_spn_10: "80b90000"
    readonly property string controller_pwmdriver_spn_11: "80ba0000"
    readonly property string controller_pwmdriver_spn_12: "80bb0000"

    // display settings
    readonly property string display_type: "01000000"
    readonly property string use_metric_units: "01010000"
    readonly property string display_brightness: "01020000"
    readonly property string display_contrast: "01030000"
    readonly property string display_color: "01040000"
    readonly property string display_color_red: "01040000"
    readonly property string display_color_green: "01040001"
    readonly property string display_color_blue: "01040002"

    readonly property string display_mixed_meter_1_config: "01100000"
    readonly property string display_mixed_meter_2_config: "01110000"
    readonly property string display_mixed_meter_3_config: "01120000"
    readonly property string display_mixed_meter_4_config: "01130000"

    // 0200 vehicle settings
    readonly property string variation: "02000000"
    readonly property string vehicle_mass: "02010000"
    readonly property string tire_diameter: "02020000"
    readonly property string speedometer_calibration: "02030000"
    readonly property string vehicle_speed_sensor_pulse_count: "02050000"

    // 8200 vehicle data
    readonly property string vehicle_speed: "82000000"
    readonly property string vehicle_acceleration: "82010000"
    readonly property string vehicle_speed_sensor_speed: "82020000"
    readonly property string brake_switch: "82030000"
    readonly property string left_front_wheel_speed: "82040000"
    readonly property string right_front_wheel_speed: "82050000"
    readonly property string left_rear_wheel_speed: "82060000"
    readonly property string right_rear_wheel_speed: "82070000"

    // 0300 transmission settings
    readonly property string transmission_type: "03000000"
    readonly property string transmission_temp_bias_enable: "03010000"
    readonly property string transmission_main_pressure_sensor_present: "03020000"
    readonly property string transmission_has_line_pressure_control: "03030000"
    readonly property string transmission_has_accumulator_control: "03040000"
    readonly property string transmission_has_pwm_tcc: "03050000"

    readonly property string transmission_turbine_shaft_speed_sensor_pulse_count: "03080000"
    readonly property string transmission_input_shaft_speed_sensor_pulse_count: "03090000"

    readonly property string transmission_shaft_1_speed_sensor_pulse_count: "030a0000"
    readonly property string transmission_shaft_2_speed_sensor_pulse_count: "030b0000"
    readonly property string transmission_shaft_3_speed_sensor_pulse_count: "030c0000"
    readonly property string transmission_shaft_4_speed_sensor_pulse_count: "030d0000"
    readonly property string transmission_shaft_5_speed_sensor_pulse_count: "030e0000"
    readonly property string transmission_shaft_6_speed_sensor_pulse_count: "030f0000"

    readonly property string transmission_gear_1_main_pressure: "03310000"
    readonly property string transmission_gear_2_main_pressure: "03320000"
    readonly property string transmission_gear_3_main_pressure: "03330000"
    readonly property string transmission_gear_4_main_pressure: "03340000"
    readonly property string transmission_gear_5_main_pressure: "03350000"
    readonly property string transmission_gear_6_main_pressure: "03360000"
    readonly property string transmission_gear_7_main_pressure: "03370000"
    readonly property string transmission_gear_8_main_pressure: "03380000"

    readonly property string transmission_shift_n_1_apply_pressure: "03400000"
    readonly property string transmission_shift_1_2_apply_pressure: "03410000"
    readonly property string transmission_shift_2_3_apply_pressure: "03420000"
    readonly property string transmission_shift_3_4_apply_pressure: "03430000"
    readonly property string transmission_shift_4_5_apply_pressure: "03440000"
    readonly property string transmission_shift_5_6_apply_pressure: "03450000"
    readonly property string transmission_shift_6_7_apply_pressure: "03460000"
    readonly property string transmission_shift_7_8_apply_pressure: "03470000"

    readonly property string transmission_shift_2_1_apply_pressure: "03480000"
    readonly property string transmission_shift_3_2_apply_pressure: "03490000"
    readonly property string transmission_shift_4_3_apply_pressure: "034a0000"
    readonly property string transmission_shift_5_4_apply_pressure: "034b0000"
    readonly property string transmission_shift_6_5_apply_pressure: "034c0000"
    readonly property string transmission_shift_7_6_apply_pressure: "034d0000"
    readonly property string transmission_shift_8_7_apply_pressure: "034e0000"

    readonly property string transmission_shift_1_2_release_pressure: "03510000"
    readonly property string transmission_shift_2_3_release_pressure: "03520000"
    readonly property string transmission_shift_3_4_release_pressure: "03530000"
    readonly property string transmission_shift_4_5_release_pressure: "03540000"
    readonly property string transmission_shift_5_6_release_pressure: "03550000"
    readonly property string transmission_shift_6_7_release_pressure: "03560000"
    readonly property string transmission_shift_7_8_release_pressure: "03570000"

    readonly property string transmission_shift_2_1_release_pressure: "03580000"
    readonly property string transmission_shift_3_2_release_pressure: "03590000"
    readonly property string transmission_shift_4_3_release_pressure: "035a0000"
    readonly property string transmission_shift_5_4_release_pressure: "035b0000"
    readonly property string transmission_shift_6_5_release_pressure: "035c0000"
    readonly property string transmission_shift_7_6_release_pressure: "035d0000"
    readonly property string transmission_shift_8_7_release_pressure: "035e0000"

    readonly property string transmission_gear_1_main_percentage: "03610000"
    readonly property string transmission_gear_2_main_percentage: "03620000"
    readonly property string transmission_gear_3_main_percentage: "03630000"
    readonly property string transmission_gear_4_main_percentage: "03640000"
    readonly property string transmission_gear_5_main_percentage: "03650000"
    readonly property string transmission_gear_6_main_percentage: "03660000"
    readonly property string transmission_gear_7_main_percentage: "03670000"
    readonly property string transmission_gear_8_main_percentage: "03680000"

    readonly property string transmission_shift_n_1_apply_percentage: "03700000"
    readonly property string transmission_shift_1_2_apply_percentage: "03710000"
    readonly property string transmission_shift_2_3_apply_percentage: "03720000"
    readonly property string transmission_shift_3_4_apply_percentage: "03730000"
    readonly property string transmission_shift_4_5_apply_percentage: "03740000"
    readonly property string transmission_shift_5_6_apply_percentage: "03750000"
    readonly property string transmission_shift_6_7_apply_percentage: "03760000"
    readonly property string transmission_shift_7_8_apply_percentage: "03770000"

    readonly property string transmission_shift_2_1_apply_percentage: "03780000"
    readonly property string transmission_shift_3_2_apply_percentage: "03790000"
    readonly property string transmission_shift_4_3_apply_percentage: "037a0000"
    readonly property string transmission_shift_5_4_apply_percentage: "037b0000"
    readonly property string transmission_shift_6_5_apply_percentage: "037c0000"
    readonly property string transmission_shift_7_6_apply_percentage: "037d0000"
    readonly property string transmission_shift_8_7_apply_percentage: "037e0000"

    readonly property string transmission_shift_1_2_release_percentage: "03810000"
    readonly property string transmission_shift_2_3_release_percentage: "03820000"
    readonly property string transmission_shift_3_4_release_percentage: "03830000"
    readonly property string transmission_shift_4_5_release_percentage: "03840000"
    readonly property string transmission_shift_5_6_release_percentage: "03850000"
    readonly property string transmission_shift_6_7_release_percentage: "03860000"
    readonly property string transmission_shift_7_8_release_percentage: "03870000"

    readonly property string transmission_shift_2_1_release_percentage: "03880000"
    readonly property string transmission_shift_3_2_release_percentage: "03890000"
    readonly property string transmission_shift_4_3_release_percentage: "038a0000"
    readonly property string transmission_shift_5_4_release_percentage: "038b0000"
    readonly property string transmission_shift_6_5_release_percentage: "038c0000"
    readonly property string transmission_shift_7_6_release_percentage: "038d0000"
    readonly property string transmission_shift_8_7_release_percentage: "038e0000"

    readonly property string transmission_pressure_temperature_compensation: "3a00000"

    readonly property string transmission_shift_r_n_prefill_time:       "03b00000"
    readonly property string transmission_shift_r_n_prefill_pressure:   "03c00000"
    readonly property string transmission_shift_r_n_prefill_percentage: "03d00000"

    readonly property string transmission_shift_n_r_prefill_time:       "03b00001"
    readonly property string transmission_shift_n_r_prefill_pressure:   "03c00001"
    readonly property string transmission_shift_n_r_prefill_percentage: "03d00001"

    readonly property string transmission_shift_n_1_prefill_time:       "03b00002"
    readonly property string transmission_shift_n_1_prefill_pressure:   "03c00002"
    readonly property string transmission_shift_n_1_prefill_percentage: "03d00002"

    readonly property string transmission_shift_1_n_prefill_time:       "03b00003"
    readonly property string transmission_shift_1_n_prefill_pressure:   "03c00003"
    readonly property string transmission_shift_1_n_prefill_percentage: "03d00003"

    readonly property string transmission_shift_1_2_prefill_time:       "03b00004"
    readonly property string transmission_shift_1_2_prefill_pressure:   "03c00004"
    readonly property string transmission_shift_1_2_prefill_percentage: "03d00004"

    readonly property string transmission_shift_2_1_prefill_time:       "03b00005"
    readonly property string transmission_shift_2_1_prefill_pressure:   "03c00005"
    readonly property string transmission_shift_2_1_prefill_percentage: "03d00005"

    readonly property string transmission_shift_2_3_prefill_time:       "03b00006"
    readonly property string transmission_shift_2_3_prefill_pressure:   "03c00006"
    readonly property string transmission_shift_2_3_prefill_percentage: "03d00006"

    readonly property string transmission_shift_3_2_prefill_time:       "03b00007"
    readonly property string transmission_shift_3_2_prefill_pressure:   "03c00007"
    readonly property string transmission_shift_3_2_prefill_percentage: "03d00007"

    readonly property string transmission_shift_3_4_prefill_time:       "03b00008"
    readonly property string transmission_shift_3_4_prefill_pressure:   "03c00008"
    readonly property string transmission_shift_3_4_prefill_percentage: "03d00008"

    readonly property string transmission_shift_4_3_prefill_time:       "03b00009"
    readonly property string transmission_shift_4_3_prefill_pressure:   "03c00009"
    readonly property string transmission_shift_4_3_prefill_percentage: "03d00009"

    readonly property string transmission_shift_4_5_prefill_time:       "03b0000a"
    readonly property string transmission_shift_4_5_prefill_pressure:   "03c0000a"
    readonly property string transmission_shift_4_5_prefill_percentage: "03d0000a"

    readonly property string transmission_shift_5_4_prefill_time:       "03b0000b"
    readonly property string transmission_shift_5_4_prefill_pressure:   "03c0000b"
    readonly property string transmission_shift_5_4_prefill_percentage: "03d0000b"

    readonly property string transmission_shift_5_6_prefill_time:       "03b0000c"
    readonly property string transmission_shift_5_6_prefill_pressure:   "03c0000c"
    readonly property string transmission_shift_5_6_prefill_percentage: "03d0000c"

    readonly property string transmission_shift_6_5_prefill_time:       "03b0000d"
    readonly property string transmission_shift_6_5_prefill_pressure:   "03c0000d"
    readonly property string transmission_shift_6_5_prefill_percentage: "03d0000d"

    readonly property string transmission_st_downshift_torque_threshold: "03e00000"
    readonly property string transmission_st_upshift_torque_threshold: "03e30000"

    readonly property string transmission_shift_r_n_ts_transfer_time: "03e10000"
    readonly property string transmission_shift_n_r_ts_transfer_time: "03e10001"
    readonly property string transmission_shift_n_1_ts_transfer_time: "03e10002"
    readonly property string transmission_shift_1_n_ts_transfer_time: "03e10003"
    readonly property string transmission_shift_1_2_ts_transfer_time: "03e10004"
    readonly property string transmission_shift_2_1_ts_transfer_time: "03e10005"
    readonly property string transmission_shift_2_3_ts_transfer_time: "03e10006"
    readonly property string transmission_shift_3_2_ts_transfer_time: "03e10007"
    readonly property string transmission_shift_3_4_ts_transfer_time: "03e10008"
    readonly property string transmission_shift_4_3_ts_transfer_time: "03e10009"
    readonly property string transmission_shift_4_5_ts_transfer_time: "03e1000a"
    readonly property string transmission_shift_5_4_ts_transfer_time: "03e1000b"
    readonly property string transmission_shift_5_6_ts_transfer_time: "03e1000c"
    readonly property string transmission_shift_6_5_ts_transfer_time: "03e1000d"

    readonly property string transmission_shift_r_n_st_transfer_time: "03e20000"
    readonly property string transmission_shift_n_r_st_transfer_time: "03e20001"
    readonly property string transmission_shift_n_1_st_transfer_time: "03e20002"
    readonly property string transmission_shift_1_n_st_transfer_time: "03e20003"
    readonly property string transmission_shift_1_2_st_transfer_time: "03e20004"
    readonly property string transmission_shift_2_1_st_transfer_time: "03e20005"
    readonly property string transmission_shift_2_3_st_transfer_time: "03e20006"
    readonly property string transmission_shift_3_2_st_transfer_time: "03e20007"
    readonly property string transmission_shift_3_4_st_transfer_time: "03e20008"
    readonly property string transmission_shift_4_3_st_transfer_time: "03e20009"
    readonly property string transmission_shift_4_5_st_transfer_time: "03e2000a"
    readonly property string transmission_shift_5_4_st_transfer_time: "03e2000b"
    readonly property string transmission_shift_5_6_st_transfer_time: "03e2000c"
    readonly property string transmission_shift_6_5_st_transfer_time: "03e2000d"

    readonly property string garage_shift_time: "03f00000"
    readonly property string garage_shift_max_pressure: "03f40000"
    readonly property string garage_shift_max_percentage: "03f50000"
    readonly property string garage_shift_p_const: "03f60000"
    readonly property string garage_shift_i_const: "03f70000"
    readonly property string garage_shift_d_const: "03f80000"

    // 8300 transmission data
    readonly property string transmission_gears: "83000000"
    readonly property string transmission_ratios: "83010000"
    readonly property string transmission_tcc_min_gear: "83020000"
    readonly property string transmission_ratio: "83030000"

    readonly property string transmission_oil_temperature: "83050000"
    readonly property string transmission_oil_level: "83060000"
    readonly property string transmission_oil_level_measurement_status: "83070000"
    readonly property string transmission_oil_level_settling_time: "83080000"

    readonly property string transmission_turbine_shaft_speed: "83100000"
    readonly property string transmission_input_shaft_speed: "83110000"
    readonly property string transmission_output_shaft_speed: "83120000"
    readonly property string transmission_slip: "83130000"
    readonly property string transmission_torque_converter_slip: "83140000"

    readonly property string transmission_shaft_1_speed: "831a0000"
    readonly property string transmission_shaft_2_speed: "831b0000"
    readonly property string transmission_shaft_3_speed: "831c0000"
    readonly property string transmission_shaft_4_speed: "831d0000"
    readonly property string transmission_shaft_5_speed: "831e0000"
    readonly property string transmission_shaft_6_speed: "831f0000"

    readonly property string transmission_main_pressure: "83200000"
    readonly property string transmission_tcc_pressure: "83210000"
    readonly property string transmission_clutch_1_pressure: "83220000"
    readonly property string transmission_clutch_2_pressure: "83230000"
    readonly property string transmission_clutch_3_pressure: "83240000"
    readonly property string transmission_clutch_4_pressure: "83250000"
    readonly property string transmission_clutch_5_pressure: "83260000"
    readonly property string transmission_clutch_6_pressure: "83270000"
    readonly property string transmission_clutch_7_pressure: "83280000"
    readonly property string transmission_clutch_8_pressure: "83290000"

    readonly property string transmission_shift_n_r: "83600000"
    readonly property string transmission_shift_n_1: "83610000"
    readonly property string transmission_shift_1_2: "83620000"
    readonly property string transmission_shift_2_3: "83630000"
    readonly property string transmission_shift_3_4: "83640000"
    readonly property string transmission_shift_4_5: "83650000"
    readonly property string transmission_shift_5_6: "83660000"
    readonly property string transmission_shift_6_7: "83670000"
    readonly property string transmission_shift_7_8: "83680000"

    readonly property string transmission_shift_r_n: "83700000"
    readonly property string transmission_shift_1_n: "83710000"
    readonly property string transmission_shift_2_1: "83720000"
    readonly property string transmission_shift_3_2: "83730000"
    readonly property string transmission_shift_4_3: "83740000"
    readonly property string transmission_shift_5_4: "83750000"
    readonly property string transmission_shift_6_5: "83760000"
    readonly property string transmission_shift_7_6: "83770000"
    readonly property string transmission_shift_8_7: "83780000"

    readonly property string transmission_gear_r: "83800000"
    readonly property string transmission_gear_n: "83810000"
    readonly property string transmission_gear_1: "83820000"
    readonly property string transmission_gear_2: "83830000"
    readonly property string transmission_gear_3: "83840000"
    readonly property string transmission_gear_4: "83850000"
    readonly property string transmission_gear_5: "83860000"
    readonly property string transmission_gear_6: "83870000"
    readonly property string transmission_gear_7: "83880000"
    readonly property string transmission_gear_8: "83890000"

    readonly property string transmission_main_pressure_sensor_voltage: "83300000"

    // 0400 starts shift adjustments..
    readonly property string reverse_lockout_speed: "04100000"

    readonly property string shift_speed_adjust_a: "04200000"
    readonly property string shift_downshift_offset_a: "04210000"
    readonly property string shift_manual_mode_a: "04220000"
    readonly property string shift_max_engine_speed_a: "04230000"
    readonly property string shift_tables_a_up_1: "04240000"
    readonly property string shift_tables_a_up_2: "04250000"
    readonly property string shift_tables_a_up_3: "04260000"
    readonly property string shift_tables_a_up_4: "04270000"
    readonly property string shift_tables_a_up_5: "04280000"
    readonly property string shift_tables_a_down_locked: "042f0000"

    readonly property string shift_downshift_offset_b: "04400000"
    readonly property string shift_manual_mode_b: "04410000"
    readonly property string shift_speed_adjust_b: "04420000"
    readonly property string shift_max_engine_speed_b: "04430000"
    readonly property string shift_tables_b_up_1: "04440000"
    readonly property string shift_tables_b_up_2: "04450000"
    readonly property string shift_tables_b_up_3: "04460000"
    readonly property string shift_tables_b_up_4: "04470000"
    readonly property string shift_tables_b_up_5: "04480000"
    readonly property string shift_tables_b_down_locked: "044f0000"

    readonly property string shift_torque_limit_1_2: "04500000"
    readonly property string shift_torque_limit_2_3: "04510000"
    readonly property string shift_torque_limit_3_4: "04520000"
    readonly property string shift_torque_limit_4_5: "04530000"
    readonly property string shift_torque_limit_5_6: "04540000"
    readonly property string shift_torque_limit_6_7: "04550000"
    readonly property string shift_torque_limit_7_8: "04560000"

    readonly property string shift_torque_limit_2_1: "04600000"
    readonly property string shift_torque_limit_3_2: "04610000"
    readonly property string shift_torque_limit_4_3: "04620000"
    readonly property string shift_torque_limit_5_4: "04630000"
    readonly property string shift_torque_limit_6_5: "04640000"
    readonly property string shift_torque_limit_7_6: "04650000"
    readonly property string shift_torque_limit_8_7: "04660000"

    readonly property string shift_torque_limit_garage_shift: "04700000"

    readonly property string shift_tables_a_down_1: "04800000"
    readonly property string shift_tables_a_down_2: "04810000"
    readonly property string shift_tables_a_down_3: "04820000"
    readonly property string shift_tables_a_down_4: "04830000"
    readonly property string shift_tables_a_down_5: "04840000"
    readonly property string shift_tables_b_down_1: "04880000"
    readonly property string shift_tables_b_down_2: "04890000"
    readonly property string shift_tables_b_down_3: "048a0000"
    readonly property string shift_tables_b_down_4: "048b0000"
    readonly property string shift_tables_b_down_5: "048c0000"

    // 8400 shift data
    readonly property string shift_current_gear: "84000000"
    readonly property string shift_selected_gear: "84010000"
    readonly property string shift_control_mode: "84020000"
    readonly property string shift_diagnostic_gear: "84030000"
    readonly property string shift_lowest_possible_gear: "84040000"
    readonly property string shift_recommended_gear: "84050000"
    readonly property string shift_highest_possible_gear: "84060000"
    readonly property string shift_requested_gear: "84100000"

    readonly property string shift_requested_range: "84110000"
    readonly property string shift_selected_range: "84120000"

    // 0500 pressure settings
    readonly property string pressure_control_source: "05000000"

    readonly property string pressure_adjust_a: "05200000"
    readonly property string pressure_r2l_boost_a: "05210000"
    readonly property string pressure_tables_a_1: "05220000"
    readonly property string pressure_tables_a_2: "05230000"
    readonly property string pressure_tables_a_3: "05240000"
    readonly property string pressure_tables_a_4: "05250000"
    readonly property string pressure_tables_a_5: "05260000"
    readonly property string pressure_tables_a_6: "05270000"

    readonly property string pressure_adjust_b: "05400000"
    readonly property string pressure_r2l_boost_b: "05410000"
    readonly property string pressure_tables_b_1: "05420000"
    readonly property string pressure_tables_b_2: "05430000"
    readonly property string pressure_tables_b_3: "05440000"
    readonly property string pressure_tables_b_4: "05450000"
    readonly property string pressure_tables_b_5: "05460000"
    readonly property string pressure_tables_b_6: "05470000"

    readonly property string clutch_1_solenoid_pressure: "05a00000"
    readonly property string clutch_1_solenoid_current: "05a10000"
    readonly property string clutch_2_solenoid_pressure: "05a20000"
    readonly property string clutch_2_solenoid_current: "05a30000"
    readonly property string clutch_3_solenoid_pressure: "05a40000"
    readonly property string clutch_3_solenoid_current: "05a50000"
    readonly property string clutch_4_solenoid_pressure: "05a60000"
    readonly property string clutch_4_solenoid_current: "05a70000"
    readonly property string clutch_5_solenoid_pressure: "05a80000"
    readonly property string clutch_5_solenoid_current: "05a90000"
    readonly property string clutch_6_solenoid_pressure: "05aa0000"
    readonly property string clutch_6_solenoid_current: "05ab0000"
    readonly property string clutch_7_solenoid_pressure: "05ac0000"
    readonly property string clutch_7_solenoid_current: "05ad0000"
    readonly property string clutch_8_solenoid_pressure: "05ae0000"
    readonly property string clutch_8_solenoid_current: "05af0000"

    // 8500 pressure data
    readonly property string pressure_current_percentage: "85000000"
    readonly property string pressure_selected_percentage: "85010000"
    readonly property string pressure_diagnostic_percentage: "85020000"

    // 0600 tcc settings
    readonly property string tcc_downshift_offset_a: "06200000"
    readonly property string tcc_disable_toss_percent_a: "06210000"
    readonly property string tcc_enable_gear_a: "06220000"
    readonly property string tcc_enable_toss_a: "06230000"
    readonly property string tcc_manual_mode_a: "06240000"
    readonly property string tcc_max_throttle_a: "06250000"
    readonly property string tcc_min_throttle_a: "06260000"
    readonly property string tcc_disable_in_switch_shift_a: "06270000"


    readonly property string tcc_downshift_offset_b: "06400000"
    readonly property string tcc_disable_toss_percent_b: "06410000"
    readonly property string tcc_enable_gear_b: "06420000"
    readonly property string tcc_enable_toss_b: "06430000"
    readonly property string tcc_manual_mode_b: "06440000"
    readonly property string tcc_max_throttle_b: "06450000"
    readonly property string tcc_min_throttle_b: "06460000"
    readonly property string tcc_disable_in_switch_shift_b: "06470000"

    readonly property string tcc_prefill_time: "06500000"
    readonly property string tcc_apply_time: "06510000"
    readonly property string tcc_prefill_pressure: "06520000"
    readonly property string tcc_prefill_percentage: "06530000"
    readonly property string tcc_max_pressure: "06540000"
    readonly property string tcc_max_percentage: "06550000"
    readonly property string tcc_percentage_proportional_constant: "06560000"
    readonly property string tcc_percentage_integral_constant: "06570000"
    readonly property string tcc_percentage_derivative_constant: "06580000"
    readonly property string tcc_pressure_proportional_constant: "06590000"
    readonly property string tcc_pressure_integral_constant: "065a0000"
    readonly property string tcc_pressure_derivative_constant: "065b0000"
    readonly property string tcc_stroke_time: "065c0000"
    readonly property string tcc_stroke_pressure: "065d0000"
    readonly property string tcc_stroke_percentage: "065e0000"

    readonly property string tc_mult_speedratio: "06700000"
    readonly property string tc_mult_torqueratio: "06710000"

    readonly property double tcc_tables_lock_a_1: 0x06800000
    readonly property double tcc_tables_lock_a_2: 0x06810000
    readonly property double tcc_tables_lock_a_3: 0x06820000
    readonly property double tcc_tables_lock_a_4: 0x06830000
    readonly property double tcc_tables_lock_a_5: 0x06840000
    readonly property double tcc_tables_lock_a_6: 0x06850000

    readonly property double tcc_tables_unlock_a_1: 0x06900000
    readonly property double tcc_tables_unlock_a_2: 0x06910000
    readonly property double tcc_tables_unlock_a_3: 0x06920000
    readonly property double tcc_tables_unlock_a_4: 0x06930000
    readonly property double tcc_tables_unlock_a_5: 0x06940000
    readonly property double tcc_tables_unlock_a_6: 0x06950000

    readonly property double tcc_tables_lock_b_1: 0x06a00000
    readonly property double tcc_tables_lock_b_2: 0x06a10000
    readonly property double tcc_tables_lock_b_3: 0x06a20000
    readonly property double tcc_tables_lock_b_4: 0x06a30000
    readonly property double tcc_tables_lock_b_5: 0x06a40000
    readonly property double tcc_tables_lock_b_6: 0x06a50000

    readonly property double tcc_tables_unlock_b_1: 0x06b00000
    readonly property double tcc_tables_unlock_b_2: 0x06b10000
    readonly property double tcc_tables_unlock_b_3: 0x06b20000
    readonly property double tcc_tables_unlock_b_4: 0x06b30000
    readonly property double tcc_tables_unlock_b_5: 0x06b40000
    readonly property double tcc_tables_unlock_b_6: 0x06b50000


    // 8600 tcc data
    readonly property string tcc_current_state: "86000000"
    readonly property string tcc_selected_state: "86010000"
    readonly property string tcc_control_mode: "86020000"
    readonly property string tcc_diagnostic_tcc: "86030000"

    // 0700 engine settings
    readonly property string engine_cylinders: "07000000"

    readonly property string engine_running_detection_speed: "07010000"
    readonly property string engine_max_torque: "07020000"

    readonly property string engine_map_torque_proportion: "07050000"

    readonly property string voltage_tps_ground_enable: "07100000"
    readonly property string voltage_tps_is_reversed: "07110000"
    readonly property string voltage_tps_calibration_low: "07120000"
    readonly property string voltage_tps_calibration_high: "07130000"
    readonly property string voltage_tps_filter_order: "07140000"

    readonly property string voltage_map_sensor_ground_enable: "07200000"
    readonly property string voltage_map_sensor_low_calibration: "07220000"
    readonly property string voltage_map_sensor_high_calibration: "07230000"

    readonly property string cs2_engine_temp_bias_enable: "07300000"

    readonly property string engine_idle_shutdown_time: "07400000"

    readonly property string engine_motoring_speed: "07500000"
    readonly property string engine_motoring_max_torque: "07510000"
    readonly property string engine_braking_speed: "07520000"
    readonly property string engine_braking_max_torque: "07530000"

    // 8700 engine data
    readonly property string engine_speed: "87000000"
    readonly property string engine_torque_mode: "87010000"
    readonly property string engine_actual_percent_torque: "87020000"
    readonly property string drivers_demand_percent_torque: "87030000"
    readonly property string engine_demand_percent_torque: "87040000"
    readonly property string acceleration_rate_limiting: "87050000"

    readonly property string engine_throttle_position: "87100000"
    readonly property string voltage_tps_voltage: "87110000"

    readonly property string engine_map_percentage: "87200000"
    readonly property string voltage_map_sensor_voltage: "87210000"

    readonly property string engine_coolant_temperature: "87300000"

    readonly property string engine_idle_shutdown_active: "87400000"
    readonly property string engine_idle_shutdown_timer_active: "87410000"

    // 0800 transfer case settings
    readonly property string transfer_case_ratios: "08000000"
    readonly property string transfer_case_ratio: "08010000"
    readonly property string transfer_case_gear: "08020000"
    // 8800 transfer case data
    readonly property string transfer_case_input_speed: "88000000"
    readonly property string transfer_case_output_speed: "88010000"
    readonly property string transfer_case_temperature: "88020000"

    // 0900 shift selector settings
    readonly property string shift_selector_gear_voltages: "09000000"
    readonly property string shift_selector_overdrive_cancel_at_startup: "09010000"
    // 8900 shift selector data
    readonly property string shift_selector_gear: "89000000"
    readonly property string shift_selector_sensor_voltage: "89010000"

    // 0a00 differential settings
    readonly property string final_drive_ratio: "0a000000"
    // 8a00 differential data
    readonly property string differential_input_speed: "8a000000"
    readonly property string differential_output_speed: "8a010000"
    readonly property string differential_temperature: "8a020000"

    // 0b00 ebus settings
    readonly property string ev_motor_communications: "0b000000"

    readonly property string ev_torque_filter_order: "0b100000"
    readonly property string ev_speed_filter_order: "0b110000"

    readonly property string ev_motor_torque_idle: "0b200000"
    readonly property string ev_motor_torque_shift: "0b210000"
    readonly property string ev_motor_speed_max: "0b220000"

    readonly property string ev_torque_ramp_down_time: "0b230000"
    readonly property string ev_torque_ramp_up_time: "0b240000"

    readonly property string ev_motor_torque_max_a: "0b300000"
    readonly property string ev_regen_torque_max_a: "0b310000"
    readonly property string ev_max_regen_speed_a: "0b320000"

    readonly property string ev_motor_torque_max_b: "0b400000"
    readonly property string ev_regen_torque_max_b: "0b410000"
    readonly property string ev_max_regen_speed_b: "0b420000"

    readonly property string ebus_shift_synchronization_tolerance: "0b500000"
    readonly property string ebus_shift_synchronization_duration: "0b510000"
    readonly property string clutch_release_time: "0b520000"
    readonly property string clutch_prefill_time: "0b530000"
    readonly property string clutch_prefill_pressure: "0b540000"
    readonly property string clutch_prefill_percentage: "0b550000"
    readonly property string clutch_stroke_time: "0b560000"
    readonly property string clutch_stroke_pressure: "0b570000"

    readonly property string ev_j1939_ctl_source_address: "0b600000"

    // 8b00 ev data
    readonly property string ev_drive_fault_count: "8b000000"
    readonly property string ev_drive_last_fault_type: "8b010000"

    // 0c00 can bus settings
    readonly property string can0_baud_rate: "0c000000"
    readonly property string can1_baud_rate: "0c100000"

    readonly property string j1939_transmission_address: "0c200000"
    readonly property string j1939_engine_address: "0c210000"
    readonly property string j1939_shift_selector_address: "0c220000"

    readonly property string xcp_cto_id: "0c300000"
    readonly property string xcp_dto_id: "0c310000"

    readonly property string can0_transmit_error_count: "8c000000"
    readonly property string can0_receive_error_count: "8c010000"
    readonly property string can0_transmit_count: "8c020000"
    readonly property string can0_receive_count: "8c030000"

    readonly property string can1_transmit_error_count: "8c100000"
    readonly property string can1_receive_error_count: "8c110000"
    readonly property string can1_transmit_count: "8c120000"
    readonly property string can1_receive_count: "8c130000"

    // 0e00 fault system
    readonly property string dtc_active_count: "8ee00000"
    readonly property string dtc_recorded_count: "8e010000"
    readonly property string dtc_active_count_by_type: "8ee20000"
    readonly property string dtc_recorded_count_by_type: "8e030000"

    // 0f00 control system config
    readonly property string reset_defaults: "0f000000"
    readonly property string security_code: "0f800000"
    readonly property string setup_security_code: "0f810000"
    // 8f00 control system data
    // ab mode
    readonly property string controller_mode: "8f000000"
    readonly property string diagnostic_mode: "8f010000"
    readonly property string security_level: "8f800000"
}
