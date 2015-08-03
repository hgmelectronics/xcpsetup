#include "Xcp_MemoryRangeTable.h"
#include "Xcp_MemoryRangeList.h"
#include "Xcp_ScalarMemoryRange.h"

namespace SetupTools
{
namespace Xcp
{

MemoryRangeList::MemoryRangeList(quint8 addrGran, MemoryRangeTable *parent) :
    QObject(parent),
    mBase(0),
    mSize(0),
    mAddrGran(addrGran)
{}

XcpPtr MemoryRangeList::base() const
{
    return mBase;
}

XcpPtr MemoryRangeList::end() const
{
    return mBase + size() / mAddrGran;
}

quint32 MemoryRangeList::size() const
{
    return mSize;
}

Xcp::Connection *MemoryRangeList::connection() const
{
    return qobject_cast<MemoryRangeTable *>(parent())->connection();
}

MemoryRange *MemoryRangeList::addRange(MemoryRange *newRange)
{
    for(MemoryRange *range : mRanges)
    {
        if(*range == *newRange)
        {
            delete(newRange);
            return range;
        }
    }
    mRanges.append(newRange);
    newRange->setParent(this);
    if(mRanges.size() == 1)
    {
        mBase = newRange->base();
        mSize = newRange->size();
    }
    else
    {
        mBase = std::min(newRange->base(), mBase);
        XcpPtr newEnd = std::max(newRange->end(), end());
        mSize = (newEnd.addr - mBase.addr) * mAddrGran;
    }
    return newRange;
}

void MemoryRangeList::onOpenDone(OpResult result)
{
    for(MemoryRange *range : mRanges)
        range->onOpenDone(result);
}

void MemoryRangeList::onCloseDone(OpResult result)
{
    for(MemoryRange *range : mRanges)
        range->onCloseDone(result);
}

void MemoryRangeList::onUploadDone(Xcp::OpResult result, Xcp::XcpPtr base, int len, std::vector<quint8> data)
{
    for(MemoryRange *range : mRanges)
        range->onUploadDone(result, base, len, data);
}

void MemoryRangeList::onDownloadDone(OpResult result, XcpPtr base, const std::vector<quint8> &data)
{
    for(MemoryRange *range : mRanges)
        range->onDownloadDone(result, base, data);
}

void MemoryRangeList::merge(MemoryRangeList &other)
{
    Q_ASSERT(mAddrGran == other.mAddrGran);
    Q_ASSERT((mBase < other.end()) || (end() > other.mBase));   // confirm they really do overlap

    bool prevEmpty = (mRanges.size() == 0);
    for(MemoryRange *range : other.mRanges)
    {
        mRanges.append(range);
        range->setParent(this);
    }
    if(prevEmpty)
    {
        mBase = other.mBase;
        mSize = other.mSize;
    }
    else
    {
        XcpPtr oldEnd = end();
        mBase = std::min(mBase, other.mBase);
        XcpPtr newEnd = std::max(other.end(), oldEnd);
        mSize = (newEnd.addr - mBase.addr) * mAddrGran;
    }
}

}   // namespace Xcp
}   // namespace SetupTools
