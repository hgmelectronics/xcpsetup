pragma Singleton
import QtQuick 2.0
import QtQuick.Controls 1.4

QtObject {
    property var keys: []
    property bool selectMode: false

    signal keyChange()

    function addKey(key) {
        if(keys.indexOf(key) === -1) {
            keys.push(key)
            keyChange()
        }
    }
    function removeKey(key) {
        var index = keys.indexOf(key)
        if(index !== -1) {
            keys.splice(index, 1)
            keyChange()
        }
    }
    function toggleKey(key) {
        var index = keys.indexOf(key)
        if(index === -1) {
            keys.push(key)
            keyChange()
            return true
        }
        else {
            keys.splice(index, 1)
            keyChange()
            return false
        }
    }
    function keySelected(key) {
        return (keys.indexOf(key) !== -1)
    }

    property Action modeAction: Action {
        text: qsTr("Auto-Refresh Select Mode")
        checkable: true
        onToggled: selectMode = checked
    }
}

