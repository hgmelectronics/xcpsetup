import QtQuick 2.5
import QtQuick.Controls 1.4

Component {
    TextInput {
        id: input
        color: styleData.textColor
        anchors.margins: 4
        text: styleData.value !== undefined ? styleData.value : ""

        onEditingFinished: {
            model[styleData.role] = text
        }

        onFocusChanged: {
            if (focus) {
                selectAll()
                forceActiveFocus()
            }
        }

        onAccepted: {
            if (focus)
                selectAll()
        }

        MouseArea {
            anchors.fill: parent
            hoverEnabled: true
            onClicked: {
                tableView.currentRow = styleData.row
                tableView.selection.clear()
                tableView.selection.select(styleData.row)
                input.selectAll()
                input.forceActiveFocus(Qt.MouseFocusReaso)
            }
        }
    }
}
