#ifndef XCP_INTERFACE_CAN_INTERFACE_H
#define XCP_INTERFACE_CAN_INTERFACE_H

#include <boost/optional.hpp>

#include "libxconfproto_global.h"

#include "Xcp_Interface_Interface.h"

namespace SetupTools
{
namespace Xcp
{
namespace Interface
{
namespace Can
{

struct LIBXCONFPROTOSHARED_EXPORT Id
{
public:
    enum class Type { Std, Ext };

    Id();
    Id(u_int32_t addr_in, Type ext_in);
    bool operator==(const Id &rhs);
    bool operator!=(const Id &rhs);

    u_int32_t addr;
    Type type;
};

struct LIBXCONFPROTOSHARED_EXPORT SlaveId
{
public:
    Id cmd, res;
};

struct LIBXCONFPROTOSHARED_EXPORT Filter
{
public:
    Filter();
    Filter(Id filt_in, u_int32_t maskId_in, bool maskEff_in);
    bool Matches(Id id) const;

    Id filt;
    u_int32_t maskId;
    bool maskEff;
};

struct LIBXCONFPROTOSHARED_EXPORT Frame
{
public:
    Id id;
    QByteArray data;
};

Filter LIBXCONFPROTOSHARED_EXPORT ExactFilter(Id addr);

//bool validateXcp(const Frame &frame);

class LIBXCONFPROTOSHARED_EXPORT Interface : public ::SetupTools::Xcp::Interface::Interface
{
    Q_OBJECT
public:
    Interface(QObject *parent = NULL);
    virtual ~Interface() {}
    virtual void connect(SlaveId addr) = 0;                         //!< Connect to a slave - allows reception of packets only from its result ID, stores its command ID for use when sending packets with Transmit()
    virtual void disconnect() = 0;                                  //!< Disconnect from the slave - allows reception of packets from any ID, disallows use of Transmit() since there is no ID set for it to use
    virtual void transmit(const QByteArray & data) = 0;             //!< Send one XCP packet to the slave
    virtual void transmitTo(const QByteArray & data, Id id) = 0;    //!< Send one CAN frame to an arbitrary ID
    virtual QList<QByteArray> receive(unsigned long timeoutMsec);   //!< Fetch all packets from the slave currently in the Rx buffer, returning after timeout if no packets
    virtual QList<Frame> receiveFrames(unsigned long timeoutMsec, const Filter filter = Filter(), bool (*validator)(const Frame &) = NULL) = 0;
    virtual void setBitrate(int bps) = 0;                           //!< Set the bitrate used on the interface
    virtual void setFilter(Filter filt) = 0;                        //!< Set the CAN filter used on the interface
protected:
    boost::optional<SlaveId> mSlaveAddr;
};

}   // namespace Can
}   // namespace Interface
}   // namespace Xcp
}   // namespace SetupTools

#endif // XCP_INTERFACE_CAN_INTERFACE_H
