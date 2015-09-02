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

        Parameters
        {
            id: parameters
            registry: root.registry
        }

        Tab {
            title: "Vehicle"
            active: true
            Flow {
                anchors.fill: parent
                anchors.margins: 10
                spacing: 10
                ScalarParamEdit {
                    name: "Final Drive Ratio"
                    param: parameters.finalDriveRatio
                }
                ScalarParamEdit {
                    name: "Tire Diameter"
                    param: parameters.tireDiameter
                }
            }
        }

        Tab {
            title: "Engine"
            active: true
            Flow {
                anchors.fill: parent
                anchors.margins: 10
                spacing: 10

                ScalarParamEdit{
                    name: "Engine Cylinders"
                    param: parameters.engineCylinders
                }

                ScalarParamEdit {
                    name: "Max Engine Speed A"
                    param: parameters.maxEngineSpeedA
                }
                ScalarParamEdit {
                    name: "Max Engine Speed B"
                    param: parameters.maxEngineSpeedB
                }

            }
        }

        Tab {


            title: "Shift Tables"
            active: true
            Flow {
                anchors.fill: parent
                anchors.margins: 10
                spacing: 10

                function bump(p)
                {
                    for(var i=0; i<p.count ; i++)
                    {
                        p.set(i,p.get(i)+1.0);
                    }
                }

                function zero(p)
                {
                    for(var i=0; i<p.count ; i++)
                    {
                        p.set(i,0.0);
                    }
                }


                Button
                {
                    text: "Zero"
                    onClicked: {
                        zero(parameters.shiftTable12A);
                        zero(parameters.shiftTable23A);
                        zero(parameters.shiftTable34A);
                        zero(parameters.shiftTable45A);
                        }
                }



                Button
                {
                    text: "Bump 1-2"
                    onClicked: {
                        bump(parameters.shiftTable12A)
                    }
                }

                Button
                {
                    text: "Bump 2-3"
                    onClicked: {
                        bump(parameters.shiftTable23A)
                    }
                }

                Button
                {
                    text: "Bump 3-4"
                    onClicked: {
                        bump(parameters.shiftTable34A)
                    }
                }

                Button
                {
                    text: "Bump 4-5"
                    onClicked: {
                        bump(parameters.shiftTable45A)
                    }
                }

                TableView
                {
                    width: 600;

                    model: parameters.shiftTableAModel

                    TableViewColumn {
                        role: "tps"
                        title: "TPS %"
                        width: 100
                    }
                    TableViewColumn {
                        role: "shift12"
                        title: "Shift 1-2"
                        width: 100
                    }
                    TableViewColumn {
                        role: "shift23"
                        title: "Shift 2-3"
                        width: 100
                    }
                    TableViewColumn {
                        role: "shift34"
                        title: "Shift 3-4"
                        width: 100
                    }
                    TableViewColumn {
                        role: "shift45"
                        title: "Shift 4-5"
                        width: 100
                    }

                }

                TableParamEdit {
                    id: shift12
                    name: "Shift Speed 1-2 A"
                    xLabel: "Throttle"
                    valueLabel: "Speed"
                    tableModel: parameters.shiftTable12AModel
                    enabled: parameters.shiftTable12A.valid
                }


                TableParamEdit {
                    name: "Shift Speed 2-3 A"
                    xLabel: "Throttle"
                    valueLabel: "Speed"
                    tableModel: parameters.shiftTable23AModel
                    enabled: parameters.shiftTable23A.valid
                }

                TableParamEdit {
                    name: "Shift Speed 3-4 A"
                    xLabel: "Throttle"
                    valueLabel: "Speed"
                    tableModel: parameters.shiftTable34AModel
                    enabled: parameters.shiftTable34A.valid
                }
                TableParamEdit {
                    name: "Shift Speed 4-5 A"
                    xLabel: "Throttle"
                    valueLabel: "Speed"
                    tableModel: parameters.shiftTable45AModel
                    enabled: parameters.shiftTable45A.valid
                }
            }
        }


        Tab {
            title: "Inputs"
            active: true
            Flow {
                anchors.fill: parent
                anchors.margins: 10
                spacing: 10
                TableParamView {
                    name: "Switch Monitor Input"
                    xLabel: "Switch #"
                    valueLabel: "State"
                    tableModel: parameters.switchMonitorModel
                    enabled: parameters.switchMonitorInput.valid
                }
            }
        }

        Tab {
            title: "Accessories"
            active: true
            Flow {
                anchors.fill: parent
                anchors.margins: 10
                spacing: 10

                ScalarParamEdit {   // duplicate to illustrate binding
                    name: "Display Brightness"
                    param: parameters.displayBrightness
                }

                ScalarParamEdit {   // duplicate to illustrate binding
                    name: "Display Contrast"
                    param: parameters.displayBrightness
                }
            }
        }
    }
}