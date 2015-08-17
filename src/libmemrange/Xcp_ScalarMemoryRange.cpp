#include "Xcp_ScalarMemoryRange.h"

namespace SetupTools {
namespace Xcp {

ScalarMemoryRange::ScalarMemoryRange(MemoryRangeType type, Xcp::XcpPtr base, bool writable, quint8 addrGran, MemoryRangeList *parent) :
    MemoryRange(base, memoryRangeTypeSize(type), writable, addrGran, parent),
    mType(type),
    mVariantType(QVariant::Type(memoryRangeTypeQtCode(type))),
    mReadCache(size()),
    mReadCacheLoaded(size())
{}

QVariant ScalarMemoryRange::value() const
{
    return mValue;
}

void ScalarMemoryRange::setValue(QVariant value)
{
    QVariant convertedValue = value;
    convertedValue.convert(mVariantType);

    // check for convertibility
    if(convertedValue.isValid()
            && (!mValue.isValid() || convertedValue != mValue))
        mValue = convertedValue;

    emit valueChanged();    // always emit valueChanged so if conversion fails the previous value gets propagated back
}

bool ScalarMemoryRange::operator==(MemoryRange &other)
{
    ScalarMemoryRange *castOther = qobject_cast<ScalarMemoryRange *>(&other);

    if(castOther == nullptr)
        return false;

    if(castOther->base() == base() && castOther->mType == mType)
        return true;

    return false;
}

void ScalarMemoryRange::download()
{
    download(mValue);
}

void ScalarMemoryRange::download(QVariant value)
{
    if(value != mSlaveValue)
    {
        std::vector<quint8> buffer(size());
        convertToSlave(mType, connectionFacade(), value, buffer.data());
        connectionFacade()->download(base(), buffer);
    }
    else
    {
        emit downloadDone(OpResult::Success);
    }
}

void ScalarMemoryRange::onUploadDone(SetupTools::Xcp::OpResult result, Xcp::XcpPtr base, int len, std::vector<quint8> data)
{
    Q_UNUSED(len);

    if(result == SetupTools::Xcp::OpResult::Success)
    {
        if(base.ext != mBase.ext)
            return;

        bool uploadIsDone = true;
        quint32 dataEnd = base.addr + data.size() / mAddrGran;
        quint32 copyBegin = std::max(base.addr, mBase.addr);
        quint32 copyEnd = std::min(dataEnd, mBase.addr + mSize / mAddrGran);
        quint32 copyBeginOffset = (copyBegin - base.addr) * mAddrGran;
        if(copyBegin == mBase.addr && copyEnd == (mBase.addr + mSize / mAddrGran))
        {
            // no caching needed, entire value loaded at once
            mSlaveValue = convertFromSlave(mType, connectionFacade(), data.data() + copyBeginOffset);
            mReadCacheLoaded.reset();
        }
        else if(end() > base && mBase < dataEnd)  // check if ranges overlap at all
        {
            quint32 copyEndOffset = (copyEnd - base.addr) * mAddrGran;
            quint32 copyBeginCacheOffset = (copyBegin - mBase.addr) * mAddrGran;
            quint32 copyEndCacheOffset = (copyEnd - mBase.addr) * mAddrGran;
            std::copy(data.begin() + copyBeginOffset, data.begin() + copyEndOffset, mReadCache.begin() + copyBeginCacheOffset);
            for(quint32 iCacheByte = copyBeginCacheOffset; iCacheByte < copyEndCacheOffset; ++iCacheByte)
                mReadCacheLoaded[iCacheByte] = true;
            if(mReadCacheLoaded.all())
            {
                mSlaveValue = convertFromSlave(mType, connectionFacade(), mReadCache.data());
                mReadCacheLoaded.reset();
            }
        }
        else
        {
            uploadIsDone = false;
        }

        if(mSlaveValue.isValid())
        {
            setValid(true);
            if(updateDelta<>(mValue, mSlaveValue))
                emit valueChanged();
        }
        if(uploadIsDone)    // some part got uploaded
            emit uploadDone(result);
    }
    else if(result == SetupTools::Xcp::OpResult::SlaveErrorOutOfRange)
    {
        mValue = QVariant();
        mSlaveValue = QVariant();
        setValid(false);
    }
}

} // namespace Xcp
} // namespace SetupTools

