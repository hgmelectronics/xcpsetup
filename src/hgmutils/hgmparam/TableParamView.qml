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
            width: tableView.viewport.width / tableView.columnCount
        }
        model: tableModel
    }
}


