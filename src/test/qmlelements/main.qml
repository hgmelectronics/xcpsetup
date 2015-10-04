import QtQuick 2.4
import QtQuick.Controls 1.3
import QtQuick.Window 2.2
import QtQuick.Dialogs 1.2
import com.hgmelectronics.setuptools 1.0
import com.hgmelectronics.setuptools.ui 1.0

ApplicationWindow {
    title: qsTr("Hello World")
    width: 640
    height: 480
    visible: true

    TablePlot {
        anchors.fill: parent
        anchors.margins: 10
        plots: [
            XYTrace {
                xList: [0, 1, 2, 3, 4, 5, 6, 7]
                valueList: [3.8,3.801,3.8,3.802,3.79,3.8,3.8,3.803]
            }
        ]
    }

}
