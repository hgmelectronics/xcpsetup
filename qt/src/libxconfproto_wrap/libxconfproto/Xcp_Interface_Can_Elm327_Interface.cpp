#include "Xcp_Interface_Can_Elm327_Interface.h"
#include <algorithm>

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

IoTask::IoTask(SerialPort &port, QObject *parent) :
    QObject(parent),
    mPort(port),
    mPacketLogEnabled(false),
    mPendingTxBytes(0),
    mPromptReady(this),
    mWriteComplete(this)
{
    mPromptReady.set();
    mWriteComplete.set();
}

void IoTask::init()
{
    connect(&mPort, &SerialPort::readyRead, this, &IoTask::portReadyRead);
    connect(&mPort, &SerialPort::bytesWritten, this, &IoTask::portBytesWritten);
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
    if(!mPort.bytesAvailable()) // probably fired by the poll timer
        return;
    // Get data from the serial port and put it into mLines (a list of lines, all ending with CR except possibly the last one, which is the line we're receiving right now)
    {
        std::vector<quint8> buffer = mPort.read(mPort.bytesAvailable());
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
        //qDebug() << mPort.elapsedSecs() << "ELM327 IO line" << line.toPercentEncoding();
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
                QThread::usleep(PROMPT_DELAY_USEC);
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
    mPort.write(data.data(), data.size());
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
	mPort.setLogging(on);
}

Io::Io(SerialPort &port, QObject *parent) :
    QObject(parent),
    mTask(port)
{
    mTask.moveToThread(&mThread);
    port.moveToThread(&mThread);
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

void Io::syncAndGetPrompt(int timeoutMsec, int retries)
{
    sync();
    if(isPromptReady())
        return;

    for(int i = 0; i < retries; ++i)
    {
        queueWrite({'\r'});
        if(waitPromptReady(timeoutMsec))
            return;
    }

    qCritical("Failed to obtain prompt from ELM327");
    throw NoResponse();
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

Interface::Interface(const QString & portName, QObject *parent) :
    ::SetupTools::Xcp::Interface::Can::Interface(parent),
    mPort(portName),
    mIntfcIsStn(false)
{
    if(!mPort.open(QIODevice::ReadWrite))
    {
        qCritical("Failed to open serial port");
        throw SerialError();
    }
    bool foundBaud = false;
    for(auto baud : POSSIBLE_BAUDRATES)
    {
        qDebug() << "Trying" << baud << "baud";
        mPort.setBaudRate(BaudRateType(baud));  // forcibly cast into BaudRateType since Windows actually can handle 500k
        mPort.setTimeout(FINDBAUD_TIMEOUT_MSEC);
        mPort.setInterCharTimeout();

        bool commEstablished = false;
        for(int i = 0; i < FINDBAUD_ATTEMPTS; ++i)
        {
            mPort.fullClear();
            mPort.write("\r");
            std::vector<quint8> findBaudRes = mPort.readGranular(16384);
            if(findBaudRes.size() > 0 && *(findBaudRes.end() - 1) == '>')
            {
                commEstablished = true;
                break;
            }
        }
        if(!commEstablished)
            continue;

        if(baud == DESIRED_BAUDRATE)
        {
            foundBaud = true;
            break;
        }
        else
        {
            // try to switch baudrate to desired
            mPort.setTimeout(SWITCHBAUD_TIMEOUT_MSEC);
            mPort.fullClear();
            mPort.write(QString("ATBRD%1\r").arg(qRound(BRG_HZ / DESIRED_BAUDRATE), 2, 16, QChar('0')).toLatin1());
            std::vector<quint8> brdRes(mPort.readGranular(12));
            if(std::search(brdRes.begin(), brdRes.end(), OK_VEC.begin(), OK_VEC.end()) != brdRes.end())
            {
                // Device allows baudrate change, proceed with switch
                mPort.setBaudRate(BaudRateType(DESIRED_BAUDRATE));
                mPort.setInterCharTimeout();
                mPort.fullClear();
                qDebug() << "Switched to" << mPort.baudRate() << "baud";
                std::vector<quint8> switchBaudRes(mPort.readGranular(11));
                static const std::vector<quint8> SWITCH_BAUD_RES_SUBSTR({'E','L','M','3','2','7'});
                if(switchBaudRes.size() >= SWITCH_BAUD_RES_SUBSTR.size()
                        && std::equal(SWITCH_BAUD_RES_SUBSTR.begin(), SWITCH_BAUD_RES_SUBSTR.end(), switchBaudRes.begin()))
                {
                    // Baudrate switch successful, send a CR to confirm we're on board
                    mPort.fullClear();
                    mPort.write("\r");
                    if(mPort.readGranular(2) != OK_VEC)
                    {
                        qCritical("Unexpected response from ELM327 when confirming UART baudrate switch");
                        throw UnexpectedResponse();
                    }
                }
                else
                {
                    // Baudrate switch unsuccessful, try to recover
                    mPort.setBaudRate(BaudRateType(baud));
                    mPort.setInterCharTimeout();

                    mPort.write("\r");
                    mPort.fullClear();
                    std::vector<quint8> recoverRes(mPort.readGranular(1024));
                    if(recoverRes.size() < 1 || *(recoverRes.end() - 1) != '>')
                    {
                        qCritical("Failed to recover from unsuccessful ELM327 baudrate switch");
                        throw UnexpectedResponse();
                    }
                }
                foundBaud = true;
                break;
            }
            else
            {
                // Device does not allow baudrate change, but we found its operating baudrate
                foundBaud = true;
                break;
            }
        }
    }
    if(!foundBaud) {
        qCritical("Failed to find ELM327 UART baudrate");
        throw SerialError();
    }
    qDebug() << "Established communication at" << mPort.baudRate() << "baud";

    mIo = QSharedPointer<Io>(new Io(mPort, this));
    runCmdWithCheck("ATWS", CheckOk::No);   // Software reset
    runCmdWithCheck("ATE0");                // Turn off echo
    runCmdWithCheck("ATL0");                // Turn off newlines
    runCmdWithCheck("ATS0");                // Turn off spaces
    runCmdWithCheck("ATH1");                // Turn on headers
    runCmdWithCheck("ATAL");                // Allow full length messages
    try
    {
        runCmdWithCheck("STFCP");           // See if this is an STN device
        mIntfcIsStn = true;
    }
    catch(UnexpectedResponse) {
        mIntfcIsStn = false;                // ELM327s will error out
    }
}

Interface::~Interface() {}

void Interface::connect(SlaveId addr)
{
    mSlaveAddr = addr;
    doSetFilter(ExactFilter(addr.res));
}

void Interface::disconnect()
{
    mSlaveAddr.reset();
    doSetFilter(mFilter);
}

void Interface::transmit(const std::vector<quint8> & data)
{
    Q_ASSERT(mSlaveAddr);
    transmitTo(data, mSlaveAddr.get().cmd);
}

void Interface::transmitTo(const std::vector<quint8> & data, Id id)
{
    Q_ASSERT(mCfgdBitrate && mCfgdFilter);
    mTxAddrIsStd = (id.type == Id::Type::Std);
    updateBitrateTxType();

    if(!mCfgdHeaderId || mCfgdHeaderId.get() != id)
    {
        if(id.type == Id::Type::Ext)
        {
            runCmdWithCheck(QString("ATCP%1").arg((id.addr >> 24) & 0x1F, 2, 16, QChar('0')).toLatin1());
            runCmdWithCheck(QString("ATSH%1").arg(id.addr & 0xFFFFFF, 6, 16, QChar('0')).toLatin1());
        }
        else
        {
            runCmdWithCheck(QString("ATSH%1").arg(id.addr & 0x7FF, 3, 16, QChar('0')).toLatin1());
        }
        mCfgdHeaderId = id;
    }
    else
    {
        mIo->syncAndGetPrompt(TIMEOUT_MSEC);    // Not synchronized by calling _runCmdWithCheck(), so do it here
    }

    if(mPacketLogEnabled)
    {
        Frame frame(id, data);
        qDebug() << QString(frame);
    }

    mIo->write(QByteArray(reinterpret_cast<const char *>(data.data()), data.size()).toHex() + "\r");
}

std::vector<Frame> Interface::receiveFrames(int timeoutMsec, const Filter filter, bool (*validator)(const Frame &))
{
    Q_ASSERT(mCfgdBitrate && mCfgdFilter);

    QElapsedTimer timer;
    timer.start();

    std::vector<Frame> frames;

    qint64 timeoutNsec = qint64(timeoutMsec) * 1000000;
    do
    {
        int queueReadTimeout = std::max(timeoutMsec - int(timer.elapsed()), 0);

        for(const Frame & newFrame : mIo->getRcvdFrames(queueReadTimeout))
        {
            if(filter.Matches(newFrame.id) &&
                    (!validator || validator(newFrame)))
                frames.push_back(newFrame);
        }
    } while(timer.nsecsElapsed() <= timeoutNsec && !frames.size());

    return frames;
}

void Interface::setBitrate(int bps)
{
    mBitrate = bps;
    updateBitrateTxType();
}
void Interface::setFilter(Filter filt)
{
    mFilter = filt;
    doSetFilter(filt);
}
void LIBXCONFPROTOSHARED_EXPORT Interface::setSerialLog(bool on)
{
    mIo->setSerialLog(on);
}
void LIBXCONFPROTOSHARED_EXPORT Interface::setPacketLog(bool enable)
{
    mPacketLogEnabled = enable;
}
double Interface::elapsedSecs()
{
    return mPort.elapsedSecs();
}

void Interface::runCmdWithCheck(const std::vector<quint8> &cmd, CheckOk checkOkPolicy)
{
    mIo->syncAndGetPrompt(TIMEOUT_MSEC);
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
        throw NoResponse();
    }
    if(checkOkPolicy == CheckOk::Yes)
    {
        bool gotOk = false;
        for(const std::vector<quint8> & response : mIo->getRcvdCmdResp(0))
        {
            if(std::search(response.begin(), response.end(), OK_VEC.begin(), OK_VEC.end()) != response.end())
            {
                gotOk = true;
                break;
            }
        }
        if(!gotOk)
        {
            std::vector<quint8> cmdNt(cmd);
            cmdNt.push_back('\0');
            qCritical("No OK from ELM327 after executing %s", cmdNt.data());
            throw NoResponse();
        }
    }
}
void Interface::doSetFilter(const Filter & filter)
{
    QString stdFilter = QString("%1").arg(filter.filt.addr & 0x7FF, 3, 16, QChar('0'));
    QString stdMask = QString("%1").arg(filter.maskId & 0x7FF, 3, 16, QChar('0'));
    QString extFilter = QString("%1").arg(filter.filt.addr & 0x1FFFFFFF, 8, 16, QChar('0'));
    QString extMask = QString("%1").arg(filter.maskId & 0x1FFFFFFF, 8, 16, QChar('0'));
    if(mIntfcIsStn)
    {
        runCmdWithCheck("STFCFC");
        runCmdWithCheck("STFCP");
        runCmdWithCheck("STFCB");
        runCmdWithCheck("ATCF00000000");
        runCmdWithCheck("ATCM00000000");
        if(!filter.maskEff || filter.filt.type == Id::Type::Std)
            runCmdWithCheck(QString("STFAP%1,%2").arg(stdFilter, stdMask).toLatin1());
        if(!filter.maskEff || filter.filt.type == Id::Type::Ext)
            runCmdWithCheck(QString("STFAP%1,%2").arg(extFilter, extMask).toLatin1());
    }
    else
    {
        // ELM327 does not support filters that can distinguish by EFF, so ignore it
        runCmdWithCheck(QString("ATCF%1").arg(extFilter).toLatin1());
        runCmdWithCheck(QString("ATCM%1").arg(extMask).toLatin1());
    }
    if(mIntfcIsStn)
        mIo->write("STM\r");
    else
        mIo->write("ATMA\r");
    mCfgdFilter = filter;
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
void Interface::updateBitrateTxType()
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
            throw ConfigError();
        }

        quint8 canOptions = 0x60;
        if(mTxAddrIsStd && mTxAddrIsStd.get())
            canOptions |= 0x80;
        if(mOptTqPerBit)
            canOptions |= 0x10;

        // STN1110 requires that protocol not be set to B when altering B settings
        runCmdWithCheck("ATSP1");
        runCmdWithCheck(QString("ATPB%1%2").arg(canOptions, 2, 16, QChar('0')).arg(mBitrateDivisor, 2, 16, QChar('0')).toLatin1());
        runCmdWithCheck("ATSPB");

        runCmdWithCheck("ATAT0");               // Disable adaptive timing
        runCmdWithCheck("ATSTff");              // Set maximum timeout = 1.02 s
        runCmdWithCheck("ATCSM0", CheckOk::No); // Try to set silent monitoring; some knockoff ELM327s don't support this command but seem to work OK anyway

        if(mSlaveAddr)
            doSetFilter(ExactFilter(mSlaveAddr.get().res));
        else
            doSetFilter(mFilter);
        mCfgdBitrate = mBitrate.get();
        if(mTxAddrIsStd)
            mCfgdTxAddrIsStd = mTxAddrIsStd.get();
    }
}

Factory::Factory(QextPortInfo info, QObject *parent) :
    SetupTools::Xcp::Interface::Can::Factory(parent),
    mPortInfo(info)
{}

SetupTools::Xcp::Interface::Can::Interface *Factory::make(QObject *parent)
{
    return new Interface(mPortInfo.portName, parent);
}
QString Factory::text()
{
    return "ELM327 on " + mPortInfo.portName + " (" + mPortInfo.friendName + ")";
}

QList<Factory *> getInterfacesAvail(QObject *parent)
{
    QList<Factory *> ret;
    for(const QextPortInfo &portInfo : getValidSerialPorts())
        ret.append(new Factory(portInfo, parent));
    return ret;
}

}   // namespace Elm327
}   // namespace Can
}   // namespace Interface
}   // namespace Xcp
}   // namespace SetupTools
