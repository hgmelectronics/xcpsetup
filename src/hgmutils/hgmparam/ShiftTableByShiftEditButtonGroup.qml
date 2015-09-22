import QtQuick 2.5
import QtQuick.Controls 1.4
import QtQuick.Layouts 1.2
import QtQuick.Window 2.2
import QtQuick.Dialogs 1.2
import com.hgmelectronics.setuptools.xcp 1.0
import com.hgmelectronics.setuptools 1.0

GroupBox {
    id: groupBox
    property int count: repeater.model
    property var speedTableParams
    property var rpmTableParams
    property var gearNumberParams
    property var gearRatioParams
    property bool isDownshift

    Row {
        spacing: 10

        Repeater {
            id: repeater
            model: 5
            ShiftTableParamEditButton {
                id: tableButton

                function findRatioIndex(gearNum) {
                    for(var i = 0; i < gearNumberParams.length; ++i) {
                        if(gearNumberParams[i].floatVal === gearNum)
                            return i;
                    }
                    return -1;
                }

                property int thisGearNum: isDownshift ? (index + 2) : (index + 1)
                property int nextGearNum: isDownshift ? (index + 1) : (index + 2)
                thisGearName: thisGearNum
                nextGearName: nextGearNum
                name: qsTr("Shift %1-%2").arg(thisGearName).arg(nextGearName)
                speedTableParam: groupBox.speedTableParams[index]
                rpmTableParam: groupBox.rpmTableParams[index]
                thisGearRatio: gearRatioParams[findRatioIndex(thisGearNum)]
                nextGearRatio: gearRatioParams[findRatioIndex(nextGearNum)]
            }
        }
    }
}
