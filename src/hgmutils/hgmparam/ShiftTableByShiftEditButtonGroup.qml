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
                function getTitle(i) {
                    var first = i + 1
                    var second = i + 2
                    if (!isDownshift) {
                        return qsTr("Shift %1-%2").arg(first).arg(second)
                    } else {
                        return qsTr("Shift %1-%2").arg(second).arg(first)
                    }
                }
                name: getTitle(index)
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
