#include "Xcp_TableParam.h"

namespace SetupTools {
namespace Xcp {

TableParam::TableParam(QObject *parent) :
    Param(parent),
    mRange(nullptr),
    mAxis(nullptr),
    mStringModel(new TableParamListModel(true, this)),
    mFloatModel(new TableParamListModel(false, this))
{

}

TableParam::TableParam(TableMemoryRange* range, Slot* slot, TableAxis* axis, QObject* parent) :
    Param(range, slot, parent),
    mRange(range),
    mAxis(axis),
    mStringModel(new TableParamListModel(true, this)),
    mFloatModel(new TableParamListModel(false, this))
{
    Q_ASSERT(mAxis && mRange && slot);
    Q_ASSERT(mAxis->rowCount() == range->count());
    Q_ASSERT(mAxis->roleNames().size());   // must have at least an x

    for(int role = TableAxisRole::XRole, endRole = TableAxisRole::XRole + mAxis->roleNames().size(); role != endRole; ++role)
        Q_ASSERT(mAxis->roleNames().count(role));

    Q_ASSERT(mAxis->roleNames().count(TableAxisRole::ValueRole) == 0);

    connect(mRange, &MemoryRange::uploadDone, this, &TableParam::onRangeUploadDone);
    connect(mRange, &MemoryRange::downloadDone, this, &TableParam::onRangeDownloadDone);
    connect(mRange, &TableMemoryRange::dataChanged, this, &TableParam::onRangeDataChanged);
}

QVariant TableParam::get(int row) const
{
    return slot()->asFloat(mRange->get(row));
}

bool TableParam::set(int row, const QVariant& value) const
{
    return mRange->set(row, slot()->asRaw(value));
}

int TableParam::count() const
{
    return mRange->count();
}


QVariant TableParam::getSerializableValue(bool *allInRange, bool *anyInRange)
{
    Q_ASSERT(mAxis && mRange && slot());

    QStringList ret;
    ret.reserve(mRange->count());

    bool allInRangeAccum = true;
    bool anyInRangeAccum = false;

    for(QVariant elem : mRange->data())
    {
        bool inRange = slot()->rawInRange(elem);
        allInRangeAccum &= inRange;
        anyInRangeAccum |= inRange;
        ret.append(slot()->asString(elem));
    }

    if(allInRange)
        *allInRange = allInRangeAccum;

    if(anyInRange)
        *anyInRange = anyInRangeAccum;

    return ret;
}

bool TableParam::setSerializableValue(const QVariant &val)
{
    Q_ASSERT(mAxis && mRange && slot());
    if(val.type() != QVariant::StringList && val.type() != QVariant::List)
        return false;
    QStringList stringList = val.toStringList();
    if(stringList.size() != mRange->count())
        return false;

    for(QString str : stringList)
    {
        if(!slot()->engrInRange(str))
            return false;
    }

    QVariantList rawList;
    rawList.reserve(mRange->count());
    for(QString str : stringList)
        rawList.push_back(slot()->asRaw(str));

    return mRange->setDataRange(rawList, 0);
}

void TableParam::resetCaches()
{
    Q_ASSERT(mAxis && mRange && slot());
    mRange->resetCaches();
}

void TableParam::onRangeUploadDone(SetupTools::Xcp::OpResult result)
{
    emit uploadDone(result);
}

void TableParam::onRangeDownloadDone(SetupTools::Xcp::OpResult result)
{
    emit downloadDone(result);
}

void TableParam::onRangeDataChanged(quint32 beginChanged, quint32 endChanged)
{
    Q_UNUSED(beginChanged);
    Q_UNUSED(endChanged);
    emit modelDataChanged();
}

void TableParam::upload()
{
    Q_ASSERT(mAxis && mRange && slot());
    mRange->upload();
}

void TableParam::download()
{
    Q_ASSERT(mAxis && mRange && slot());
    mRange->download();
}

TableParamListModel::TableParamListModel(bool stringFormat, TableParam *parent) :
    QAbstractListModel(parent),
    mParam(parent),
    mStringFormat(stringFormat)
{
    mRoleNames = mParam->mAxis->roleNames();
    mRoleNames[TableAxisRole::ValueRole] = QByteArray("value");

    connect(mParam->slot(), &Slot::valueParamChanged, this, &TableParamListModel::onValueParamChanged);
    connect(mParam->range(), &TableMemoryRange::dataChanged, this, &TableParamListModel::onRangeDataChanged);
}

int TableParamListModel::rowCount(const QModelIndex &parent) const
{
    return parent.isValid() ? 0 : mParam->range()->count();
}

QVariant TableParamListModel::data(const QModelIndex &index, int role) const
{
    if(!index.isValid()
            || index.column() != 0
            || index.row() < 0
            || index.row() >= mParam->range()->count())
        return QVariant();

    if(role == TableAxisRole::ValueRole)
    {
        QVariant rawData = mParam->range()->get(index.row());
        if(mStringFormat)
            return mParam->slot()->asString(rawData);
        else
            return mParam->slot()->asFloat(rawData);
    }
    else
    {
        return mParam->mAxis->data(index, role);
    }
}

QVariant TableParamListModel::headerData(int section, Qt::Orientation orientation, int role) const
{
    if(section != 0
            || orientation != Qt::Horizontal)
        return QVariant();

    return QString(mRoleNames[role]);
}

bool TableParamListModel::setData(const QModelIndex &index, const QVariant &value, int role)
{
    if(!index.isValid()
            || index.column() != 0
            || index.row() < 0
            || index.row() >= mParam->range()->count()
            || role != TableAxisRole::ValueRole)
        return false;

    return mParam->range()->set(index.row(), mParam->slot()->asRaw(value));
}

Qt::ItemFlags TableParamListModel::flags(const QModelIndex &index) const
{
    Q_UNUSED(index);
    return Qt::ItemIsEnabled | Qt::ItemIsSelectable | Qt::ItemIsEditable;
}

QHash<int, QByteArray> TableParamListModel::roleNames() const
{
    return mRoleNames;
}

void TableParamListModel::onValueParamChanged()
{
    onRangeDataChanged(0, mParam->mRange->count());
}

void TableParamListModel::onRangeDataChanged(quint32 beginChanged, quint32 endChanged)
{
    static const QVector<int> ROLES({TableAxisRole::ValueRole});
    emit dataChanged(index(beginChanged), index(endChanged - 1), ROLES);
}

} // namespace Xcp
} // namespace SetupTools

