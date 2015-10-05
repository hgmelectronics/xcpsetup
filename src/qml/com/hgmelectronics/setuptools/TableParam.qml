import QtQuick 2.0
import com.hgmelectronics.setuptools 1.0
import com.hgmelectronics.setuptools.xcp 1.0

QtObject {
    property var x
    property var value
    property var xModel: (typeof x.stringModel !== "undefined") ? x.stringModel : x
    property var valueModel: (typeof value.stringModel !== "undefined") ? value.stringModel : value
    property bool valid: ((typeof x.valid !== "undefined") ? x.valid : true) && ((typeof value.valid !== "undefined") ? value.valid : true)

    property TableMapperModel stringModel: TableMapperModel {
        mapping: {
            "x": xModel,
            "value": valueModel
        }
    }

    Component.onCompleted: {
        console.assert(xModel.count === valueModel.count, "TableParam instantiated with mismatched row counts", xModel.count, "and", valueModel.count)
    }
}
