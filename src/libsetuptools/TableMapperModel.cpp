#include "TableMapperModel.h"
#include "util.h"

namespace SetupTools {

static int roleToSubModelNum(int role)
{
    return role - Qt::UserRole;
}

static int subModelNumToRole(int num)
{
    return num + Qt::UserRole;
}

TableMapperModel::TableMapperModel(QObject *parent) :
    QAbstractItemModel(parent),
    mRowCount(0),
    mColumnCount(0)
{}

bool TableMapperModel::tryUpdateMapping()
{
    // determine the new dimensions of the model, and confirm that all values in the QVariantMap are convertible to QAbstractItemModel *
    int newRowCount = 0;
    int newColumnCount = 0;

    for(const QString &roleName : mMapping.keys())
    {
        QAbstractItemModel *subModel = mMapping[roleName].value<QAbstractItemModel *>();
        if(subModel == nullptr)
            qWarning("TableMapperModel submodel \"%s\" not convertible to QAbstractItemModel, instead type %d", roleName.toLocal8Bit().data(), mMapping[roleName].type());
        Q_ASSERT(subModel != nullptr);

        newRowCount = std::max(newRowCount, subModel->rowCount());
        newColumnCount = std::max(newColumnCount, subModel->columnCount());
    }

    bool newModelEmpty = false;
    for(const QString &roleName : mMapping.keys())   // verify dimensions are compatible
    {
        QAbstractItemModel *subModel = mMapping[roleName].value<QAbstractItemModel *>();

        if((subModel->rowCount() != 1 && subModel->rowCount() != newRowCount) ||
            (subModel->columnCount() != 1 && subModel->columnCount() != newColumnCount))
        {
            newModelEmpty = true;
            newRowCount = 0;
            newColumnCount = 0;
        }
    }

    // disconnect old change signals
    for(QAbstractItemModel *subModel : mSubModels)
    {
        disconnect(subModel, &QAbstractItemModel::dataChanged, this, &TableMapperModel::onMappedDataChanged);
        disconnect(subModel, &QAbstractItemModel::rowsInserted, this, &TableMapperModel::onSubmodelRowsColsAddedRemoved);
        disconnect(subModel, &QAbstractItemModel::rowsRemoved, this, &TableMapperModel::onSubmodelRowsColsAddedRemoved);
        disconnect(subModel, &QAbstractItemModel::columnsInserted, this, &TableMapperModel::onSubmodelRowsColsAddedRemoved);
        disconnect(subModel, &QAbstractItemModel::columnsRemoved, this, &TableMapperModel::onSubmodelRowsColsAddedRemoved);
    }

    // call pre-hook for dimensional change
    int oldRowCount = mRowCount;
    int oldColumnCount = mColumnCount;

    if(oldRowCount != newRowCount
            && oldColumnCount != newColumnCount)
    {
        // Qt does not seem to like changing both dimensions at the same time
        // Work around by removing all rows, then changing column dimension to final, then proceeding as normal
        if(oldRowCount > 0)
        {
            beginRemoveRows(QModelIndex(), 0, oldRowCount - 1);
            mRowCount = 0;
            endRemoveRows();
        }

        if(newColumnCount > oldColumnCount)
            beginInsertColumns(QModelIndex(), oldColumnCount, newColumnCount - 1);
        else if(newColumnCount < oldColumnCount)
            beginRemoveColumns(QModelIndex(), newColumnCount, oldColumnCount - 1);
        mColumnCount = newColumnCount;

        if(newColumnCount > oldColumnCount)
            endInsertColumns();
        else if(newColumnCount < oldColumnCount)
            endRemoveColumns();

        oldRowCount = mRowCount;
        oldColumnCount = mColumnCount;
    }

    if(newRowCount > oldRowCount)
        beginInsertRows(QModelIndex(), oldRowCount, newRowCount - 1);
    else if(newRowCount < oldRowCount)
        beginRemoveRows(QModelIndex(), newRowCount, oldRowCount - 1);

    if(newColumnCount > oldColumnCount)
        beginInsertColumns(QModelIndex(), oldColumnCount, newColumnCount - 1);
    else if(newColumnCount < oldColumnCount)
        beginRemoveColumns(QModelIndex(), newColumnCount, oldColumnCount - 1);

    // set up members and confirm all sub-model dimensions are either 1 or model dimension
    mRowCount = newRowCount;
    mColumnCount = newColumnCount;
    mSubModels.clear();
    mSubModels.reserve(mMapping.size());
    mRoleNames.clear();
    mRoleNames.reserve(mMapping.size());

    int role = Qt::UserRole;
    for(const QString &roleName : mMapping.keys())
    {
        QAbstractItemModel *subModel = mMapping[roleName].value<QAbstractItemModel *>();

        mSubModels.append(subModel);
        connect(subModel, &QAbstractItemModel::dataChanged, this, &TableMapperModel::onMappedDataChanged);
        connect(subModel, &QAbstractItemModel::rowsInserted, this, &TableMapperModel::onSubmodelRowsColsAddedRemoved);
        connect(subModel, &QAbstractItemModel::rowsRemoved, this, &TableMapperModel::onSubmodelRowsColsAddedRemoved);
        connect(subModel, &QAbstractItemModel::columnsInserted, this, &TableMapperModel::onSubmodelRowsColsAddedRemoved);
        connect(subModel, &QAbstractItemModel::columnsRemoved, this, &TableMapperModel::onSubmodelRowsColsAddedRemoved);
        mRoleNames[role] = roleName.toUtf8();
        ++role;
    }

    // call post-hook for dimensional change
    if(newRowCount > oldRowCount)
        endInsertRows();
    else if(newRowCount < oldRowCount)
        endRemoveRows();

    if(newColumnCount > oldColumnCount)
        endInsertColumns();
    else if(newColumnCount < oldColumnCount)
        endRemoveColumns();

    if(!newModelEmpty)
        // all data in the model has changed
        emit dataChanged(index(0, 0), index(mRowCount - 1, mColumnCount - 1), QVector<int>::fromList(mRoleNames.keys()));

    return !newModelEmpty;
}

void TableMapperModel::setMapping(const QVariantMap &mapping)
{
    // do nothing if the mapping has not changed
    if(!updateDelta<>(mMapping, mapping))
        return;

    tryUpdateMapping();
    // the mapping property has changed
    emit mappingChanged();
}

int TableMapperModel::rowCount(const QModelIndex &parent) const
{
    return parent.isValid() ? 0 : mRowCount;
}

int TableMapperModel::columnCount(const QModelIndex &parent) const
{
    return parent.isValid() ? 0 : mColumnCount;
}

QVariant TableMapperModel::data(const QModelIndex &index, int role) const
{
    if(!isValidIndex(index) || !isValidRole(role))
        return QVariant();

    QAbstractItemModel *subModel = mSubModels[roleToSubModelNum(role)];
    return subModel->data(index, Qt::DisplayRole);
}

QVariant TableMapperModel::headerData(int section, Qt::Orientation orientation, int role) const
{
    if(section < 0
            || (orientation == Qt::Horizontal && section >= mColumnCount)
            || (orientation == Qt::Vertical && section >= mRowCount)
            || mRoleNames.count(role) == 0)
        return QVariant();

    return QString::fromUtf8(mRoleNames[role]);
}

bool TableMapperModel::setData(const QModelIndex &index, const QVariant &value, int role)
{
    if(!isValidIndex(index) || !isValidRole(role))
        return false;

    QAbstractItemModel *subModel = mSubModels[roleToSubModelNum(role)];
    QModelIndex subIndex = subModelIndex(subModel, index);
    return subModel->setData(subIndex, value, Qt::DisplayRole);
}

Qt::ItemFlags TableMapperModel::flags(const QModelIndex &index) const
{
    Qt::ItemFlags orFlags = 0;

    for(int i = 0; i < mSubModels.size(); ++i)
        orFlags |= mSubModels[i]->flags(subModelIndex(i, index));

    return orFlags;
}

QHash<int, QByteArray> TableMapperModel::roleNames() const
{
    return mRoleNames;
}

QModelIndex TableMapperModel::parent(const QModelIndex &child) const
{
    Q_UNUSED(child);
    return QModelIndex();
}

QModelIndex TableMapperModel::index(int row, int column, const QModelIndex &parent) const
{
    if(parent.isValid()
            || row < 0
            || row >= mRowCount
            || column < 0
            || column >= mColumnCount)
        return QModelIndex();

    return createIndex(row, column, nullptr);
}

void TableMapperModel::onMappedDataChanged(const QModelIndex &topLeft, const QModelIndex &bottomRight, const QVector<int> &roles)
{
    Q_UNUSED(roles);

    auto senderIt = std::find(mSubModels.begin(), mSubModels.end(), qobject_cast<QAbstractItemModel *>(QObject::sender()));
    Q_ASSERT(senderIt != mSubModels.end());

    int subModelNum = std::distance(mSubModels.begin(), senderIt);
    QAbstractItemModel *subModel = *senderIt;
    int topRow = topLeft.row();
    int leftColumn = topLeft.column();
    int bottomRow = bottomRight.row();
    int rightColumn = bottomRight.column();
    if(subModel->rowCount() == 1)
    {
        topRow = 0;
        bottomRow = mRowCount - 1;
    }
    if(subModel->columnCount() == 1)
    {
        leftColumn = 0;
        rightColumn = mColumnCount - 1;
    }
    QVector<int> rolesOut = {subModelNumToRole(subModelNum)};

    QModelIndex topLeftOut = index(topRow, leftColumn);
    QModelIndex bottomRightOut = index(bottomRow, rightColumn);
    if(topLeftOut.isValid() && bottomRightOut.isValid())
        emit dataChanged(topLeftOut, bottomRightOut, rolesOut);
}

void TableMapperModel::onSubmodelRowsColsAddedRemoved(const QModelIndex &parent, int first, int last)
{
    Q_UNUSED(parent);
    Q_UNUSED(first);
    Q_UNUSED(last);

    tryUpdateMapping();
}

bool TableMapperModel::isValidRole(int role) const
{
    int submodelNum = roleToSubModelNum(role);
    return 0 <= submodelNum && submodelNum < mSubModels.count();
}

bool TableMapperModel::isValidIndex(const QModelIndex &index) const
{
    return index.isValid()
            && index.column() >= 0
            && index.column() < mColumnCount
            && index.row() >= 0
            && index.row() < mRowCount;
}

QModelIndex TableMapperModel::subModelIndex(int subModelNum, const QModelIndex &index) const
{
    if(subModelNum < 0
            || subModelNum >= mSubModels.size())
        return QModelIndex();

    return subModelIndex(mSubModels[subModelNum], index);
}

QModelIndex TableMapperModel::subModelIndex(QAbstractItemModel *subModel, const QModelIndex &index) const
{
    if(index.parent().isValid())
        return QModelIndex();

    int row = (subModel->rowCount() == 1) ? 0 : index.row();
    int column = (subModel->columnCount() == 1) ? 0 : index.column();

    return subModel->index(row, column);
}

} // namespace SetupTools

