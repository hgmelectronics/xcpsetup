#include "Xcp_Param.h"

namespace SetupTools {
namespace Xcp {

Param::Param(QObject *parent) :
    Param(nullptr, parent)
{}

Param::Param(MemoryRange *baseRange, QObject *parent) :
    QObject(parent),
    saveable(false),
    mBaseRange(baseRange)
{
    connect(mBaseRange, &MemoryRange::validChanged, this, &Param::onRangeValidChanged);
    connect(mBaseRange, &MemoryRange::writeCacheDirtyChanged, this, &Param::onRangeWriteCacheDirtyChanged);
}

bool Param::valid() const
{
    Q_ASSERT(mBaseRange);
    return mBaseRange->valid();
}

bool Param::writeCacheDirty() const
{
    Q_ASSERT(mBaseRange);
    return mBaseRange->writeCacheDirty();
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

