import QtQuick 2.5
import QtQuick.Controls 1.4
import QtQuick.Layouts 1.2
import com.setuptools 1.0
import com.setuptools.xcp 1.0

ColumnLayout {

    property string name
    property string xLabel
    property string yLabel
    property TableParam param

    enabled: param.valid

    Label {
        text: name
    }

    ColumnEditDelegate
    {
        id: columnEditDelegate
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
            delegate: columnEditDelegate
            width: tableView.viewport.width / tableView.columnCount
        }
        model: param.stringModel
    }
}
