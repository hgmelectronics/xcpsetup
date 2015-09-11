import QtQuick 2.5
import QtQuick.Controls 1.4

Component {
    TextInput {
        color: styleData.textColor
        anchors.margins: 4
        text: styleData.value !== undefined ? styleData.value : ""
        onEditingFinished: model.value = text
        focus: (styleData.row === tableView.currentRow)
        onFocusChanged: {
            if(focus) {
                selectAll()
                forceActiveFocus()
            }
        }
        MouseArea {
            anchors.fill: parent
            hoverEnabled: true
            onClicked: {
                tableView.currentRow = styleData.row
                tableView.selection.clear()
                tableView.selection.select(styleData.row)
            }
        }
    }
}
