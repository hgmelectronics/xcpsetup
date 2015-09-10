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
        model: ListModel {
            id: bitrateItems
            ListElement {
                text: "125"
                bps: 125000
            }
            ListElement {
                text: "250"
                bps: 250000
            }
            ListElement {
                text: "500"
                bps: 500000
            }
            ListElement {
                text: "1000"
                bps: 1000000
            }
        }

        validator: DoubleValidator {
            bottom: 10
            top: 1000
        }

        onCurrentIndexChanged: {
            if (currentIndex >= 0)
                box.bps = bitrateItems.get(currentIndex).bps
        }

        onAccepted: {
            box.bps = parseFloat(editText) * 1000
        }

        Component.onCompleted: {
            currentIndex = find("500")
        }
    }
}
