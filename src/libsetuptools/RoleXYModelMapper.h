#ifndef ROLEMODELLINESERIES_H
#define ROLEMODELLINESERIES_H

#include <QObject>
#include <QtCharts/QLineSeries>
#include <QAbstractItemModel>

namespace SetupTools {

class RoleXYModelMapper : public QObject
{
    Q_OBJECT
    Q_PROPERTY(QAbstractItemModel * model READ model WRITE setModel NOTIFY modelChanged)
    Q_PROPERTY(QT_CHARTS_NAMESPACE::QXYSeries * series READ series WRITE setSeries NOTIFY seriesChanged)
    Q_PROPERTY(QString xRole READ xRole WRITE setXRole NOTIFY xRoleChanged)
    Q_PROPERTY(QString yRole READ yRole WRITE setYRole NOTIFY yRoleChanged)
public:
    explicit RoleXYModelMapper(QObject *parent = 0);
    QAbstractItemModel * model()
    {
        return mModel;
    }
    QT_CHARTS_NAMESPACE::QXYSeries * series()
    {
        return mSeries;
    }
    QString xRole()
    {
        return mXRole;
    }
    QString yRole()
    {
        return mYRole;
    }

    void setModel(QAbstractItemModel * model);
    void setSeries(QT_CHARTS_NAMESPACE::QXYSeries * series);
    void setXRole(QString xRole);
    void setYRole(QString yRole);

signals:
    void modelChanged();
    void seriesChanged();
    void xRoleChanged();
    void yRoleChanged();
public slots:
    void onModelDataChanged(const QModelIndex &topLeft, const QModelIndex &bottomRight, const QVector<int> &roles);
private:
    void regenerate();
    int roleIndex(QString name);

    QAbstractItemModel * mModel;
    QT_CHARTS_NAMESPACE::QXYSeries * mSeries;
    QString mXRole;
    QString mYRole;
    int mXRoleIndex;
    int mYRoleIndex;
};

}   // namespace SetupTools

#endif // ROLEMODELLINESERIES_H
