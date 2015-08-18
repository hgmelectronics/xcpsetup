#include "Xcp_Param.h"

namespace SetupTools {
namespace Xcp {

Param::Param(MemoryRange *baseRange, QObject *parent) :
    QObject(parent),
    saveable(false),
    mBaseRange(baseRange)
{}

bool Param::writeCacheDirty() const
{
    return mBaseRange->writeCacheDirty();
}

void Param::onRangeWriteCacheDirtyChanged()
{
    emit writeCacheDirtyChanged(key);
}

} // namespace Xcp
} // namespace SetupTools

