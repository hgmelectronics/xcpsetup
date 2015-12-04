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
    property int scalarColumnWidth: 100
    property int encodingColumnWidth: 150

    property var editableRoleNames: {
        var ret = []
        tableParam.roleNames.forEach(function(role) {
            if(tableParam.model[role].flags(0) & Qt.ItemIsEditable)
                ret.push(role)
        })
        return ret
    }
    property string selectedRoleName: editableRoleNames.length > 0 ? editableRoleNames[0] : ""

    property bool hasEncoding: {
        for(var i = 0; i < tableParam.roleNames.length; ++i) {
            if(typeof(tableParam.roleMapping[roleNames[i]].slot.encodingStringList) !== "undefined")
                return true
        }
        return false
    }

    TableView {
        id: tableView
        anchors.fill: parent
        property real columnWidth: viewport.width / columnCount
        enabled: tableParam.valid

        model: root.tableParam.stringModel
        selectionMode: SelectionMode.ContiguousSelection

        rowDelegate: Rectangle {
            height: hasEncoding ? 24 : 16
            property TableView control: tableView
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

        Instantiator {
            model: roleNames.length

            onObjectAdded: tableView.insertColumn(index, object)
            onObjectRemoved: tableView.removeColumn(index)

            TableViewColumn {
                id: col
                role: root.roleNames[index]
                width: (typeof(root.tableParam.roleMapping[role].slot.encodingStringList) !== "undefined") ? encodingColumnWidth : scalarColumnWidth
                delegate: Component {
                    Loader {
                        sourceComponent: {
                            if(typeof(root.tableParam.roleMapping[styleData.role].slot.encodingStringList) == "undefined") {
                                // Not encoding
                                if(styleData.selected
                                        && (root.tableParam.model[styleData.role].flags(0) & Qt.ItemIsEditable))
                                    return editDelegate
                                else
                                    return displayDelegate
                            }
                            else {
                                return encodingDelegate
                            }
                        }
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
                                property int implicitWidth: input.implicitWidth + 16
                                TextInput {
                                    id: input
                                    color: styleData.textColor
                                    anchors.leftMargin: 8
                                    anchors.fill: parent
                                    verticalAlignment: Qt.AlignVCenter
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
                        Component {
                            id: encodingDelegate
                            Item {
                                property int implicitWidth: combo.implicitWidth + 16
                                id: modelForwarder
                                property var dataModel: model[styleData.role]
                                ComboBox {
                                    id: combo
                                    model: tableParam.roleMapping[styleData.role].slot.encodingStringList
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
                    }
                }

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
