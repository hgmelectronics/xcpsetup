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
    ::SetupTools::Xcp::Interface::Interface(parent)
{}

void LIBXCONFPROTOSHARED_EXPORT Interface::transmit(const std::vector<quint8> & data)
{
    mSlaveReceiveQueue.put(data);
}

std::vector<std::vector<quint8> > LIBXCONFPROTOSHARED_EXPORT Interface::receive(int timeoutMsec)
{
    return mMasterReceiveQueue.getAll(timeoutMsec);
}

void LIBXCONFPROTOSHARED_EXPORT Interface::slaveTransmit(const std::vector<quint8> & data)
{
    mMasterReceiveQueue.put(data);
}

std::vector<std::vector<quint8> > LIBXCONFPROTOSHARED_EXPORT Interface::slaveReceive(int timeoutMsec)
{
    return mSlaveReceiveQueue.getAll(timeoutMsec);
}

}   // namespace Can
}   // namespace Interface
}   // namespace Xcp
}   // namespace SetupTools
