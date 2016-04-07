#ifndef ROLEMODELEDAUTOAXIS_H
#define ROLEMODELEDAUTOAXIS_H

#include <QObject>
#include <QtCharts/QValueAxis>
#include <QQmlListProperty>
#include <QtCharts/QXYSeries>

namespace SetupTools {

class XYSeriesAutoAxis : public QObject
{
    Q_OBJECT

    Q_PROPERTY(QQmlListProperty<QtCharts::QXYSeries> series READ series)
    Q_PROPERTY(QtCharts::QValueAxis * xAxis READ xAxis NOTIFY axisChanged)
    Q_PROPERTY(QtCharts::QValueAxis * yAxis READ yAxis NOTIFY axisChanged)
    Q_PROPERTY(bool includeInvisible READ includeInvisible WRITE setIncludeInvisible NOTIFY includeInvisibleChanged)
public:
    explicit XYSeriesAutoAxis(QObject *parent = 0);
    QQmlListProperty<QtCharts::QXYSeries> & series()
    {
        return mSeriesProperty;
    }
    QtCharts::QValueAxis * xAxis()
    {
        return mXAxis;
    }
    QtCharts::QValueAxis * yAxis()
    {
        return mYAxis;
    }
    bool includeInvisible() const
    {
        return mIncludeInvisible;
    }

    static void seriesAppend(QQmlListProperty<QtCharts::QXYSeries> * property, QtCharts::QXYSeries * value);
    static QtCharts::QXYSeries * seriesAt(QQmlListProperty<QtCharts::QXYSeries> * property, int index);
    static void seriesClear(QQmlListProperty<QtCharts::QXYSeries> * property);
    static int seriesCount(QQmlListProperty<QtCharts::QXYSeries> * property);
    void appendSeries(QtCharts::QXYSeries * series);
    void clearSeries();
    void setIncludeInvisible(bool value);
signals:
    void axisChanged();
    void includeInvisibleChanged();
public slots:
    void onSeriesChanged();
private:
    QQmlListProperty<QtCharts::QXYSeries> mSeriesProperty;
    QList<QtCharts::QXYSeries *> mSeries;
    QtCharts::QValueAxis * mXAxis;
    QtCharts::QValueAxis * mYAxis;
    bool mIncludeInvisible;
};

}   // namespace SetupTools

#endif // ROLEMODELEDAUTOAXIS_H
