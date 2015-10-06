import QtQuick 2.5
import QtQuick.Controls 1.4
import QtQuick.Layouts 1.2
import com.hgmelectronics.setuptools 1.0

Rectangle {
    id: root
    property string xLabel
    property string valueLabel
    property TableMetaParam tableMetaParam
    property TableParam tableParam: tableMetaParam.param
    property alias tableView: tableView
    width: tableView.implicitWidth
    height: tableView.implicitHeight

    Component {
        id: valueEditDelegate
        Item {
            id: modelForwarder
            property var dataModel: model[styleData.role]
            ComboBox {
                id: combo
                model: tableParam.value.slot.encodingStringList
                editable: true
                onActivated: {
                    if (index == -1)
                        modelForwarder.dataModel = editText
                    else
                        modelForwarder.dataModel = model[index]
                }
                onAccepted: {
                    modelForwarder.dataModel = editText
                }
            }
        }
    }

    TableView {
        id: tableView
        anchors.fill: parent
        property real columnWidth: viewport.width / columnCount
        enabled: root.tableParam.valid

        model: root.tableParam.stringModel
        selectionMode: SelectionMode.ContiguousSelection
        rowDelegate: Rectangle {
            height: 20
            property TableView control: tableView
            property color selectedColor: control.activeFocus ? "#07c" : "#999"
            property SystemPalette palette: SystemPalette {
                colorGroup: control.enabled ?
                                SystemPalette.Active :
                                SystemPalette.Disabled
            }

            property color backgroundColor: control.backgroundVisible ? palette.base : "transparent"
            property color alternateBackgroundColor: "#f5f5f5"
            color: styleData.selected ?
                       selectedColor :
                       (!styleData.alternate ?
                           alternateBackgroundColor :
                           backgroundColor)
        }

        TableViewColumn {
            role: "x"
            width: tableView.columnWidth
            title: xLabel
        }
        TableViewColumn {
            role: "value"
            delegate: valueEditDelegate
            width: tableView.columnWidth
            title: valueLabel
        }
    }
}
