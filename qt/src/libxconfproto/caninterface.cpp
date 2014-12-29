#include "caninterface.h"

namespace SetupTools
{
namespace Xcp
{
namespace Interface
{
namespace Can
{

LIBXCONFPROTOSHARED_EXPORT Id::Id() :
    addr(0),
    type(Type::Std)
{}

LIBXCONFPROTOSHARED_EXPORT Id::Id(u_int32_t addr_in, Type ext_in) :
    addr(addr_in),
    type(ext_in)
{}

bool LIBXCONFPROTOSHARED_EXPORT Id::operator==(const Id &rhs)
{
    return (addr == rhs.addr && type == rhs.type);
}

bool LIBXCONFPROTOSHARED_EXPORT Id::operator!=(const Id &rhs)
{
    return (addr != rhs.addr || type != rhs.type);
}

LIBXCONFPROTOSHARED_EXPORT Filter::Filter() :
    filt(0, Id::Type::Std),
    maskId(0),
    maskEff(false)
{}

LIBXCONFPROTOSHARED_EXPORT Filter::Filter(Id filt_in, u_int32_t maskId_in, bool maskEff_in) :
    filt(filt_in),
    maskId(maskId_in),
    maskEff(maskEff_in)
{}

Filter LIBXCONFPROTOSHARED_EXPORT ExactFilter(Id addr) {
    if(addr.type == Id::Type::Ext)
        return Filter(addr, 0x1FFFFFFF, true);
    else
        return Filter(addr, 0x7FF, true);
}

bool Filter::Matches(Id id) const {
    if(maskEff && filt.type != id.type)
        return false;
    else if(filt.addr != (maskId & id.addr))
        return false;
    else
        return true;
}

bool validateXcp(const Frame &frame)
{
    if(frame.data.size() > 0 && (quint8(frame.data[0]) == 0xFF || quint8(frame.data[1]) == 0xFE))
        return true;
    else
        return false;
}

CanInterface::CanInterface(QObject *parent) :
    Interface(parent)
{}

QList<QByteArray> LIBXCONFPROTOSHARED_EXPORT CanInterface::receive(int timeoutMsec)
{
    if(!mSlaveAddr)
        return QList<QByteArray>();

    QList<Frame> frames = receiveFrames(timeoutMsec, ExactFilter(mSlaveAddr.get().res), &SetupTools::Xcp::Interface::Can::validateXcp);

    QList<QByteArray> pkts;
    for(auto &frame: frames)
        pkts.append(frame.data);
    return pkts;
}

}   // namespace Can
}   // namespace Interface
}   // namespace Xcp
}   // namespace SetupTools
