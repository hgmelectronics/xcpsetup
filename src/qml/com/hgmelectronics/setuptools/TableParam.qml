import QtQuick 2.0
import com.hgmelectronics.setuptools 1.0
import com.hgmelectronics.setuptools.xcp 1.0

QtObject {
    id: root
    property var x
    property var value
    property var xModel: (typeof x.stringModel !== "undefined") ? x.stringModel : x
    property var valueModel: (typeof value.stringModel !== "undefined") ? value.stringModel : value
    property bool valid: ((typeof x.valid !== "undefined") ? x.valid : true) && ((typeof value.valid !== "undefined") ? value.valid : true)

    signal downloadDone(OpResult result)

    property TableMapperModel stringModel: TableMapperModel {
        mapping: {
            "x": xModel,
            "value": valueModel
        }
    }

    property Connections xDownloadDoneConnection: Connections {
        target: (typeof x.downloadDone !== "undefined") ? x : null
        onDownloadDone: root.downloadDone(result)
    }

    property Connections valueDownloadDoneConnection: Connections {
        target: (typeof value.downloadDone !== "undefined") ? value : null
        onDownloadDone: root.downloadDone(result)
    }

    Component.onCompleted: {
        console.assert(xModel.count === valueModel.count, "TableParam instantiated with mismatched row counts", xModel.count, "and", valueModel.count)
    }
}
