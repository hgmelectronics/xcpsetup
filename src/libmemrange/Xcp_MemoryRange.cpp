#include "Xcp_MemoryRange.h"

namespace SetupTools
{
namespace Xcp
{

bool MemoryRange::valid() const
{

}

bool MemoryRange::writable() const
{

}

XcpPtr MemoryRange::base() const
{

}

quint32 MemoryRange::length() const
{

}

QVariant MemoryRange::getValue() const
{
    return mValue;
}

void MemoryRange::setValue(QVariant value)
{
    // check for convertibility
    if(value == mValue)
    {
        return;
    }
    if(mConnection->isOpen())
    {
        size_t numBytes = mSize * mConnection->addrGran();
        std::vector<uint8_t> buffer(numBytes, 0);
        mConnection->toSlaveEndian(value,buffer.data());
        mConnection->download(mAddress, buffer);
        mConnection->upload(mAddress,numBytes);
    }
    else
    {
        mValue = value;
        emit valueChanged();
    }
}

void MemoryRange::refresh()
{

}

void MemoryRange::onOpenDone(OpResult result)
{

}

void MemoryRange::onCloseDone(OpResult result)
{

}

void MemoryRange::onUploadDone(Xcp::OpResult result, Xcp::XcpPtr base, int len, std::vector<quint8> data = std::vector<quint8> ())
{
    Q_UNUSED(base);
    Q_UNUSED(len);

    if(result != Xcp::OpResult::Success)
    {
        setValid(false);
    }
    else if(data.size() < sizeof(ValueType))
    {
        setValid(false);
    }
    else
    {
        mValue =    getConnection()->fromSlaveEndian<ValueType>(dataVec.data());
        setValid(true);
    }
}


void MemoryRange::onDownloadDone(Xcp::OpResult result, Xcp::XcpPtr base, const std::vector<quint8> &data)
{
    if(result != OpResult::Success)
    {
        setValid(false);
        return;
    }
    ValueType value = getConnection()->fromSlaveEndian<ValueType>(data.data());
    if(value != mValue)
    {
        mValue = value;
        emit valueChanged();
        setValue(true);

    }
}

Xcp::Connection *MemoryRange::getConnection()
{
    return qobject_cast<MemoryRangeList *>(parent())->getConnection();
}

}   // namespace Xcp
}   // namespace SetupTools
