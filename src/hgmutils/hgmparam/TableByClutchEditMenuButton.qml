import QtQuick 2.5
import QtQuick.Controls 1.4
import QtQuick.Layouts 1.2
import QtQuick.Window 2.2
import QtQuick.Dialogs 1.2

Button {
    id: button
    property int count: tableParam.length
    property string xLabel
    property string valueLabel
    property var tableParam
    text: tableParam[0].name.replace(/Clutch [1-9] (.*)/, "$1")
    enabled: {
        for(var i = 0; i < tableParam.length; ++i) {
            if(tableParam[i].param.valid)
                return true;
        }
        return false;
    }

    Menu {
        id: menu
        Instantiator {
            model: tableParam.length
            onObjectAdded: menu.insertItem(index, object)
            onObjectRemoved: menu.removeItem(object)
            TableParamEditMenuItem {
                name: button.tableParam[index].name.replace(/(Clutch [1-9]).*/, "$1")
                tableParam: button.tableParam[index]
                xLabel: button.xLabel
                valueLabel: button.valueLabel
            }
        }
    }
    onClicked: {
        menu.popup()
    }
}
