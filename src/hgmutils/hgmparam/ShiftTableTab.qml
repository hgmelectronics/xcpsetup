import QtQuick 2.5
import QtQuick.Controls 1.4
import QtQuick.Layouts 1.2
import QtQuick.Window 2.2
import QtQuick.Dialogs 1.2
import com.setuptools.xcp 1.0
import com.setuptools 1.0

Tab {
    active: true
    property var shiftTables
    property LinearSlot throttleSlot
    readonly property string speedUnit: shiftTables[0].slot.unit

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
                zero(shiftTables[0]);
                zero(shiftTables[1]);
                zero(shiftTables[2]);
            }
        }


        Button
        {
            text: "Bump 1-2"
            onClicked: {
                bump(shiftTables[0])
            }
        }

        Button
        {
            text: "Bump 2-3"
            onClicked: {
                bump(shiftTables[1])
            }
        }

        Button
        {
            text: "Bump 3-4"
            onClicked: {
                bump(shiftTables[2])
            }
        }

        TableView {
            id:tableView
            width: 600;

            model:
                TableParamMapper {
                stringFormat: true
                mapping: { "shift12": shiftTables[0],
                           "shift23": shiftTables[1],
                           "shift34": shiftTables[2],
                           "shift45": shiftTables[3],
                           "shift56": shiftTables[4]
                }
            }

            TableViewColumn {
                title: "Throttle %"
                delegate: Component {
                    Text {
                        elide: styleData.elideMode
                        text: throttleSlot.asString(styleData.row)
                        color: styleData.textColor
                    }
                }

                width: tableView.viewport.width / tableView.columnCount
            }

            TableViewColumn {
                role: "shift12"
                title: "Shift 1-2, " + speedUnit
                width: tableView.viewport.width / tableView.columnCount
            }
            TableViewColumn {
                role: "shift23"
                title: "Shift 2-3, " + speedUnit
                width: tableView.viewport.width / tableView.columnCount
            }

            TableViewColumn {
                role: "shift34"
                title: "Shift 3-4, " + speedUnit
                width: tableView.viewport.width / tableView.columnCount
            }

            TableViewColumn {
                role: "shift45"
                title: "Shift 4-5, " + speedUnit
                width: tableView.viewport.width / tableView.columnCount
            }
            TableViewColumn {
                role: "shift56"
                title: "Shift 5-6, " + speedUnit
                width: tableView.viewport.width / tableView.columnCount
            }
        }

        TableParamEdit {
            name: "Shift Speed 1-2"
            xLabel: "Throttle"
            yLabel: "Speed"
            param: shiftTables[0]
        }


        TableParamEdit {
            name: "Shift Speed 2-3"
            xLabel: "Throttle"
            yLabel: "Speed"
            param: shiftTables[1]
        }

        TableParamEdit {
            name: "Shift Speed 3-4"
            xLabel: "Throttle"
            yLabel: "Speed"
            param: shiftTables[2]
        }

        TableParamEdit {
            name: "Shift Speed 4-5"
            xLabel: "Throttle"
            yLabel: "Speed"
            param: shiftTables[3]
        }

        TableParamEdit {
            name: "Shift Speed 5-6"
            xLabel: "Throttle"
            yLabel: "Speed"
            param: shiftTables[4]
        }
    }
}
