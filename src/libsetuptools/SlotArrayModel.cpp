#include "SlotArrayModel.h"
#include "util.h"

namespace SetupTools {

SlotArrayModel::SlotArrayModel(QObject *parent) :
    QAbstractListModel(parent),
    mSlot(nullptr),
    mCount(0),
    mMin(0),
    mStride(1),
    mStringFormat(true)
{}

SlotArrayModel::SlotArrayModel(Slot *slot, int count, int min, int stride, bool stringFormat, QObject *parent) :
    QAbstractListModel(parent),
    mSlot(slot),
    mCount(count),
    mMin(min),
    mStride(stride),
    mStringFormat(stringFormat)
{
    if(mSlot != nullptr)
        connect(mSlot, &Slot::valueParamChanged, this, &SlotArrayModel::onSlotValueParamChanged);
}

QVariant SlotArrayModel::get(int row) const
{
    return data(index(row));
}

void SlotArrayModel::setSlot(Slot *newSlot)
{
    if(mSlot == newSlot)
        return;

    if(mSlot != nullptr)
        disconnect(mSlot, &Slot::valueParamChanged, this, &SlotArrayModel::onSlotValueParamChanged);
    mSlot = newSlot;
    if(mSlot != nullptr)
        connect(mSlot, &Slot::valueParamChanged, this, &SlotArrayModel::onSlotValueParamChanged);

    emit slotChanged();
    emit dataChanged(index(0), index(mCount - 1));
}

void SlotArrayModel::setCount(int newCount)
{
    Q_ASSERT(newCount >= 0);
    if(newCount > mCount)
    {
        emit countChanged();
        beginInsertRows(QModelIndex(), mCount, newCount - 1);
        int oldCount = mCount;
        mCount = newCount;
        endInsertRows();
        emit dataChanged(index(oldCount), index(newCount - 1));
    }
    else if(newCount < mCount)
    {
        emit countChanged();
        beginRemoveRows(QModelIndex(), newCount, mCount - 1);
        mCount = newCount;
        endRemoveRows();
    }
}

void SlotArrayModel::setMin(int newMin)
{
    if(updateDelta<>(mMin, newMin))
    {
        emit minChanged();
        emit dataChanged(index(0), index(mCount - 1));
    }
}

void SlotArrayModel::setStride(int newStride)
{
    if(updateDelta<>(mStride, newStride))
    {
        emit strideChanged();
        emit dataChanged(index(0), index(mCount - 1));
    }
}

void SlotArrayModel::setStringFormat(bool newStringFormat)
{
    if(updateDelta<>(mStringFormat, newStringFormat))
    {
        emit stringFormatChanged();
        emit dataChanged(index(0), index(mCount - 1));
    }
}

int SlotArrayModel::rowCount(const QModelIndex &parent) const
{
    if(!parent.isValid())
        return mCount;
    else
        return 0;
}

int SlotArrayModel::columnCount(const QModelIndex &parent) const
{
    if(!parent.isValid())
        return 1;
    else
        return 0;
}

QVariant SlotArrayModel::data(const QModelIndex &index, int role) const
{
    if(!mSlot
            || !index.isValid()
            || index.column() != 0
            || index.row() < 0
            || index.row() >= mCount
            || role != Qt::DisplayRole)
        return QVariant();

    if(mStringFormat)
        return mSlot->asString(mMin + index.row() * mStride);
    else
        return mSlot->asFloat(mMin + index.row() * mStride);
}

void SlotArrayModel::onSlotValueParamChanged()
{
    emit dataChanged(index(0), index(mCount - 1));
}

} // namespace SetupTools

