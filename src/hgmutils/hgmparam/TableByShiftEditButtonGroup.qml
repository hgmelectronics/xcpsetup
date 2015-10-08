import QtQuick 2.5
import QtQuick.Controls 1.4
import QtQuick.Layouts 1.2
import QtQuick.Window 2.2
import QtQuick.Dialogs 1.2

GroupBox {
    id: groupBox
    property alias count: repeater.model
    property string xLabel
    property string valueLabel
    property var tableParam

    title: tableParam[0].name.replace(/Shift [1-9RN]-[1-9RN] (.*)/, "$1")

    Row {
        spacing: 5
        Repeater {
            id: repeater
            model: tableParam.length
            TableParamEditButton {
                id: tableButton
                name: groupBox.tableParam[index].name.replace(/(Shift [1-9RN]-[1-9RN]).*/, "$1")
                tableParam: groupBox.tableParam[index]
                xLabel: groupBox.xLabel
                valueLabel: groupBox.valueLabel
            }
        }
    }
}
