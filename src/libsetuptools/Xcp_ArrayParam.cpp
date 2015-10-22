#include "Xcp_ArrayParam.h"

namespace SetupTools {
namespace Xcp {

ArrayParam::ArrayParam(QObject *parent) :
    Param(parent),
    mRange(nullptr),
    mStringModel(new ArrayParamModel(true, false, this)),
    mFloatModel(new ArrayParamModel(false, false, this)),
    mRawModel(new ArrayParamModel(false, true, this))
{

}

ArrayParam::ArrayParam(ArrayMemoryRange* range, Slot* slot, ParamRegistry* parent) :
    Param(range, slot, parent),
    mRange(range),
    mStringModel(new ArrayParamModel(true, false, this)),
    mFloatModel(new ArrayParamModel(false, false, this)),
    mRawModel(new ArrayParamModel(false, true, this))
{
    Q_ASSERT(mRange && slot);

    connect(mRange, &MemoryRange::uploadDone, this, &ArrayParam::onRangeUploadDone);
    connect(mRange, &MemoryRange::downloadDone, this, &ArrayParam::onRangeDownloadDone);
    connect(mRange, &ArrayMemoryRange::dataChanged, this, &ArrayParam::onRangeDataChanged);
}

QVariant ArrayParam::get(int row) const
{
    return slot()->asFloat(mRange->get(row));
}

bool ArrayParam::set(int row, const QVariant& value) const
{
    return mRange->set(row, slot()->asRaw(value));
}

int ArrayParam::count() const
{
    return mRange->count();
}

QVariant ArrayParam::getSerializableValue(bool *allInRange, bool *anyInRange)
{
    if(!mRange || !slot())
        return QVariant();

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

bool ArrayParam::setSerializableValue(const QVariant &val)
{
    if(!mRange || !slot())
        return false;
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

QVariant ArrayParam::getSerializableRawValue(bool *allInRange, bool *anyInRange)
{
    if(!mRange || !slot())
        return QVariant();

    QVariantList ret;
    ret.reserve(mRange->count());

    bool allInRangeAccum = true;
    bool anyInRangeAccum = false;

    for(QVariant elem : mRange->data())
    {
        bool inRange = slot()->rawInRange(elem);
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

bool ArrayParam::setSerializableRawValue(const QVariant &val)
{
    if(!mRange || !slot())
        return false;
    if(val.type() != QVariant::StringList && val.type() != QVariant::List)
        return false;
    if(val.toList().size() != mRange->count())
        return false;

    for(QVariant elem : val.toList())
    {
        if(!slot()->rawInRange(elem))
            return false;
    }

    return mRange->setDataRange(val.toList(), 0);
}

void ArrayParam::onRangeUploadDone(SetupTools::Xcp::OpResult result)
{
    emit uploadDone(result);
}

void ArrayParam::onRangeDownloadDone(SetupTools::Xcp::OpResult result)
{
    emit downloadDone(result);
}

void ArrayParam::onRangeDataChanged(quint32 beginChanged, quint32 endChanged)
{
    Q_UNUSED(beginChanged);
    Q_UNUSED(endChanged);
    emit modelChanged();
}

void ArrayParam::upload()
{
    Q_ASSERT(mRange && slot());
    mRange->upload();
}

void ArrayParam::download()
{
    Q_ASSERT(mRange && slot());
    mRange->download();
}

ArrayParamModel::ArrayParamModel(bool stringFormat, bool raw, ArrayParam *parent) :
    QAbstractListModel(parent),
    mParam(parent),
    mStringFormat(stringFormat),
    mRaw(raw)
{

    connect(mParam->slot(), &Slot::valueParamChanged, this, &ArrayParamModel::onValueParamChanged);
    connect(mParam->range(), &ArrayMemoryRange::dataChanged, this, &ArrayParamModel::onRangeDataChanged);
}

int ArrayParamModel::count() const
{
    return rowCount();
}

int ArrayParamModel::rowCount(const QModelIndex &parent) const
{
    return parent.isValid() ? 0 : mParam->range()->count();
}

QVariant ArrayParamModel::data(const QModelIndex &index, int role) const
{
    if(!index.isValid()
            || index.column() != 0
            || index.row() < 0
            || index.row() >= mParam->range()->count()
            || role != Qt::DisplayRole)
        return QVariant();

    QVariant rawData = mParam->range()->get(index.row());
    if(mRaw)
        return rawData;
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
            || index.row() >= mParam->range()->count()
            || role != Qt::DisplayRole)
        return false;

    if(mRaw)
        return mParam->range()->set(index.row(), value);
    else
        return mParam->range()->set(index.row(), mParam->slot()->asRaw(value));
}

Qt::ItemFlags ArrayParamModel::flags(const QModelIndex &index) const
{
    Q_UNUSED(index);
    return Qt::ItemIsEnabled | Qt::ItemIsSelectable | Qt::ItemFlag(mParam->range()->writable() ? Qt::ItemIsEditable : 0);
}

void ArrayParamModel::onValueParamChanged()
{
    emit dataChanged(index(0), index(mParam->mRange->count() - 1));
}

void ArrayParamModel::onRangeDataChanged(quint32 beginChanged, quint32 endChanged)
{
    emit dataChanged(index(beginChanged), index(endChanged - 1));   // convert from STL style (end = past-the-end) to Qt model style (end = last one)
}

} // namespace Xcp
} // namespace SetupTools

