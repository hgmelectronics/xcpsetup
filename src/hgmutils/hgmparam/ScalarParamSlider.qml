import QtQuick 2.5
import QtQuick.Controls 1.4
import QtQuick.Layouts 1.1
import com.setuptools.xcp 1.0
import com.setuptools 1.0

GroupBox {
    id: groupBox
    property alias name: groupBox.title
    property ScalarParam param

    Column
    {
        spacing: 10

        Slider
        {
            id: slider
            minimumValue: param.slot.engrA
            maximumValue: param.slot.engrB
            value: param.floatVal
        }

        Row
        {
            TextField
            {
                text: param.textVal
            }
            Text
            {
                text: param.slot.unit
            }
        }
    }

}

