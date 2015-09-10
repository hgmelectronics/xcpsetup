import QtQuick 2.5
import QtQuick.Controls 1.4
import QtQuick.Layouts 1.2
import com.hgmelectronics.setuptools.xcp 1.0

ColumnLayout {
    property string name
    property TableParam param
    Label {
        text: name
    }

    Component {
        id: valueEditDelegate
        TextField {
            anchors.margins: 4
            text: styleData.value
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
            title: param.xLabel + ((param.xUnit.length > 0) ? ", " : "") + param.xUnit
            width: tableView.viewport.width / 2
        }
        TableViewColumn {
            role: "value"
            title: param.valueLabel + ((param.valueUnit.length > 0) ? ", " : "") + param.valueUnit
            delegate: valueEditDelegate
            width: tableView.viewport.width / 2
        }
        model: param.stringModel
    }
}
