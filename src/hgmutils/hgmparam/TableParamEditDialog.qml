import QtQuick 2.5
import QtQuick.Controls 1.4
import QtQuick.Layouts 1.2
import QtQuick.Window 2.0
import com.hgmelectronics.setuptools.xcp 1.0
import com.hgmelectronics.setuptools 1.0
import com.hgmelectronics.setuptools.ui 1.0

Window {
    id: root

    property alias xLabel: xColumn.title
    property alias valueLabel: valueColumn.title
    property TableParam tableParam
    property double steeperFlatterRatio: 1.1
    property double increaseDecreaseDelta: 1.0

    width: 400
    height: 400
    minimumWidth: 400
    minimumHeight: 220 + chartBox.height


    function arrayAverage() {
        var sum = 0.0;
        for(var i = 0; i < tableParam.value.count; ++i) {
            sum += tableParam.value.get(i);
        }
        return sum / tableParam.value.count;
    }

    function clampValue(val) {
        if(val < tableParam.value.slot.engrMin)
            return tableParam.value.slot.engrMin
        else if(val > tableParam.value.slot.engrMax)
            return tableParam.value.slot.engrMax
        else
            return val
    }

    function scaleAbout(scale, zero) {
        for(var i = 0; i < tableParam.value.count; ++i) {
            var oldDelta = tableParam.value.get(i) - zero
            tableParam.value.set(i, clampValue(oldDelta * scale + zero))
        }
    }

    function offset(delta) {
        for(var i = 0; i < tableParam.value.count; ++i) {
            tableParam.value.set(i, clampValue(tableParam.value.get(i) + delta))
        }
    }

    SplitView {
        anchors.fill: parent
        anchors.margins: 10
        orientation: Qt.Vertical
        Rectangle {
            id: chartBox
            Layout.fillWidth: true
            Layout.fillHeight: false
            Layout.minimumWidth: 300
            Layout.minimumHeight: 150
            height: 150

            TablePlot {
                id: plot
                anchors.fill: parent
                anchors.margins: 10
                plots: [
                    XYTrace {
                        tableModel: root.tableParam.stringModel
                    }
                ]
            }
        }

        RowLayout {
            Layout.fillWidth: true
            Layout.fillHeight: true
            Layout.minimumWidth: 300
            Layout.minimumHeight: 200
            spacing: 10

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
                            input.forceActiveFocus(Qt.MouseFocusReaso)
                        }
                    }
                }
            }

            TableView {
                id: tableView

                property real columnWidth: viewport.width / columnCount

                model: root.tableParam.stringModel
                selectionMode: SelectionMode.ExtendedSelection
                Layout.margins: 10
                Layout.fillHeight: true

                TableViewColumn {
                    id: xColumn
                    role: "x"
                    width: tableView.columnWidth
                }
                TableViewColumn {
                    id: valueColumn
                    role: "value"
                    delegate: valueEditDelegate
                    width: tableView.columnWidth
                }
            }

            ColumnLayout {
                Layout.margins: 10
                Layout.fillHeight: true
                spacing: 10
                Button {
                    Layout.fillWidth: true
                    text: qsTr("Steeper")
                    onClicked: scaleAbout(steeperFlatterRatio, arrayAverage())
                }
                Button {
                    Layout.fillWidth: true
                    text: qsTr("Flatter")
                    onClicked: scaleAbout(1 / steeperFlatterRatio, arrayAverage())
                }
                Button {
                    Layout.fillWidth: true
                    text: qsTr("Increase All")
                    onClicked: offset(increaseDecreaseDelta, arrayAverage())
                }
                Button {
                    Layout.fillWidth: true
                    text: qsTr("Decrease All")
                    onClicked: offset(-increaseDecreaseDelta, arrayAverage())
                }
                Button {
                    Layout.fillWidth: true
                    text: qsTr("Increase Selected")
                    enabled: tableView.selection.count > 0
                    onClicked: tableView.selection.forEach(
                                   function(rowIndex) {
                                       tableParam.value.set(rowIndex, clampValue(tableParam.value.get(rowIndex) + increaseDecreaseDelta))
                                   }
                               )
                }
                Button {
                    Layout.fillWidth: true
                    text: qsTr("Decrease Selected")
                    enabled: tableView.selection.count > 0
                    onClicked: tableView.selection.forEach(
                                   function(rowIndex) {
                                       tableParam.value.set(rowIndex, clampValue(tableParam.value.get(rowIndex) - increaseDecreaseDelta))
                                   }
                               )
                }
            }
        }
    }
}
