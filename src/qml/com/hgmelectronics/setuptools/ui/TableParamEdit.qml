import QtQuick 2.5
import QtQuick.Controls 1.4
import QtQuick.Layouts 1.2
import com.hgmelectronics.setuptools 1.0
import com.hgmelectronics.setuptools.ui 1.0

Rectangle {
    id: root
    property string xLabel: tableParam.x.slot.unit
    property string valueLabel: tableParam.value.slot.unit
    property TableMetaParam tableMetaParam
    property TableParam tableParam: tableMetaParam.param
    property alias tableView: tableView
    width: tableView.implicitWidth
    height: tableView.implicitHeight
    property bool enableAutoRefreshOverlay: false // FIXME tableMetaParam.isLiveData


    property bool valueOnly: !(tableParam.xModel.flags(0) & Qt.ItemIsEditable) && (tableParam.valueModel.flags(0) & Qt.ItemIsEditable)
    property bool valueSelected: valueOnly
    property bool xSelected: false

    TableView {
        id: tableView
        anchors.fill: parent
        property real columnWidth: viewport.width / columnCount
        enabled: tableParam.valid

        model: root.tableParam.stringModel
        selectionMode: SelectionMode.ContiguousSelection

        TableViewColumn {
            id: xColumn
            role: "x"
            delegate: Component {
                Loader {
                    sourceComponent: (styleData.selected && (tableParam.xModel.flags(0) & Qt.ItemIsEditable)) ? xEditDelegate : xDisplayDelegate
                    Component {
                        id: xDisplayDelegate
                        Item {
                            property int implicitWidth: label.implicitWidth + 16

                            Text {
                                id: label
                                visible: !(tableParam.xModel.flags & Qt.ItemIsEditable)
                                height: Math.max(16, label.implicitHeight)
                                objectName: "label"
                                width: parent.width
                                //font: __styleitem.font
                                anchors.left: parent.left
                                anchors.right: parent.right
                                anchors.leftMargin: styleData["depth"] && styleData.column === 0 ? 0 : 8
                                horizontalAlignment: styleData.textAlignment
                                anchors.verticalCenter: parent.verticalCenter
                                elide: styleData.elideMode
                                text: styleData.value !== undefined ? styleData.value : ""
                                color: styleData.textColor
                                renderType: Text.NativeRendering
                            }
                        }
                    }
                    Component {
                        id: xEditDelegate
                        Item {
                            TextInput {
                                id: input
                                color: styleData.textColor
                                anchors.leftMargin: 7
                                anchors.fill: parent
                                horizontalAlignment: styleData.textAlignment
                                text: styleData.value !== undefined ? styleData.value : ""
                                validator: tableParam.x.slot.validator

                                onEditingFinished: {
                                    if(model[styleData.role] != text)
                                        model[styleData.role] = text
                                }
                                onAccepted: {
                                    if (styleData.selected)
                                        selectAll()
                                }

                                MouseArea {
                                    anchors.fill: parent
                                    onClicked: {
                                        forceActiveFocus(Qt.MouseFocusReason)
                                        valueSelected = false
                                        xSelected = true
                                    }
                                    onActiveFocusChanged: {
                                        if(activeFocus)
                                            input.selectAll()
                                        else
                                            input.deselect()
                                    }
                                }

                                Connections {
                                    target: styleData
                                    onSelectedChanged: {
                                        if(!styleData.selected) {
                                            input.deselect()
                                        }
                                    }
                                }

                                Component.onCompleted: {
                                    if(xSelected) {
                                        forceActiveFocus(Qt.MouseFocusReason)
                                        input.selectAll()
                                    }
                                }
                                Component.onDestruction: {
                                    if(model[styleData.role] != text)
                                        model[styleData.role] = text
                                }
                            }
                        }
                    }
                }
            }

            width: tableView.columnWidth
            title: xLabel
        }
        TableViewColumn {
            id: valueColumn
            role: "value"
            delegate: Loader {
                sourceComponent: (styleData.selected && (tableParam.valueModel.flags(0) & Qt.ItemIsEditable)) ? valueEditDelegate : valueDisplayDelegate

                Component {
                    id: valueDisplayDelegate
                    Item {
                        property int implicitWidth: label.implicitWidth + 16

                        Text {
                            id: label
                            visible: !(tableParam.xModel.flags & Qt.ItemIsEditable)
                            height: Math.max(16, label.implicitHeight)
                            objectName: "label"
                            width: parent.width
                            //font: __styleitem.font
                            anchors.left: parent.left
                            anchors.right: parent.right
                            anchors.leftMargin: styleData["depth"] && styleData.column === 0 ? 0 : 8
                            horizontalAlignment: styleData.textAlignment
                            anchors.verticalCenter: parent.verticalCenter
                            elide: styleData.elideMode
                            text: styleData.value !== undefined ? styleData.value : ""
                            color: styleData.textColor
                            renderType: Text.NativeRendering
                        }
                    }
                }
                Component {
                    id: valueEditDelegate
                    TextInput {
                        id: input
                        color: styleData.textColor
                        anchors.leftMargin: 7
                        anchors.fill: parent
                        text: styleData.value !== undefined ? styleData.value : ""
                        validator: tableParam.value.slot.validator

                        onEditingFinished: {
                            if(model[styleData.role] != text)
                                model[styleData.role] = text
                        }
                        onAccepted: {
                            if (styleData.selected)
                                selectAll()
                        }

                        MouseArea {
                            anchors.fill: parent
                            onClicked: {
                                valueSelected = true
                                xSelected = false
                                forceActiveFocus(Qt.MouseFocusReason)
                            }
                            onActiveFocusChanged: {
                                if(activeFocus)
                                    input.selectAll()
                                else
                                    input.deselect()
                            }
                        }

                        Connections {
                            target: styleData
                            onSelectedChanged: {
                                if(!styleData.selected) {
                                    input.deselect()
                                }
                            }
                        }

                        Component.onCompleted: {
                            if(valueSelected) {
                                forceActiveFocus(Qt.MouseFocusReason)
                                input.selectAll()
                            }
                        }
                        Component.onDestruction: {
                            if(model[styleData.role] != text)
                                model[styleData.role] = text
                        }
                    }
                }
            }
            width: tableView.columnWidth
            title: valueLabel
        }
    }

//    AutoRefreshOverlay {
//        key: param.key
//        visible: enableAutoRefreshOverlay
//        enabled: enableAutoRefreshOverlay
//    }
}
