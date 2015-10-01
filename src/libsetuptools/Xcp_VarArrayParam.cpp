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
    emit modelChanged();
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
    mExtRangeUploadIdx.reset();
    mExtRangeDownloadIdx.reset();
}

void VarArrayParam::onRangeUploadDone(OpResult result)
{
    if(result != OpResult::Success)

    {
        emit uploadDone(result);
    }
    else if(mExtRanges.empty()
            || (mActualDim && mActualDim.get() == 0))
    {
        emit uploadDone(result);
        emit modelDataChanged(0, mRange->count());
    }
    else
    {
        mExtRangeUploadIdx = 0;
        mExtRanges[0]->upload();
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
    emit modelChanged();
    emit modelDataChanged(beginChanged, int(endChanged) - 1);
}

void VarArrayParam::onExtRangeUploadDone(OpResult result)
{
    Q_ASSERT(mExtRangeUploadIdx);
    if(result == OpResult::SlaveErrorOutOfRange && !mActualDim)
    {
        mActualDim = mExtRangeUploadIdx.get() + mRange->count();
        emit countChanged();
        mExtRangeUploadIdx.reset();
        emit uploadDone(OpResult::Success);
    }
    else
    {
        mExtRangeUploadIdx.reset();
        emit uploadDone(result);
    }
}

void VarArrayParam::onExtRangeDownloadDone(OpResult result)
{
    Q_ASSERT(mExtRangeDownloadIdx);
    if(result == OpResult::SlaveErrorOutOfRange && !mActualDim)
    {
        mActualDim = mExtRangeDownloadIdx.get() + mRange->count();
        emit countChanged();
        mExtRangeDownloadIdx.reset();
        emit downloadDone(OpResult::Success);
    }
    else
    {
        mExtRangeDownloadIdx.reset();
        emit downloadDone(result);
    }
}

void VarArrayParam::onExtRangeValueChanged(int index)
{
    emit modelChanged();
    emit modelDataChanged(mRange->count() + index, mRange->count() + index);
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
    {
        rawData = mParam->range()->get(index.row());
    }
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
        mParam->mExtRanges[(index.row() - mParam->range()->count())]->setValue(value);
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
    emit dataChanged(index(0), index(mParam->count() - 1));
}

void VarArrayParamModel::onParamDataChanged(quint32 beginChanged, quint32 endChanged)
{
    emit dataChanged(index(beginChanged), index(endChanged - 1));   // convert from STL style (end = past-the-end) to Qt model style (end = last one)
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
}

} // namespace Xcp
} // namespace SetupTools

