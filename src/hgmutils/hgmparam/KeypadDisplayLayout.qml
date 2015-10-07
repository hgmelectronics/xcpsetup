import QtQuick 2.5
import QtQuick.Controls 1.4
import QtQuick.Layouts 1.2
import QtQuick.Window 2.2
import QtQuick.Dialogs 1.2
import com.hgmelectronics.setuptools.xcp 1.0
import com.hgmelectronics.setuptools 1.0
import com.hgmelectronics.setuptools.ui 1.0

GridLayout {
    property Parameters parameters
    anchors.fill: parent
    anchors.margins: 5
    columnSpacing: 5
    rowSpacing: 5
    rows: 6
    flow: GridLayout.TopToBottom

    EncodingParamEdit {
        metaParam: parameters.displayUnits
    }
    ScalarParamSpinBox {
        metaParam: parameters.displayBrightness
    }
    ScalarParamSpinBox {
        metaParam: parameters.displayContrast
    }
    ScalarParamSpinBox {
        metaParam: parameters.displayColorRed
    }
    ScalarParamSpinBox {
        metaParam: parameters.displayColorGreen
    }
    ScalarParamSpinBox {
        metaParam: parameters.displayColorBlue
    }
//    Button {
//        id: displayColorButton
//        enabled: parameters.displayColor.param.valid
//        onClicked: displayColorDialog.open()
//    }
//    ColorDialog {
//        id: displayColorDialog
//        property ArrayParam displayColorArray
//        showAlphaChannel: false

//        Connections {
//            target: parameters.displayColor.param.value
//            onModelChanged: setColor(Qt.rgba(displayColorArray.get(0) / 100, displayColorArray.get(1) / 100, displayColorArray.get(2) / 100))
//        }
//        onAccepted:
//    }
}
