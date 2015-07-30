#include "Xcp_ScalarMemoryRange.h"

namespace SetupTools {
namespace Xcp {

ScalarMemoryRange::ScalarMemoryRange(MemoryRangeType type, Xcp::XcpPtr base, bool writable, quint8 addrGran, MemoryRangeList *parent) :
    MemoryRange(base, memoryRangeTypeSize(type), writable, addrGran, parent),
    mType(type),
    mValid(false),
    mCache(size()),
    mCacheLoaded(size()),
    mValue(QVariant::Type(memoryRangeTypeQtCode(type)))    // make a null QVariant of requested type
{}

bool ScalarMemoryRange::valid() const
{
    return mValid;
}

QVariant ScalarMemoryRange::value() const
{
    return mValue;
}

void ScalarMemoryRange::setValue(QVariant value)
{
    QVariant convertedValue = value;
    convertedValue.convert(mValue.type());

    // check for convertibility
    if(!convertedValue.isValid())
        return;
    if(convertedValue == mValue)
        return;

    if(connection()->isOpen())
    {
        std::vector<quint8> buffer(size());
        convertToSlave(mType, connection(), convertedValue, buffer.data());
        connection()->download(base(), buffer);
    }
    else
    {
        mValue = convertedValue;
        emit valueChanged();
    }
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

void ScalarMemoryRange::onUploadDone(Xcp::OpResult result, Xcp::XcpPtr base, int len, std::vector<quint8> data)
{
    Q_UNUSED(base);
    Q_UNUSED(len);

    if(result == Xcp::OpResult::Success && data.size() >= size())
    {
        if(base.ext != mBase.ext)
            return;

        QVariant newValue = mValue;
        quint32 dataEnd = base.addr + data.size() / mAddrGran;
        quint32 copyBegin = std::max(base.addr, mBase.addr);
        quint32 copyEnd = std::min(dataEnd, mBase.addr + mSize / mAddrGran);
        quint32 copyBeginOffset = (copyBegin - base.addr) * mAddrGran;
        if(copyBegin == mBase.addr && copyEnd == (mBase.addr + mSize / mAddrGran))
        {
            // no caching needed, entire value loaded at once
            newValue = convertFromSlave(mType, connection(), data.data() + copyBeginOffset);
            mCacheLoaded.reset();
        }
        else if(end() > base || mBase < dataEnd)
        {
            quint32 copyEndOffset = (copyEnd - base.addr) * mAddrGran;
            quint32 copyBeginCacheOffset = (copyBegin - mBase.addr) * mAddrGran;
            quint32 copyEndCacheOffset = (copyEnd - mBase.addr) * mAddrGran;
            std::copy(data.begin() + copyBeginOffset, data.begin() + copyEndOffset, mCache.begin() + copyBeginCacheOffset);
            for(quint32 iCacheByte = copyBeginCacheOffset; iCacheByte < copyEndCacheOffset; ++iCacheByte)
                mCacheLoaded[iCacheByte] = true;
            if(mCacheLoaded.all())
            {
                newValue = convertFromSlave(mType, connection(), mCache.data());
                mCacheLoaded.reset();
            }
        }
        QVariant oldValue = mValue;
        mValue = newValue;
        if(newValue != oldValue)
            emit valueChanged();
        setValid(true);
    }
    else
    {
        setValid(false);
    }
}

void ScalarMemoryRange::setValid(bool newValid)
{
    if(updateDelta<bool>(mValid, newValid))
        emit validChanged();
}

} // namespace Xcp
} // namespace SetupTools

