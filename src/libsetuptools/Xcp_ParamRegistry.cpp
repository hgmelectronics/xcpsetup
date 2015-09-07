#include "Xcp_ParamRegistry.h"
#include "Xcp_ScalarMemoryRange.h"
#include "Xcp_ScalarParam.h"
#include "Xcp_ArrayMemoryRange.h"
#include "Xcp_ArrayParam.h"

namespace SetupTools {
namespace Xcp {

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

ScalarParam *ParamRegistry::addScalarParam(int type, XcpPtr base, bool writable, bool saveable, SetupTools::Slot *slot, QString key)
{
    if(mParams.count(key))
    {
        ScalarParam *other = qobject_cast<ScalarParam *>(mParams[key]);
        if(!other
                || other->range()->base() != base
                || other->range()->type() != type
                || other->range()->writable() != writable
                || other->saveable != saveable
                || other->slot() != slot)
            return nullptr;
        else
            return other;
    }

    if(!MemoryRange::isValidType(type))
        return nullptr;

    MemoryRange *range = mTable->addScalarRange(MemoryRange::MemoryRangeType(type), base, writable);
    if(range == nullptr)
        return nullptr;

    ScalarMemoryRange *scalarRange = qobject_cast<ScalarMemoryRange *>(range);
    Q_ASSERT(scalarRange != nullptr);
    ScalarParam *param = new ScalarParam(scalarRange, slot, this);
    Q_ASSERT(param != nullptr);
    param->saveable = saveable;
    param->key = key;
    mParams[key] = param;
    mParamKeys.insert(std::lower_bound(mParamKeys.begin(), mParamKeys.end(), key), key);
    if(saveable)
        mSaveableParamKeys.insert(std::lower_bound(mSaveableParamKeys.begin(), mSaveableParamKeys.end(), key), key);
    connect(param, &Param::writeCacheDirtyChanged, this, &ParamRegistry::onParamWriteCacheDirtyChanged);
    return param;
}

ArrayParam *ParamRegistry::addArrayParam(int type, XcpPtr base, int count, bool writable, bool saveable, Slot *slot, QString key)
{
    if(slot == nullptr)
        return nullptr;
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
            return nullptr;
        else
            return other;
    }

    if(count < 1)
        return nullptr;

    if(!MemoryRange::isValidType(type))
        return nullptr;

    MemoryRange *range = mTable->addTableRange(MemoryRange::MemoryRangeType(type), base, count, writable);
    if(range == nullptr)
        return nullptr;

    ArrayMemoryRange *tableRange = qobject_cast<ArrayMemoryRange *>(range);
    Q_ASSERT(tableRange != nullptr);
    ArrayParam* param = new ArrayParam(tableRange, slot, this);
    Q_ASSERT(param != nullptr);
    param->saveable = saveable;
    param->key = key;
    mParams[key] = param;
    mParamKeys.insert(std::lower_bound(mParamKeys.begin(), mParamKeys.end(), key), key);
    if(saveable)
        mSaveableParamKeys.insert(std::lower_bound(mSaveableParamKeys.begin(), mSaveableParamKeys.end(), key), key);
    connect(param, &Param::writeCacheDirtyChanged, this, &ParamRegistry::onParamWriteCacheDirtyChanged);
    return param;
}

ScalarParam *ParamRegistry::addScalarParam(int type, XcpPtr base, bool writable, bool saveable, SetupTools::Slot *slot)
{
    return addScalarParam(type, base, writable, saveable, slot, base.toString());
}

ArrayParam *ParamRegistry::addArrayParam(int type, XcpPtr base, int count, bool writable, bool saveable, SetupTools::Slot *slot)
{
    return addArrayParam(type, base, count, writable, saveable, slot, base.toString());
}

ScalarParam *ParamRegistry::addScalarParam(int type, quint32 base, bool writable, bool saveable, SetupTools::Slot *slot, QString key)
{
    XcpPtr basePtr(base);
    return addScalarParam(type, basePtr, writable, saveable, slot, key);
}

ArrayParam *ParamRegistry::addArrayParam(int type, quint32 base, int count, bool writable, bool saveable, SetupTools::Slot *slot, QString key)
{
    XcpPtr basePtr(base);
    return addArrayParam(type, basePtr, count, writable, saveable, slot, key);
}

ScalarParam *ParamRegistry::addScalarParam(int type, quint32 base, bool writable, bool saveable, SetupTools::Slot *slot)
{
    XcpPtr basePtr(base);
    return addScalarParam(type, basePtr, writable, saveable, slot, basePtr.toString());
}

ArrayParam *ParamRegistry::addArrayParam(int type, quint32 base, int count, bool writable, bool saveable, SetupTools::Slot *slot)
{
    XcpPtr basePtr(base);
    return addArrayParam(type, basePtr, count, writable, saveable, slot, basePtr.toString());
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

void ParamRegistry::onTableConnectionChanged()
{
    emit connectionChanged();
}

void ParamRegistry::addParamKey(QString key)
{
    auto beforeIt = std::lower_bound(mParamKeys.begin(), mParamKeys.end(), key);
    mParamKeys.insert(beforeIt, key);
    emit paramsChanged();
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

