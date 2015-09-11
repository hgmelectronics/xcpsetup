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
    Q_ASSERT(mSlot);
    return mSlot;
}

bool Param::valid() const
{
    Q_ASSERT(mBaseRange);
    return mBaseRange->valid();
}

void Param::setValid(bool valid)
{
    Q_ASSERT(mBaseRange);
    mBaseRange->setValid(valid);
}

bool Param::writeCacheDirty() const
{
    Q_ASSERT(mBaseRange);
    return mBaseRange->writeCacheDirty();
}

void Param::setWriteCacheDirty(bool dirty)
{
    Q_ASSERT(mBaseRange);
    return mBaseRange->setWriteCacheDirty(dirty);
}

void Param::resetCaches()
{
    Q_ASSERT(mBaseRange);
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

