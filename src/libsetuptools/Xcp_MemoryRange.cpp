#include "Xcp_MemoryRangeTable.h"
#include "Xcp_MemoryRangeList.h"
#include "Xcp_MemoryRange.h"

namespace SetupTools
{
namespace Xcp
{

MemoryRange::MemoryRange(MemoryRangeType type, Xcp::XcpPtr base, quint32 size, bool writable, quint8 addrGran, MemoryRangeList *parent) :
    QObject(parent),
    mBase(base),
    mSize(size),
    mAddrGran(addrGran),
    mWritable(writable),
    mType(type),
    mValid(true),
    mFullReload(true),
    mWriteCacheDirty(false)
{}


void MemoryRange::setFullReload(bool newFullReload)
{
    if(updateDelta<bool>(mFullReload, newFullReload))
        emit fullReloadChanged();
}


XcpPtr MemoryRange::end() const
{
    return mBase + (mSize / mAddrGran);
}

void MemoryRange::upload()
{
    connectionFacade()->upload(mBase, mSize);
}

void MemoryRange::onConnectionChanged(bool ok)
{
    Q_UNUSED(ok);
}

void MemoryRange::onDownloadDone(SetupTools::Xcp::OpResult result, Xcp::XcpPtr base, const std::vector<quint8> &data)
{
    if(result == OpResult::Success)
    {
        if(mFullReload)
            connectionFacade()->upload(mBase, mSize);
        else
            connectionFacade()->upload(base, data.size() / mAddrGran);
    }
    emit downloadDone(result);
}

Xcp::ConnectionFacade *MemoryRange::connectionFacade() const
{
    return qobject_cast<MemoryRangeList *>(parent())->connectionFacade();
}

void MemoryRange::setValid(bool newValid)
{
    if(updateDelta<bool>(mValid, newValid))
        emit validChanged();
}

void MemoryRange::setWriteCacheDirty(bool newWriteCacheDirty)
{
    if(updateDelta<bool>(mWriteCacheDirty, newWriteCacheDirty))
        emit writeCacheDirtyChanged();
}

void MemoryRange::convertToSlave(QVariant value, quint8 *buf)
{
    Xcp::ConnectionFacade *conn = connectionFacade();
    switch(mType)
    {
    case MemoryRange::MemoryRangeType::U8:
        conn->toSlaveEndian<quint8>(value.toUInt(), buf);
        break;
    case MemoryRange::MemoryRangeType::S8:
        conn->toSlaveEndian<qint8>(value.toInt(), buf);
        break;
    case MemoryRange::MemoryRangeType::U16:
        conn->toSlaveEndian<quint16>(value.toUInt(), buf);
        break;
    case MemoryRange::MemoryRangeType::S16:
        conn->toSlaveEndian<qint16>(value.toInt(), buf);
        break;
    case MemoryRange::MemoryRangeType::U32:
        conn->toSlaveEndian<quint32>(value.toUInt(), buf);
        break;
    case MemoryRange::MemoryRangeType::S32:
        conn->toSlaveEndian<qint32>(value.toInt(), buf);
        break;
    case MemoryRange::MemoryRangeType::F32:
    {
        union {
            quint32 i;
            float f;
        } u;
        u.f = value.toFloat();
        conn->toSlaveEndian<quint32>(u.i, buf);
        break;
    }
    case MemoryRange::MemoryRangeType::U64:
        conn->toSlaveEndian<quint64>(value.toULongLong(), buf);
        break;
    case MemoryRange::MemoryRangeType::S64:
        conn->toSlaveEndian<qint64>(value.toLongLong(), buf);
        break;
    case MemoryRange::MemoryRangeType::F64:
    {
        union {
            quint64 i;
            double f;
        } u;
        u.f = value.toDouble();
        conn->toSlaveEndian<quint64>(u.i, buf);
        break;
    }
    default:
        break;
    }
}

QVariant MemoryRange::convertFromSlave(const quint8 *buf)
{
    Xcp::ConnectionFacade *conn = connectionFacade();
    switch(mType)
    {
    case MemoryRange::MemoryRangeType::U8:
        return conn->fromSlaveEndian<quint8>(buf);
        break;
    case MemoryRange::MemoryRangeType::S8:
        return conn->fromSlaveEndian<qint8>(buf);
        break;
    case MemoryRange::MemoryRangeType::U16:
        return conn->fromSlaveEndian<quint16>(buf);
        break;
    case MemoryRange::MemoryRangeType::S16:
        return conn->fromSlaveEndian<qint16>(buf);
        break;
    case MemoryRange::MemoryRangeType::U32:
        return conn->fromSlaveEndian<quint32>(buf);
        break;
    case MemoryRange::MemoryRangeType::S32:
        return conn->fromSlaveEndian<qint32>(buf);
        break;
    case MemoryRange::MemoryRangeType::F32:
    {
        union {
            quint32 i;
            float f;
        } u;
        u.i = conn->fromSlaveEndian<quint32>(buf);
        return u.f;
        break;
    }
    case MemoryRange::MemoryRangeType::U64:
        return conn->fromSlaveEndian<quint64>(buf);
        break;
    case MemoryRange::MemoryRangeType::S64:
        return conn->fromSlaveEndian<qint64>(buf);
        break;
    case MemoryRange::MemoryRangeType::F64:
    {
        union {
            quint64 i;
            double f;
        } u;
        u.i = conn->fromSlaveEndian<quint64>(buf);
        return u.f;
        break;
    }
    default:
        return QVariant();
        break;
    }
}

quint32 memoryRangeTypeSize(MemoryRange::MemoryRangeType type)
{
    switch(type)
    {
    case MemoryRange::MemoryRangeType::U8:
    case MemoryRange::MemoryRangeType::S8:
        return 1;
        break;
    case MemoryRange::MemoryRangeType::U16:
    case MemoryRange::MemoryRangeType::S16:
        return 2;
        break;
    case MemoryRange::MemoryRangeType::U32:
    case MemoryRange::MemoryRangeType::S32:
    case MemoryRange::MemoryRangeType::F32:
        return 4;
        break;
    case MemoryRange::MemoryRangeType::U64:
    case MemoryRange::MemoryRangeType::S64:
    case MemoryRange::MemoryRangeType::F64:
        return 8;
        break;
    default:
        return 0;
        break;
    }
}

QMetaType::Type memoryRangeTypeQtCode(MemoryRange::MemoryRangeType type)
{
    switch(type)
    {
    case MemoryRange::MemoryRangeType::U8:
    case MemoryRange::MemoryRangeType::U16:
    case MemoryRange::MemoryRangeType::U32:
        return QMetaType::Type::UInt;
        break;
    case MemoryRange::MemoryRangeType::S8:
    case MemoryRange::MemoryRangeType::S16:
    case MemoryRange::MemoryRangeType::S32:
        return QMetaType::Type::Int;
        break;
    case MemoryRange::MemoryRangeType::F32:
        return QMetaType::Type::Float;
        break;
    case MemoryRange::MemoryRangeType::U64:
        return QMetaType::Type::ULongLong;
        break;
    case MemoryRange::MemoryRangeType::S64:
        return QMetaType::Type::LongLong;
        break;
    case MemoryRange::MemoryRangeType::F64:
        return QMetaType::Type::Double;
        break;
    default:
        return QMetaType::Type::UnknownType;
        break;
    }
}

}   // namespace Xcp
}   // namespace SetupTools
