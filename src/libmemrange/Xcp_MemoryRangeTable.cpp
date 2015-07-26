#include "Xcp_MemoryRangeTable.h"

namespace SetupTools
{
    MemoryRangeTable::MemoryRangeTable(XCPConnection* connection, QObject* parent=nullptr):
        QObject(parent),
        mConnection(connection)

    {
        connect(connection, &XCPConnection::openDone, this, &MemoryRangeTable::onOpenDone);
        connect(connection, &XCPConnection::closeDone, this, &MemoryRangeTable::onCloseDone);

        connect(connection, &XCPConnection::uploadDone, this, &MemoryRangeTable::onUploadDone);
        connect(connection, &XCPConnection::downloadDone, this, &MemoryRangeTable::onDownloadDone);

    }

    void MemoryRangeTable::onOpenDone(OpResult result)
    {
        // walk through all of the memory ranges and call the read or open
        // enabling the range if it is valid
    }

    void MemoryRangeTable::onCloseDone(OpResult result)
    {
        //
    }

    void MemoryRangeTable::onUploadDone(OpResult result, XcpPtr base, int len, std::vector<quint8> data)
    {
        // find the appropriate ranges and call methods to norify objects bound to the signals
    }

    void MemoryRangeTable::onDownloadDone(OpResult result, XcpPtr base, std::vector<quint8> data)
    {
        // find the appropriate ranges and call methods to norify objects bound to the signals
    }

}

