import QtQuick 2.5
import QtQuick.Controls 1.4
import QtQuick.Layouts 1.1
import com.hgmelectronics.setuptools.xcp 1.0

GroupBox {
    title: "Interface"
    property string uri

    property Action updateAvail: Action {
        text: qsTr("Update");
        tooltip: qsTr("Update available interfaces");

        onTriggered: registry.updateAvail()
    }

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

    RowLayout {
        anchors.fill: parent
        ComboBox {
            id: comboBox

            Layout.fillWidth: true

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
        }

        Button {
            action: updateAvail
        }

        InterfaceRegistry {
            id: registry
        }
    }
}
