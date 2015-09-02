import QtQuick 2.5
import com.setuptools.xcp 1.0
import com.setuptools 1.0

QtObject {
    readonly property LinearTableAxis switchMonitorId: LinearTableAxis {
        min: 0
        max: 21
        size: 22
        xUnit: ""
    }

    readonly property LinearTableAxis percentage1: LinearTableAxis {
        min: 0
        max: 100
        size: 101
        xUnit: "%"
    }
}
