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

    Axes {
        id: axes
    }
    
    TabView {
        id: paramTabView
        anchors.fill: parent
        Tab {
            title: "System"
            active: true
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
            active: true
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
            title: "Tables"
            active: true
            Flow {
                anchors.fill: parent
                anchors.margins: 10
                spacing: 10
                TableParamView {
                    name: "Switch Monitor Input"
                    param: registry.addTableParam(MemoryRange.U32, 0x80500000, false, false, slots.booleanOnOff1, axes.switchMonitorId);
                    Component.onCompleted: {
                        param.xLabel = "Switch #"
                        param.valueLabel = "State"
                    }
                }
                TableParamEdit {
                    name: "Shift Table 1-2 A"
                    param: registry.addTableParam(MemoryRange.U32, 0x04240000, true, true, slots.rpm1, axes.percentage1);
                    Component.onCompleted: {
                        param.xLabel = "TPS"
                        param.valueLabel = "TOSS"
                    }
                }
            }
        }
        Tab {
            title: "Bar"
            active: true
            Flow {
                anchors.fill: parent
                anchors.margins: 10
                spacing: 10
                ScalarParamEdit {   // duplicate to illustrate binding
                    name: "Display Brightness"
                    param: registry.addScalarParam(MemoryRange.U32, 0x01020000, true, true, slots.percentage1)
                }
                EncodingParamEdit {
                    name: "Spaceball 1 Speed"
                    param: registry.addScalarParam(MemoryRange.U32, 0xFEDC0000, true, true, slots.spaceball1)
                }
            }
        }
    }
}
