import QtQuick 2.5
import QtQuick.Controls 1.4
import QtQuick.Layouts 1.2
import com.hgmelectronics.setuptools 1.0

import "QChart.js" as Charts

QChart {
    id: chart
    property list<XYTrace> plots

    chartAnimated: false
    chartOptions: ({
                       pointDot: false,
                       bezierCurve: false,
                  })
    chartType: Charts.ChartType.SCATTER
    chartData: []

    function replot() {
        var newChartData = []
        for(var i = 0; i < plots.length; ++i) {
            var baseColor = plots[i].baseColor
            newChartData.push({
                               fillColor: Qt.rgba(baseColor.r, baseColor.g, baseColor.b, baseColor.a * 0.5),
                               strokeColor: baseColor,
                               pointColor: baseColor,
                               pointStrokeColor: Qt.lighter(baseColor),
                               xData: plots[i].xList,
                               yData: plots[i].valueList
                           })
        }
        chartData = newChartData
    }
    onPlotsChanged: {
        replot()
        for(var i = 0; i < plots.length; ++i) {
            plots[i].plotChanged.connect(replot)
        }
    }
    Component.onCompleted: {
        replot()
    }
}
