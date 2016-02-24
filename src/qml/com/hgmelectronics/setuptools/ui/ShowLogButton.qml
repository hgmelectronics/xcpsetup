import QtQuick 2.4
import QtQuick.Controls 1.4
import QtQuick.Controls.Styles 1.4

Button {
    property LogWindow window

    text: qsTr("Show Log")

    style: ButtonStyle {
        background: Rectangle {
            border.width: 1
            border.color: "#444444"
            color: window.visibleFault ? "#FF3333" : (window.visibleWarn ? "#DDDD33" : (window.visibleInfo ? "#FFFFFF" : "#CCCCCC"))
        }
    }

    onClicked: {
        window.showNormal()
        window.raise()
    }
}
