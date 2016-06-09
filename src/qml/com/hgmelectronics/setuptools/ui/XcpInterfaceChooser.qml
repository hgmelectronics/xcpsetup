import QtQuick 2.5
import QtQuick.Controls 1.4
import QtQuick.Layouts 1.1
import com.hgmelectronics.setuptools.xcp 1.0

GroupBox {
    title: "Interface"
    property string uri     // URI corresponding to current combobox index. Can't use binding since QML doesn't know that registry data changes require an update.
    property string saveUri // URI saved by QSettings. May be something not available in current registry. If user has not picked an entry from the registry and this one becomes available, it gets set as uri.

    property Action updateAvail: Action {
        text: qsTr("Update");
        tooltip: qsTr("Update available interfaces");

        onTriggered: registry.updateAvail()
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
                uri = registry.uri(comboBox.currentIndex).toString()
            }

            Connections {
                target: registry
                onDataChanged: {
                    setIndexFromUri(saveUri)    // if user previously opened something, try to preserve its index
                    uri = registry.uri(comboBox.currentIndex).toString()
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

    function setIndexFromUri(newUri) {
        var newUriIndex = registry.find(newUri)
        if(newUriIndex >= 0) { // saveUri exists in registry
            comboBox.currentIndex = newUriIndex    // set it as the current index, this will also update uri
        }
        else {
            if(registry.rowCount()) {    // does not exist - if there is anything in the registry use that instead
                comboBox.currentIndex = 0
            }
            else {
                comboBox.currentIndex = -1
            }
        }
    }

    onSaveUriChanged: {
        setIndexFromUri(saveUri)
    }
}
