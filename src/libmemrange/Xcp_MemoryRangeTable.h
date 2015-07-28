#ifndef SETUPTOOLS_XCP_MEMORYRANGETABLE_H
#define SETUPTOOLS_XCP_MEMORYRANGETABLE_H

#include <QObject>
#include <vector>

#include "Xcp_Connection.h"
#include "Xcp_MemoryRangeList.h"

namespace SetupTools
{
namespace Xcp
{

class MemoryRangeTable: public QObject
{
    Q_OBJECT
    Q_ENUMS(MemoryRangeType)

    Q_PROPERTY(Xcp::Connection *connection READ getConnection WRITE setConnection)
public:
    MemoryRangeTable(QObject *parent = nullptr);
    Xcp::Connection *getConnection() const;
    void setConnection(Xcp::Connection *);

    /**
     * @brief adds a memrange to table, either in new list or overlapping list, or returns an identical one if existing
     */
    Q_INVOKABLE MemoryRange *addRange(MemoryRangeType type, XcpPtr base, quint32 count, bool writable);

public slots:
    void onOpenDone(Xcp::OpResult result);
    void onCloseDone(Xcp::OpResult result);
    void onUploadDone(Xcp::OpResult result, Xcp::XcpPtr base, int len, std::vector<quint8> data = std::vector<quint8> ());
    void onDownloadDone(Xcp::OpResult result, Xcp::XcpPtr base, std::vector<quint8> data);

private:
    Xcp::Connection *mConnection;
    std::vector<MemoryRangeList> mEntries;
};

}   // namespace Xcp
}   // namespace SetupTools

#endif // SETUPTOOLS_XCP_MEMORYRANGETABLE_H
