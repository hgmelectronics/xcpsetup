import QtQuick 2.0
import com.hgmelectronics.setuptools 1.0
import com.hgmelectronics.setuptools.xcp 1.0

MultiroleTableParam {
    property var x
    property var value
    property var xModel: model["x"]
    property var valueModel: model["value"]

    roleMapping: {
        "x": x,
        "value": value
    }
}
