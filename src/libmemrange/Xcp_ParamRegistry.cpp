#include "Xcp_ParamRegistry.h"
#include "Xcp_ScalarMemoryRange.h"
#include "Xcp_ScalarParam.h"

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

Param *ParamRegistry::addParam(MemoryRange::MemoryRangeType type, XcpPtr base, quint32 count, bool writable, bool saveable, const Slot *slot, QString key)
{
    std::string stdKey(key.toStdString());
    if(mParams.count(stdKey))
        return nullptr;

    MemoryRange *range = mTable.addRange(type, base, count, writable);
    if(range == nullptr)
        return nullptr;

    if(count == 1)
    {
        ScalarMemoryRange *scalarRange = qobject_cast<ScalarMemoryRange *>(range);
        Q_ASSERT(scalarRange != nullptr);
        ScalarParam *param = new ScalarParam(scalarRange, slot, this);
        Q_ASSERT(param != nullptr);
        param->saveable = saveable;
        mParams[stdKey] = param;
        return param;
    }
    else if(count > 1)
    {
        return nullptr; // FIXME add table support
    }
    else
        return nullptr;
}

Param *ParamRegistry::getParam(QString key)
{
    auto it = mParams.find(key.toStdString());
    if(it != mParams.end())
        return it->second;
    else
        return nullptr;
}

void ParamRegistry::onTableConnectionChanged()
{
    emit connectionChanged();
}

} // namespace Xcp
} // namespace SetupTools

