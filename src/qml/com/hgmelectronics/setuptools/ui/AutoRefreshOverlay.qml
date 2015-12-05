import QtQuick 2.0
import com.hgmelectronics.setuptools 1.0

Rectangle {
    id: root

    property color selectedColor: "#20FF0000"
    property bool selected: false
    property string key
    property var keys: [key]
    readonly property string typeName: "AutoRefreshOverlay"
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
                setSelected(!isAnySelected())
            else
                mouse.accepted = false
        }
    }

    function setSelected(on) {
        if(enabled) {
            keys.forEach(function(k) {
                if(on)
                    AutoRefreshSelector.addKey(k)
                else
                    AutoRefreshSelector.removeKey(k)
            })
        }
    }

    function selectedFromSelector() {
        selected = isAnySelected()
    }
    function isAnySelected() {
        var isSelected = false
        keys.forEach(function(k) {
            if(AutoRefreshSelector.keySelected(k))
                isSelected = true
        })
        return isSelected
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
            setSelected(false)
    }
}

