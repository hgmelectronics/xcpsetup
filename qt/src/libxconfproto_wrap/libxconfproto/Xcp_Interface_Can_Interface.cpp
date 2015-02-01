#include "Xcp_Interface_Can_Interface.h"

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

LIBXCONFPROTOSHARED_EXPORT Id::Id(quint32 addr_in, Type ext_in) :
    addr(addr_in),
    type(ext_in)
{}

LIBXCONFPROTOSHARED_EXPORT Id::operator QString()
{
    if(type == Type::Std)
        return QString("%1").arg(addr, 3, 16, QChar('0'));
    else
        return QString("x%1").arg(addr, 8, 16, QChar('0'));
}

bool LIBXCONFPROTOSHARED_EXPORT operator==(const Id &lhs, const Id &rhs)
{
    return (lhs.addr == rhs.addr && lhs.type == rhs.type);
}

bool LIBXCONFPROTOSHARED_EXPORT operator!=(const Id &lhs, const Id &rhs)
{
    return !(lhs == rhs);
}

LIBXCONFPROTOSHARED_EXPORT Filter::Filter() :
    filt(0, Id::Type::Std),
    maskId(0),
    maskEff(false)
{}

LIBXCONFPROTOSHARED_EXPORT Filter::Filter(Id filt_in, quint32 maskId_in, bool maskEff_in) :
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

Frame::Frame() :
    id(),
    data()
{}
Frame::Frame(Id id_in, const std::vector<quint8> &data_in) :
    id(id_in),
    data(data_in)
{}
Frame::Frame(quint32 id_in, Id::Type idType_in, const std::vector<quint8> &data_in) :
    id(id_in, idType_in),
    data(data_in)
{}

LIBXCONFPROTOSHARED_EXPORT Frame::operator QString()
{
    QByteArray dataArr(reinterpret_cast<const char *>(data.data()), data.size());

    return QString(id) + " " + dataArr.toHex();
}

bool validateXcp(const Frame &frame)
{
    if(frame.data.size() > 0 && (quint8(frame.data[0]) == 0xFF || quint8(frame.data[0]) == 0xFE))
        return true;
    else
        return false;
}

LIBXCONFPROTOSHARED_EXPORT Interface::Interface(QObject *parent) :
    ::SetupTools::Xcp::Interface::Interface(parent),
    mPacketLogEnabled(false)
{}

void LIBXCONFPROTOSHARED_EXPORT Interface::transmit(const std::vector<quint8> & data)
{
    Q_ASSERT(mSlaveAddr);
    transmitTo(data, mSlaveAddr.get().cmd);
}

std::vector<std::vector<quint8> > LIBXCONFPROTOSHARED_EXPORT Interface::receive(int timeoutMsec)
{
    if(!mSlaveAddr)
        return std::vector<std::vector<quint8> >();

    std::vector<Frame> frames = receiveFrames(timeoutMsec, ExactFilter(mSlaveAddr.get().res), &SetupTools::Xcp::Interface::Can::validateXcp);

    std::vector<std::vector<quint8> > pkts;
    for(auto &frame: frames)
        pkts.push_back(frame.data);
    return pkts;
}

void LIBXCONFPROTOSHARED_EXPORT Interface::setPacketLog(bool enable)
{
    mPacketLogEnabled = enable;
}

}   // namespace Can
}   // namespace Interface
}   // namespace Xcp
}   // namespace SetupTools
