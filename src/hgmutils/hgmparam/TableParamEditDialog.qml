import QtQuick 2.5
import QtQuick.Controls 1.4
import QtQuick.Layouts 1.2
import QtQuick.Window 2.0
import com.hgmelectronics.setuptools.xcp 1.0
import com.hgmelectronics.setuptools 1.0
import com.hgmelectronics.setuptools.ui 1.0

Window {
    id: root
    title: name
    width: 400
    height: 400
    minimumWidth: 400
    minimumHeight: 220 + chartBox.height

    property string name
    property string xLabel
    property string valueLabel
    property TableParam tableParam
    property double steeperFlatterRatio: 1.1
    property double increaseDecreaseDelta: 1.0

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
                        valid: root.tableParam.value.valid
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
                    color: styleData.textColor
                    anchors.margins: 4
                    text: styleData.value !== undefined ? styleData.value : ""
                    onEditingFinished: model.value = text
                    focus: (styleData.row === tableView.currentRow)
                    onFocusChanged: {
                        if(focus) {
                            selectAll()
                            forceActiveFocus()
                        }
                    }
                    MouseArea {
                        anchors.fill: parent
                        hoverEnabled: true
                        onClicked: {
                            tableView.currentRow = styleData.row
                            tableView.selection.clear()
                            tableView.selection.select(styleData.row)
                        }
                    }
                }
            }

            TableView {
                id: tableView
                TableViewColumn {
                    role: "x"
                    title: root.xLabel
                    width: tableView.viewport.width / tableView.columnCount
                }
                TableViewColumn {
                    role: "value"
                    title: root.valueLabel
                    delegate: valueEditDelegate
                    width: tableView.viewport.width / tableView.columnCount
                }
                model: root.tableParam.stringModel
                selectionMode: SelectionMode.ExtendedSelection
                Layout.margins: 10
                Layout.fillHeight: true
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
