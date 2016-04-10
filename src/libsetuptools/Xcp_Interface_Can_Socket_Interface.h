#ifndef XCP_INTERFACE_CAN_SOCKET_INTERFACE_H
#define XCP_INTERFACE_CAN_SOCKET_INTERFACE_H

#include <QObject>
#include <boost/optional.hpp>
#include <boost/range/iterator_range.hpp>
#include <memory>
#include <QtSerialPort/QtSerialPort>
#include <QThread>
#include <QtGlobal>
#include "Xcp_Interface_Can_Interface.h"
#include "Xcp_Interface_Can_Registry.h"
#include "Xcp_Interface_Registry.h"
#include "util.h"

namespace SetupTools
{
namespace Xcp
{
namespace Interface
{
namespace Can
{
namespace Socket
{

class Exception : public ::SetupTools::Xcp::Interface::Exception {};

class UnexpectedResponse : public Exception {};

class NoResponse : public UnexpectedResponse {};

class SerialError : public Exception {};

class ConfigError : public Exception {};

/*!
 * \brief Implementation of CanInterface for SocketCAN. Does not support setting bitrate or interface up/down right now!
 */
class Interface : public ::SetupTools::Xcp::Interface::Can::Interface
{
    Q_OBJECT
public:
    Interface(QObject *parent = NULL);
    Interface(QString ifName, QObject *parent = NULL);
    virtual ~Interface();
    virtual OpResult setup(QString ifName);
    virtual OpResult teardown();
    virtual OpResult connect(SlaveId addr);                      //!< Connect to a slave - allows reception of packets only from its result ID, stores its command ID for use when sending packets with Transmit()
    virtual OpResult disconnect();                                  //!< Disconnect from the slave - allows reception of packets from any ID, disallows use of Transmit() since there is no ID set for it to use
    virtual OpResult transmit(const std::vector<quint8> & data, bool replyExpected = true);             //!< Send one XCP packet to the slave
    virtual OpResult transmitTo(const std::vector<quint8> & data, Id id, bool replyExpected = true); //!< Send one CAN frame to an arbitrary ID
    virtual OpResult receiveFrames(int timeoutMsec, std::vector<Frame> &out, const Filter filter = Filter(), bool (*validator)(const Frame &) = NULL);
    virtual OpResult clearReceived();
    virtual OpResult setBitrate(int bps);                           //!< Set the bitrate used on the interface
    virtual OpResult setFilter(Filter filt);                     //!< Set the CAN filter used on the interface
    virtual bool hasReliableTx() override;
    virtual bool allowsMultipleReplies() override;
    virtual int maxReplyTimeout() override;
private:
    OpResult doSetFilter(const Filter & filt);
    OpResult setRxTimeout(quint32 usec);

    static constexpr quint32 SEND_TIMEOUT_US = 100000;
    static constexpr quint32 ENOBUFS_WAIT_US = 100;
    static constexpr quint32 MAX_RECV_FRAMES = 1024;

    int mSocket;
    Filter mFilter;
};

QList<QSerialPortInfo> getPortsAvail();

class Registry
{
public:
    static QList<QUrl> avail();
    static Interface *make(QUrl uri);
    static QString desc(QUrl uri);
};

}   // namespace Socket
}   // namespace Can
}   // namespace Interface
}   // namespace Xcp
}   // namespace SetupTools

#endif // XCP_INTERFACE_CAN_SOCKET_INTERFACE_H
