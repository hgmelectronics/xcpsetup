import QtQuick 2.0
import com.setuptools.xcp 1.0
import com.setuptools 1.0

Item {
    property LinearTableAxis switchMonitorId: LinearTableAxis {
        min: 1
        max: 22
        size: 22
        xUnit: ""
    }
    property LinearTableAxis percentage1: LinearTableAxis {
        min: 0
        max: 100
        size: 101
        xUnit: "%"
    }
}
