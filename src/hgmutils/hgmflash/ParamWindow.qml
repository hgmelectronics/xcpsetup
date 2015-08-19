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
            Flow {
                anchors.fill: parent
                anchors.margins: 10
                spacing: 10
                ScalarParamEdit {
                    name: "Display Brightness"
                    param: registry.addScalarParam(MemoryRange.U32, 0x01020000, true, true, slots.percentage1)
                }
                ScalarParamEdit {   // duplicate to illustrate binding
                    name: "Display Brightness"
                    param: registry.addScalarParam(MemoryRange.U32, 0x01020000, true, true, slots.percentage1)
                }
            }
        }
        Tab {
            title: "Ratios And More"
            Flow {
                anchors.fill: parent
                anchors.margins: 10
                spacing: 10
                ScalarParamEdit {
                    name: "Final Drive Ratio"
                    param: registry.addScalarParam(MemoryRange.U32, 0x0A000000, true, true, slots.ratio1)
                }
                ScalarParamEdit {
                    name: "Max Engine Speed A"
                    param: registry.addScalarParam(MemoryRange.U32, 0x04230000, true, true, slots.rpm1)
                }
            }
        }
        Tab {
            title: "Foo"
            Flow {
                anchors.fill: parent
                anchors.margins: 10
                spacing: 10
                ScalarParamEdit {   // duplicate to illustrate binding
                    name: "Display Brightness"
                    param: registry.addScalarParam(MemoryRange.U32, 0x01020000, true, true, slots.percentage1)
                }
            }
        }
        Tab {
            title: "Bar"
            Flow {
                anchors.fill: parent
                anchors.margins: 10
                spacing: 10
                ScalarParamEdit {   // duplicate to illustrate binding
                    name: "Display Brightness"
                    param: registry.addScalarParam(MemoryRange.U32, 0x01020000, true, true, slots.percentage1)
                }
            }
        }
    }
}
