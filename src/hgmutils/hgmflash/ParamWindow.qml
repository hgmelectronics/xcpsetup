import QtQuick 2.5
import QtQuick.Controls 1.4
import QtQuick.Layouts 1.2
import QtQuick.Window 2.2
import QtQuick.Dialogs 1.2
import com.setuptools.xcp 1.0
import com.setuptools 1.0

Window {
    property ParamRegistry registry

    id: paramWindow
    title: "CS2 Parameter Editor"

    width: 600
    height: 400
    SystemPalette { id: myPalette; colorGroup: SystemPalette.Active }
    color: myPalette.window

    function show() {
        visible = true
    }

    Slots {
        id: slots
    }
    
    TabView {
        id: paramTabView
        anchors.fill: parent
        Tab {
            title: "System"
            Rectangle {
                color: myPalette.window
                Flow {
                    anchors.fill: parent
                    anchors.margins: 10
                    RowLayout {
                        Label { text: "Display Brightness" }

                        TextField {
                            property ScalarParam param: registry.addScalarParam(MemoryRange.U32, 0x01020000, true, true, slots.percentage1)
                            text: param.stringVal
                            onEditingFinished: param.stringVal = text
                        }
                    }
                }
            }
        }
        Tab {
            title: "Gear Ratios"
            Flow {
                
            }
        }
        Tab {
            title: "Foo"
            Flow {
                
            }
        }
        Tab {
            title: "Bar"
            Flow {
                
            }
        }
    }
}
