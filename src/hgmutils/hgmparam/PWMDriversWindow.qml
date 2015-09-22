import QtQuick 2.5
import QtQuick.Controls 1.4
import QtQuick.Layouts 1.2
import QtQuick.Window 2.0

Window {
    id: root
    property alias model: tableView.model
    title: qsTr("PWM Drivers")
    width: 400
    height: 400

    Component {
        id: valueEditDelegate
        TextInput {
            id: input
            color: styleData.textColor
            anchors.margins: 4
            text: styleData.value !== undefined ? styleData.value : ""

            onEditingFinished: {
                model[styleData.role] = text
            }

            onFocusChanged: {
                if (focus) {
                    selectAll()
                    forceActiveFocus()
                }
            }

            onAccepted: {
                if (focus)
                    selectAll()
            }

            MouseArea {
                anchors.fill: parent
                hoverEnabled: true
                onClicked: {
                    tableView.currentRow = styleData.row
                    tableView.selection.clear()
                    tableView.selection.select(styleData.row)
                    input.selectAll()
                    input.forceActiveFocus(Qt.MouseFocusReason)
                }
            }
        }
    }

    TableView {
        id: tableView
        property real columnWidth: viewport.width / tableView.columnCount

        anchors.fill: parent
        anchors.margins: 10

        TableViewColumn {
            role: "x"
            title: "Driver"
            width: tableView.columnWidth
        }
        TableViewColumn {
            role: "frequency"
            title: "Frequency"
            width: tableView.columnWidth
            delegate: valueEditDelegate
        }
        TableViewColumn {
            role: "dutyCycle"
            title: "Duty Cycle"
            width: tableView.columnWidth
            delegate: valueEditDelegate
        }
        TableViewColumn {
            role: "mode"
            title: "Mode"
            width: tableView.columnWidth
            delegate: valueEditDelegate
        }
    }
}
