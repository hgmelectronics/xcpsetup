import QtQuick 2.5
import QtQuick.Controls 1.4
import QtQuick.Layouts 1.2
import com.hgmelectronics.setuptools 1.0

Rectangle {
    id: root
    property string xLabel: tableParam.x.slot.unit
    property string valueLabel: tableParam.value.slot.unit
    property TableParam tableParam
    property alias tableView: tableView
    width: tableView.implicitWidth
    height: tableView.implicitHeight

    Component {
        id: valueEditDelegate
        TextInput {
            id: input
            color: styleData.textColor
            anchors.margins: 4
            text: styleData.value !== undefined ? styleData.value : ""
            validator: tableParam.value.slot.validator

            onEditingFinished: {
                if(model[styleData.role] != text)
                    model[styleData.role] = text
            }
            onAccepted: {
                if (styleData.selected)
                    selectAll()
            }

            MouseArea {
                anchors.fill: parent
                onClicked: {
                    tableView.currentRow = styleData.row
                    tableView.selection.clear()
                    tableView.selection.select(styleData.row, styleData.row)
                    selectAll()
                    forceActiveFocus(Qt.MouseFocusReason)
                }
            }

            Connections {
                target: styleData
                onSelectedChanged: {
                    if(!styleData.selected) {
                        deselect()
                    }
                }
            }
        }
    }

    TableView {
        id: tableView
        anchors.fill: parent
        property real columnWidth: viewport.width / columnCount
        enabled: tableParam.valid

        model: root.tableParam.stringModel

        TableViewColumn {
            id: xColumn
            role: "x"
            width: tableView.columnWidth
            title: xLabel
        }
        TableViewColumn {
            id: valueColumn
            role: "value"
            delegate: valueEditDelegate
            width: tableView.columnWidth
            title: valueLabel
        }
    }
}
