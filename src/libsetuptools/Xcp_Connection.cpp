#include "Xcp_Connection.h"

#include <string.h>
#include <QReadLocker>
#include <QWriteLocker>
#include <QMetaType>
#include <boost/crc.hpp>
#include <boost/range/iterator_range.hpp>
#include <numeric>

#include "util.h"

namespace SetupTools
{
namespace Xcp
{

QString XcpPtr::toString() const
{
    if(ext == 0)
        return QString("%1").arg(addr, 8, 16, QChar('0'));
    else
        return QString("%1:%1").arg(ext, 2, 16, QChar('0')).arg(addr, 16, 8, QChar('0'));
}

XcpPtr XcpPtr::fromString(QString str, bool *ok)
{
    XcpPtr out;
    bool isOk = false;

    QStringList split = str.split(QChar(':'));

    if(split.size() >= 1 && split.size() < 2)
    {
        QList<quint32> num;
        bool convOk = true;
        for(const QString &splitStr : split)
        {
            num.push_back(splitStr.toULong(&convOk, 16));
            if(!convOk)
                break;
        }

        if(convOk)
        {
            Q_ASSERT(num.size() == split.size());
            if(num.size() == 1)
            {
                out = XcpPtr(num[0]);
                isOk = true;
            }
            else if(num[0] <= std::numeric_limits<quint8>::max())
            {
                Q_ASSERT(num.size() == 2);
                out = XcpPtr(num[1], quint8(num[0]));
                isOk = true;
            }
        }
    }

    if(ok)
        *ok = isOk;
    return out;
}

static bool isNumType(QVariant::Type type)
{
    return type == QVariant::Type::Int
            || type == QVariant::Type::UInt
            || type == QVariant::Type::LongLong
            || type == QVariant::Type::ULongLong
            || type == QVariant::Type::Double;
}

XcpPtr XcpPtr::fromVariant(const QVariant & var, bool * ok)
{
    XcpPtr out;
    bool isOk = false;
    if(isNumType(var.type()))
    {
        quint32 addr = var.toUInt(&isOk);
        out = XcpPtr(addr);
    }
    else if(var.type() == QVariant::Type::List)
    {
        QVariantList list = var.toList();
        if(list.size() == 1 && isNumType(list[0].type()))
        {
            quint32 addr = var.toUInt(&isOk);
            out = XcpPtr(addr);
        }
        else if(list.size() == 2 && isNumType(list[0].type()) && isNumType(list[1].type()))
        {
            bool extOk = false;
            quint32 ext = list[0].toUInt(&extOk);
            if(extOk)
            {
                quint32 addr = list[1].toUInt(&isOk);
                out = XcpPtr(addr, quint8(ext));
            }
        }
    }

    if(!isOk)
        out = fromString(var.toString(), &isOk);

    if(ok)
        *ok = isOk;
    return out;
}

#define RESETMTA_RETURN_ON_FAIL(value) { OpResult EMIT_RETURN__ret = value; if(EMIT_RETURN__ret != OpResult::Success) { mCalcMta.reset(); return EMIT_RETURN__ret; } }

boost::optional<quint32> computeCksumStatic(CksumType type, const std::vector<quint8> &data)
{
    switch(type)
    {
    case CksumType::XCP_CRC_16:
        {
            boost::crc_16_type computer;
            computer.process_block(data.data(), data.data() + data.size());
            return computer.checksum();
        }
        break;
    case CksumType::XCP_CRC_16_CITT:
        {
            boost::crc_ccitt_type computer;
            computer.process_block(data.data(), data.data() + data.size());
            return computer.checksum();
        }
        break;
    case CksumType::XCP_CRC_32:
        {
            boost::crc_32_type computer;
            computer.process_block(data.data(), data.data() + data.size());
            return computer.checksum();
        }
        break;
    case CksumType::ST_CRC_32:
        {
            // template < std::size_t Bits, BOOST_CRC_PARM_TYPE TruncPoly, BOOST_CRC_PARM_TYPE InitRem, BOOST_CRC_PARM_TYPE FinalXor, bool ReflectIn, bool ReflectRem > boost::crc_optimal
            // typedef crc_optimal<32, 0x04C11DB7, 0xFFFFFFFF, 0xFFFFFFFF, true, true> crc_32_type;
            boost::crc_optimal<32, 0x04C11DB7, 0xFFFFFFFF, 0x00000000, false, false> computer;
            int nWords = data.size() / sizeof(quint32);
            boost::iterator_range<const quint32 *> words(reinterpret_cast<const quint32 *>(data.data()), reinterpret_cast<const quint32 *>(data.data()) + nWords);
            for(quint32 word : words)
            {
                decltype(word) flipWord = qFromBigEndian(word);
                computer.process_bytes(&flipWord, sizeof(flipWord));
            }
            return computer.checksum();
        }
        break;
    default:
        return boost::optional<quint32>();
        break;
    }
}

quint32 Connection::computeCksum(CksumType type, const std::vector<quint8> &data)
{
    switch(type)
    {
    case CksumType::XCP_ADD_11:
        return additiveChecksum<quint8, quint8>(data);
        break;
    case CksumType::XCP_ADD_12:
        return additiveChecksum<quint16, quint8>(data);
        break;
    case CksumType::XCP_ADD_14:
        return additiveChecksum<quint32, quint8>(data);
        break;
    case CksumType::XCP_ADD_22:
        return additiveChecksum<quint16, quint16>(data);
        break;
    case CksumType::XCP_ADD_24:
        return additiveChecksum<quint32, quint16>(data);
        break;
    case CksumType::XCP_ADD_44:
        return additiveChecksum<quint32, quint32>(data);
        break;
    default:
    {
        boost::optional<quint32> cksum = computeCksumStatic(type, data);
        Q_ASSERT(cksum);
        return cksum.get();
    } break;
    }
}

Connection::Connection(QObject *parent) :
    QObject(parent),
    mIntfc(nullptr),
    mTimeoutMsec(0),
    mNvWriteTimeoutMsec(0),
    mBootDelayMsec(0),
    mProgClearTimeoutMsec(0),
    mProgResetIsAcked(true),
    mConnected(false),
    mOpProgress(0),
    mOpProgressNotifyFrac(0.015625),
    mOpProgressFracs(0)
{
    qRegisterMetaType<SetupTools::Xcp::XcpPtr>("XcpPtr");
    qRegisterMetaType<SetupTools::OpResult>();
    qRegisterMetaType<SetupTools::OpResultWrapper::OpResult>();
    qRegisterMetaType<SetupTools::Xcp::Connection::OpExtInfo>();
    qRegisterMetaType<SetupTools::Xcp::CksumType>();
    qRegisterMetaType<std::vector<quint8> >();
}

QObject *Connection::intfc()
{
    QReadLocker lock(&mIntfcLock);
    return mIntfc;
}

void Connection::setIntfc(QObject *intfc)
{
    {
        QWriteLocker lock(&mIntfcLock);
        if(mIntfc)
            disconnect(mIntfc, &Interface::Interface::connectedTargetChanged, this, &Connection::connectedTargetChanged);
        mIntfc = qobject_cast<Interface::Interface *>(intfc);
        if(mIntfc)
            connect(mIntfc, &Interface::Interface::connectedTargetChanged, this, &Connection::connectedTargetChanged);
    }

    emit stateChanged();
}

int Connection::timeout()
{
    return mTimeoutMsec;
}

void Connection::setTimeout(int msec)
{
    mTimeoutMsec = msec;
}

int Connection::nvWriteTimeout()
{
    return mNvWriteTimeoutMsec;
}

void Connection::setNvWriteTimeout(int msec)
{
    mNvWriteTimeoutMsec = msec;
}

int Connection::bootDelay()
{
    return mBootDelayMsec;
}

void Connection::setBootDelay(int msec)
{
    mBootDelayMsec = msec;
}

double Connection::opProgressNotifyFrac()
{
    QReadLocker lock(&mOpProgressLock);
    return mOpProgressNotifyFrac;
}

void Connection::setOpProgressNotifyFrac(double val)
{
    QWriteLocker lock(&mOpProgressLock);
    mOpProgressNotifyFrac = val;
}

int Connection::progClearTimeout()
{
    return mProgClearTimeoutMsec;
}

void Connection::setProgClearTimeout(int msec)
{
    mProgClearTimeoutMsec = msec;
}

bool Connection::progResetIsAcked()
{
    return mProgResetIsAcked;
}

void Connection::setProgResetIsAcked(bool val)
{
    mProgResetIsAcked = val;
}

double Connection::opProgress()
{
    QReadLocker lock(&mOpProgressLock);
    return mOpProgress;
}

void Connection::forceSlaveSupportCalPage()
{
    mSupportsCalPage = true;
}

Connection::State Connection::state()
{
    QReadLocker lock(&mIntfcLock);
    if(mIntfc == nullptr)
        return State::IntfcInvalid;
    else if(!mConnected)
        return State::Closed;
    else if(!mPgmStarted)
        return State::CalMode;
    else
        return State::PgmMode;
}

OpResult Connection::setTarget(QString val)
{
    if(mIntfc == nullptr)
        EMIT_RETURN(setTargetDone, OpResult::IntfcConfigError);
    if(mConnected)
        EMIT_RETURN(setTargetDone, OpResult::InvalidOperation);

    OpResult out = mIntfc->setTarget(val);
    EMIT_RETURN(setTargetDone, out);
}

OpResult Connection::setState(State val)
{
    QReadLocker lock(&mIntfcLock);
    if(state() == val)
        EMIT_RETURN(setStateDone, OpResult::Success);
    if(!mIntfc)
        EMIT_RETURN(setStateDone, OpResult::NoIntfc);

    switch(val)
    {
    case State::Closed:
        emit stateChanged();
        EMIT_RETURN(setStateDone, close());
        break;
    case State::CalMode:
        if(mConnected)
        {
            Q_ASSERT(mPgmStarted);
            // need to do program reset
            EMIT_RETURN_ON_FAIL(setStateDone, programReset());
            EMIT_RETURN(setStateDone, open());
        }
        else
        {
            EMIT_RETURN(setStateDone, open());
        }
        break;
    case State::PgmMode:
        if(!mConnected)
            EMIT_RETURN_ON_FAIL(setStateDone, open());

        EMIT_RETURN(setStateDone, programStart());
        break;
    default:
    case State::IntfcInvalid:
        Q_ASSERT(0);
        break;
    }
    return OpResult::InvalidOperation;
}

#pragma GCC diagnostic push
#pragma GCC diagnostic ignored "-Wmissing-field-initializers"

OpResult Connection::open(boost::optional<int> timeoutMsec)
{
    QString msg = tr("connecting to slave");

    mConnected = false;
    mCalcMta.reset();
    emit stateChanged();

    std::vector<quint8> reply;
    EMIT_RETURN_ON_FAIL(openDone, transact({CmdCode_Connect, 0x00}, 8, reply, msg, {OpType::Open, CmdCode_Connect}, timeoutMsec));
    if(reply[0] != 0xFF)
        EMIT_RETURN(openDone, getReplyResult(reply, msg, {OpType::Open, CmdCode_Connect}));
    mSupportsCalPage = reply[1] & 0x01;
    mSupportsPgm = reply[1] & 0x10;
    mIsBigEndian = reply[2] & 0x01;
    switch(reply[2] & 0x06)
    {
        case 0x00:
            mAddrGran = 1;
            break;
        case 0x02:
            mAddrGran = 2;
            break;
        case 0x04:
            mAddrGran = 4;
            break;
        default:
            EMIT_RETURN(openDone, getReplyResult(reply, msg, {OpType::Open, CmdCode_Connect}));
            break;
    }
    mMaxCto = reply[3];
    mMaxDownPayload = ((mMaxCto - 2) / mAddrGran) * mAddrGran;
    mMaxUpPayload = ((mMaxCto - 1) / mAddrGran) * mAddrGran;
    if(reply[6] != char(0x01) || reply[7] != char(0x01))
        EMIT_RETURN(openDone, getReplyResult(reply, msg, {OpType::Open, CmdCode_Connect}));

    mPgmStarted = false;
    mPgmMasterBlockMode = false;
    mConnected = true;
    emit stateChanged();

    EMIT_RETURN(openDone, OpResult::Success);
}

OpResult Connection::close()
{
    QString msg = tr("disconnecting from slave");

    mConnected = false;
    mCalcMta.reset();
    emit stateChanged();
    std::vector<quint8> reply;
    EMIT_RETURN_ON_FAIL(closeDone, transact({CmdCode_Disconnect}, 1, reply, msg, {OpType::Close, CmdCode_Disconnect}));
    if(reply[0] != 0xFF)
        EMIT_RETURN(closeDone, getReplyResult(reply, msg, {OpType::Close, CmdCode_Disconnect}));

    EMIT_RETURN(closeDone, OpResult::Success);
}

OpResult Connection::upload(XcpPtr base, int len, std::vector<quint8> *out)
{
    if(!mConnected)
        EMIT_RETURN(uploadDone, OpResult::NotConnected, base, len);
    if(len % mAddrGran)
        EMIT_RETURN(uploadDone, OpResult::AddrGranError, base, len);

    int remBytes = len;
    XcpPtr packetPtr = base;

    std::vector<quint8> data;
    while(remBytes > 0)
    {
        int packetBytes = std::min(remBytes, mMaxUpPayload);
        std::vector<quint8> seg;
        OpResult segResult = uploadSegment(packetPtr, packetBytes, seg, OpType::Upload);
        if(segResult != OpResult::Success)
        {
            if(out)
                *out = data;
            updateEmitOpProgress(0);
            emit uploadDone(segResult, base, len, data);
            return segResult;
        }
        data.insert(data.end(), seg.begin(), seg.end());
        remBytes -= packetBytes;
        packetPtr.addr += packetBytes / mAddrGran;
        updateEmitOpProgress(double(len - remBytes) / len);
    }
    if(out)
        *out = data;
    emit uploadDone(OpResult::Success, base, len, data);
    updateEmitOpProgress(0);
    return OpResult::Success;
}

OpResult Connection::download(XcpPtr base, const std::vector<quint8> data)
{
    if(!mConnected)
        EMIT_RETURN(downloadDone, OpResult::NotConnected, base, data);
    if(mPgmStarted)
        EMIT_RETURN(downloadDone, OpResult::WrongMode, base, data);
    if(data.size() % mAddrGran)
        EMIT_RETURN(downloadDone, OpResult::AddrGranError, base, data);
    if(!mSupportsCalPage)
        EMIT_RETURN(downloadDone, OpResult::InvalidOperation, base, data);

    int remBytes = data.size();
    XcpPtr packetPtr = base;
    const uchar *packetDataPtr = data.data();

    while(remBytes > 0)
    {
        int packetBytes = std::min(remBytes, mMaxDownPayload);
        OpResult segResult = downloadSegment(packetPtr, std::vector<quint8>(packetDataPtr, packetDataPtr + packetBytes), OpType::Download);
        if(segResult != OpResult::Success)
        {
            updateEmitOpProgress(0);
            emit downloadDone(segResult, base, data);
            return segResult;
        }
        remBytes -= packetBytes;
        packetDataPtr += packetBytes;
        packetPtr.addr += packetBytes / mAddrGran;
        updateEmitOpProgress(double(packetDataPtr - data.data()) / data.size());
    }

    emit downloadDone(OpResult::Success, base, data);
    updateEmitOpProgress(0);
    return OpResult::Success;
}

OpResult Connection::nvWrite()
{
    QReadLocker lock(&mIntfcLock);
    Q_ASSERT(mIntfc);
    if(!mConnected)
        EMIT_RETURN(nvWriteDone, OpResult::NotConnected);
    if(mPgmStarted)
        EMIT_RETURN(nvWriteDone, OpResult::WrongMode);
    if(!mSupportsCalPage)
        EMIT_RETURN(nvWriteDone, OpResult::InvalidOperation);

    std::function<OpResult (void)> action = [this]()
    {
        // do not use transact() since slave might send two packets (reply plus EV_STORE_CAL)
        {
            RETURN_ON_FAIL(mIntfc->transmit({CmdCode_SetRequest, 0x01, 0x00, 0x00}));
            bool setReqRepliedTo = false;
            bool writeComplete = false;
            QElapsedTimer replyTimer;
            replyTimer.start();
            if(mTimeoutMsec <= 0)
                return OpResult::InvalidArgument;

            while(1)
            {
                int timeout = std::max(mTimeoutMsec - int(replyTimer.elapsed()), 0);
                std::vector<std::vector<quint8> > replies;
                RETURN_ON_FAIL(mIntfc->receive(timeout, replies));

                if(replies.size() == 0)
                {
                    emit opMsg(OpResult::Timeout, tr("Timeout while writing nonvolatile memory"), {OpType::NvWrite, CmdCode_SetRequest});
                    return OpResult::Timeout;
                }

                for(std::vector<quint8> &reply : replies)
                {
                    if(reply.size() >= 1 && reply[0] == 0xFF)
                        setReqRepliedTo = true;
                    else if(reply.size() >= 2 && reply[0] == 0xFD && reply[1] == 0x03)
                        writeComplete = true;
                    else
                        return getReplyResult(reply, tr("writing nonvolatile memory"), {OpType::NvWrite, CmdCode_SetRequest});
                }
                if(setReqRepliedTo)
                {
                    if(writeComplete)
                        return OpResult::Success;
                    else
                        break;
                }
            }

        }

        QElapsedTimer timer;
        timer.start();
        while(!timer.hasExpired(mNvWriteTimeoutMsec))
        {
            // do not use transact() since slave might send two packets (reply plus EV_STORE_CAL)
            RETURN_ON_FAIL(mIntfc->transmit({CmdCode_GetStatus}));
            bool getStsRepliedTo = false;
            bool writeComplete = false;
            QElapsedTimer replyTimer;
            replyTimer.start();

            while(1)
            {
                int timeout = std::max(mTimeoutMsec - int(replyTimer.elapsed()), 0);
                std::vector<std::vector<quint8> > replies;
                RETURN_ON_FAIL(mIntfc->receive(timeout, replies));

                if(replies.size() == 0)
                {
                    emit opMsg(OpResult::Timeout, tr("Timeout while waiting for nonvolatile memory write to finish"), {OpType::NvWrite, CmdCode_GetStatus});
                    return OpResult::Timeout;
                }

                for(std::vector<quint8> &reply : replies)
                {
                    if(reply.size() >= 2 && reply[0] == 0xFF)
                    {
                        getStsRepliedTo = true;
                        if(!(reply[1] & 0x01))
                            writeComplete = true;
                    }
                    else if(reply.size() >= 2 && reply[0] == 0xFD && reply[1] == 0x03)
                    {
                        writeComplete = true;
                    }
                    else
                    {
                        return getReplyResult(reply, tr("waiting for nonvolatile memory write to finish"), {OpType::NvWrite, CmdCode_GetStatus});
                    }
                }

                if(getStsRepliedTo)
                {
                    if(writeComplete)
                        return OpResult::Success;
                    else
                        break;  // Write not complete, but this GET_STATUS was answered, so we can send another
                }
            }
            int msecsLeft = mNvWriteTimeoutMsec / NUM_NV_WRITE_POLLS - int(replyTimer.elapsed());
            QThread::msleep(std::max(msecsLeft, 0));
        }
        emit opMsg(OpResult::Timeout, tr("Timeout while waiting for nonvolatile memory write to finish"), {OpType::NvWrite, CmdCode_GetStatus});
        return OpResult::Timeout; // Exited outer while() loop due to timeout
    };

    EMIT_RETURN(nvWriteDone, tryQuery(action, OpType::NvWrite));
}

OpResult Connection::setCalPage(quint8 segment, quint8 page)
{
    if(!mConnected)
        EMIT_RETURN(setCalPageDone, OpResult::NotConnected, segment, page);
    if(mPgmStarted)
        EMIT_RETURN(setCalPageDone, OpResult::WrongMode, segment, page);
    if(!mSupportsCalPage)
        EMIT_RETURN(setCalPageDone, OpResult::InvalidOperation, segment, page);

    std::vector<quint8> query({CmdCode_SetCalPage, 0x03, segment, page});

    mCalcMta.reset();   // standard does not define what happens to MTA

    std::function<OpResult (void)> action = [this, query]()
    {
        QString msg = tr("setting calibration segment/page");

        std::vector<quint8> reply;
        RETURN_ON_FAIL(transact(query, 1, reply, msg, {OpType::SetCalPage, CmdCode_SetCalPage}));
        if(reply[0] != 0xFF)
            return getReplyResult(reply, msg, {OpType::SetCalPage, CmdCode_SetCalPage});

        return OpResult::Success;
    };

    EMIT_RETURN(setCalPageDone, tryQuery(action, OpType::SetCalPage), segment, page);
}

OpResult Connection::copyCalPage(quint8 fromSegment, quint8 fromPage, quint8 toSegment, quint8 toPage)
{
    if(!mConnected)
        EMIT_RETURN(copyCalPageDone, OpResult::NotConnected, fromSegment, fromPage, toSegment, toPage);
    if(mPgmStarted)
        EMIT_RETURN(copyCalPageDone, OpResult::WrongMode, fromSegment, fromPage, toSegment, toPage);
    if(!mSupportsCalPage)
        EMIT_RETURN(copyCalPageDone, OpResult::InvalidOperation, fromSegment, fromPage, toSegment, toPage);

    std::vector<quint8> query({CmdCode_CopyCalPage, fromSegment, fromPage, toSegment, toPage});

    mCalcMta.reset();   // standard does not define what happens to MTA

    std::function<OpResult (void)> action = [this, query]()
    {
        QString msg = tr("copying calibration page");

        std::vector<quint8> reply;
        RETURN_ON_FAIL(transact(query, 1, reply, msg, {OpType::CopyCalPage, CmdCode_CopyCalPage}));
        if(reply[0] != 0xFF)
            return getReplyResult(reply, msg, {OpType::CopyCalPage, CmdCode_CopyCalPage});

        return OpResult::Success;
    };

    EMIT_RETURN(copyCalPageDone, tryQuery(action, OpType::CopyCalPage), fromSegment, fromPage, toSegment, toPage);
}

OpResult Connection::programStart()
{
    if(!mConnected)
        EMIT_RETURN(programStartDone, OpResult::NotConnected);

    std::function<OpResult (void)> action = [this]()
    {
        QString msg = tr("entering program mode");
        std::vector<quint8> reply;
        RETURN_ON_FAIL(transact({0xD2}, 7, reply, msg, {OpType::ProgramStart, CmdCode_ProgramStart}));
        if(reply[0] != 0xFF)
            return getReplyResult(reply, msg, {OpType::ProgramStart, CmdCode_ProgramStart});
        mPgmMasterBlockMode = reply[2] & 0x01;
        mPgmMaxCto = reply[3];
        if(mPgmMaxCto < 8)
            return getReplyResult(reply, msg, {OpType::ProgramStart, CmdCode_ProgramStart});
        mPgmMaxBlocksize = reply[4];
        mPgmMaxDownPayload = ((mPgmMaxCto - 2) / mAddrGran) * mAddrGran;
        mCalcMta.reset();   // standard does not define what happens to MTA
        mPgmStarted = true;
        emit stateChanged();

        // Compensate for erroneous implementations that gave BS as a number of bytes, not number of packets
        if(mPgmMaxBlocksize > (255 / mPgmMaxDownPayload))
            mPgmMaxBlocksize = mPgmMaxBlocksize / mPgmMaxDownPayload;

        return OpResult::Success;
    };

    EMIT_RETURN(programStartDone, tryQuery(action, OpType::ProgramStart));
}

OpResult Connection::programClear(XcpPtr base, int len)
{
    if(!mConnected)
        EMIT_RETURN(programClearDone, OpResult::NotConnected, base, len);
    if(!mPgmStarted)
        EMIT_RETURN(programClearDone, OpResult::WrongMode, base, len);
    if(len % mAddrGran)
        EMIT_RETURN(programClearDone, OpResult::AddrGranError, base, len);

    std::vector<quint8> query({CmdCode_ProgramClear, 0x00, 0, 0, 0, 0, 0, 0});
    toSlaveEndian<quint32>(len / mAddrGran, query.data() + 4);

    mCalcMta.reset();   // standard does not define what happens to MTA

    std::function<OpResult (void)> action = [this, base, query, len]()
    {
        QString msg = tr("erasing program");

        if(!mCalcMta || mCalcMta.get() != base)
            RETURN_ON_FAIL(setMta(base, OpType::ProgramClear));

        std::vector<quint8> reply;
        RETURN_ON_FAIL(transact(query, 1, reply, msg, {OpType::ProgramClear, CmdCode_ProgramClear, base, len}, mProgClearTimeoutMsec));
        if(reply[0] != 0xFF)
            return getReplyResult(reply, msg, {OpType::ProgramClear, CmdCode_ProgramClear, base, len});

        return OpResult::Success;
    };

    EMIT_RETURN(programClearDone, tryQuery(action, OpType::ProgramClear), base, len);
}

OpResult Connection::programRange(XcpPtr base, const std::vector<quint8> data, bool finalEmptyPacket)
{
    if(!mConnected)
        EMIT_RETURN(programRangeDone, OpResult::NotConnected, base, data, finalEmptyPacket);
    if(!mPgmStarted)
        EMIT_RETURN(programRangeDone, OpResult::WrongMode, base, data, finalEmptyPacket);
    if(data.size() % mAddrGran)
        EMIT_RETURN(programRangeDone, OpResult::AddrGranError, base, data, finalEmptyPacket);

    std::vector<quint8>::const_iterator dataIt = data.begin();
    while(1)
    {
        XcpPtr startPtr = {quint32(base.addr + std::distance(data.begin(), dataIt) / mAddrGran), base.ext};
        if(dataIt == data.end())
        {
            if(finalEmptyPacket)
            {
                std::vector<quint8> packetData;   // empty vector
                OpResult segResult = programPacket(startPtr, packetData, OpType::ProgramRange);
                if(segResult != OpResult::Success)
                {
                    updateEmitOpProgress(0);
                    emit programRangeDone(segResult, base, data, finalEmptyPacket);
                    return segResult;
                }
            }
            break;
        }

        if(mPgmMasterBlockMode && mIntfc->hasReliableTx())
        {
            int blockBytes = std::min(std::distance(dataIt, data.end()), ssize_t(mPgmMaxBlocksize * mPgmMaxDownPayload));
            std::vector<quint8> blockData(dataIt, dataIt + blockBytes);
            OpResult segResult = programBlock(startPtr, blockData, OpType::ProgramRange);
            if(segResult != OpResult::Success)
            {
                updateEmitOpProgress(0);
                emit programRangeDone(segResult, base, data, finalEmptyPacket);
                return segResult;
            }
            dataIt += blockBytes;
        }
        else
        {
            int packetBytes = std::min(std::distance(dataIt, data.end()), ssize_t(mPgmMaxDownPayload));
            std::vector<quint8> packetData(dataIt, dataIt + packetBytes);
            OpResult segResult = programPacket(startPtr, packetData, OpType::ProgramRange);
            if(segResult != OpResult::Success)
            {
                updateEmitOpProgress(0);
                emit programRangeDone(segResult, base, data, finalEmptyPacket);
                return segResult;
            }
            dataIt += packetBytes;
        }
        updateEmitOpProgress(double(dataIt - data.begin()) / data.size());
    }

    emit programRangeDone(OpResult::Success, base, data, finalEmptyPacket);
    updateEmitOpProgress(0);
    return OpResult::Success;
}

OpResult Connection::programVerify(XcpPtr mta, quint32 crc)
{
    if(!mConnected)
        EMIT_RETURN(programVerifyDone, OpResult::NotConnected, mta, crc);
    if(!mPgmStarted)
        EMIT_RETURN(programVerifyDone, OpResult::WrongMode, mta, crc);

    std::vector<quint8> query({CmdCode_ProgramVerify, 0x01, 0, 0, 0, 0, 0, 0});
    toSlaveEndian<quint16>(0x0002, query.data() + 2);
    toSlaveEndian<quint32>(crc, query.data() + 4);

    std::function<OpResult (void)> action = [this, mta, query]()
    {
        QString msg = tr("verifying program");

        if(!mCalcMta || mCalcMta.get() != mta)
            RETURN_ON_FAIL(setMta(mta, OpType::ProgramVerify));

        std::vector<quint8> reply;
        RETURN_ON_FAIL(transact(query, 1, reply, msg, {OpType::ProgramVerify, CmdCode_ProgramVerify}));
        if(reply[0] != 0xFF)
            return getReplyResult(reply, msg, {OpType::ProgramVerify, CmdCode_ProgramVerify});

        return OpResult::Success;
    };

    EMIT_RETURN(programVerifyDone, tryQuery(action, OpType::ProgramVerify), mta, crc);
}

OpResult Connection::programReset()
{
    if(!mConnected)
        EMIT_RETURN(programResetDone, OpResult::NotConnected);

    std::function<OpResult (void)> action = [this]()
    {
        QString msg = tr("resetting slave");

        std::vector<quint8> reply;
        if(mProgResetIsAcked)
        {
            RETURN_ON_FAIL(transact({0xCF}, 1, reply, msg, {OpType::ProgramReset, CmdCode_ProgramReset}));
            if(reply[0] != 0xFF)
                return getReplyResult(reply, msg, {OpType::ProgramReset, CmdCode_ProgramReset});
        }
        else
        {
            RETURN_ON_FAIL(mIntfc->transmit({CmdCode_ProgramReset}));
        }

        mConnected = false;
        mCalcMta.reset();
        QThread::msleep(mBootDelayMsec);
        emit stateChanged();
        return OpResult::Success;
    };

    EMIT_RETURN(programResetDone, tryQuery(action, OpType::ProgramReset));
}

OpResult Connection::transact(const std::vector<quint8> &cmd, int minReplyBytes, std::vector<quint8> &out, QString info, OpExtInfo ext, boost::optional<int> timeoutMsec)
{
    QReadLocker lock(&mIntfcLock);
    Q_ASSERT(mIntfc);
    if(timeoutMsec.get_value_or(mTimeoutMsec) <= 0)
        return OpResult::InvalidArgument;
    RETURN_ON_FAIL(mIntfc->clearReceived());
    RETURN_ON_FAIL(mIntfc->transmit(cmd));

    std::vector<std::vector<quint8> > replies;
    RETURN_ON_FAIL(mIntfc->receive(timeoutMsec.get_value_or(mTimeoutMsec), replies));

    if(replies.size() == 0)
    {
        emit opMsg(OpResult::Timeout, tr("Timeout while %1").arg(info), ext);
        return OpResult::Timeout;
    }

    Q_ASSERT(minReplyBytes > 0);
    if(replies.size() > 1 || replies[0].size() < size_t(minReplyBytes))
        return getRepliesResult(replies, info, ext);

    out = replies[0];
    return OpResult::Success;
}

OpResult Connection::getRepliesResult(const std::vector<std::vector<quint8> > &replies, QString info, OpExtInfo ext)
{
    if(replies.size() > 1)
    {
        QString msg = tr("Multiple replies received %1").arg(info);
        emit opMsg(OpResult::MultipleReplies, msg, ext);

        for(const std::vector<quint8> &reply : replies)
        {
            QByteArray replyArr(reinterpret_cast<const char *>(reply.data()), reply.size());
            qDebug() << "Received" << replyArr.toHex();
        }
        return OpResult::MultipleReplies;
    }

    if(replies[0].size() >= 2 && quint8(replies[0][0]) == 0xFE)
    {
        static const QMap<quint8, QPair<QString, OpResult>> RESULT_CODES = {
            {0x10, {tr("busy"), OpResult::SlaveErrorBusy}},
            {0x11, {tr("DAQ active"), OpResult::SlaveErrorDaqActive}},
            {0x12, {tr("program active"), OpResult::SlaveErrorPgmActive}},
            {0x20, {tr("command unknown"), OpResult::SlaveErrorCmdUnknown}},
            {0x21, {tr("command syntax invalid"), OpResult::SlaveErrorCmdSyntax}},
            {0x22, {tr("parameter out of range"), OpResult::SlaveErrorOutOfRange}},
            {0x23, {tr("write protected"), OpResult::SlaveErrorWriteProtected}},
            {0x24, {tr("access denied"), OpResult::SlaveErrorAccessDenied}},
            {0x25, {tr("access locked"), OpResult::SlaveErrorAccessLocked}},
            {0x26, {tr("page invalid"), OpResult::SlaveErrorPageNotValid}},
            {0x27, {tr("page mode invalid"), OpResult::SlaveErrorModeNotValid}},
            {0x28, {tr("segment invalid"), OpResult::SlaveErrorSegmentNotValid}},
            {0x29, {tr("sequence"), OpResult::SlaveErrorSequence}},
            {0x2A, {tr("DAQ configuration invalid"), OpResult::SlaveErrorDAQConfig}},
            {0x30, {tr("memory overflow"), OpResult::SlaveErrorMemoryOverflow}},
            {0x31, {tr("generic"), OpResult::SlaveErrorGeneric}},
            {0x32, {tr("program verify failed"), OpResult::SlaveErrorVerify}}
        };

        quint8 code = replies[0][1];
        QPair<QString, OpResult> decoded;

        if(RESULT_CODES.count(code))
            decoded = RESULT_CODES[code];
        else
            decoded = {tr("undefined error code"), OpResult::SlaveErrorUndefined};

        QString msg = tr("Slave error: %1 %2").arg(decoded.first).arg(info);

        emit opMsg(decoded.second, msg, ext);

        return decoded.second;
    }
    else
    {
        QByteArray replyArr(reinterpret_cast<const char *>(replies[0].data()), replies[0].size());
        qDebug() << "Received" << replyArr.toHex();

        QString msg = tr("Bad reply %1").arg(info);

        emit opMsg(OpResult::BadReply, msg, ext);

        return OpResult::BadReply;
    }
}
OpResult Connection::getReplyResult(const std::vector<quint8> &reply, QString info, OpExtInfo ext)
{
    return getRepliesResult(std::vector<std::vector<quint8> >({reply}), info, ext);
}

OpResult Connection::uploadSegment(XcpPtr base, int len, std::vector<quint8> &out, OpType type)
{
    std::function<OpResult (void)> action = [this, base, len, type, &out]()
    {
        QString msg = tr("uploading data from address 0x%1 ext 0x%2, length %3").arg(base.addr, 8, 16, QChar('0')).arg(base.ext, 2, 16, QChar('0')).arg(len).toLocal8Bit();

        std::vector<quint8> query;
        std::vector<quint8> reply;
        if(mCalcMta && mCalcMta.get() == base)
            query = std::vector<quint8>({CmdCode_Upload, quint8(len / mAddrGran)});
        else
        {
            query = std::vector<quint8>({CmdCode_ShortUpload, quint8(len / mAddrGran), 0, base.ext, 0, 0, 0, 0});
            toSlaveEndian<quint32>(base.addr, query.data() + 4);
        }

        RESETMTA_RETURN_ON_FAIL(transact(query, mAddrGran + len, reply, msg, {type, query[0], base, len}));
        if(reply[0] != 0xFF)
        {
            mCalcMta.reset();
            return getReplyResult(reply, msg, {type, query[0], base, len});
        }

        mCalcMta = base + (len / mAddrGran);

        out = std::vector<quint8>(reply.begin() + mAddrGran, reply.begin() + mAddrGran + len);
        return OpResult::Success;
    };

    return tryQuery(action, type);
}

OpResult Connection::downloadSegment(XcpPtr base, const std::vector<quint8> &data, OpType type)
{
    std::vector<quint8> query({CmdCode_Download, quint8(data.size() / mAddrGran)});
    if(mAddrGran > 2)
        query.resize(mAddrGran);
    query.insert(query.end(), data.begin(), data.end());

    std::function<OpResult (void)> action = [this, base, query, type, &data]()
    {
        QString msg = tr("downloading data to address 0x%1 ext 0x%2, length %3").arg(base.addr, 8, 16, QChar('0')).arg(base.ext, 2, 16, QChar('0')).arg(data.size()).toLocal8Bit();

        if(!mCalcMta || mCalcMta.get() != base)
            RETURN_ON_FAIL(setMta(base, type));

        std::vector<quint8> reply;
        RESETMTA_RETURN_ON_FAIL(transact(query, 1, reply, msg, {type, CmdCode_Download, base, data.size()}));
        if(reply[0] != 0xFF)
        {
            mCalcMta.reset();
            return getReplyResult(reply, msg, {type, CmdCode_Download, base, data.size()});
        }

        mCalcMta = base + query[1];
        return OpResult::Success;
    };

    return tryQuery(action, type);
}

OpResult Connection::programPacket(XcpPtr base, const std::vector<quint8> &data, OpType type)
{
    Q_ASSERT(int(data.size()) % mAddrGran == 0);
    Q_ASSERT(int(data.size()) <= mPgmMaxDownPayload);

    quint32 nElem = data.size() / mAddrGran;
    std::vector<quint8> query({0xD0, quint8(nElem)});
    if(mAddrGran > 2)
        query.resize(mAddrGran);
    query.insert(query.end(), data.begin(), data.end());

    std::function<OpResult (void)> action = [this, base, query, nElem, type, &data]()
    {
        QString msg = tr("downloading program data to address 0x%1 ext 0x%2, length %3").arg(base.addr, 8, 16, QChar('0')).arg(base.ext, 2, 16, QChar('0')).arg(data.size()).toLocal8Bit();

        if(!mCalcMta || mCalcMta.get() != base)
            RETURN_ON_FAIL(setMta(base, type));

        std::vector<quint8> reply;
        RESETMTA_RETURN_ON_FAIL(transact(query, 1, reply, msg, {type, CmdCode_Program, base, data.size()}));
        if(reply[0] != 0xFF)
        {
            mCalcMta.reset();
            return getReplyResult(reply, msg, {type, CmdCode_Program, base, data.size()});
        }

        mCalcMta = base + query[1];
        return OpResult::Success;
    };

    return tryQuery(action, type);
}

OpResult Connection::programBlock(XcpPtr base, const std::vector<quint8> &data, OpType type)
{
    QReadLocker lock(&mIntfcLock);
    Q_ASSERT(mIntfc);
    Q_ASSERT(int(data.size()) % mAddrGran == 0);
    Q_ASSERT(int(data.size()) <= mPgmMaxBlocksize * mPgmMaxDownPayload);

    std::function<OpResult (void)> action = [this, base, data, type]()
    {
        QString msg = tr("downloading program data in block mode to address 0x%1 ext 0x%2, length %3").arg(base.addr, 8, 16, QChar('0')).arg(base.ext, 2, 16, QChar('0')).arg(data.size()).toLocal8Bit();

        if(!mCalcMta || mCalcMta.get() != base)
            RETURN_ON_FAIL(setMta(base, type));

        int remBytes = data.size();
        bool isFirstPacket = true;

        OpExtInfo ext = OpExtInfo();

        while(remBytes > 0)
        {
            // check for a pre-existing error (from a previous operation, or a previous iter of this operation)
            std::vector<std::vector<quint8> > replies;
            {
                OpResult readResult = mIntfc->receive(0, replies);
                if(readResult != OpResult::Success && readResult != OpResult::Timeout)
                {
                    mCalcMta.reset();
                    return readResult;
                }
            }
            // if no replies, everything is OK
            if(replies.size() > 0)
            {
                for(const std::vector<quint8> &reply : replies)
                {
                    if(reply.size() < 2 || reply[0] != 0xFE || reply[1] != 0x29)
                        return getRepliesResult(replies, msg, ext);   // not ERR_SEQUENCE
                }
                // if replies are all ERR_SEQUENCE, raise packet lost (and potentially try again)
                return OpResult::PacketLost;
            }

            int payloadBytes = std::min(remBytes, mPgmMaxDownPayload);
            std::vector<quint8> query = {quint8(isFirstPacket ? CmdCode_Program : CmdCode_ProgramNext), quint8(remBytes / mAddrGran)};
            if(mAddrGran > 2)
                query.resize(mAddrGran);
            std::vector<quint8>::const_iterator dataStartIt = data.end() - remBytes;
            std::vector<quint8>::const_iterator dataEndIt = dataStartIt + payloadBytes;
            query.insert(query.end(), dataStartIt, dataEndIt);
            remBytes -= payloadBytes;
            ext.type = type;
            ext.cmd = query[0];
            ext.addr = mCalcMta.get();
            ext.len = payloadBytes;
            RESETMTA_RETURN_ON_FAIL(mIntfc->transmit(query, (remBytes == 0)));
            mCalcMta.get().addr += payloadBytes;

            isFirstPacket = false;
        }

        std::vector<std::vector<quint8> > replies;
        RESETMTA_RETURN_ON_FAIL(mIntfc->receive(mTimeoutMsec, replies));
        if(replies.size() == 0)
        {
            emit opMsg(OpResult::Timeout, tr("Timeout while programming block"), ext);
            return OpResult::Timeout;
        }
        else if(replies.size() > 1 || replies[0].size() < 1 || replies[0][0] != 0xFF)
        {
            for(const std::vector<quint8> &reply : replies)
            {
                if(reply.size() < 2 || reply[0] != 0xFE || reply[1] != 0x29)
                    return getRepliesResult(replies, msg, ext);   // not ERR_SEQUENCE
            }
            // if replies are all ERR_SEQUENCE, raise packet lost (and potentially try again)
            return OpResult::PacketLost;
        }

        return OpResult::Success;
    };

    return tryQuery(action, type);
}

OpResult Connection::buildChecksum(XcpPtr base, int len, CksumType *typeOut, quint32 *cksumOut)
{
    if(len % mAddrGran != 0)
        return OpResult::AddrGranError;

    CksumType typeVal = CksumType::Invalid;
    quint32 cksumVal = 0;

    std::function<OpResult (void)> action = [this, base, len, &typeVal, &cksumVal, typeOut, cksumOut]()
    {
        QString msg = tr("building checksum at address 0x%1 ext 0x%2, length %3").arg(base.addr, 8, 16, QChar('0')).arg(base.ext, 2, 16, QChar('0')).arg(len).toLocal8Bit();
        static const std::map<quint8, CksumType> CKSUM_TYPE_CODES = {
            {0x01, CksumType::XCP_ADD_11},
            {0x02, CksumType::XCP_ADD_12},
            {0x03, CksumType::XCP_ADD_14},
            {0x04, CksumType::XCP_ADD_22},
            {0x05, CksumType::XCP_ADD_24},
            {0x06, CksumType::XCP_ADD_44},
            {0x07, CksumType::XCP_CRC_16},
            {0x08, CksumType::XCP_CRC_16_CITT},
            {0x09, CksumType::XCP_CRC_32},
            {0xFF, CksumType::XCP_USER_DEFINED}
        };

        std::vector<quint8> query;
        std::vector<quint8> reply;

        if(!mCalcMta || mCalcMta.get() != base)
            RETURN_ON_FAIL(setMta(base, OpType::BuildChecksum));

        query = {0xF3, 0, 0, 0, 0, 0, 0, 0};
        toSlaveEndian<quint32>(len / mAddrGran, query.data() + 4);

        RESETMTA_RETURN_ON_FAIL(transact(query, 8, reply, msg, {OpType::BuildChecksum, CmdCode_BuildChecksum, base, len}));
        if(reply[0] != 0xFF)
        {
            mCalcMta.reset();
            return getReplyResult(reply, msg, {OpType::BuildChecksum, CmdCode_BuildChecksum, base, len});
        }

        decltype(CKSUM_TYPE_CODES)::const_iterator type = CKSUM_TYPE_CODES.find(reply[1]);
        if(type == CKSUM_TYPE_CODES.end())
        {
            mCalcMta.reset();
            return getReplyResult(reply, msg, {OpType::BuildChecksum, CmdCode_BuildChecksum, base, len});
        }

        mCalcMta = base;
        typeVal = type->second;
        cksumVal = fromSlaveEndian<quint32>(reply.data() + 4);
        if(typeOut)
            *typeOut = typeVal;
        if(cksumOut)
            *cksumOut = cksumVal;
        return OpResult::Success;
    };

    EMIT_RETURN(buildChecksumDone, tryQuery(action, OpType::BuildChecksum), base, len, typeVal, cksumVal);
}

OpResult Connection::getAvailSlavesStr(QString bcastIdStr, QString filterStr, QList<QString> *out)
{
    boost::optional<Xcp::Interface::Can::Id> bcastId = Xcp::Interface::Can::StrToId(bcastIdStr);
    if(!bcastId)
    {
        emit getAvailSlavesStrDone(OpResult::InvalidArgument, bcastIdStr, filterStr, QList<QString>());
        return OpResult::InvalidArgument;
    }
    boost::optional<Xcp::Interface::Can::Filter> filter = Xcp::Interface::Can::StrToFilter(filterStr);
    if(!filter)
    {
        emit getAvailSlavesStrDone(OpResult::InvalidArgument, bcastIdStr, filterStr, QList<QString>());
        return OpResult::InvalidArgument;
    }
    std::vector<Interface::Can::SlaveId> ids;
    OpResult getAvailRes = getAvailSlaves(bcastId.get(), filter.get(), &ids);
    if(getAvailRes != OpResult::Success)
    {
        emit getAvailSlavesStrDone(getAvailRes, bcastIdStr, filterStr, QList<QString>());
        return getAvailRes;
    }
    QList<QString> idStrs;
    for(Interface::Can::SlaveId id : ids)
        idStrs.append(Interface::Can::SlaveIdToStr(id));
    if(out)
        *out = idStrs;
    emit getAvailSlavesStrDone(OpResult::Success, bcastIdStr, filterStr, idStrs);
    return OpResult::Success;
}

OpResult Connection::getAvailSlaves(Interface::Can::Id bcastId, Interface::Can::Filter filter, std::vector<Interface::Can::SlaveId> *out)
{
    if(!mIntfc)
    {
        emit getAvailSlavesDone(OpResult::InvalidOperation, bcastId, filter, std::vector<Interface::Can::SlaveId>());
        return OpResult::InvalidOperation;
    }
    SetupTools::Xcp::Interface::Can::Interface *canIntfc = qobject_cast<SetupTools::Xcp::Interface::Can::Interface *>(mIntfc);
    if(!canIntfc)
    {
        emit getAvailSlavesDone(OpResult::InvalidOperation, bcastId, filter, std::vector<Interface::Can::SlaveId>());
        return OpResult::InvalidOperation;
    }
    static const std::vector<quint8> QUERY = {CmdCode_TransportLayerCmd, 0xFF, 0x58, 0x43, 0x50, 0x00};
    static const std::vector<quint8> REPLYHEAD = {0xFF, 0x58, 0x43, 0x50};
    OpResult setFilterRes = canIntfc->setFilter(filter);
    if(setFilterRes != OpResult::Success)
    {
        emit getAvailSlavesDone(setFilterRes, bcastId, filter, std::vector<Interface::Can::SlaveId>());
        return setFilterRes;
    }
    OpResult clearReceivedRes = canIntfc->clearReceived();
    if(clearReceivedRes != OpResult::Success)
    {
        emit getAvailSlavesDone(clearReceivedRes, bcastId, filter, std::vector<Interface::Can::SlaveId>());
        return clearReceivedRes;
    }
    OpResult transmitRes = canIntfc->transmitTo(QUERY, bcastId);
    if(transmitRes != OpResult::Success)
    {
        emit getAvailSlavesDone(transmitRes, bcastId, filter, std::vector<Interface::Can::SlaveId>());
        return transmitRes;
    }

    if(mTimeoutMsec <= 0)
        return OpResult::InvalidArgument;
    QThread::msleep(mTimeoutMsec);
    std::vector<Xcp::Interface::Can::Frame> frames;
    canIntfc->receiveFrames(mTimeoutMsec, frames);
    std::vector<Interface::Can::SlaveId> ids;
    for(auto &frame : frames)
    {
        if(frame.data.size() < 8)
            continue;
        if(!std::equal(REPLYHEAD.begin(), REPLYHEAD.end(), frame.data.begin()))
            continue;
        Interface::Can::Id cmdId;
        cmdId.addr = qFromBigEndian<quint32>(frame.data.data() + 4);
        cmdId.type = frame.id.type;
        cmdId.addr &= (cmdId.type == Interface::Can::Id::Type::Ext) ? 0x1FFFFFFF : 0x7FF;
        ids.push_back({cmdId, frame.id});
    }
    if(out)
        *out = ids;
    emit getAvailSlavesDone(OpResult::Success, bcastId, filter, ids);
    return OpResult::Success;
}

bool Connection::isOpen() {
    return mConnected;
}

bool Connection::isCalMode() {
    return mConnected && !mPgmStarted;
}

bool Connection::isPgmMode() {
    return mConnected && mPgmStarted;
}

int Connection::addrGran() {
    if(mConnected)
        return mAddrGran;
    else
        return 0;
}

OpResult Connection::setMta(XcpPtr ptr, OpType type)
{
    QString msg = tr("setting slave Memory Transfer Address to 0x%1 ext 0x%2").arg(ptr.addr, 8, 16, QChar('0')).arg(ptr.ext, 2, 16, QChar('0')).toLocal8Bit();
    std::vector<quint8> query({CmdCode_SetMta, 0, 0, ptr.ext, 0, 0, 0, 0});
    toSlaveEndian<quint32>(ptr.addr, query.data() + 4);

    std::vector<quint8> reply;
    RESETMTA_RETURN_ON_FAIL(transact(query, 1, reply, msg, {type, CmdCode_SetMta, ptr}));
    if(reply[0] != 0xFF)
    {
        mCalcMta.reset();
        return getReplyResult(reply, msg, {type, CmdCode_SetMta, ptr});
    }
    mCalcMta = ptr;
    return OpResult::Success;
}

OpResult Connection::tryQuery(std::function<OpResult (void)> &action, OpType type)
{
    int failures = 0;
    while(failures < MAX_RETRIES)
    {
        OpResult res = action();
        if(res == OpResult::Success)
            return OpResult::Success;
        else if(res == OpResult::Timeout || res == OpResult::PacketLost)
            ++failures;
        else
            return res;

        while(failures < MAX_RETRIES)
        {
            OpResult synchRes = synch(type);
            if(synchRes == OpResult::Success)
                break;
            else if(synchRes == OpResult::Timeout)
                ++failures;
            else
                return synchRes;
        }
    }
    return OpResult::Timeout;
}

OpResult Connection::synch(OpType type)
{
    QReadLocker lock(&mIntfcLock);
    Q_ASSERT(mIntfc);
    if(mTimeoutMsec <= 0)
        return OpResult::InvalidArgument;
    RETURN_ON_FAIL(mIntfc->clearReceived());
    RETURN_ON_FAIL(mIntfc->transmit(std::vector<quint8>({CmdCode_Synch})));

    std::vector<std::vector<quint8> > replies;
    RETURN_ON_FAIL(mIntfc->receive(mTimeoutMsec, replies));

    if(replies.size() == 0)
    {
        emit opMsg(OpResult::Timeout, tr("Timeout while resynchronizing"), {type, CmdCode_Synch});
        return OpResult::Timeout;
    }

    if(replies.size() > 1 || replies[0] != std::vector<quint8>({0xFE, 0x00}))
        return getRepliesResult(replies, tr("resynchronizing"), {type, CmdCode_Synch});

    return OpResult::Success;
}

#pragma GCC diagnostic pop // "-Wmissing-field-uninitializers"

void Connection::updateEmitOpProgress(double newVal)
{
    QWriteLocker lock(&mOpProgressLock);
    mOpProgress = newVal;
    int newFracs = int(newVal / mOpProgressNotifyFrac);
    if(newFracs != mOpProgressFracs)
    {
        mOpProgressFracs = newFracs;
        lock.unlock();
        emit opProgressChanged();
    }
}

}   // namespace Xcp
}   // namespace SetupTools
