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
    }
    property LinearSlot count: LinearSlot {
        rawA: -0x7FFFFFFF
        engrA: -0x7FFFFFFF
        rawB: 0x7FFFFFFF
        engrB: 0x7FFFFFFF
        unit: ""
        precision: 0
    }
    property LinearSlot aiVolts: LinearSlot {
        rawA: 0
        engrA: 0
        rawB: 65536
        engrB: 2.5
        unit: "V"
        precision: 4
    }
    property LinearSlot aoVolts: LinearSlot {
        rawA: 0
        engrA: 0
        rawB: 65536
        engrB: 2.5
        unit: "V"
        precision: 4
    }
    property LinearSlot bool01: LinearSlot {
        rawA: 0
        engrA: 0
        rawB: 1
        engrB: 1
        unit: ""
        precision: 0
    }
    property LinearSlot timeUsec: LinearSlot {
        rawA: -1e9
        engrA: -1e6
        rawB: 1e9
        engrB: 1e6
        unit: "ms"
        precision: 4
    }
    property LinearSlot freqHz: LinearSlot {
        rawA: 0
        engrA: 0
        rawB: 1e9
        engrB: 1e9
        unit: "Hz"
        precision: 2
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
    }
    property EncodingSlot bridgeForce: EncodingSlot {
        encodingList: [
            { raw: -1, engr: qsTr("Low") },
            { raw: 0, engr: qsTr("Unforced") },
            { raw: 1, engr: qsTr("High") }
        ]
    }
    property EncodingSlot pwmPercentage: EncodingSlot {
        encodingList: [
            { raw: -1, engr: qsTr("Individual") }
        ]
        unencodedSlot: percentage
        unit: "%"
        precision: 2
    }
    property LinearSlot percentage: LinearSlot {
        rawA: 0
        engrA: 0
        rawB: 1
        engrB: 100
        unit: "%"
        precision: 2
    }
}
