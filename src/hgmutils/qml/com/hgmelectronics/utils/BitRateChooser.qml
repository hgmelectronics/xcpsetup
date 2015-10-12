import QtQuick 2.5
import QtQuick.Controls 1.4

GroupBox {
    id: box
    title: qsTr("Speed (kbps)")
    property int bps
    property alias allowedRates: bitrateComboBox.model
    property int defaultRate: 500

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
                box.bps = parseFloat(model[currentIndex]) * 1000
        }

        onAccepted: {
            box.bps = parseFloat(editText) * 1000
        }

        Component.onCompleted: {
            currentIndex = find(box.defaultRate.toString())
        }
    }
}
