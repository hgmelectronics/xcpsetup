import QtQuick 2.5
import QtQuick.Controls 1.4
import QtQuick.Layouts 1.2
import QtQuick.Window 2.2
import QtQuick.Dialogs 1.2
import com.hgmelectronics.setuptools.xcp 1.0
import com.hgmelectronics.setuptools 1.0



GroupBox {
    property alias count: repeater.model
    property string xLabel
    property string valueLabel
    property var valueArray
    property var tableModel

    id: groupBox
    Row {
        spacing: 10
        Repeater {
            id: repeater
            TableParamEditButton {
                id: tableButton
                function getTitle(i) {
                    var first = i + 1
                    return "Gear " + first
                }
                name: getTitle(index)
                valueArray: groupBox.valueArray[index]
                tableModel: groupBox.tableModel[index]
                xLabel: groupBox.xLabel
                valueLabel: groupBox.valueLabel
            }
        }
    }
}