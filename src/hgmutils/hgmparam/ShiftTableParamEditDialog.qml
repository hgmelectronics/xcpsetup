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

    function scaleAbout(scale, zero) {
        for(var i = 0; i < speedTableParam.value.count; ++i) {
            var oldDelta = speedTableParam.value.get(i) - zero
            speedTableParam.value.set(i, clampValue(oldDelta * scale + zero))
        }
    }

    function offset(delta) {
        for(var i = 0; i < speedTableParam.value.count; ++i) {
            speedTableParam.value.set(i, clampValue(speedTableParam.value.get(i) + delta))
        }
    }


    Action {
        id: makeSteeper
        text: qsTr("Steeper")
        onTriggered: scaleAbout(steeperFlatterRatio, arrayAverage())
    }
    Action {
        id: makeFlatter
        text: qsTr("Flatter")
        onTriggered: scaleAbout(1 / steeperFlatterRatio, arrayAverage())
    }
    Action {
        id: increaseAll
        text: qsTr("Increase All")
        onTriggered: offset(increaseDecreaseDelta)
    }
    Action {
        id: decreaseAll
        text: qsTr("Decrease All")
        onTriggered: offset(-increaseDecreaseDelta)
    }
    Action {
        id: increaseSelected
        text: qsTr("Increase Selected (+)")
        enabled: tableView.selection.count > 0
        onTriggered: tableView.selection.forEach(
                       function(rowIndex) {
                           speedTableParam.value.set(rowIndex, clampValue(speedTableParam.value.get(rowIndex) + increaseDecreaseDelta))
                       }
                   )
    }
    Action {
        id: decreaseSelected
        text: qsTr("Decrease Selected (-)")
        enabled: tableView.selection.count > 0
        onTriggered: tableView.selection.forEach(
                       function(rowIndex) {
                           speedTableParam.value.set(rowIndex, clampValue(speedTableParam.value.get(rowIndex) - increaseDecreaseDelta))
                       }
                   )
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
        anchors.fill: parent
        anchors.margins: 10
        orientation: Qt.Vertical

        Component.onCompleted: forceActiveFocus()

        Keys.onPressed: {
            if(event.key === Qt.Key_Plus || event.key === Qt.Key_Equal) {
                increaseSelected.trigger()
                event.accepted = true
            }
            else if(event.key === Qt.Key_Minus || event.key === Qt.Key_Underscore) {
                decreaseSelected.trigger()
                event.accepted = true
            }
            else if(event.key === Qt.Key_Slash) {
                linearizeSelected.trigger()
                event.accepted = true
            }
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

                    Connections {
                        target: styleData
                        onSelectedChanged: {
                            if(styleData.selected) {
                                selectAll()
                                forceActiveFocus()
                            }
                            else {
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
                    width: tableView.viewport.width / tableView.columnCount + 5
                }
                TableViewColumn {
                    role: "speed"
                    title: speedSlot.unit
                    delegate: valueEditDelegate
                    width: tableView.viewport.width / tableView.columnCount - 25
                }
                TableViewColumn {
                    role: "beforeRpm"
                    title: qsTr("Before %1").arg(rpmSlot.unit)
                    width: tableView.viewport.width / tableView.columnCount + 10
                }
                TableViewColumn {
                    role: "afterRpm"
                    title: qsTr("After %1").arg(rpmSlot.unit)
                    width: tableView.viewport.width / tableView.columnCount + 10
                }
                model: root.tableDisplayModel
                selectionMode: SelectionMode.ExtendedSelection
            }

            ColumnLayout {
                Layout.margins: 10
                Layout.fillHeight: true
                Layout.minimumWidth: 150
                Layout.maximumWidth: 150
                spacing: 10
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
                    action: increaseAll
                }
                Button {
                    Layout.fillWidth: true
                    action: decreaseAll
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
