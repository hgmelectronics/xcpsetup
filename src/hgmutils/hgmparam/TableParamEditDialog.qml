import QtQuick 2.5
import QtQuick.Controls 1.4
import QtQuick.Layouts 1.2
import QtQuick.Window 2.0
import QtQuick.Controls.Styles 1.4
import QtQuick.Dialogs 1.2
import QtCharts 2.0
import com.hgmelectronics.setuptools.xcp 1.0
import com.hgmelectronics.setuptools 1.0
import com.hgmelectronics.setuptools.ui 1.0

Window {
    id: root

    property string name: tableParam.name
    property string xLabel
    property string valueLabel
    property bool hasPlot: !encodingValue
    property bool hasShapers: !encodingValue
    property TableMetaParam tableParam
    property bool encodingValue: (typeof(tableParam.param.value.slot.encodingStringList) !== "undefined")
    property double steeperFlatterRatio: 1.1
    property double increaseDecreaseDelta: 1.0

    onVisibleChanged: {
        width = width + 1   // hack to force redraw of plot - there is a bug with the QPainter scenegraph renderer that causes it to not show on closing and reopening window
        width = width - 1
    }

    title: name
    width: (hasShapers || hasPlot) ? 420 : 240
    height: 350 + plot.height
    minimumWidth: (hasShapers || hasPlot) ? 420 : 240
    minimumHeight: 350 + plot.height

    function arrayAverage() {
        var sum = 0.0
        for (var i = 0; i < tableParam.param.value.count; ++i) {
            sum += tableParam.param.value.get(i)
        }
        return sum / tableParam.param.value.count
    }

    function clampValue(val) {
        if (val < tableParam.param.value.slot.engrMin)
            return tableParam.param.value.slot.engrMin
        else if (val > tableParam.param.value.slot.engrMax)
            return tableParam.param.value.slot.engrMax
        else
            return val
    }

    function checkImmediateWrite() {
        if(tableParam.immediateWrite)
            ImmediateWrite.trigger(tableParam.param.value.key)
    }

    function scaleAbout(scale, zero) {
        tableView.selection.forEach( function(rowIndex) {
            var oldDelta = tableParam.param.value.get(rowIndex) - zero
            tableParam.param.value.set(rowIndex, clampValue(oldDelta * scale + zero))
        } )
    }

    function offset(delta) {
        tableView.selection.forEach( function(rowIndex) {
            tableParam.param.value.set(rowIndex, clampValue(tableParam.param.value.get(rowIndex) + delta))
        } )
    }

    function selectionAverage() {
        var average = 0.0
        tableView.selection.forEach( function(rowIndex) {
            average += tableParam.param.value.get(rowIndex)
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
        onTriggered: {
            scaleAbout(steeperFlatterRatio, selectionAverage())
            checkImmediateWrite()
        }
    }
    Action {
        id: makeFlatter
        text: qsTr("Flatter")
        enabled: tableView.selection.count > 0
        onTriggered: {
            scaleAbout(1 / steeperFlatterRatio, selectionAverage())
            checkImmediateWrite()
        }
    }
    Action {
        id: increaseSelected
        text: qsTr("Increase Selected (+)")
        enabled: tableView.selection.count > 0
        onTriggered: {
            offset(increaseDecreaseDelta)
            checkImmediateWrite()
        }
    }
    Action {
        id: decreaseSelected
        text: qsTr("Decrease Selected (-)")
        enabled: tableView.selection.count > 0
        onTriggered: {
            offset(-increaseDecreaseDelta)
            checkImmediateWrite()
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
            var minIndexX = parseFloat(stringModelIfDefined(tableParam.param.x).get(minIndex))
            var maxIndexX = parseFloat(stringModelIfDefined(tableParam.param.x).get(maxIndex))
            var minIndexY = parseFloat(tableParam.param.value.get(minIndex))
            var maxIndexY = parseFloat(tableParam.param.value.get(maxIndex))
            var dYdX = (maxIndexY - minIndexY) / (maxIndexX - minIndexX)
            tableView.selection.forEach(
                                   function(rowIndex) {
                                       var x = parseFloat(stringModelIfDefined(tableParam.param.x).get(rowIndex))
                                       tableParam.param.value.set(rowIndex, (x - minIndexX) * dYdX + minIndexY)
                                   }
                               )
            checkImmediateWrite()
        }
    }
    Action {
        id: copyTable
        text: qsTr("Copy Table")
        onTriggered: {
            tabSeparated.rows = tableParam.param.value.count
            tabSeparated.columns = tableColumns
            for(var i = 0; i < tabSeparated.rows; ++i) {
                tabSeparated.set(i, 0, tableParam.param.x.get(i))
                tabSeparated.set(i, 1, tableParam.param.value.get(i))
            }
            Clipboard.setText(tabSeparated.text)
        }
    }
    Action {
        id: pasteTable
        text: qsTr("Paste Table")
        onTriggered: {
            tabSeparated.text = Clipboard.text
            if(tabSeparated.rows == tableParam.param.value.count && tabSeparated.columns == tableColumns) {
                for(var i = 0; i < tabSeparated.rows; ++i) {
                    if(tableParam.param.xStringModel.flags(i) & Qt.ItemIsEditable)
                        tableParam.param.x.set(i, tabSeparated.get(i, 0));
                    if(tableParam.param.valueStringModel.flags(i) & Qt.ItemIsEditable)
                        tableParam.param.value.set(i, tabSeparated.get(i, 1));
                }
            }
            else {
                pasteNoFitDialog.open()
            }
        }
    }
    readonly property int tableColumns: 2
    MessageDialog {
        id: pasteNoFitDialog
        title: qsTr("Error")
        text: qsTr("The data on the clipboard does not fit the table. The clipboard has %1 rows and %2 columns, but the table has %3 rows and %4 columns.".arg(tabSeparated.rows).arg(tabSeparated.columns).arg(tableParam.param.value.count).arg(tableColumns))
        standardButtons: StandardButton.Ok
    }

    TabSeparated {
        id: tabSeparated
    }

    property TableView tableView: regularTableParamEdit.tableView

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
            else if(event.key === Qt.Key_C && event.modifiers === Qt.ControlModifier)
                copyTable.trigger()
            else if(event.key === Qt.Key_V && event.modifiers === Qt.ControlModifier)
                pasteTable.trigger()
            else
                event.accepted = false
        }

        ChartView {
            id: plot

            Layout.fillWidth: true
            Layout.fillHeight: false
            Layout.minimumHeight: 250
            height: 250
            margins.left: 0
            margins.right: 0
            margins.bottom: 0
            margins.top: 0

            antialiasing: true
            legend.visible: false
            visible: hasPlot

            RoleModeledLineSeries {
                id: series1
                visible: root.tableParam.param.value.valid
                model: root.tableParam.param.floatModel

                axisX: autoAxis.xAxis
                axisY: autoAxis.yAxis
            }
        }

        XYSeriesAutoAxis {
            id: autoAxis
            series: [ series1 ]
            xAxis.titleText: xLabel
            yAxis.titleText: valueLabel
        }

        RowLayout {
            Layout.fillWidth: true
            Layout.fillHeight: true
            Layout.minimumHeight: 250
            spacing: 10
            id: rowLayout

            TableParamEdit {
                id: regularTableParamEdit
                xLabel: root.xLabel
                valueLabel: root.valueLabel
                tableMetaParam: root.tableParam
                Layout.margins: 10
                Layout.fillHeight: true
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
                Button {
                    Layout.fillWidth: true
                    action: copyTable
                }
                Button {
                    Layout.fillWidth: true
                    action: pasteTable
                }
            }
        }
    }
    AutoRefreshArea {
        base: rowLayout
    }
}
