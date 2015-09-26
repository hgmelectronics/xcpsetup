import QtQuick 2.5
import QtQuick.Controls 1.4
import com.hgmelectronics.setuptools.xcp 1.0
import com.hgmelectronics.setuptools 1.0

CheckBox {
    id: checkBox
    property ScalarParam param
    property alias name: checkBox.text
    property double bitMask: 0x00000001
    checked: (param.floatVal & bitMask)
    enabled: param.valid
    onClicked: param.floatVal = (param.floatVal & ~bitMask) | (checked ? bitMask : 0)
}

