#ifndef SETUPTOOLS_XCP_MEMORYRANGELIST_H
#define SETUPTOOLS_XCP_MEMORYRANGELIST_H

#include <QObject>

#include "Xcp_Connection.h"
#include "Xcp_MemoryRange.h"

namespace SetupTools
{
namespace Xcp
{

class MemoryRangeTable; // forward declare
/**
 * @brief A list of memory ranges that overlap, or of only one range.
 */
class MemoryRangeList : public QObject
{
    Q_OBJECT

    Q_PROPERTY(XcpPtr base READ base)
    Q_PROPERTY(quint32 size READ size) //!< Length in bytes, NOT in AG
public:
    MemoryRangeList(quint8 addrGran, MemoryRangeTable *parent);

    XcpPtr base() const;
    XcpPtr end() const;
    quint32 size() const; //!< Length in bytes, NOT in AG
    Xcp::Connection *connection() const;

    /**
     * @brief adds a memrange to list, or returns a pointer to an existing one that is identical
     * @param type Type code
     * @param base Base XCP address
     * @param count Number of entries in range - if > 1 results in a table
     * @param writable
     * @return Pointer to the new or existing range
     */
    MemoryRange *addRange(MemoryRange *newRange);

    /**
     * @brief Passes callback down to all ranges within this list
     * @param result
     */
    void onOpenDone(Xcp::OpResult result);

    /**
     * @brief Passes callback down to all ranges within this list
     * @param result
     */
    void onCloseDone(Xcp::OpResult result);

    /**
     * @brief Passes callback down to all ranges within this list
     * @param result
     * @param base
     * @param len
     * @param data
     */
    void onUploadDone(Xcp::OpResult result, Xcp::XcpPtr base, int len, std::vector<quint8> data = std::vector<quint8> ());

    /**
     * @brief Passes callback down to all ranges within this list
     * @param result
     * @param base
     * @param len
     * @param data
     */
    void onDownloadDone(Xcp::OpResult result, Xcp::XcpPtr base, const std::vector<quint8> &data);

    /**
     * @brief Append and take ownership of the contents of another memory range list
     * @param other
     */
    void merge(MemoryRangeList &other);
signals:

public slots:

private:
    QList<MemoryRange *> mRanges;
    XcpPtr mBase;
    quint32 mSize;
    quint8 mAddrGran;
};

}   // namespace Xcp
}   // namespace SetupTools

#endif // SETUPTOOLS_XCP_MEMORYRANGELIST_H
