import QtQuick 2.5
import QtQuick.Controls 1.4
import QtQuick.Layouts 1.2
import com.hgmelectronics.setuptools.xcp 1.0
import com.hgmelectronics.setuptools 1.0

ColumnLayout {

    property string name
    property string xLabel
    property string yLabel
    property TableParam param

    enabled: param.valid

    Label {
        text: name
    }

        Component {
            id: valueEditDelegate
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

    TableView {
        id: tableView
        TableViewColumn {
            role: "x"
            title: xLabel + ((param.axis.xUnit.length > 0) ? ", " : "") + param.axis.xUnit
            width: tableView.viewport.width / tableView.columnCount
        }
        TableViewColumn {
            role: "value"
            title: yLabel + ((param.slot.unit.length > 0) ? ", " : "") + param.slot.unit
            delegate: valueEditDelegate
            width: tableView.viewport.width / tableView.columnCount
        }
        model: param.stringModel
    }
}
