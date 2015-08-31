import QtQuick 2.5
import QtQuick.Controls 1.4
import QtQuick.Layouts 1.2
import com.setuptools.xcp 1.0

ColumnLayout {
    property string name
    property ScalarParam param

    enabled: param.valid

    Label {
        text: name
    }

    RowLayout {
        TextField {
            text: param.stringVal
            onEditingFinished: param.stringVal = text
        }

        Label {
            text: param.slot.unit
        }
    }
}
