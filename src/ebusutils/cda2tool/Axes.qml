import QtQuick 2.0
import com.hgmelectronics.setuptools.xcp 1.0
import com.hgmelectronics.setuptools 1.0

Item {
    property LinearTableAxis cellV: LinearTableAxis {
        min: 0
        max: 255
        size: 256
        xUnit: ""
    }
    property LinearTableAxis tabTemp: LinearTableAxis {
        min: 0
        max: 287
        size: 288
        xUnit: ""
    }
    property LinearTableAxis cbtmId: LinearTableAxis {
        min: 0
        max: 31
        size: 32
        xUnit: ""
    }
    property LinearTableAxis ctcNum: LinearTableAxis {
        min: 0
        max: 3
        size: 4
        xUnit: "#"
    }
}
