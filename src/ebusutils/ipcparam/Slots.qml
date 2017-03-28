import QtQuick 2.0
import com.hgmelectronics.setuptools.xcp 1.0
import com.hgmelectronics.setuptools 1.0

Item {
    property LinearSlot raw32: LinearSlot {
        rawA: -0x7FFFFFFF
        engrA: -0x7FFFFFFF
        rawB: 0x7FFFFFFF
        engrB: 0x7FFFFFFF
        unit: ""
        precision: 0
    }
    property LinearSlot rawf32: LinearSlot {
        rawA: -0x7FFFFFFF
        engrA: -0x7FFFFFFF
        rawB: 0x7FFFFFFF
        engrB: 0x7FFFFFFF
        unit: ""
        precision: 3
        storageType: Slot.F32
    }
    property LinearSlot count: LinearSlot {
        rawA: -0x7FFFFFFF
        engrA: -0x7FFFFFFF
        rawB: 0x7FFFFFFF
        engrB: 0x7FFFFFFF
        unit: ""
        precision: 0
        storageType: Slot.F32
    }
    property LinearSlot volts: LinearSlot {
        rawA: -1e9
        engrA: -1e9
        rawB: 1e9
        engrB: 1e9
        unit: "V"
        precision: 4
        storageType: Slot.F32
    }
    property LinearSlot watts: LinearSlot {
        rawA: -1e9
        engrA: -1e9
        rawB: 1e9
        engrB: 1e9
        unit: "W"
        precision: 0
        storageType: Slot.F32
    }
    property LinearSlot coeffVoltsPerAmp: LinearSlot {
        rawA: 0
        engrA: 0
        rawB: 1e9
        engrB: 1e9
        unit: "V/A"
        precision: 5
        storageType: Slot.F32
    }
    property LinearSlot coeffVoltsPerVolt: LinearSlot {
        rawA: 0
        engrA: 0
        rawB: 1e9
        engrB: 1e9
        unit: "V/V"
        precision: 3
        storageType: Slot.F32
    }
    property LinearSlot coeffVoltsPerVoltSec: LinearSlot {
        rawA: 0
        engrA: 0
        rawB: 1e9
        engrB: 1e9
        unit: "V/V-s"
        precision: 3
        storageType: Slot.F32
    }
    property LinearSlot coeffVoltsPerAmpSec: LinearSlot {
        rawA: 0
        engrA: 0
        rawB: 1e9
        engrB: 1e9
        unit: "V/A-s"
        precision: 3
        storageType: Slot.F32
    }
    property LinearSlot milliOhms: LinearSlot {
        rawA: 0
        engrA: 0
        rawB: 1e6
        engrB: 1e9
        unit: "mOhm"
        precision: 3
        storageType: Slot.F32
    }
    property LinearSlot microHenries: LinearSlot {
        rawA: 0
        engrA: 0
        rawB: 1e3
        engrB: 1e9
        unit: "uH"
        precision: 3
        storageType: Slot.F32
    }
    property LinearSlot amps: LinearSlot {
        rawA: -1e9
        engrA: -1e9
        rawB: 1e9
        engrB: 1e9
        unit: "A"
        precision: 4
        storageType: Slot.F32
    }
    property LinearSlot radians: LinearSlot {
        rawA: -1e9
        engrA: -1e9
        rawB: 1e9
        engrB: 1e9
        unit: "rad"
        precision: 4
        storageType: Slot.F32
    }
    property LinearSlot voltAmps: LinearSlot {
        rawA: -1e9
        engrA: -1e9
        rawB: 1e9
        engrB: 1e9
        unit: "VA"
        precision: 0
        storageType: Slot.F32
    }
    property LinearSlot degC: LinearSlot {
        rawA: -1e9
        engrA: -1e9
        rawB: 1e9
        engrB: 1e9
        unit: "C"
        precision: 1
        storageType: Slot.F32
    }
    property LinearSlot aoVolts: LinearSlot {
        rawA: 0
        engrA: 0
        rawB: 65536
        engrB: 2.5
        unit: "V"
        precision: 4
        storageType: Slot.F32
    }
    property LinearSlot bool01: LinearSlot {
        rawA: 0
        engrA: 0
        rawB: 1
        engrB: 1
        unit: ""
        precision: 0
        storageType: Slot.F32
    }
    property LinearSlot timeUsec: LinearSlot {
        rawA: -1e9
        engrA: -1e6
        rawB: 1e9
        engrB: 1e6
        unit: "ms"
        precision: 4
        storageType: Slot.F32
    }
    property LinearSlot timeSecAsUsec: LinearSlot {
        rawA: -1e3
        engrA: -1e9
        rawB: 1e3
        engrB: 1e9
        unit: "us"
        precision: 3
        storageType: Slot.F32
    }
    property LinearSlot freqHz: LinearSlot {
        rawA: 0
        engrA: 0
        rawB: 1e9
        engrB: 1e9
        unit: "Hz"
        precision: 2
        storageType: Slot.F32
    }
    property LinearSlot freqHzSigned: LinearSlot {
        rawA: -1e9
        engrA: -1e9
        rawB: 1e9
        engrB: 1e9
        unit: "Hz"
        precision: 2
        storageType: Slot.F32
    }
    property LinearSlot freqRad: LinearSlot {
        rawA: 0
        engrA: 0
        rawB: 1e9
        engrB: 1e9
        unit: "rad/s"
        precision: 2
        storageType: Slot.F32
    }
    property LinearSlot freqRadSigned: LinearSlot {
        rawA: -1e9
        engrA: -1e9
        rawB: 1e9
        engrB: 1e9
        unit: "rad/s"
        precision: 2
        storageType: Slot.F32
    }
    property LinearSlot rawu32hex: LinearSlot {
        rawA: 0
        engrA: 0
        rawB: 0xFFFFFFFF
        engrB: 0xFFFFFFFF
        unit: ""
        precision: 0
        base: 16
    }
    property EncodingSlot phaseOrder: EncodingSlot {
        encodingList: [
            { raw: 0, engr: qsTr("ABC") },
            { raw: 1, engr: qsTr("CBA") }
        ]
        storageType: Slot.F32
    }
    property EncodingSlot phaseName: EncodingSlot {
        encodingList: [
            { raw: 0, engr: qsTr("A") },
            { raw: 1, engr: qsTr("B") },
            { raw: 2, engr: qsTr("C") }
        ]
        storageType: Slot.F32
    }
    property EncodingSlot bridgeForce: EncodingSlot {
        encodingList: [
            { raw: -1, engr: qsTr("Low") },
            { raw: 0, engr: qsTr("Unforced") },
            { raw: 1, engr: qsTr("High") }
        ]
        storageType: Slot.F32
    }
    property EncodingSlot dcdcState: EncodingSlot {
        encodingList: [
            { raw: 0, engr: qsTr("Init") },
            { raw: 1, engr: qsTr("Idle") },
            { raw: 2, engr: qsTr("SafetyCheck") },
            { raw: 3, engr: qsTr("Stage2Startup") },
            { raw: 4, engr: qsTr("Stage1Startup") },
            { raw: 5, engr: qsTr("CtcClose") },
            { raw: 6, engr: qsTr("Run") },
            { raw: 7, engr: qsTr("Shutdown") },
            { raw: 8, engr: qsTr("Fault") }
        ]
        storageType: Slot.F32
    }
//    property EncodingSlot pwmPercentage: EncodingSlot {
//        encodingList: [
//            { raw: -1, engr: qsTr("Released") }
//        ]
//        unencodedSlot: percentage
//        unit: "%"
//        precision: 2
//        storageType: Slot.F32
//    }
    property LinearSlot percentage: LinearSlot {
        rawA: 0
        engrA: 0
        rawB: 1
        engrB: 100
        unit: "%"
        precision: 2
        storageType: Slot.F32
    }
    property LinearSlot pwmPercentage: LinearSlot {
        rawA: -1
        engrA: -100
        rawB: 1
        engrB: 100
        unit: "%"
        precision: 2
        storageType: Slot.F32
    }
    property LinearSlot signedPercentage: LinearSlot {
        rawA: -1
        engrA: -100
        rawB: 1
        engrB: 100
        unit: "%"
        precision: 2
        storageType: Slot.F32
    }
}
