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
            width: tableView.columnWidth
        }
    }
}
