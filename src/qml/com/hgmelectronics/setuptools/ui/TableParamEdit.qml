import QtQuick 2.5
import QtQuick.Controls 1.4
import QtQuick.Layouts 1.2
import com.hgmelectronics.setuptools 1.0
import com.hgmelectronics.setuptools.ui 1.0

MultiroleTableParamEdit {
    property string xLabel: tableParam.x.slot.unit
    property string valueLabel: tableParam.value.slot.unit

    label: {
        "x": xLabel,
        "value": valueLabel
    }
    roleNames: ["x", "value"]
}
