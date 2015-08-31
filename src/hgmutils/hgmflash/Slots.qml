import QtQuick 2.5
import com.setuptools.xcp 1.0
import com.setuptools 1.0

QtObject {
    readonly property LinearSlot cylinderCount: LinearSlot {
        rawA: 0
        engrA: 0
        rawB: 16
        engrB: 16
        precision: 0
    }

    readonly property LinearSlot percentage1: LinearSlot {
        rawA: 0
        engrA: 0
        rawB: 100
        engrB: 100
        unit: "%"
        precision: 0
    }
    readonly property LinearSlot ratio1: LinearSlot {
        rawA: 0
        engrA: 0
        rawB: 1000000000
        engrB: 10000000
        unit: ":1"
        precision: 2
    }
    readonly property LinearSlot rpm1: LinearSlot {
        rawA: 0
        engrA: 0
        rawB:  1000000000
        engrB: 1000000000
        unit: "rpm"
        precision: 0
    }

    readonly property LinearSlot length: LinearSlot{
        rawA: 0
        engrA: 0
        rawB: 10000
        engrB: 1000
        unit: "cm"
        precision: 1
    }

    readonly property LinearSlot booleanOnOff1: LinearSlot {
        rawA: 0
        engrA: 0
        rawB: 1
        engrB: 1
        unit: ""
        precision: 0
    }

    readonly property EncodingSlot yesNo: EncodingSlot {
        encodingList: [
            {raw: 0, engr: "No"},
            {raw: 1, engr: "Yes"},
        ]
    }

    readonly property EncodingSlot onOff: EncodingSlot {
        encodingList: [
            {raw: 0, engr: "Off"},
            {raw: 1, engr: "On"},
        ]
    }

    readonly property EncodingSlot switchId: EncodingSlot {
        encodingList: [
            {raw: 0, engr: "SG0"},
            {raw: 1, engr: "SG1"},
            {raw: 2, engr: "SG2"},
            {raw: 3, engr: "SG3"},
            {raw: 4, engr: "SG4"},
            {raw: 5, engr: "SG5"},
            {raw: 6, engr: "SG6"},
            {raw: 7, engr: "SG7"},
            {raw: 8, engr: "SG8"},
            {raw: 9, engr: "SG9"},
            {raw: 10, engr: "SG10"},
            {raw: 11, engr: "SG11"},
            {raw: 12, engr: "SG12"},
            {raw: 13, engr: "SG13"},
            {raw: 14, engr: "SP0"},
            {raw: 15, engr: "SP1"},
            {raw: 16, engr: "SP2"},
            {raw: 17, engr: "SP3"},
            {raw: 18, engr: "SP4"},
            {raw: 19, engr: "SP5"},
            {raw: 20, engr: "SP6"},
            {raw: 21, engr: "SP7"},
        ]
    }
}
