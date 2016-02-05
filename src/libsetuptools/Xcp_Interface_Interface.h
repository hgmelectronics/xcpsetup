#ifndef XCP_INTERFACE_INTERFACE_H
#define XCP_INTERFACE_INTERFACE_H

#include <QtCore>
#include <list>
#include <QException>
#include "Xcp_Exception.h"
#include "util.h"

namespace SetupTools
{
namespace Xcp
{
namespace Interface
{

class Exception : public ::SetupTools::Xcp::Exception {};

/*!
 * \brief Base class for interfaces (not abstract so dummies can be created by QML, but will fail assertion if dummy used.)
 * Doesn't contain Connect() or the notion of packets since this might be used for USB (one-to-one)
 * or CAN (many devices on the bus, all addressable by the host).
 */

class Interface : public QObject
{
    Q_OBJECT
public:
    Interface(QObject *parent = NULL);
    virtual ~Interface() {}
    virtual OpResult transmit(const std::vector<quint8> & data, bool replyExpected = true);         //!< Send one XCP packet to the slave
    virtual OpResult receive(int timeoutMsec, std::vector<std::vector<quint8> > &out); //!< Fetch all packets from the slave currently in the Rx buffer, returning after timeout if no packets
    virtual OpResult clearReceived() = 0;
    virtual OpResult setPacketLog(bool enable) = 0;
    virtual bool hasReliableTx() = 0;
    virtual bool allowsMultipleReplies() = 0;
    virtual int maxReplyTimeout() = 0;
};

}   // namespace Interface
}   // namespace Xcp
}   // namespace SetupTools

#endif // XCP_INTERFACE_INTERFACE_H
