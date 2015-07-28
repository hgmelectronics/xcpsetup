#include "Xcp_MemoryRange.h"

namespace SetupTools
{
namespace Xcp
{

MemoryRange::MemoryRange(MemoryRangeType type, Xcp::XcpPtr base, bool writable, MemoryRangeList *parent) :
    QObject(parent),
    mBase(base),
    mSize(MemoryRangeTypeSize(type)),
    mWritable(writable)
{}

bool MemoryRange::writable() const
{
    return mWritable;
}

void MemoryRange::setWritable(bool newWritable)
{
    if(updateDelta<bool>(mWritable, newWritable))
        emit writableChanged();
}

XcpPtr MemoryRange::base() const
{
    return mBase;
}

quint32 MemoryRange::size() const
{
    return mSize;
}

void MemoryRange::refresh()
{
    getConnection()->upload(mBase, mSize);
}

void MemoryRange::onOpenDone(OpResult result)
{
    if(result == OpResult::Success)
        refresh();
}

void MemoryRange::onCloseDone(OpResult result)
{
    Q_UNUSED(result);
    // do nothing
}

void MemoryRange::onDownloadDone(Xcp::OpResult result, Xcp::XcpPtr base, const std::vector<quint8> &data)
{
    Q_UNUSED(result);
    Q_UNUSED(base);
    Q_UNUSED(data);

    getConnection()->upload(mBase, mSize);
}

Xcp::Connection *MemoryRange::getConnection() const
{
    return qobject_cast<MemoryRangeList *>(parent())->getConnection();
}

void convertToSlave(MemoryRange::MemoryRangeType type, Xcp::Connection *conn, QVariant value, quint8 *buf)
{
    switch(type)
    {
    case MemoryRangeType::U8:
        conn->toSlaveEndian<quint8>(value.toUInt(), buf);
        break;
    case MemoryRangeType::S8:
        conn->toSlaveEndian<qint8>(value.toInt(), buf);
        break;
    case MemoryRangeType::U16:
        conn->toSlaveEndian<quint16>(value.toUInt(), buf);
        break;
    case MemoryRangeType::S16:
        conn->toSlaveEndian<qint16>(value.toInt(), buf);
        break;
    case MemoryRangeType::U32:
        conn->toSlaveEndian<quint32>(value.toUInt(), buf);
        break;
    case MemoryRangeType::S32:
        conn->toSlaveEndian<qint32>(value.toInt(), buf);1
        break;
    case MemoryRangeType::F32:
        conn->toSlaveEndian<float>(value.toFloat(), buf);
        break;
    case MemoryRangeType::U64:
        conn->toSlaveEndian<quint64>(value.toULongLong(), buf);
        break;
    case MemoryRangeType::S64:
        conn->toSlaveEndian<qint64>(value.toLongLong(), buf);
        break;
    case MemoryRangeType::F64:
        conn->toSlaveEndian<double>(value.toDouble(), buf);
        break;
    default:
        break;
    }
}

QVariant convertFromSlave(MemoryRange::MemoryRangeType type, Xcp::Connection *conn, const quint8 *buf)
{
    switch(type)
    {
    case MemoryRangeType::U8:
        return conn->fromSlaveEndian<quint8>(buf);
        break;
    case MemoryRangeType::S8:
        return conn->fromSlaveEndian<qint8>(buf);
        break;
    case MemoryRangeType::U16:
        return conn->fromSlaveEndian<quint16>(buf);
        break;
    case MemoryRangeType::S16:
        return conn->fromSlaveEndian<qint16>(buf);
        break;
    case MemoryRangeType::U32:
        return conn->fromSlaveEndian<quint32>(buf);
        break;
    case MemoryRangeType::S32:
        return conn->fromSlaveEndian<qint32>(buf);
        break;
    case MemoryRangeType::F32:
       return  conn->fromSlaveEndian<float>(buf);
        break;
    case MemoryRangeType::U64:
        return conn->fromSlaveEndian<quint64>(buf);
        break;
    case MemoryRangeType::S64:
        return conn->fromSlaveEndian<qint64>(buf);
        break;
    case MemoryRangeType::F64:
        return conn->fromSlaveEndian<double>(buf);
        break;
    default:
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
