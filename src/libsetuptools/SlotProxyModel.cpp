#include "SlotProxyModel.h"
#include "util.h"

namespace SetupTools {

SlotProxyModel::SlotProxyModel(QObject *parent) :
    QAbstractProxyModel(parent),
    mTargetAllRoles(true),
    mStringFormat(true)
{
    connect(this, &QAbstractProxyModel::sourceModelChanged, this, &SlotProxyModel::onSourceModelChanged);
    updateTargetRoles();
}

QStringList SlotProxyModel::targetRoleNames() const
{
    return mTargetRoleNames;
}

void SlotProxyModel::setTargetRoleNames(QStringList val)
{
    if(updateDelta<>(mTargetRoleNames, val))
        emit targetRoleNamesChanged();

    updateTargetRoles();
}

void SlotProxyModel::setStringFormat(bool val)
{
    if(updateDelta<>(mStringFormat, val))
    {
        emit dataChanged(index(0, 0), index(rowCount() - 1, columnCount() - 1));
        emit stringFormatChanged();
    }
}

void SlotProxyModel::setTargetAllRoles(bool val)
{
    if(updateDelta<>(mTargetAllRoles, val))
        emit targetAllRolesChanged();

    updateTargetRoles();
}

void SlotProxyModel::setSlot(Slot *slot)
{
    if(updateDelta<>(mSlot, slot))
    {
        emit dataChanged(index(0, 0), index(rowCount() - 1, columnCount() - 1));
        emit slotChanged();
    }
}

void SlotProxyModel::updateTargetRoles()
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

QModelIndex SlotProxyModel::mapFromSource(const QModelIndex &sourceIndex) const
{
    if(!sourceIndex.isValid() || sourceIndex.parent().isValid())
        return QModelIndex();

    return index(sourceIndex.row(), sourceIndex.column());
}

QModelIndex SlotProxyModel::mapToSource(const QModelIndex &proxyIndex) const
{
    if(!proxyIndex.isValid() || proxyIndex.parent().isValid())
        return QModelIndex();

    return index(proxyIndex.row(), proxyIndex.column());
}

int SlotProxyModel::rowCount(const QModelIndex &parent) const
{
    QAbstractItemModel *source = sourceModel();
    if(source)
        return source->rowCount(parent);
    else
        return 0;
}

int SlotProxyModel::columnCount(const QModelIndex &parent) const
{
    QAbstractItemModel *source = sourceModel();
    if(source)
        return source->columnCount(parent);
    else
        return 0;
}

QModelIndex SlotProxyModel::parent(const QModelIndex &child) const
{
    Q_UNUSED(child);
    return QModelIndex();
}

QModelIndex SlotProxyModel::index(int row, int column, const QModelIndex &parent) const
{
    if(parent.isValid())
        return QModelIndex();

    return createIndex(row, column, nullptr);
}

QVariant SlotProxyModel::data(const QModelIndex &proxyIndex, int role) const
{
    if(!sourceModel())
    {
        return QVariant();
    }
    else if(mTargetRoles.contains(role))
    {
        QVariant sourceData = sourceModel()->data(mapToSource(proxyIndex), role);
        if(mSlot)
        {
            if(mStringFormat)
                return mSlot->asString(sourceData);
            else
                return mSlot->asFloat(sourceData);
        }
        else
        {
            return sourceData;
        }
    }
    else
    {
        return sourceModel()->data(mapToSource(proxyIndex), role);
    }
}

bool SlotProxyModel::setData(const QModelIndex &index, const QVariant &value, int role)
{
    if(!sourceModel())
        return false;
    else if(mTargetRoles.contains(role))
    {
        if(mSlot)
            return sourceModel()->setData(mapToSource(index), mSlot->asRaw(value), role);
        else
            return sourceModel()->setData(mapToSource(index), value, role);
    }
    else
    {
        return sourceModel()->setData(mapToSource(index), value, role);
    }
}

void SlotProxyModel::onSourceModelChanged()
{
    disconnect(mDataChangedConnection);

    QAbstractItemModel *source = sourceModel();
    mSourceRoleNumbers.clear();
    if(source)
    {
        mDataChangedConnection = connect(source, &QAbstractItemModel::dataChanged, this, &SlotProxyModel::onSourceDataChanged);
        auto sourceRoleNames = source->roleNames();
        for(int role : sourceRoleNames.keys())
        {
            QString name = QString::fromLatin1(sourceRoleNames[role]);
            mSourceRoleNumbers[name] = role;
        }
    }
    updateTargetRoles();
}

void SlotProxyModel::onSourceDataChanged(const QModelIndex &topLeft, const QModelIndex &bottomRight, const QVector<int> &roles)
{
    emit dataChanged(mapFromSource(topLeft), mapFromSource(bottomRight), roles);
}

} // namespace SetupTools
