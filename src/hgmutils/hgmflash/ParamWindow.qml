import QtQuick 2.5
import QtQuick.Controls 1.4
import QtQuick.Layouts 1.2
import QtQuick.Window 2.2
import QtQuick.Dialogs 1.2
import com.setuptools.xcp 1.0
import com.setuptools 1.0

Window {
    id: paramWindow

    property ParamRegistry registry

    function show() {
        visible = true
    }

    title: "CS2 Parameter Editor"
    width: 600
    height: 400
    SystemPalette { id: myPalette; colorGroup: SystemPalette.Active }
    color: myPalette.window

    Parameters
    {
        id: parameters
        registry: paramWindow.registry
    }


    TabView {
        id: paramTabView
        anchors.fill: parent
        Tab {
            title: "Vehicle"
            active: true
            Flow {
                anchors.fill: parent
                anchors.margins: 10
                spacing: 10
                ScalarParamSpinBox {
                    name: "Final Drive Ratio"
                    param: parameters.finalDriveRatio
                }

                ScalarParamSpinBox {
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

                ScalarParamSpinBox{
                    name: "Engine Cylinders"
                    param: parameters.engineCylinders
                }

                ScalarParamSpinBox {
                    name: "Max Engine Speed A"
                    param: parameters.maxEngineSpeedA
                }
                ScalarParamSpinBox {
                    name: "Max Engine Speed B"
                    param: parameters.maxEngineSpeedB
                }

            }
        }


        //        Tab
        //        {
        //            active:true
        //            var chartLineData = {
        //                labels: ["January","February","March","April","May","June","July"],
        //                datasets: [{
        //                        fillColor: "rgba(220,220,220,0.5)",
        //                        strokeColor: "rgba(220,220,220,1)",
        //                        pointColor: "rgba(220,220,220,1)",
        //                        pointStrokeColor: "#ffffff",
        //                        data: [65,59,90,81,56,55,40]
        //                    }, {
        //                        fillColor: "rgba(151,187,205,0.5)",
        //                        strokeColor: "rgba(151,187,205,1)",
        //                        pointColor: "rgba(151,187,205,1)",
        //                        pointStrokeColor: "#ffffff",
        //                        data: [28,48,40,19,96,27,100]
        //                    }]
        //            }


        //            QChart {
        //                id: chart_line;
        //                width: chart_width;
        //                height: chart_height;
        //                chartAnimated: true;
        //                chartAnimationEasing: Easing.InOutElastic;
        //                chartAnimationDuration: 2000;
        //                chartData: chartsData.ChartLineData;
        //                chartType: Charts.ChartType.LINE;
        //            }
        //        }


        ShiftTableTab {
            title: "A Shift Tables"
            active: true
            shiftTables: parameters.shiftTablesA
            throttleSlot: parameters.slots.percentage1
        }

        ShiftTableTab {
            title: "B Shift Tables"
            active: true
            shiftTables: parameters.shiftTablesB
            throttleSlot: parameters.slots.percentage1
        }


        Tab {
            title: "Inputs"
            active: true
            Flow {
                anchors.fill: parent
                anchors.margins: 10
                spacing: 10
                TableParamView2 {
                    name: "Switch Monitor Input"
                    param: parameters.switchMonitorInput
                    xSlot: parameters.slots.switchId
                    //                    Component.onCompleted: {
                    //                        param.xLabel = "Switch #"
                    //                        param.valueLabel = "State"
                    //                    }
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

                ScalarParamSpinBox {   // duplicate to illustrate binding
                    name: "Display Brightness"
                    param: parameters.displayBrightness
                }

                ScalarParamSpinBox {   // duplicate to illustrate binding
                    name: "Display Contrast"
                    param: parameters.displayBrightness
                }
            }
        }
    }
}
