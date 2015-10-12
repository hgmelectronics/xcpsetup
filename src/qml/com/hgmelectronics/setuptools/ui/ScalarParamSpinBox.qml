import QtQuick 2.5
import QtQuick.Controls 1.4
import QtQuick.Layouts 1.1
import com.hgmelectronics.setuptools.xcp 1.0
import com.hgmelectronics.setuptools 1.0

GroupBox {
    id: groupBox
    property alias horizontalAlignment: spinBox.horizontalAlignment
    property alias stepSize: spinBox.stepSize
    property ScalarMetaParam metaParam
    property string name: metaParam.name
    property ScalarParam param: metaParam.param
    title: name
    enabled: param.valid
    width: Math.max(sizeHint.implicitWidth + 6, spinBox.implicitWidth + 6)

    Text {
        id: sizeHint
        visible: false
        text: name
        font.bold: true
    }

    SpinBox {
        id: spinBox
        implicitWidth: 150
        horizontalAlignment: Qt.AlignRight
        stepSize: Math.pow(10,-param.slot.precision)
        minimumValue: Math.min(param.slot.engrA, param.slot.engrB)
        maximumValue: Math.max(param.slot.engrA, param.slot.engrB)
        decimals: param.slot.precision
        suffix: param.slot.unit.length != 0 ? " %1".arg(param.slot.unit) : ""
        value: param.floatVal
        onEditingFinished: param.floatVal = value
    }
}
