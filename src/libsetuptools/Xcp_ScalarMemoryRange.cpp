#include "Xcp_ScalarMemoryRange.h"

namespace SetupTools {
namespace Xcp {

ScalarMemoryRange::ScalarMemoryRange(MemoryRangeType type, Xcp::XcpPtr base, bool writable, quint8 addrGran, MemoryRangeList *parent) :
    MemoryRange(type, base, memoryRangeTypeSize(type), writable, addrGran, parent),
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
    {
        setWriteCacheDirty(true);
        mValue = convertedValue;
    }

    emit valueChanged();    // always emit valueChanged so if conversion fails the previous value gets propagated back
}

void ScalarMemoryRange::resetCaches()
{
    mReadCacheLoaded.reset();
    mSlaveValue = QVariant();
    setWriteCacheDirty(true);
}

bool ScalarMemoryRange::operator==(MemoryRange &other)
{
    ScalarMemoryRange *castOther = qobject_cast<ScalarMemoryRange *>(&other);

    if(castOther == nullptr)
        return false;

    if(castOther->base() == base() && castOther->type() == type())
        return true;

    return false;
}

void ScalarMemoryRange::download()
{
    download(mValue);
}

void ScalarMemoryRange::download(QVariant value)
{
    if(writable() && value != mSlaveValue)
    {
        std::vector<quint8> buffer(size());
        convertToSlave(value, buffer.data());
        connectionFacade()->download(base(), buffer);
    }
    else
    {
        emit downloadDone(OpResult::Success);
    }
}

void ScalarMemoryRange::onUploadDone(SetupTools::Xcp::OpResult result, Xcp::XcpPtr baseAddr, int len, std::vector<quint8> data)
{
    Q_UNUSED(len);

    if(result == SetupTools::Xcp::OpResult::Success)
    {
        if(baseAddr.ext != base().ext)
            return;

        quint32 dataEnd = baseAddr.addr + data.size() / addrGran();

        if(end() <= baseAddr || base() >= dataEnd)  // check if ranges overlap at all
            return;

        quint32 copyBegin = std::max(baseAddr.addr, base().addr);
        quint32 copyEnd = std::min(dataEnd, base().addr + size() / addrGran());
        quint32 copyBeginOffset = (copyBegin - baseAddr.addr) * addrGran();
        if(copyBegin == base().addr && copyEnd == (base().addr + size() / addrGran()))
        {
            // no caching needed, entire value loaded at once
            mSlaveValue = convertFromSlave(data.data() + copyBeginOffset);
            mReadCacheLoaded.reset();
        }
        else if(end() > baseAddr && base() < dataEnd)
        {
            quint32 copyEndOffset = (copyEnd - baseAddr.addr) * addrGran();
            quint32 copyBeginCacheOffset = (copyBegin - base().addr) * addrGran();
            quint32 copyEndCacheOffset = (copyEnd - base().addr) * addrGran();
            std::copy(data.begin() + copyBeginOffset, data.begin() + copyEndOffset, mReadCache.begin() + copyBeginCacheOffset);
            for(quint32 iCacheByte = copyBeginCacheOffset; iCacheByte < copyEndCacheOffset; ++iCacheByte)
                mReadCacheLoaded[iCacheByte] = true;
            if(mReadCacheLoaded.all())
            {
                mSlaveValue = convertFromSlave(mReadCache.data());
                mReadCacheLoaded.reset();
            }
        }
        if(mSlaveValue.isValid())
        {
            setValid(true);
            if(updateDelta<>(mValue, mSlaveValue))
                emit valueChanged();
        }
        emit uploadDone(result);
    }
    else if(result == SetupTools::Xcp::OpResult::SlaveErrorOutOfRange)
    {
        mValue = QVariant();
        mSlaveValue = QVariant();
        emit valueChanged();
        setValid(false);
        emit uploadDone(OpResult::Success); // swallow out-of-range errors since they just indicate this param doesn't exist on slave
    }
    else
    {
        emit uploadDone(result);
    }
    setWriteCacheDirty(mValue != mSlaveValue);
}

} // namespace Xcp
} // namespace SetupTools

