import QtQuick 2.5

QtObject {
    readonly property double controller_software_version: 0x80010000
    readonly property double controller_heap_used: 0x80080000
    readonly property double controller_heap_size: 0x80090000
    readonly property double controller_heap_allocation_count: 0x800a0000
    readonly property double controller_heap_release_count: 0x800b0000

    readonly property double controller_tach_input_frequency: 0x80100000
    readonly property double controller_tiss_input_frequency: 0x80110000
    readonly property double controller_toss_input_frequency: 0x80120000
    readonly property double controller_spare_input_frequency: 0x80130000

    readonly property double controller_throttle_position_sensor_voltage: 0x80200000
    readonly property double controller_map_sensor_voltage: 0x80210000
    readonly property double controller_internal_temperature_sensor_voltage: 0x80220000
    readonly property double controller_internal_temperature: 0x80230000
    readonly property double controller_engine_temperature_sensor_voltage: 0x80240000
    readonly property double controller_transmission_temperature_sensor_voltage: 0x80250000
    readonly property double controller_multiplexed_sensor_voltage: 0x80260000

    readonly property double controller_5_volt_bus_voltage: 0x80270000
    readonly property double controller_3_3_volt_bus_voltage: 0x80280000
    readonly property double controller_1_8_volt_bus_voltage: 0x80290000
    readonly property double controller_12_volt_bus_voltage: 0x802a0000
    readonly property double controller_voltage: 0x802c0000

    readonly property double controller_acclerometer: 0x80300000

    readonly property double controller_speed_timer_1_frequency: 0x80400000
    readonly property double controller_speed_timer_2_frequency: 0x80410000

    readonly property double controller_switch_state: 0x80500000
    readonly property double controller_switch_current: 0x80510000

    readonly property double controller_sd_card_write_protect: 0x80600000
    readonly property double controller_sd_card_present: 0x80610000
    readonly property double controller_master_driver_fault: 0x80620000

    readonly property double controller_usb_power: 0x80700000
    readonly property double controller_green_led: 0x80710000
    readonly property double controller_red_led: 0x80720000
    readonly property double controller_transmission_temperature_sensor_bias: 0x80730000
    readonly property double controller_engine_temperature_sensor_bias: 0x80740000
    readonly property double controller_throttle_position_sensor_ground: 0x80750000
    readonly property double controller_map_ground: 0x80760000
    readonly property double controller_usb_connect: 0x80770000

    readonly property double controller_pwmdriver_frequency: 0x80800000

    readonly property double controller_pwmdriver_duty_cycle: 0x80900000

    readonly property double controller_pwmdriver_mode: 0x80a00000

    readonly property double controller_pwmdriver_spn_1: 0x80b00000
    readonly property double controller_pwmdriver_spn_2: 0x80b10000
    readonly property double controller_pwmdriver_spn_3: 0x80b20000
    readonly property double controller_pwmdriver_spn_4: 0x80b30000
    readonly property double controller_pwmdriver_spn_5: 0x80b40000
    readonly property double controller_pwmdriver_spn_6: 0x80b50000
    readonly property double controller_pwmdriver_spn_7: 0x80b60000
    readonly property double controller_pwmdriver_spn_8: 0x80b70000
    readonly property double controller_pwmdriver_spn_9: 0x80b80000
    readonly property double controller_pwmdriver_spn_10: 0x80b90000
    readonly property double controller_pwmdriver_spn_11: 0x80ba0000
    readonly property double controller_pwmdriver_spn_12: 0x80bb0000

    // display settings
    readonly property double display_type: 0x01000000
    readonly property double use_metric_units: 0x01010000
    readonly property double display_brightness: 0x01020000
    readonly property double display_contrast: 0x01030000
    readonly property double display_color: 0x01040000

    readonly property double display_mixed_meter_1_config: 0x01100000
    readonly property double display_mixed_meter_2_config: 0x01110000
    readonly property double display_mixed_meter_3_config: 0x01120000
    readonly property double display_mixed_meter_4_config: 0x01130000

    // 0200 vehicle settings
    readonly property double variation: 0x02000000
    readonly property double vehicle_mass: 0x02010000
    readonly property double tire_diameter: 0x02020000
    readonly property double speedometer_calibration: 0x02030000
    readonly property double start_inhibit_relay_type: 0x02040000
    readonly property double vehicle_speed_sensor_pulse_count: 0x02050000

    // 8200 vehicle data
    readonly property double vehicle_speed: 0x82000000
    readonly property double vehicle_acceleration: 0x82010000
    readonly property double vehicle_speed_sensor_speed: 0x82020000
    readonly property double brake_switch: 0x82030000
    readonly property double left_front_wheel_speed: 0x82040000
    readonly property double right_front_wheel_speed: 0x82050000
    readonly property double left_rear_wheel_speed: 0x82060000
    readonly property double right_rear_wheel_speed: 0x82070000

    // 0300 transmission settings
    readonly property double transmission_type: 0x03000000
    readonly property double transmission_temp_bias_enable: 0x03010000
    readonly property double transmission_main_pressure_sensor_present: 0x03020000
    readonly property double transmission_has_line_pressure_control: 0x03030000
    readonly property double transmission_has_accumulator_control: 0x03040000
    readonly property double transmission_has_pwm_tcc: 0x03050000

    readonly property double transmission_turbine_shaft_speed_sensor_pulse_count: 0x03080000
    readonly property double transmission_input_shaft_speed_sensor_pulse_count: 0x03090000

    readonly property double transmission_shaft_1_speed_sensor_pulse_count: 0x30a0000
    readonly property double transmission_shaft_2_speed_sensor_pulse_count: 0x30b0000
    readonly property double transmission_shaft_3_speed_sensor_pulse_count: 0x30c0000
    readonly property double transmission_shaft_4_speed_sensor_pulse_count: 0x30d0000
    readonly property double transmission_shaft_5_speed_sensor_pulse_count: 0x30e0000
    readonly property double transmission_shaft_6_speed_sensor_pulse_count: 0x30f0000

    readonly property double transmission_gear_1_main_pressure: 0x03310000
    readonly property double transmission_gear_2_main_pressure: 0x03320000
    readonly property double transmission_gear_3_main_pressure: 0x03330000
    readonly property double transmission_gear_4_main_pressure: 0x03340000
    readonly property double transmission_gear_5_main_pressure: 0x03350000
    readonly property double transmission_gear_6_main_pressure: 0x03360000
    readonly property double transmission_gear_7_main_pressure: 0x03370000
    readonly property double transmission_gear_8_main_pressure: 0x03380000

    readonly property double transmission_shift_n_1_apply_pressure: 0x03400000
    readonly property double transmission_shift_1_2_apply_pressure: 0x03410000
    readonly property double transmission_shift_2_3_apply_pressure: 0x03420000
    readonly property double transmission_shift_3_4_apply_pressure: 0x03430000
    readonly property double transmission_shift_4_5_apply_pressure: 0x03440000
    readonly property double transmission_shift_5_6_apply_pressure: 0x03450000
    readonly property double transmission_shift_6_7_apply_pressure: 0x03460000
    readonly property double transmission_shift_7_8_apply_pressure: 0x03470000

    readonly property double transmission_shift_2_1_apply_pressure: 0x03480000
    readonly property double transmission_shift_3_2_apply_pressure: 0x03490000
    readonly property double transmission_shift_4_3_apply_pressure: 0x034a0000
    readonly property double transmission_shift_5_4_apply_pressure: 0x034b0000
    readonly property double transmission_shift_6_5_apply_pressure: 0x034c0000
    readonly property double transmission_shift_7_6_apply_pressure: 0x034d0000
    readonly property double transmission_shift_8_7_apply_pressure: 0x034e0000

    readonly property double transmission_shift_1_2_release_pressure: 0x03510000
    readonly property double transmission_shift_2_3_release_pressure: 0x03520000
    readonly property double transmission_shift_3_4_release_pressure: 0x03530000
    readonly property double transmission_shift_4_5_release_pressure: 0x03540000
    readonly property double transmission_shift_5_6_release_pressure: 0x03550000
    readonly property double transmission_shift_6_7_release_pressure: 0x03560000
    readonly property double transmission_shift_7_8_release_pressure: 0x03570000

    readonly property double transmission_shift_2_1_release_pressure: 0x03580000
    readonly property double transmission_shift_3_2_release_pressure: 0x03590000
    readonly property double transmission_shift_4_3_release_pressure: 0x35a0000
    readonly property double transmission_shift_5_4_release_pressure: 0x35b0000
    readonly property double transmission_shift_6_5_release_pressure: 0x35c0000
    readonly property double transmission_shift_7_6_release_pressure: 0x35d0000
    readonly property double transmission_shift_8_7_release_pressure: 0x35e0000

    readonly property double transmission_gear_1_main_percentage: 0x03610000
    readonly property double transmission_gear_2_main_percentage: 0x03620000
    readonly property double transmission_gear_3_main_percentage: 0x03630000
    readonly property double transmission_gear_4_main_percentage: 0x03640000
    readonly property double transmission_gear_5_main_percentage: 0x03650000
    readonly property double transmission_gear_6_main_percentage: 0x03660000
    readonly property double transmission_gear_7_main_percentage: 0x03670000
    readonly property double transmission_gear_8_main_percentage: 0x03680000

    readonly property double transmission_shift_n_1_apply_percentage: 0x03700000
    readonly property double transmission_shift_1_2_apply_percentage: 0x03710000
    readonly property double transmission_shift_2_3_apply_percentage: 0x03720000
    readonly property double transmission_shift_3_4_apply_percentage: 0x03730000
    readonly property double transmission_shift_4_5_apply_percentage: 0x03740000
    readonly property double transmission_shift_5_6_apply_percentage: 0x03750000
    readonly property double transmission_shift_6_7_apply_percentage: 0x03760000
    readonly property double transmission_shift_7_8_apply_percentage: 0x03770000

    readonly property double transmission_shift_2_1_apply_percentage: 0x03780000
    readonly property double transmission_shift_3_2_apply_percentage: 0x03790000
    readonly property double transmission_shift_4_3_apply_percentage: 0x37a0000
    readonly property double transmission_shift_5_4_apply_percentage: 0x37b0000
    readonly property double transmission_shift_6_5_apply_percentage: 0x37c0000
    readonly property double transmission_shift_7_6_apply_percentage: 0x37d0000
    readonly property double transmission_shift_8_7_apply_percentage: 0x37e0000

    readonly property double transmission_shift_1_2_release_percentage: 0x03810000
    readonly property double transmission_shift_2_3_release_percentage: 0x03820000
    readonly property double transmission_shift_3_4_release_percentage: 0x03830000
    readonly property double transmission_shift_4_5_release_percentage: 0x03840000
    readonly property double transmission_shift_5_6_release_percentage: 0x03850000
    readonly property double transmission_shift_6_7_release_percentage: 0x03860000
    readonly property double transmission_shift_7_8_release_percentage: 0x03870000

    readonly property double transmission_shift_2_1_release_percentage: 0x03880000
    readonly property double transmission_shift_3_2_release_percentage: 0x03890000
    readonly property double transmission_shift_4_3_release_percentage: 0x38a0000
    readonly property double transmission_shift_5_4_release_percentage: 0x38b0000
    readonly property double transmission_shift_6_5_release_percentage: 0x38c0000
    readonly property double transmission_shift_7_6_release_percentage: 0x38d0000
    readonly property double transmission_shift_8_7_release_percentage: 0x38e0000

    readonly property double transmission_pressure_temperature_compensation: 0x3a00000

    readonly property double transmission_shift_r_n_prefill_time:       0x03b00000
    readonly property double transmission_shift_r_n_prefill_pressure:   0x03c00000
    readonly property double transmission_shift_r_n_prefill_percentage: 0x03d00000

    readonly property double transmission_shift_n_r_prefill_time:       0x03b00001
    readonly property double transmission_shift_n_r_prefill_pressure:   0x03c00001
    readonly property double transmission_shift_n_r_prefill_percentage: 0x03d00001

    readonly property double transmission_shift_n_1_prefill_time:       0x03b00002
    readonly property double transmission_shift_n_1_prefill_pressure:   0x03c00002
    readonly property double transmission_shift_n_1_prefill_percentage: 0x03d00002

    readonly property double transmission_shift_1_n_prefill_time:       0x03b00003
    readonly property double transmission_shift_1_n_prefill_pressure:   0x03c00003
    readonly property double transmission_shift_1_n_prefill_percentage: 0x03d00003

    readonly property double transmission_shift_1_2_prefill_time:       0x03b00004
    readonly property double transmission_shift_1_2_prefill_pressure:   0x03c00004
    readonly property double transmission_shift_1_2_prefill_percentage: 0x03d00004

    readonly property double transmission_shift_2_1_prefill_time:       0x03b00005
    readonly property double transmission_shift_2_1_prefill_pressure:   0x03c00005
    readonly property double transmission_shift_2_1_prefill_percentage: 0x03d00005

    readonly property double transmission_shift_2_3_prefill_time:       0x03b00006
    readonly property double transmission_shift_2_3_prefill_pressure:   0x03c00006
    readonly property double transmission_shift_2_3_prefill_percentage: 0x03d00006

    readonly property double transmission_shift_3_2_prefill_time:       0x03b00007
    readonly property double transmission_shift_3_2_prefill_pressure:   0x03c00007
    readonly property double transmission_shift_3_2_prefill_percentage: 0x03d00007

    readonly property double transmission_shift_3_4_prefill_time:       0x03b00008
    readonly property double transmission_shift_3_4_prefill_pressure:   0x03c00008
    readonly property double transmission_shift_3_4_prefill_percentage: 0x03d00008

    readonly property double transmission_shift_4_3_prefill_time:       0x03b00009
    readonly property double transmission_shift_4_3_prefill_pressure:   0x03c00009
    readonly property double transmission_shift_4_3_prefill_percentage: 0x03d00009

    readonly property double transmission_shift_4_5_prefill_time:       0x03b0000a
    readonly property double transmission_shift_4_5_prefill_pressure:   0x03c0000a
    readonly property double transmission_shift_4_5_prefill_percentage: 0x03d0000a

    readonly property double transmission_shift_5_4_prefill_time:       0x03b0000b
    readonly property double transmission_shift_5_4_prefill_pressure:   0x03c0000b
    readonly property double transmission_shift_5_4_prefill_percentage: 0x03d0000b

    readonly property double transmission_shift_5_6_prefill_time:       0x03b0000c
    readonly property double transmission_shift_5_6_prefill_pressure:   0x03c0000c
    readonly property double transmission_shift_5_6_prefill_percentage: 0x03d0000c

    readonly property double transmission_shift_6_5_prefill_time:       0x03b0000d
    readonly property double transmission_shift_6_5_prefill_pressure:   0x03c0000d
    readonly property double transmission_shift_6_5_prefill_percentage: 0x03d0000d

    readonly property double transmission_st_downshift_torque_threshold: 0x03e00000
    readonly property double transmission_st_upshift_torque_threshold: 0x03e30000
    readonly property double transmission_ts_reg_p_const: 0x03e40000
    readonly property double transmission_ts_reg_i_const: 0x03e50000
    readonly property double transmission_ts_reg_d_const: 0x03e60000

    readonly property double transmission_shift_r_n_ts_transfer_time: 0x03e10000
    readonly property double transmission_shift_n_r_ts_transfer_time: 0x03e10001
    readonly property double transmission_shift_n_1_ts_transfer_time: 0x03e10002
    readonly property double transmission_shift_1_n_ts_transfer_time: 0x03e10003
    readonly property double transmission_shift_1_2_ts_transfer_time: 0x03e10004
    readonly property double transmission_shift_2_1_ts_transfer_time: 0x03e10005
    readonly property double transmission_shift_2_3_ts_transfer_time: 0x03e10006
    readonly property double transmission_shift_3_2_ts_transfer_time: 0x03e10007
    readonly property double transmission_shift_3_4_ts_transfer_time: 0x03e10008
    readonly property double transmission_shift_4_3_ts_transfer_time: 0x03e10009
    readonly property double transmission_shift_4_5_ts_transfer_time: 0x03e1000a
    readonly property double transmission_shift_5_4_ts_transfer_time: 0x03e1000b
    readonly property double transmission_shift_5_6_ts_transfer_time: 0x03e1000c
    readonly property double transmission_shift_6_5_ts_transfer_time: 0x03e1000d

    readonly property double transmission_shift_r_n_st_transfer_time: 0x03e20000
    readonly property double transmission_shift_n_r_st_transfer_time: 0x03e20001
    readonly property double transmission_shift_n_1_st_transfer_time: 0x03e20002
    readonly property double transmission_shift_1_n_st_transfer_time: 0x03e20003
    readonly property double transmission_shift_1_2_st_transfer_time: 0x03e20004
    readonly property double transmission_shift_2_1_st_transfer_time: 0x03e20005
    readonly property double transmission_shift_2_3_st_transfer_time: 0x03e20006
    readonly property double transmission_shift_3_2_st_transfer_time: 0x03e20007
    readonly property double transmission_shift_3_4_st_transfer_time: 0x03e20008
    readonly property double transmission_shift_4_3_st_transfer_time: 0x03e20009
    readonly property double transmission_shift_4_5_st_transfer_time: 0x03e2000a
    readonly property double transmission_shift_5_4_st_transfer_time: 0x03e2000b
    readonly property double transmission_shift_5_6_st_transfer_time: 0x03e2000c
    readonly property double transmission_shift_6_5_st_transfer_time: 0x03e2000d

    readonly property double garage_shift_time: 0x03f00000
    readonly property double garage_shift_max_pressure: 0x03f40000
    readonly property double garage_shift_max_percentage: 0x03f50000
    readonly property double garage_shift_p_const: 0x03f60000
    readonly property double garage_shift_i_const: 0x03f70000
    readonly property double garage_shift_d_const: 0x03f80000

    // 8300 transmission data
    readonly property double transmission_gears: 0x83000000
    readonly property double transmission_ratios: 0x83010000
    readonly property double transmission_tcc_min_gear: 0x83020000
    readonly property double transmission_ratio: 0x83030000

    readonly property double transmission_oil_temperature: 0x83050000
    readonly property double transmission_oil_level: 0x83060000
    readonly property double transmission_oil_level_measurement_status: 0x83070000
    readonly property double transmission_oil_level_settling_time: 0x83080000

    readonly property double transmission_turbine_shaft_speed: 0x83100000
    readonly property double transmission_input_shaft_speed: 0x83110000
    readonly property double transmission_output_shaft_speed: 0x83120000
    readonly property double transmission_slip: 0x83130000
    readonly property double transmission_torque_converter_slip: 0x83140000

    readonly property double transmission_shaft_1_speed: 0x831a0000
    readonly property double transmission_shaft_2_speed: 0x831b0000
    readonly property double transmission_shaft_3_speed: 0x831c0000
    readonly property double transmission_shaft_4_speed: 0x831d0000
    readonly property double transmission_shaft_5_speed: 0x831e0000
    readonly property double transmission_shaft_6_speed: 0x831f0000

    readonly property double transmission_main_pressure: 0x83200000
    readonly property double transmission_tcc_pressure: 0x83210000
    readonly property double transmission_clutch_1_pressure: 0x83220000
    readonly property double transmission_clutch_2_pressure: 0x83230000
    readonly property double transmission_clutch_3_pressure: 0x83240000
    readonly property double transmission_clutch_4_pressure: 0x83250000
    readonly property double transmission_clutch_5_pressure: 0x83260000
    readonly property double transmission_clutch_6_pressure: 0x83270000
    readonly property double transmission_clutch_7_pressure: 0x83280000
    readonly property double transmission_clutch_8_pressure: 0x83290000

    readonly property double transmission_shift_n_r: 0x83600000
    readonly property double transmission_shift_n_1: 0x83610000
    readonly property double transmission_shift_1_2: 0x83620000
    readonly property double transmission_shift_2_3: 0x83630000
    readonly property double transmission_shift_3_4: 0x83640000
    readonly property double transmission_shift_4_5: 0x83650000
    readonly property double transmission_shift_5_6: 0x83660000
    readonly property double transmission_shift_6_7: 0x83670000
    readonly property double transmission_shift_7_8: 0x83680000

    readonly property double transmission_shift_r_n: 0x83700000
    readonly property double transmission_shift_1_n: 0x83710000
    readonly property double transmission_shift_2_1: 0x83720000
    readonly property double transmission_shift_3_2: 0x83730000
    readonly property double transmission_shift_4_3: 0x83740000
    readonly property double transmission_shift_5_4: 0x83750000
    readonly property double transmission_shift_6_5: 0x83760000
    readonly property double transmission_shift_7_6: 0x83770000
    readonly property double transmission_shift_8_7: 0x83780000

    readonly property double transmission_gear_r: 0x83800000
    readonly property double transmission_gear_n: 0x83810000
    readonly property double transmission_gear_1: 0x83820000
    readonly property double transmission_gear_2: 0x83830000
    readonly property double transmission_gear_3: 0x83840000
    readonly property double transmission_gear_4: 0x83850000
    readonly property double transmission_gear_5: 0x83860000
    readonly property double transmission_gear_6: 0x83870000
    readonly property double transmission_gear_7: 0x83880000
    readonly property double transmission_gear_8: 0x83890000

    readonly property double transmission_main_pressure_sensor_voltage: 0x83300000

    // 0400 starts shift adjustments..
    readonly property double reverse_lockout_speed: 0x04100000

    readonly property double shift_speed_adjust_a: 0x04200000
    readonly property double shift_downshift_offset_a: 0x04210000
    readonly property double shift_manual_mode_a: 0x04220000
    readonly property double shift_max_engine_speed_a: 0x04230000
    readonly property double shift_tables_a_up_1: 0x04240000
    readonly property double shift_tables_a_up_2: 0x04250000
    readonly property double shift_tables_a_up_3: 0x04260000
    readonly property double shift_tables_a_up_4: 0x04270000
    readonly property double shift_tables_a_up_5: 0x04280000
    readonly property double shift_tables_a_down_locked: 0x042f0000

    readonly property double shift_downshift_offset_b: 0x04400000
    readonly property double shift_manual_mode_b: 0x04410000
    readonly property double shift_speed_adjust_b: 0x04420000
    readonly property double shift_max_engine_speed_b: 0x04430000
    readonly property double shift_tables_b_up_1: 0x04440000
    readonly property double shift_tables_b_up_2: 0x04450000
    readonly property double shift_tables_b_up_3: 0x04460000
    readonly property double shift_tables_b_up_4: 0x04470000
    readonly property double shift_tables_b_up_5: 0x04480000
    readonly property double shift_tables_b_down_locked: 0x044f0000

    readonly property double shift_torque_limit_1_2: 0x04500000
    readonly property double shift_torque_limit_2_3: 0x04510000
    readonly property double shift_torque_limit_3_4: 0x04520000
    readonly property double shift_torque_limit_4_5: 0x04530000
    readonly property double shift_torque_limit_5_6: 0x04540000
    readonly property double shift_torque_limit_6_7: 0x04550000
    readonly property double shift_torque_limit_7_8: 0x04560000

    readonly property double shift_torque_limit_2_1: 0x04600000
    readonly property double shift_torque_limit_3_2: 0x04610000
    readonly property double shift_torque_limit_4_3: 0x04620000
    readonly property double shift_torque_limit_5_4: 0x04630000
    readonly property double shift_torque_limit_6_5: 0x04640000
    readonly property double shift_torque_limit_7_6: 0x04650000
    readonly property double shift_torque_limit_8_7: 0x04660000

    readonly property double shift_torque_limit_garage_shift: 0x04700000

    readonly property double shift_tables_a_down_1: 0x04800000
    readonly property double shift_tables_a_down_2: 0x04810000
    readonly property double shift_tables_a_down_3: 0x04820000
    readonly property double shift_tables_a_down_4: 0x04830000
    readonly property double shift_tables_a_down_5: 0x04840000
    readonly property double shift_tables_b_down_1: 0x04880000
    readonly property double shift_tables_b_down_2: 0x04890000
    readonly property double shift_tables_b_down_3: 0x048a0000
    readonly property double shift_tables_b_down_4: 0x048b0000
    readonly property double shift_tables_b_down_5: 0x048c0000

    // 8400 shift data
    readonly property double shift_current_gear: 0x84000000
    readonly property double shift_selected_gear: 0x84010000
    readonly property double shift_control_mode: 0x84020000
    readonly property double shift_diagnostic_gear: 0x84030000
    readonly property double shift_lowest_possible_gear: 0x84040000
    readonly property double shift_recommended_gear: 0x84050000
    readonly property double shift_highest_possible_gear: 0x84060000
    readonly property double shift_requested_gear: 0x84100000

    readonly property double shift_requested_range: 0x84110000
    readonly property double shift_selected_range: 0x84120000

    // 0500 pressure settings
    readonly property double pressure_control_source: 0x05000000

    readonly property double pressure_adjust_a: 0x05200000
    readonly property double pressure_r2l_boost_a: 0x05210000
    readonly property double pressure_tables_a_1: 0x05220000
    readonly property double pressure_tables_a_2: 0x05230000
    readonly property double pressure_tables_a_3: 0x05240000
    readonly property double pressure_tables_a_4: 0x05250000
    readonly property double pressure_tables_a_5: 0x05260000
    readonly property double pressure_tables_a_6: 0x05270000

    readonly property double pressure_adjust_b: 0x05400000
    readonly property double pressure_r2l_boost_b: 0x05410000
    readonly property double pressure_tables_b_1: 0x05420000
    readonly property double pressure_tables_b_2: 0x05430000
    readonly property double pressure_tables_b_3: 0x05440000
    readonly property double pressure_tables_b_4: 0x05450000
    readonly property double pressure_tables_b_5: 0x05460000
    readonly property double pressure_tables_b_6: 0x05470000

    readonly property double clutch_1_solenoid_pressure: 0x05a00000
    readonly property double clutch_1_solenoid_current: 0x05a10000
    readonly property double clutch_2_solenoid_pressure: 0x05a20000
    readonly property double clutch_2_solenoid_current: 0x05a30000
    readonly property double clutch_3_solenoid_pressure: 0x05a40000
    readonly property double clutch_3_solenoid_current: 0x05a50000
    readonly property double clutch_4_solenoid_pressure: 0x05a60000
    readonly property double clutch_4_solenoid_current: 0x05a70000
    readonly property double clutch_5_solenoid_pressure: 0x05a80000
    readonly property double clutch_5_solenoid_current: 0x05a90000
    readonly property double clutch_6_solenoid_pressure: 0x05aa0000
    readonly property double clutch_6_solenoid_current: 0x05ab0000
    readonly property double clutch_7_solenoid_pressure: 0x05ac0000
    readonly property double clutch_7_solenoid_current: 0x05ad0000
    readonly property double clutch_8_solenoid_pressure: 0x05ae0000
    readonly property double clutch_8_solenoid_current: 0x05af0000

    // 8500 pressure data
    readonly property double pressure_current_percentage: 0x85000000
    readonly property double pressure_selected_percentage: 0x85010000
    readonly property double pressure_diagnostic_percentage: 0x85020000

    // 0600 tcc settings
    readonly property double tcc_downshift_offset_a: 0x06200000
    readonly property double tcc_disable_toss_percent_a: 0x06210000
    readonly property double tcc_enable_gear_a: 0x06220000
    readonly property double tcc_enable_toss_a: 0x06230000
    readonly property double tcc_manual_mode_a: 0x06240000
    readonly property double tcc_max_throttle_a: 0x06250000
    readonly property double tcc_min_throttle_a: 0x06260000
    readonly property double tcc_disable_in_switch_shift_a: 0x06270000


    readonly property double tcc_downshift_offset_b: 0x06400000
    readonly property double tcc_disable_toss_percent_b: 0x06410000
    readonly property double tcc_enable_gear_b: 0x06420000
    readonly property double tcc_enable_toss_b: 0x06430000
    readonly property double tcc_manual_mode_b: 0x06440000
    readonly property double tcc_max_throttle_b: 0x06450000
    readonly property double tcc_min_throttle_b: 0x06460000
    readonly property double tcc_disable_in_switch_shift_b: 0x06470000

    readonly property double tcc_prefill_time: 0x06500000
    readonly property double tcc_apply_time: 0x06510000
    readonly property double tcc_prefill_pressure: 0x06520000
    readonly property double tcc_prefill_percentage: 0x06530000
    readonly property double tcc_max_pressure: 0x06540000
    readonly property double tcc_max_percentage: 0x06550000
    readonly property double tcc_percentage_proportional_constant: 0x06560000
    readonly property double tcc_percentage_integral_constant: 0x06570000
    readonly property double tcc_percentage_derivative_constant: 0x06580000
    readonly property double tcc_pressure_proportional_constant: 0x06590000
    readonly property double tcc_pressure_integral_constant: 0x065a0000
    readonly property double tcc_pressure_derivative_constant: 0x065b0000
    readonly property double tcc_stroke_time: 0x065c0000
    readonly property double tcc_stroke_pressure: 0x065d0000
    readonly property double tcc_stroke_percentage: 0x065e0000

    readonly property double tc_mult_speedratio: 0x06700000
    readonly property double tc_mult_torqueratio: 0x06710000

    // 8600 tcc data
    readonly property double tcc_current_state: 0x86000000
    readonly property double tcc_selected_state: 0x86010000
    readonly property double tcc_control_mode: 0x86020000
    readonly property double tcc_diagnostic_tcc: 0x86030000

    // 0700 engine settings
    readonly property double engine_cylinders: 0x07000000

    readonly property double engine_running_detection_speed: 0x07010000
    readonly property double engine_max_torque: 0x07020000

    readonly property double engine_map_torque_proportion: 0x07050000

    readonly property double voltage_tps_ground_enable: 0x07100000
    readonly property double voltage_tps_is_reversed: 0x07110000
    readonly property double voltage_tps_calibration_low: 0x07120000
    readonly property double voltage_tps_calibration_high: 0x07130000
    readonly property double voltage_tps_filter_order: 0x07140000

    readonly property double voltage_map_sensor_ground_enable: 0x07200000
    readonly property double voltage_map_sensor_low_calibration: 0x07220000
    readonly property double voltage_map_sensor_high_calibration: 0x07230000

    readonly property double cs2_engine_temp_bias_enable: 0x07300000

    readonly property double engine_idle_shutdown_time: 0x07400000

    readonly property double engine_motoring_speed: 0x07500000
    readonly property double engine_motoring_max_torque: 0x07510000
    readonly property double engine_braking_speed: 0x07520000
    readonly property double engine_braking_max_torque: 0x07530000

    // 8700 engine data
    readonly property double engine_speed: 0x87000000
    readonly property double engine_torque_mode: 0x87010000
    readonly property double engine_actual_percent_torque: 0x87020000
    readonly property double drivers_demand_percent_torque: 0x87030000
    readonly property double engine_demand_percent_torque: 0x87040000
    readonly property double acceleration_rate_limiting: 0x87050000

    readonly property double engine_throttle_position: 0x87100000
    readonly property double voltage_tps_voltage: 0x87110000

    readonly property double engine_map_percentage: 0x87200000
    readonly property double voltage_map_sensor_voltage: 0x87210000

    readonly property double engine_coolant_temperature: 0x87300000

    readonly property double engine_idle_shutdown_active: 0x87400000
    readonly property double engine_idle_shutdown_timer_active: 0x87410000

    // 0800 transfer case settings
    readonly property double transfer_case_ratios: 0x08000000
    readonly property double transfer_case_ratio: 0x08010000
    readonly property double transfer_case_gear: 0x08020000
    // 8800 transfer case data
    readonly property double transfer_case_input_speed: 0x88000000
    readonly property double transfer_case_output_speed: 0x88010000
    readonly property double transfer_case_temperature: 0x88020000

    // 0900 shift selector settings
    readonly property double shift_selector_gear_voltages: 0x09000000
    readonly property double shift_selector_overdrive_cancel_at_startup: 0x09010000
    // 8900 shift selector data
    readonly property double shift_selector_gear: 0x89000000
    readonly property double shift_selector_sensor_voltage: 0x89010000

    // 0a00 differential settings
    readonly property double final_drive_ratio: 0x0a000000
    // 8a00 differential data
    readonly property double differential_input_speed: 0x8a000000
    readonly property double differential_output_speed: 0x8a010000
    readonly property double differential_temperature: 0x8a020000

    // 0b00 ebus settings
    readonly property double ev_motor_communications: 0x0b000000

    readonly property double ev_torque_filter_order: 0x0b100000
    readonly property double ev_speed_filter_order: 0x0b110000

    readonly property double ev_motor_torque_idle: 0x0b200000
    readonly property double ev_motor_torque_shift: 0x0b210000
    readonly property double ev_motor_speed_max: 0x0b220000

    readonly property double ev_torque_ramp_down_time: 0x0b230000
    readonly property double ev_torque_ramp_up_time: 0x0b240000

    readonly property double ev_motor_torque_max_a: 0x0b300000
    readonly property double ev_regen_torque_max_a: 0x0b310000
    readonly property double ev_max_regen_speed_a: 0x0b320000

    readonly property double ev_motor_torque_max_b: 0x0b400000
    readonly property double ev_regen_torque_max_b: 0x0b410000
    readonly property double ev_max_regen_speed_b: 0x0b420000

    readonly property double ebus_shift_synchronization_tolerance: 0x0b500000
    readonly property double ebus_shift_synchronization_duration: 0x0b510000
    readonly property double clutch_release_time: 0x0b520000
    readonly property double clutch_prefill_time: 0x0b530000
    readonly property double clutch_prefill_pressure: 0x0b540000
    readonly property double clutch_prefill_percentage: 0x0b550000
    readonly property double clutch_stroke_time: 0x0b560000
    readonly property double clutch_stroke_pressure: 0x0b570000

    readonly property double ev_j1939_ctl_source_address: 0x0b600000

    // 8b00 ev data
    readonly property double ev_drive_fault_count: 0x8b000000
    readonly property double ev_drive_last_fault_type: 0x8b010000

    // 0c00 can bus settings
    readonly property double can0_baud_rate: 0x0c000000
    readonly property double can1_baud_rate: 0x0c100000

    readonly property double j1939_transmission_address: 0x0c200000
    readonly property double j1939_engine_address: 0x0c210000
    readonly property double j1939_shift_selector_address: 0x0c220000

    readonly property double xcp_cto_id: 0x0c300000
    readonly property double xcp_dto_id: 0x0c310000

    readonly property double can0_transmit_error_count: 0x8c000000
    readonly property double can0_receive_error_count: 0x8c010000
    readonly property double can0_transmit_count: 0x8c020000
    readonly property double can0_receive_count: 0x8c030000

    readonly property double can1_transmit_error_count: 0x8c100000
    readonly property double can1_receive_error_count: 0x8c110000
    readonly property double can1_transmit_count: 0x8c120000
    readonly property double can1_receive_count: 0x8c130000

    // 0e00 fault system
    readonly property double dtc_active_count: 0x8ee00000
    readonly property double dtc_recorded_count: 0x8e010000
    readonly property double dtc_active_count_by_type: 0x8ee20000
    readonly property double dtc_recorded_count_by_type: 0x8e030000

    // 0f00 control system config
    readonly property double reset_defaults: 0x0f000000
    readonly property double security_code: 0x0f800000
    readonly property double setup_security_code: 0x0f810000
    // 8f00 control system data
    // ab mode
    readonly property double controller_mode: 0x8f000000
    readonly property double diagnostic_mode: 0x8f010000
    readonly property double security_level: 0x8f800000
}
