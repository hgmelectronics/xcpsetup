import QtQuick 2.5
import QtQuick.Controls 1.4
import QtQuick.Layouts 1.2
import QtQuick.Window 2.2
import QtQuick.Dialogs 1.2
import com.hgmelectronics.setuptools 1.0

MenuItem {
    id: item

    property alias name: item.text
    property alias tableParam: table.tableParam
    property alias valueLabel: table.valueLabel
    property alias xLabel: table.xLabel
    property alias hasPlot: table.hasPlot
    property alias hasShapers: table.hasShapers

    enabled: table.tableParam.param.value.range.valid
    onTriggered: table.visible = true
    text: tableParam.name

    property TableParamEditDialog dialog: TableParamEditDialog {
        id: table
        xLabel: tableParam.param.x.slot.unit
        valueLabel: tableParam.param.value.slot.unit
    }
}
