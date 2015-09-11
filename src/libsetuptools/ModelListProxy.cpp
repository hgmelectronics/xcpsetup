#include "ModelListProxy.h"
#include "util.h"

namespace SetupTools {

ModelListProxy::ModelListProxy(QObject *parent) :
    QObject(parent),
    mSource(nullptr),
    mCoercedType(Type::Double),
    mShape(Shape::ColumnVector),
    mRole(Qt::DisplayRole)
{}

QVariantList ModelListProxy::list() const
{
    return mList;
}

void ModelListProxy::setSource(QAbstractItemModel *source)
{
    disconnect(mDataChangedConnection);
    disconnect(mLayoutChangedConnection);

    mSource = source;

    if(mSource)
    {
        mDataChangedConnection = connect(mSource, &QAbstractItemModel::dataChanged, this, &ModelListProxy::onSourceDataChanged);
        mLayoutChangedConnection = connect(mSource, &QAbstractItemModel::layoutChanged, this, &ModelListProxy::onSourceLayoutChanged);

        updateRole();

        createListData();
    }
}

void ModelListProxy::setCoercedType(int type)
{
    if(updateDelta<>(mCoercedType, type) && mSource)
        createListData();
}

void ModelListProxy::setRoleName(QString roleName)
{
    if(updateDelta<>(mRoleName, roleName))
    {
        updateRole();

        if(mSource)
            createListData();
    }
}

void ModelListProxy::setShape(int shape)
{
    if(shape != Shape::ColumnVector && shape != Shape::RowVector && shape != Shape::Matrix)
        return;

    if(updateDelta<>(mShape, shape) && mSource)
        createListData();
}

void ModelListProxy::onSourceDataChanged(const QModelIndex &topLeft, const QModelIndex &bottomRight, const QVector<int> &roles)
{
    Q_ASSERT(mSource);

    if(roles.count(mRole))
        updateListData(topLeft.row(), topLeft.column(), bottomRight.row(), bottomRight.column());
}

void ModelListProxy::onSourceLayoutChanged(const QList<QPersistentModelIndex> &parents, QAbstractItemModel::LayoutChangeHint hint)
{
    Q_UNUSED(parents);
    Q_UNUSED(hint);

    Q_ASSERT(mSource);

    createListData();
}

QVariant ModelListProxy::coerceData(QVariant data)
{
    if(mCoercedType == Type::Invalid)
        return data;
    QVariant out = data;
    out.convert(mCoercedType);
    return out;
}

void ModelListProxy::createListData()
{
    mList.clear();
    switch(mShape)
    {
    case Shape::ColumnVector:
        mList.reserve(mSource->rowCount());
        for(int iRow = 0; iRow < mSource->rowCount(); ++iRow)
            mList.append(coerceData(mSource->data(mSource->index(iRow, 0), mRole)));
        break;
    case Shape::RowVector:
        mList.reserve(mSource->columnCount());
        for(int iColumn = 0; iColumn < mSource->columnCount(); ++iColumn)
            mList.append(coerceData(mSource->data(mSource->index(0, iColumn), mRole)));
        break;
    case Shape::Matrix:
        mList.reserve(mSource->rowCount());
        for(int iRow = 0; iRow < mSource->rowCount(); ++iRow)
        {
            QVariantList rowList;
            rowList.reserve(mSource->columnCount());
            for(int iColumn = 0; iColumn < mSource->columnCount(); ++iColumn)
                rowList.append(coerceData(mSource->data(mSource->index(iRow, iColumn), mRole)));
            mList.append(rowList);
        }
        break;
    default:
        Q_ASSERT(0);
        break;
    }

    emit listChanged();
}

void ModelListProxy::updateListData(int topRow, int leftColumn, int bottomRow, int rightColumn)
{
    Q_ASSERT(topRow >= 0 && topRow <= bottomRow);
    Q_ASSERT(bottomRow < mSource->rowCount());
    Q_ASSERT(leftColumn >= 0 && leftColumn <= rightColumn);
    Q_ASSERT(rightColumn < mSource->columnCount());

    switch(mShape)
    {
    case Shape::ColumnVector:
        for(int iRow = topRow; iRow <= bottomRow; ++iRow)
            mList[iRow] = coerceData(mSource->data(mSource->index(iRow, 0), mRole));
        break;
    case Shape::RowVector:
        for(int iColumn = leftColumn; iColumn <= rightColumn; ++iColumn)
            mList[iColumn] = coerceData(mSource->data(mSource->index(0, iColumn), mRole));
        break;
    case Shape::Matrix:
        for(int iRow = topRow; iRow <= bottomRow; ++iRow)
        {
            QVariantList rowList = mList[iRow].value<QVariantList>();
            for(int iColumn = leftColumn; iColumn <= rightColumn; ++iColumn)
                rowList[iColumn] = coerceData(mSource->data(mSource->index(iRow, iColumn), mRole));
            mList[iRow] = rowList;
        }
        break;
    default:
        Q_ASSERT(0);
        break;
    }

    emit listChanged();
}

void ModelListProxy::updateRole()
{
    mRole = Qt::DisplayRole;

    if(mSource)
    {
        for(int role : mSource->roleNames().keys())
        {
            if(mSource->roleNames()[role] == mRoleName)
            {
                mRole = role;
                break;
            }
        }
    }
}

} // namespace SetupTools

