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

void Interface::transmit(const std::vector<quint8> & data) {
    Q_UNUSED(data);
    Q_ASSERT(0);
}

std::vector<std::vector<quint8> > Interface::receive(int timeoutMsec) {
    Q_UNUSED(timeoutMsec);
    Q_ASSERT(0);
    return std::vector<std::vector<quint8> >();
}

}
}
}
