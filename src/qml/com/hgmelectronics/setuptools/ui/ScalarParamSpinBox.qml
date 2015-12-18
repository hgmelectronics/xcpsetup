import QtQuick 2.5
import QtQuick.Controls 1.4
import QtQuick.Layouts 1.1
import com.hgmelectronics.setuptools.xcp 1.0
import com.hgmelectronics.setuptools 1.0
import com.hgmelectronics.setuptools.ui 1.0

GroupBox {
    id: groupBox

    property alias horizontalAlignment: spinBox.horizontalAlignment
    property alias stepSize: spinBox.stepSize
    property ScalarMetaParam metaParam
    property string name: metaParam.name
    property bool enableAutoRefreshOverlay: metaParam.isLiveData
    property alias minimumValue: spinBox.minimumValue
    property alias maximumValue: spinBox.maximumValue

    property ScalarParam param: metaParam.param
    title: name
    enabled: param.valid
    implicitWidth: 166
    width: implicitWidth

    RowLayout {
        SpinBox {
            id: spinBox
            implicitWidth: groupBox.implicitWidth - 16
            width: groupBox.width - 16
            horizontalAlignment: Qt.AlignRight
            stepSize: Math.pow(10,-param.slot.precision)
            minimumValue: !isNaN(parseFloat(param.slot.engrMin)) ? parseFloat(param.slot.engrMin) : -Number.MAX_VALUE
            maximumValue: !isNaN(parseFloat(param.slot.engrMax)) ? parseFloat(param.slot.engrMax) : Number.MAX_VALUE
            decimals: param.slot.precision
            suffix: param.slot.unit.length != 0 ? " %1".arg(param.slot.unit) : ""
            value: param.floatVal
            onEditingFinished: {
                if(param.floatVal != value || isNaN(param.floatVal)) {
                    param.floatVal = value
                    if(metaParam.immediateWrite)
                        ImmediateWrite.trigger(param.key)
                }
            }
        }
        Text {
            id: sizeHint
            visible: false
            text: name
        }
        AutoRefreshOverlay {
            key: param.key
            visible: enableAutoRefreshOverlay
            enabled: enableAutoRefreshOverlay
        }
    }
}
