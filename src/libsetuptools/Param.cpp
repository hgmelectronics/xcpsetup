#include "Param.h"
#include "util.h"

#include "ParamRegistry.h"

namespace SetupTools {

Param::Param(QObject *parent) :
    QObject(parent),
    mRegistry(nullptr),
    mAddr(),
    mName(),
    mWritable(),
    mSaveable(),
    mFullReload(),
    mBigEndian(),
    mDataType(MemoryRangeType::INVALID),
    mDataTypeSize(),
    mDataTypeCode(),
    mSlot(nullptr),
    mCompleted(),
    mValid(),
    mWriteCacheDirty(),
    mNumBytesLoaded()
{
}

void Param::setValid(bool valid)
{
    if(updateDelta<>(mValid, valid))
    {
        if(valid)
        {
            mBytesLoaded.set();
            mSlaveBytesLoaded.set();
            mNumBytesLoaded = mBytes.size();
        }
        else
        {
            mBytesLoaded.reset();
            mSlaveBytesLoaded.reset();
            mNumBytesLoaded = 0;
        }
        updateEngrFromRaw(0, mBytes.size());
        emit validChanged(mAddr.toString());
        emit rawValueChanged(mAddr.toString());
    }
}

static quint32 memoryRangeTypeSize(Param::MemoryRangeType type)
{
    switch(type)
    {
    case Param::MemoryRangeType::U8:
    case Param::MemoryRangeType::S8:
        return 1;
    case Param::MemoryRangeType::U16:
    case Param::MemoryRangeType::S16:
        return 2;
    case Param::MemoryRangeType::U32:
    case Param::MemoryRangeType::S32:
    case Param::MemoryRangeType::F32:
        return 4;
    case Param::MemoryRangeType::U64:
    case Param::MemoryRangeType::S64:
    case Param::MemoryRangeType::F64:
        return 8;
    default:
        break;
    }
    return 0;
}

static QMetaType::Type memoryRangeTypeQtCode(Param::MemoryRangeType type)
{
    switch(type)
    {
    case Param::MemoryRangeType::U8:
    case Param::MemoryRangeType::U16:
    case Param::MemoryRangeType::U32:
        return QMetaType::Type::UInt;
        break;
    case Param::MemoryRangeType::S8:
    case Param::MemoryRangeType::S16:
    case Param::MemoryRangeType::S32:
        return QMetaType::Type::Int;
        break;
    case Param::MemoryRangeType::F32:
        return QMetaType::Type::Float;
        break;
    case Param::MemoryRangeType::U64:
        return QMetaType::Type::ULongLong;
        break;
    case Param::MemoryRangeType::S64:
        return QMetaType::Type::LongLong;
        break;
    case Param::MemoryRangeType::F64:
        return QMetaType::Type::Double;
        break;
    default:
        break;
    }
    return QMetaType::Type::UnknownType;
}

void Param::setRegistry(ParamRegistry * val)
{
    if(updateDelta<>(mRegistry, val))
    {
        Q_ASSERT(!mCompleted);

        emit registryChanged();
        registerIfCompleted();
    }
}

void Param::setAddr(const QVariant & val)
{
    QVariant newAddr = val;
    QString newKey = val.toString();

    if(val.type() == QVariant::Double)
    {
        newAddr = val.toULongLong();
        newKey = QString("%1").arg(val.toULongLong(), 0, 16);
    }
    else if(val.type() == QVariant::String)
    {
        QString str = val.toString();
        if(str.startsWith("$"))
            newAddr = str.mid(1).toULongLong(nullptr, 16);
    }

    bool updated = false;
    if(updateDelta<>(mAddr, newAddr))
        updated = true;
    if(updateDelta<>(mKey, newKey))
        updated = true;

    if(updated)
    {
        Q_ASSERT(!mCompleted);

        emit addrChanged();
        if(mName.isEmpty())
            emit nameChanged();
        registerIfCompleted();
    }
}

void Param::setDataType(int val)
{
    if(updateDelta<>(mDataType, MemoryRangeType(val)))
    {
        Q_ASSERT(!mCompleted);

        mDataTypeSize = memoryRangeTypeSize(mDataType);
        mDataTypeCode = memoryRangeTypeQtCode(mDataType);

        emit dataTypeChanged();
        registerIfCompleted();
    }
}

void Param::setSlot(Slot * val)
{
    if(updateDelta<>(mSlot, val))
    {
        Q_ASSERT(!mCompleted);

        emit slotChanged();

        registerIfCompleted();
    }
}

void Param::setWriteCacheDirty(bool newWriteCacheDirty)
{
    const bool dirty = mWritable & newWriteCacheDirty;
    if(updateDelta<bool>(mWriteCacheDirty, dirty))
        emit writeCacheDirtyChanged(mKey);
}

void Param::resetCaches()
{
    mSlaveBytesLoaded.reset();
    setWriteCacheDirty(true);
    emit cachesReset();
}

boost::iterator_range<const quint8 *> Param::bytes() const
{
    return mBytes;
}

QPair<quint32, quint32> Param::changedBytes() const
{
    quint32 begin = 0, end = mBytes.size();

    while(begin != end
          && (!mBytesLoaded[end - 1] || (mBytesLoaded[end - 1] && mSlaveBytesLoaded[end - 1] && mBytes[end - 1] == mSlaveBytes[end - 1])))
        --end;

    while(begin != end
          && (!mBytesLoaded[begin] || (mBytesLoaded[begin] && mSlaveBytesLoaded[begin] && mBytes[begin] == mSlaveBytes[begin])))
        ++begin;

    return {begin, end};
}

void Param::setBytes(boost::iterator_range<const quint8 *> data, quint32 offset, bool eraseExisting)
{
    Q_ASSERT(data.size() + offset <= quint32(mBytes.size()));

    bool changed = false;

    if(eraseExisting)
        mBytesLoaded.reset();

    if(!std::equal(data.begin(), data.end(), mBytes.begin() + offset))
    {
        changed = true;
        std::copy(data.begin(), data.end(), mBytes.begin() + offset);
    }

    for(quint32 i = offset, end = offset + data.size(); i != end; ++i)
    {
        if(!mBytesLoaded[i])
        {
            changed = true;
            mBytesLoaded[i] = true;
        }
    }

    if(changed)
    {
        while(mNumBytesLoaded < quint32(mBytes.size()) && mBytesLoaded[mNumBytesLoaded])
            ++mNumBytesLoaded;
        if(mNumBytesLoaded >= minSize())
        {
            if(updateDelta<>(mValid, true))
                emit validChanged(mKey);
        }
        updateEngrFromRaw(offset, offset + data.size());
        emit rawValueChanged(mKey);
    }
    setWriteCacheDirty(mBytesLoaded != mSlaveBytesLoaded
            || !std::equal(mBytes.begin(), mBytes.begin() + mNumBytesLoaded, mSlaveBytes.begin()));
}

void Param::setSlaveBytes(boost::iterator_range<const quint8 *> data, quint32 offset)
{
    Q_ASSERT(data.size() + offset <= quint32(mBytes.size()));

    std::copy(data.begin(), data.end(), mSlaveBytes.begin() + offset);

    for(quint32 i = offset, end = offset + data.size(); i != end; ++i)
    {
        mSlaveBytesLoaded.set(i);
    }

    setBytes(data, offset);
}

bool Param::convertToSlave(QVariant value, quint8 * buf) const
{
    bool ok = false;
    switch(mDataType)
    {
    case MemoryRangeType::U8:
        toSlaveEndian<quint8>(value.toUInt(&ok), buf);
        break;
    case MemoryRangeType::S8:
        toSlaveEndian<qint8>(value.toInt(&ok), buf);
        break;
    case MemoryRangeType::U16:
        toSlaveEndian<quint16>(value.toUInt(&ok), buf);
        break;
    case MemoryRangeType::S16:
        toSlaveEndian<qint16>(value.toInt(&ok), buf);
        break;
    case MemoryRangeType::U32:
        toSlaveEndian<quint32>(value.toUInt(&ok), buf);
        break;
    case MemoryRangeType::S32:
        toSlaveEndian<qint32>(value.toInt(&ok), buf);
        break;
    case MemoryRangeType::F32:
    {
        union {
            quint32 i;
            float f;
        } u;
        u.f = value.toFloat(&ok);
        toSlaveEndian<quint32>(u.i, buf);
        break;
    }
    case MemoryRangeType::U64:
        toSlaveEndian<quint64>(value.toULongLong(&ok), buf);
        break;
    case MemoryRangeType::S64:
        toSlaveEndian<qint64>(value.toLongLong(&ok), buf);
        break;
    case MemoryRangeType::F64:
    {
        union {
            quint64 i;
            double f;
        } u;
        u.f = value.toDouble(&ok);
        toSlaveEndian<quint64>(u.i, buf);
        break;
    }
    default:
        break;
    }
    return ok;
}

QVariant Param::convertFromSlave(const quint8 * buf) const
{
    switch(mDataType)
    {
    case MemoryRangeType::U8:
        return fromSlaveEndian<quint8>(buf);
        break;
    case MemoryRangeType::S8:
        return fromSlaveEndian<qint8>(buf);
        break;
    case MemoryRangeType::U16:
        return fromSlaveEndian<quint16>(buf);
        break;
    case MemoryRangeType::S16:
        return fromSlaveEndian<qint16>(buf);
        break;
    case MemoryRangeType::U32:
        return fromSlaveEndian<quint32>(buf);
        break;
    case MemoryRangeType::S32:
        return fromSlaveEndian<qint32>(buf);
        break;
    case MemoryRangeType::F32:
    {
        union {
            quint32 i;
            float f;
        } u;
        u.i = fromSlaveEndian<quint32>(buf);
        return u.f;
        break;
    }
    case MemoryRangeType::U64:
        return fromSlaveEndian<quint64>(buf);
        break;
    case MemoryRangeType::S64:
        return fromSlaveEndian<qint64>(buf);
        break;
    case MemoryRangeType::F64:
    {
        union {
            quint64 i;
            double f;
        } u;
        u.i = fromSlaveEndian<quint64>(buf);
        return u.f;
        break;
    }
    default:
        return QVariant();
        break;
    }
}

bool Param::isCompleted()
{
    if(mCompleted)
        return true;
    else
        return mRegistry
            && mSlot
            && !mAddr.toString().isEmpty()
            && !mKey.isEmpty()
            && mDataType != MemoryRangeType::INVALID
            && minSize() > 0
            && maxSize() >= minSize();
}

void Param::registerIfCompleted()
{
    if(isCompleted() && !mCompleted)
    {
        mCompleted = true;

        mBytes.resize(maxSize());
        mSlaveBytes.resize(maxSize());
        mBytesLoaded.resize(maxSize());
        mSlaveBytesLoaded.resize(maxSize());
        mBytesLoaded.reset();
        mSlaveBytesLoaded.reset();

        mRegistry->registerParam(this);
    }
}

} // namespace SetupTools
