#include "RoleXYModelMapper.h"
#include "util.h"
#include "QDebug"

namespace SetupTools {

RoleXYModelMapper::RoleXYModelMapper(QObject *parent) :
    QObject(parent),
    mModel(nullptr),
    mSeries(qobject_cast<QtCharts::QXYSeries *>(parent)),
    mXRole("x"),
    mYRole("value"),
    mXRoleIndex(-1),
    mYRoleIndex(-1)
{
}

void RoleXYModelMapper::setModel(QAbstractItemModel *model)
{
    if(model == mModel)
        return;

    if(mModel)
        disconnect(mModel, &QAbstractItemModel::dataChanged, this, &RoleXYModelMapper::onModelDataChanged);

    if(model && model->columnCount() == 1)
    {
        connect(model, &QAbstractItemModel::dataChanged, this, &RoleXYModelMapper::onModelDataChanged);
        mModel = model;
    }
    else
    {
        mModel = nullptr;
    }

    mXRoleIndex = roleIndex(mXRole);
    mYRoleIndex = roleIndex(mYRole);

    regenerate();

    emit modelChanged();
}

void RoleXYModelMapper::setSeries(QT_CHARTS_NAMESPACE::QXYSeries *series)
{
    if(updateDelta<>(mSeries, series))
    {
        regenerate();

        emit seriesChanged();
    }
}

void RoleXYModelMapper::setXRole(QString xRole)
{
    if(updateDelta<>(mXRole, xRole))
    {
        mXRoleIndex = roleIndex(mXRole);

        regenerate();

        emit xRoleChanged();
    }
}

void RoleXYModelMapper::setYRole(QString yRole)
{
    if(updateDelta<>(mYRole, yRole))
    {
        mYRoleIndex = roleIndex(mYRole);

        regenerate();

        emit yRoleChanged();
    }
}

void RoleXYModelMapper::onModelDataChanged(const QModelIndex &topLeft, const QModelIndex &bottomRight, const QVector<int> &roles)
{
    Q_UNUSED(topLeft);
    Q_UNUSED(bottomRight);
    Q_UNUSED(roles);

    regenerate();
}

void RoleXYModelMapper::regenerate()
{
    //mSeries = qobject_cast<QtCharts::QXYSeries *>(parent());
    if(!mSeries)
        return;

    if(mXRoleIndex < 0 || mYRoleIndex < 0)
    {
        mSeries->removePoints(0, mSeries->count());   // delete all data
        return;
    }

    QVector<QPointF> points;
    points.reserve(mModel->rowCount());
    for(int i = 0; i < mModel->rowCount(); ++i)
    {
        QModelIndex index = mModel->index(i, 0);
        qreal x = mModel->data(index, mXRoleIndex).toReal();
        qreal y = mModel->data(index, mYRoleIndex).toReal();
        if(!std::isnan(x) && !std::isnan(y))
            points.push_back(QPointF(x, y));
    }

    mSeries->replace(points);

//    mSeries->removePoints(0, mSeries->count());

//    for(auto & point : points)
//        mSeries->insert(mSeries->count(), point);
}

int RoleXYModelMapper::roleIndex(QString name)
{
    if(!mModel)
        return -1;

    QByteArray nameBytes = name.toUtf8();

    QHash<int, QByteArray> roleNames = mModel->roleNames();

    for(auto it = roleNames.begin(), end = roleNames.end(); it != end; ++it)
    {
        if(it.value() == nameBytes)
            return it.key();
    }

    return -1;
}

}   // namespace SetupTools
