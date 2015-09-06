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

class IoTask : public QObject
{
    Q_OBJECT
public:
    IoTask(SerialPort *port, QObject *parent = NULL);
    std::vector<Frame> getRcvdFrames(int timeoutMsec);
    std::vector<std::vector<quint8> > getRcvdCmdResp(int timeoutMsec);
    bool isPromptReady();
    bool waitPromptReady(int timeoutMsec);
    void waitWriteComplete();
    void clearWriteComplete();
    void setSerialLog(bool on);

public slots:
    void init();
    void portReadyRead();
    void portBytesWritten(qint64 bytes);
    void write(std::vector<quint8> data);

private:
    constexpr static const uchar EOL = '\r';
    constexpr static const int PROMPT_DELAY_USEC = 200;

    SerialPort *mPort;
    bool mPacketLogEnabled;
    qint64 mPendingTxBytes;
    QMutex mPendingTxBytesMutex;
    QTimer *mReadPollTimer;

    std::vector<std::vector<quint8> > mLines;
    PythonicQueue<Frame> mRcvdFrameQueue;
    PythonicQueue<std::vector<quint8> > mRcvdCmdRespQueue;
    std::list<std::vector<quint8> > mTransmitQueue;
    PythonicEvent mPromptReady, mWriteComplete;
};

class Io : public QObject
{
    Q_OBJECT
public:
    Io(SerialPort *port, QObject *parent = NULL);
    ~Io();
    void sync();
    OpResult syncAndGetPrompt(int timeoutMsec, int retries = 5);
    std::vector<Frame> getRcvdFrames(int timeoutMsec);
    std::vector<std::vector<quint8> > getRcvdCmdResp(int timeoutMsec);
    void flushCmdResp();
    void write(const std::vector<quint8> &data);
    inline void write(const QByteArray &data)
    {
        std::vector<quint8> dataVec(reinterpret_cast<const quint8 *>(data.begin()), reinterpret_cast<const quint8 *>(data.end()));
        write(dataVec);
    }

    bool isPromptReady();
    bool waitPromptReady(int timeoutMsec);
    void setPacketLog(bool enable);
    void setSerialLog(bool enable);
signals:
    void initTask();
    void queueWrite(std::vector<quint8> data);
private:
    constexpr static const uchar EOL = '\r';
    constexpr static const int READ_POLL_INTERVAL_MSEC = 20;

    IoTask mTask;
    QThread mThread;
    QTimer mReadPollTimer;
};

/*!
 * \brief ELM327 I/O thread class
 *
 * Reads input, discards zero bytes (which ELM docs say can sometimes be inserted in error),
 * packages completed lines that appear to be CAN frames and places them in the receive queue.
 * Lines that are not packets and not empty are placed in the command response queue, and command prompts from the ELM327
 * (indicating readiness to receive commands) set the prompt-ready condition.
 */


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
    virtual OpResult setPacketLog(bool enable);
    virtual bool hasReliableTx();
private:
    OpResult doSetFilter(const Filter & filt);
    OpResult setRxTimeout(quint32 usec);

    static constexpr quint32 SEND_TIMEOUT_US = 100000;
    static constexpr quint32 ENOBUFS_WAIT_US = 100;
    static constexpr quint32 MAX_RECV_FRAMES = 1024;

    int mSocket;
    boost::optional<SlaveId> mSlaveAddr;
    Filter mFilter;
    bool mPacketLog;
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
