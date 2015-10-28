import QtQuick 2.0
import QtQuick.Controls 1.4
import com.hgmelectronics.setuptools 1.0

Item {
    property var base: parent

    anchors.fill: parent

    property var autoRefreshOverlays: []

    Menu {
        id: ctxMenu
        title: qsTr("Auto-Refresh")
        MenuItem {
            action: selectAllAutoRefresh
            text: qsTr("Select All for Auto-Refresh")
        }
        MenuItem {
            action: deselectAllAutoRefresh
            text: qsTr("Deselect All for Auto-Refresh")
        }
        MenuItem {
            action: AutoRefreshSelector.modeAction
            text: qsTr("Auto-Refresh Select Mode")
        }
    }

    Action {
        id: selectAllAutoRefresh
        text: qsTr("Select All")
        onTriggered: {
            for(var i = 0; i < autoRefreshOverlays.length; ++i)
                autoRefreshOverlays[i].setSelected(true)
        }
    }

    Action {
        id: deselectAllAutoRefresh
        text: qsTr("Deselect All")
        onTriggered: {
            for(var i = 0; i < autoRefreshOverlays.length; ++i)
                autoRefreshOverlays[i].setSelected(false)
        }
    }

    MouseArea {
        anchors.fill: parent
        acceptedButtons: Qt.RightButton
        onClicked: ctxMenu.popup()
    }

    Component.onCompleted: {
        findAROChildren(base)
    }
    function findAROChildren(obj) {
        if(obj.typeName === "AutoRefreshOverlay")
            autoRefreshOverlays.push(obj)
        else if(typeof(obj.children) !== "undefined") {
            for(var i = 0; i < obj.children.length; ++i)
                findAROChildren(obj.children[i])
        }
    }
}
