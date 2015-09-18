import QtQuick 2.5
import com.hgmelectronics.setuptools 1.0

QtObject {
    property TableMapperModel tableModel
    property ModelListProxy tableXProxy: ModelListProxy {
        source: tableModel
        roleName: "x"
    }
    property ModelListProxy tableValueProxy: ModelListProxy {
        source: tableModel
        roleName: "value"
    }
    property var xList: tableXProxy.list
    property var valueList: tableValueProxy.list
    property color baseColor: Qt.rgba(0.6, 0.7, 0.8, 1.0)
    property bool fade: false
    property string text: ""

    signal plotChanged

    onXListChanged: plotChanged()
    onValueListChanged: plotChanged()
    onBaseColorChanged: plotChanged()
    onFadeChanged: plotChanged()
}
