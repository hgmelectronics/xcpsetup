import QtQuick 2.5
import QtQuick.Controls 1.4
import QtQuick.Layouts 1.2
import com.hgmelectronics.setuptools 1.0
import com.hgmelectronics.setuptools.ui 1.0

Rectangle {
    id: root
    property var label: {
        var ret = ({})
        tableParam.roleNames.forEach(function(role) {
            ret[role] = tableParam.roleMapping[role].slot.unit
        })
        return ret
    }

    property MultiroleTableMetaParam tableMetaParam
    property MultiroleTableParam tableParam: tableMetaParam.param
    property alias tableView: tableView
    width: tableView.implicitWidth
    height: tableView.implicitHeight
    property bool enableAutoRefreshOverlay: false // FIXME tableMetaParam.isLiveData
    property var roleNames: tableParam.roleNames

    property var editableRoleNames: {
        var ret = []
        tableParam.roleNames.forEach(function(role) {
            if(tableParam.model[role].flags(0) & Qt.ItemIsEditable)
                ret.push(role)
        })
        return ret
    }
    property string selectedRoleName: editableRoleNames.length > 0 ? editableRoleNames[0] : ""

    TableView {
        id: tableView
        anchors.fill: parent
        property real columnWidth: viewport.width / columnCount
        enabled: tableParam.valid

        model: root.tableParam.stringModel
        selectionMode: SelectionMode.ContiguousSelection

        Instantiator {
            model: roleNames.length

            onObjectAdded: tableView.insertColumn(index, object)
            onObjectRemoved: tableView.removeColumn(index)

            TableViewColumn {
                id: col
                role: root.roleNames[index]
                delegate: Component {
                    Loader {
                        sourceComponent: (styleData.selected && (root.tableParam.model[styleData.role].flags(0) & Qt.ItemIsEditable)) ? editDelegate : displayDelegate
                        Component {
                            id: displayDelegate
                            Item {
                                property int implicitWidth: label.implicitWidth + 16

                                Text {
                                    id: label
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

                                    MouseArea {
                                        anchors.fill: parent
                                        propagateComposedEvents: true
                                        onPressed: {
                                            mouse.accepted = false
                                            forceActiveFocus(Qt.MouseFocusReason)
                                            selectedRoleName = role
                                        }
                                        onReleased: mouse.accepted = false
                                        onDoubleClicked: mouse.accepted = false
                                        onPositionChanged: mouse.accepted = false
                                        onPressAndHold: mouse.accepted = false
                                        onClicked: mouse.accepted = false
                                    }
                                }
                            }
                        }
                        Component {
                            id: editDelegate
                            Item {
                                TextInput {
                                    id: input
                                    color: styleData.textColor
                                    anchors.leftMargin: 7
                                    anchors.fill: parent
                                    horizontalAlignment: styleData.textAlignment
                                    text: styleData.value !== undefined ? styleData.value : ""
                                    validator: root.tableParam.roleMapping[styleData.role].slot.validator

                                    function updateValue() {
                                        if(model[styleData.role] != text)
                                            model[styleData.role] = text
                                        if(root.tableMetaParam.immediateWrite)
                                            ImmediateWrite.trigger(root.tableParam.roleMapper[styleData.role].key)
                                    }

                                    onEditingFinished: updateValue()
                                    onAccepted: {
                                        if (styleData.selected)
                                            selectAll()
                                    }

                                    MouseArea {
                                        anchors.fill: parent
                                        propagateComposedEvents: true
                                        onReleased: mouse.accepted = false
                                        onDoubleClicked: mouse.accepted = false
                                        onPositionChanged: mouse.accepted = false
                                        onPressAndHold: mouse.accepted = false
                                        onClicked: {
                                            mouse.accepted = false
                                            forceActiveFocus(Qt.MouseFocusReason)
                                            selectedRoleName = role
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
                                        if(role == selectedRoleName) {
                                            forceActiveFocus(Qt.MouseFocusReason)
                                            input.selectAll()
                                        }
                                    }
                                    Component.onDestruction: updateValue()
                                }
                            }
                        }
                    }
                }

                width: tableView.columnWidth
                title: label[role]
            }
        }
    }

//    AutoRefreshOverlay {
//        key: param.key
//        visible: enableAutoRefreshOverlay
//        enabled: enableAutoRefreshOverlay
//    }
}
