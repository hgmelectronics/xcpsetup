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
    mPacketLogEnabled(false)
{
    mPacketTimer.start();
}

void LIBXCONFPROTOSHARED_EXPORT Interface::transmit(const std::vector<quint8> & data)
{
    if(mPacketLogEnabled)
    {
        QByteArray arr;
        arr.setRawData(reinterpret_cast<const char *>(data.data()), data.size());
        qDebug() << mPacketTimer.nsecsElapsed() / 1000000000.0 << "Master TX" << arr.toPercentEncoding();
    }
    mSlaveReceiveQueue.put(data);
}

std::vector<std::vector<quint8> > LIBXCONFPROTOSHARED_EXPORT Interface::receive(int timeoutMsec)
{
    return mMasterReceiveQueue.getAll(timeoutMsec);
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

}   // namespace Can
}   // namespace Interface
}   // namespace Xcp
}   // namespace SetupTools
