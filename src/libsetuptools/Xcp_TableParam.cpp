#include "Xcp_TableParam.h"

namespace SetupTools {
namespace Xcp {

TableParam::TableParam(QObject *parent) :
    Param(parent),
    mRange(nullptr),
    mSlot(nullptr),
    mAxis(nullptr),
    mStringModel(new TableParamListModel(true, this)),
    mFloatModel(new TableParamListModel(false, this))
{}

TableParam::TableParam(TableMemoryRange *range, const Slot *slot, const TableAxis *axis, QObject *parent) :
    Param(range, parent),
    mRange(range),
    mSlot(slot),
    mAxis(axis),
    mStringModel(new TableParamListModel(true, this)),
    mFloatModel(new TableParamListModel(false, this))
{
    Q_ASSERT(mAxis->rowCount() == range->rowCount());
    Q_ASSERT(mAxis->roleNames().size());   // must have at least an x
    for(int role = TableAxisRole::XRole, endRole = TableAxisRole::XRole + mAxis->roleNames().size(); role != endRole; ++role)
        Q_ASSERT(mAxis->roleNames().count(role));
    Q_ASSERT(mAxis->roleNames().count(TableAxisRole::ValueRole) == 0);

    connect(mAxis, &TableAxis::xUnitChanged, this, &TableParam::onAxisXUnitChanged);
    connect(mAxis, &TableAxis::yUnitChanged, this, &TableParam::onAxisYUnitChanged);
    connect(mSlot, &Slot::unitChanged, this, &TableParam::onSlotUnitChanged);
    connect(mRange, &MemoryRange::uploadDone, this, &TableParam::onRangeUploadDone);
    connect(mRange, &MemoryRange::downloadDone, this, &TableParam::onRangeDownloadDone);
}

QString TableParam::unit(int role)
{
    Q_ASSERT(mAxis && mRange && mSlot);
    switch(role)
    {
    case TableAxisRole::XRole:
        return mAxis->xUnit();
        break;
    case TableAxisRole::YRole:
        return mAxis->yUnit();
        break;
    case TableAxisRole::ValueRole:
        return mSlot->unit();
        break;
    default:
        return QString("");
        break;
    }
}

TableParamListModel *TableParam::stringModel()
{
    Q_ASSERT(mAxis && mRange && mSlot);
    return mStringModel;
}

TableParamListModel *TableParam::floatModel()
{
    Q_ASSERT(mAxis && mRange && mSlot);
    return mFloatModel;
}

QString TableParam::xLabel() const
{
    Q_ASSERT(mAxis && mRange && mSlot);
    return mXLabel;
}

QString TableParam::yLabel() const
{
    Q_ASSERT(mAxis && mRange && mSlot);
    return mYLabel;
}

QString TableParam::valueLabel() const
{
    Q_ASSERT(mAxis && mRange && mSlot);
    return mValueLabel;
}

void TableParam::setXLabel(QString newVal)
{
    Q_ASSERT(mAxis && mRange && mSlot);
    if(updateDelta<>(mXLabel, newVal))
        emit xLabelChanged();
}

void TableParam::setYLabel(QString newVal)
{
    Q_ASSERT(mAxis && mRange && mSlot);
    if(updateDelta<>(mYLabel, newVal))
        emit yLabelChanged();
}

void TableParam::setValueLabel(QString newVal)
{
    Q_ASSERT(mAxis && mRange && mSlot);
    if(updateDelta<>(mValueLabel, newVal))
        emit valueLabelChanged();
}

QString TableParam::xUnit() const
{
    Q_ASSERT(mAxis && mRange && mSlot);
    return mAxis->xUnit();
}

QString TableParam::yUnit() const
{
    Q_ASSERT(mAxis && mRange && mSlot);
    return mAxis->yUnit();
}

QString TableParam::valueUnit() const
{
    Q_ASSERT(mAxis && mRange && mSlot);
    return mSlot->unit();
}

const TableMemoryRange *TableParam::range() const
{
    Q_ASSERT(mAxis && mRange && mSlot);
    return mRange;
}

QVariant TableParam::getSerializableValue()
{
    Q_ASSERT(mAxis && mRange && mSlot);
    QStringList ret;
    ret.reserve(mRange->rowCount());
    for(QVariant elem : mRange->data())
        ret.append(mSlot->toString(elem));
    return ret;
}

bool TableParam::setSerializableValue(const QVariant &val)
{
    Q_ASSERT(mAxis && mRange && mSlot);
    if(val.type() != QVariant::StringList && val.type() != QVariant::List)
        return false;
    QStringList stringList = val.toStringList();
    if(stringList.size() != mRange->rowCount())
        return false;

    for(QString str : stringList)
    {
        if(!mSlot->engrInRange(str))
            return false;
    }

    QVariantList rawList;
    rawList.reserve(mRange->rowCount());
    for(QString str : stringList)
        rawList.push_back(mSlot->toRaw(str));

    return mRange->setDataRange(rawList, 0);
}

void TableParam::resetCaches()
{
    Q_ASSERT(mAxis && mRange && mSlot);
    mRange->resetCaches();
}

void TableParam::onAxisXUnitChanged()
{
    emit xUnitChanged();
}

void TableParam::onAxisYUnitChanged()
{
    emit yUnitChanged();
}

void TableParam::onSlotUnitChanged()
{
    emit valueUnitChanged();
}

void TableParam::onRangeUploadDone(SetupTools::Xcp::OpResult result)
{
    emit uploadDone(result);
}

void TableParam::onRangeDownloadDone(SetupTools::Xcp::OpResult result)
{
    emit downloadDone(result);
}

void TableParam::upload()
{
    Q_ASSERT(mAxis && mRange && mSlot);
    mRange->upload();
}

void TableParam::download()
{
    Q_ASSERT(mAxis && mRange && mSlot);
    mRange->download();
}

TableParamListModel::TableParamListModel(bool stringFormat, TableParam *parent) :
    QAbstractListModel(parent),
    mParam(parent),
    mStringFormat(stringFormat)
{
    connect(mParam, &TableParam::xLabelChanged, this, &TableParamListModel::onTableLabelChanged);
    connect(mParam, &TableParam::yLabelChanged, this, &TableParamListModel::onTableLabelChanged);
    connect(mParam, &TableParam::valueLabelChanged, this, &TableParamListModel::onTableLabelChanged);
    connect(mParam->mSlot, &Slot::valueParamChanged, this, &TableParamListModel::onValueParamChanged);
    connect(mParam->mRange, &TableMemoryRange::dataChanged, this, &TableParamListModel::onRangeDataChanged);
}

int TableParamListModel::rowCount(const QModelIndex &parent) const
{
    if(parent.isValid())
        return 0;
    else
        return mParam->mRange->rowCount();
}

QVariant TableParamListModel::data(const QModelIndex &index, int role) const
{
    if(!index.isValid()
            || index.column() != 0
            || index.row() < 0
            || index.row() >= mParam->mRange->rowCount())
        return QVariant();

    if(role == TableAxisRole::ValueRole)
    {
        QVariant rawData = mParam->mRange->data()[index.row()];
        if(mStringFormat)
            return mParam->mSlot->toString(rawData);
        else
            return mParam->mSlot->toFloat(rawData);
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

    switch(role)
    {
    case TableAxisRole::XRole:
        return mParam->xLabel();
        break;
    case TableAxisRole::YRole:
        return mParam->yLabel();
        break;
    case TableAxisRole::ValueRole:
        return mParam->valueLabel();
        break;
    default:
        return QVariant();
        break;
    }
}

bool TableParamListModel::setData(const QModelIndex &index, const QVariant &value, int role)
{
    if(!index.isValid()
            || index.column() != 0
            || index.row() < 0
            || index.row() >= mParam->mRange->rowCount()
            || role != TableAxisRole::ValueRole)
        return false;

    return mParam->mRange->setData(mParam->mSlot->toRaw(value), index.row());
}

void TableParamListModel::onTableLabelChanged()
{
    emit headerDataChanged(Qt::Horizontal, 0, 0);
}

void TableParamListModel::onValueParamChanged()
{
    onRangeDataChanged(0, mParam->mRange->rowCount());
}

void TableParamListModel::onRangeDataChanged(quint32 beginChanged, quint32 endChanged)
{
    static const QVector<int> ROLES({TableAxisRole::ValueRole});
    emit dataChanged(index(beginChanged), index(endChanged - 1), ROLES);
}

} // namespace Xcp
} // namespace SetupTools

