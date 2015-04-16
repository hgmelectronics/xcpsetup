import QtQuick 2.4
import QtQuick.Controls 1.3
import QtQuick.Window 2.2
import QtQuick.Dialogs 1.2
import com.setuptools.examples.multilist_demo 1.0

ApplicationWindow {
    title: qsTr("Hello World")
    width: testing.width + 20
    height: 300
    visible: true

    menuBar: MenuBar {
        Menu {
            title: qsTr("&File")
            MenuItem {
                text: qsTr("E&xit")
                onTriggered: Qt.quit();
            }
        }
    }


    Rectangle {
        anchors.fill: parent
        ScrollView {
            width: 400
            height: parent.height
            ListView {
                id: testing
                anchors.fill: parent
                model: multiselectListModel
                MultiselectListController {
                    id: controller
                }

                delegate: Component {
                    Rectangle {
                        width: testing.width
                        height: 30
                        color: model.wrapper.selected ? "#00B8F5" : "#EEE"
                        Text {
                            elide: Text.ElideRight
                            text: model.wrapper.displayText
                            color: model.wrapper.selected ? "white" : "black"
                            anchors {
                                verticalCenter: parent.verticalCenter
                                left: parent.left
                                leftMargin: 5
                            }
                        }
                        MouseArea {
                            anchors.fill: parent
                            onClicked: {
                                controller.clicked(mouse.modifiers, multiselectListModel, model.wrapper)
                            }
                        }
                    }
                }
            }
        }
    }
}
