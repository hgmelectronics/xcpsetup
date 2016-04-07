import QtQuick 2.5
import QtCharts 2.0
import com.hgmelectronics.setuptools 1.0
import com.hgmelectronics.setuptools.ui 1.0

LineSeries {
    id: line

    property alias model: mapper.model
    property alias xRole: mapper.xRole
    property alias yRole: mapper.yRole

    RoleXYModelMapper {
        id: mapper
        series: line
    }
}
