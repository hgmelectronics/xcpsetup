import QtQuick 2.5
import QtQuick.Controls 1.4
import QtQuick.Layouts 1.2
import QtQuick.Window 2.2
import QtQuick.Dialogs 1.2
import com.hgmelectronics.setuptools.xcp 1.0
import com.hgmelectronics.setuptools 1.0
import com.hgmelectronics.setuptools.ui 1.0

RowLayout {
    property Parameters parameters
    anchors.fill: parent
    anchors.margins: 5
    spacing: 5

    ColumnLayout {
        Layout.fillHeight: true
        Layout.alignment: Qt.AlignTop
        EncodingParamEdit {
            metaParam: parameters.can0BaudRate
        }
        EncodingParamEdit {
            metaParam: parameters.can1BaudRate
        }
    }

    ColumnLayout {
        Layout.fillHeight: true
        Layout.alignment: Qt.AlignTop
        ScalarParamEdit {
            metaParam: parameters.j1939TransmissionAddress
        }
        ScalarParamEdit {
            metaParam: parameters.j1939EngineAddress
        }
        ScalarParamEdit {
            metaParam: parameters.j1939ShiftSelectorAddress
        }
        ScalarParamEdit {
            metaParam: parameters.xcpCTOId
        }
        ScalarParamEdit {
            metaParam: parameters.xcpDTOId
        }
    }
}
