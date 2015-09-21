import QtQuick 2.5
import QtQuick.Controls 1.4
import QtQuick.Layouts 1.2
import com.hgmelectronics.setuptools.xcp 1.0
import com.hgmelectronics.setuptools 1.0

GroupBox {
    id: groupBox
    enabled: param.valid
    property alias name: groupBox.title
    property alias horizontalAlignment: text.horizontalAlignment
    property ScalarParam param

    TextField {
        id: text
        text: param.stringVal
        readOnly: param.range.writable
        onEditingFinished: param.stringVal = text
    }
}
