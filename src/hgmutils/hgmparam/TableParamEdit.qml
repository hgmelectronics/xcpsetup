import QtQuick 2.5
import QtQuick.Controls 1.4
import QtQuick.Layouts 1.2
import com.hgmelectronics.setuptools 1.0

ColumnLayout {
    property alias name: label.name
    property alias xLabel: xColumn.title
    property alias valueLabel: valueColumn.title
    property alias model: tableView.model

    Label {
        id: label
    }

    Component {
        id: valueEditDelegate
        TextInput {
            id: input
            color: styleData.textColor
            anchors.margins: 4
            text: styleData.value !== undefined ? styleData.value : ""

            onEditingFinished: {
                if(model[styleData.role] != text)
                    model[styleData.role] = text
            }

            Connections {
                target: styleData
                onSelectedChanged: {
                    if(styleData.selected) {
                        selectAll()
                        forceActiveFocus()
                    }
                    else {
                        deselect()
                    }
                }
            }
        }
    }

    TableView {
        id: tableView
        property real columnWidth: viewport.width / columnCount

        TableViewColumn {
            id: xColumn
            role: "x"
            width: tableView.columnWidth
        }
        TableViewColumn {
            id: valueColumn
            role: "value"
            delegate: valueEditDelegate
            width: tableView.columnWidth
        }
    }
}
