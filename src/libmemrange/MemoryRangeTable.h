#ifndef SETUPTOOLS_MEMORYRANGETABLE_H
#define SETUPTOOLS_MEMORYRANGETABLE_H

#include <QObject>
#include <QList>
#include "boost/optional.hpp"
#include "Xcp_Connection.h"

namespace SetupTools
{
    class MemoryRangeBase;

    class MemoryRangeTable: public QObject
    {
        Q_OBJECT
    public:
        MemoryRangeTable(Xcp::Connection* connection, QObject* parent=nullptr);

        Xcp::Connection* getConnection()
        {
            return mConnection;
        }

    private slots:
        void onOpenDone(Xcp::OpResult result);
        void onCloseDone(Xcp::OpResult result);
        void onUploadDone(Xcp::OpResult result, Xcp::XcpPtr base, int len, std::vector<quint8> data = std::vector<quint8> ());
        void onDownloadDone(Xcp::OpResult result, Xcp::XcpPtr base, std::vector<quint8> data);

    private:
        Xcp::Connection* mConnection;
        std::vector<MemoryRangeBase*> mEntries;
    };
}

#endif // SETUPTOOLS_MEMORYRANGETABLE_H
