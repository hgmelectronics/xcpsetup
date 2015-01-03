#ifndef XCP_INTERFACE_INTERFACE_H
#define XCP_INTERFACE_INTERFACE_H

#include <QtCore>
#include <QByteArray>
#include <QList>
#include <QException>
#include "Xcp_Exception.h"

namespace SetupTools
{
namespace Xcp
{
namespace Interface
{

class Exception : public ::SetupTools::Xcp::Exception {};

/*!
 * \brief Abstract base class for interfaces. Doesn't contain Connect() or the notion of packets
 * since this might be used for USB (one-to-one) or CAN (many devices on the bus, all addressable
 * by the host).
 */

class Interface : public QObject
{
    Q_OBJECT
public:
    Interface(QObject *parent = NULL);
    virtual ~Interface() {}
    virtual void transmit(const QByteArray & data) = 0;         //!< Send one XCP packet to the slave
    virtual QList<QByteArray> receive(int timeoutMsec) = 0; //!< Fetch all packets from the slave currently in the Rx buffer, returning after timeout if no packets
};

}   // namespace Interface
}   // namespace Xcp
}   // namespace SetupTools

#endif // XCP_INTERFACE_INTERFACE_H
