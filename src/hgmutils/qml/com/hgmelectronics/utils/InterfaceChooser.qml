import QtQuick 2.5
import QtQuick.Controls 1.4
import com.hgmelectronics.setuptools.xcp 1.0

GroupBox {
    title: "Interface"
    property alias uri: comboBox.selectedUri

    InterfaceRegistry {
        id: registry
    }

    ComboBox {
        id: comboBox
        property string selectedUri

        enabled: !paramLayer.intfcOk
        anchors.fill: parent
        model: registry.avail
        textRole: "text"
        visible: true
        selectedUri: (count > 0
                      && currentIndex < count) ? model[currentIndex].uri : ""
    }
}
