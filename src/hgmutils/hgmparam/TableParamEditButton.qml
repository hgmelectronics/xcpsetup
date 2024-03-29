import QtQuick 2.5
import QtQuick.Controls 1.4
import QtQuick.Layouts 1.2
import QtQuick.Window 2.2
import QtQuick.Dialogs 1.2
import com.hgmelectronics.setuptools 1.0

Button {
    id: button
    Layout.margins: 8
    property alias name: button.text
    property alias tableParam: table.tableParam
    property alias valueLabel: table.valueLabel
    property alias xLabel: table.xLabel
    property alias hasPlot: table.hasPlot
    property alias hasShapers: table.hasShapers

    enabled: table.tableParam.param.value.valid
    onClicked: {
        table.showNormal()
        table.raise()
    }
    text: tableParam.name

    TableParamEditDialog {
        id: table
        xLabel: tableParam.param.x.slot.unit
        valueLabel: tableParam.param.value.slot.unit
    }
}
