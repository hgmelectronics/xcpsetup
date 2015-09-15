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
            if(plots[i].valid) {
                var baseColor = plots[i].baseColor
                var alphaMult = plots[i].fade ? 0.5 : 1
                var fillAlphaMult = plots[i].fill ? 0.5 : 0
                newChartData.push({
                                   fillColor: Qt.rgba(baseColor.r, baseColor.g, baseColor.b, alphaMult * fillAlphaMult * baseColor.a),
                                   strokeColor: Qt.rgba(baseColor.r, baseColor.g, baseColor.b, alphaMult * baseColor.a),
                                   pointColor: Qt.rgba(1, 1, 1, alphaMult * baseColor.a),
                                   pointStrokeColor: Qt.lighter(Qt.rgba(baseColor.r, baseColor.g, baseColor.b, alphaMult * baseColor.a)),
                                   xData: plots[i].xList,
                                   yData: plots[i].valueList
                               })
            }
        }
        chartData = newChartData
    }
    onPlotsChanged: {
        replot()
        for(var i = 0; i < plots.length; ++i) {
            plots[i].plotChanged.disconnect(replot)
            plots[i].plotChanged.connect(replot)
        }
    }
    Component.onCompleted: {
        replot()
    }
}
