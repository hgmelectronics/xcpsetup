#include "Xcp_Interface_Loopback_Interface.h"

namespace SetupTools
{
namespace Xcp
{
namespace Interface
{
namespace Loopback
{

LIBXCONFPROTOSHARED_EXPORT Interface::Interface(QObject *parent) :
    ::SetupTools::Xcp::Interface::Interface(parent),
    mPacketLogEnabled(false),
    mHasReliableTx(true)
{
    mPacketTimer.start();
}

OpResult LIBXCONFPROTOSHARED_EXPORT Interface::transmit(const std::vector<quint8> & data, bool replyExpected)
{
    Q_UNUSED(replyExpected);
    if(mPacketLogEnabled)
    {
        QByteArray arr;
        arr.setRawData(reinterpret_cast<const char *>(data.data()), data.size());
        qDebug() << mPacketTimer.nsecsElapsed() / 1000000000.0 << "Master TX" << arr.toPercentEncoding();
    }
    mSlaveReceiveQueue.put(data);
    return OpResult::Success;
}

OpResult LIBXCONFPROTOSHARED_EXPORT Interface::receive(int timeoutMsec, std::vector<std::vector<quint8> > &out)
{
    out = mMasterReceiveQueue.getAll(timeoutMsec);
    return OpResult::Success;
}

OpResult LIBXCONFPROTOSHARED_EXPORT Interface::clearReceived()
{
    mMasterReceiveQueue.getAll(0);
    return OpResult::Success;
}

void LIBXCONFPROTOSHARED_EXPORT Interface::slaveTransmit(const std::vector<quint8> & data)
{
    if(mPacketLogEnabled)
    {
        QByteArray arr;
        arr.setRawData(reinterpret_cast<const char *>(data.data()), data.size());
        qDebug() << mPacketTimer.nsecsElapsed() / 1000000000.0 << "Slave TX" << arr.toPercentEncoding();
    }
    mMasterReceiveQueue.put(data);
}

std::vector<std::vector<quint8> > LIBXCONFPROTOSHARED_EXPORT Interface::slaveReceive(int timeoutMsec)
{
    return mSlaveReceiveQueue.getAll(timeoutMsec);
}

void LIBXCONFPROTOSHARED_EXPORT Interface::setPacketLog(bool enable)
{
    mPacketLogEnabled = enable;
}

LIBXCONFPROTOSHARED_EXPORT void Interface::setHasReliableTx(bool val)
{
    mHasReliableTx = val;
}

LIBXCONFPROTOSHARED_EXPORT bool Interface::hasReliableTx()
{
    return mHasReliableTx;
}

}   // namespace Can
}   // namespace Interface
}   // namespace Xcp
}   // namespace SetupTools
