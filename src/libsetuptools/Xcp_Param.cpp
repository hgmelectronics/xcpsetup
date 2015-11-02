#include "Xcp_Param.h"

namespace SetupTools {
namespace Xcp {

Param::Param(QObject *parent) :
    QObject(parent),
    saveable(false),
    mBaseRange(nullptr),
    mExtRangeValidChangedMapper(nullptr),
    mExtRangeWriteCacheDirtyChangedMapper(nullptr),
    mExtRangeValid(0, 0),
    mExtRangeWriteCacheDirty(0, 0),
    mRequireExtRangesValid(false),
    mSlot(nullptr)
{

}

Param::Param(MemoryRange *baseRange, Slot *slot, QObject *parent) :
    QObject(parent),
    saveable(false),
    mBaseRange(baseRange),
    mExtRangeValidChangedMapper(nullptr),
    mExtRangeWriteCacheDirtyChangedMapper(nullptr),
    mExtRangeValid(0, 0),
    mExtRangeWriteCacheDirty(0, 0),
    mRequireExtRangesValid(false),
    mSlot(slot)

{
    connect(mBaseRange, &MemoryRange::validChanged, this, &Param::onRangeValidChanged);
    connect(mBaseRange, &MemoryRange::writeCacheDirtyChanged, this, &Param::onRangeWriteCacheDirtyChanged);
}

Param::Param(MemoryRange *baseRange, QList<MemoryRange *> extRanges, bool requireExtRangesValid, Slot *slot, QObject *parent) :
    QObject(parent),
    saveable(false),
    mBaseRange(baseRange),
    mExtRanges(extRanges),
    mExtRangeValidChangedMapper(new QSignalMapper(this)),
    mExtRangeWriteCacheDirtyChangedMapper(new QSignalMapper(this)),
    mExtRangeValid(extRanges.size(), 0),
    mExtRangeWriteCacheDirty(extRanges.size(), 0),
    mRequireExtRangesValid(requireExtRangesValid),
    mSlot(slot)
{
    connect(mBaseRange, &MemoryRange::validChanged, this, &Param::onRangeValidChanged);
    connect(mBaseRange, &MemoryRange::writeCacheDirtyChanged, this, &Param::onRangeWriteCacheDirtyChanged);
    for(int i = 0; i < mExtRanges.size(); ++i)
    {
        mExtRangeValidChangedMapper->setMapping(mExtRanges[i], i);
        mExtRangeWriteCacheDirtyChangedMapper->setMapping(mExtRanges[i], i);
        connect(mExtRanges[i], &MemoryRange::validChanged, mExtRangeValidChangedMapper, static_cast<void (QSignalMapper::*)()>(&QSignalMapper::map));
        connect(mExtRanges[i], &MemoryRange::writeCacheDirtyChanged, mExtRangeWriteCacheDirtyChangedMapper, static_cast<void (QSignalMapper::*)()>(&QSignalMapper::map));
    }
    connect(mExtRangeValidChangedMapper, static_cast<void (QSignalMapper::*)(int)>(&QSignalMapper::mapped), this, &Param::onExtRangeValidChanged);
    connect(mExtRangeWriteCacheDirtyChangedMapper, static_cast<void (QSignalMapper::*)(int)>(&QSignalMapper::mapped), this, &Param::onExtRangeWriteCacheDirtyChanged);
}

SetupTools::Slot *Param::slot() const
{
    return mSlot;
}

void Param::setSaveable(bool newSaveable)
{
    if(updateDelta<>(saveable, newSaveable))
        emit saveableChanged();
}

void Param::setKey(QString newKey)
{
    if(updateDelta<>(key, newKey))
        emit keyChanged();
}

bool Param::valid() const
{
    if(!mBaseRange)
        return false;
    return mBaseRange->valid() && (!mRequireExtRangesValid || mExtRangeValid.all());
}

void Param::setValid(bool valid)
{
    Q_ASSERT(mBaseRange);
    mBaseRange->setValid(valid);
    for(MemoryRange *extRange : mExtRanges)
        extRange->setValid(valid);
}

bool Param::writeCacheDirty() const
{
    if(!mBaseRange)
        return false;
    return mBaseRange->writeCacheDirty() || mExtRangeWriteCacheDirty.any();
}

void Param::setWriteCacheDirty(bool dirty)
{
    Q_ASSERT(mBaseRange);
    mBaseRange->setWriteCacheDirty(dirty);
    for(MemoryRange *extRange : mExtRanges)
        extRange->setWriteCacheDirty(dirty);
}

void Param::resetCaches()
{
    if(!mBaseRange)
        return;
    mBaseRange->resetCaches();
    for(MemoryRange *extRange : mExtRanges)
        extRange->resetCaches();
    emit cachesReset();
}

void Param::onRangeValidChanged()
{
    emit validChanged();
}

void Param::onRangeWriteCacheDirtyChanged()
{
    emit writeCacheDirtyChanged(key);
}

void Param::onExtRangeValidChanged(int index)
{
    bool prevValid = valid();
    mExtRangeValid.set(index, mExtRanges[index]->valid());
    if(prevValid != valid())
        emit validChanged();
}

void Param::onExtRangeWriteCacheDirtyChanged(int index)
{
    bool prevWriteCacheDirty = writeCacheDirty();
    mExtRangeWriteCacheDirty.set(index, mExtRanges[index]->writeCacheDirty());
    if(prevWriteCacheDirty != writeCacheDirty())
        emit writeCacheDirtyChanged(key);
}

} // namespace Xcp
} // namespace SetupTools

