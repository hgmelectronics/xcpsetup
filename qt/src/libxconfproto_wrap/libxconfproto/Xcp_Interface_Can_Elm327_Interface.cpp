#include "Xcp_Interface_Can_Elm327_Interface.h"
#include <algorithm>
#include <QUrl>

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

static const std::vector<quint8> OK_VEC({'O', 'K'});

IoTask::IoTask(SerialPort *port, QObject *parent) :
    QObject(parent),
    mPort(port),
    mPacketLogEnabled(false),
    mPendingTxBytes(0),
    mPromptReady(this),
    mWriteComplete(this)
{
    mWriteComplete.set();
}

void IoTask::init()
{
    connect(mPort, &SerialPort::readyRead, this, &IoTask::portReadyRead);
    connect(mPort, &SerialPort::bytesWritten, this, &IoTask::portBytesWritten);
}

std::vector<Frame> IoTask::getRcvdFrames(int timeoutMsec)
{
    return mRcvdFrameQueue.getAll(timeoutMsec);
}

std::vector<std::vector<quint8> > IoTask::getRcvdCmdResp(int timeoutMsec)
{
    return mRcvdCmdRespQueue.getAll(timeoutMsec);
}

bool IoTask::isPromptReady()
{
    return mPromptReady.isSet();
}

bool IoTask::waitPromptReady(int timeoutMsec)
{
    return mPromptReady.wait(timeoutMsec);
}

void IoTask::waitWriteComplete()
{
    mWriteComplete.wait();
}

void IoTask::clearWriteComplete()
{
    mWriteComplete.clear();
    mPromptReady.clear();
}

void IoTask::portReadyRead()
{
    if(!mPort->bytesAvailable()) // probably fired by the poll timer
        return;
    // Get data from the serial port and put it into mLines (a list of lines, all ending with CR except possibly the last one, which is the line we're receiving right now)
    {
        std::vector<quint8> buffer = mPort->read(mPort->bytesAvailable());
        std::vector<quint8> newLine;
        if(!mLines.empty())
        {
            newLine = mLines[0];
            mLines.pop_back();
        }
        for(uchar c : buffer)
        {
            if(c != '\0')   // Ignore nulls, which ELM documentation says may be emitted in error
            {
                newLine.push_back(c);
                if(c == EOL)
                {
                    mLines.push_back(newLine);
                    newLine.clear();
                }
            }
        }
        if(newLine.size())
            mLines.push_back(newLine);
    }

    // Process lines from mLines, putting any incomplete line that may exist back into mLines
    std::vector<std::vector<quint8> > incompleteLines;
    for(std::vector<quint8> & line : mLines)
    {
        //qDebug() << mPort->elapsedSecs() << "ELM327 IO line" << line.toPercentEncoding();
        if(*(line.end() - 1) == EOL)
        {
            line.pop_back();
            if(!line.empty()) {
                if(containsNonHex(line))\
                    mRcvdCmdRespQueue.put(line);
                else
                {
                    Frame frame;
                    size_t idLen;
                    if(line.size() % 2 == 1)
                    {
                        frame.id.type = Id::Type::Std;
                        idLen = 3;
                    }
                    else
                    {
                        frame.id.type = Id::Type::Ext;
                        idLen = 8;
                    }

                    if(line.size() >= idLen)
                    {
                        frame.id.addr = QByteArray(reinterpret_cast<char *>(line.data()), idLen).toUInt(NULL, 16);
                        QByteArray dataArr(QByteArray::fromHex(QByteArray(reinterpret_cast<char *>(line.data() + idLen), line.size() - idLen)));
                        frame.data = std::vector<quint8>(reinterpret_cast<quint8 *>(dataArr.data()), reinterpret_cast<quint8 *>(dataArr.data() + dataArr.size()));
                        mRcvdFrameQueue.put(frame);
                    }
                    else
                        mRcvdCmdRespQueue.put(line);    // too short to be valid

                }
            }
        }
        else
        {
            if(line.size() == 1 && line[0] == '>')
            {
#ifdef SPINWAIT
                QElapsedTimer promptTimer;
                promptTimer.start();
                while(promptTimer.nsecsElapsed() < (PROMPT_DELAY_USEC * 1000)) {} // spin
#else
                QThread::usleep(PROMPT_DELAY_USEC);
#endif

                mPromptReady.set();
            }
            else
                incompleteLines.push_back(line);
        }
    }
    mLines.swap(incompleteLines);
}

void IoTask::write(std::vector<quint8> data)
{
    {
        QMutexLocker locker(&mPendingTxBytesMutex);
        mPendingTxBytes += data.size();
    }
    mPort->write(data.data(), data.size());
}

void IoTask::portBytesWritten(qint64 bytes)
{
    QMutexLocker locker(&mPendingTxBytesMutex);
    mPendingTxBytes = std::max(mPendingTxBytes - bytes, qint64(0)); // coerce since first call to this function always seems to be a spurious one with bytes==1
    if(mPendingTxBytes == 0)
        mWriteComplete.set();
}

void IoTask::setSerialLog(bool on)
{
    mPort->setLogging(on);
}

Io::Io(SerialPort *port, QObject *parent) :
    QObject(parent),
    mTask(port)
{
    mTask.moveToThread(&mThread);
    port->moveToThread(&mThread);
    mThread.start();
    connect(this, &Io::initTask, &mTask, &IoTask::init, Qt::QueuedConnection);
    connect(this, &Io::queueWrite, &mTask, &IoTask::write, Qt::QueuedConnection);
    connect(&mReadPollTimer, &QTimer::timeout, &mTask, &IoTask::portReadyRead, Qt::QueuedConnection);
    emit initTask();
    mReadPollTimer.setSingleShot(false);
    mReadPollTimer.start(READ_POLL_INTERVAL_MSEC);
}

Io::~Io()
{
    mThread.quit();
    mThread.wait();
}

void Io::sync()
{
    mTask.waitWriteComplete();
}

OpResult Io::syncAndGetPrompt(int timeoutMsec, int retries)
{
    sync();
    if(isPromptReady())
        return OpResult::Success;

    for(int i = 0; i < retries; ++i)
    {
        queueWrite({'\r'});
        if(waitPromptReady(timeoutMsec))
            return OpResult::Success;
    }

    qCritical("Failed to obtain prompt from ELM327");
    return OpResult::IntfcNoResponse;
}

std::vector<Frame> Io::getRcvdFrames(int timeoutMsec)
{
    return mTask.getRcvdFrames(timeoutMsec);
}

std::vector<std::vector<quint8> > Io::getRcvdCmdResp(int timeoutMsec)
{
    return mTask.getRcvdCmdResp(timeoutMsec);
}

void Io::flushCmdResp()
{
    mTask.getRcvdCmdResp(0);    // ignore the return value -> it gets destroyed
}

void Io::write(const std::vector<quint8> &data)
{
    mTask.clearWriteComplete();
    emit queueWrite(data);
    mTask.waitWriteComplete();
}

bool Io::isPromptReady()
{
    return mTask.isPromptReady();
}

bool Io::waitPromptReady(int timeoutMsec)
{
    return mTask.waitPromptReady(timeoutMsec);
}

void Io::setSerialLog(bool on)
{
	mTask.setSerialLog(on);
}

constexpr int Interface::POSSIBLE_BAUDRATES[];

Interface::Interface(QObject *parent) :
    ::SetupTools::Xcp::Interface::Can::Interface(parent),
    mPortInfo(NULL),
    mPort(NULL)
{}

Interface::Interface(const QSerialPortInfo portInfo, QObject *parent) :
    ::SetupTools::Xcp::Interface::Can::Interface(parent),
    mPortInfo(new QSerialPortInfo(portInfo)),
    mPort(NULL)
{}

Interface::~Interface() {}

OpResult Interface::setup(const QSerialPortInfo *portInfo)
{
    if(portInfo)
        mPort = new SerialPort(*portInfo);
    else if(mPortInfo)
        mPort = new SerialPort(*mPortInfo);
    else
        return OpResult::InvalidOperation;

    if(!mPort->open(QIODevice::ReadWrite))
    {
        qCritical("Failed to open serial port");
        return OpResult::IntfcIoError;
    }
    mIo = new Io(mPort, this);
    bool foundBaud = false;
    for(auto baud : POSSIBLE_BAUDRATES)
    {
        qDebug() << "Trying" << baud << "baud";
        mPort->setBaudRate(baud);  // forcibly cast into BaudRateType since Windows actually can handle 500k

        if(mIo->syncAndGetPrompt(FINDBAUD_TIMEOUT_MSEC, FINDBAUD_ATTEMPTS) != OpResult::Success)
            continue;

        if(baud == DESIRED_BAUDRATE)
        {
            foundBaud = true;
            break;
        }
        else
        {
            // try to switch baudrate to desired

            mIo->getRcvdCmdResp(0); // dump anything received during initial baudrate detect

            {
                QByteArray cmd = QString("ATBRD%1\r").arg(qRound(BRG_HZ / DESIRED_BAUDRATE), 2, 16, QChar('0')).toLatin1();
                if(runCmdCheckResp(cmd, QByteArray("OK"), TIMEOUT_MSEC) != OpResult::Success)
                {
                    // Device does not allow baudrate change, but we found its operating baudrate
                    foundBaud = true;
                    break;
                }
            }

            mPort->setBaudRate(DESIRED_BAUDRATE);
            qDebug() << "Switched to" << mPort->baudRate() << "baud";

            if(runCmdCheckResp(QByteArray("\r"), QByteArray("ELM327"), TIMEOUT_MSEC) != OpResult::Success)
            {
                // Baudrate switch unsuccessful, try to recover
                mPort->setBaudRate(baud);
                if(mIo->syncAndGetPrompt(BAUD_RECOVERY_TIMEOUT_MSEC) == OpResult::Success)
                {
                    foundBaud = true;
                    break;
                }
                else
                {
                    qCritical("Failed to recover from unsuccessful ELM327 baudrate switch");
                    return OpResult::IntfcUnexpectedResponse;
                }
            }

            // Baudrate switch successful, send a CR to confirm we're on board
            if(runCmdCheckResp(QByteArray("\r"), QByteArray("OK"), TIMEOUT_MSEC) != OpResult::Success)
            {
                qCritical("Unexpected response from ELM327 when confirming UART baudrate switch");
                return OpResult::IntfcUnexpectedResponse;
            }

            foundBaud = true;
            break;
        }
    }
    if(!foundBaud) {
        qCritical("Failed to find ELM327 UART baudrate");
        return OpResult::IntfcIoError;
    }
    qDebug() << "Established communication at" << mPort->baudRate() << "baud";

    RETURN_FAIL(runCmdWithCheck("ATWS", CheckOk::No))   // Software reset
    RETURN_FAIL(runCmdWithCheck("ATE0"))                // Turn off echo
    RETURN_FAIL(runCmdWithCheck("ATL0"))                // Turn off newlines
    RETURN_FAIL(runCmdWithCheck("ATS0"))                // Turn off spaces
    RETURN_FAIL(runCmdWithCheck("ATH1"))                // Turn on headers
    RETURN_FAIL(runCmdWithCheck("ATAL"))               // Allow full length messages

    mIntfcIsStn = (runCmdWithCheck("STFCP") == OpResult::Success); // ELM327s will error out
    return OpResult::Success;
}

OpResult Interface::teardown()
{
    delete mIo;
    mIo = NULL;

    mPort->close();
    delete mPort;
    mPort = NULL;

    return OpResult::Success;
}

OpResult Interface::connect(SlaveId addr)
{
    Q_ASSERT(mPort);
    OpResult res = doSetFilter(ExactFilter(addr.res));
    if(res == OpResult::Success)
    {
        mSlaveAddr = addr;
        return OpResult::Success;
    }
    else
    {
        mSlaveAddr.reset();
        return res;
    }
}

OpResult Interface::disconnect()
{
    Q_ASSERT(mPort);
    mSlaveAddr.reset();
    return doSetFilter(mFilter);
}

OpResult Interface::transmit(const std::vector<quint8> & data)
{
    Q_ASSERT(mPort);
    Q_ASSERT(mSlaveAddr);
    return transmitTo(data, mSlaveAddr.get().cmd);
}

OpResult Interface::transmitTo(const std::vector<quint8> & data, Id id)
{
    Q_ASSERT(mPort);
    Q_ASSERT(mCfgdBitrate && mCfgdFilter);
    mTxAddrIsStd = (id.type == Id::Type::Std);

    RETURN_FAIL(updateBitrateTxType())

    if(!mCfgdHeaderId || mCfgdHeaderId.get() != id)
    {
        if(id.type == Id::Type::Ext)
        {
            RETURN_FAIL(runCmdWithCheck(QString("ATCP%1").arg((id.addr >> 24) & 0x1F, 2, 16, QChar('0')).toLatin1()))
            RETURN_FAIL(runCmdWithCheck(QString("ATSH%1").arg(id.addr & 0xFFFFFF, 6, 16, QChar('0')).toLatin1()))
        }
        else
        {
            RETURN_FAIL(runCmdWithCheck(QString("ATSH%1").arg(id.addr & 0x7FF, 3, 16, QChar('0')).toLatin1()))
        }
        mCfgdHeaderId = id;
    }
    else
    {
        RETURN_FAIL(mIo->syncAndGetPrompt(TIMEOUT_MSEC))   // Not synchronized by calling _runCmdWithCheck(), so do it here
    }

    if(mPacketLogEnabled)
    {
        Frame frame(id, data);
        qDebug() << QString(frame);
    }

    mIo->write(QByteArray(reinterpret_cast<const char *>(data.data()), data.size()).toHex() + "\r");
    return OpResult::Success;
}

OpResult Interface::receiveFrames(int timeoutMsec, std::vector<Frame> &out, const Filter filter, bool (*validator)(const Frame &))
{
    Q_ASSERT(mCfgdBitrate && mCfgdFilter);

    QElapsedTimer timer;
    timer.start();

    qint64 timeoutNsec = qint64(timeoutMsec) * 1000000;
    do
    {
        int queueReadTimeout = std::max(timeoutMsec - int(timer.elapsed()), 0);

        for(const Frame & newFrame : mIo->getRcvdFrames(queueReadTimeout))
        {
            if(filter.Matches(newFrame.id) &&
                    (!validator || validator(newFrame)))
                out.push_back(newFrame);
        }
    } while(timer.nsecsElapsed() <= timeoutNsec && !out.size());

    return OpResult::Success;
}

OpResult Interface::clearReceived()
{
    mIo->getRcvdFrames(0);
    return OpResult::Success;
}

OpResult Interface::setBitrate(int bps)
{
    mBitrate = bps;
    return updateBitrateTxType();
}
OpResult Interface::setFilter(Filter filt)
{
    mFilter = filt;
    return doSetFilter(filt);
}
void LIBXCONFPROTOSHARED_EXPORT Interface::setSerialLog(bool on)
{
    mIo->setSerialLog(on);
}
OpResult LIBXCONFPROTOSHARED_EXPORT Interface::setPacketLog(bool enable)
{
    mPacketLogEnabled = enable;
    return OpResult::Success;
}
double Interface::elapsedSecs()
{
    return mPort->elapsedSecs();
}

OpResult Interface::runCmdWithCheck(const std::vector<quint8> &cmd, CheckOk checkOkPolicy)
{
    RETURN_FAIL(mIo->syncAndGetPrompt(TIMEOUT_MSEC))
    mIo->flushCmdResp();
    {
        std::vector<quint8> tx(cmd);
        tx.push_back('\r');
        mIo->write(tx);
    }
    if(!mIo->waitPromptReady(TIMEOUT_MSEC))
    {
        std::vector<quint8> cmdNt(cmd);
        cmdNt.push_back('\0');
        qCritical("No prompt from ELM327 after executing %s", cmdNt.data());
        return OpResult::IntfcNoResponse;
    }
    if(checkOkPolicy == CheckOk::Yes)
    {
        for(const std::vector<quint8> & response : mIo->getRcvdCmdResp(0))
        {
            if(std::search(response.begin(), response.end(), OK_VEC.begin(), OK_VEC.end()) != response.end())
                return OpResult::Success;
        }
        std::vector<quint8> cmdNt(cmd);
        cmdNt.push_back('\0');
        qCritical("No OK from ELM327 after executing %s", cmdNt.data());
        return OpResult::IntfcNoResponse;
    }
    return OpResult::Success;
}
OpResult Interface::runCmdCheckResp(const std::vector<quint8> &cmd, const std::vector<quint8> &respSubstr, int timeoutMsec)
{
    Q_ASSERT(cmd.size());
    mIo->write(cmd);
    QElapsedTimer cmdTimer;
    cmdTimer.start();
    while(1)
    {
        int timeout = timeoutMsec - int(cmdTimer.elapsed());
        if(timeout < 0)
            break;

        std::vector<std::vector<quint8> > cmdResp = mIo->getRcvdCmdResp(timeout);
        for(const std::vector<quint8> &resp : cmdResp)
        {
            if(std::search(resp.begin(), resp.end(), respSubstr.begin(), respSubstr.end()) != resp.end())
                return OpResult::Success;
        }
    }
    return OpResult::IntfcNoResponse;
}
OpResult Interface::doSetFilter(const Filter & filter)
{
    QString stdFilter = QString("%1").arg(filter.filt.addr & 0x7FF, 3, 16, QChar('0'));
    QString stdMask = QString("%1").arg(filter.maskId & 0x7FF, 3, 16, QChar('0'));
    QString extFilter = QString("%1").arg(filter.filt.addr & 0x1FFFFFFF, 8, 16, QChar('0'));
    QString extMask = QString("%1").arg(filter.maskId & 0x1FFFFFFF, 8, 16, QChar('0'));
    if(mIntfcIsStn)
    {
        RETURN_FAIL(runCmdWithCheck("STFCFC"))
        RETURN_FAIL(runCmdWithCheck("STFCP"))
        RETURN_FAIL(runCmdWithCheck("STFCB"))
        RETURN_FAIL(runCmdWithCheck("ATCF00000000"))
        RETURN_FAIL(runCmdWithCheck("ATCM00000000"))
        if(!filter.maskEff || filter.filt.type == Id::Type::Std)
            RETURN_FAIL(runCmdWithCheck(QString("STFAP%1,%2").arg(stdFilter, stdMask).toLatin1()))
        if(!filter.maskEff || filter.filt.type == Id::Type::Ext)
            RETURN_FAIL(runCmdWithCheck(QString("STFAP%1,%2").arg(extFilter, extMask).toLatin1()))
    }
    else
    {
        // ELM327 does not support filters that can distinguish by EFF, so ignore it
        RETURN_FAIL(runCmdWithCheck(QString("ATCF%1").arg(extFilter).toLatin1()))
        RETURN_FAIL(runCmdWithCheck(QString("ATCM%1").arg(extMask).toLatin1()))
    }
    if(mIntfcIsStn)
        mIo->write("STM\r");
    else
        mIo->write("ATMA\r");
    mCfgdFilter = filter;
    return OpResult::Success;
}
bool Interface::calcBitrateParams(int &divisor, bool &useOptTqPerBit)
{
    int newDivisor;

    newDivisor = qRound(CAN_TQ_CLOCK_HZ / (mBitrate.get() * STD_TQ_PER_BIT));
    double calcBitrate = CAN_TQ_CLOCK_HZ / (newDivisor * STD_TQ_PER_BIT);
    double calcBitrateRatio = calcBitrate / mBitrate.get();
    if(abs(calcBitrateRatio - 1) < CAN_BITRATE_TOL)
    {
        divisor = newDivisor;
        useOptTqPerBit = false;
        return true;
    }
    else
    {
        newDivisor = qRound(CAN_TQ_CLOCK_HZ / (mBitrate.get() * OPT_TQ_PER_BIT));
        calcBitrate = CAN_TQ_CLOCK_HZ / (divisor * OPT_TQ_PER_BIT);
        if(abs(calcBitrate / mBitrate.get() - 1) < CAN_BITRATE_TOL)
        {
            divisor = newDivisor;
            useOptTqPerBit = true;
            return true;
        }
        else
            return false;
    }
}
OpResult Interface::updateBitrateTxType()
{
    Q_ASSERT(mBitrate);

    bool newBitrate = (!mCfgdBitrate || mCfgdBitrate.get() != mBitrate.get());
    bool newAddrType = (mTxAddrIsStd && (!mCfgdTxAddrIsStd || mCfgdTxAddrIsStd.get() != mTxAddrIsStd.get()));

    if(newBitrate || newAddrType)
    {
        int newDivisor;
        bool newOptTqPerBit;
        if(calcBitrateParams(newDivisor, newOptTqPerBit))
        {
            mBitrateDivisor = newDivisor;
            mOptTqPerBit = newOptTqPerBit;
        }
        else
        {
            qCritical("CAN bitrate %d cannot be generated by ELM327", mBitrate.get());
            return OpResult::IntfcConfigError;
        }

        quint8 canOptions = 0x60;
        if(mTxAddrIsStd && mTxAddrIsStd.get())
            canOptions |= 0x80;
        if(mOptTqPerBit)
            canOptions |= 0x10;

        // STN1110 requires that protocol not be set to B when altering B settings
        RETURN_FAIL(runCmdWithCheck("ATSP1"))
        RETURN_FAIL(runCmdWithCheck(QString("ATPB%1%2").arg(canOptions, 2, 16, QChar('0')).arg(mBitrateDivisor, 2, 16, QChar('0')).toLatin1()))
        RETURN_FAIL(runCmdWithCheck("ATSPB"))

        RETURN_FAIL(runCmdWithCheck("ATAT0"))               // Disable adaptive timing
        RETURN_FAIL(runCmdWithCheck("ATSTff"))              // Set maximum timeout = 1.02 s
        RETURN_FAIL(runCmdWithCheck("ATCSM0", CheckOk::No)) // Try to set silent monitoring; some knockoff ELM327s don't support this command but seem to work OK anyway

        if(mSlaveAddr)
            RETURN_FAIL(doSetFilter(ExactFilter(mSlaveAddr.get().res)))
        else
            RETURN_FAIL(doSetFilter(mFilter))
        mCfgdBitrate = mBitrate.get();
        if(mTxAddrIsStd)
            mCfgdTxAddrIsStd = mTxAddrIsStd.get();
    }
    return OpResult::Success;
}

Factory::Factory(QSerialPortInfo info, QObject *parent) :
    SetupTools::Xcp::Interface::Can::Factory(parent),
    mPortInfo(info)
{}

SetupTools::Xcp::Interface::Can::Interface *Factory::make(QObject *parent)
{
    return new Interface(mPortInfo, parent);
}
QString Factory::text()
{
    return "ELM327 on " + mPortInfo.portName() + " (" + mPortInfo.description() + ")";
}

QList<QSerialPortInfo> getPortsAvail()
{
    QList<QSerialPortInfo> ret;
    for(const auto &portInfo : QSerialPortInfo::availablePorts())
    {
        if(!portInfo.isBusy()) {
            QSerialPort port(portInfo);
            if(port.open(QIODevice::ReadWrite)) {
                port.close();
                ret.append(portInfo);
            }
        }
    }
    return ret;
}

QList<Factory *> getInterfacesAvail(QObject *parent)
{
    QList<Factory *> ret;
    for(QSerialPortInfo portInfo : getPortsAvail())
        ret.append(new Factory(portInfo, parent));
    return ret;
}

QList<QString> Registry::avail()
{
    QList<QString> ret;
    for(QSerialPortInfo portInfo : getPortsAvail())
        ret.append(QString("elm327:%1?bitrate=250000&filter=00000000:00000000").arg(portInfo.portName()));
    return ret;
}

Interface *Registry::make(QString uriStr)
{
    QUrl uri(uriStr);
    if(QString::compare(uri.scheme(), "elm327", Qt::CaseInsensitive) != 0)
        return NULL;
    QUrlQuery uriQuery(uri.query());

    QSerialPortInfo portInfo(uri.path());
    if(portInfo.isBusy() || portInfo.isNull())
        return NULL;

    Interface *intfc = new Interface();
    if(intfc->setup(&portInfo) != OpResult::Success)
    {
        delete intfc;
        return NULL;
    }

    bool setBitrate = false;
    QString bitrateStr = uriQuery.queryItemValue("bitrate");
    int bitrate = bitrateStr.toInt(&setBitrate);
    if(setBitrate)
    {
        if(intfc->setBitrate(bitrate) != OpResult::Success)
        {
            delete intfc;
            return NULL;
        }
    }

    return intfc;
}

QString Registry::desc(QString uriStr)
{
    QUrl uri(uriStr);
    if(QString::compare(uri.scheme(), "elm327", Qt::CaseInsensitive) != 0)
        return QString("");

    return QString("ELM327/STN1110 on %1").arg(uri.path());
}

}   // namespace Elm327
}   // namespace Can
}   // namespace Interface
}   // namespace Xcp
}   // namespace SetupTools
