import QtQuick 2.5
import com.hgmelectronics.setuptools 1.0
import com.hgmelectronics.setuptools.xcp 1.0

QtObject {
    id: root
    property var roleMapping    // e.g. "x": xArray, "value": valueArray

    property var roleNames: {
        var ret = ([])
        for(var key in roleMapping) {
            if(roleMapping.hasOwnProperty(key)) {
                ret.push(key)
            }
        }
        return ret
    }

    property var model: {
        var ret = ({})
        for(var key in roleMapping) {
            if(roleMapping.hasOwnProperty(key)) {
                if(typeof(roleMapping[key].stringModel) !== "undefined")
                    ret[key] = roleMapping[key].stringModel
                else
                    ret[key] = roleMapping[key]
            }
        }
        return ret
    }

    property bool valid: {
        for(var key in roleMapping) {
            if(roleMapping.hasOwnProperty(key)) {
                if(typeof(roleMapping[key].valid) !== "undefined" && !roleMapping[key].valid)
                    return false
            }
        }
        return true
    }

    property int count: {
        var ret = 0x7FFFFFFF
        for(var key in roleMapping) {
            if(roleMapping.hasOwnProperty(key)) {
                if(typeof(roleMapping[key].count) !== "undefined")
                    ret = Math.min(ret, roleMapping[key].count)
                else
                    ret = 0
            }
        }
        return ret
    }

    signal downloadDone(OpResult result)

    property TableMapperModel stringModel: TableMapperModel {
        mapping: root.model
    }

    property Instantiator downloadDoneConnector: Instantiator {
        model: roleNames
        Connections {
            target: (typeof roleMapping[roleNames[index]].downloadDone !== "undefined") ? roleMapping[roleNames[index]] : null
            onDownloadDone: root.downloadDone(result)
        }
    }

    Component.onCompleted: {
        for(var i = 1; i < roleNames.length; ++i) {
            console.assert(model[roleNames[0]].count === model[roleNames[i]].count, "MultiroleTableParam instantiated with mismatched row counts", model[roleNames[0]].count, "and", model[roleNames[i]].count)
        }
    }
}
