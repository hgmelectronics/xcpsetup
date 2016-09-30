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
    property LinearSlot rawu32: LinearSlot {
        rawA: 0
        engrA: 0
        rawB: 0xFFFFFFFF
        engrB: 0xFFFFFFFF
        unit: ""
        precision: 0
    }
    property LinearSlot bool01: LinearSlot {
        rawA: 0
        engrA: 0
        rawB: 1
        engrB: 1
        unit: ""
        precision: 0
    }
    property LinearSlot raw32hex: LinearSlot {
        rawA: -0x7FFFFFFF
        engrA: -0x7FFFFFFF
        rawB: 0x7FFFFFFF
        engrB: 0x7FFFFFFF
        unit: ""
        precision: 0
        base: 16
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
    property LinearSlot saeTp02: LinearSlot {
        rawA: 0
        engrA: -273
        rawB: 19200
        engrB: 327
        unit: "degC"
        precision: 2
    }
    property LinearSlot saeEv01: LinearSlot {
        rawA: 0
        engrA: 0
        rawB: 64255
        engrB: 3212.75
        unit: "V"
        precision: 2
    }
    property LinearSlot voltage1: LinearSlot {
        rawA: -64255
        engrA: -3212.75
        rawB: 64255
        engrB: 3212.75
        unit: "V"
        precision: 2
    }
    property LinearSlot millivolts: LinearSlot {
        rawA: -1e9
        engrA: -1e6
        rawB: 1e9
        engrB: 1e6
        unit: "V"
        precision: 3
    }
    property LinearSlot saeEv04: LinearSlot {
        rawA: 0
        engrA: -1606
        rawB: 64255
        engrB: 1606.75
        unit: "V"
        precision: 2
    }
    property LinearSlot saeEc01: LinearSlot {
        rawA: 0
        engrA: -1600
        rawB: 64255
        engrB: 1612.75
        unit: "A"
        precision: 2
    }
    property LinearSlot saeEc05: LinearSlot {
        rawA: 0
        engrA: 0
        rawB: 64255
        engrB: 3212.75
        unit: "A"
        precision: 2
    }
    property LinearSlot saeEc05Signed: LinearSlot {
        rawA: -64255
        engrA: -3212.75
        rawB: 64255
        engrB: 3212.75
        unit: "A"
        precision: 2
    }
    property LinearSlot hallScale: LinearSlot {
        rawA: 0
        engrA: 0
        rawB: 64255
        engrB: 3212.75
        unit: "A/V"
        precision: 2
    }
    property LinearSlot current1: LinearSlot {
        rawA: -64255
        engrA: -3212.75
        rawB: 64255
        engrB: 3212.75
        unit: "A"
        precision: 2
    }
    property LinearSlot yaskawaBusVolts: LinearSlot {
        rawA: 0
        engrA: 0
        rawB: 64255
        engrB: 64255
        unit: "V"
        precision: 0
    }
    property LinearSlot yaskawaAnalogVolts: LinearSlot {
        rawA: -1e9
        engrA: -1e7
        rawB: 1e9
        engrB: 1e7
        unit: "V"
        precision: 2
    }
    property EncodingSlot invMode: EncodingSlot {
        encodingList: [
            { raw: 0, engr: qsTr("Coast") },
            { raw: 1, engr: qsTr("Speed") },
            { raw: 2, engr: qsTr("Torque") },
            { raw: 3, engr: qsTr("Fault Reset") }
        ]
    }
    property EncodingSlot invState: EncodingSlot {
        encodingList: [
            { raw: 0, engr: qsTr("Coast") },
            { raw: 1, engr: qsTr("Speed") },
            { raw: 2, engr: qsTr("Torque") },
            { raw: 3, engr: qsTr("Drive Fault") },
            { raw: 4, engr: qsTr("MODBUS Fault") },
            { raw: 5, engr: qsTr("Improper Torque Ref") },
            { raw: 6, engr: qsTr("A1 Readback Fault") },
            { raw: 7, engr: qsTr("A2 Readback Fault") },
            { raw: 8, engr: qsTr("S1 Readback Fault") },
            { raw: 9, engr: qsTr("S2 Readback Fault") },
            { raw: 10, engr: qsTr("S3 Readback Fault") },
            { raw: 11, engr: qsTr("S4 Readback Fault") },
            { raw: 12, engr: qsTr("Speed Readback Fault") },
            { raw: 13, engr: qsTr("Torque Readback Fault") },
            { raw: 14, engr: qsTr("Current Regulation Fault") },
            { raw: 15, engr: qsTr("Motor Overtemp") }
        ]
    }
    property EncodingSlot modbusPduResult: EncodingSlot {
        encodingList: [
            { raw: 0, engr: qsTr("Complete") },
            { raw: 1, engr: qsTr("Busy") },
            { raw: 2, engr: qsTr("Timeout") },
            { raw: 3, engr: qsTr("CRC Error") },
            { raw: 4, engr: qsTr("Wrong Slave ID") },
            { raw: 5, engr: qsTr("Unexpected Reply") },
            { raw: 6, engr: qsTr("Function Exception") },
            { raw: 7, engr: qsTr("Address Exception") },
            { raw: 8, engr: qsTr("Value Exception") },
            { raw: 9, engr: qsTr("Slave Failure") },
            { raw: 10, engr: qsTr("Unknown Exception") }
        ]
    }
    property LinearSlot conductance1: LinearSlot {
        rawA: 0
        engrA: 0
        rawB: 0x7FFFFFFE
        engrB: 0x7FFFFFFE/1000.0
        unit: "uS"
        precision: 3
    }
    property LinearSlot saePc01: LinearSlot {
        rawA: 0
        engrA: 0
        rawB: 64255
        engrB: 160.6375
        unit: "%"
        precision: 3
    }
    property LinearSlot saePc05: LinearSlot {
        rawA: 0
        engrA: -125
        rawB: 250
        engrB: 125
        unit: "%"
        precision: 0
    }
    property LinearSlot saePc06Ext: LinearSlot {
        rawA: -1E9
        engrA: -1E9
        rawB: 1E9
        engrB: 1E9
        unit: "%"
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
    property LinearSlot timeCycle: LinearSlot {
        rawA: -1E9
        engrA: -1E7
        rawB: 1E9
        engrB: 1E7
        unit: "s"
        precision: 2
    }
    property LinearSlot ytbAiVolts: LinearSlot {
        rawA: 0
        engrA: 0
        rawB: 65536
        engrB: 2.5
        unit: "V"
        precision: 3
    }
    property LinearSlot ytbAoVolts: LinearSlot {
        rawA: 0
        engrA: 0
        rawB: 65520
        engrB: 2.5
        unit: "V"
        precision: 3
    }
    property LinearSlot rpm1: LinearSlot {
        rawA: 0
        engrA: 0
        rawB: 64255
        engrB: 64255
        unit: "rpm"
        precision: 0
    }
    property LinearSlot rpm1Signed: LinearSlot {
        rawA: -64255
        engrA: -64255
        rawB: 64255
        engrB: 64255
        unit: "rpm"
        precision: 0
    }
    property LinearSlot signedDeciPercent: LinearSlot {
        rawA: -1E9
        engrA: -1E8
        rawB: 1E9
        engrB: 1E8
        unit: "%"
        precision: 1
    }
    property EncodingSlot thermistorCurve: EncodingSlot {
        encodingList: [
            { raw: 0, engr: "Thermistor J" },
            { raw: 1, engr: "Thermistor G" }
        ]
    }
    property LinearSlot torque1: LinearSlot {
        rawA: -1E9
        engrA: -1E9
        rawB: 1E9
        engrB: 1E9
        unit: "Nm"
        precision: 0
    }
    property LinearSlot motorCurrRegPropCoeff: LinearSlot {
        rawA: -65536
        engrA: -100
        rawB: 65536
        engrB: 100
        unit: "%"
        precision: 3
    }
    property LinearSlot motorCurrRegIntCoeff: LinearSlot {
        rawA: -65536
        engrA: -1000
        rawB: 65536
        engrB: 1000
        unit: "%/s"
        precision: 2
    }
}
