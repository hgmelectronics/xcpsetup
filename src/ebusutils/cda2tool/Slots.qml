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
    property LinearSlot ltcCellv: LinearSlot {
        rawA: 0
        engrA: 0
        rawB: 55000
        engrB: 5.5
        unit: "V"
        precision: 4
    }
    property LinearSlot ltcCellvExt: LinearSlot {
        rawA: -55000
        engrA: -5.5
        rawB: 55000
        engrB: 5.5
        unit: "V"
        precision: 4
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
    property LinearSlot current1: LinearSlot {
        rawA: -64255
        engrA: -3212.75
        rawB: 64255
        engrB: 3212.75
        unit: "A"
        precision: 2
    }
    property LinearSlot iaiMvScale: LinearSlot {
        rawA: -32768
        engrA: -512
        rawB: 32768
        engrB: 512
        unit: "mV"
        precision: 2
    }
    property LinearSlot cellProtRes: LinearSlot {
        rawA: 0
        engrA: 0
        rawB: 128000000
        engrB: 1000000
        unit: "mOhm"
        precision: 2
    }
    property EncodingSlot ctcCtrlState: EncodingSlot {
        encodingList: [
            { raw: 0, engr: "Standby" },
            { raw: 1, engr: "Batt Check" },
            { raw: 2, engr: "Ready" },
            { raw: 3, engr: "Run" },
            { raw: 4, engr: "Run Stop" },
            { raw: 5, engr: "Charge" },
            { raw: 6, engr: "Charge Stop" },
            { raw: 7, engr: "Fault Halt" }
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
    property LinearSlot timeSysTick: LinearSlot {
        rawA: -9000000
        engrA: -1000
        rawB: 9000000
        engrB: 1000
        unit: "ms"
        precision: 4
    }
    property LinearSlot timeCycle: LinearSlot {
        rawA: -1E9
        engrA: -1E8
        rawB: 1E9
        engrB: 1E8
        unit: "s"
        precision: 1
    }
    property LinearSlot iaiScaleShunt: LinearSlot {
        rawA: 0
        engrA: 0
        rawB: 10240E6
        engrB: 100E6
        unit: "A/100mV"
        precision: 1
    }
    property EncodingSlot iaiFunc: EncodingSlot {
        encodingList: [
            { raw: 0, engr: "1=hybrid, 2=non-trac aux" }
        ]
    }
    property LinearSlot stAiVolts: LinearSlot {
        rawA: 0
        engrA: 0
        rawB: 4096
        engrB: 5
        unit: "V"
        precision: 3
    }
    property LinearSlot saeVr01: LinearSlot {
        rawA: 0
        engrA: 0
        rawB: 64255
        engrB: 8031.875
        unit: "rpm"
        precision: 1
    }
    property EncodingSlot auxBattCnvtState: EncodingSlot {
        encodingList: [
            { raw: 0, engr: "Disabled" },
            { raw: 1, engr: "Running" },
            { raw: 2, engr: "Overtemp" },
            { raw: 3, engr: "Electronic Fault" }
        ]
    }
    property EncodingSlot auxBattCnvtType: EncodingSlot {
        encodingList: [
            { raw: 0, engr: "US Hybrid" }
        ]
    }
    property EncodingSlot thermistorCurve: EncodingSlot {
        encodingList: [
            { raw: 0, engr: "Thermistor J" },
            { raw: 1, engr: "Thermistor G" }
        ]
    }
    property LinearSlot auxBattFloatCoeff: LinearSlot {
        rawA: -40960
        engrA: -1000
        rawB: 40960
        engrB: 1000
        unit: "mV/degC"
        precision: 2
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
