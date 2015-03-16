#include "Xcp_Interface_Interface.h"

namespace SetupTools
{
namespace Xcp
{
namespace Interface
{

Interface::Interface(QObject *parent) :
    QObject(parent)
{}

OpResult Interface::transmit(const std::vector<quint8> & data) {
    Q_UNUSED(data);
    Q_ASSERT(0);
    return OpResult::InvalidOperation;
}

OpResult Interface::receive(int timeoutMsec, std::vector<std::vector<quint8> > &out) {
    Q_UNUSED(timeoutMsec);
    Q_UNUSED(out);
    Q_ASSERT(0);
    return OpResult::InvalidOperation;
}

}
}
}
