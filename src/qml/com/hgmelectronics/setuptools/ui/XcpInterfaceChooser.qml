import QtQuick 2.5
import QtQuick.Controls 1.4
import com.hgmelectronics.setuptools.xcp 1.0

GroupBox {
    title: "Interface"
    property string uri
    property bool allowUpdate: enabled

    function setIndexByUri(newUri) {
        //console.log("setIndexByUri: begins with", newUri)
        var i = 0
        while(1) {
            if(i >= registry.rowCount()) {
                //console.log("setIndexByUri: Ran out of entries")
                comboBox.currentIndex = -1
                break
            }
            else if(newUri == registry.uri(i)) {
                //console.log("setIndexByUri: Found index", i)
                comboBox.currentIndex = i
                break
            }
            //console.log("setIndexByUri: Non-matching entry", registry.uri(i))
            ++i
        }
    }

    onUriChanged: {
         setIndexByUri(uri)
    }

    InterfaceRegistry {
        id: registry
    }

    ComboBox {
        id: comboBox

        anchors.fill: parent
        model: registry
        textRole: "display"
        visible: true

        onCurrentIndexChanged: {
            if(count > 0 && currentIndex < count)
                uri = registry.uri(currentIndex)
        }

        Connections {
            target: registry
            onDataChanged: {
                if(comboBox.currentIndex >= registry.rowCount() || comboBox.currentIndex < 0) {
                    //console.log("onDataChanged: Index out of range")
                    comboBox.currentIndex = -1
                }
                else if(registry.uri(comboBox.currentIndex) != uri) {
                    //console.log("onDataChanged: URI mismatched")
                    setIndexByUri(uri)
                }
            }
        }

        MouseArea {
            anchors.fill: parent
            propagateComposedEvents: true

            onPressed: {
                mouse.accepted = false
                if(allowUpdate)
                    registry.updateAvail()
            }
            onReleased: mouse.accepted = false
            onDoubleClicked: mouse.accepted = false
            onPositionChanged: mouse.accepted = false
            onPressAndHold: mouse.accepted = false
            onClicked: mouse.accepted = false
        }
    }
}
