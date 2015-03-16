#ifndef XCP_INTERFACE_LOOPBACK_INTERFACE_H
#define XCP_INTERFACE_LOOPBACK_INTERFACE_H

#include <boost/optional.hpp>

#include "libxconfproto_global.h"

#include "Xcp_Interface_Interface.h"

namespace SetupTools
{
namespace Xcp
{
namespace Interface
{
namespace Loopback
{

class LIBXCONFPROTOSHARED_EXPORT Interface : public ::SetupTools::Xcp::Interface::Interface
{
    Q_OBJECT
public:
    Interface(QObject *parent = NULL);
    virtual ~Interface() {}
    virtual OpResult transmit(const std::vector<quint8> & data);             //!< Send one XCP packet to the slave
    virtual OpResult receive(int timeoutMsec, std::vector<std::vector<quint8> > &out);   //!< Fetch all packets from the slave currently in the Rx buffer, returning after timeout if no packets
    void slaveTransmit(const std::vector<quint8> & data);             //!< Send one XCP packet to the master
    std::vector<std::vector<quint8> > slaveReceive(int timeoutMsec);   //!< Fetch all packets from the master currently in the Tx buffer, returning after timeout if no packets
    virtual void setPacketLog(bool enable);
private:
    PythonicQueue<std::vector<quint8> > mMasterReceiveQueue, mSlaveReceiveQueue;
    bool mPacketLogEnabled;
    QElapsedTimer mPacketTimer;
};

}   // namespace Loopback
}   // namespace Interface
}   // namespace Xcp
}   // namespace SetupTools

#endif // XCP_INTERFACE_LOOPBACK_INTERFACE_H
