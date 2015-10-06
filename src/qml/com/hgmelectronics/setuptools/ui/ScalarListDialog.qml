import QtQuick 2.5
import QtQuick.Controls 1.4
import QtQuick.Layouts 1.2
import QtQuick.Window 2.2
import QtQuick.Dialogs 1.2
import com.hgmelectronics.setuptools.xcp 1.0
import com.hgmelectronics.setuptools 1.0

Window {
    id: root

    property list<ScalarMetaParamList> paramLists
    property alias verticalScrollBarPolicy: scrollView.verticalScrollBarPolicy
    height: 600

    property bool anyValid: {
        for(var i = 0; i < paramLists.length; ++i) {
            if(paramLists[i].anyValid)
                return true
        }
        return false
    }

    property int columns: paramLists.length
    property int rows: paramLists[0].params.length
    maximumWidth: 15 + (stalkingHorse.implicitWidth + 5) * columns + scrollView.width - scrollView.viewport.width
    width: maximumWidth

    ScalarParamEdit {
        id: stalkingHorse
        metaParam: paramLists[0].params[0]
        visible: false
    }

    ScrollView {
        id: scrollView
        anchors.fill: parent
        anchors.margins: 5
        verticalScrollBarPolicy: Qt.ScrollBarAlwaysOn
        Row {
            id: rowLayout
            Layout.fillWidth: true
            spacing: 5
            Repeater {
                model: columns
                Column {
                    id: column
                    spacing: 5
                    property ScalarMetaParamList paramList: paramLists[index]
                    Repeater {
                        model: rows
                        ScalarParamEdit {
                            id: edit
                            metaParam: paramList.params[index]
                            visible: paramList.params[index].param.valid
                        }
                    }
                }
            }
        }
    }
}
