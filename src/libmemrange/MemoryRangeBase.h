#ifndef SETUPTOOLS_MEMORYRANGEBASE_H
#define SETUPTOOLS_MEMORYRANGEBASE_H

#include <QObject>
#include <vector>
#include "MemoryRangeTable.h"
#include "Xcp_Connection.h"

namespace SetupTools
{
    class MemoryRangeBase: public QObject
    {
        Q_OBJECT

    public:
        MemoryRangeBase(Xcp::XcpPtr address, uint32_t size, bool writable, MemoryRangeTable* parent);

        Q_PROPERTY(uint32_t address READ address )
        Q_PROPERTY(uint32_t length READ length)
        Q_PROPERTY(bool valid READ valid NOTIFY validChanged)
        Q_PROPERTY(bool writable READ writeable NOTIFY writableChanged)

        bool valid() const
        {
            return mValid;
        }

        uint32_t address() const
        {
            return mAddress;
        }

        uint32_t length() const
        {
            return mLength;
        }

        bool writable() const
        {
            return mWritable;
        }

        void openDone(Xcp::OpResult result);  // read
        void closeDone(Xcp::OpResult result); // notify invalid...
        virtual void uploadDone(Xcp::OpResult result, Xcp::XcpPtr base, int len, std::vector<quint8> data) = 0;
        virtual void downloadDone(Xcp::OpResult result, Xcp::XcpPtr base, std::vector<quint8> data) =0;

    signals:
        void valueChanged();
        void validChanged();
        void writableChanged();


    public slots:
        void refresh();

    protected:
        void setValid(bool valid);
        Xcp::Connection* getConnection()
        {
            return static_cast<MemoryRangeTable*>(parent())->getConnection();
        }

    private:
        Xcp::XcpPtr mAddress;
        uint32_t mSize;
        bool mValid;
        bool mWritable;

    };
}

#endif // SETUPTOOLS_MEMORYRANGEBASE_H
