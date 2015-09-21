import QtQuick 2.5
import QtQuick.Controls 1.4

GroupBox {
    property string value
    TextField {

        horizontalAlignment: TextInput.AlignRight
        text: value
        validator: RegExpValidator {
            regExp: /[0-9A-Fa-f]{1,8}/
        }
        onAccepted: {
            value = text
        }
    }
}
