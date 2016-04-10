#include "XYSeriesAutoAxis.h"
#include "util.h"
#include "QDebug"

namespace SetupTools {

XYSeriesAutoAxis::XYSeriesAutoAxis(QObject *parent) :
    QObject(parent),
    mSeriesProperty(this, nullptr, &seriesAppend, &seriesCount, &seriesAt, &seriesClear),
    mSeries(),
    mXAxis(new QtCharts::QValueAxis(this)),
    mYAxis(new QtCharts::QValueAxis(this)),
    mIncludeInvisible(false)
{
}

void XYSeriesAutoAxis::seriesAppend(QQmlListProperty<QtCharts::QXYSeries> *property, QtCharts::QXYSeries *value)
{
    auto self = qobject_cast<XYSeriesAutoAxis *>(property->object);
    if(!self)
        return;

    self->appendSeries(value);
}

QtCharts::QXYSeries * XYSeriesAutoAxis::seriesAt(QQmlListProperty<QtCharts::QXYSeries> *property, int index)
{
    auto self = qobject_cast<XYSeriesAutoAxis *>(property->object);
    if(!self)
        return nullptr;

    return self->mSeries.at(index);
}

void XYSeriesAutoAxis::seriesClear(QQmlListProperty<QtCharts::QXYSeries> *property)
{
    auto self = qobject_cast<XYSeriesAutoAxis *>(property->object);
    if(!self)
        return;

    self->clearSeries();
}

int XYSeriesAutoAxis::seriesCount(QQmlListProperty<QtCharts::QXYSeries> *property)
{
    auto self = qobject_cast<XYSeriesAutoAxis *>(property->object);
    if(!self)
        return 0;

    return self->mSeries.count();
}

void XYSeriesAutoAxis::appendSeries(QtCharts::QXYSeries *series)
{
    mSeries.append(series);
    connect(series, &QtCharts::QXYSeries::pointsReplaced, this, &XYSeriesAutoAxis::onSeriesChanged);
    connect(series, &QtCharts::QAbstractSeries::visibleChanged, this, &XYSeriesAutoAxis::onSeriesChanged);
}

void XYSeriesAutoAxis::clearSeries()
{
    for(QtCharts::QXYSeries * series : mSeries)
    {
        disconnect(series, &QtCharts::QXYSeries::pointsReplaced, this, &XYSeriesAutoAxis::onSeriesChanged);
        disconnect(series, &QtCharts::QAbstractSeries::visibleChanged, this, &XYSeriesAutoAxis::onSeriesChanged);
    }
    mSeries.clear();
}

void XYSeriesAutoAxis::setIncludeInvisible(bool value)
{
    if(updateDelta<>(mIncludeInvisible, value))
    {
        onSeriesChanged();
        emit includeInvisibleChanged();
    }
}

void decadify(double & min, double & max)
{
    if(max < min)
    {
        min = 0;
        max = 1;
        return;
    }

    if(max == min)
    {
        min = max - 1;
        max = max + 1;
        return;
    }

    double orderOfMagnitude = pow(10, floor(log(max - min) / log(10)));
    min = floor(min / orderOfMagnitude) * orderOfMagnitude;
    max = ceil(max / orderOfMagnitude) * orderOfMagnitude;
}

void XYSeriesAutoAxis::onSeriesChanged()
{
    double xMin = std::numeric_limits<double>::max();
    double xMax = std::numeric_limits<double>::lowest();
    double yMin = std::numeric_limits<double>::max();
    double yMax = std::numeric_limits<double>::lowest();
    for(QtCharts::QXYSeries * series : mSeries)
    {
        if(series->isVisible() || mIncludeInvisible)
        {
            for(int i = 0, end = series->count(); i < end; ++i)
            {
                auto point = series->at(i);
                double x = point.x();
                double y = point.y();
                if(!std::isnan(x) && !std::isnan(y))
                {
                    xMin = std::min(xMin, x);
                    xMax = std::max(xMax, x);
                    yMin = std::min(yMin, y);
                    yMax = std::max(yMax, y);
                }
            }
        }
    }

    decadify(xMin, xMax);
    decadify(yMin, yMax);

    if(!(xMin == mXAxis->min()) || !(xMax == mXAxis->max())
            || !(yMin == mYAxis->min()) || !(yMax == mYAxis->max()))
    {
        mXAxis->setMin(xMin);
        mXAxis->setMax(xMax);
        mYAxis->setMin(yMin);
        mYAxis->setMax(yMax);
        emit axisChanged();
    }
}

}
