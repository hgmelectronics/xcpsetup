import QtQuick 2.5
import QtQuick.Controls 1.4
import QtQuick.Layouts 1.2
import QtQuick.Window 2.2
import QtQuick.Dialogs 1.2
import com.hgmelectronics.setuptools.xcp 1.0
import com.hgmelectronics.setuptools 1.0

Button {
    id: button
    enabled: table.tableParam.value.range.valid
    property alias name: button.text
    property alias tableParam: table.tableParam
    property alias scaleParam: table.scaleParam
    property alias thisGearRatio: table.thisGearRatio
    property alias nextGearRatio: table.nextGearRatio
    property alias rpmSlot: table.rpmSlot

    onClicked: table.visible = true

    ShiftTableParamEditDialog {
        id: table
        name: button.text
    }
}
