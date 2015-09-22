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
    property var gearRatioParams
    property int firstGearTableOffset: 2
    property bool isDownshift

    Row {
        spacing: 10

        Repeater {
            id: repeater
            model: 5
            ShiftTableParamEditButton {
                id: tableButton

                thisGearName: qsTr("%1").arg(isDownshift ? (index + 2) : (index + 1))
                nextGearName: qsTr("%1").arg(isDownshift ? (index + 1) : (index + 2))
                name: qsTr("Shift %1-%2").arg(thisGearName).arg(nextGearName)
                speedTableParam: groupBox.speedTableParams[index]
                rpmTableParam: groupBox.rpmTableParams[index]
                thisGearRatio: gearRatioParams[index + firstGearTableOffset]
                property ScalarParam dummyScalar: ScalarParam {}
                nextGearRatio: isDownshift ?
                                   ((index > 0) ? gearRatioParams[index - 1 + firstGearTableOffset] : dummyScalar) :
                                   ((index < (count - 1)) ? gearRatioParams[index + 1 + firstGearTableOffset] : dummyScalar)
            }
        }
    }
}
