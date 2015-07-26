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
    Q_PROPERTY(uint32_t length READ length) //!< Length in bytes, NOT in AG
public:
    MemoryRangeList(MemoryRangeTable *parent);

    XcpPtr base();
    uint32_t length(); //!< Length in bytes, NOT in AG

    /**
     * @brief adds a memrange to list, or returns a pointer to an existing one that is identical
     * @param type Type code
     * @param base Base XCP address
     * @param count Number of entries in range - if > 1 results in a table
     * @return Pointer to the new or existing range
     */
    MemoryRange *addRange(MemoryRangeType type, XcpPtr base, quint32 count, bool writable);

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
signals:

public slots:

};

}   // namespace Xcp
}   // namespace SetupTools

#endif // SETUPTOOLS_XCP_MEMORYRANGELIST_H
