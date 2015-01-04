#include "Xcp_Connection.h"

#include <string.h>
#include <QtEndian>

#include "util.h"

namespace SetupTools
{
namespace Xcp
{

XcpConnection::XcpConnection(QSharedPointer<Interface::Interface> intfc, int timeoutMsec, int nvWriteTimeoutMsec, QObject *parent) :
    QObject(parent),
    mIntfc(intfc),
    mTimeoutMsec(timeoutMsec),
    mNvWriteTimeoutMsec(nvWriteTimeoutMsec),
    mConnected(false)
{}

void XcpConnection::open()
{
    static constexpr char OPMSG[] = "connecting to slave";

    std::vector<quint8> reply = transact({0xFF, 0x00}, 8, OPMSG);
    if(reply[0] != uchar(0xFF))
        throwReply(reply, OPMSG);
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
            throwReply(reply, OPMSG);
    }
    mMaxCto = reply[3];
    mMaxDownPayload = ((mMaxCto - 2) / mAddrGran) * mAddrGran;
    mMaxUpPayload = ((mMaxCto - 1) / mAddrGran) * mAddrGran;
    if(reply[6] != char(0x01) || reply[7] != char(0x01))
        throwReply(reply, OPMSG);

    mCalcMta.reset();
    mPgmStarted = false;
    mPgmMasterBlockMode = false;
    mConnected = true;
}

void XcpConnection::close()
{
    static constexpr char OPMSG[] = "disconnecting from slave";
    static const std::vector<quint8> QUERY = {0xFE};

    mConnected = false;
    transact(QUERY, 1, OPMSG);
}

std::vector<quint8> XcpConnection::upload(XcpPtr base, int len)
{
    Q_ASSERT(mConnected);
    if(len % mAddrGran)
        throw AddrGranError();

    int remBytes = len;
    XcpPtr packetPtr = base;
    std::vector<quint8> ret;

    while(remBytes > 0)
    {
        int packetBytes = std::min(remBytes, mMaxUpPayload);
        std::vector<quint8> seg(uploadSegment(packetPtr, packetBytes));
        ret.insert(ret.end(), seg.begin(), seg.end());
        remBytes -= packetBytes;
        packetPtr.addr += packetBytes;
    }
    return ret;
}

void XcpConnection::download(XcpPtr base, const std::vector<quint8> &data)
{
    Q_ASSERT(mConnected);
    if(data.size() % mAddrGran)
        throw AddrGranError();
    if(!mSupportsCalPage)
        throw InvalidOperation();

    int remBytes = data.size();
    XcpPtr packetPtr = base;
    const uchar *packetDataPtr = data.data();

    while(remBytes > 0)
    {
        int packetBytes = std::min(remBytes, mMaxDownPayload);
        downloadSegment(packetPtr, std::vector<quint8>(packetDataPtr, packetDataPtr + packetBytes));
        remBytes -= packetBytes;
        packetDataPtr += packetBytes;
        packetPtr.addr += packetBytes;
    }
}

void XcpConnection::nvWrite()
{
    Q_ASSERT(mConnected);
    if(!mSupportsCalPage)
        throw InvalidOperation();

}

void XcpConnection::setCalPage(quint8 segment, quint8 page)
{
    Q_ASSERT(mConnected);
    if(!mSupportsCalPage)
        throw InvalidOperation();

    std::vector<quint8> query({0xEB, 0x03, segment, page});

    mCalcMta.reset();   // standard does not define what happens to MTA

    std::function<void (void)> action = [this, query]()
    {
        static constexpr char OPMSG[] = "setting calibration segment/page";

        transact(query, 1, OPMSG);
    };

    tryQuery(action);
}

void XcpConnection::programStart()
{
    Q_ASSERT(mConnected);

}

void XcpConnection::programClear(XcpPtr base, int len)
{
    Q_ASSERT(mConnected && mPgmStarted);

    std::vector<quint8> query({0xD1, 0x00, 0, 0, 0, 0, 0, 0});
    toSlaveEndian<quint32>(len, query.data() + 4);

    mCalcMta.reset();   // standard does not define what happens to MTA

    std::function<void (void)> action = [this, base, query]()
    {
        static constexpr char OPMSG[] = "erasing program";

        if(!mCalcMta || mCalcMta.get() != base)
            setMta(base);

        transact(query, 1, OPMSG);
    };

    tryQuery(action);
}

void XcpConnection::programRange(XcpPtr base, const std::vector<quint8> &data)
{
    Q_ASSERT(mConnected && mPgmStarted);

}

void XcpConnection::programVerify(quint32 crc)
{
    Q_ASSERT(mConnected && mPgmStarted);

}

void XcpConnection::programReset()
{
    Q_ASSERT(mConnected && mPgmStarted);

}

std::vector<quint8> XcpConnection::transact(const std::vector<quint8> &cmd, int minReplyBytes, const char *msg, int timeoutMsec)
{
    mIntfc->transmit(cmd);

    std::vector<std::vector<quint8> > replies = mIntfc->receive(timeoutMsec < 0 ? mTimeoutMsec : timeoutMsec);

    if(replies.size() == 0)
        throw Timeout();

    Q_ASSERT(minReplyBytes > 0);
    if(replies.size() > 1 || replies[0].size() < size_t(minReplyBytes))
        throwReplies(replies, msg);

    return replies[0];
}

void XcpConnection::throwReplies(const std::vector<std::vector<quint8> > &replies, const char *msg)
{
    typedef std::pair<QString, SlaveError> ErrCodeData;
    static const std::map<quint8, ErrCodeData> ERR_CODE_MAP =
    {
        {0x10, {"busy", SlaveErrorBusy()}},
        {0x11, {"DAQ active", SlaveErrorDaqActive()}},
        {0x12, {"program active", SlaveErrorPgmActive()}},
        {0x20, {"command unknown", SlaveErrorCmdUnknown()}},
        {0x21, {"command syntax invalid", SlaveErrorCmdSyntax()}},
        {0x22, {"parameter out of range", SlaveErrorOutOfRange()}},
        {0x23, {"write protected", SlaveErrorWriteProtected()}},
        {0x24, {"access denied", SlaveErrorAccessDenied()}},
        {0x25, {"access locked", SlaveErrorAccessLocked()}},
        {0x26, {"page invalid", SlaveErrorPageNotValid()}},
        {0x27, {"page mode invalid", SlaveErrorModeNotValid()}},
        {0x28, {"segment invalid", SlaveErrorSegmentNotValid()}},
        {0x29, {"sequence", SlaveErrorSequence()}},
        {0x2A, {"DAQ configuration invalid", SlaveErrorDAQConfig()}},
        {0x30, {"memory overflow", SlaveErrorMemoryOverflow()}},
        {0x31, {"generic", SlaveErrorGeneric()}},
        {0x32, {"program verify failed", SlaveErrorVerify()}}
    };
    static const ErrCodeData ERR_CODE_UNDEF = {"undefined error code", SlaveErrorUndefined()};
    char appendMsg[256];
    Q_ASSERT(replies.size() >= 1);
    Q_ASSERT(!msg || strlen(msg) < sizeof(appendMsg) - 2);
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
        throw MultipleReplies();
    }

    if(replies[0].size() == 2 && quint8(replies[0][0]) == 0xFE)
    {
        // Look up message for error code, print to qCritical along with caller supplied message
        ErrCodeData codeData;
        typedef decltype(ERR_CODE_MAP) CodeMapType;
        CodeMapType::const_iterator itCodeData = ERR_CODE_MAP.find(quint8(replies[0][1]));
        if(itCodeData != ERR_CODE_MAP.end())
            codeData = itCodeData->second;
        else
            codeData = ERR_CODE_UNDEF;
        qCritical("Slave error: %s%s", reinterpret_cast<const char *>(codeData.first.constData()), appendMsg);

        // Throw appropriate exception for error code
        throw codeData.second;
    }
    else
    {
        QByteArray replyArr(reinterpret_cast<const char *>(replies[0].data()), replies[0].size());
        qDebug() << "Received" << replyArr.toHex();
        throw BadReply();
    }
}
void XcpConnection::throwReply(const std::vector<quint8> &reply, const char *msg)
{
    throwReplies(std::vector<std::vector<quint8> >({reply}), msg);
}

std::vector<quint8> XcpConnection::uploadSegment(XcpPtr base, int len)
{
    std::vector<quint8> ret;

    std::function<void (void)> action = [this, base, len, &ret]()
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

        try
        {
            reply = transact(query, mAddrGran + len, OPMSG);
            //FIXME now check 0xFF on all transact() calls
        } catch(ConnException)
        {
            mCalcMta.reset();
            throw;
        }

        mCalcMta = XcpPtr(base.addr + len / mAddrGran, base.ext);

        ret = std::move(std::vector<quint8>(reply.begin() + mAddrGran, reply.begin() + mAddrGran + len));
    };

    tryQuery(action);

    return ret;
}

void XcpConnection::downloadSegment(XcpPtr base, const std::vector<quint8> &data)
{
    std::vector<quint8> query({0xF0, quint8(data.size() / mAddrGran)});
    if(mAddrGran > 2)
        query.resize(mAddrGran);
    query.insert(query.end(), data.begin(), data.end());

    std::function<void (void)> action = [this, base, query]()
    {
        static constexpr char OPMSG[] = "downloading data";

        if(!mCalcMta || mCalcMta.get() != base)
            setMta(base);

        try
        {
            transact(query, 1, OPMSG);
        } catch(ConnException)
        {
            mCalcMta.reset();
            throw;
        }
    };

    tryQuery(action);
}

void XcpConnection::setMta(XcpPtr ptr)
{
    static constexpr char OPMSG[] = "setting slave Memory Transfer Address";
    std::vector<quint8> query({0xF6, 0, 0, ptr.ext, 0, 0, 0, 0});
    toSlaveEndian<quint32>(ptr.addr, query.data() + 4);

    try
    {
        transact(query, 1, OPMSG);
    } catch(ConnException)
    {
        mCalcMta.reset();
        throw;
    }
    mCalcMta = ptr;
}

void XcpConnection::tryQuery(std::function<void (void)> &action)
{
    int failures = 0;
    while(failures < MAX_RETRIES)
    {
        try
        {
            action();
            return; // return if it succeeds
        } catch(Timeout)
        {
            ++failures;
        } catch(PacketLost)
        {
            ++failures;
        }

        while(failures < MAX_RETRIES)
        {
            try
            {
                synch();
                break;
            } catch (Timeout)
            {
                ++failures;
            }
        }
    }
    throw Timeout();
}

void XcpConnection::synch()
{
    mIntfc->transmit(std::vector<quint8>({0xFC}));

    std::vector<std::vector<quint8> > replies = mIntfc->receive(mTimeoutMsec);

    if(replies.size() == 0)
        throw Timeout();

    if(replies.size() > 1 || replies[0] != std::vector<quint8>({0xFE, 0x00}))
        throwReplies(replies, "resynchronizing");
}

}   // namespace Xcp
}   // namespace SetupTools
