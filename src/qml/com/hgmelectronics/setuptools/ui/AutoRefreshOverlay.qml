import QtQuick 2.0
import com.hgmelectronics.setuptools 1.0

Rectangle {
    id: root

    property color selectedColor: "#20FF0000"
    property bool selected: false
    property string key
    radius: 2

    anchors.fill: parent
    color: selected ? selectedColor : "transparent"
    MouseArea {
        anchors.fill: parent
        propagateComposedEvents: true

        onPressed: {
            if(!AutoRefreshSelector.selectMode)
                mouse.accepted = false
        }
        onReleased: mouse.accepted = false
        onDoubleClicked: mouse.accepted = false
        onPositionChanged: mouse.accepted = false
        onPressAndHold: mouse.accepted = false
        onClicked: {
            if(AutoRefreshSelector.selectMode)
                AutoRefreshSelector.toggleKey(key)
            else
                mouse.accepted = false
        }
    }

    function setSelected(on) {
        if(!enabled) {
            if(on)
                AutoRefreshSelector.addKey(key)
            else
                AutoRefreshSelector.removeKey(key)
        }
    }

    function selectedFromSelector() {
        selected = AutoRefreshSelector.keySelected(key)
    }
    function updateSelectorConnection() {
        if(enabled)
            AutoRefreshSelector.keyChange.connect(selectedFromSelector)
        else
            AutoRefreshSelector.keyChange.disconnect(selectedFromSelector)
    }

    Component.onCompleted: updateSelectorConnection()

    onEnabledChanged: {
        updateSelectorConnection()
        if(!enabled)
            AutoRefreshSelector.removeKey(key)
    }
}

