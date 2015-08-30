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

//        Tab {
//            title: "Analog I/O"
//            active: true
//            Flow {
//                anchors.fill: parent
//                anchors.margins: 10
//                spacing: 10
//                ScalarParamEdit {
//                    name: "Final Drive Ratio"
//                    param: registry.addScalarParam(MemoryRange.U32, 0x0A000000*4, true, true, slots.raw32)
//                }
//                ScalarParamEdit {
//                    name: "Max Engine Speed A"
//                    param: registry.addScalarParam(MemoryRange.U32, 0x04230000*4, true, true, slots.raw32)
//                }
//            }
//        }

//        Tab {
//            title: "CBTM"
//            active: true
//            Flow {
//                anchors.fill: parent
//                anchors.margins: 10
//                spacing: 10
//                TableParamEdit {
//                    name: "Cell Voltage"
//                    param: registry.addTableParam(MemoryRange.U32, 0x00031000*4, false, false, slots.ltcCellv, axes.cellV);
//                    Component.onCompleted: {
//                        param.xLabel = "Num"
//                        param.valueLabel = "V"
//                    }
//                }
//                TableParamEdit {
//                    name: "Tab Temp"
//                    param: registry.addTableParam(MemoryRange.U32, 0x00032000*4, false, false, slots.ltcTemp, axes.cellV);
//                    Component.onCompleted: {
//                        param.xLabel = "Num"
//                        param.valueLabel = "degC"
//                    }
//                }
//                TableParamEdit {
//                    name: "Discharge"
//                    param: registry.addTableParam(MemoryRange.U32, 0x00033000*4, true, false, slots.raw32, axes.cbtmId);
//                    Component.onCompleted: {
//                        param.xLabel = "Num"
//                        param.valueLabel = "8bit"
//                    }
//                }
//                TableParamEdit {
//                    name: "Status"
//                    param: registry.addTableParam(MemoryRange.U32, 0x00033100*4, false, false, slots.raw32, axes.cbtmId);
//                    Component.onCompleted: {
//                        param.xLabel = "Num"
//                        param.valueLabel = "8bit"
//                    }
//                }
//            }
//        }
        Tab {
            title: "Contactor"
            active: true
            Flow {
                anchors.fill: parent
                anchors.margins: 10
                spacing: 10
                ScalarParamEdit {
                    name: "Max Simul Pickups"
                    param: registry.addScalarParam(MemoryRange.U32, 0x00040000*4, true, true, slots.raw32)
                }
                ScalarParamEdit {
                    name: "Ctc 1 On"
                    param: registry.addScalarParam(MemoryRange.U32, 0x00041000*4, true, true, slots.raw32)
                }
//                TableParamEdit {
//                    name: "Has B input"
//                    param: registry.addTableParam(MemoryRange.U32, 0x00040010*4, true, true, slots.raw32, axes.ctcNum);
//                    Component.onCompleted: {
//                        param.xLabel = "Num"
//                        param.valueLabel = "Bool"
//                    }
//                }
//                TableParamEdit {
//                    name: "On"
//                    param: registry.addTableParam(MemoryRange.U32, 0x00041000*4, true, false, slots.raw32, axes.ctcNum);
//                    Component.onCompleted: {
//                        param.xLabel = "Num"
//                        param.valueLabel = "Bool"
//                    }
//                }
//                TableParamEdit {
//                    name: "OK"
//                    param: registry.addTableParam(MemoryRange.U32, 0x00041010*4, false, false, slots.raw32, axes.ctcNum);
//                    Component.onCompleted: {
//                        param.xLabel = "Num"
//                        param.valueLabel = "Bool"
//                    }
//                }
//                TableParamEdit {
//                    name: "A Closed"
//                    param: registry.addTableParam(MemoryRange.U32, 0x00041020*4, false, false, slots.raw32, axes.ctcNum);
//                    Component.onCompleted: {
//                        param.xLabel = "Num"
//                        param.valueLabel = "Bool"
//                    }
//                }
//                TableParamEdit {
//                    name: "B Closed"
//                    param: registry.addTableParam(MemoryRange.U32, 0x00041030*4, false, false, slots.raw32, axes.ctcNum);
//                    Component.onCompleted: {
//                        param.xLabel = "Num"
//                        param.valueLabel = "Bool"
//                    }
//                }
            }
        }
    }
}
