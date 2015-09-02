import QtQuick 2.0
import com.setuptools.xcp 1.0
import com.setuptools 1.0

Item {
    property LinearSlot raw32: LinearSlot {
        rawA: 0
        engrA: 0
        rawB: 0xFFFFFFFF
        engrB: 0xFFFFFFFF
        unit: ""
        precision: 0
    }
    property LinearSlot ltcCellv: LinearSlot {
        rawA: 0
        engrA: 0
        rawB: 55000
        engrB: 5.5
        unit: "V"
        precision: 4
    }
    property LinearSlot ltcTemp: LinearSlot {
        rawA: 0
        engrA: -273
        rawB: 19200
        engrB: 327
        unit: "degC"
        precision: 2
    }
}
