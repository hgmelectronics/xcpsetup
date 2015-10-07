import QtQuick 2.5
import QtQuick.Controls 1.4
import QtQuick.Controls.Styles 1.4
import QtQuick.Layouts 1.2
import QtQuick.Window 2.2
import QtQuick.Dialogs 1.2
import com.hgmelectronics.setuptools.xcp 1.0
import com.hgmelectronics.setuptools 1.0
import com.hgmelectronics.setuptools.ui 1.0

Item {
    id: root
    property alias useMetricUnits: params.useMetricUnits
    property ParamRegistry registry
    anchors.left: parent.left
    anchors.right: parent.right

    Parameters {
        id: params
        registry: root.registry
    }

    TabView {
        id: tabView
        anchors.fill: parent

        style: TabViewStyle {
            tabOverlap: 0
        }

        Tab {
            title: qsTr("Vehicle")
            VehicleLayout {
                parameters: params
            }
            visible: false
        }

        Tab {
            title: qsTr("Engine")
            EngineLayout {
                parameters: params
            }
        }

        Tab {
            title: qsTr("Trans")
            TransmissionLayout {
                parameters: params
            }
        }

        Tab {
            title: qsTr("Shift Speeds")
            ShiftSpeedsLayout {
                parameters: params
            }
        }

        Tab {
            title: qsTr("Shift Pressures %")
            PressurePercentageLayout {
                parameters: params
            }
        }

        Tab {
            title: qsTr("Shift Pressures")
            PressureAbsoluteLayout {
                parameters: params
            }
        }

        Tab {
            title: qsTr("TCC")
            TccLayout {
                parameters: params
            }
        }

        Tab {
            title: qsTr("Diagnostics")
            DiagnosticsLayout {
                parameters: params
            }
        }

        Tab {
            title: qsTr("Keypad")
            KeypadDisplayLayout {
                parameters: params
            }
        }

        Tab {
            title: qsTr("CAN")
            CanLayout {
                parameters: params
            }
        }

//        Tab {
//            title: qsTr("EV")
//            EvLayout {
//                parameters: params
//            }
//        }
    }
}
