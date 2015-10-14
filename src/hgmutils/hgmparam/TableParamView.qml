import QtQuick 2.5
import QtQuick.Controls 1.4
import QtQuick.Layouts 1.2

ColumnLayout {
    property alias name: label.text
    property alias xLabel: xColumn.title
    property alias valueLabel: valueColumn.title
    property alias model: tableView.model
    property alias xColumnWidth: xColumn.width
    property alias valueColumnWidth: valueColumn.width
    property bool verticalScroll: false

    Label {
        id: label
    }

    TableView {
        id: tableView
        property int scrollWidth: 0
        verticalScrollBarPolicy: verticalScroll ? Qt.ScrollBarAlwaysOn : Qt.ScrollBarAlwaysOff
        implicitWidth: xColumn.width + valueColumn.width + tableView.scrollWidth
        width: implicitWidth

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

        Component.onCompleted: {
            scrollWidth = width - viewport.width
        }
    }
}
