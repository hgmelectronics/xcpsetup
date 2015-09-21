import QtQuick 2.5
import QtQuick.Controls 1.4
import QtQuick.Layouts 1.2
import QtQuick.Window 2.2
import QtQuick.Dialogs 1.2
import com.hgmelectronics.setuptools.xcp 1.0
import com.hgmelectronics.setuptools 1.0
import com.hgmelectronics.setuptools.ui 1.0

Flow {
    anchors.fill: parent
    anchors.margins: 10
    spacing: 10

    property Parameters parameters

    ScalarParamSpinBox {
        name: qsTr("Engine Cylinders")
        param: parameters.engineCylinders
    }

    ScalarParamSpinBox {
        name: qsTr("Max Engine Speed A")
        param: parameters.shiftMaxEngineSpeedA
    }
    ScalarParamSpinBox {
        name: qsTr("Max Engine Speed B")
        param: parameters.shiftMaxEngineSpeedB
    }
}
