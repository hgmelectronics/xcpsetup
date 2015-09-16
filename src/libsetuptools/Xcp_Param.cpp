#include "Xcp_Param.h"

namespace SetupTools {
namespace Xcp {

Param::Param(QObject *parent) :
    QObject(parent),
    saveable(false),
    mBaseRange(nullptr),
    mSlot(nullptr)
{

}

Param::Param(MemoryRange *baseRange, Slot* slot, QObject *parent) :
    QObject(parent),
    saveable(false),
    mBaseRange(baseRange),
    mSlot(slot)

{
    connect(mBaseRange, &MemoryRange::validChanged, this, &Param::onRangeValidChanged);
    connect(mBaseRange, &MemoryRange::writeCacheDirtyChanged, this, &Param::onRangeWriteCacheDirtyChanged);
}

SetupTools::Slot *Param::slot() const
{
    return mSlot;
}

bool Param::valid() const
{
    if(!mBaseRange)
        return false;
    return mBaseRange->valid();
}

bool Param::writeCacheDirty() const
{
    if(!mBaseRange)
        return false;
    return mBaseRange->writeCacheDirty();
}

void Param::resetCaches()
{
    if(!mBaseRange)
        return;
    mBaseRange->resetCaches();
}

void Param::onRangeValidChanged()
{
    emit validChanged();
}

void Param::onRangeWriteCacheDirtyChanged()
{
    emit writeCacheDirtyChanged(key);
}

} // namespace Xcp
} // namespace SetupTools

