import QtQuick 2.0
import com.setuptools.xcp 1.0
import com.setuptools 1.0

Item {
    property LinearSlot percentage1: LinearSlot {
        rawA: 0
        engrA: 0
        rawB: 100
        engrB: 100
        unit: "%"
        precision: 0
    }
    property LinearSlot ratio1: LinearSlot {
        rawA: 0
        engrA: 0
        rawB: 1000000000
        engrB: 10000000
        unit: ":1"
        precision: 2
    }
    property LinearSlot rpm1: LinearSlot {
        rawA: 0
        engrA: 0
        rawB: 1000000000
        engrB: 1000000000
        unit: "rpm"
        precision: 0
    }
    property LinearSlot booleanOnOff1: LinearSlot {
        rawA: 0
        engrA: 0
        rawB: 1
        engrB: 1
        unit: ""
        precision: 0
    }

    property EncodingSlot spaceball1: EncodingSlot {
        unencodedSlot: rpm1
        encodingList: [
            {raw: 0, engr: "Stopped"},
            {raw: 299792458, engr: "Lightspeed"},
            {raw: 4000000000, engr: "Ludicrous Speed"}
        ]
    }
}
