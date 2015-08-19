import QtQuick 2.0
import com.setuptools.xcp 1.0
import com.setuptools 1.0

Item {
    property LinearSlot percentage1: percentage1
    LinearSlot {
        id: percentage1
        rawA: 0
        engrA: 0
        rawB: 100
        engrB: 100
    }
}
