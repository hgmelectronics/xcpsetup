import QtQuick 2.5
import com.hgmelectronics.setuptools 1.0
import com.hgmelectronics.setuptools.xcp 1.0

QtObject {
    id: root
    property var roleMapping    // e.g. "x": xArray, "value": valueArray

    property var roleNames: {
        var ret = ([])
        for(var role in roleMapping) {
            if(roleMapping.hasOwnProperty(role)) {
                ret.push(role)
            }
        }
        return ret
    }

    property var keys: {
        var ret = ([])
        for(var role in roleMapping) {
            if(roleMapping.hasOwnProperty(role)
                    && typeof(roleMapping[role].key) !== "undefined")
                ret.push(roleMapping[role].key)
        }
        return ret
    }

    property var model: {
        var ret = ({})
        for(var role in roleMapping) {
            if(roleMapping.hasOwnProperty(role)) {
                if(typeof(roleMapping[role].stringModel) !== "undefined")
                    ret[role] = roleMapping[role].stringModel
                else
                    ret[role] = roleMapping[role]
            }
        }
        return ret
    }

    property bool valid: {
        for(var role in roleMapping) {
            if(roleMapping.hasOwnProperty(role)) {
                if(typeof(roleMapping[role].valid) !== "undefined" && !roleMapping[role].valid)
                    return false
            }
        }
        return true
    }

    property int count: {
        var ret = 0x7FFFFFFF
        for(var role in roleMapping) {
            if(roleMapping.hasOwnProperty(role)) {
                if(typeof(roleMapping[role].count) !== "undefined")
                    ret = Math.min(ret, roleMapping[role].count)
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
