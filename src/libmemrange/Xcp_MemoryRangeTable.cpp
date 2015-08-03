#include "Xcp_MemoryRangeTable.h"
#include "Xcp_ScalarMemoryRange.h"

namespace SetupTools
{
namespace Xcp
{

MemoryRangeTable::MemoryRangeTable(quint32 addrGran, QObject *parent):
  QObject(parent),
  mAddrGran(addrGran),
  mConnection(nullptr)
{}

quint32 MemoryRangeTable::addrGran() const
{
    return mAddrGran;
}

Connection *MemoryRangeTable::connection() const
{
    return mConnection;
}

void MemoryRangeTable::setConnection(Connection *newConn)
{
    if(newConn != mConnection) {
        if(mConnection)
            disconnect(mConnection, nullptr, nullptr, nullptr);
        mConnection = newConn;
        connect(newConn, &Connection::openDone, this, &MemoryRangeTable::onOpenDone);
        connect(newConn, &Connection::closeDone, this, &MemoryRangeTable::onCloseDone);
        connect(newConn, &Connection::uploadDone, this, &MemoryRangeTable::onUploadDone);
        connect(newConn, &Connection::downloadDone, this, &MemoryRangeTable::onDownloadDone);
        emit connectionChanged();
    }
}

bool MemoryRangeTable::connectionOk() const
{
    if(mConnection == nullptr)
        return false;
    else if(!mConnection->isOpen())
        return false;
    else if(mConnection->addrGran() != int(mAddrGran))
        return false;
    else
        return true;
}

MemoryRange *MemoryRangeTable::addRange(MemoryRange::MemoryRangeType type, XcpPtr base, quint32 count, bool writable)
{
    if(memoryRangeTypeSize(type) % mAddrGran)   // reject unaligned types
        return nullptr;

    MemoryRange *newRange = nullptr;
    if(count == 1)
    {
        newRange = new ScalarMemoryRange(type, base, writable, mAddrGran, nullptr);
    }
    else if(count > 1)
    {
        // FIXME add table support here
    }

    if(newRange == nullptr)
        return nullptr;

    ListRange overlap = findOverlap(base, newRange->size());

    MemoryRangeList *newList = new MemoryRangeList(mAddrGran, this);
    newList->addRange(newRange);
    for(MemoryRangeList *list : overlap)
        newList->merge(*list);
    QList<MemoryRangeList *>::iterator insertIt = mEntries.erase(overlap.begin(), overlap.end());
    mEntries.insert(insertIt, newList);
    return newRange;
}

void MemoryRangeTable::clear()
{
    for(MemoryRangeList *list : mEntries)
        delete list;
    mEntries.clear();
}

void MemoryRangeTable::onOpenDone(OpResult result)
{
    Q_UNUSED(result);
    emit connectionChanged();
    // walk through all of the memory ranges and call the read or open
    // enabling the range if it is valid
    for(MemoryRangeList *list : mEntries)
        list->onOpenDone(result);
}

void MemoryRangeTable::onCloseDone(OpResult result)
{
    Q_UNUSED(result);
    emit connectionChanged();
    for(MemoryRangeList *list : mEntries)
        list->onCloseDone(result);
}

void MemoryRangeTable::onUploadDone(OpResult result, XcpPtr base, int len, std::vector<quint8> data)
{
    // find the appropriate ranges and call methods to notify objects bound to the signals
    ListRange overlap = findOverlap(base, len);
    for(MemoryRangeList *list : overlap)
        list->onUploadDone(result, base, len, data);
}

void MemoryRangeTable::onDownloadDone(OpResult result, XcpPtr base, std::vector<quint8> data)
{
    // find the appropriate ranges and call methods to notify objects bound to the signals
    ListRange overlap = findOverlap(base, data.size());
    for(MemoryRangeList *list : overlap)
        list->onDownloadDone(result, base, data);
}

bool MemoryRangeTable::listBeginLessThan(const MemoryRangeList *list, const XcpPtr &addr)
{
    return (list->base() < addr);
}

bool MemoryRangeTable::listEndLessThan(const MemoryRangeList *list, const XcpPtr &addr)
{
    return (list->end() < addr);
}

MemoryRangeTable::ListIterator MemoryRangeTable::findOverlapBegin(XcpPtr addr)
{
    // find first entry in the table that is not entirely before addr
    // use lower_bound so the comparison function is simpler - compensate by adding 1 to addr
    return std::lower_bound(mEntries.begin(), mEntries.end(), addr + 1, listEndLessThan);
}

MemoryRangeTable::ListIterator MemoryRangeTable::findOverlapEnd(XcpPtr addr)
{
    // find first entry in the table that is entirely past addr
    return std::lower_bound(mEntries.begin(), mEntries.end(), addr, listBeginLessThan);
}

MemoryRangeTable::ListRange MemoryRangeTable::findOverlap(XcpPtr addr, int len)
{
    QList<MemoryRangeList *>::iterator begin = findOverlapBegin(addr);
    QList<MemoryRangeList *>::iterator end = findOverlapEnd(addr + (len / mAddrGran));
    Q_ASSERT(std::distance(begin, end) >= 0);
    return boost::iterator_range<QList<MemoryRangeList *>::iterator>(begin, end);
}

}   // namespace Xcp
}   // namespace SetupTools
