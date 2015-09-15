import QtQuick 2.5
import QtQuick.Controls 1.4
import QtQuick.Layouts 1.2
import QtQuick.Window 2.2
import QtQuick.Dialogs 1.2
import com.hgmelectronics.setuptools.xcp 1.0
import com.hgmelectronics.setuptools 1.0

GroupBox {
    id: groupBox
    property alias count: repeater.model
    property string xLabel
    property string valueLabel
    property var tableParam

    property bool isDownshift: false

    Row {
        spacing: 10
        Repeater {
            id: repeater
            TableParamEditButton {
                id: tableButton
                function getTitle(i) {
                    var first = i + 1
                    var second = i + 2
                    if (!isDownshift) {
                        return qsTr("Shift %1-%2").arg(first).arg(second)
                    } else {
                        return qsTr("Shift %1-%2").arg(second).arg(first)
                    }
                }
                name: getTitle(index)
                tableParam: groupBox.tableParam[index]
                xLabel: groupBox.xLabel
                valueLabel: groupBox.valueLabel
            }
        }
    }
}
