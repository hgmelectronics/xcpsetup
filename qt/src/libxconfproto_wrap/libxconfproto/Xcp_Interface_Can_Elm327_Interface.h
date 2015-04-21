#ifndef XCP_INTERFACE_CAN_ELM327_INTERFACE_H
#define XCP_INTERFACE_CAN_ELM327_INTERFACE_H

#include "libxconfproto_global.h"
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
namespace Elm327
{

class LIBXCONFPROTOSHARED_EXPORT Exception : public ::SetupTools::Xcp::Interface::Exception {};

class LIBXCONFPROTOSHARED_EXPORT UnexpectedResponse : public Exception {};

class LIBXCONFPROTOSHARED_EXPORT NoResponse : public UnexpectedResponse {};

class LIBXCONFPROTOSHARED_EXPORT SerialError : public Exception {};

class LIBXCONFPROTOSHARED_EXPORT ConfigError : public Exception {};

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

class LIBXCONFPROTOSHARED_EXPORT Io : public QObject
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
 * \brief Implementation of CanInterface for the ELM327/STN1110
 */
class LIBXCONFPROTOSHARED_EXPORT Interface : public ::SetupTools::Xcp::Interface::Can::Interface
{
    Q_OBJECT
public:
    Interface(QObject *parent = NULL);
    Interface(const QSerialPortInfo portInfo, QObject *parent = NULL);
    virtual ~Interface();
    virtual OpResult setup(const QSerialPortInfo *portInfo = NULL);
    virtual OpResult teardown();
    virtual OpResult connect(SlaveId addr);                      //!< Connect to a slave - allows reception of packets only from its result ID, stores its command ID for use when sending packets with Transmit()
    virtual OpResult disconnect();                                  //!< Disconnect from the slave - allows reception of packets from any ID, disallows use of Transmit() since there is no ID set for it to use
    virtual OpResult transmit(const std::vector<quint8> & data);             //!< Send one XCP packet to the slave
    virtual OpResult transmitTo(const std::vector<quint8> & data, Id id); //!< Send one CAN frame to an arbitrary ID
    virtual OpResult receiveFrames(int timeoutMsec, std::vector<Frame> &out, const Filter filter = Filter(), bool (*validator)(const Frame &) = NULL);
    virtual OpResult clearReceived();
    virtual OpResult setBitrate(int bps);                           //!< Set the bitrate used on the interface
    virtual OpResult setFilter(Filter filt);                     //!< Set the CAN filter used on the interface
    void setSerialLog(bool on);
    double elapsedSecs();
    virtual OpResult setPacketLog(bool enable);
    virtual bool hasReliableTx();
private:
    enum class CheckOk { No, Yes };

    OpResult runCmdWithCheck(const std::vector<quint8> &cmd, CheckOk checkOkPolicy = CheckOk::Yes);
    inline OpResult runCmdWithCheck(const QByteArray &cmd, CheckOk checkOkPolicy = CheckOk::Yes)
    {
        std::vector<quint8> cmdVec(reinterpret_cast<const quint8 *>(cmd.begin()), reinterpret_cast<const quint8 *>(cmd.end()));
        return runCmdWithCheck(cmdVec, checkOkPolicy);
    }
    inline OpResult runCmdWithCheck(const char *cmd, CheckOk checkOkPolicy = CheckOk::Yes)
    {
        std::vector<quint8> cmdVec(strlen(cmd));
        std::copy(cmd, cmd + strlen(cmd), reinterpret_cast<char *>(cmdVec.data()));
        return runCmdWithCheck(cmdVec, checkOkPolicy);
    }
    OpResult runCmdCheckResp(const std::vector<quint8> &cmd, const std::vector<quint8> &respSubstr, int timeoutMsec);
    inline OpResult runCmdCheckResp(const QByteArray &cmd, const QByteArray &respSubstr, int timeoutMsec)
    {
        std::vector<quint8> cmdVec(reinterpret_cast<const quint8 *>(cmd.begin()), reinterpret_cast<const quint8 *>(cmd.end()));
        std::vector<quint8> respSubstrVec(reinterpret_cast<const quint8 *>(respSubstr.begin()), reinterpret_cast<const quint8 *>(respSubstr.end()));
        return runCmdCheckResp(cmdVec, respSubstrVec, timeoutMsec);
    }

    OpResult doSetFilter(const Filter & filt);
    OpResult updateBitrateTxType();
    bool calcBitrateParams(int &divisor, bool &useOptTqPerBit);

    constexpr static const int TIMEOUT_MSEC = 200;
    constexpr static const int FINDBAUD_TIMEOUT_MSEC = 50;
    constexpr static const int FINDBAUD_ATTEMPTS = 3;
    constexpr static const int BAUD_RECOVERY_TIMEOUT_MSEC = 500;
    constexpr static const int SWITCHBAUD_TIMEOUT_MSEC = 1280;
    constexpr static const int SWITCHBAUD_DELAY_MSEC = 25;
    constexpr static const int POSSIBLE_BAUDRATES [] = { 500000, 115200, 38400, 9600, 230400, 460800, 57600, 28800, 14400, 4800, 2400, 1200 };
    constexpr static const int DESIRED_BAUDRATE = 500000;
    constexpr static const double BRG_HZ = 4000000;

    constexpr static const double CAN_TQ_CLOCK_HZ = 4000000;
    constexpr static const int STD_TQ_PER_BIT = 8;
    constexpr static const int OPT_TQ_PER_BIT = 7;
    constexpr static const double CAN_BITRATE_TOL = 0.001;

    QSerialPortInfo *mPortInfo;
    SerialPort *mPort;
    Io *mIo;
    bool mIntfcIsStn;

    boost::optional<int> mBitrate;
    int mBitrateDivisor;
    bool mOptTqPerBit;
    boost::optional<bool> mTxAddrIsStd;
    Filter mFilter;
    boost::optional<int> mCfgdBitrate;
    boost::optional<Id> mCfgdHeaderId;
    boost::optional<bool> mCfgdTxAddrIsStd;
    boost::optional<Filter> mCfgdFilter;
};

class LIBXCONFPROTOSHARED_EXPORT Factory : public ::SetupTools::Xcp::Interface::Can::Factory
{
    Q_OBJECT
    Q_PROPERTY(QString text READ text CONSTANT)
public:
    Factory(QSerialPortInfo info, QObject *parent = 0);
    virtual ~Factory() {}
    virtual SetupTools::Xcp::Interface::Can::Interface *make(QObject *parent = 0);
    virtual QString text();
private:
    QSerialPortInfo mPortInfo;
};

QList<QSerialPortInfo> LIBXCONFPROTOSHARED_EXPORT getPortsAvail();

QList<Factory *> LIBXCONFPROTOSHARED_EXPORT getInterfacesAvail(QObject *parent = 0);

class LIBXCONFPROTOSHARED_EXPORT Registry
{
public:
    static QList<QString> avail();
    static Interface *make(QString uri);
    static QString desc(QString uri);
};

}   // namespace Elm327
}   // namespace Can
}   // namespace Interface
}   // namespace Xcp
}   // namespace SetupTools

#endif // XCP_INTERFACE_CAN_ELM327_INTERFACE_H
