import QtQuick 2.4
import QtQuick.Controls 1.4
import QtQuick.Layouts 1.2
import QtQuick.Window 2.2
import com.hgmelectronics.setuptools 1.0

Window {
    id: aboutDialog
    property string programName
    property string programVersion
    property string programHash: AppVersion.hash

    title: "About %1".arg(programName)

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
                    text: "%1 %2".arg(programName).arg(programVersion)
                }
                Label {
                    visible: programHash.length > 0
                    text: qsTr("Hash %1".arg(programHash))
                }
                Label {
                    text: qsTr("Copyright \u00A9 2015<br>HGM Automotive Electronics Inc.")
                }
            }
            Image {
                source: "hgmlogo-about.png"
                Layout.alignment: Qt.AlignVCenter | Qt.AlignRight
            }
        }
        Label {
            textFormat: Text.RichText
            wrapMode: Text.WordWrap
            text: "This program is free software: you can redistribute it and/or modify<br>"
                  + "it under the terms of the GNU General Public License as published by<br>"
                  + "the Free Software Foundation, either version 3 of the License, or<br>"
                  + "(at your option) any later version.<br>" + "<br>"
                  + "This program is distributed in the hope that it will be useful, <br>"
                  + "but WITHOUT ANY WARRANTY; without even the implied warranty of <br>"
                  + "MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the <br>"
                  + "GNU General Public License for more details.<br>" + "<br>"
                  + "You should have received a copy of the GNU General Public License <br>"
                  + "along with this program.  If not, see <a href=\"http://www.gnu.org/licenses/\">http://www.gnu.org/licenses/</a>."
        }
        Button {
            anchors.right: parent.right
            text: qsTr("Close")
            isDefault: true
            onClicked: aboutDialog.visible = false
        }
    }
}
