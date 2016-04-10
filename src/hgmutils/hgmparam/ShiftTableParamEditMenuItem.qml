import QtQuick 2.5
import QtQuick.Controls 1.4
import QtQuick.Layouts 1.2
import QtQuick.Window 2.2
import QtQuick.Dialogs 1.2
import com.hgmelectronics.setuptools 1.0

MenuItem {
    id: item

    property alias name: item.text
    property alias speedTableParam: table.speedTableParam
    property alias rpmTableParam: table.rpmTableParam
    property alias thisGearRatio: table.thisGearRatio
    property alias nextGearRatio: table.nextGearRatio
    property alias thisGearName: table.thisGearName
    property alias nextGearName: table.nextGearName

    enabled: table.speedTableParam.param.valid
    visible: table.speedTableParam.param.valid
    onTriggered: {
        table.showNormal()
        table.raise()
    }
    text: speedTableParam.name

    property ShiftTableParamEditDialog dialog: ShiftTableParamEditDialog {
        id: table
        name: item.text
    }
}
