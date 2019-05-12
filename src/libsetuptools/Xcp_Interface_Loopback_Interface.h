#ifndef XCP_INTERFACE_LOOPBACK_INTERFACE_H
#define XCP_INTERFACE_LOOPBACK_INTERFACE_H

#include <boost/optional.hpp>

#include "Xcp_Interface_Interface.h"

namespace SetupTools
{
namespace Xcp
{
namespace Interface
{
namespace Loopback
{

class Interface : public ::SetupTools::Xcp::Interface::Interface
{
    Q_OBJECT
public:
    Interface(QObject *parent = NULL);
    virtual ~Interface() {}
    virtual OpResult setTarget(const QString &target) override;
    virtual OpResult transmit(const std::vector<quint8> & data, bool replyExpected = true) override;             //!< Send one XCP packet to the slave
    virtual OpResult receive(int timeoutMsec, std::vector<std::vector<quint8> > &out) override;   //!< Fetch all packets from the slave currently in the Rx buffer, returning after timeout if no packets
    virtual OpResult clearReceived() override;
    void slaveTransmit(const std::vector<quint8> & data);             //!< Send one XCP packet to the master
    std::vector<std::vector<quint8> > slaveReceive(int timeoutMsec);   //!< Fetch all packets from the master currently in the Tx buffer, returning after timeout if no packets
    virtual SetupTools::OpResult setPacketLog(bool enable) override;
    QString connectedTarget() override;
    void setHasReliableTx(bool val);
    virtual bool hasReliableTx() override;
    virtual bool allowsMultipleReplies() override;
    virtual int maxReplyTimeout() override;
private:
    PythonicQueue<std::vector<quint8> > mMasterReceiveQueue, mSlaveReceiveQueue;
    bool mPacketLogEnabled;
    bool mHasReliableTx;
    QElapsedTimer mPacketTimer;
};

}   // namespace Loopback
}   // namespace Interface
}   // namespace Xcp
}   // namespace SetupTools

#endif // XCP_INTERFACE_LOOPBACK_INTERFACE_H
