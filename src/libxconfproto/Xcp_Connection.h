#ifndef XCP_CONNECTION_H
#define XCP_CONNECTION_H

#include <QObject>
#include <QReadWriteLock>
#include <QtEndian>
#include <boost/optional.hpp>
#include <boost/range/iterator_range.hpp>
#include <vector>

#include "libxconfproto_global.h"
#include "Xcp_Interface_Interface.h"
#include "Xcp_Interface_Can_Interface.h"

namespace SetupTools
{
namespace Xcp
{

class ConnException : public ::SetupTools::Xcp::Exception {};

class Timeout : public ConnException {};
class InvalidOperation : public ConnException {};
class BadReply : public ConnException {};
class PacketLost : public ConnException {};
class SlaveError : public ConnException {};
class AddrGranError : public ConnException {};

class SlaveErrorBusy : public SlaveError {};
class SlaveErrorDaqActive : public SlaveError {};
class SlaveErrorPgmActive : public SlaveError {};
class SlaveErrorCmdUnknown : public SlaveError {};
class SlaveErrorCmdSyntax : public SlaveError {};
class SlaveErrorOutOfRange : public SlaveError {};
class SlaveErrorWriteProtected : public SlaveError {};
class SlaveErrorAccessDenied : public SlaveError {};
class SlaveErrorAccessLocked : public SlaveError {};
class SlaveErrorPageNotValid : public SlaveError {};
class SlaveErrorModeNotValid : public SlaveError {};
class SlaveErrorSegmentNotValid : public SlaveError {};
class SlaveErrorSequence : public SlaveError {};
class SlaveErrorDAQConfig : public SlaveError {};
class SlaveErrorMemoryOverflow : public SlaveError {};
class SlaveErrorGeneric : public SlaveError {};
class SlaveErrorVerify : public SlaveError {};
class SlaveErrorUndefined : public SlaveError {};

class MultipleReplies : public ConnException {};

enum class CksumType {
    Invalid,
    XCP_ADD_11,
    XCP_ADD_12,
    XCP_ADD_14,
    XCP_ADD_22,
    XCP_ADD_24,
    XCP_ADD_44,
    XCP_CRC_16,
    XCP_CRC_16_CITT,    // [sic]; it's CCITT but the XCP standard leaves out a C
    XCP_CRC_32,
    XCP_USER_DEFINED,
    ST_CRC_32
};

struct LIBXCONFPROTOSHARED_EXPORT XcpPtr
{
    XcpPtr() : addr(0), ext(0) {}
    XcpPtr(quint32 addr_in) : addr(addr_in), ext(0) {}
    XcpPtr(quint32 addr_in, quint8 ext_in) : addr(addr_in), ext(ext_in) {}

    inline XcpPtr &operator+=(quint32 offset)
    {
        addr += offset;
        return *this;
    }

    inline XcpPtr &operator-=(quint32 offset)
    {
        addr -= offset;
        return *this;
    }

    quint32 addr;
    quint8 ext;
};

inline bool operator==(const XcpPtr &lhs, const XcpPtr &rhs)
{
    return (lhs.addr == rhs.addr && lhs.ext == rhs.ext);
}
inline bool operator!=(const XcpPtr &lhs, const XcpPtr &rhs)
{
    return (lhs.addr != rhs.addr || lhs.ext != rhs.ext);
}

inline XcpPtr operator+(const XcpPtr &ptr, quint32 offset)
{
    return XcpPtr(ptr.addr + offset, ptr.ext);
}
inline XcpPtr operator+(quint32 offset, const XcpPtr &ptr)
{
    return XcpPtr(ptr.addr + offset, ptr.ext);
}
inline XcpPtr operator-(const XcpPtr &ptr, quint32 offset)
{
    return XcpPtr(ptr.addr - offset, ptr.ext);
}
inline bool operator<(const XcpPtr &lhs, const XcpPtr &rhs)
{
    if(lhs.ext < rhs.ext)
        return true;
    else if(lhs.ext == rhs.ext)
        return (lhs.addr < rhs.addr);
    else    // if lhs.ext > rhs.ext
        return false;
}
inline bool operator>(const XcpPtr &lhs, const XcpPtr &rhs)
{
    if(lhs.ext < rhs.ext)
        return false;
    else if(lhs.ext == rhs.ext)
        return (lhs.addr > rhs.addr);
    else    // if lhs.ext > rhs.ext
        return true;
}
inline bool operator<=(const XcpPtr &lhs, const XcpPtr &rhs)
{
    if(lhs.ext < rhs.ext)
        return true;
    else if(lhs.ext == rhs.ext)
        return (lhs.addr <= rhs.addr);
    else    // if lhs.ext > rhs.ext
        return false;
}
inline bool operator>=(const XcpPtr &lhs, const XcpPtr &rhs)
{
    if(lhs.ext < rhs.ext)
        return false;
    else if(lhs.ext == rhs.ext)
        return (lhs.addr >= rhs.addr);
    else    // if lhs.ext > rhs.ext
        return true;
}

boost::optional<quint32> LIBXCONFPROTOSHARED_EXPORT computeCksumStatic(CksumType type, const std::vector<quint8> &data);

class LIBXCONFPROTOSHARED_EXPORT Connection : public QObject
{
    Q_OBJECT
    Q_ENUMS(State)
public:
    enum class State {
        IntfcInvalid,
        Closed,
        CalMode,
        PgmMode
    };
    enum StateIntEnum {
        IntfcInvalid =  static_cast<int>(State::IntfcInvalid),
        Closed =        static_cast<int>(State::Closed),
        CalMode =       static_cast<int>(State::CalMode),
        PgmMode =       static_cast<int>(State::PgmMode)
    };

private:

    Q_PROPERTY(QObject *intfc READ intfc WRITE setIntfc)
    Q_PROPERTY(int timeout READ timeout WRITE setTimeout)
    Q_PROPERTY(int nvWriteTimeout READ nvWriteTimeout WRITE setNvWriteTimeout)
    Q_PROPERTY(int resetTimeout READ resetTimeout WRITE setResetTimeout)
    Q_PROPERTY(int progClearTimeout READ progClearTimeout WRITE setProgClearTimeout)
    Q_PROPERTY(double opProgressNotifyFrac READ opProgressNotifyFrac WRITE setOpProgressNotifyFrac)
    Q_PROPERTY(bool progResetIsAcked READ progResetIsAcked WRITE setProgResetIsAcked)

    /**
     * Progress through a long operation with interim state notification (upload and download
     * of more than one packet, program range). Resets to zero immediately after completion signals are emitted.
     */
    Q_PROPERTY(double opProgress READ opProgress NOTIFY opProgressChanged)
public:
    explicit Connection(QObject *parent = 0);
    QObject *intfc(void);
    void setIntfc(QObject *intfc);
    int timeout(void);
    void setTimeout(int msec);
    int nvWriteTimeout(void);
    void setNvWriteTimeout(int msec);
    int resetTimeout(void);
    void setResetTimeout(int msec);
    double opProgressNotifyFrac();
    void setOpProgressNotifyFrac(double);
    int progClearTimeout(void);
    void setProgClearTimeout(int msec);
    bool progResetIsAcked(void);
    void setProgResetIsAcked(bool val);
    double opProgress();
    State state();
    template <typename T>
    T fromSlaveEndian(const uchar *src)
    {
        if(mIsBigEndian)
            return qFromBigEndian<T>(src);
        else
            return qFromLittleEndian<T>(src);
    }
    template <typename T>
    T fromSlaveEndian(const char *src)
    {
        return fromSlaveEndian<T>(reinterpret_cast<const uchar *>(src));
    }
    template <typename T>
    T fromSlaveEndian(T src)
    {
        if(mIsBigEndian)
            return qFromBigEndian<T>(src);
        else
            return qFromLittleEndian<T>(src);
    }
    template <typename T>
    void toSlaveEndian(T src, uchar *dest)
    {
        if(mIsBigEndian)
            qToBigEndian(src, dest);
        else
            qToLittleEndian(src, dest);
    }
    template <typename T>
    void toSlaveEndian(T src, char *dest)
    {
        toSlaveEndian<T>(src, reinterpret_cast<uchar *>(dest));
    }
    template <typename T>
    T toSlaveEndian(T src)
    {
        if(mIsBigEndian)
            return qToBigEndian<T>(src);
        else
            return qToLittleEndian<T>(src);
    }
    template <typename A, typename D>
    A additiveChecksum(boost::iterator_range<std::vector<quint8>::const_iterator> data)
    {
        Q_ASSERT(data.size() % sizeof(D) == 0);
        const D *it = reinterpret_cast<const D *>(&*data.begin());
        const D *end = reinterpret_cast<const D *>(&*data.end());

        A accum = 0;
        while(it != end)
        {
            accum += toSlaveEndian<D>(*it);
            ++it;
        }
        return accum;
    }

    quint32 computeCksum(CksumType type, const std::vector<quint8> &data);
    bool isOpen();
    bool isCalMode();
    bool isPgmMode();
    int addrGran();

signals:
    void setStateDone(SetupTools::Xcp::OpResult result);
    void openDone(SetupTools::Xcp::OpResult result);
    void closeDone(SetupTools::Xcp::OpResult result);
    void uploadDone(SetupTools::Xcp::OpResult result, XcpPtr base, int len, std::vector<quint8> data = std::vector<quint8> ());
    void downloadDone(SetupTools::Xcp::OpResult result, XcpPtr base, std::vector<quint8> data);
    void nvWriteDone(SetupTools::Xcp::OpResult result);
    void setCalPageDone(SetupTools::Xcp::OpResult result, quint8 segment, quint8 page);
    void programStartDone(SetupTools::Xcp::OpResult result);
    void programClearDone(SetupTools::Xcp::OpResult result, XcpPtr base, int len);
    void programRangeDone(SetupTools::Xcp::OpResult result, XcpPtr base, std::vector<quint8> data, bool finalEmptyPacket);
    void programVerifyDone(SetupTools::Xcp::OpResult result, XcpPtr mta, quint32 crc);
    void programResetDone(SetupTools::Xcp::OpResult result);
    void buildChecksumDone(SetupTools::Xcp::OpResult result, XcpPtr base, int len, CksumType type, quint32 cksum);
    void getAvailSlavesDone(SetupTools::Xcp::OpResult result, Xcp::Interface::Can::Id bcastId, Xcp::Interface::Can::Filter filter, std::vector<Xcp::Interface::Can::SlaveId> slaveIds);
    void getAvailSlavesStrDone(SetupTools::Xcp::OpResult result, QString bcastId, QString filter, QList<QString> slaveIds);
    void stateChanged();
    void opProgressChanged();
public slots:
    SetupTools::Xcp::OpResult setState(State);
    SetupTools::Xcp::OpResult open(boost::optional<int> timeoutMsec = boost::optional<int>());
    SetupTools::Xcp::OpResult close();
    SetupTools::Xcp::OpResult upload(XcpPtr base, int len, std::vector<quint8> *out=nullptr);
    SetupTools::Xcp::OpResult download(XcpPtr base, const std::vector<quint8> data);
    SetupTools::Xcp::OpResult nvWrite();
    SetupTools::Xcp::OpResult setCalPage(quint8 segment, quint8 page);
    SetupTools::Xcp::OpResult programStart();
    SetupTools::Xcp::OpResult programClear(XcpPtr base, int len);
    SetupTools::Xcp::OpResult programRange(XcpPtr base, const std::vector<quint8> data, bool finalEmptyPacket = true);
    SetupTools::Xcp::OpResult programVerify(XcpPtr mta, quint32 crc);
    SetupTools::Xcp::OpResult programReset();
    SetupTools::Xcp::OpResult buildChecksum(XcpPtr base, int len, CksumType *typeOut, quint32 *cksumOut);
    SetupTools::Xcp::OpResult getAvailSlavesStr(QString bcastId, QString filter, QList<QString> *out);
    SetupTools::Xcp::OpResult getAvailSlaves(Xcp::Interface::Can::Id bcastId, Xcp::Interface::Can::Filter filter, std::vector<Xcp::Interface::Can::SlaveId> *out);
private:
    static SetupTools::Xcp::OpResult getRepliesResult(const std::vector<std::vector<quint8> > &replies, const char *msg = NULL);
    static SetupTools::Xcp::OpResult getReplyResult(const std::vector<quint8> &reply, const char *msg = NULL);
    SetupTools::Xcp::OpResult transact(const std::vector<quint8> &cmd, int minReplyBytes, std::vector<quint8> &out, const char *msg = NULL, boost::optional<int> timeoutMsec = boost::optional<int>());
    SetupTools::Xcp::OpResult uploadSegment(XcpPtr base, int len, std::vector<quint8> &out);
    SetupTools::Xcp::OpResult downloadSegment(XcpPtr base, const std::vector<quint8> &data);
    SetupTools::Xcp::OpResult programPacket(XcpPtr base, const std::vector<quint8> &data);
    SetupTools::Xcp::OpResult programBlock(XcpPtr base, const std::vector<quint8> &data);
    SetupTools::Xcp::OpResult setMta(XcpPtr ptr);
    SetupTools::Xcp::OpResult tryQuery(std::function<SetupTools::Xcp::OpResult (void)> &action);
    SetupTools::Xcp::OpResult synch();
    void updateEmitOpProgress(double newVal);

    constexpr static const int MAX_RETRIES = 10;
    constexpr static const int NUM_NV_WRITE_POLLS = 10;

    Interface::Interface *mIntfc;
    QReadWriteLock mIntfcLock;
    int mTimeoutMsec, mNvWriteTimeoutMsec, mResetTimeoutMsec, mProgClearTimeoutMsec;
    bool mProgResetIsAcked;

    bool mConnected;
    bool mIsBigEndian, mSupportsCalPage, mSupportsPgm;
    int mAddrGran, mMaxCto, mMaxDownPayload, mMaxUpPayload;
    double mOpProgress, mOpProgressNotifyFrac;
    int mOpProgressFracs;
    QReadWriteLock mOpProgressLock;

    bool mPgmStarted, mPgmMasterBlockMode;
    int mPgmMaxCto, mPgmMaxBlocksize, mPgmMaxDownPayload;
    boost::optional<XcpPtr> mCalcMta;
};

}   // namespace Xcp
}   // namespace SetupTools

Q_DECLARE_METATYPE(SetupTools::Xcp::XcpPtr)
Q_DECLARE_METATYPE(SetupTools::Xcp::Connection::State)
Q_DECLARE_METATYPE(SetupTools::Xcp::CksumType)
Q_DECLARE_METATYPE(std::vector<quint8>)

#endif // XCP_CONNECTION_H
