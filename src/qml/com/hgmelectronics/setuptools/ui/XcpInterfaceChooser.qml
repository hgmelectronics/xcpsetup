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
                comboBox.currentIndex = registry.rowCount() > 0 ? 0 : -1
                break
            }
            else if(newUri === registry.uri(i).toString()) {
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
        uri = registry.uri(comboBox.currentIndex).toString()
    }

    RowLayout {
        anchors.fill: parent
        ComboBox {
            id: comboBox

            Layout.fillWidth: true
            currentIndex: -1

            model: registry
            textRole: "display"
            visible: true

            onCurrentIndexChanged: {
                //console.log("onCurrentIndexChanged", currentIndex)
                uri = registry.uri(currentIndex).toString()
            }

            Connections {
                target: registry
                onDataChanged: setIndexByUri(uri)
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
