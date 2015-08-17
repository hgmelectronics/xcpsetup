#include "Xcp_TableMemoryRange.h"

namespace SetupTools {
namespace Xcp {

TableMemoryRange::TableMemoryRange(MemoryRangeType type, quint32 dim, Xcp::XcpPtr base, bool writable, quint8 addrGran, MemoryRangeList *parent) :
    MemoryRange(base, memoryRangeTypeSize(type) * dim, writable, addrGran, parent),
    mType(type),
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

int TableMemoryRange::rowCount() const
{
    return int(mDim);
}

QVariant TableMemoryRange::operator[](quint32 index) const
{
    if(index < mDim)
        return mData[index];
    else
        return QVariant();
}

const QList<QVariant> &TableMemoryRange::data() const
{
    return mData;
}

bool TableMemoryRange::setData(const QVariant &value, quint32 index)
{
    if(index >= mDim)
        return false;

    QVariant convertedValue = value;
    convertedValue.convert(mQtType);
    // check for convertibility
    if(!convertedValue.isValid())
        return false;

    if(updateDelta<>(mData[index], convertedValue))
    {
        emit dataChanged(index, index + 1);
        emit valueChanged();
    }
    return true;
}

bool TableMemoryRange::setDataRange(const QList<QVariant> &data, quint32 beginIndex)
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
    }

    return true;
}

bool TableMemoryRange::operator==(MemoryRange &other)
{
    TableMemoryRange *castOther = qobject_cast<TableMemoryRange *>(&other);

    if(castOther == nullptr)
        return false;

    if(castOther->base() == base()
            && castOther->mType == mType
            && castOther->mDim == mDim)
        return true;

    return false;
}

void TableMemoryRange::download()
{
    bool changed = false;
    quint32 beginChanged;
    quint32 endChanged;
    for(quint32 index = 0; index != mDim; ++index)
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

void TableMemoryRange::download(quint32 beginIndex, const QList<QVariant> &data)
{
    if(!data.empty())
    {
        ConnectionFacade *facade = connectionFacade();
        Q_ASSERT(beginIndex + data.size() <= mDim);
        Q_ASSERT(facade);

        std::vector<quint8> buffer(mElemSize * data.size());
        quint8 *bufIt = buffer.data();
        for(const QVariant &item : data)
        {
            convertToSlave(mType, facade, item, bufIt);
            bufIt += mElemSize;
        }
        facade->download(base() + (beginIndex * mElemSize / mAddrGran), buffer);
    }
    else
    {
        emit downloadDone(OpResult::Success);
        return;
    }
}

void TableMemoryRange::onUploadDone(SetupTools::Xcp::OpResult result, Xcp::XcpPtr base, int len, std::vector<quint8> data)
{
    Q_UNUSED(base);
    Q_UNUSED(len);

    ConnectionFacade *facade = connectionFacade();

    if(result == SetupTools::Xcp::OpResult::Success)
    {
        if(base.ext != mBase.ext)
            return;

        quint32 dataEnd = base.addr + data.size() / mAddrGran;

        if(end() <= base || mBase >= dataEnd)
            return;

        quint32 beginAddr = std::max(base.addr, mBase.addr);
        quint32 endAddr = std::min(dataEnd, mBase.addr + mSize / mAddrGran);
        quint32 beginTableOffset = (beginAddr - mBase.addr) * mAddrGran;
        quint32 endTableOffset = (endAddr - mBase.addr) * mAddrGran;
        quint32 beginIndex = beginTableOffset / mElemSize;
        quint32 endIndex = (endTableOffset + mElemSize - 1) / mElemSize;
        quint32 beginFullIndex = (beginTableOffset + mElemSize - 1) / mElemSize;
        quint32 endFullIndex = endTableOffset / mElemSize;

        QList<QVariant> newValue = mData;

        for(quint32 i = beginFullIndex; i < endFullIndex; ++i)
        {
            quint32 elemDataOffset = i * mElemSize + (mBase.addr - base.addr) * mAddrGran;
            newValue[i] = convertFromSlave(mType, facade, data.data() + elemDataOffset);
            mReadCacheLoaded.reset(i);
        }
        if(beginIndex < beginFullIndex)
        {
            quint32 beginDataOffset = (beginAddr - base.addr) * mAddrGran;
            quint32 partSize = (beginFullIndex * mElemSize) - beginTableOffset;
            QVariant partValue = partialUpload(beginTableOffset, {data.data() + beginDataOffset, data.data() + beginDataOffset + partSize});
            if(partValue.isValid())
                newValue[beginIndex] = partValue;
        }
        if(endIndex > endFullIndex)
        {
            quint32 endDataOffset = (endAddr - base.addr) * mAddrGran;
            quint32 partSize = endTableOffset % mElemSize;
            quint32 beginDataOffset = endDataOffset - partSize;
            QVariant partValue = partialUpload(endFullIndex * mElemSize, {data.data() + beginDataOffset, data.data() + endDataOffset});
            if(partValue.isValid())
                newValue[endIndex - 1] = partValue;
        }
        quint32 beginChanged = beginIndex;
        quint32 endChanged = endIndex;
        while(beginChanged != endChanged)
        {
            if(mData[beginChanged] == newValue[beginChanged] && !mData[beginChanged].isNull())
                ++beginChanged;
            else
                break;
        }
        while(beginChanged != endChanged)
        {
            if(mData[endChanged - 1] == newValue[endChanged - 1] && !mData[endChanged - 1].isNull())
                --endChanged;
            else
                break;
        }

        if(beginChanged < endChanged)
        {
            mData = newValue;
            emit dataChanged(beginChanged, endChanged);
            emit valueChanged();
        }
        bool valid = true;
        for(const QVariant &elem : mData)
        {
            if(elem.isNull())
            {
                valid = false;
                break;
            }
        }
        setValid(valid);
        emit dataUploaded(beginIndex, endIndex);
        emit uploadDone(result);
    }
    else if(result == SetupTools::Xcp::OpResult::SlaveErrorOutOfRange)
    {
        setValid(false);
    }
}

QVariant TableMemoryRange::partialUpload(quint32 offset, boost::iterator_range<quint8 *> data)
{
    QVariant newValue;

    std::copy(data.begin(), data.end(), mReadCache.begin() + offset);
    for(quint32 iCacheByte = offset, end = offset + data.size(); iCacheByte < end; ++iCacheByte)
        mReadCacheLoaded[iCacheByte] = true;

    quint32 index = offset / mElemSize;
    quint32 elemOffset = index * mElemSize;

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
        newValue = convertFromSlave(mType, connectionFacade(), mReadCache.data() + elemOffset);
        for(quint32 i = elemOffset, end = elemOffset + data.size(); i < end; ++i)
            mReadCacheLoaded.reset(i);
    }
    return newValue;
}

} // namespace Xcp
} // namespace SetupTools

