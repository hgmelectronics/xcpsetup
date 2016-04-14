import QtQuick 2.5
import com.hgmelectronics.setuptools.xcp 1.0
import com.hgmelectronics.setuptools 1.0

QtObject {
    property bool useMetricUnits: true
    property double finalDriveRatio: NAN
    property double tireDiameter: NAN   // cm or inches depending on useMetricUnits

    property var zeroIsDisabledEncoding: [
        { raw: 0, engr: "Disabled"}
    ]

    property EncodingSlot abMode: EncodingSlot {
        encodingList: [
            { raw: 0, engr: "A"},
            { raw: 1, engr: "B"}
        ]
    }

    property LinearSlot acceleration1: LinearSlot {
        rawA: -1E9
        engrA: -1E7
        rawB: 1E9
        engrB: 1E7
        unit: "m/s^2"
        precision: 2
    }

    property EncodingSlot xyzIndex: EncodingSlot {
        encodingList: [
            { raw: 0, engr: "X"},
            { raw: 1, engr: "Y"},
            { raw: 2, engr: "Z"}
        ]
    }

    property EncodingSlot booleanManualMode: EncodingSlot {
        encodingList: [
            { raw: 0, engr: "Automatic"},
            { raw: 1, engr: "Manual"}
        ]
    }

    property EncodingSlot booleanOnOffGauge: EncodingSlot {
        encodingList: [
            { raw: 0, engr: "OFF"},
            { raw: 1, engr: "ON"}
        ]
    }

    property EncodingSlot booleanOnOff1: EncodingSlot {
        encodingList: [
            { raw: 0, engr: "Off"},
            { raw: 1, engr: "On"}
        ]
    }

    property EncodingSlot booleanYesNo1: EncodingSlot {
        encodingList: [
            { raw: 0, engr: "No"},
            { raw: 1, engr: "Yes"}
        ]
    }

    property LinearSlot count2: LinearSlot {
        rawA: 0
        engrA: 0
        rawB: 99
        engrB: 99
    }

    property LinearSlot count3: LinearSlot {
        rawA: 0
        engrA: 0
        rawB: 999
        engrB: 999
    }

    property LinearSlot countByte: LinearSlot {
        rawA: 0
        engrA: 0
        rawB: 255
        engrB: 255
    }

    property LinearSlot count4: LinearSlot {
        rawA: 0
        engrA: 0
        rawB: 9999
        engrB: 9999
    }

    property LinearSlot count: LinearSlot {
        rawA: 0
        engrA: 0
        rawB: 65535
        engrB: 65535
    }

    property LinearSlot clutchId: LinearSlot {
        rawA: 0
        engrA: 1
        rawB: 8
        engrB: 9
    }

    property LinearSlot pwmDriverId: LinearSlot {
        rawA: 0
        engrA: 1
        rawB: 98
        engrB: 99
    }

    property EncodingSlot colorIndex: EncodingSlot {
        encodingList: [
            { raw: 0, engr: "Red"},
            { raw: 1, engr: "Green"},
            { raw: 2, engr: "Blue"}
        ]
    }

    property EncodingSlot dtcType: EncodingSlot {
        encodingList: [
            { raw: 0, engr: "Fail safe"},
            { raw: 1, engr: "Stop"},
            { raw: 2, engr: "Warn"},
            { raw: 3, engr: "Protect" }
        ]
    }

    property EncodingSlot evDriveFault: EncodingSlot {
        encodingList: [
            { raw: 0, engr: "None"},
            { raw: 1, engr: "Reply timeout"},
            { raw: 2, engr: "Character timeout"},
            { raw: 3, engr: "CRC error" },
            { raw: 4, engr: "MODBUS exception" },
            { raw: 5, engr: "Unspecified" }
        ]
    }

    property EncodingSlot failureModeIndicator: EncodingSlot {
        encodingList: [
            { raw: 0, engr: "Above normal"},
            { raw: 1, engr: "Below normal"},
            { raw: 2, engr: "Intermittent"},
            { raw: 3, engr: "Voltage too high" },
            { raw: 4, engr: "Voltage too low" },
            { raw: 5, engr: "Current too low" },
            { raw: 6, engr: "Current too high" },
            { raw: 7, engr: "Not responding" },
            { raw: 8, engr: "Abnormal timing" },
            { raw: 9, engr: "Abnormal update rate" },
            { raw: 10, engr: "Abnormal change rate" },
            { raw: 11, engr: "Unknown fault" },
            { raw: 12, engr: "Bad component" },
            { raw: 13, engr: "Not calibrated" },
            { raw: 14, engr: "Service required" },
            { raw: 15, engr: "Above normal (L)" },
            { raw: 16, engr: "Above normal (M)" },
            { raw: 17, engr: "Below normal (L)" },
            { raw: 18, engr: "Below normal (M)" },
            { raw: 19, engr: "Network data " },
            { raw: 20, engr: "Drifted high" },
            { raw: 21, engr: "Drifted low" },
            { raw: 31, engr: "Fault" }
        ]
    }



    property EncodingSlot gear1: EncodingSlot {
        encodingList: [
            { raw: 0xFF, engr: "I"},
            { raw: 0xFB, engr: "P"},
            { raw: -1, engr: "R"},
            { raw: 0, engr: "N"}
        ]
        unencodedSlot: LinearSlot {
            rawA: 0
            engrA: 0
            rawB: 99
            engrB: 99
        }
    }

    property LinearSlot oneDigitOffsetBy1: LinearSlot {
        rawA: 0
        engrA: 1
        rawB: 9
        engrB: 10
    }

    property LinearSlot hex8bit: LinearSlot {
        rawA: 0
        engrA: 0
        rawB: 0xFF
        engrB: 0xFF
        base: 16
    }

    property LinearSlot hex16bit: LinearSlot {
        rawA: 0
        engrA: 0
        rawB: 0xFFFF
        engrB: 0xFFFF
        base: 16
    }

    property LinearSlot hex32bit: LinearSlot {
        rawA: 0
        engrA: 0
        rawB: 0xFFFFFFFF
        engrB: 0xFFFFFFFF
        base: 16
    }

    property EncodingSlot hgmShiftSelectorCalibrationGear: EncodingSlot {
        encodingList: [
            { raw: 0, engr: "P"},
            { raw: 1, engr: "R"},
            { raw: 2, engr: "N"}
        ]
        unencodedSlot: LinearSlot {
            rawA: 3
            engrA: 1
            rawB: 10
            engrB: 8
        }
    }

    property EncodingSlot hgmShiftSelectorCalibrationSensorVoltage: EncodingSlot {
        encodingList: zeroIsDisabledEncoding
        unencodedSlot: LinearSlot {
            rawA: 0
            engrA: 0
            rawB: 9999
            engrB: 9.999
            precision: 3
            unit: ":1"
        }
        unit: ":1"
    }

    property LinearSlot kiloBaud: LinearSlot {
        rawA: 0
        engrA: 0
        rawB: 9999
        engrB: 9999
        unit: "Kb"
    }

    property EncodingSlot canSpeed: EncodingSlot {
        encodingList: [
            { raw: 125, engr: "125"},
            { raw: 250, engr: "250"},
            { raw: 500, engr: "500"},
            { raw: 1000, engr: "1000"}
        ]
        unit: "kbps"
    }

    property EncodingSlot measurementSystem: EncodingSlot {
        encodingList: [
            { raw: 0, engr: "US"},
            { raw: 1, engr: "Metric"}
        ]
    }

    property LinearSlot pressureTableAxis: LinearSlot {
        rawA: 0
        engrA: 0
        rawB: 10
        engrB: 100
        unit: "%"
    }

    property LinearSlot percentage1: LinearSlot {
        rawA: 0
        engrA: 0
        rawB: 100
        engrB: 100
        unit: "%"
        precision: 0
    }

    property LinearSlot percentage2: LinearSlot {
        rawA: 0
        engrA: 0
        rawB: 1000
        engrB: 100
        unit: "%"
        precision: 1
    }

    property LinearSlot percentage3: LinearSlot {
        rawA: 0
        engrA: 0
        rawB: 10
        engrB: 100
        unit: "%"
    }

    property LinearSlot percentage1Gauge: LinearSlot {
        rawA: 0
        engrA: 0
        rawB: 100
        engrB: 100
        unit: "%"
        precision: 0
    }

    property LinearSlot percentage2Gauge: LinearSlot {
        rawA: 0
        engrA: 0
        rawB: 1000
        engrB: 100
        unit: "%"
        precision: 0
    }

    property EncodingSlot pwmDriverMode: EncodingSlot {
        encodingList: [
            { raw: 0, engr: "Low side"},
            { raw: 1, engr: "High side"},
            { raw: 2, engr: "Both"}
        ]
    }

    property EncodingSlot speedoCalibration: EncodingSlot {
        encodingList: zeroIsDisabledEncoding
        unencodedSlot: LinearSlot {
            rawA: 0
            engrA: 0
            rawB: 1E9
            engrB: 1E7
            unit: ": 1"
            precision: 2
        }
    }

    property LinearSlot ratio1: LinearSlot {
        rawA: 0
        engrA: 0
        rawB: 1E9
        engrB: 1E7
        unit: ": 1"
        precision: 2
    }

    property LinearSlot ratioGauge: LinearSlot {
        rawA: 0
        engrA: 0
        rawB: 1E9
        engrB: 1E7
        precision: 2
    }

    property LinearSlot frequency: LinearSlot {
        rawA:0
        engrA: 0
        rawB: 1E9
        engrB: 1E8
        precision: 1
        unit: "Hz"
    }

    property EncodingSlot resetDefaults: EncodingSlot {
        encodingList: [
            { raw: 0, engr: "Factory" },
            { raw: 1, engr: "Transmission" },
            { raw: 2, engr: "Disabled" }
        ]
    }

    property LinearSlot rpm1: LinearSlot {
        rawA: 0
        engrA: 0
        rawB:  1E9
        engrB: 1E9
        unit: "RPM"
        precision: 0
    }

    property LinearSlot rpmGauge: LinearSlot {
        rawA: 0
        engrA: 0
        rawB:  1E9
        engrB: 1E9
        precision: 0
    }

    property EncodingSlot securityCode: EncodingSlot {
        encodingList: zeroIsDisabledEncoding
        unencodedSlot: LinearSlot {
            rawA: 0
            engrA: 0
            rawB: 0xFFFF
            engrB: 0xFFFF
            base: 16
        }
    }

    property EncodingSlot switchId: EncodingSlot {
        encodingList: [
            {raw: 0, engr: "SG0/Shift Lever 1"},
            {raw: 1, engr: "SG1/Shift Lever 2"},
            {raw: 2, engr: "SG2/Shift Lever 3"},
            {raw: 3, engr: "SG3/Shift Lever 4"},
            {raw: 4, engr: "SG4/Shift Lever 5"},
            {raw: 5, engr: "SG5/Neutral Switch"},
            {raw: 6, engr: "SG6/Reverse Switch"},
            {raw: 7, engr: "SG7/Transfer Case 1"},
            {raw: 8, engr: "SG8/Transfer Case 2"},
            {raw: 9, engr: "SG9/Mode LED 1"},
            {raw: 10, engr: "SG10/Mode LED 2"},
            {raw: 11, engr: "SG11/OD Cancel LED"},
            {raw: 12, engr: "SG12/Pressure Sensor"},
            {raw: 13, engr: "SG13/TCC LED"},
            {raw: 14, engr: "SP0/A-B Mode Switch"},
            {raw: 15, engr: "SP1/Mode 1 Switch"},
            {raw: 16, engr: "SP2/Mode 2 Switch"},
            {raw: 17, engr: "SP3/OD Cancel Switch"},
            {raw: 18, engr: "SP4/Manual TCC Switch"},
            {raw: 19, engr: "SP5/Shift Up Switch"},
            {raw: 20, engr: "SP6/Shift Down Switch"},
            {raw: 21, engr: "SP7/A-B Mode LED"},
        ]
    }

    property EncodingSlot booleanNormalReversed: EncodingSlot {
        encodingList: [
            { raw: 0, engr: "Normal"},
            { raw: 1, engr: "Reversed"}
        ]
    }

    property EncodingSlot controlMode: EncodingSlot {
        encodingList: [
            { raw: 0, engr: "Manual" },
            { raw: 1, engr: "Auto" },
            { raw: 2, engr: "Switch" },
            { raw: 3, engr: "Diagnostic" },
            { raw: 4, engr: "Fail safe" }
        ]
    }

    property EncodingSlot controlModeGauge: EncodingSlot {
        encodingList: [
            { raw: 0, engr: "M" },
            { raw: 1, engr: "A" },
            { raw: 2, engr: "S" },
            { raw: 3, engr: "D" },
            { raw: 4, engr: "F" }
        ]
    }

    property EncodingSlot torqueSignalSource: EncodingSlot {
        encodingList: [
            { raw: 0, engr: "Throttle" },
            { raw: 1, engr: "MAP" }
        ]
    }

    property EncodingSlot torqueMode: EncodingSlot {
        encodingList: [
            { raw: 0, engr: "Idle Governor" },
            { raw: 1, engr: "Accelerator" },
            { raw: 2, engr: "Cruise Control" },
            { raw: 3, engr: "PTO Governor" },
            { raw: 4, engr: "Road Speed Governor" },
            { raw: 5, engr: "ASR Control" },
            { raw: 6, engr: "Transmission" },
            { raw: 7, engr: "ABS Control" },
            { raw: 8, engr: "Torque Limiting" },
            { raw: 9, engr: "High Speed Governor" },
            { raw: 10, engr: "Braking System" },
            { raw: 11, engr: "Remote Accelerator" },
            { raw: 12, engr: "Service Procedure" },
            { raw: 13, engr: "Not Defined" },
            { raw: 14, engr: "Other" },
            { raw: 15, engr: "Not Available" }
        ]
    }

    property LinearSlot torque: LinearSlot {
        rawA: -1E9
        engrA: useMetricUnits ? -1E9 : -7.37562E8
        rawB: 1E9
        engrB: useMetricUnits ? 1E9 : 7.37562E8
        unit: useMetricUnits ? "Nm" : "ft-lbf"
        precision: 0
    }

    property EncodingSlot transferCaseRangeGauge: EncodingSlot {
        encodingList: [
            { raw: 0, engr: " " },
            { raw: 1, engr: "L" }
        ]
    }

    property EncodingSlot transmissionType1: EncodingSlot {
        encodingList: [
            { raw: 0, engr: "Unknown" },
            { raw: 100, engr: "GM 4L60E" },
            { raw: 101, engr: "GM 4L60E Transaxle" },
            { raw: 102, engr: "GM 4L70 w/IMS" },
            { raw: 105, engr: "GM 4L80E" },
            { raw: 110, engr: "GM 4T65E" },
            { raw: 111, engr: "GM 4T65E w/IMS" },
            { raw: 115, engr: "GM 4T80E" },
            { raw: 116, engr: "GM 4T80E w/IMS" },
            { raw: 200, engr: "Ford 4R100 Non-PWM TCC" },
            { raw: 206, engr: "Ford 4R100 PWM TCC" },
            { raw: 201, engr: "Ford 4R70W Non-PWM TCC" },
            { raw: 207, engr: "Ford 4R70W PWM TCC " },
            { raw: 202, engr: "Ford 4R75W Non-PWM TCC" },
            { raw: 208, engr: "Ford 4R75W PWM TCC" },
            { raw: 203, engr: "Ford AODE Non-PWM TCC" },
            { raw: 209, engr: "Ford AODE PWM TCC" },
            { raw: 204, engr: "Ford E4OD Non-PWM TCC" },
            { raw: 210, engr: "Ford E4OD PWM TCC" },
            { raw: 205, engr: "Ford E4OD Non-PWM TCC RABS" },
            { raw: 211, engr: "Ford E4OD PWM TCC RABS" },
            { raw: 212, engr: "Ford 5R110" },
            { raw: 300, engr: "ZF 4HP24 w/D2 switch" },
            { raw: 301, engr: "ZF 4HP24 w/P38 switch" },
            { raw: 302, engr: "ZF 4HP24 w/HGM Lever Sensor" },
            { raw: 400, engr: "Nissan RE4R03A" },
            { raw: 401, engr: "Nissan RE5R05A" },
            { raw: 500, engr: "Toyota 442F" },
            { raw: 501, engr: "Toyota 442F w/PCS" },
            { raw: 502, engr: "Toyota A340" },
            { raw: 503, engr: "Toyota A341" },
            { raw: 505, engr: "Toyota AB60" },
            { raw: 600, engr: "Allison 3000 Gen 3" },
            { raw: 610, engr: "Ebus MRPCS" },
            { raw: 620, engr: "Ebus SRMCS" },
            { raw: 700, engr: "Dart Machine 3 Speed" },
            { raw: 701, engr: "ZeroTruck / Dart Machine 3 Speed" },
            { raw: 702, engr: "Dart Machine 2 Speed" },
            { raw: 900, engr: "HGM 4L80E 6 Speed" },
            { raw: 1000, engr: "Mercedes W5A330" },
            { raw: 1001, engr: "Mercedes W5A580" },
            { raw: 1100, engr: "PSI A61FM" }
        ]
        unencodedSlot: count
    }

    property EncodingSlot transmissionOilLevelMeasurementStatus: EncodingSlot {
        encodingList: [
            { raw: 0, engr: "Valid" },
            { raw: 1, engr: "Settling" },
            { raw: 2, engr: "Transmission In Gear" },
            { raw: 3, engr: "Transmission Too cold" },
            { raw: 4, engr: "Transmission Oil Too Hot" },
            { raw: 5, engr: "Vehicle Moving" },
            { raw: 6, engr: "Vehicle Not Level" },
            { raw: 7, engr: "Engine Speed Too Low" },
            { raw: 8, engr: "Engine Speed Too High" },
            { raw: 9, engr: "No Request For Reading" },
            { raw: 10, engr: "Not Defined 1" },
            { raw: 11, engr: "Not Defined 2" },
            { raw: 12, engr: "Not Defined 3" },
            { raw: 13, engr: "Invalid Conditions" },
            { raw: 14, engr: "Error" },
            { raw: 15, engr: "Not Available" }
        ]
    }

    property EncodingSlot variationTypes: EncodingSlot {
        encodingList: [
            { raw: 0, engr: "Unknown" },
            { raw: 1, engr: "Gasoline Engine w/sensors" },
            { raw: 2, engr: "High Speed Diesel w/sensors" },
            { raw: 3, engr: "Low Speed Diesel w/sensors" },
            { raw: 4, engr: "J1939 Gasoline Engine" },
            { raw: 5, engr: "J1939 High Speed Diesel" },
            { raw: 6, engr: "J1939 Low Speed Diesel" },
            { raw: 7, engr: "Ford 5L Coyote Crate Engine" },
            { raw: 8, engr: "GMLAN Gasoline Engine" },
            { raw: 9, engr: "GMLAN Diesel Engine" },
            { raw: 10, engr: "Chrysler CANC Gasoline" },
            { raw: 11, engr: "Chrysler CANC Diesel Engine" },
            { raw: 12, engr: "Land Rover Duratorq 2.2L" },
            { raw: 13, engr: "Land Rover Duratorq 2.4L" },
            { raw: 14, engr: "Toyota 1URFE" },
            { raw: 15, engr: "Ebus Yaskawa F7" },
            { raw: 16, engr: "Ebus Yaskawa A1000" },
            { raw: 17, engr: "AEM Series 2 CAN" },
            { raw: 18, engr: "VW GTI MKV" },
            { raw: 19, engr: "Ebus Yaskawa G5" },
            { raw: 20, engr: "Nissan ZD30" }
        ]
        unencodedSlot: count
    }

    property LinearSlot voltage1: LinearSlot {
        rawA: 0
        engrA: 0
        rawB: 1E9
        engrB: 1E6
        precision: 2
        unit: "V"
    }


    property LinearSlot timeMilliseconds1: LinearSlot {
        rawA: 0
        engrA: 0
        rawB: 1E8
        engrB: 1E9
        precision: 0
        unit: "ms"
    }

    property LinearSlot timeSeconds1: LinearSlot {
        rawA: 0
        engrA: 0
        rawB: 1E9
        engrB: 1E7
        precision: 2
        unit: "s"
    }

    property EncodingSlot timeInSecondsZeroIsDisabled: EncodingSlot {
        encodingList: zeroIsDisabledEncoding
        unencodedSlot: LinearSlot {
            rawA: 0
            engrA: 0
            rawB: 1E9
            engrB: 1E7
            precision: 2
        }
    }

    property LinearSlot tempTableIndex1: LinearSlot {
        rawA: 0
        engrA: useMetricUnits ? -50 : -58
        rawB: 10
        engrB: useMetricUnits ? 150 : 302
        unit: useMetricUnits ? "C" : "F"
    }

    property LinearSlot pressure: LinearSlot {
        rawA: 0
        engrA: 0
        rawB: 1E9
        engrB: useMetricUnits ? 1E9 : 1.45037738E8
        unit: useMetricUnits ? "kPA" : "PSI"
        precision: useMetricUnits ? 0 : 1
    }

    property LinearSlot current: LinearSlot {
        rawA: 0
        engrA: 0
        rawB: 1E9
        engrB: 1E9
        unit: "mA"
        precision: 0
    }

    property LinearSlot temperature1: LinearSlot {
        rawA: -2730
        engrA: useMetricUnits ? -273 : -459.4
        rawB: 50000
        engrB: useMetricUnits ? 5000 : 9032
        unit: useMetricUnits ? "C" : "F"
        precision: 1
    }


    property LinearSlot vehicleSpeed: LinearSlot {
        rawA: 0
        engrA: 0
        rawB: 1E9
        engrB: useMetricUnits ? 3.6E7 : 2.23693629E7
        unit: useMetricUnits ? "KPH" : "MPH"
        precision: 1
    }

    property LinearSlot vehicleSpeedGauge: LinearSlot {
        rawA: 0
        engrA: 0
        rawB: 1E9
        engrB: useMetricUnits ? 3.6E7 : 2.23693629E7
        precision: 0
    }

    property LinearSlot mass: LinearSlot {
        rawA: 0
        engrA: 0
        rawB: 1E9
        engrB: useMetricUnits ? 1E9 : 2.20462E9
        unit: useMetricUnits ? "kg" : "lbs"
    }

    property LinearSlot length: LinearSlot {
        rawA: 0
        engrA: 0
        rawB: 1E9
        engrB: useMetricUnits ? 1E8 : 3.937007874E7
        unit: useMetricUnits ? "cm" : "in"
        precision: 1
    }

    // 1e9 RPM, 1 cm tire, 1:1 final drive = 1884955.59 kph
    // 1e9 RPM, 1 in tire, 1:1 final drive = 2974993.04 mph
    property double speedPerTossRpm: (useMetricUnits ? 1.88495559E-03 : 2.97499304E-03) * tireDiameter / finalDriveRatio

    property LinearSlot tossRPMAsSpeed: LinearSlot {
        rawA: 0
        engrA: 0
        rawB: 1E9
        engrB: 1E9 * speedPerTossRpm
        unit: useMetricUnits ? "KPH" : "MPH"
        precision: 1
    }

    property LinearSlot torquePerRpm: LinearSlot {
        rawA: -1E9
        engrA: useMetricUnits ? -1E6 : -7.37562E6
        rawB: 1E9
        engrB: useMetricUnits ? 1E6 : 7.37562E6
        unit: useMetricUnits ? "Nm/RPM" : "ft-lbf/RPM"
        precision: 2
    }

    property LinearSlot percentagePerTorque: LinearSlot {
        rawA: -1E9
        engrA: useMetricUnits ? -1E6 : -1.355818E6
        rawB: 1E9
        engrB: useMetricUnits ? 1E6 : 1.355818E6
        unit: useMetricUnits ? "%/Nm" : "%/ft-lbf"
        precision: 3
    }

    property LinearSlot percentagePerRpmSec: LinearSlot {
        rawA: -1E9
        engrA: -1E8
        rawB: 1E9
        engrB: 1E8
        unit: "%/kRPM-s"
        precision: 1
    }

    property LinearSlot percentagePerRpm: LinearSlot {
        rawA: -1E9
        engrA: -1E6
        rawB: 1E9
        engrB: 1E6
        unit: "%/kRPM"
        precision: 3
    }

    property LinearSlot percentagePerRpmPerSec: LinearSlot {
        rawA: -1E9
        engrA: -1E6
        rawB: 1E9
        engrB: 1E6
        unit: "%/kRPM/s"
        precision: 3
    }

    property LinearSlot pressurePerRpmSec: LinearSlot {
        rawA: -1E9
        engrA: useMetricUnits ? -1E8 : -1.45037738E7
        rawB: 1E9
        engrB: useMetricUnits ? 1E8 : 1.45037738E7
        unit: useMetricUnits ? "kPa/kRPM-s" : "PSI-kRPM/s"
        precision: useMetricUnits ? 1 : 2
    }

    property LinearSlot pressurePerRpm: LinearSlot {
        rawA: -1E9
        engrA: useMetricUnits ? -1E6 : -1.45037738E5
        rawB: 1E9
        engrB: useMetricUnits ? 1E6 : 1.45037738E5
        unit: useMetricUnits ? "kPa/kRPM" : "PSI/kRPM"
        precision: useMetricUnits ? 3 : 4
    }

    property LinearSlot pressurePerRpmPerSec: LinearSlot {
        rawA: -1E9
        engrA: useMetricUnits ? -1E6 : -1.45037738E5
        rawB: 1E9
        engrB: useMetricUnits ? 1E6 : 1.45037738E5
        unit: useMetricUnits ? "kPa/kRPM/s" : "PSI/kRPM/s"
        precision: useMetricUnits ? 3 : 4
    }
}
