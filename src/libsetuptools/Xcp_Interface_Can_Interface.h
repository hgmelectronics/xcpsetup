#ifndef XCP_INTERFACE_CAN_INTERFACE_H
#define XCP_INTERFACE_CAN_INTERFACE_H

#include <boost/optional.hpp>

#include "Xcp_Interface_Interface.h"

namespace SetupTools
{
namespace Xcp
{
namespace Interface
{
namespace Can
{

struct Id
{
public:
    enum class Type { Std, Ext };

    Id();
    Id(quint32 addr_in, Type ext_in);
    operator QString();

    quint32 addr;
    Type type;
};
bool operator==(const Id &lhs, const Id &rhs);
bool operator!=(const Id &lhs, const Id &rhs);

boost::optional<Id> StrToId(QString str);
QString IdToStr(Id id);

struct SlaveId
{
public:
    Id cmd, res;
};

boost::optional<SlaveId>  StrToSlaveId(QString str);
QString  SlaveIdToStr(SlaveId id);

struct  Filter
{
public:
    Filter();
    Filter(Id filt_in, quint32 maskId_in, bool maskEff_in);
    bool Matches(Id id) const;

    Id filt;
    quint32 maskId;
    bool maskEff;
};

boost::optional<Filter>  StrToFilter(QString str);
QString  FilterToStr(Filter filt);

struct  Frame
{
public:
    Frame();
    Frame(Id id_in, const std::vector<quint8> &data_in);
    Frame(quint32 id_in, Id::Type idType_in, const std::vector<quint8> &data_in);
    operator QString();

    Id id;
    std::vector<quint8> data;
};

Filter  ExactFilter(Id addr);

//bool validateXcp(const Frame &frame);

class Interface : public ::SetupTools::Xcp::Interface::Interface
{
    Q_OBJECT
public:
    Interface(QObject *parent = NULL);
    virtual ~Interface() {}
    virtual OpResult connect(SlaveId addr) = 0;                         //!< Connect to a slave - allows reception of packets only from its result ID, stores its command ID for use when sending packets with Transmit()
    virtual OpResult disconnect() = 0;                                  //!< Disconnect from the slave - allows reception of packets from any ID, disallows use of Transmit() since there is no ID set for it to use
    virtual OpResult transmit(const std::vector<quint8> & data, bool replyExpected = true);             //!< Send one XCP packet to the slave
    virtual OpResult transmitTo(const std::vector<quint8> & data, Id id, bool replyExpected = true) = 0;    //!< Send one CAN frame to an arbitrary ID
    virtual OpResult receive(int timeoutMsec, std::vector<std::vector<quint8> > &out);   //!< Fetch all packets from the slave currently in the Rx buffer, returning after timeout if no packets
    virtual OpResult receiveFrames(int timeoutMsec, std::vector<Frame> &out, const Filter filter = Filter(), bool (*validator)(const Frame &) = NULL) = 0;
    virtual OpResult clearReceived() = 0;
    virtual OpResult setBitrate(int bps) = 0;                           //!< Set the bitrate used on the interface
    virtual OpResult setFilter(Filter filt) = 0;                        //!< Set the CAN filter used on the interface
    virtual OpResult setPacketLog(bool enable);
    boost::optional<SlaveId> getSlaveId();
protected:
    boost::optional<SlaveId> mSlaveAddr;
    bool mPacketLogEnabled;
};

}   // namespace Can
}   // namespace Interface
}   // namespace Xcp
}   // namespace SetupTools

#endif // XCP_INTERFACE_CAN_INTERFACE_H
