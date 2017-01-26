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
    property LinearSlot amps: LinearSlot {
        rawA: -1e9
        engrA: -1e9
        rawB: 1e9
        engrB: 1e9
        unit: "A"
        precision: 4
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
    property EncodingSlot bridgeForce: EncodingSlot {
        encodingList: [
            { raw: -1, engr: qsTr("Low") },
            { raw: 0, engr: qsTr("Unforced") },
            { raw: 1, engr: qsTr("High") }
        ]
        storageType: Slot.F32
    }
    property EncodingSlot pwmPercentage: EncodingSlot {
        encodingList: [
            { raw: -1, engr: qsTr("Released") }
        ]
        unencodedSlot: percentage
        unit: "%"
        precision: 2
        storageType: Slot.F32
    }
    property LinearSlot percentage: LinearSlot {
        rawA: 0
        engrA: 0
        rawB: 1
        engrB: 100
        unit: "%"
        precision: 2
        storageType: Slot.F32
    }
}
