#include "Xcp_ParamRegistry.h"
#include "Xcp_ScalarMemoryRange.h"
#include "Xcp_ScalarParam.h"
#include "Xcp_TableMemoryRange.h"
#include "Xcp_TableParam.h"

namespace SetupTools {
namespace Xcp {

ParamRegistry::ParamRegistry(quint32 addrGran, QObject *parent) :
    QObject(parent),
    mTable(addrGran, this)
{
    connect(&mTable, &MemoryRangeTable::connectionChanged, this, &ParamRegistry::onTableConnectionChanged);
}

quint32 ParamRegistry::addrGran() const
{
    return mTable.addrGran();
}

ConnectionFacade *ParamRegistry::connectionFacade() const
{
    return mTable.connectionFacade();
}

void ParamRegistry::setConnectionFacade(ConnectionFacade *facade)
{
    mTable.setConnectionFacade(facade);
}

bool ParamRegistry::connectionOk() const
{
    return mTable.connectionOk();
}

const MemoryRangeTable *ParamRegistry::table() const
{
    return &mTable;
}

const QList<QString> &ParamRegistry::paramKeys() const
{
    return mParamKeys;
}

bool ParamRegistry::writeCacheDirty() const
{
    return !mWriteCacheDirtyKeys.empty();
}

Param *ParamRegistry::addScalarParam(MemoryRange::MemoryRangeType type, XcpPtr base, bool writable, bool saveable, const Slot *slot, QString key)
{
    if(mParams.count(key))
        return nullptr;

    MemoryRange *range = mTable.addScalarRange(type, base, writable);
    if(range == nullptr)
        return nullptr;

    ScalarMemoryRange *scalarRange = qobject_cast<ScalarMemoryRange *>(range);
    Q_ASSERT(scalarRange != nullptr);
    ScalarParam *param = new ScalarParam(scalarRange, slot, this);
    Q_ASSERT(param != nullptr);
    param->saveable = saveable;
    param->key = key;
    mParams[key] = param;
    connect(param, &Param::writeCacheDirtyChanged, this, &ParamRegistry::onParamWriteCacheDirtyChanged);
    return param;
}

Param *ParamRegistry::addTableParam(MemoryRange::MemoryRangeType type, XcpPtr base, int count, bool writable, bool saveable, const Slot *slot, const TableAxis *axis, QString key)
{
    if(mParams.count(key))
        return nullptr;

    if(count < 1)
        return nullptr;

    MemoryRange *range = mTable.addTableRange(type, base, count, writable);
    if(range == nullptr)
        return nullptr;

    TableMemoryRange *tableRange = qobject_cast<TableMemoryRange *>(range);
    Q_ASSERT(tableRange != nullptr);
    TableParam *param = new TableParam(tableRange, slot, axis, this);
    Q_ASSERT(param != nullptr);
    param->saveable = saveable;
    param->key = key;
    mParams[key] = param;
    connect(param, &Param::writeCacheDirtyChanged, this, &ParamRegistry::onParamWriteCacheDirtyChanged);
    return param;
}

Param *ParamRegistry::addScalarParam(MemoryRange::MemoryRangeType type, XcpPtr base, bool writable, bool saveable, const Slot *slot)
{
    return addScalarParam(type, base, writable, saveable, slot, base.toString());
}

Param *ParamRegistry::addTableParam(MemoryRange::MemoryRangeType type, XcpPtr base, int count, bool writable, bool saveable, const Slot *slot, const TableAxis *axis)
{
    return addTableParam(type, base, count, writable, saveable, slot, axis, base.toString());
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

