#include "Xcp_ArrayParam.h"

namespace SetupTools {
namespace Xcp {

ArrayParam::ArrayParam(QObject *parent) :
    Param(parent),
    mRange(nullptr),
    mStringModel(new ArrayParamModel(true, this)),
    mFloatModel(new ArrayParamModel(false, this))
{

}

ArrayParam::ArrayParam(ArrayMemoryRange* range, Slot* slot, QObject* parent) :
    Param(range, slot, parent),
    mRange(range),
    mStringModel(new ArrayParamModel(true, this)),
    mFloatModel(new ArrayParamModel(false, this))
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
    Q_ASSERT(mRange && slot());

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
    Q_ASSERT(mRange && slot());
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

void ArrayParam::resetCaches()
{
    Q_ASSERT(mRange && slot());
    mRange->resetCaches();
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
    emit modelDataChanged();
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

ArrayParamModel::ArrayParamModel(bool stringFormat, ArrayParam *parent) :
    QAbstractListModel(parent),
    mParam(parent),
    mStringFormat(stringFormat)
{

    connect(mParam->slot(), &Slot::valueParamChanged, this, &ArrayParamModel::onValueParamChanged);
    connect(mParam->range(), &ArrayMemoryRange::dataChanged, this, &ArrayParamModel::onRangeDataChanged);
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
    if(mStringFormat)
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

    return mParam->range()->set(index.row(), mParam->slot()->asRaw(value));
}

Qt::ItemFlags ArrayParamModel::flags(const QModelIndex &index) const
{
    Q_UNUSED(index);
    return Qt::ItemIsEnabled | Qt::ItemIsSelectable | Qt::ItemFlag(mParam->range()->writable() ? Qt::ItemIsEditable : 0);
}

void ArrayParamModel::onValueParamChanged()
{
    onRangeDataChanged(0, mParam->mRange->count() - 1);
}

void ArrayParamModel::onRangeDataChanged(quint32 beginChanged, quint32 endChanged)
{
    emit dataChanged(index(beginChanged), index(endChanged - 1));
}

} // namespace Xcp
} // namespace SetupTools
