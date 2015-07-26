#include "MemoryRange.h"


namespace SetupTools
{

class MemoryRange: public MemoryRangeBase
{
    Q_OBJECT
    Q_ENUMS(MemoryRangeType)
    Q_PROPERTY(QVariant value READ getValue WRITE setValue NOTIFY valueChanged)

public:

    ValueType getValue() const
    {
        return mValue;
    }

    void setValue(ValueType value)
    {
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

private slots:
    virtual void onUploadDone(Xcp::OpResult result, Xcp::XcpPtr base, int len, std::vector<quint8> data = std::vector<quint8> ())
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


    virtual void onDownloadDone(Xcp::OpResult result, Xcp::XcpPtr base, const std::vector<quint8> &data)
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

private:
    ValueType mValue;

};

}
