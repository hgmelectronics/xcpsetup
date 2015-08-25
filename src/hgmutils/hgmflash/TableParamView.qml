import QtQuick 2.5
import QtQuick.Controls 1.4
import QtQuick.Layouts 1.2
import com.setuptools.xcp 1.0

ColumnLayout {
    property string name
    property TableParam param
    Label {
        text: name
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
            width: tableView.viewport.width / 2
        }
        model: param.stringModel
    }
}
