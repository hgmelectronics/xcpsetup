#include "TransposeProxyModel.h"

namespace SetupTools {

TransposeProxyModel::TransposeProxyModel(QObject *parent) :
    QAbstractProxyModel(parent)
{
    connect(this, &QAbstractProxyModel::sourceModelChanged, this, &TransposeProxyModel::onSourceModelChanged);
}

QModelIndex TransposeProxyModel::mapFromSource(const QModelIndex &sourceIndex) const
{
    if(!sourceIndex.isValid() || sourceIndex.parent().isValid())
        return QModelIndex();

    return index(sourceIndex.column(), sourceIndex.row());
}

QModelIndex TransposeProxyModel::mapToSource(const QModelIndex &proxyIndex) const
{
    if(!proxyIndex.isValid() || proxyIndex.parent().isValid())
        return QModelIndex();

    return index(proxyIndex.column(), proxyIndex.row());
}

int TransposeProxyModel::rowCount(const QModelIndex &parent) const
{
    QAbstractItemModel *source = sourceModel();
    if(source)
        return source->columnCount(parent);
    else
        return 0;
}

int TransposeProxyModel::columnCount(const QModelIndex &parent) const
{
    QAbstractItemModel *source = sourceModel();
    if(source)
        return source->rowCount(parent);
    else
        return 0;
}

QModelIndex TransposeProxyModel::parent(const QModelIndex &child) const
{
    Q_UNUSED(child);
    return QModelIndex();
}

QModelIndex TransposeProxyModel::index(int row, int column, const QModelIndex &parent) const
{
    if(parent.isValid())
        return QModelIndex();

    return createIndex(row, column, nullptr);
}

void TransposeProxyModel::onSourceModelChanged()
{
    disconnect(mDataChangedConnection);

    QAbstractItemModel *source = sourceModel();
    if(source)
        mDataChangedConnection = connect(source, &QAbstractItemModel::dataChanged, this, &TransposeProxyModel::onSourceDataChanged);
}

void TransposeProxyModel::onSourceDataChanged(const QModelIndex &topLeft, const QModelIndex &bottomRight, const QVector<int> &roles)
{
    emit dataChanged(mapFromSource(topLeft), mapFromSource(bottomRight), roles);
}

} // namespace SetupTools
