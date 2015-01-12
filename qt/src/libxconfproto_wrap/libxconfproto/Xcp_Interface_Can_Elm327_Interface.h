#ifndef XCP_INTERFACE_CAN_ELM327_INTERFACE_H
#define XCP_INTERFACE_CAN_ELM327_INTERFACE_H

#include <QObject>
#include <boost/optional.hpp>
#include <boost/range/iterator_range.hpp>
#include <memory>
#include <QtSerialPort/QtSerialPort>
#include <QThread>
#include <QtGlobal>
#include "Xcp_Interface_Can_Interface.h"
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

class Exception : public ::SetupTools::Xcp::Interface::Exception {};

class UnexpectedResponse : public Exception {};

class NoResponse : public UnexpectedResponse {};

class SerialError : public Exception {};

class ConfigError : public Exception {};

class IoTask : public QObject
{
    Q_OBJECT
public:
    IoTask(SerialPort &port, QObject *parent = NULL);
    void init();
    std::vector<Frame> getRcvdFrames(int timeoutMsec);
    std::vector<std::vector<quint8> > getRcvdCmdResp(int timeoutMsec);
    bool isPromptReady();
    bool waitPromptReady(int timeoutMsec);
    void waitWriteComplete();
    void clearWriteComplete();
public slots:
    void portReadyRead();
    void queueWrite(std::vector<quint8> data, bool recoveryRequired);
    void recoveryTimerDone();
private:
    static constexpr uchar EOL = '\r';
    static constexpr int ELM327_RECOVERY_MSEC = 1;

    void doWrite(const std::vector<quint8> &data);

    SerialPort &mPort;

    std::vector<std::vector<quint8> > mLines;
    PythonicQueue<Frame> mRcvdFrameQueue;
    PythonicQueue<std::vector<quint8> > mRcvdCmdRespQueue;
    std::list<std::vector<quint8> > mTransmitQueue;
    PythonicEvent mPromptReady, mWriteComplete;
    QTimer mRecoveryTimer;
};

class Io : public QObject
{
    Q_OBJECT
public:
    Io(SerialPort &port, QObject *parent = NULL);
    ~Io();
    void sync();
    void syncAndGetPrompt(int timeoutMsec, int retries = 5);
    std::vector<Frame> getRcvdFrames(int timeoutMsec);
    std::vector<std::vector<quint8> > getRcvdCmdResp(int timeoutMsec);
    void flushCmdResp();
    void write(const std::vector<quint8> &data, bool recoveryRequired);
    inline void write(const QByteArray &data, bool recoveryRequired)
    {
        std::vector<quint8> dataVec(reinterpret_cast<const quint8 *>(data.begin()), reinterpret_cast<const quint8 *>(data.end()));
        write(dataVec, recoveryRequired);
    }

    bool isPromptReady();
    bool waitPromptReady(int timeoutMsec);
signals:
    void queueWrite(std::vector<quint8> data, bool recoveryRequired);
private:
    static constexpr uchar EOL = '\r';

    IoTask mTask;
    QThread mThread;
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
    Interface(const QSerialPortInfo & portInfo, bool serialLog = false, QObject *parent = NULL);
    virtual ~Interface();
    virtual void connect(SlaveId addr);                      //!< Connect to a slave - allows reception of packets only from its result ID, stores its command ID for use when sending packets with Transmit()
    virtual void disconnect();                                  //!< Disconnect from the slave - allows reception of packets from any ID, disallows use of Transmit() since there is no ID set for it to use
    virtual void transmitTo(const std::vector<quint8> & data, Id id); //!< Send one CAN frame to an arbitrary ID
    virtual std::vector<Frame> receiveFrames(int timeoutMsec, const Filter filter = Filter(), bool (*validator)(const Frame &) = NULL);
    virtual void setBitrate(int bps);                           //!< Set the bitrate used on the interface
    virtual void setFilter(Filter filt);                     //!< Set the CAN filter used on the interface
    void setSerialLog(bool on);
    double elapsedSecs();
private:
    enum class CheckOk { No, Yes };

    void runCmdWithCheck(const std::vector<quint8> &cmd, CheckOk checkOkPolicy = CheckOk::Yes);
    inline void runCmdWithCheck(const QByteArray &cmd, CheckOk checkOkPolicy = CheckOk::Yes)
    {
        std::vector<quint8> cmdVec(reinterpret_cast<const quint8 *>(cmd.begin()), reinterpret_cast<const quint8 *>(cmd.end()));
        runCmdWithCheck(cmdVec, checkOkPolicy);
    }
    inline void runCmdWithCheck(const char *cmd, CheckOk checkOkPolicy = CheckOk::Yes)
    {
        std::vector<quint8> cmdVec(strlen(cmd));
        std::copy(cmd, cmd + strlen(cmd), reinterpret_cast<char *>(cmdVec.data()));
        runCmdWithCheck(cmdVec, checkOkPolicy);
    }

    void doSetFilter(const Filter & filt);
    void updateBitrateTxType();
    bool calcBitrateParams(int &divisor, bool &useOptTqPerBit);

    static constexpr int TIMEOUT_MSEC = 200;
    static constexpr int FINDBAUD_TIMEOUT_MSEC = 50;
    static constexpr int FINDBAUD_ATTEMPTS = 3;
    static constexpr int SWITCHBAUD_TIMEOUT_MSEC = 1280;
    static constexpr int SWITCHBAUD_DELAY_MSEC = 25;
    static constexpr int POSSIBLE_BAUDRATES [] = { 500000, 115200, 38400, 9600, 230400, 460800, 57600, 28800, 14400, 4800, 2400, 1200 };
    static constexpr int DESIRED_BAUDRATE = 500000;
    static constexpr double BRG_HZ = 4000000;

    static constexpr double CAN_TQ_CLOCK_HZ = 4000000;
    static constexpr int STD_TQ_PER_BIT = 8;
    static constexpr int OPT_TQ_PER_BIT = 7;
    static constexpr double CAN_BITRATE_TOL = 0.001;

    SerialPort mPort;
    QSharedPointer<Io> mIo;
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

}   // namespace Elm327
}   // namespace Can
}   // namespace Interface
}   // namespace Xcp
}   // namespace SetupTools

#endif // XCP_INTERFACE_CAN_ELM327_INTERFACE_H
