import QtQuick 2.5
import QtQuick.Controls 1.4
import QtQuick.Layouts 1.2
import QtQuick.Window 2.2
import QtQuick.Dialogs 1.2
import com.hgmelectronics.setuptools.xcp 1.0
import com.hgmelectronics.setuptools 1.0

Button {
    id: button
    property alias name: button.text
    property alias speedTableParam: table.speedTableParam
    property alias rpmTableParam: table.rpmTableParam
    property alias thisGearRatio: table.thisGearRatio
    property alias nextGearRatio: table.nextGearRatio
    enabled: table.speedTableParam.value.range.valid
    onClicked: table.visible = true

    ShiftTableParamEditDialog {
        id: table
        name: button.text
    }
}
