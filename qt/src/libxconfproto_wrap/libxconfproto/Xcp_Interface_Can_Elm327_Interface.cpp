#include "Xcp_Interface_Can_Elm327_Interface.h"

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

Io::Io(GranularTimeSerialPort &port, QObject *parent) :
    QThread(parent),
    mPort(port),
    mPromptReady(true), // Process of finding baudrate leaves ELM at a prompt
    mTerminate(false)
{
    mPort.setTimeout(TICK_MSEC);
    mSendTimer.start();
    start();
}
Io::~Io()
{
    mTerminate = true;
    wait();
}
void Io::sync()
{
    QMutexLocker locker(&mPipelineClearMutex);
    mPipelineClearCond.wait(locker.mutex());
}

void Io::syncAndGetPrompt(int timeoutMsec, int retries)
{
    sync();

    if(isPromptReady())
        return;

    for(int i = 0; i < retries; ++i)
    {
        write("\r");
        if(waitPromptReady(timeoutMsec))
            return;
    }

    qCritical("Failed to obtain prompt from ELM327");
    throw NoResponse();
}

QList<Frame> Io::getRcvdFrames(int timeoutMsec)
{
    return mRcvdFrameQueue.getAll(timeoutMsec);
}

QList<QByteArray> Io::getRcvdCmdResp(int timeoutMsec)
{
    return mRcvdCmdRespQueue.getAll(timeoutMsec);
}

void Io::flushCmdResp()
{
    mRcvdCmdRespQueue.getAll(0);    // ignore the return value -> it gets destroyed
}

void Io::write(QByteArray data)
{
    mTransmitQueue.put(data);
    sync();
}

bool Io::isPromptReady()
{
    return mPromptReady;    // don't need to bother with the mutex/condition since this is just a poll
}

bool Io::waitPromptReady(int timeoutMsec)
{
    QMutexLocker locker(&mPromptReadyMutex);
    if(mPromptReady)
        return true;
    else
        return mPromptReadyCond.wait(locker.mutex(), timeoutMsec);
}

void Io::run()
{
    while(1)
    {
        if(mTerminate)
            return;

        bool setPromptReady = false;
        bool setPipelineClear = true;

        Q_ASSERT(mLines.size() <= 1);

        // Get data from the serial port and put it into mLines (a list of lines, all ending with CR except possibly the last one, which is the line we're receiving right now)
        {
            QByteArray buffer = mPort.readGranular(READ_SIZE);
            QByteArray newLine;
            if(!mLines.isEmpty())
                newLine = mLines.takeFirst();
            for(char c : buffer)
            {
                if(c != '\0')   // Ignore nulls, which ELM documentation says may be emitted in error
                {
                    newLine.append(c);
                    if(c == EOL)
                    {
                        mLines.append(newLine);
                        newLine.clear();
                    }
                }
            }
            if(newLine.size())
                mLines.append(newLine);
        }

        // Process lines from mLines, putting any incomplete line that may exist back into mLines
        QList<QByteArray> incompleteLines;
        for(QByteArray & line : mLines)
        {
            //qDebug() << mPort.elapsedSecs() << "ELM327 IO line" << line.toPercentEncoding();
            if(line.endsWith(EOL))
            {
                line.chop(1);
                if(!line.isEmpty()) {
                    if(containsNonHex(line))\
                        mRcvdCmdRespQueue.put(line);
                    else
                    {
                        Frame frame;
                        int idLen;
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
                            frame.id.addr = line.left(idLen).toUInt(NULL, 16);
                            frame.data = QByteArray::fromHex(line.mid(idLen));
                            mRcvdFrameQueue.put(frame);
                        }
                        else
                            mRcvdCmdRespQueue.put(line);    // too short to be valid

                    }
                }
            }
            else
            {
                if(line == ">")
                    setPromptReady = true;
                else
                    incompleteLines.append(line);
            }
        }
        mLines.swap(incompleteLines);

        // Send data from mTransmitQueue, unless we're waiting for the device to "settle"
        if(mSendTimer.nsecsElapsed() > ELM_RECOVERY_NSEC && !mTransmitQueue.empty())
        {
            mPromptReady = false;
            QByteArray data = mTransmitQueue.get().get();   // mTransmitQueue.get() returns a boost::optional, but we know it's set because of condition above
            mPort.write(data); // write() is *probably* synchronous
            mSendTimer.start();
            setPromptReady = false;
            setPipelineClear = false;
        }

        if(setPromptReady)
        {
            QMutexLocker locker(&mPromptReadyMutex);
            mPromptReady = true;
            mPromptReadyCond.wakeAll();
        }

        if(setPipelineClear && mTransmitQueue.empty())
        {
            QMutexLocker locker(&mPipelineClearMutex);
            mPipelineClearCond.wakeAll();
        }
    }
}

constexpr int Interface::POSSIBLE_BAUDRATES[];

Interface::Interface(const QSerialPortInfo & portInfo, bool serialLog, QObject *parent) :
    ::SetupTools::Xcp::Interface::Can::Interface(parent),
    mPort(portInfo),
    mIntfcIsStn(false)
{
    mPort.setLogging(serialLog);
    if(!mPort.open(QIODevice::ReadWrite))
    {
        qCritical("Failed to open serial port");
        throw SerialError();
    }
    bool foundBaud = false;
    for(auto baud : POSSIBLE_BAUDRATES)
    {
        qDebug() << "Trying" << baud << "baud";
        mPort.setBaudRate(baud);
        mPort.setTimeout(FINDBAUD_TIMEOUT_MSEC);
        mPort.setInterCharTimeout();

        bool commEstablished = false;
        for(int i = 0; i < FINDBAUD_ATTEMPTS; ++i)
        {
            mPort.fullClear();
            mPort.write("\r");
            QByteArray findBaudRes = mPort.readGranular(16384);
            if(findBaudRes.size() > 0 && findBaudRes.endsWith(">"))
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
            QByteArray brdRes = mPort.readGranular(12);
            if(brdRes.contains("OK"))
            {
                // Device allows baudrate change, proceed with switch
                mPort.setBaudRate(DESIRED_BAUDRATE);
                mPort.setInterCharTimeout();
                mPort.fullClear();
                qDebug() << "Switched to" << mPort.baudRate() << "baud";
                QByteArray switchBaudRes = mPort.readGranular(11);
                qDebug() << "switchBaudRes ==" << switchBaudRes.toPercentEncoding();
                if(switchBaudRes.startsWith("ELM327"))
                {
                    // Baudrate switch successful, send a CR to confirm we're on board
                    mPort.fullClear();
                    mPort.write("\r");
                    if(mPort.readGranular(2) != "OK")
                    {
                        qCritical("Unexpected response from ELM327 when confirming UART baudrate switch");
                        throw UnexpectedResponse();
                    }
                }
                else
                {
                    // Baudrate switch unsuccessful, try to recover
                    mPort.setBaudRate(baud);
                    mPort.setInterCharTimeout();

                    mPort.write("\r");
                    mPort.fullClear();
                    if(!mPort.readGranular(1024).endsWith(">"))
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

void Interface::transmit(const QByteArray & data)
{
    Q_ASSERT(mSlaveAddr);
    transmitTo(data, mSlaveAddr.get().cmd);
}

void Interface::transmitTo(const QByteArray & data, Id id)
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

    mIo->write(data.toHex() + "\r");
}

QList<Frame> Interface::receiveFrames(int timeoutMsec, const Filter filter, bool (*validator)(const Frame &))
{
    Q_ASSERT(mCfgdBitrate && mCfgdFilter);

    QList<Frame> frames;

    QElapsedTimer timer;
    timer.start();

    qint64 timeoutNsec = qint64(timeoutMsec) * 1000000;
    while(timer.nsecsElapsed() <= timeoutNsec && !frames.size())
    {
        int queueReadTimeout = std::max(qint64(timeoutMsec) - timer.elapsed() / 1000000, qint64(0));

        for(const Frame & newFrame : mIo->getRcvdFrames(queueReadTimeout))
        {
            if(filter.Matches(newFrame.id) &&
                    (!validator || validator(newFrame)))
                frames.append(newFrame);
        }
    }

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
void Interface::setSerialLog(bool on)
{
    mPort.setLogging(on);
}
double Interface::elapsedSecs()
{
    return mPort.elapsedSecs();
}

void Interface::runCmdWithCheck(const QByteArray &cmd, CheckOk checkOkPolicy)
{
    mIo->syncAndGetPrompt(TIMEOUT_MSEC);
    mIo->flushCmdResp();
    mIo->write(cmd + "\r");
    if(!mIo->waitPromptReady(TIMEOUT_MSEC))
    {
        qCritical("No prompt from ELM327 after executing %s", cmd.constData());
        throw NoResponse();
    }
    if(checkOkPolicy == CheckOk::Yes)
    {
        bool gotOk = false;
        for(const QByteArray & response : mIo->getRcvdCmdResp(0))
        {
            if(response.contains("OK"))
            {
                gotOk = true;
                break;
            }
        }
        if(!gotOk)
        {
            qCritical("No OK from ELM327 after executing %s", cmd.constData());
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
    double calcBitrate = CAN_TQ_CLOCK_HZ / (divisor * STD_TQ_PER_BIT);
    if(abs(calcBitrate / mBitrate.get() - 1) < CAN_BITRATE_TOL)
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

}   // namespace Elm327
}   // namespace Can
}   // namespace Interface
}   // namespace Xcp
}   // namespace SetupTools