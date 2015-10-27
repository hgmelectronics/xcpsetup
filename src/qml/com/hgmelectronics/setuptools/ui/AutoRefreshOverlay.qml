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
            if(AutoRefreshSelector.selectMode) {
                AutoRefreshSelector.toggleKey(key)
                console.log(AutoRefreshSelector.keys)
            }
            else
                mouse.accepted = false
        }
    }
    Connections {
        target: AutoRefreshSelector
        onKeyChange: selected = AutoRefreshSelector.keySelected(key)
    }
}

