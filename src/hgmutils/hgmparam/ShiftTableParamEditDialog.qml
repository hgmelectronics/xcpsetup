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
    width: 500
    height: 500
    minimumWidth: 500
    minimumHeight: 220 + chartBox.height

    function isDefined(val) {
        return (typeof(val) !== "undefined") && (val !== null)
    }

    function stringModelIfDefined(param) {
        return isDefined(param.stringModel) ? param.stringModel : param
    }

    property string name
    property string thisGearName
    property string nextGearName
    property TableParam speedTableParam
    property TableParam rpmTableParam
    property ScalarParam thisGearRatio
    property ScalarParam nextGearRatio

    property var speedSlot: speedTableParam.value.slot
    property var tpsSlot: speedTableParam.x.slot
    property var rpmSlot: rpmTableParam.value.slot

    property double steeperFlatterRatio: 1.1
    property double increaseDecreaseDelta: 1.0


    property ScaleOffsetProxyModel beforeRpmModel: ScaleOffsetProxyModel {
        sourceModel: stringModelIfDefined(rpmTableParam.value)
        scale: thisGearRatio.floatVal
        formatSlot: rpmSlot
    }

    property ScaleOffsetProxyModel afterRpmModel: ScaleOffsetProxyModel {
        sourceModel: stringModelIfDefined(rpmTableParam.value)
        scale: nextGearRatio.floatVal
        formatSlot: rpmSlot
    }

    property TableMapperModel tableDisplayModel: TableMapperModel {
        mapping: {
            "tps": stringModelIfDefined(speedTableParam.x),
            "speed": stringModelIfDefined(speedTableParam.value),
            "beforeRpm": beforeRpmModel,
            "afterRpm": afterRpmModel
        }
    }

    function arrayAverage() {
        var sum = 0.0;
        for(var i = 0; i < speedTableParam.value.count; ++i) {
            sum += speedTableParam.value.get(i);
        }
        return sum / speedTableParam.value.count;
    }

    function clampValue(val) {
        if(val < speedTableParam.value.slot.engrMin)
            return speedTableParam.value.slot.engrMin
        else if(val > speedTableParam.value.slot.engrMax)
            return speedTableParam.value.slot.engrMax
        else
            return val
    }

    function clampWeakOrderingFromSelection() {
        var selectionFirst = speedTableParam.value.count
        var selectionLast = -1
        tableView.selection.forEach( function(rowIndex) {
            selectionFirst = Math.min(rowIndex, selectionFirst)
            selectionLast = Math.max(rowIndex, selectionLast)
        } )
        for(var i = selectionLast + 1; i < speedTableParam.value.count; ++i) {
            var prevVal = speedTableParam.value.get(i - 1)
            if(parseFloat(speedTableParam.value.get(i)) < parseFloat(prevVal))
                speedTableParam.value.set(i, prevVal)
        }
        for(var i = selectionFirst - 1; i >= 0; --i) {
            var prevVal = speedTableParam.value.get(i + 1)
            if(parseFloat(speedTableParam.value.get(i)) > parseFloat(prevVal))
                speedTableParam.value.set(i, prevVal)
        }
    }

    function scaleAbout(scale, zero) {
        tableView.selection.forEach( function(rowIndex) {
            var oldDelta = speedTableParam.value.get(rowIndex) - zero
            speedTableParam.value.set(rowIndex, clampValue(oldDelta * scale + zero))
        } )
    }

    function offset(delta) {
        tableView.selection.forEach( function(rowIndex) {
            speedTableParam.value.set(rowIndex, clampValue(speedTableParam.value.get(rowIndex) + delta))
        } )
    }

    function selectionAverage() {
        var average = 0.0
        tableView.selection.forEach( function(rowIndex) {
            average += speedTableParam.value.get(rowIndex)
        } )
        average /= tableView.selection.count
        return average
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
        onTriggered: {
            scaleAbout(steeperFlatterRatio, selectionAverage())
            clampWeakOrderingFromSelection()
        }
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
        onTriggered: {
            offset(increaseDecreaseDelta)
            clampWeakOrderingFromSelection()
        }
    }
    Action {
        id: decreaseSelected
        text: qsTr("Decrease Selected (-)")
        enabled: tableView.selection.count > 0
        onTriggered: {
            offset(-increaseDecreaseDelta)
            clampWeakOrderingFromSelection()
        }
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
            var minIndexX = parseFloat(stringModelIfDefined(speedTableParam.x).get(minIndex))
            var maxIndexX = parseFloat(stringModelIfDefined(speedTableParam.x).get(maxIndex))
            var minIndexY = parseFloat(speedTableParam.value.get(minIndex))
            var maxIndexY = parseFloat(speedTableParam.value.get(maxIndex))
            var dYdX = (maxIndexY - minIndexY) / (maxIndexX - minIndexX)
            tableView.selection.forEach(
                                   function(rowIndex) {
                                       var x = parseFloat(stringModelIfDefined(speedTableParam.x).get(rowIndex))
                                       speedTableParam.value.set(rowIndex, (x - minIndexX) * dYdX + minIndexY)
                                   }
                               )
        }
    }

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

        Rectangle {
            id: chartBox
            Layout.fillWidth: true
            Layout.fillHeight: false
            Layout.minimumWidth: 300
            Layout.minimumHeight: 150
            height: 150

            TablePlot {
                id: speedPlot
                anchors.fill: parent
                anchors.margins: 10
                plots: [
                    XYTrace {
                        tableModel: root.speedTableParam.stringModel
                        valid: root.speedTableParam.value.valid
                    }
                ]
            }
        }

        RowLayout {
            Layout.fillWidth: true
            Layout.fillHeight: true
            Layout.minimumWidth: 450
            Layout.minimumHeight: 250
            spacing: 10
            Component {
                id: valueEditDelegate
                TextInput {
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

            TableView {
                id: tableView
                Layout.fillWidth: true
                Layout.fillHeight: true
                Layout.margins: 10
                TableViewColumn {
                    role: "tps"
                    title: qsTr("Throttle %1").arg(tpsSlot.unit)
                    width: tableView.viewport.width / tableView.columnCount
                }
                TableViewColumn {
                    role: "speed"
                    title: speedSlot.unit
                    delegate: valueEditDelegate
                    width: tableView.viewport.width / tableView.columnCount
                }
                TableViewColumn {
                    role: "beforeRpm"
                    title: qsTr("%1 @%2").arg(rpmSlot.unit).arg(thisGearName)
                    width: tableView.viewport.width / tableView.columnCount
                }
                TableViewColumn {
                    role: "afterRpm"
                    title: qsTr("%1 @%2").arg(rpmSlot.unit).arg(nextGearName)
                    width: tableView.viewport.width / tableView.columnCount
                }
                model: root.tableDisplayModel
                selectionMode: SelectionMode.ContiguousSelection
            }

            ColumnLayout {
                Layout.margins: 10
                Layout.fillHeight: true
                Layout.minimumWidth: 150
                Layout.maximumWidth: 150
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
