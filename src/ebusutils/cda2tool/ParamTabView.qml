import QtQuick 2.5
import QtQuick.Controls 1.4
import QtQuick.Layouts 1.2
import QtQuick.Window 2.2
import QtQuick.Dialogs 1.2
import com.hgmelectronics.setuptools.xcp 1.0
import com.hgmelectronics.setuptools 1.0

Item {
    id: root
    property ParamRegistry registry
    anchors.left: parent.left
    anchors.right: parent.right
    TabView {
        id: tabView
        anchors.fill: parent

        Parameters {
            id: parameters
            registry: root.registry
        }

        Tab {
            title: "Analog I/O"
            active: true
            TableParamEdit {
                name: "AI"
                xLabel: "#"
                valueLabel: "cts"
                tableModel: parameters.aioAiCts
            }
            ScalarParamEdit {
                name: "VBat"
                param: parameters.aioVbatEv01
            }
        }

        Tab {
            title: "CBTM"
            active: true
            Flow {
                anchors.fill: parent
                anchors.margins: 10
                spacing: 10
                ColumnLayout {
                    ScalarParamEdit {
                        name: "IsoSPI #1 First Board"
                        param: parameters.cbtmIsospi1FirstBoard
                    }
                    ScalarParamEdit {
                        name: "IsoSPI #1 Last Board"
                        param: parameters.cbtmIsospi1LastBoard
                    }
                    ScalarParamEdit {
                        name: "IsoSPI #2 First Board"
                        param: parameters.cbtmIsospi2FirstBoard
                    }
                    ScalarParamEdit {
                        name: "IsoSPI #2 Last Board"
                        param: parameters.cbtmIsospi2LastBoard
                    }
                }
                TableParamEdit {
                    name: "Cell Voltage"
                    xLabel: "Cell #"
                    valueLabel: "V"
                    tableModel: parameters.cbtmCellVolt
                }
                TableParamEdit {
                    name: "Tab Temp"
                    xLabel: "Tab #"
                    valueLabel: "degC"
                    tableModel: parameters.cbtmTabTemp
                }
                TableParamEdit {
                    name: "Discharge"
                    xLabel: "Board #"
                    valueLabel: "Bitfield"
                    tableModel: parameters.cbtmDisch
                }
                TableParamEdit {
                    name: "Status"
                    xLabel: "Board #"
                    valueLabel: "Bitfield"
                    tableModel: parameters.cbtmStatus
                }
            }
        }

        Tab {
            title: "Contactor"
            active: true
            Flow {
                anchors.fill: parent
                anchors.margins: 10
                spacing: 10
                ScalarParamEdit {
                    name: "Max Simul Pickups"
                    param: parameters.ctcMaxSimulPickup
                }
                TableParamEdit {
                    name: "Has B input"
                    xLabel: "Ctc #"
                    valueLabel: "Bool"
                    tableModel: parameters.ctcHasBInput
                }
                TableParamEdit {
                    name: "On"
                    xLabel: "Ctc #"
                    valueLabel: "Bool"
                    tableModel: parameters.ctcOn
                }
                TableParamEdit {
                    name: "OK"
                    xLabel: "Ctc #"
                    valueLabel: "Bool"
                    tableModel: parameters.ctcOk
                }
                TableParamEdit {
                    name: "A Closed"
                    xLabel: "Ctc #"
                    valueLabel: "Bool"
                    tableModel: parameters.ctcAClosed
                }
                TableParamEdit {
                    name: "B Closed"
                    xLabel: "Ctc #"
                    valueLabel: "Bool"
                    tableModel: parameters.ctcBClosed
                }
            }
        }
    }
}
