import QtQuick 2.5
import QtQuick.Controls 1.4
import QtQuick.Layouts 1.2
import QtQuick.Window 2.2
import QtQuick.Dialogs 1.2
import com.hgmelectronics.setuptools.xcp 1.0
import com.hgmelectronics.setuptools 1.0
import com.hgmelectronics.setuptools.ui 1.0

Button {
    id: root
    property string name
    property alias xLabel: edit.xLabel
    property alias valueLabel: edit.valueLabel
    property alias tableParam: edit.tableParam

    text: name
    onClicked: win.visible = true

    Window {
        id: win
        title: root.name
        TableParamEdit {
            id: edit
            anchors.fill: parent
            anchors.margins: 10
        }
    }
}
