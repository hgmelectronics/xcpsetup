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
    property LinearSlot ltcTemp: LinearSlot {
        rawA: 0
        engrA: -273
        rawB: 19200
        engrB: 327
        unit: "degC"
        precision: 2
    }
}
