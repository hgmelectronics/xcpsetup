import QtQuick 2.4
import QtQuick.Controls 1.3
import QtQuick.Layouts 1.1
import com.setuptools 1.0

ColumnLayout {
    spacing: 10
    anchors.right: parent.right
    anchors.rightMargin: 40
    anchors.left: parent.left
    anchors.leftMargin: 40
    anchors.bottom: parent.bottom
    anchors.bottomMargin: 40
    anchors.top: parent.top
    anchors.topMargin: 40

    property alias openButton: openButton
    property alias closeButton: closeButton
    property alias readButton: readButton
    property alias writeButton: writeButton
    property alias addressField: addressField
    property alias dataField: dataField
    property alias interfaceComboBox: interfaceComboBox

    RowLayout {
        id: row1
        spacing: 10

        Button {
            id: openButton
            text: qsTr("Open")
        }


        Button {
            id: readButton
            text: qsTr("Read")
            enabled: !openButton.enabled
        }

        Button {
            id: writeButton
            text: qsTr("Write")
            enabled: !openButton.enabled
        }

        Button {
            id: closeButton
            text: qsTr("Close")
            enabled: !openButton.enabled
        }

    }

    IntValidator
    {
        id: numberRange;
        bottom: 0;
    }

    RowLayout {
        id: row2

        ColumnLayout {
            id: addressColumn

            Label {
                id: label1
                text: qsTr("Address")
            }

            TextField {
                id: addressField
                enabled: !openButton.enabled
                inputMethodHints: Qt.ImhPreferNumbers
                placeholderText: qsTr("0")
                validator: numberRange
            }
        }

        ColumnLayout {
            id: dataColumn
            Label {
                id: label2
                text: qsTr("Data")
            }

            TextField {
                id: dataField
                enabled: !openButton.enabled
                inputMethodHints: Qt.ImhPreferNumbers
                placeholderText: qsTr("0")
                validator: numberRange

            }
        }
    }

    RowLayout {
        id: row3

        ComboBox {
            id: interfaceComboBox
            model: XcpCanInterfaceRegistry.avail
            textRole: "text"
            visible: true
            implicitWidth: 300
        }
    }
}
