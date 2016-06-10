#include "ScaleOffsetProxyModel.h"
#include "util.h"

namespace SetupTools {

ScaleOffsetProxyModel::ScaleOffsetProxyModel(QObject *parent) :
    QAbstractProxyModel(parent),
    mScale(1),
    mOffset(0),
    mTargetAllRoles(true),
    mFormatSlot(nullptr)
{
    connect(this, &QAbstractProxyModel::sourceModelChanged, this, &ScaleOffsetProxyModel::onSourceModelChanged);
    updateTargetRoles();
}

int ScaleOffsetProxyModel::count() {
    return rowCount();
}

void ScaleOffsetProxyModel::setScale(double val)
{
    if(updateDelta<>(mScale, val))
    {
        emit dataChanged(index(0, 0), index(rowCount() - 1, columnCount() - 1));
        emit scaleChanged();
    }
}

void ScaleOffsetProxyModel::setOffset(double val)
{
    if(updateDelta<>(mOffset, val))
    {
        emit dataChanged(index(0, 0), index(rowCount() - 1, columnCount() - 1));
        emit offsetChanged();
    }
}

QStringList ScaleOffsetProxyModel::targetRoleNames() const
{
    return mTargetRoleNames;
}

void ScaleOffsetProxyModel::setTargetRoleNames(QStringList val)
{
    if(updateDelta<>(mTargetRoleNames, val))
        emit targetRoleNamesChanged();

    updateTargetRoles();
}

void ScaleOffsetProxyModel::setTargetAllRoles(bool val)
{
    if(updateDelta<>(mTargetAllRoles, val))
        emit targetAllRolesChanged();

    updateTargetRoles();
}

void ScaleOffsetProxyModel::setFormatSlot(Slot *formatSlot)
{
    if(updateDelta<>(mFormatSlot, formatSlot))
    {
        emit dataChanged(index(0, 0), index(rowCount() - 1, columnCount() - 1));
        emit formatSlotChanged();
    }
}

void ScaleOffsetProxyModel::updateTargetRoles()
{
    QSet<int> oldRoles = mTargetRoles;
    mTargetRoles.clear();

    QSet<int> sourceRoleSet;
    if(sourceModel())
        sourceRoleSet = QSet<int>::fromList(sourceModel()->roleNames().keys());

    if(mTargetAllRoles)
    {
        mTargetRoles = sourceRoleSet;
    }
    else
    {
        for(const QString &roleName : mTargetRoleNames)
        {
            if(mSourceRoleNumbers.count(roleName))
                mTargetRoles << mSourceRoleNumbers[roleName];
        }
    }
    QSet<int> changedRoles = ((oldRoles | mTargetRoles) - (oldRoles & mTargetRoles)) & sourceRoleSet;
    if(!changedRoles.empty())
        emit dataChanged(index(0, 0), index(rowCount() - 1, columnCount() - 1), changedRoles.toList().toVector());
}

QModelIndex ScaleOffsetProxyModel::mapFromSource(const QModelIndex &sourceIndex) const
{
    if(!sourceIndex.isValid() || sourceIndex.parent().isValid())
        return QModelIndex();

    return index(sourceIndex.row(), sourceIndex.column());
}

QModelIndex ScaleOffsetProxyModel::mapToSource(const QModelIndex &proxyIndex) const
{
    if(!proxyIndex.isValid() || proxyIndex.parent().isValid())
        return QModelIndex();

    return index(proxyIndex.row(), proxyIndex.column());
}

int ScaleOffsetProxyModel::rowCount(const QModelIndex &parent) const
{
    QAbstractItemModel *source = sourceModel();
    if(source)
        return source->rowCount(parent);
    else
        return 0;
}

int ScaleOffsetProxyModel::columnCount(const QModelIndex &parent) const
{
    QAbstractItemModel *source = sourceModel();
    if(source)
        return source->columnCount(parent);
    else
        return 0;
}

QModelIndex ScaleOffsetProxyModel::parent(const QModelIndex &child) const
{
    Q_UNUSED(child);
    return QModelIndex();
}

QModelIndex ScaleOffsetProxyModel::index(int row, int column, const QModelIndex &parent) const
{
    if(parent.isValid())
        return QModelIndex();

    return createIndex(row, column, nullptr);
}

QVariant ScaleOffsetProxyModel::data(const QModelIndex &proxyIndex, int role) const
{
    if(!sourceModel())
    {
        return QVariant();
    }
    else if(mTargetRoles.contains(role))
    {
        double scaled = sourceModel()->data(mapToSource(proxyIndex), role).toDouble() * mScale + mOffset;
        if(mFormatSlot)
            return mFormatSlot->stringRoundtrip(scaled);
        else
            return scaled;
    }
    else
    {
        return sourceModel()->data(mapToSource(proxyIndex), role);
    }
}

bool ScaleOffsetProxyModel::setData(const QModelIndex &index, const QVariant &value, int role)
{
    if(!sourceModel())
        return false;
    else if(mTargetRoles.contains(role))
    {
        bool convOk;
        double floatValue = value.toDouble(&convOk);
        if(!convOk)
            return false;
        return sourceModel()->setData(mapToSource(index), (floatValue - mOffset) / mScale, role);
    }
    else
    {
        return sourceModel()->setData(mapToSource(index), value, role);
    }
}

void ScaleOffsetProxyModel::onSourceModelChanged()
{
    disconnect(mDataChangedConnection);
    disconnect(mColumnsAboutToBeInsertedConnection);
    disconnect(mColumnsAboutToBeRemovedConnection);
    disconnect(mColumnsInsertedConnection);
    disconnect(mColumnsRemovedConnection);
    disconnect(mRowsAboutToBeInsertedConnection);
    disconnect(mRowsAboutToBeRemovedConnection);
    disconnect(mRowsInsertedConnection);
    disconnect(mRowsRemovedConnection);

    QAbstractItemModel *source = sourceModel();
    mSourceRoleNumbers.clear();
    if(source)
    {
        mDataChangedConnection = connect(source, &QAbstractItemModel::dataChanged, this, &ScaleOffsetProxyModel::onSourceDataChanged);
        mColumnsAboutToBeInsertedConnection = connect(source, &QAbstractItemModel::columnsAboutToBeInserted, this, &ScaleOffsetProxyModel::onSourceColumnsAboutToBeInserted);
        mColumnsAboutToBeRemovedConnection = connect(source, &QAbstractItemModel::columnsAboutToBeRemoved, this, &ScaleOffsetProxyModel::onSourceColumnsAboutToBeRemoved);
        mColumnsInsertedConnection = connect(source, &QAbstractItemModel::columnsInserted, this, &ScaleOffsetProxyModel::onSourceColumnsInserted);
        mColumnsRemovedConnection = connect(source, &QAbstractItemModel::columnsRemoved, this, &ScaleOffsetProxyModel::onSourceColumnsRemoved);
        mRowsAboutToBeInsertedConnection = connect(source, &QAbstractItemModel::rowsAboutToBeInserted, this, &ScaleOffsetProxyModel::onSourceRowsAboutToBeInserted);
        mRowsAboutToBeRemovedConnection = connect(source, &QAbstractItemModel::rowsAboutToBeRemoved, this, &ScaleOffsetProxyModel::onSourceRowsAboutToBeRemoved);
        mRowsInsertedConnection = connect(source, &QAbstractItemModel::rowsInserted, this, &ScaleOffsetProxyModel::onSourceRowsInserted);
        mRowsRemovedConnection = connect(source, &QAbstractItemModel::rowsRemoved, this, &ScaleOffsetProxyModel::onSourceRowsRemoved);
        auto sourceRoleNames = source->roleNames();
        for(int role : sourceRoleNames.keys())
        {
            QString name = QString::fromLatin1(sourceRoleNames[role]);
            mSourceRoleNumbers[name] = role;
        }
    }
    updateTargetRoles();
}

void ScaleOffsetProxyModel::onSourceDataChanged(const QModelIndex &topLeft, const QModelIndex &bottomRight, const QVector<int> &roles)
{
    emit dataChanged(mapFromSource(topLeft), mapFromSource(bottomRight), roles);
}

void ScaleOffsetProxyModel::onSourceColumnsAboutToBeInserted(const QModelIndex &parent, int first, int last)
{
    beginInsertColumns(parent, first, last);
}

void ScaleOffsetProxyModel::onSourceColumnsAboutToBeRemoved(const QModelIndex &parent, int first, int last)
{
    beginRemoveRows(parent, first, last);
}

void ScaleOffsetProxyModel::onSourceColumnsInserted(const QModelIndex &parent, int first, int last)
{
    Q_UNUSED(parent);
    Q_UNUSED(first);
    Q_UNUSED(last);
    endInsertColumns();
}

void ScaleOffsetProxyModel::onSourceColumnsRemoved(const QModelIndex &parent, int first, int last)
{
    Q_UNUSED(parent);
    Q_UNUSED(first);
    Q_UNUSED(last);
    endRemoveColumns();
}

void ScaleOffsetProxyModel::onSourceRowsAboutToBeInserted(const QModelIndex &parent, int first, int last)
{
    beginInsertRows(parent, first, last);
}

void ScaleOffsetProxyModel::onSourceRowsAboutToBeRemoved(const QModelIndex &parent, int first, int last)
{
    beginRemoveRows(parent, first, last);
}

void ScaleOffsetProxyModel::onSourceRowsInserted(const QModelIndex &parent, int first, int last)
{
    Q_UNUSED(parent);
    Q_UNUSED(first);
    Q_UNUSED(last);
    endInsertRows();
    emit countChanged();
}

void ScaleOffsetProxyModel::onSourceRowsRemoved(const QModelIndex &parent, int first, int last)
{
    Q_UNUSED(parent);
    Q_UNUSED(first);
    Q_UNUSED(last);
    endRemoveRows();
    emit countChanged();
}

} // namespace SetupTools
