#include "ArrayParam.h"
#include "util.h"

namespace SetupTools {

ArrayParam::ArrayParam(Param *parent) :
    Param(parent),
    mActualDim(),
    mMinCount(),
    mMaxCount(),
    mStringModel(new ArrayParamModel(true, false, this)),
    mFloatModel(new ArrayParamModel(false, false, this)),
    mRawModel(new ArrayParamModel(true, true, this))
{
    connect(this, &Param::validChanged, this, &ArrayParam::onValidChanged);
}

QVariant ArrayParam::get(int row) const
{
    if(!slot())
        return QVariant();

    return slot()->asFloat(rawVal(row));
}

bool ArrayParam::set(int row, const QVariant &value)
{
    if(!slot())
        return false;

    bool ok = setRawVal(row, slot()->asRaw(value));
    if(ok)
    {
        emit modelChanged();
        emit modelDataChanged(row, row + 1);
    }
    return ok;
}

QVariant ArrayParam::getSerializableValue(bool *allInRange, bool *anyInRange)
{
    QVariant raw = getSerializableRawValue(allInRange, anyInRange);

    if(!raw.canConvert(QVariant::List))
        return raw;

    QStringList ret;
    if(slot())
    {
        ret.reserve(raw.toList().size());
        for(QVariant elem : raw.toList())
            ret.append(slot()->asString(elem));
    }
    return ret;
}

QVariant ArrayParam::getSerializableRawValue(bool *allInRange, bool *anyInRange)
{
    if(!mActualDim || !valid())
        return QVariant();

    QVariantList ret;
    ret.reserve(mActualDim);

    bool allInRangeAccum = true;
    bool anyInRangeAccum = false;

    for(int i = 0; i < mActualDim; ++i)
    {
        QVariant elem = rawVal(i);

        bool inRange = slot() && slot()->rawInRange(elem);
        allInRangeAccum &= inRange;
        anyInRangeAccum |= inRange;
        ret.append(elem);
    }

    if(allInRange)
        *allInRange = allInRangeAccum;

    if(anyInRange)
        *anyInRange = anyInRangeAccum;

    return ret;
}

bool ArrayParam::setSerializableValue(const QVariant &val)
{
    if(!val.isValid())
    {
        return setSerializableRawValue(val);
    }
    if(val.type() != QVariant::StringList && val.type() != QVariant::List)
        return false;
    QStringList stringList = val.toStringList();

    if(!slot())
        return false;

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

bool ArrayParam::setSerializableRawValue(const QVariant &val)
{
    if(!val.isValid())
    {
        setValid(false);
        return true;
    }
    if(val.type() != QVariant::StringList && val.type() != QVariant::List)
        return false;
    QVariantList list = val.toList();
    if(list.size() < minCount()
            || list.size() > maxCount())
        return false;

    std::vector<quint8> data;
    data.resize(list.size() * dataTypeSize());

    if(!slot())
        return false;

    for(size_t i = 0; i < size_t(list.size()); ++i)
    {
        if(!slot()->rawInRange(list[i]))
            return false;
        if(!convertToSlave(list[i], data.data() + i * dataTypeSize()))
            return false;
    }

    setBytes({data.begin().base(), data.end().base()}, 0, true);

    return true;
}

void ArrayParam::onValidChanged()
{
    emit modelChanged();
    emit modelDataChanged(0, mActualDim);
}

void ArrayParam::updateEngrFromRaw(quint32 begin, quint32 end)  // called from Param when data or its presence changes via XCP or setValid()
{
    quint32 beginElem = begin / dataTypeSize();
    quint32 endElem = (end + dataTypeSize() - 1) / dataTypeSize();

    if(updateDelta<>(mActualDim, int(loadedBytes() / dataTypeSize())))
        emit countChanged();
    emit modelChanged();
    emit modelDataChanged(beginElem, endElem);
}

void ArrayParam::setMinCount(int val)
{
    int oldMinCount = minCount();
    int oldMaxCount = maxCount();
    int oldCount = count();

    mMinCount = val;

    if(minCount() != oldMinCount)
        emit minCountChanged();
    if(maxCount() != oldMaxCount)
        emit minCountChanged();
    if(count() != oldCount)
        emit countChanged();
}
void ArrayParam::setMaxCount(int val)
{
    int oldMinCount = minCount();
    int oldMaxCount = maxCount();
    int oldCount = count();

    mMaxCount = val;

    if(minCount() != oldMinCount)
        emit minCountChanged();
    if(maxCount() != oldMaxCount)
        emit minCountChanged();
    if(count() != oldCount)
        emit countChanged();
}

quint32 ArrayParam::minSize()
{
    return minCount() * dataTypeSize();
}

quint32 ArrayParam::maxSize()
{
    return maxCount() * dataTypeSize();
}

QVariant ArrayParam::rawVal(int row) const
{
    if(row < 0 || row >= mActualDim || !valid())
        return QVariant();

    return convertFromSlave(bytes().begin() + row * dataTypeSize());
}

bool ArrayParam::setRawVal(int row, const QVariant & val)
{
    if(row < 0 || row >= mActualDim)
        return false;

    quint8 buf[dataTypeSize()];
    bool ok = convertToSlave(val, buf);
    setBytes({buf, buf + dataTypeSize()}, row * dataTypeSize());
    return ok;
}


ArrayParamModel::ArrayParamModel(bool stringFormat, bool raw, ArrayParam *parent) :
    QAbstractListModel(parent),
    mParam(parent),
    mPrevCount(parent->count()),
    mStringFormat(stringFormat),
    mRaw(raw)
{
    connect(mParam, &Param::slotChanged, this, &ArrayParamModel::onParamSlotChanged);
    if(mParam->slot())
        connect(mParam->slot(), &Slot::valueParamChanged, this, &ArrayParamModel::onValueParamChanged);
    mConnectedSlot = mParam->slot();
    connect(mParam, &ArrayParam::modelDataChanged, this, &ArrayParamModel::onParamDataChanged);
    connect(mParam, &ArrayParam::countChanged, this, &ArrayParamModel::onParamCountChanged);
}

int ArrayParamModel::count() const
{
    return rowCount();
}

int ArrayParamModel::rowCount(const QModelIndex &parent) const
{
    return parent.isValid() ? 0 : mPrevCount;
}

QVariant ArrayParamModel::data(const QModelIndex &index, int role) const
{
    if(!index.isValid()
            || index.column() != 0
            || index.row() < 0
            || index.row() >= mParam->count()
            || role != Qt::DisplayRole)
        return QVariant();

    QVariant rawData = mParam->rawVal(index.row());

    if(mRaw)
        return rawData;
    else if(!mParam->slot())
        return QVariant();
    else if(mStringFormat)
        return mParam->slot()->asString(rawData);
    else
        return mParam->slot()->asFloat(rawData);
}

bool ArrayParamModel::setData(const QModelIndex &index, const QVariant &value, int role)
{
    if(!index.isValid()
            || index.column() != 0
            || index.row() < 0
            || index.row() >= mParam->count()
            || role != Qt::DisplayRole)
        return false;

    if(!mRaw && !mParam->slot())
        return false;

    QVariant toSet = mRaw ? value : mParam->slot()->asRaw(value);

    return mParam->setRawVal(index.row(), toSet);
}

Qt::ItemFlags ArrayParamModel::flags(const QModelIndex &index) const
{
    Q_UNUSED(index);
    return Qt::ItemIsEnabled | Qt::ItemIsSelectable | Qt::ItemFlag(mParam->writable() ? Qt::ItemIsEditable : 0);
}

void ArrayParamModel::onValueParamChanged()
{
    if(mPrevCount > 0)
        emit dataChanged(createIndex(0, 0), createIndex(mPrevCount - 1, 0));
}

void ArrayParamModel::onParamDataChanged(quint32 beginChanged, quint32 endChanged)
{
    int clampedBegin = std::max(int(beginChanged), 0);
    int clampedEnd = std::min(int(endChanged), mPrevCount);
    if(clampedEnd > clampedBegin && clampedBegin >= 0)
    emit dataChanged(createIndex(clampedBegin, 0), createIndex(clampedEnd - 1, 0));   // convert from STL style (end = past-the-end) to Qt model style (end = last one)
}

void ArrayParamModel::onParamCountChanged()
{
    if(mParam->count() > mPrevCount)
    {
        beginInsertRows(QModelIndex(), mPrevCount, mParam->count() - 1);
        mPrevCount = mParam->count();
        endInsertRows();
    }
    else if(mParam->count() < mPrevCount)
    {
        beginRemoveRows(QModelIndex(), mParam->count(), mPrevCount - 1);
        mPrevCount = mParam->count();
        endRemoveRows();
    }
    emit countChanged();
    emit dataChanged(createIndex(0, 0), createIndex(mParam->count() - 1, 0));
}

void ArrayParamModel::onParamSlotChanged()
{
    if(mConnectedSlot)
        disconnect(mConnectedSlot, &Slot::valueParamChanged, this, &ArrayParamModel::onValueParamChanged);
    if(mParam->slot())
        connect(mParam->slot(), &Slot::valueParamChanged, this, &ArrayParamModel::onValueParamChanged);
    mConnectedSlot = mParam->slot();
    onValueParamChanged();
}

} // namespace SetupTools
