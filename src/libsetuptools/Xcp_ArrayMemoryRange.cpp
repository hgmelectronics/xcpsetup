#include "Xcp_ArrayMemoryRange.h"
#include <functional>

namespace SetupTools {
namespace Xcp {

ArrayMemoryRange::ArrayMemoryRange(MemoryRangeType type, quint32 dim, Xcp::XcpPtr base, bool writable, quint8 addrGran, MemoryRangeList *parent) :
    MemoryRange(type, base, memoryRangeTypeSize(type) * dim, writable, addrGran, parent),
    mQtType(QVariant::Type(memoryRangeTypeQtCode(type))),
    mElemSize(memoryRangeTypeSize(type)),
    mDim(dim),
    mReadCache(size()),
    mReadCacheLoaded(size())
{
    mData.reserve(dim);
    mSlaveData.reserve(dim);
    for(quint32 i = 0; i < dim; ++i)
    {
        mData.push_back(QVariant());
        mSlaveData.push_back(QVariant());
    }
    Q_ASSERT(dim > 0);
    Q_ASSERT(quint64(dim) * memoryRangeTypeSize(type) < std::numeric_limits<quint32>::max());
}

bool ArrayMemoryRange::inRange(int index) const
{
    return 0 <= index && index<count();
}

bool ArrayMemoryRange::set(int index, const QVariant &value)
{
    if(!inRange(index))
    {
        return false;
    }

    QVariant convertedValue = value;
    convertedValue.convert(mQtType);
    // check for convertibility
    if(!convertedValue.isValid())
        return false;

    if(updateDelta<>(mData[index], convertedValue))
    {
        emit dataChanged(index, index + 1);
        emit valueChanged();
        setWriteCacheDirty(true);
    }
    return true;
}

bool ArrayMemoryRange::setDataRange(const QList<QVariant> &data, quint32 beginIndex)
{
    if((beginIndex + data.size()) > mDim)
        return false;

    QList<QVariant> convertedData = data;
    for(QVariant &item : convertedData)
    {
        item.convert(mQtType);
        if(!item.isValid())
        {
            emit dataChanged(beginIndex, beginIndex + data.size());
            emit valueChanged();
            return false;
        }
    }

    bool changed = false;
    quint32 beginChanged, endChanged;
    for(quint32 index = beginIndex, endIndex = beginIndex + convertedData.size(); index != endIndex; ++index)
    {
        bool itemChanged = updateDelta<>(mData[index], convertedData[index]);
        if(itemChanged)
        {
            if(!changed)
            {
                changed = true;
                beginChanged = index;
            }
            endChanged = index + 1;
        }
    }

    if(changed)
    {
        emit dataChanged(beginChanged, endChanged);
        emit valueChanged();
        setWriteCacheDirty(true);
    }

    return true;
}

void ArrayMemoryRange::resetCaches()
{
    mReadCacheLoaded.reset();
    std::fill(mSlaveData.begin(), mSlaveData.end(), QVariant());
    setWriteCacheDirty(true);
}

bool ArrayMemoryRange::operator==(MemoryRange &other)
{
    ArrayMemoryRange *castOther = qobject_cast<ArrayMemoryRange *>(&other);

    if(castOther == nullptr)
        return false;

    if(castOther->base() == base()
            && castOther->type() == type()
            && castOther->dim() == dim())
        return true;

    return false;
}

void ArrayMemoryRange::download()
{
    bool changed = false;
    quint32 beginChanged = 0;
    quint32 endChanged = 0;
    for(quint32 index = 0; index != dim(); ++index)
    {
        if(mData[index] != mSlaveData[index])
        {
            if(!changed)
            {
                beginChanged = index;
                changed = true;
            }

            endChanged = index + 1;
        }
    }
    download(beginChanged, mData.mid(beginChanged, endChanged - beginChanged));
}

void ArrayMemoryRange::download(quint32 beginIndex, const QList<QVariant> &data)
{
    if(!data.empty())
    {
        Q_ASSERT(beginIndex + data.size() <= mDim);

        std::vector<quint8> buffer(mElemSize * data.size());
        quint8 *bufIt = buffer.data();
        for(const QVariant &item : data)
        {
            convertToSlave(item, bufIt);
            bufIt += mElemSize;
        }
        connectionFacade()->download(base() + (beginIndex * mElemSize / addrGran()), buffer);
    }
    else
    {
        emit downloadDone(OpResult::Success);
        return;
    }
}

void ArrayMemoryRange::onUploadDone(SetupTools::Xcp::OpResult result, Xcp::XcpPtr baseAddr, int len, std::vector<quint8> data)
{
    Q_UNUSED(len);

    if(result == SetupTools::Xcp::OpResult::Success)
    {
        if(baseAddr.ext != base().ext)
            return;

        quint32 dataEnd = baseAddr.addr + data.size() / addrGran();

        if(end() <= baseAddr || base() >= dataEnd)
            return;

        quint32 beginAddr = std::max(baseAddr.addr, base().addr);
        quint32 endAddr = std::min(dataEnd, base().addr + size() / addrGran());
        quint32 beginTableOffset = (beginAddr - base().addr) * addrGran();
        quint32 endTableOffset = (endAddr - base().addr) * addrGran();
        quint32 beginIndex = beginTableOffset / elemSize();
        quint32 endIndex = (endTableOffset + elemSize() - 1) / elemSize();
        quint32 beginFullIndex = (beginTableOffset + elemSize() - 1) / elemSize();
        quint32 endFullIndex = endTableOffset / elemSize();
        quint32 beginChangedIndex = std::numeric_limits<quint32>::max();
        quint32 endChangedIndex = std::numeric_limits<quint32>::min();

        std::function<void(quint32 index, QVariant value)> setDataValue =
                [this, &beginChangedIndex, &endChangedIndex](quint32 index, QVariant value)->void
        {
            mSlaveData[index] = value;
            bool changed = updateDelta<>(mData[index], value);
            if(changed)
            {
                beginChangedIndex = std::min(beginChangedIndex, index);
                endChangedIndex = std::max(endChangedIndex, index + 1);
            }
        };

        for(quint32 i = beginFullIndex; i < endFullIndex; ++i)
        {
            quint32 elemDataOffset = i * elemSize() + (base().addr - baseAddr.addr) * addrGran();
            setDataValue(i, convertFromSlave(data.data() + elemDataOffset));
            mReadCacheLoaded.reset(i);
        }
        if(beginIndex < beginFullIndex)
        {
            quint32 beginDataOffset = (beginAddr - baseAddr.addr) * addrGran();
            quint32 partSize = (beginFullIndex * elemSize()) - beginTableOffset;
            QVariant partValue = partialUpload(beginTableOffset, {data.data() + beginDataOffset, data.data() + beginDataOffset + partSize});
            if(partValue.isValid())
                setDataValue(beginIndex, partValue);
        }
        if(endIndex > endFullIndex)
        {
            quint32 endDataOffset = (endAddr - baseAddr.addr) * addrGran();
            quint32 partSize = endTableOffset % elemSize();
            quint32 beginDataOffset = endDataOffset - partSize;
            QVariant partValue = partialUpload(endFullIndex * elemSize(), {data.data() + beginDataOffset, data.data() + endDataOffset});
            if(partValue.isValid())
                setDataValue(endIndex - 1, partValue);
        }

        if(beginChangedIndex < endChangedIndex)
        {
            emit dataChanged(beginChangedIndex, endChangedIndex);
            emit valueChanged();
        }
        setValid(true);
        emit dataUploaded(beginIndex, endIndex);
        emit uploadDone(result);
        setWriteCacheDirty(mData != mSlaveData);
    }
    else if(result == SetupTools::Xcp::OpResult::SlaveErrorOutOfRange)
    {
        setValid(false);
        std::fill(mData.begin(), mData.end(), QVariant());
        std::fill(mSlaveData.begin(), mSlaveData.end(), QVariant());
        emit uploadDone(OpResult::Success);
    }
    else
    {
        emit uploadDone(result);
    }
}

QVariant ArrayMemoryRange::partialUpload(quint32 offset, boost::iterator_range<quint8 *> data)
{
    QVariant newValue;

    std::copy(data.begin(), data.end(), mReadCache.begin() + offset);
    for(quint32 iCacheByte = offset, end = offset + data.size(); iCacheByte < end; ++iCacheByte)
        mReadCacheLoaded[iCacheByte] = true;

    quint32 index = offset / elemSize();
    quint32 elemOffset = index * elemSize();

    bool allLoaded = true;
    for(quint32 i = elemOffset, end = elemOffset + data.size(); i < end; ++i)
    {
        if(!mReadCacheLoaded[i])
        {
            allLoaded = false;
            break;
        }
    }
    if(allLoaded)
    {
        newValue = convertFromSlave(mReadCache.data() + elemOffset);
        for(quint32 i = elemOffset, end = elemOffset + data.size(); i < end; ++i)
            mReadCacheLoaded.reset(i);
    }
    return newValue;
}

} // namespace Xcp
} // namespace SetupTools

