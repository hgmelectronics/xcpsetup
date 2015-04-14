#include "Xcp_Connection.h"

#include <string.h>
#include <QtEndian>
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

#define RESETMTA_RETURN_ON_FAIL(value) { OpResult EMIT_RETURN__ret = value; if(EMIT_RETURN__ret != OpResult::Success) { mCalcMta.reset(); return EMIT_RETURN__ret; } }

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
        case CksumType::XCP_USER_DEFINED:
            Q_ASSERT(type != CksumType::XCP_USER_DEFINED);
            break;
        default:
            Q_ASSERT(0);
            break;
    }
    return 0;
}

Connection::Connection(QObject *parent) :
    QObject(parent),
    mTimeoutMsec(0),
    mNvWriteTimeoutMsec(0),
    mResetTimeoutMsec(0),
    mConnected(false)
{
    qRegisterMetaType<XcpPtr>("XcpPtr");
    qRegisterMetaType<OpResult>();
    qRegisterMetaType<OpResultWrapper::OpResult>();
    qRegisterMetaType<CksumType>();
    qRegisterMetaType<std::vector<quint8> >();
}

QObject *Connection::intfc()
{
    QReadLocker lock(&mIntfcLock);
    return mIntfc;
}

void Connection::setIntfc(QObject *intfc)
{
    QWriteLocker lock(&mIntfcLock);
    mIntfc = qobject_cast<Interface::Interface *>(intfc);
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

int Connection::resetTimeout()
{
    return mResetTimeoutMsec;
}

void Connection::setResetTimeout(int msec)
{
    mResetTimeoutMsec = msec;
}

Connection::State Connection::state()
{
    QReadLocker lock(&mIntfcLock);
    if(mIntfc == NULL)
        return State::IntfcInvalid;
    else if(!mConnected)
        return State::Closed;
    else if(!mPgmStarted)
        return State::CalMode;
    else
        return State::PgmMode;
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
        EMIT_RETURN(setStateDone, close());
        break;
    case State::CalMode:
        if(mConnected)
        {
            Q_ASSERT(mPgmStarted);
            // need to do program reset
            EMIT_RETURN_ON_FAIL(setStateDone, programReset());
            EMIT_RETURN(setStateDone, open(mResetTimeoutMsec));
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

OpResult Connection::open(boost::optional<int> timeoutMsec)
{
    static constexpr char OPMSG[] = "connecting to slave";

    mConnected = false;
    mCalcMta.reset();
    emit stateChanged();

    std::vector<quint8> reply;
    EMIT_RETURN_ON_FAIL(openDone, transact({0xFF, 0x00}, 8, reply, OPMSG, timeoutMsec));
    if(reply[0] != 0xFF)
        EMIT_RETURN(openDone, getReplyResult(reply, OPMSG));
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
            EMIT_RETURN(openDone, getReplyResult(reply, OPMSG));
            break;
    }
    mMaxCto = reply[3];
    mMaxDownPayload = ((mMaxCto - 2) / mAddrGran) * mAddrGran;
    mMaxUpPayload = ((mMaxCto - 1) / mAddrGran) * mAddrGran;
    if(reply[6] != char(0x01) || reply[7] != char(0x01))
        EMIT_RETURN(openDone, getReplyResult(reply, OPMSG));

    mPgmStarted = false;
    mPgmMasterBlockMode = false;
    mConnected = true;
    emit stateChanged();

    EMIT_RETURN(openDone, OpResult::Success);
}

OpResult Connection::close()
{
    static constexpr char OPMSG[] = "disconnecting from slave";

    mConnected = false;
    mCalcMta.reset();
    emit stateChanged();
    std::vector<quint8> reply;
    EMIT_RETURN_ON_FAIL(closeDone, transact({0xFE}, 1, reply, OPMSG));
    if(reply[0] != 0xFF)
        EMIT_RETURN(closeDone, getReplyResult(reply, OPMSG));

    EMIT_RETURN(closeDone, OpResult::Success);
}

OpResult Connection::upload(XcpPtr base, int len, std::vector<quint8> *out)
{
    if(!mConnected)
        EMIT_RETURN(uploadDone, OpResult::NotConnected);
    if(len % mAddrGran)
        EMIT_RETURN(uploadDone, OpResult::AddrGranError);

    int remBytes = len;
    XcpPtr packetPtr = base;

    std::vector<quint8> data;
    while(remBytes > 0)
    {
        int packetBytes = std::min(remBytes, mMaxUpPayload);
        std::vector<quint8> seg;
        EMIT_RETURN_ON_FAIL(uploadDone, uploadSegment(packetPtr, packetBytes, seg));
        data.insert(data.end(), seg.begin(), seg.end());
        remBytes -= packetBytes;
        packetPtr.addr += packetBytes / mAddrGran;
    }
    emit uploadDone(OpResult::Success, data);
    if(out)
        *out = data;
    return OpResult::Success;
}

OpResult Connection::download(XcpPtr base, const std::vector<quint8> data)
{
    if(!mConnected)
        EMIT_RETURN(downloadDone, OpResult::NotConnected);
    if(mPgmStarted)
        EMIT_RETURN(programClearDone, OpResult::WrongMode);
    if(data.size() % mAddrGran)
        EMIT_RETURN(downloadDone, OpResult::AddrGranError);
    if(!mSupportsCalPage)
        EMIT_RETURN(downloadDone, OpResult::InvalidOperation);

    int remBytes = data.size();
    XcpPtr packetPtr = base;
    const uchar *packetDataPtr = data.data();

    while(remBytes > 0)
    {
        int packetBytes = std::min(remBytes, mMaxDownPayload);
        EMIT_RETURN_ON_FAIL(downloadDone, downloadSegment(packetPtr, std::vector<quint8>(packetDataPtr, packetDataPtr + packetBytes)));
        remBytes -= packetBytes;
        packetDataPtr += packetBytes;
        packetPtr.addr += packetBytes / mAddrGran;
    }
    EMIT_RETURN(downloadDone, OpResult::Success);
}

OpResult Connection::nvWrite()
{
    QReadLocker lock(&mIntfcLock);
    Q_ASSERT(mIntfc);
    if(!mConnected)
        EMIT_RETURN(nvWriteDone, OpResult::NotConnected);
    if(mPgmStarted)
        EMIT_RETURN(programClearDone, OpResult::WrongMode);
    if(!mSupportsCalPage)
        EMIT_RETURN(nvWriteDone, OpResult::InvalidOperation);

    std::function<OpResult (void)> action = [this]()
    {
        static constexpr char SET_REQ_OPMSG[] = "writing nonvolatile memory";
        // do not use transact() since slave might send two packets (reply plus EV_STORE_CAL)
        {
            RETURN_ON_FAIL(mIntfc->transmit({0xF9, 0x01, 0x00, 0x00}));
            bool setReqRepliedTo = false;
            bool writeComplete = false;
            QElapsedTimer replyTimer;
            replyTimer.start();

            while(1)
            {
                int timeout = std::max(mTimeoutMsec - int(replyTimer.elapsed()), 0);
                std::vector<std::vector<quint8> > replies;
                RETURN_ON_FAIL(mIntfc->receive(timeout, replies));

                if(replies.size() == 0)
                    return OpResult::Timeout;

                for(std::vector<quint8> &reply : replies)
                {
                    if(reply.size() >= 1 && reply[0] == 0xFF)
                        setReqRepliedTo = true;
                    else if(reply.size() >= 2 && reply[0] == 0xFD && reply[1] == 0x03)
                        writeComplete = true;
                    else
                        return getReplyResult(reply, SET_REQ_OPMSG);
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
            static constexpr char GET_STS_OPMSG[] = "waiting for nonvolatile memory write to finish";

            // do not use transact() since slave might send two packets (reply plus EV_STORE_CAL)
            RETURN_ON_FAIL(mIntfc->transmit({0xFD}));
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
                    return OpResult::Timeout;

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
                        return getReplyResult(reply, GET_STS_OPMSG);
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
        return OpResult::Timeout; // Exited outer while() loop due to timeout
    };

    EMIT_RETURN(nvWriteDone, tryQuery(action));
}

OpResult Connection::setCalPage(quint8 segment, quint8 page)
{
    if(!mConnected)
        EMIT_RETURN(setCalPageDone, OpResult::NotConnected);
    if(mPgmStarted)
        EMIT_RETURN(programClearDone, OpResult::WrongMode);
    if(!mSupportsCalPage)
        EMIT_RETURN(setCalPageDone, OpResult::InvalidOperation);

    std::vector<quint8> query({0xEB, 0x03, segment, page});

    mCalcMta.reset();   // standard does not define what happens to MTA

    std::function<OpResult (void)> action = [this, query]()
    {
        static constexpr char OPMSG[] = "setting calibration segment/page";

        std::vector<quint8> reply;
        RETURN_ON_FAIL(transact(query, 1, reply, OPMSG));
        if(reply[0] != 0xFF)
            return getReplyResult(reply, OPMSG);

        return OpResult::Success;
    };

    EMIT_RETURN(setCalPageDone, tryQuery(action));
}

OpResult Connection::programStart()
{
    if(!mConnected)
        EMIT_RETURN(programStartDone, OpResult::NotConnected);

    std::function<OpResult (void)> action = [this]()
    {
        static constexpr char OPMSG[] = "entering program mode";
        std::vector<quint8> reply;
        RETURN_ON_FAIL(transact({0xD2}, 7, reply, OPMSG));
        if(reply[0] != 0xFF)
            return getReplyResult(reply, OPMSG);
        mPgmMasterBlockMode = reply[2] & 0x01;
        mPgmMaxCto = reply[3];
        if(mPgmMaxCto < 8)
            return getReplyResult(reply, OPMSG);
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

    EMIT_RETURN(programStartDone, tryQuery(action));
}

OpResult Connection::programClear(XcpPtr base, int len)
{
    if(!mConnected)
        EMIT_RETURN(programClearDone, OpResult::NotConnected);
    if(!mPgmStarted)
        EMIT_RETURN(programClearDone, OpResult::WrongMode);
    if(len % mAddrGran)
        EMIT_RETURN(programClearDone, OpResult::AddrGranError);

    std::vector<quint8> query({0xD1, 0x00, 0, 0, 0, 0, 0, 0});
    toSlaveEndian<quint32>(len / mAddrGran, query.data() + 4);

    mCalcMta.reset();   // standard does not define what happens to MTA

    std::function<OpResult (void)> action = [this, base, query]()
    {
        static constexpr char OPMSG[] = "erasing program";

        if(!mCalcMta || mCalcMta.get() != base)
            RETURN_ON_FAIL(setMta(base));

        std::vector<quint8> reply;
        RETURN_ON_FAIL(transact(query, 1, reply, OPMSG));
        if(reply[0] != 0xFF)
            return getReplyResult(reply, OPMSG);

        return OpResult::Success;
    };

    EMIT_RETURN(programClearDone, tryQuery(action));
}

OpResult Connection::programRange(XcpPtr base, const std::vector<quint8> data)
{
    if(!mConnected)
        EMIT_RETURN(programClearDone, OpResult::NotConnected);
    if(!mPgmStarted)
        EMIT_RETURN(programClearDone, OpResult::WrongMode);
    if(data.size() % mAddrGran)
        EMIT_RETURN(programRangeDone, OpResult::AddrGranError);

    std::vector<quint8>::const_iterator dataIt = data.begin();
    while(dataIt != data.end())
    {
        XcpPtr startPtr = {quint32(base.addr + std::distance(data.begin(), dataIt) / mAddrGran), base.ext};
        if(mPgmMasterBlockMode)
        {
            int blockBytes = std::min(std::distance(dataIt, data.end()), ssize_t(mPgmMaxBlocksize * mPgmMaxDownPayload));
            std::vector<quint8> blockData(dataIt, dataIt + blockBytes);
            EMIT_RETURN_ON_FAIL(programRangeDone, programBlock(startPtr, blockData));
            dataIt += blockBytes;
        }
        else
        {
            int packetBytes = std::min(std::distance(dataIt, data.end()), ssize_t(mPgmMaxDownPayload));
            std::vector<quint8> packetData(dataIt, dataIt + packetBytes);
            EMIT_RETURN_ON_FAIL(programRangeDone, programPacket(startPtr, packetData));
            dataIt += packetBytes;
        }
    }
    return OpResult::Success;
}

OpResult Connection::programVerify(quint32 crc)
{
    if(!mConnected)
        EMIT_RETURN(programClearDone, OpResult::NotConnected);
    if(!mPgmStarted)
        EMIT_RETURN(programClearDone, OpResult::WrongMode);

    std::vector<quint8> query({0xC8, 0x01, 0, 0, 0, 0, 0, 0});
    toSlaveEndian<quint16>(0x0002, query.data() + 2);
    toSlaveEndian<quint32>(crc, query.data() + 4);

    std::function<OpResult (void)> action = [this, query]()
    {
        static constexpr char OPMSG[] = "verifying program";

        std::vector<quint8> reply;
        RETURN_ON_FAIL(transact(query, 1, reply, OPMSG));
        if(reply[0] != 0xFF)
            return getReplyResult(reply, OPMSG);

        return OpResult::Success;
    };

    EMIT_RETURN(programVerifyDone, tryQuery(action));
}

OpResult Connection::programReset()
{
    if(!mConnected)
        EMIT_RETURN(programClearDone, OpResult::NotConnected);
    if(!mPgmStarted)
        EMIT_RETURN(programClearDone, OpResult::WrongMode);

    std::function<OpResult (void)> action = [this]()
    {
        static constexpr char OPMSG[] = "resetting slave";

        std::vector<quint8> reply;
        RETURN_ON_FAIL(transact({0xCF}, 1, reply, OPMSG));
        if(reply[0] != 0xFF)
            return getReplyResult(reply, OPMSG);

        mConnected = false;
        mCalcMta.reset();
        emit stateChanged();
        return OpResult::Success;
    };

    EMIT_RETURN(programResetDone, tryQuery(action));
}

OpResult Connection::transact(const std::vector<quint8> &cmd, int minReplyBytes, std::vector<quint8> &out, const char *msg, boost::optional<int> timeoutMsec)
{
    QReadLocker lock(&mIntfcLock);
    Q_ASSERT(mIntfc);
    RETURN_ON_FAIL(mIntfc->clearReceived());
    RETURN_ON_FAIL(mIntfc->transmit(cmd));

    std::vector<std::vector<quint8> > replies;
    RETURN_ON_FAIL(mIntfc->receive(timeoutMsec.get_value_or(mTimeoutMsec), replies));

    if(replies.size() == 0)
        return OpResult::Timeout;

    Q_ASSERT(minReplyBytes > 0);
    if(replies.size() > 1 || replies[0].size() < size_t(minReplyBytes))
        return getRepliesResult(replies, msg);

    out = replies[0];
    return OpResult::Success;
}

OpResult Connection::getRepliesResult(const std::vector<std::vector<quint8> > &replies, const char *msg)
{
    char appendMsg[(msg ? strlen(msg) : 0) + 2];
    Q_ASSERT(replies.size() >= 1);
    if(msg) {
        strcpy(appendMsg, " ");
        strcat(appendMsg, msg);
    }
    else
        appendMsg[0] = '\0';

    if(replies.size() > 1)
    {
        qCritical("Multiple replies received%s", appendMsg);
        for(const std::vector<quint8> &reply : replies)
        {
            QByteArray replyArr(reinterpret_cast<const char *>(reply.data()), reply.size());
            qDebug() << "Received" << replyArr.toHex();
        }
        return OpResult::MultipleReplies;
    }

    if(replies[0].size() >= 2 && quint8(replies[0][0]) == 0xFE)
    {
        const char *appendBase = &*appendMsg;   // capturing appendMsg causes g++ 4.8.2 internal error
        auto printMsg = [appendBase](const char *codeDesc)
        {
            char msg[strlen(codeDesc) + strlen(appendBase) + 15];
            strcpy(msg, "Slave error: ");
            strcat(msg, codeDesc);
            strcat(msg, appendBase);
            qCritical("%s", msg);
        };

        switch(replies[0][1])
        {
            case 0x10:  printMsg("busy");                       return OpResult::SlaveErrorBusy;            break;
            case 0x11:  printMsg("DAQ active");                 return OpResult::SlaveErrorDaqActive;       break;
            case 0x12:  printMsg("program active");             return OpResult::SlaveErrorPgmActive;       break;
            case 0x20:  printMsg("command unknown");            return OpResult::SlaveErrorCmdUnknown;      break;
            case 0x21:  printMsg("command syntax invalid");     return OpResult::SlaveErrorCmdSyntax;       break;
            case 0x22:  printMsg("parameter out of range");     return OpResult::SlaveErrorOutOfRange;      break;
            case 0x23:  printMsg("write protected");            return OpResult::SlaveErrorWriteProtected;  break;
            case 0x24:  printMsg("access denied");              return OpResult::SlaveErrorAccessDenied;    break;
            case 0x25:  printMsg("access locked");              return OpResult::SlaveErrorAccessLocked;    break;
            case 0x26:  printMsg("page invalid");               return OpResult::SlaveErrorPageNotValid;    break;
            case 0x27:  printMsg("page mode invalid");          return OpResult::SlaveErrorModeNotValid;    break;
            case 0x28:  printMsg("segment invalid");            return OpResult::SlaveErrorSegmentNotValid; break;
            case 0x29:  printMsg("sequence");                   return OpResult::SlaveErrorSequence;        break;
            case 0x2A:  printMsg("DAQ configuration invalid");  return OpResult::SlaveErrorDAQConfig;       break;
            case 0x30:  printMsg("memory overflow");            return OpResult::SlaveErrorMemoryOverflow;  break;
            case 0x31:  printMsg("generic");                    return OpResult::SlaveErrorGeneric;         break;
            case 0x32:  printMsg("program verify failed");      return OpResult::SlaveErrorVerify;          break;
            default:    printMsg("undefined error code");       return OpResult::SlaveErrorUndefined;       break;
        }
    }
    else
    {
        QByteArray replyArr(reinterpret_cast<const char *>(replies[0].data()), replies[0].size());
        qDebug() << "Received" << replyArr.toHex();
        return OpResult::BadReply;
    }
}
OpResult Connection::getReplyResult(const std::vector<quint8> &reply, const char *msg)
{
    return getRepliesResult(std::vector<std::vector<quint8> >({reply}), msg);
}

OpResult Connection::uploadSegment(XcpPtr base, int len, std::vector<quint8> &out)
{
    std::function<OpResult (void)> action = [this, base, len, &out]()
    {
        static constexpr char OPMSG[] = "uploading data";

        std::vector<quint8> query;
        std::vector<quint8> reply;
        if(mCalcMta && mCalcMta.get() == base)
            query = std::vector<quint8>({0xF5, quint8(len / mAddrGran)});
        else
        {
            query = std::vector<quint8>({0xF4, quint8(len / mAddrGran), 0, base.ext, 0, 0, 0, 0});
            toSlaveEndian<quint32>(base.addr, query.data() + 4);
        }

        RESETMTA_RETURN_ON_FAIL(transact(query, mAddrGran + len, reply, OPMSG));
        if(reply[0] != 0xFF)
        {
            mCalcMta.reset();
            return getReplyResult(reply, OPMSG);
        }

        mCalcMta = {base.addr + len / mAddrGran, base.ext};

        out = std::move(std::vector<quint8>(reply.begin() + mAddrGran, reply.begin() + mAddrGran + len));
        return OpResult::Success;
    };

    return tryQuery(action);
}

OpResult Connection::downloadSegment(XcpPtr base, const std::vector<quint8> &data)
{
    std::vector<quint8> query({0xF0, quint8(data.size() / mAddrGran)});
    if(mAddrGran > 2)
        query.resize(mAddrGran);
    query.insert(query.end(), data.begin(), data.end());

    std::function<OpResult (void)> action = [this, base, query]()
    {
        static constexpr char OPMSG[] = "downloading data";

        if(!mCalcMta || mCalcMta.get() != base)
            RETURN_ON_FAIL(setMta(base));

        std::vector<quint8> reply;
        RESETMTA_RETURN_ON_FAIL(transact(query, 1, reply, OPMSG));
        if(reply[0] != 0xFF)
        {
            mCalcMta.reset();
            return getReplyResult(reply, OPMSG);
        }

        mCalcMta = {base.addr + query[1], base.ext};
        return OpResult::Success;
    };

    return tryQuery(action);
}

OpResult Connection::programPacket(XcpPtr base, const std::vector<quint8> &data)
{
    Q_ASSERT(int(data.size()) % mAddrGran == 0);
    Q_ASSERT(int(data.size()) <= mPgmMaxDownPayload);

    quint32 nElem = data.size() / mAddrGran;
    std::vector<quint8> query({0xD0, quint8(nElem)});
    if(mAddrGran > 2)
        query.resize(mAddrGran);
    query.insert(query.end(), data.begin(), data.end());

    std::function<OpResult (void)> action = [this, base, query, nElem]()
    {
        static constexpr char OPMSG[] = "downloading program data";

        if(!mCalcMta || mCalcMta.get() != base)
            RETURN_ON_FAIL(setMta(base));

        std::vector<quint8> reply;
        RESETMTA_RETURN_ON_FAIL(transact(query, 1, reply, OPMSG));
        if(reply[0] != 0xFF)
        {
            mCalcMta.reset();
            return getReplyResult(reply, OPMSG);
        }

        mCalcMta = {base.addr + query[1], base.ext};
        return OpResult::Success;
    };

    return tryQuery(action);
}

OpResult Connection::programBlock(XcpPtr base, const std::vector<quint8> &data)
{
    QReadLocker lock(&mIntfcLock);
    Q_ASSERT(mIntfc);
    Q_ASSERT(int(data.size()) % mAddrGran == 0);
    Q_ASSERT(int(data.size()) <= mPgmMaxBlocksize * mPgmMaxDownPayload);

    std::function<OpResult (void)> action = [this, base, data]()
    {
        static constexpr char OPMSG[] = "downloading program data in block mode";

        if(!mCalcMta || mCalcMta.get() != base)
            RETURN_ON_FAIL(setMta(base));

        int remBytes = data.size();
        bool isFirstPacket = true;

        while(remBytes > 0)
        {
            // check for a pre-existing error (from a previous operation, or a previous iter of this operation)
            std::vector<std::vector<quint8> > replies;
            RESETMTA_RETURN_ON_FAIL(mIntfc->receive(0, replies));
            // if no replies, everything is OK
            if(replies.size() > 0)
            {
                for(const std::vector<quint8> &reply : replies)
                {
                    if(reply.size() < 2 || reply[0] != 0xFE || reply[1] != 0x29)
                        return getRepliesResult(replies, OPMSG);   // not ERR_SEQUENCE
                }
                // if replies are all ERR_SEQUENCE, raise packet lost (and potentially try again)
                return OpResult::PacketLost;
            }

            int payloadBytes = std::min(remBytes, mPgmMaxDownPayload);
            std::vector<quint8> query = {quint8(isFirstPacket ? 0xD0 : 0xCA), quint8(remBytes / mAddrGran)};
            if(mAddrGran > 2)
                query.resize(mAddrGran);
            std::vector<quint8>::const_iterator dataStartIt = data.end() - remBytes;
            std::vector<quint8>::const_iterator dataEndIt = dataStartIt + payloadBytes;
            query.insert(query.end(), dataStartIt, dataEndIt);
            RESETMTA_RETURN_ON_FAIL(mIntfc->transmit(query));
            remBytes -= payloadBytes;
            mCalcMta.get().addr += payloadBytes;

            isFirstPacket = false;
        }

        std::vector<std::vector<quint8> > replies;
        RESETMTA_RETURN_ON_FAIL(mIntfc->receive(mTimeoutMsec, replies));
        if(replies.size() == 0)
            return OpResult::Timeout;
        else if(replies.size() > 1 || replies[0].size() < 1 || replies[0][0] != 0xFF)
        {
            for(const std::vector<quint8> &reply : replies)
            {
                if(reply.size() < 2 || reply[0] != 0xFE || reply[1] != 0x29)
                    return getRepliesResult(replies, OPMSG);   // not ERR_SEQUENCE
            }
            // if replies are all ERR_SEQUENCE, raise packet lost (and potentially try again)
            return OpResult::PacketLost;
        }

        return OpResult::Success;
    };

    return tryQuery(action);
}

OpResult Connection::buildChecksum(XcpPtr base, int len, CksumType *typeOut, quint32 *cksumOut)
{
    if(len % mAddrGran != 0)
        return OpResult::AddrGranError;

    std::function<OpResult (void)> action = [this, base, len, typeOut, cksumOut]()
    {
        static constexpr char OPMSG[] = "building checksum";
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
            RETURN_ON_FAIL(setMta(base));

        query = {0xF3, 0, 0, 0, 0, 0, 0, 0};
        toSlaveEndian<quint32>(len / mAddrGran, query.data() + 4);

        RESETMTA_RETURN_ON_FAIL(transact(query, 8, reply, OPMSG));
        if(reply[0] != 0xFF)
        {
            mCalcMta.reset();
            return getReplyResult(reply, OPMSG);
        }

        decltype(CKSUM_TYPE_CODES)::const_iterator type = CKSUM_TYPE_CODES.find(reply[1]);
        if(type == CKSUM_TYPE_CODES.end())
        {
            mCalcMta.reset();
            return getReplyResult(reply, OPMSG);
        }

        mCalcMta = base;
        if(typeOut)
            *typeOut = type->second;
        if(cksumOut)
            *cksumOut = fromSlaveEndian<quint32>(reply.data() + 4);
        emit buildChecksumDone(OpResult::Success, type->second, fromSlaveEndian<quint32>(reply.data() + 4));
        return OpResult::Success;
    };

    EMIT_RETURN_ON_FAIL(buildChecksumDone, tryQuery(action));
    return OpResult::Success;
}

OpResult Connection::getAvailSlavesStr(QString bcastIdStr, QString filterStr, QList<QString> *out)
{
    boost::optional<Xcp::Interface::Can::Id> bcastId = Xcp::Interface::Can::StrToId(bcastIdStr);
    if(!bcastId)
    {
        emit getAvailSlavesStrDone(OpResult::InvalidArgument, QList<QString>());
        return OpResult::InvalidArgument;
    }
    boost::optional<Xcp::Interface::Can::Filter> filter = Xcp::Interface::Can::StrToFilter(filterStr);
    if(!filter)
    {
        emit getAvailSlavesStrDone(OpResult::InvalidArgument, QList<QString>());
        return OpResult::InvalidArgument;
    }
    std::vector<Interface::Can::SlaveId> ids;
    OpResult getAvailRes = getAvailSlaves(bcastId.get(), filter.get(), &ids);
    if(getAvailRes != OpResult::Success)
    {
        emit getAvailSlavesStrDone(getAvailRes, QList<QString>());
        return getAvailRes;
    }
    QList<QString> idStrs;
    for(Interface::Can::SlaveId id : ids)
        idStrs.append(Interface::Can::SlaveIdToStr(id));
    if(out)
        *out = idStrs;
    emit getAvailSlavesStrDone(OpResult::Success, idStrs);
    return OpResult::Success;
}

OpResult Connection::getAvailSlaves(Interface::Can::Id bcastId, Interface::Can::Filter filter, std::vector<Interface::Can::SlaveId> *out)
{
    SetupTools::Xcp::Interface::Can::Interface *canIntfc = qobject_cast<SetupTools::Xcp::Interface::Can::Interface *>(mIntfc);
    if(!canIntfc)
    {
        emit getAvailSlavesDone(OpResult::InvalidOperation, std::vector<Interface::Can::SlaveId>());
        return OpResult::InvalidOperation;
    }
    static const std::vector<quint8> QUERY = {0xF2, 0xFF, 0x58, 0x43, 0x50, 0x00};
    static const std::vector<quint8> REPLYHEAD = {0xFF, 0x58, 0x43, 0x50};
    OpResult setFilterRes = canIntfc->setFilter(filter);
    if(setFilterRes != OpResult::Success)
    {
        emit getAvailSlavesDone(setFilterRes, std::vector<Interface::Can::SlaveId>());
        return setFilterRes;
    }
    OpResult clearReceivedRes = canIntfc->clearReceived();
    if(clearReceivedRes != OpResult::Success)
    {
        emit getAvailSlavesDone(clearReceivedRes, std::vector<Interface::Can::SlaveId>());
        return clearReceivedRes;
    }
    OpResult transmitRes = canIntfc->transmitTo(QUERY, bcastId);
    if(transmitRes != OpResult::Success)
    {
        emit getAvailSlavesDone(transmitRes, std::vector<Interface::Can::SlaveId>());
        return transmitRes;
    }
    QThread::msleep(mTimeoutMsec);

    std::vector<Xcp::Interface::Can::Frame> frames;
    canIntfc->receiveFrames(0, frames);
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
    emit getAvailSlavesDone(OpResult::Success, ids);
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

OpResult Connection::setMta(XcpPtr ptr)
{
    static constexpr char OPMSG[] = "setting slave Memory Transfer Address";
    std::vector<quint8> query({0xF6, 0, 0, ptr.ext, 0, 0, 0, 0});
    toSlaveEndian<quint32>(ptr.addr, query.data() + 4);

    std::vector<quint8> reply;
    RESETMTA_RETURN_ON_FAIL(transact(query, 1, reply, OPMSG));
    if(reply[0] != 0xFF)
    {
        mCalcMta.reset();
        return getReplyResult(reply, OPMSG);
    }
    mCalcMta = ptr;
    return OpResult::Success;
}

OpResult Connection::tryQuery(std::function<OpResult (void)> &action)
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
            OpResult synchRes = synch();
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

OpResult Connection::synch()
{
    QReadLocker lock(&mIntfcLock);
    Q_ASSERT(mIntfc);
    RETURN_ON_FAIL(mIntfc->clearReceived());
    RETURN_ON_FAIL(mIntfc->transmit(std::vector<quint8>({0xFC})));

    std::vector<std::vector<quint8> > replies;
    RETURN_ON_FAIL(mIntfc->receive(mTimeoutMsec, replies));

    if(replies.size() == 0)
        return OpResult::Timeout;

    if(replies.size() > 1 || replies[0] != std::vector<quint8>({0xFE, 0x00}))
        return getRepliesResult(replies, "resynchronizing");

    return OpResult::Success;
}

}   // namespace Xcp
}   // namespace SetupTools
