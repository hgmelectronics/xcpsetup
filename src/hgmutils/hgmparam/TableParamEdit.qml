import QtQuick 2.5
import QtQuick.Controls 1.4
import QtQuick.Layouts 1.2
import com.hgmelectronics.setuptools.xcp 1.0
import com.hgmelectronics.setuptools 1.0

ColumnLayout {

    property string name
    property string xLabel
    property string valueLabel
    property TableMapperModel tableModel

    Label {
        text: name
    }

    Component {
        id: valueEditDelegate
        TextInput {
            id: input
            color: styleData.textColor
            anchors.margins: 4
            text: styleData.value
                  !== undefined ? styleData.value : ""
            onEditingFinished: {
                model[getColumn(styleData.column).role] = text
            }

            onFocusChanged: {
                if (focus) {
                    selectAll()
                    forceActiveFocus()
                }
            }
            onAccepted: {
                if(focus)
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
                    input.forceActiveFocus()
                }
            }
        }

    }

    TableView {
        id: tableView
        TableViewColumn {
            role: "x"
            title: xLabel
            width: tableView.viewport.width / tableView.columnCount
        }
        TableViewColumn {
            role: "value"
            title: valueLabel
            delegate: valueEditDelegate
            width: tableView.viewport.width / tableView.columnCount
        }
        model: tableModel
    }
}
