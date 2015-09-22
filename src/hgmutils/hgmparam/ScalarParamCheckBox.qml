import QtQuick 2.5
import QtQuick.Controls 1.4
import com.hgmelectronics.setuptools.xcp 1.0
import com.hgmelectronics.setuptools 1.0
import com.hgmelectronics.setuptools.ui 1.0

CheckBox {
    id: checkBox
    property ScalarParam param
    property alias name: checkBox.text
    checked: param.floatVal != 0
    enabled: param.valid
    onClicked: param.floatVal = checked
}

