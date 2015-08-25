#include "Xcp_Interface_Loopback_Interface.h"

namespace SetupTools
{
namespace Xcp
{
namespace Interface
{
namespace Loopback
{

 Interface::Interface(QObject *parent) :
    ::SetupTools::Xcp::Interface::Interface(parent),
    mPacketLogEnabled(false),
    mHasReliableTx(true)
{
    mPacketTimer.start();
}

OpResult  Interface::transmit(const std::vector<quint8> & data, bool replyExpected)
{
    Q_UNUSED(replyExpected);
    if(mPacketLogEnabled)
    {
        qDebug() << mPacketTimer.nsecsElapsed() / 1000000000.0 << "Master TX" << ToHexString(data.begin(), data.end());
    }
    mSlaveReceiveQueue.put(data);
    return OpResult::Success;
}

OpResult  Interface::receive(int timeoutMsec, std::vector<std::vector<quint8> > &out)
{
    out = mMasterReceiveQueue.getAll(timeoutMsec);
    return OpResult::Success;
}

OpResult  Interface::clearReceived()
{
    mMasterReceiveQueue.getAll(0);
    return OpResult::Success;
}

void  Interface::slaveTransmit(const std::vector<quint8> & data)
{
    if(mPacketLogEnabled)
    {
        qDebug() << mPacketTimer.nsecsElapsed() / 1000000000.0 << "Slave TX" << ToHexString(data.begin(), data.end());
    }
    mMasterReceiveQueue.put(data);
}

std::vector<std::vector<quint8> >  Interface::slaveReceive(int timeoutMsec)
{
    return mSlaveReceiveQueue.getAll(timeoutMsec);
}

SetupTools::Xcp::OpResult Interface::setPacketLog(bool enable)
{
    mPacketLogEnabled = enable;
    return OpResult::Success;
}

 void Interface::setHasReliableTx(bool val)
{
    mHasReliableTx = val;
}

 bool Interface::hasReliableTx()
{
    return mHasReliableTx;
}

}   // namespace Can
}   // namespace Interface
}   // namespace Xcp
}   // namespace SetupTools
