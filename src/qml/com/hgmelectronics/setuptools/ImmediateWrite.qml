pragma Singleton
import QtQuick 2.0

QtObject {
    property var keys: []

    signal triggered()

    function trigger(key) {
        keys.push(key)
        triggered()
    }

    function clear() {
        keys = []
    }
}
