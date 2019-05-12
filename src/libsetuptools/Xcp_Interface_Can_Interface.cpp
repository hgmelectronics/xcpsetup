#include "Xcp_Interface_Can_Interface.h"

namespace SetupTools
{
namespace Xcp
{
namespace Interface
{
namespace Can
{

Id::operator QString() const
{
    if(type == Type::Std)
        return QString("%1").arg(addr, 3, 16, QChar('0'));
    else
        return QString("x%1").arg(addr, 8, 16, QChar('0'));
}

boost::optional<Id> StrToId(QString str)
{
    bool ok;
    Id ret;

    ret.addr = str.toUInt(&ok, 16);
    if(!ok)
        return boost::optional<Id>();
    ret.type = (str.size() > 3) ? Id::Type::Ext : Id::Type::Std;
    return ret;
}

QString IdToStr(Id id)
{
    return QString("%1").arg(id.addr, (id.type == Id::Type::Ext) ? 8 : 3, 16, QChar('0'));
}

boost::optional<SlaveId> StrToSlaveId(QString str)
{
    QStringList parts = str.split(":");
    if(parts.size() != 2 )
        return boost::optional<SlaveId>();

    boost::optional<Id> cmdId = StrToId(parts[0]);
    boost::optional<Id> resId = StrToId(parts[1]);
    if(!cmdId || !resId)
        return boost::optional<SlaveId>();
    return boost::optional<SlaveId>({cmdId.get(), resId.get()});
}

QString SlaveIdToStr(SlaveId id)
{
    return IdToStr(id.cmd) + ":" + IdToStr(id.res);
}

Filter::Filter() :
    filt(0, Id::Type::Std),
    maskId(0),
    maskEff(false)
{}

Filter::Filter(Id filt_in, quint32 maskId_in, bool maskEff_in) :
    filt(filt_in),
    maskId(maskId_in),
    maskEff(maskEff_in)
{}

Filter ExactFilter(Id addr) {
    if(addr.type == Id::Type::Ext)
        return Filter(addr, 0x1FFFFFFF, true);
    else
        return Filter(addr, 0x7FF, true);
}

boost::optional<Filter> StrToFilter(QString str)
{
    QStringList parts = str.split(":");
    if(parts.size() > 2 || parts.size() < 1)
        return boost::optional<Filter>();

    boost::optional<Id> id = StrToId(parts[0]);
    if(!id)
        return boost::optional<Filter>();
    if(parts.size() == 1)
        return ExactFilter(id.get());

    boost::optional<Id> mask = StrToId(parts[1]);
    if(!mask)
        return boost::optional<Filter>();
    return Filter(id.get(), mask.get().addr, true);
}

QString FilterToStr(Filter filt)
{
    Id mask(filt.maskId, filt.filt.type);
    return IdToStr(filt.filt) + ":" + IdToStr(mask);
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

Frame::operator QString() const
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

Interface::Interface(QObject *parent) :
    ::SetupTools::Xcp::Interface::Interface(parent),
    mPacketLogEnabled(false)
{
    QObject::connect(this, &Interface::slaveIdChanged, this, &Interface::slaveIdToTargetThunk);
}

OpResult Interface::setTarget(const QString &target)
{
    boost::optional<SlaveId> id = StrToSlaveId(target);
    if(id)
        return connect(id.get());
    else
        return disconnect();
}

OpResult Interface::transmit(const std::vector<quint8> & data, bool replyExpected)
{
    Q_ASSERT(mSlaveAddr);
    return transmitTo(data, mSlaveAddr.get().cmd, replyExpected);
}

OpResult Interface::receive(int timeoutMsec, std::vector<std::vector<quint8> > &out)
{
    if(!mSlaveAddr)
        return OpResult::InvalidOperation;

    std::vector<Frame> frames;
    RETURN_ON_FAIL(receiveFrames(timeoutMsec, frames, ExactFilter(mSlaveAddr.get().res), &SetupTools::Xcp::Interface::Can::validateXcp));

    out.clear();
    for(auto &frame: frames)
        out.push_back(frame.data);
    return OpResult::Success;
}

OpResult Interface::setPacketLog(bool enable)
{
    mPacketLogEnabled = enable;
    return OpResult::Success;
}

boost::optional<SlaveId> Interface::getSlaveId()
{
    return mSlaveAddr;
}

QString Interface::connectedTarget()
{
    if(mSlaveAddr)
        return SlaveIdToStr(mSlaveAddr.get());
    else
        return QString();
}

void Interface::slaveIdToTargetThunk()
{
    emit connectedTargetChanged(connectedTarget());
}

}   // namespace Can
}   // namespace Interface
}   // namespace Xcp
}   // namespace SetupTools
