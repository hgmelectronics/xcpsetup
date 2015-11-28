import QtQuick 2.5
import QtQuick.Controls 1.4
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

        Tab {
            active: true
            title: qsTr("Vehicle")
            VehicleLayout {
                parameters: params
            }
            visible: false
        }

        Tab {
            active: true
            title: qsTr("Engine")
            EngineLayout {
                parameters: params
            }
        }

        Tab {
            active: true
            title: qsTr("Trans")
            TransmissionLayout {
                parameters: params
            }
        }

        Tab {
            active: true
            title: qsTr("Shift Speeds")
            ShiftSpeedsLayout {
                parameters: params
            }
        }

        Tab {
            active: true
            title: qsTr("Shift Pressures %")
            PressurePercentageLayout {
                parameters: params
            }
        }

        Tab {
            active: true
            title: qsTr("Shift Pressures")
            PressureAbsoluteLayout {
                parameters: params
            }
        }

        Tab {
            active: true
            title: qsTr("TCC")
            TccLayout {
                parameters: params
            }
        }

        Tab {
            active: true
            title: qsTr("Diagnostics")
            DiagnosticsLayout {
                parameters: params
            }
        }

        Tab {
            active: true
            title: qsTr("Keypad")
            KeypadDisplayLayout {
                parameters: params
            }
        }

        Tab {
            active: true
            title: qsTr("CAN")
            CanLayout {
                parameters: params
            }
        }

        Tab {
            active: true
            title: qsTr("EV")
            EvLayout {
                parameters: params
            }
        }
    }
}
