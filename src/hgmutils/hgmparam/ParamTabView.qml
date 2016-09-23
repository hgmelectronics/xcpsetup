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
    property Parameters registry
    anchors.left: parent.left
    anchors.right: parent.right


    TabView {
        id: tabView
        anchors.fill: parent

        Tab {
            active: true
            title: qsTr("Vehicle")
            VehicleLayout {
                parameters: root.registry
            }
            visible: false
        }

        Tab {
            active: true
            title: qsTr("Engine")
            EngineLayout {
                parameters: registry
            }
        }

        Tab {
            active: true
            title: qsTr("Trans")
            TransmissionLayout {
                parameters: registry
            }
        }

        Tab {
            active: true
            title: qsTr("Shift Speeds")
            ShiftSpeedsLayout {
                parameters: registry
            }
        }

        Tab {
            active: true
            title: qsTr("Shift Control")
            PressureLayout {
                parameters: registry
            }
        }

        Tab {
            active: true
            title: qsTr("TC")
            TcLayout {
                parameters: registry
            }
        }

        Tab {
            active: true
            title: qsTr("Diagnostics")
            DiagnosticsLayout {
                parameters: registry
            }
        }

        Tab {
            active: true
            title: qsTr("Keypad")
            KeypadDisplayLayout {
                parameters: registry
            }
        }

        Tab {
            active: true
            title: qsTr("CAN")
            CanLayout {
                parameters: registry
            }
        }

        Tab {
            active: true
            title: qsTr("EV")
            EvLayout {
                parameters: registry
            }
        }
    }
}
