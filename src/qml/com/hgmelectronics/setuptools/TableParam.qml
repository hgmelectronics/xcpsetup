import QtQuick 2.0
import com.hgmelectronics.setuptools 1.0
import com.hgmelectronics.setuptools.xcp 1.0

QtObject {
    property var x
    property var value

    property TableMapperModel stringModel: TableMapperModel {
        mapping: {
            "x": (typeof x.stringModel !== "undefined") ? x.stringModel : x,
            "value": value.stringModel
        }
    }
}
