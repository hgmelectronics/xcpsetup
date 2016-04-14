#include "Xcp_ParamRegistry.h"
#include "Xcp_ScalarMemoryRange.h"
#include "Xcp_ScalarParam.h"
#include "Xcp_ArrayMemoryRange.h"
#include "Xcp_ArrayParam.h"

namespace SetupTools {
namespace Xcp {

void ParamAddrRangeMap::insert(XcpPtr base, quint32 size, Param * param)
{
    mVector.insert(lowerBound(base), {base, size, param});
}

QPair<Param *, int> ParamAddrRangeMap::find(XcpPtr base)
{
    auto upperIt = upperBound(base);
    if(upperIt != mVector.begin())
    {
        auto matchIt = upperIt - 1;
        int offset = int(qint64(base.addr) - qint64(matchIt->base.addr));
        if(offset < int(matchIt->size))
            return {matchIt->param, offset};
    }
    return {nullptr, 0};
}

QVector<ParamAddrRangeMap::ArrayAddrEntry>::iterator ParamAddrRangeMap::lowerBound(XcpPtr base)
{
    return std::lower_bound(mVector.begin(), mVector.end(), base);
}

QVector<ParamAddrRangeMap::ArrayAddrEntry>::iterator ParamAddrRangeMap::upperBound(XcpPtr base)
{
    return std::upper_bound(mVector.begin(), mVector.end(), base);
}

ParamRegistry::ParamRegistry(QObject *parent) :
    QObject(parent)
{}

ParamRegistry::ParamRegistry(quint32 addrGran, QObject *parent) :
    QObject(parent),
    mTable(new MemoryRangeTable(addrGran, this))
{
    connect(mTable, &MemoryRangeTable::connectionChanged, this, &ParamRegistry::onTableConnectionChanged);
}

quint32 ParamRegistry::addrGran() const
{
    return mTable->addrGran();
}

ConnectionFacade *ParamRegistry::connectionFacade() const
{
    return mTable->connectionFacade();
}

void ParamRegistry::setConnectionFacade(ConnectionFacade *facade)
{
    mTable->setConnectionFacade(facade);
}

bool ParamRegistry::connectionOk() const
{
    return mTable->connectionOk();
}

const MemoryRangeTable *ParamRegistry::table() const
{
    return mTable;
}

const QList<QString> &ParamRegistry::paramKeys() const
{
    return mParamKeys;
}

const QList<QString> &ParamRegistry::saveableParamKeys() const
{
    return mSaveableParamKeys;
}

bool ParamRegistry::writeCacheDirty() const
{
    return !mWriteCacheDirtyKeys.empty();
}

QPair<Param *, int> ParamRegistry::findParamByAddr(XcpPtr base)
{
    auto scalarIt = mScalarAddrMap.find(base);
    if(scalarIt != mScalarAddrMap.end())
        return {*scalarIt, -1};

    return mArrayAddrMap.find(base);
}

ScalarParam *ParamRegistry::addScalarParam(int type, XcpPtr base, bool writable, bool saveable, SetupTools::Slot *slot, QString keyIn, QString nameIn)
{
    QString key = keyIn.isEmpty() ? base.toString() : keyIn;
    QString name = nameIn.isEmpty() ? key : nameIn;

    if(mParams.count(key))
    {
        ScalarParam *other = qobject_cast<ScalarParam *>(mParams[key]);
        if(!other
                || other->range()->base() != base
                || other->range()->type() != type
                || other->range()->writable() != writable
                || other->saveable != saveable
                || other->slot() != slot)
        {
            qDebug() << QString("Failed to create scalar param with key %1, incompatible overlapping range").arg(key);
            return nullptr;
        }
        else
        {
            return other;
        }
    }

    if(!MemoryRange::isValidType(type))
    {
        qDebug() << QString("Failed to create scalar param with key %1, invalid type %2").arg(key).arg(type);
        return nullptr;
    }

    ScalarMemoryRange *scalarRange = mTable->addScalarRange(MemoryRange::MemoryRangeType(type), base, writable);
    if(scalarRange == nullptr)
    {
        qDebug() << QString("Failed to create scalar param with key %1, failed to create range").arg(key);
        return nullptr;
    }

    ScalarParam *param = new ScalarParam(scalarRange, slot, this);
    Q_ASSERT(param != nullptr);
    param->saveable = saveable;
    param->key = key;
    param->name = name;
    mParams[key] = param;
    mParamKeys.insert(std::lower_bound(mParamKeys.begin(), mParamKeys.end(), key), key);
    mScalarAddrMap[base] = param;
    if(saveable)
        mSaveableParamKeys.insert(std::lower_bound(mSaveableParamKeys.begin(), mSaveableParamKeys.end(), key), key);
    connect(param, &Param::writeCacheDirtyChanged, this, &ParamRegistry::onParamWriteCacheDirtyChanged);
    return param;
}

ArrayParam *ParamRegistry::addArrayParam(int type, XcpPtr base, int count, bool writable, bool saveable, Slot *slot, QString keyIn, QString nameIn)
{
    QString key = keyIn.isEmpty() ? base.toString() : keyIn;
    QString name = nameIn.isEmpty() ? key : nameIn;

    if(slot == nullptr)
    {
        qDebug() << QString("Failed to create array param with key %1, no slot specified").arg(key);
        return nullptr;
    }
    if(mParams.count(key))
    {
        ArrayParam *other = qobject_cast<ArrayParam *>(mParams[key]);
        if(!other
                || other->range()->base() != base
                || other->range()->type() != type
                || other->range()->writable() != writable
                || other->saveable != saveable
                || other->count() != count
                || other->slot() != slot)
        {
            qDebug() << QString("Failed to create array param with key %1, incompatible overlapping range").arg(key);
            return nullptr;
        }
        else
        {
            return other;
        }
    }

    if(count < 1)
    {
        qDebug() << QString("Failed to create array param with key %1, invalid count %2").arg(key).arg(count);
        return nullptr;
    }

    if(!MemoryRange::isValidType(type))
    {
        qDebug() << QString("Failed to create array param with key %1, invalid type %2").arg(key).arg(type);
        return nullptr;
    }

    ArrayMemoryRange *tableRange = mTable->addTableRange(MemoryRange::MemoryRangeType(type), base, count, writable);
    if(tableRange == nullptr)
    {
        qDebug() << QString("Failed to create array param with key %1, failed to create range").arg(key);
        return nullptr;
    }

    ArrayParam* param = new ArrayParam(tableRange, slot, this);
    Q_ASSERT(param != nullptr);
    param->saveable = saveable;
    param->key = key;
    param->name = name;
    mParams[key] = param;
    mParamKeys.insert(std::lower_bound(mParamKeys.begin(), mParamKeys.end(), key), key);
    mArrayAddrMap.insert(base, tableRange->size() / mTable->addrGran(), param);
    if(saveable)
        mSaveableParamKeys.insert(std::lower_bound(mSaveableParamKeys.begin(), mSaveableParamKeys.end(), key), key);
    connect(param, &Param::writeCacheDirtyChanged, this, &ParamRegistry::onParamWriteCacheDirtyChanged);
    return param;
}

VarArrayParam *ParamRegistry::addVarArrayParam(int type, XcpPtr base, int minCount, int maxCount, bool writable, bool saveable, Slot *slot, QString keyIn, QString nameIn)
{
    QString key = keyIn.isEmpty() ? base.toString() : keyIn;
    QString name = nameIn.isEmpty() ? key : nameIn;

    MemoryRange::MemoryRangeType castType = MemoryRange::MemoryRangeType(type);

    if(slot == nullptr)
    {
        qDebug() << QString("Failed to create var array param with key %1, no slot specified").arg(key);
        return nullptr;
    }
    if(mParams.count(key))
    {
        VarArrayParam *other = qobject_cast<VarArrayParam *>(mParams[key]);
        if(!other
                || other->range()->base() != base
                || other->range()->type() != type
                || other->range()->writable() != writable
                || other->saveable != saveable
                || other->minCount() != minCount
                || other->maxCount() != maxCount
                || other->slot() != slot)
        {
            qDebug() << QString("Failed to create var array param with key %1, incompatible overlapping range").arg(key);
            return nullptr;
        }
        else
            return other;
    }

    if(minCount < 1 || maxCount < minCount)
    {
        qDebug() << QString("Failed to create var array param with key %1, invalid count range %2-%3").arg(key).arg(minCount).arg(maxCount);
        return nullptr;
    }

    if(!MemoryRange::isValidType(type))
        return nullptr;

    ArrayMemoryRange *baseRange = qobject_cast<ArrayMemoryRange *>(
                mTable->addTableRange(castType, base, minCount, writable)
                );
    if(baseRange == nullptr)
    {
        qDebug() << QString("Failed to create param with key %1, failed to create base table range").arg(key);
        return nullptr;
    }

    int nExtRanges = maxCount - minCount;
    QList<ScalarMemoryRange *> extRanges;
    extRanges.reserve(nExtRanges);
    for(int i = minCount; i < maxCount; ++i)
    {
        int offset = i * memoryRangeTypeSize(castType) / mTable->addrGran();
        ScalarMemoryRange *extRange = qobject_cast<ScalarMemoryRange *>(
                    mTable->addScalarRange(castType, base + offset, writable)
                    );
        if(extRange == nullptr)
        {
            qDebug() << QString("Failed to create param with key %1, failed to create extended scalar range").arg(key);
            return nullptr;
        }
        extRanges.push_back(extRange);
    }
    VarArrayParam *param = new VarArrayParam(baseRange, extRanges, slot, this);
    Q_ASSERT(param != nullptr);
    param->saveable = saveable;
    param->key = key;
    param->name = name;
    mParams[key] = param;
    mParamKeys.insert(std::lower_bound(mParamKeys.begin(), mParamKeys.end(), key), key);
    mArrayAddrMap.insert(base, baseRange->size() / minCount * maxCount / mTable->addrGran(), param);
    if(saveable)
        mSaveableParamKeys.insert(std::lower_bound(mSaveableParamKeys.begin(), mSaveableParamKeys.end(), key), key);
    connect(param, &Param::writeCacheDirtyChanged, this, &ParamRegistry::onParamWriteCacheDirtyChanged);
    return param;
}

ScalarParam *ParamRegistry::addScalarParam(int type, double base, bool writable, bool saveable, SetupTools::Slot *slot, QString key, QString name)
{
    XcpPtr basePtr(base);
    return addScalarParam(type, basePtr, writable, saveable, slot, key, name);
}

ArrayParam *ParamRegistry::addArrayParam(int type, double base, int count, bool writable, bool saveable, SetupTools::Slot *slot, QString key, QString name)
{
    XcpPtr basePtr(base);
    return addArrayParam(type, basePtr, count, writable, saveable, slot, key, name);
}

VarArrayParam *ParamRegistry::addVarArrayParam(int type, double base, int minCount, int maxCount, bool writable, bool saveable, SetupTools::Slot *slot, QString key, QString name)
{
    XcpPtr basePtr(base);
    return addVarArrayParam(type, basePtr, minCount, maxCount, writable, saveable, slot, key, name);
}

Param *ParamRegistry::getParam(QString key)
{
    auto it = mParams.find(key);
    if(it != mParams.end())
        return *it;
    else
        return nullptr;
}

void ParamRegistry::resetCaches()
{
    for(Param *param : mParams)
        param->resetCaches();
}

void ParamRegistry::setValidAll(bool valid)
{
    for(Param *param : mParams)
        param->setValid(valid);
}

void ParamRegistry::setWriteCacheDirtyAll(bool dirty)
{
    for(Param *param : mParams)
        param->setWriteCacheDirty(dirty);
}

void ParamRegistry::onTableConnectionChanged()
{
    emit connectionChanged();
}

void ParamRegistry::onParamWriteCacheDirtyChanged(QString key)
{
    Q_ASSERT(mParams.count(key));

    bool regPrevDirty = !mWriteCacheDirtyKeys.empty();
    bool dirty = mParams[key]->writeCacheDirty();
    auto keyIt = std::lower_bound(mWriteCacheDirtyKeys.begin(), mWriteCacheDirtyKeys.end(), key);
    if(dirty)
    {
        if(keyIt == mWriteCacheDirtyKeys.end() || *keyIt != key)
            mWriteCacheDirtyKeys.insert(keyIt, key);
    }
    else
    {
        if(keyIt != mWriteCacheDirtyKeys.end() && *keyIt == key)
            mWriteCacheDirtyKeys.erase(keyIt);
    }
    bool regDirty = !mWriteCacheDirtyKeys.empty();
    if(regPrevDirty != regDirty)
        emit writeCacheDirtyChanged();
}

} // namespace Xcp
} // namespace SetupTools

