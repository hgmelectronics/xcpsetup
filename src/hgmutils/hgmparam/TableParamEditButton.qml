import QtQuick 2.5
import QtQuick.Controls 1.4
import QtQuick.Layouts 1.2
import QtQuick.Window 2.2
import QtQuick.Dialogs 1.2
import com.hgmelectronics.setuptools 1.0

Button {
    id: button
    property alias name: button.text
    property alias valueArray: table.valueArray
    property alias tableModel: table.tableModel
    property alias valueLabel: table.valueLabel
    property alias xLabel: table.xLabel

    enabled: table.valueArray.range.valid

    onClicked: table.visible = true

    TableParamEditDialog {
        id: table
        title: button.text
    }

}

