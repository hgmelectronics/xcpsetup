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
    height: 290 + chartBox.height
    minimumWidth: (hasShapers || hasPlot) ? 420 : 240
    minimumHeight: 290 + chartBox.height

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
        tableView.selection.forEach( function(rowIndex) {
            var oldDelta = tableParam.value.get(rowIndex) - zero
            tableParam.value.set(rowIndex, clampValue(oldDelta * scale + zero))
        } )
    }

    function offset(delta) {
        tableView.selection.forEach( function(rowIndex) {
            tableParam.value.set(rowIndex, clampValue(tableParam.value.get(rowIndex) + delta))
        } )
    }

    function selectionAverage() {
        var average = 0.0
        tableView.selection.forEach( function(rowIndex) {
            average += tableParam.value.get(rowIndex)
        } )
        average /= tableView.selection.count
        return average
    }

    function isDefined(val) {
        return (typeof(val) !== "undefined") && (val !== null)
    }

    function stringModelIfDefined(param) {
        return isDefined(param.stringModel) ? param.stringModel : param
    }

    Action {
        id: selectAll
        text: qsTr("Select All (Ctrl-A)")
        enabled: tableView.selection.count < tableView.rowCount
        onTriggered: tableView.selection.selectAll()
    }
    Action {
        id: deselect
        text: qsTr("Deselect (Ctrl-Shift-A)")
        enabled: tableView.selection.count > 0
        onTriggered: tableView.selection.clear()
    }
    Action {
        id: makeSteeper
        text: qsTr("Steeper")
        enabled: tableView.selection.count > 0
        onTriggered: scaleAbout(steeperFlatterRatio, selectionAverage())
    }
    Action {
        id: makeFlatter
        text: qsTr("Flatter")
        enabled: tableView.selection.count > 0
        onTriggered: scaleAbout(1 / steeperFlatterRatio, selectionAverage())
    }
    Action {
        id: increaseSelected
        text: qsTr("Increase Selected (+)")
        enabled: tableView.selection.count > 0
        onTriggered: offset(increaseDecreaseDelta)
    }
    Action {
        id: decreaseSelected
        text: qsTr("Decrease Selected (-)")
        enabled: tableView.selection.count > 0
        onTriggered: offset(-increaseDecreaseDelta)
    }
    Action {
        id: linearizeSelected
        text: qsTr("Linearize Selected (/)")
        enabled: tableView.selection.count > 0
        onTriggered: {
            var minIndex = tableView.model.rowCount()
            var maxIndex = -1
            tableView.selection.forEach(
                                   function(rowIndex) {
                                       minIndex = Math.min(minIndex, rowIndex)
                                       maxIndex = Math.max(maxIndex, rowIndex)
                                   }
                               )
            var minIndexX = parseFloat(stringModelIfDefined(tableParam.x).get(minIndex))
            var maxIndexX = parseFloat(stringModelIfDefined(tableParam.x).get(maxIndex))
            var minIndexY = parseFloat(tableParam.value.get(minIndex))
            var maxIndexY = parseFloat(tableParam.value.get(maxIndex))
            var dYdX = (maxIndexY - minIndexY) / (maxIndexX - minIndexX)
            tableView.selection.forEach(
                                   function(rowIndex) {
                                       var x = parseFloat(stringModelIfDefined(tableParam.x).get(rowIndex))
                                       tableParam.value.set(rowIndex, (x - minIndexX) * dYdX + minIndexY)
                                   }
                               )
        }
    }

    property TableView tableView: encodingValue ? encodingTableView : regularTableView

    SplitView {
        id: splitView
        anchors.fill: parent
        anchors.margins: 10
        orientation: Qt.Vertical

        Connections {
            target: root
            onActiveChanged: {
                if(root.active)
                    splitView.forceActiveFocus(Qt.ActiveWindowFocusReason)
            }
        }

        Keys.onPressed: {
            event.accepted = true
            if(event.key === Qt.Key_Plus || event.key === Qt.Key_Equal)
                increaseSelected.trigger()
            else if(event.key === Qt.Key_Minus || event.key === Qt.Key_Underscore)
                decreaseSelected.trigger()
            else if(event.key === Qt.Key_Slash)
                linearizeSelected.trigger()
            else if(event.key === Qt.Key_A && event.modifiers === Qt.ControlModifier)
                selectAll.trigger()
            else if(event.key === Qt.Key_A && event.modifiers === (Qt.ShiftModifier | Qt.ControlModifier))
                deselect.trigger()
            else
                event.accepted = false
        }

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
                    onAccepted: {
                        if (focus)
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
                    action: selectAll
                }
                Button {
                    Layout.fillWidth: true
                    action: deselect
                }
                Button {
                    Layout.fillWidth: true
                    action: makeSteeper
                }
                Button {
                    Layout.fillWidth: true
                    action: makeFlatter
                }
                Button {
                    Layout.fillWidth: true
                    action: increaseSelected
                }
                Button {
                    Layout.fillWidth: true
                    action: decreaseSelected
                }
                Button {
                    Layout.fillWidth: true
                    action: linearizeSelected
                }
            }
        }
    }
}
