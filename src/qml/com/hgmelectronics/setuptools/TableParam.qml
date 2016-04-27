import QtQuick 2.0
import com.hgmelectronics.setuptools 1.0
import com.hgmelectronics.setuptools.xcp 1.0

MultiroleTableParam {
    property var x
    property var value
    property var xStringModel: stringModelMapping["x"]
    property var valueStringModel: stringModelMapping["value"]

    roleMapping: {
        "x": x,
        "value": value
    }
}
