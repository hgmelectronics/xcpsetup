import QtQuick 2.5
import QtQuick.Controls 1.4

GroupBox {
    id: box
    title: qsTr("Speed (kbps)")
    property int bps

    ComboBox {
        id: bitrateComboBox
        anchors.fill: parent
        editable: true
        implicitWidth: 80
        model: ["125", "250", "500", "1000"]

        validator: IntValidator {
            bottom: 10
            top: 1000
        }

        onCurrentIndexChanged: {
            if (currentIndex >= 0)
                box.bps = model[currentIndex] * 1000
        }

        onAccepted: {
            box.bps = parseFloat(editText) * 1000
        }

        Component.onCompleted: {
            currentIndex = find("500")
        }
    }
}
