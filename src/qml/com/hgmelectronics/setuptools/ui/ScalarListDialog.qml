import QtQuick 2.5
import QtQuick.Controls 1.4
import QtQuick.Layouts 1.2
import QtQuick.Window 2.2
import QtQuick.Dialogs 1.2
import com.hgmelectronics.setuptools.xcp 1.0
import com.hgmelectronics.setuptools 1.0
import com.hgmelectronics.setuptools.ui 1.0

Window {
    id: root

    property list<ScalarMetaParamList> paramLists

    property alias verticalScrollBarPolicy: scrollView.verticalScrollBarPolicy
    property int maxInitialHeight: 600
    height: Math.min(desiredHeight, maxInitialHeight)

    property bool anyValid: {
        for(var i = 0; i < paramLists.length; ++i) {
            if(paramLists[i].anyValid)
                return true
        }
        return false
    }

    property bool allListsAnyValid: {
        for(var i = 0; i < paramLists.length; ++i) {
            if(!paramLists[i].anyValid)
                return false
        }
        return true
    }

    property int rows: {
        var n = 0
        for(var i = 0; i < paramLists.length; ++i) {
            n = Math.max(n, paramLists[i].params.length)
        }
        return n
    }

    property int desiredHeight: 25 + (stalkingHorse.implicitHeight + 5) * rows
    property int columns: paramLists.length
    property int calcWidth: 15 + (stalkingHorse.implicitWidth + 5) * columns + scrollView.width - scrollView.viewport.width
    property int minimumUsableWidth: 250
    minimumWidth: Math.min(minimumUsableWidth, calcWidth)
    maximumWidth: Math.max(minimumUsableWidth, calcWidth)
    width: maximumWidth

    ScalarParamEdit {
        id: stalkingHorse
        metaParam: paramLists[0].params[0]
        visible: false
    }

    ColumnLayout {
        id: columnLayout
        anchors.fill: parent
        ScrollView {
            id: scrollView
            anchors.fill: parent
            verticalScrollBarPolicy: (desiredHeight > maxInitialHeight) ? Qt.ScrollBarAlwaysOn : Qt.ScrollBarAlwaysOff
            Item {
                height: rowLayout.implicitHeight + 20
                Row {
                    id: rowLayout
                    spacing: 5
                    anchors.fill: parent
                    anchors.margins: 10
                    Repeater {
                        model: columns
                        Column {
                            id: column
                            spacing: 5
                            property ScalarMetaParamList paramList: paramLists[index]
                            Repeater {
                                model: paramList.length
                                ScalarParamEdit {
                                    id: edit
                                    metaParam: paramList.params[index]
                                    enabled: paramList.params[index].param.valid
                                }
                            }
                        }
                    }
                }
            }
        }
    }
    AutoRefreshArea {
        base: columnLayout
    }
}
