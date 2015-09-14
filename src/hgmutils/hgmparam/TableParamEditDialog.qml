import QtQuick 2.5
import QtQuick.Controls 1.4
import QtQuick.Layouts 1.2
import QtQuick.Window 2.0
import paramview 1.0
import com.hgmelectronics.setuptools.xcp 1.0
import com.hgmelectronics.setuptools 1.0

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
    property TableMapperModel tableModel
    property ArrayParam valueArray
    property double steeperFlatterRatio: 1.1
    property double increaseDecreaseDelta: 1.0

    function arrayAverage() {
        var sum = 0.0;
        for(var i = 0; i < valueArray.count; ++i) {
            sum += valueArray.get(i);
        }
        return sum / valueArray.count;
    }

    function clampValue(val) {
        if(val < valueArray.slot.engrMin)
            return valueArray.slot.engrMin
        else if(val > valueArray.slot.engrMax)
            return valueArray.slot.engrMax
        else
            return val
    }

    function scaleAbout(scale, zero) {
        for(var i = 0; i < valueArray.count; ++i) {
            var oldDelta = valueArray.get(i) - zero
            valueArray.set(i, clampValue(oldDelta * scale + zero))
        }
    }

    function offset(delta) {
        for(var i = 0; i < valueArray.count; ++i) {
            valueArray.set(i, clampValue(valueArray.get(i) + delta))
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
                        tableModel: root.tableModel
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
                model: root.tableModel
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
                    text: "Steeper"
                    onClicked: scaleAbout(steeperFlatterRatio, arrayAverage())
                }
                Button {
                    Layout.fillWidth: true
                    text: "Flatter"
                    onClicked: scaleAbout(1 / steeperFlatterRatio, arrayAverage())
                }
                Button {
                    Layout.fillWidth: true
                    text: "Increase All"
                    onClicked: offset(increaseDecreaseDelta, arrayAverage())
                }
                Button {
                    Layout.fillWidth: true
                    text: "Decrease All"
                    onClicked: offset(-increaseDecreaseDelta, arrayAverage())
                }
                Button {
                    Layout.fillWidth: true
                    text: "Increase Selected"
                    enabled: tableView.selection.count > 0
                    onClicked: tableView.selection.forEach(
                                   function(rowIndex) {
                                       valueArray.set(rowIndex, clampValue(valueArray.get(rowIndex) + increaseDecreaseDelta))
                                   }
                               )
                }
                Button {
                    Layout.fillWidth: true
                    text: "Decrease Selected"
                    enabled: tableView.selection.count > 0
                    onClicked: tableView.selection.forEach(
                                   function(rowIndex) {
                                       valueArray.set(rowIndex, clampValue(valueArray.get(rowIndex) - increaseDecreaseDelta))
                                   }
                               )
                }
            }
        }
    }
}
