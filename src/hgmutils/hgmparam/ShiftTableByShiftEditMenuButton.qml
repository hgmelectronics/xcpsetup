import QtQuick 2.5
import QtQuick.Controls 1.4
import QtQuick.Layouts 1.2
import QtQuick.Window 2.2
import QtQuick.Dialogs 1.2
import com.hgmelectronics.setuptools.xcp 1.0
import com.hgmelectronics.setuptools 1.0

Button {
    id: button
    property int count: rpmTableParams.length
    property var speedTableParams
    property var rpmTableParams
    property TableParam gearNumberRatioParam
    property bool isDownshift

    enabled: {
        for(var i = 0; i < speedTableParams.length; ++i) {
            if(speedTableParams[i].param.valid)
                return true;
        }
        return false;
    }

    function findRatio(gearNum) {
        for(var i = 0; i < gearNumberRatioParam.count; ++i) {
            if(gearNumberRatioParam.x.get(i) === gearNum)
                return gearNumberRatioParam.value.get(i)
        }
        // probably being instantiated before parameters are loaded - return something that at least does not cause an error
        return 0
    }

    Menu {
        id: menu
        Instantiator {
            model: rpmTableParams.length
            onObjectAdded: menu.insertItem(index, object)
            onObjectRemoved: menu.removeItem(object)
            ShiftTableParamEditMenuItem {
                property int thisGearNum: isDownshift ? (index + 2) : (index + 1)
                property int nextGearNum: isDownshift ? (index + 1) : (index + 2)
                thisGearName: thisGearNum
                nextGearName: nextGearNum
                name: qsTr("Shift %1-%2").arg(thisGearName).arg(nextGearName)

                rpmTableParam: button.rpmTableParams[index]
                speedTableParam: button.speedTableParams[index]
                thisGearRatio: findRatio(thisGearNum)
                nextGearRatio: findRatio(nextGearNum)
            }
        }
    }
    onClicked: {
        menu.popup()
    }
}
