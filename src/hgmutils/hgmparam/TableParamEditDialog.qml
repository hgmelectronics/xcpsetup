import QtQuick 2.5
import QtQuick.Controls 1.4
import QtQuick.Layouts 1.2
import QtQuick.Window 2.0
import QtQuick.Controls.Styles 1.4
import com.hgmelectronics.setuptools.xcp 1.0
import com.hgmelectronics.setuptools 1.0
import com.hgmelectronics.setuptools.ui 1.0

Window {
    id: root

    property string xLabel
    property string valueLabel
    property bool hasPlot: !encodingValue
    property bool hasShapers: !encodingValue
    property TableParam tableParam
    property bool encodingValue: (typeof(tableParam.value.slot.encodingStringList) !== "undefined")
    property double steeperFlatterRatio: 1.1
    property double increaseDecreaseDelta: 1.0

    width: (hasShapers || hasPlot) ? 420 : 240
    height: 420
    minimumWidth: (hasShapers || hasPlot) ? 420 : 240
    minimumHeight: 270 + chartBox.height

    function arrayAverage() {
        var sum = 0.0
        for (var i = 0; i < tableParam.value.count; ++i) {
            sum += tableParam.value.get(i)
        }
        return sum / tableParam.value.count
    }

    function clampValue(val) {
        if (val < tableParam.value.slot.engrMin)
            return tableParam.value.slot.engrMin
        else if (val > tableParam.value.slot.engrMax)
            return tableParam.value.slot.engrMax
        else
            return val
    }

    function scaleAbout(scale, zero) {
        for (var i = 0; i < tableParam.value.count; ++i) {
            var oldDelta = tableParam.value.get(i) - zero
            tableParam.value.set(i, clampValue(oldDelta * scale + zero))
        }
    }

    function offset(delta) {
        for (var i = 0; i < tableParam.value.count; ++i) {
            tableParam.value.set(i, clampValue(tableParam.value.get(i) + delta))
        }
    }

    property TableView tableView: encodingValue ? encodingTableView : regularTableView

    SplitView {
        anchors.fill: parent
        anchors.margins: 10
        orientation: Qt.Vertical

          // dreadful hack because making chart invisible causes QML to hang
        handleDelegate: Rectangle {
            SystemPalette { id: pal }
            width: 1
            height: 1
            color: hasPlot ? Qt.darker(pal.window, 1.5) : "transparent"
        }

        Rectangle {
            id: chartBox
            Layout.fillWidth: true
            Layout.fillHeight: false

            Layout.minimumHeight: hasPlot ? 150 : 0  // dreadful hack because making chart invisible causes QML to hang
            height: hasPlot ? 150 : 0

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
            //visible: hasPlot
        }

        RowLayout {
            Layout.fillWidth: true
            Layout.fillHeight: true
            Layout.minimumHeight: 250
            spacing: 10

            Component {
                id: regularValueEditDelegate
                TextInput {
                    id: input
                    color: styleData.textColor
                    anchors.margins: 4
                    text: styleData.value !== undefined ? styleData.value : ""

                    onEditingFinished: {
                        if(model[styleData.role] != text)
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
                            regularTableView.currentRow = styleData.row
                            regularTableView.selection.clear()
                            regularTableView.selection.select(styleData.row)
                            input.selectAll()
                            input.forceActiveFocus(Qt.MouseFocusReaso)
                        }
                    }
                }
            }

            Component {
                id: encodingValueEditDelegate
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
                id: regularTableView
                visible: !encodingValue
                property real columnWidth: viewport.width / columnCount

                model: root.tableParam.stringModel
                selectionMode: SelectionMode.ExtendedSelection
                Layout.margins: 10
                Layout.fillHeight: true

                TableViewColumn {
                    role: "x"
                    width: regularTableView.columnWidth
                    title: xLabel
                }
                TableViewColumn {
                    role: "value"
                    delegate: regularValueEditDelegate
                    width: regularTableView.columnWidth
                    title: valueLabel
                }
            }
            TableView {
                id: encodingTableView
                visible: encodingValue
                property real columnWidth: viewport.width / columnCount

                model: root.tableParam.stringModel
                selectionMode: SelectionMode.ExtendedSelection
                Layout.margins: 10
                Layout.fillHeight: true
                rowDelegate: Rectangle {
                    height: 20
                    property TableView control: encodingTableView
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
                    width: encodingTableView.columnWidth
                    title: xLabel
                }
                TableViewColumn {
                    role: "value"
                    delegate: encodingValueEditDelegate
                    width: encodingTableView.columnWidth
                    title: valueLabel
                }
            }

            ColumnLayout {
                visible: hasShapers
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
                    onClicked: scaleAbout(1 / steeperFlatterRatio,
                                          arrayAverage())
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
                    enabled: root.tableView.selection.count > 0
                    onClicked: root.tableView.selection.forEach(function (rowIndex) {
                        tableParam.value.set(
                                    rowIndex, clampValue(
                                        tableParam.value.get(
                                            rowIndex) + increaseDecreaseDelta))
                    })
                }
                Button {
                    Layout.fillWidth: true
                    text: qsTr("Decrease Selected")
                    enabled: root.tableView.selection.count > 0
                    onClicked: root.tableView.selection.forEach(function (rowIndex) {
                        tableParam.value.set(
                                    rowIndex, clampValue(
                                        tableParam.value.get(
                                            rowIndex) - increaseDecreaseDelta))
                    })
                }
            }
        }
    }
}
