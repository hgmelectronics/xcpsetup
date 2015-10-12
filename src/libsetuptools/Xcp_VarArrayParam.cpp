#include "Xcp_VarArrayParam.h"

namespace SetupTools {
namespace Xcp {

VarArrayParam::VarArrayParam(QObject *parent) :
    Param(parent),
    mRange(nullptr),
    mStringModel(new VarArrayParamModel(true, false, this)),
    mFloatModel(new VarArrayParamModel(false, false, this)),
    mRawModel(new VarArrayParamModel(false, true, this))
{}

template <typename Tto, typename Tfrom>
QList<Tto> QListCast(const QList<Tfrom> &from)
{
    QList<Tto> to;
    to.reserve(from.size());
    for(const Tfrom &elem : from)
        to.push_back(Tto(elem));
    return to;
}

VarArrayParam::VarArrayParam(ArrayMemoryRange *range, QList<ScalarMemoryRange *> extRanges, Slot *slot, QObject *parent) :
    Param(range, QListCast<MemoryRange *>(extRanges), false, slot, parent),
    mRange(range),
    mExtRanges(extRanges),
    mDataChanged(mRange->count() + mExtRanges.size()),
    mUploadingRange(false),
    mStringModel(new VarArrayParamModel(true, false, this)),
    mFloatModel(new VarArrayParamModel(false, false, this)),
    mRawModel(new VarArrayParamModel(false, true, this))
{
    Q_ASSERT(mRange && slot);

    connect(mRange, &MemoryRange::uploadDone, this, &VarArrayParam::onRangeUploadDone);
    connect(mRange, &MemoryRange::downloadDone, this, &VarArrayParam::onRangeDownloadDone);
    connect(mRange, &ArrayMemoryRange::dataChanged, this, &VarArrayParam::onRangeDataChanged);
    connect(this, &Param::cachesReset, this, &VarArrayParam::onCachesReset);

    for(int i = 0; i < mExtRanges.size(); ++i)
    {
        connect(mExtRanges[i], &MemoryRange::uploadDone, this, &VarArrayParam::onExtRangeUploadDone);
        connect(mExtRanges[i], &MemoryRange::downloadDone, this, &VarArrayParam::onExtRangeDownloadDone);
        mExtRangeChangedMapper.setMapping(mExtRanges[i], i);
        connect(mExtRanges[i], &ScalarMemoryRange::valueChanged, &mExtRangeChangedMapper, static_cast<void (QSignalMapper::*)()>(&QSignalMapper::map));
    }
    connect(&mExtRangeChangedMapper, static_cast<void (QSignalMapper::*)(int)>(&QSignalMapper::mapped), this, &VarArrayParam::onExtRangeValueChanged);
}

QVariant VarArrayParam::get(int row) const
{
    if(!mActualDim || row >= mActualDim.get())
        return QVariant();

    QVariant raw;
    if(row < mRange->count())
        raw = mRange->get(row);
    else
        raw = mExtRanges[row - mRange->count()]->value();

    return slot()->asFloat(raw);
}

bool VarArrayParam::set(int row, const QVariant &value) const
{
    if(!mActualDim || row >= mActualDim.get())
        return false;

    QVariant raw = slot()->asRaw(value);
    if(row < mRange->count())
    {
        return mRange->set(row, raw);
    }
    else
    {
        mExtRanges[row - mRange->count()]->setValue(raw);
        return true;
    }
}

int VarArrayParam::count() const
{
    return mActualDim.get_value_or(0);
}

int VarArrayParam::minCount() const
{
    return mRange->count();
}

int VarArrayParam::maxCount() const
{
    return mRange->count() + mExtRanges.size();
}

QVariant VarArrayParam::getSerializableValue(bool *allInRange, bool *anyInRange)
{
    QVariant raw = getSerializableRawValue(allInRange, anyInRange);

    if(!raw.canConvert(QVariant::List) || !slot())
        return raw;

    QStringList ret;
    ret.reserve(raw.toList().size());
    for(QVariant elem : raw.toList())
        ret.append(slot()->asString(elem));
    return ret;
}

QVariant VarArrayParam::getSerializableRawValue(bool *allInRange, bool *anyInRange)
{
    if(!mRange || !slot() || !mActualDim)
        return QVariant();

    QVariantList ret;
    ret.reserve(mActualDim.get());

    bool allInRangeAccum = true;
    bool anyInRangeAccum = false;

    for(QVariant elem : mRange->data())
    {
        bool inRange = slot()->rawInRange(elem);
        allInRangeAccum &= inRange;
        anyInRangeAccum |= inRange;
        ret.append(slot()->asString(elem));
    }
    for(ScalarMemoryRange *extRange : mExtRanges)
    {
        QVariant raw = extRange->value();
        bool inRange = slot()->rawInRange(raw);
        allInRangeAccum &= inRange;
        anyInRangeAccum |= inRange;
        ret.append(raw);
    }

    if(allInRange)
        *allInRange = allInRangeAccum;

    if(anyInRange)
        *anyInRange = anyInRangeAccum;

    return ret;
}

bool VarArrayParam::setSerializableValue(const QVariant &val)
{
    if(!slot())
        return false;
    if(val.type() != QVariant::StringList && val.type() != QVariant::List)
        return false;
    QStringList stringList = val.toStringList();

    for(QString str : stringList)
    {
        if(!slot()->engrInRange(str))
            return false;
    }

    QVariantList rawList;
    rawList.reserve(stringList.size());
    for(QString str : stringList)
        rawList.push_back(slot()->asRaw(str));

    return setSerializableRawValue(rawList);
}

bool VarArrayParam::setSerializableRawValue(const QVariant &val)
{
    if(!mRange || !slot())
        return false;
    if(val.type() != QVariant::StringList && val.type() != QVariant::List)
        return false;
    QVariantList list = val.toList();
    if(list.size() < mRange->count()
            || list.size() > (mRange->count() + mExtRanges.size()))
        return false;

    for(QVariant elem : list)
    {
        if(!slot()->rawInRange(elem))
            return false;
    }

    if(!mRange->setDataRange(list.mid(0, mRange->count()), 0))
        return false;

    for(int i = 0; i < mExtRanges.size(); ++i)
        mExtRanges[i]->setValue(list[i + mRange->count()]);

    mActualDim = list.size();
    emit countChanged();
    emitDataChanged(true);
    return true;
}

void VarArrayParam::upload()
{
    if(mExtRangeUploadIdx)
    {
        emit uploadDone(OpResult::InvalidOperation);
        return;
    }
    Q_ASSERT(mRange && slot());
    mUploadingRange = true;
    mRange->upload();
}

void VarArrayParam::download()
{
    if(mExtRangeDownloadIdx)
    {
        emit downloadDone(OpResult::InvalidOperation);
        return;
    }
    Q_ASSERT(mRange && slot());
    mRange->download();
}

void VarArrayParam::onCachesReset()
{
    mActualDim.reset();
    mDataChanged.reset();
    mUploadingRange = false;
    mExtRangeUploadIdx.reset();
    mExtRangeDownloadIdx.reset();
}

void VarArrayParam::onRangeUploadDone(OpResult result)
{
    if(!mUploadingRange)    // initiated by memory range in response to upload
    {
        /// If mActualDim is set and equal to base range count, then this is the last upload
        /// that will result from the ongoing download sequence, and we should emit a signal.
        /// If not set, then the next download might fail, so upload would not be triggered,
        /// and we would never emit uploadDone. Therefore, must emit now.
        if(!mActualDim || mActualDim.get() == mRange->count())
        {
            emitDataChanged();
            emit uploadDone(result);
        }
    }
    else
    {
        mUploadingRange = false;    /// Always clear the "we initiated this upload" flag.

        if(result != OpResult::Success || !mRange->valid())
        {
            /// If operation fails or range is not valid, then just emit signal.
            /// User will find out range is not valid through existing method on Param.
            emitDataChanged();
            emit uploadDone(result);
        }
        else
        {
            if(mExtRanges.empty() || (mActualDim && mActualDim.get() == mRange->count()))
            {
                /// If we know there is no data in extended ranges, we're done
                emitDataChanged();
                emit uploadDone(result);
            }
            else
            {
                /// Otherwise begin upload of extended ranges
                mExtRangeUploadIdx = 0;
                mExtRanges[0]->upload();
            }
        }
    }
}

void VarArrayParam::onRangeDownloadDone(OpResult result)
{
    if(result != OpResult::Success
            || mExtRanges.empty()
            || (mActualDim && mActualDim.get() == 0))
    {
        emit downloadDone(result);
    }
    else
    {
        mExtRangeDownloadIdx = 0;
        mExtRanges[0]->download();
    }
}

void VarArrayParam::onRangeDataChanged(quint32 beginChanged, quint32 endChanged)
{
    for(quint32 i = beginChanged; i < endChanged; ++i)
        mDataChanged[i] = true;
}

void VarArrayParam::onExtRangeUploadDone(OpResult result)
{
    if(!mExtRangeUploadIdx) // initiated by memory range in response to download
    {
        /// Same logic as base range uploadDone in response to download:
        /// if we don't know that the next upload should succeed, emit.
        /// Otherwise, emit if active download index is cleared (meaning the last extRangeDownloadDone handler has run)
        if(!mActualDim || !mExtRangeDownloadIdx)
        {
            emitDataChanged();
            emit uploadDone(result);
        }
    }
    else if(result != OpResult::Success)
    {
        // Success is returned when address out of range (just sets valid = false), so some other failure occurred
        mExtRangeUploadIdx.reset();
        emitDataChanged();
        emit uploadDone(result);
    }
    else if(!mExtRanges[mExtRangeUploadIdx.get()]->valid())
    {
        // This appears to be one past the end of the array
        if(!mActualDim)
        {
            mActualDim = mExtRangeUploadIdx.get() + mRange->count();
            emit countChanged();
            mExtRangeUploadIdx.reset();
            emitDataChanged(true);
            emit uploadDone(OpResult::Success);
        }
        else
        {
            // Array shrank while connected - ??????
            mExtRangeUploadIdx.reset();
            emitDataChanged();
            emit uploadDone(OpResult::UnknownError);
        }
    }
    else
    {
        int lastExtRange = mExtRanges.size() - 1;
        if(mActualDim)
            lastExtRange = mActualDim.get() - mRange->count() - 1;

        if(mExtRangeUploadIdx.get() < lastExtRange)
        {
            // More extended ranges to go
            mExtRangeUploadIdx = mExtRangeUploadIdx.get() + 1;
            mExtRanges[mExtRangeUploadIdx.get()]->upload();
        }
        else
        {
            bool forceModelChanged = false;
            if(!mActualDim)
            {
                mActualDim = mExtRanges.size() + mRange->count();
                emit countChanged();
                forceModelChanged = true;
            }
            mExtRangeUploadIdx.reset();
            emitDataChanged(forceModelChanged);
            emit uploadDone(result);
        }
    }
}

void VarArrayParam::onExtRangeDownloadDone(OpResult result)
{
    Q_ASSERT(mExtRangeDownloadIdx);
    if(result == OpResult::SlaveErrorOutOfRange && !mActualDim)
    {
        mActualDim = mExtRangeDownloadIdx.get() + mRange->count();
        emit countChanged();
        emit modelChanged();
        mExtRangeDownloadIdx.reset();
        emit downloadDone(OpResult::Success);
    }
    else if(mExtRangeDownloadIdx.get() < (mExtRanges.size() - 1))
    {
        mExtRangeDownloadIdx = mExtRangeDownloadIdx.get() + 1;
        mExtRanges[mExtRangeDownloadIdx.get()]->download();
    }
    else
    {
        mExtRangeDownloadIdx.reset();
        emit downloadDone(result);
    }
}

void VarArrayParam::onExtRangeValueChanged(int index)
{
    mDataChanged[index + mRange->count()] = true;
}

void VarArrayParam::emitDataChanged(bool forceModelChanged)
{
    size_t beginBitUnsigned = mDataChanged.find_first();
    if(beginBitUnsigned >= mDataChanged.size())
        return; // no data changed

    qint32 beginBit = beginBitUnsigned;
    qint32 lastBit = mDataChanged.size() - 1;
    Q_ASSERT(beginBit >= 0);
    Q_ASSERT(beginBit <= qint32(mDataChanged.size()));
    Q_ASSERT(lastBit >= 0);
    while(1)
    {
        if(lastBit < beginBit || mDataChanged[lastBit])
            break;
        --lastBit;
    }
    if(forceModelChanged || lastBit >= beginBit)
        emit modelChanged();
    if(lastBit >= beginBit)
        emit modelDataChanged(beginBit, lastBit + 1);
    mDataChanged.reset();
}

VarArrayParamModel::VarArrayParamModel(bool stringFormat, bool raw, VarArrayParam *parent) :
    QAbstractListModel(parent),
    mParam(parent),
    mPrevCount(parent->count()),
    mStringFormat(stringFormat),
    mRaw(raw)
{
    connect(mParam->slot(), &Slot::valueParamChanged, this, &VarArrayParamModel::onValueParamChanged);
    connect(mParam, &VarArrayParam::modelDataChanged, this, &VarArrayParamModel::onParamDataChanged);
    connect(mParam, &VarArrayParam::countChanged, this, &VarArrayParamModel::onParamCountChanged);
}

int VarArrayParamModel::count() const
{
    return rowCount();
}

int VarArrayParamModel::rowCount(const QModelIndex &parent) const
{
    return parent.isValid() ? 0 : mParam->count();
}

QVariant VarArrayParamModel::data(const QModelIndex &index, int role) const
{
    if(!index.isValid()
            || index.column() != 0
            || !mParam->mActualDim
            || index.row() < 0
            || index.row() >= mParam->mActualDim.get()
            || role != Qt::DisplayRole)
        return QVariant();

    QVariant rawData;
    if(index.row() < mParam->range()->count())
        rawData = mParam->range()->get(index.row());
    else
        rawData = mParam->mExtRanges[(index.row() - mParam->range()->count())]->value();

    if(mRaw)
        return rawData;
    else if(mStringFormat)
        return mParam->slot()->asString(rawData);
    else
        return mParam->slot()->asFloat(rawData);
}

bool VarArrayParamModel::setData(const QModelIndex &index, const QVariant &value, int role)
{
    if(!index.isValid()
            || index.column() != 0
            || !mParam->mActualDim
            || index.row() < 0
            || index.row() >= mParam->mActualDim.get()
            || role != Qt::DisplayRole)
        return false;

    QVariant toSet = mRaw ? value : mParam->slot()->asRaw(value);

    if(index.row() < mParam->range()->count())
    {
        return mParam->range()->set(index.row(), toSet);
    }
    else
    {
        mParam->mExtRanges[(index.row() - mParam->range()->count())]->setValue(toSet);
        return true;
    }
}

Qt::ItemFlags VarArrayParamModel::flags(const QModelIndex &index) const
{
    Q_UNUSED(index);
    return Qt::ItemIsEnabled | Qt::ItemIsSelectable | Qt::ItemFlag(mParam->range()->writable() ? Qt::ItemIsEditable : 0);
}

void VarArrayParamModel::onValueParamChanged()
{
    emit dataChanged(createIndex(0, 0), createIndex(mParam->count() - 1, 0));
}

void VarArrayParamModel::onParamDataChanged(quint32 beginChanged, quint32 endChanged)
{
    emit dataChanged(createIndex(beginChanged, 0), createIndex(endChanged - 1, 0));   // convert from STL style (end = past-the-end) to Qt model style (end = last one)
}

void VarArrayParamModel::onParamCountChanged()
{
    if(mParam->count() > mPrevCount)
    {
        beginInsertRows(QModelIndex(), mPrevCount, mParam->count());
        endInsertRows();
    }
    else if(mParam->count() < mPrevCount)
    {
        beginRemoveRows(QModelIndex(), mParam->count(), mPrevCount - 1);
        endRemoveRows();
    }
    mPrevCount = mParam->count();
    emit countChanged();
    emit dataChanged(createIndex(0, 0), createIndex(mParam->count() - 1, 0));
}

} // namespace Xcp
} // namespace SetupTools

