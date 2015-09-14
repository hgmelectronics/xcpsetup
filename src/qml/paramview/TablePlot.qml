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
            newChartData.push({
                               fillColor: Qt.rgba(plots[i].baseColor[0]/255,
                                               plots[i].baseColor[1]/255,
                                               plots[i].baseColor[2]/255,
                                               0.5),
                               strokeColor: Qt.rgba(plots[i].baseColor[0]/255,
                                               plots[i].baseColor[1]/255,
                                               plots[i].baseColor[2]/255,
                                               1.0),
                               pointColor: Qt.rgba(plots[i].baseColor[0]/255,
                                               plots[i].baseColor[1]/255,
                                               plots[i].baseColor[2]/255,
                                               1.0),
                               pointStrokeColor: Qt.lighter(
                                                     Qt.rgba(plots[i].baseColor[0]/255,
                                                         plots[i].baseColor[1]/255,
                                                         plots[i].baseColor[2]/255,
                                                         1.0)),
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
