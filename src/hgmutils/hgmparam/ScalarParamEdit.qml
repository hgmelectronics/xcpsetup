import QtQuick 2.5
import QtQuick.Controls 1.4
import QtQuick.Layouts 1.2
import com.hgmelectronics.setuptools.xcp 1.0
import com.hgmelectronics.setuptools 1.0

GroupBox {
    id: groupBox
    enabled: param.valid
    property alias name: groupBox.title
    property alias horizontalAlignment: textField.horizontalAlignment
    property ScalarParam param

    TextField {
        id: textField
        text: param.stringVal
        readOnly: !param.range.writable
        horizontalAlignment: TextInput.AlignRight
        onEditingFinished: {
            if(param.stringVal != text)
                param.stringVal = text
        }
    }
}
