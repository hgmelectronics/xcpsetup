import QtQuick 2.5
import QtQuick.Controls 1.4
import com.hgmelectronics.setuptools.xcp 1.0

GroupBox {
    title: "Interface"
    property alias uri: comboBox.selectedUri
    property bool allowUpdate: enabled

    InterfaceRegistry {
        id: registry
    }

    ComboBox {
        id: comboBox
        property string selectedUri

        enabled: !paramLayer.intfcOk
        anchors.fill: parent
        model: registry
        textRole: "display"
        visible: true
        selectedUri: (count > 0
                      && currentIndex < count) ? registry.uri(currentIndex) : ""

        Connections {
            target: registry
            onDataChanged: {
                if(comboBox.currentIndex >= registry.rowCount())
                    comboBox.currentIndex = -1
            }
        }

        MouseArea {
            anchors.fill: parent
            propagateComposedEvents: true

            onPressed: {
                mouse.accepted = false
                if(allowUpdate) {
                    registry.updateAvail()
                    console.log("registry.updateAvail()")
                }
            }
            onReleased: mouse.accepted = false
            onDoubleClicked: mouse.accepted = false
            onPositionChanged: mouse.accepted = false
            onPressAndHold: mouse.accepted = false
            onClicked: mouse.accepted = false
        }
    }
}
