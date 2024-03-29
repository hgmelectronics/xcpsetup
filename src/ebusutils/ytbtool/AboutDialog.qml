import QtQuick 2.4
import QtQuick.Controls 1.4
import QtQuick.Layouts 1.2
import QtQuick.Window 2.2

Window {
    id: aboutDialog
    title: "About HGMFlash"

    width: aboutForm.implicitWidth + 20
    height: aboutForm.implicitHeight + 20
    maximumWidth: aboutForm.implicitWidth + 20
    maximumHeight: aboutForm.implicitHeight + 20
    minimumWidth: aboutForm.implicitWidth + 20
    minimumHeight: aboutForm.implicitHeight + 20

    function show() {
        visible = true
    }

    ColumnLayout {
        id: aboutForm
        anchors.fill: parent
        anchors.margins: 10
        spacing: 5

        RowLayout {
            width: parent.width
            ColumnLayout {
                Label {
                    font.pixelSize: 18
                    Layout.fillWidth: true
                    text: "CDA2Tool 1.0"
                }
                Label {
                    text: "Copyright \u00A9 2015<br>Ebus Inc."
                }
            }
        }
        Label {
            textFormat: Text.RichText
            wrapMode: Text.WordWrap
            text:   "This program is free software: you can redistribute it and/or modify<br>" +
                    "it under the terms of the GNU General Public License as published by<br>"+
                    "the Free Software Foundation, either version 3 of the License, or<br>" +
                    "(at your option) any later version.<br>" +
                    "<br>" +
                    "This program is distributed in the hope that it will be useful, <br>" +
                    "but WITHOUT ANY WARRANTY; without even the implied warranty of <br>" +
                    "MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the <br>" +
                    "GNU General Public License for more details.<br>" +
                    "<br>" +
                    "You should have received a copy of the GNU General Public License <br>" +
                    "along with this program.  If not, see <a href=\"http://www.gnu.org/licenses/\">http://www.gnu.org/licenses/</a>."
        }
        Button {
            anchors.right: parent.right
            text: "Close"
            isDefault: true
            onClicked: aboutDialog.visible = false
        }
    }
}
