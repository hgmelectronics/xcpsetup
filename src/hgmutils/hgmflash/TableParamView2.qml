import QtQuick 2.5
import QtQuick.Controls 1.4
import QtQuick.Layouts 1.2
import com.setuptools.xcp 1.0
import com.setuptools 1.0

ColumnLayout {
    property string name
    property TableParam param
    property EncodingSlot xSlot

    enabled: param.valid

    Label {
        text: name
    }

    Component
    {
        id: xModelDelegate
        Text {
            elide: styleData.elideMode
            text: xSlot.asString(styleData.row)
            color: styleData.textColor
        }

    }

    TableView {
        id: tableView
        TableViewColumn {
//            title: param.xLabel + ((param.xUnit.length > 0) ? ", " : "") + param.xUnit
            delegate: xModelDelegate
            width: tableView.viewport.width / tableView.columnCount
        }

        TableViewColumn {
            role: "value"
//            title: param.valueLabel + ((param.valueUnit.length > 0) ? ", " : "") + param.valueUnit
            width: tableView.viewport.width / tableView.columnCount
        }
        model: param.stringModel
    }
}
