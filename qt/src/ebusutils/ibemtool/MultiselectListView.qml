import QtQuick 2.4
import QtQuick.Controls 1.3
import com.ebus.ui.multiselectlist 1.0

Rectangle {
    property alias model: listView.model
    property int rowHeight: 30
    property int rowLeftMargin: 5
    property string selectedBgColor: "#00B8F5"
    property string selectedTextColor: "#FFFFFF"
    property string unselectedBgColor: "#EEEEEE"
    property string unselectedTextColor: "#000000"
    id: root
    color: unselectedBgColor

    ScrollView {

        anchors.fill: parent
        ListView {
            id: listView
            anchors.fill: parent
            MultiselectListController {
                id: controller
            }

            delegate: Component {
                Rectangle {
                    id: delegateRect
                    width: listView.width
                    height: root.rowHeight
                    color: model.wrapper.selected ? root.selectedBgColor : root.unselectedBgColor
                    Text {
                        id: delegateText
                        elide: Text.ElideRight
                        text: model.wrapper.displayText
                        color: model.wrapper.selected ? root.selectedTextColor : root.unselectedTextColor
                        anchors {
                            verticalCenter: parent.verticalCenter
                            left: parent.left
                            leftMargin: root.rowLeftMargin
                        }
                    }
                    MouseArea {
                        anchors.fill: parent
                        onClicked: {
                            controller.clicked(mouse.modifiers, listView.model, model.wrapper)
                        }
                    }
                }
            }
        }
    }
}
