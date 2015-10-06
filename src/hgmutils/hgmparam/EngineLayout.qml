import QtQuick 2.5
import QtQuick.Controls 1.4
import QtQuick.Layouts 1.2
import QtQuick.Window 2.2
import QtQuick.Dialogs 1.2
import com.hgmelectronics.setuptools.xcp 1.0
import com.hgmelectronics.setuptools 1.0
import com.hgmelectronics.setuptools.ui 1.0

Flow {
    property Parameters parameters
    anchors.fill: parent
    anchors.margins: 5
    spacing: 5

    ScalarParamSpinBox {
        metaParam: parameters.engineCylinders
    }
    ScalarParamSpinBox {
        metaParam: parameters.shiftMaxEngineSpeedA
    }
    ScalarParamSpinBox {
        metaParam: parameters.shiftMaxEngineSpeedB
    }
}
