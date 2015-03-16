#ifndef XCP_CONNECTION_H
#define XCP_CONNECTION_H

#include <QObject>
#include <QReadWriteLock>
#include <boost/optional.hpp>
#include <boost/range/iterator_range.hpp>
#include <vector>

#include "libxconfproto_global.h"
#include "Xcp_Interface_Interface.h"

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
    XCP_USER_DEFINED
};

struct LIBXCONFPROTOSHARED_EXPORT XcpPtr
{
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

quint32 computeCksum(CksumType type, const std::vector<quint8> &data);

class LIBXCONFPROTOSHARED_EXPORT Connection : public QObject
{
    Q_OBJECT
public:
    enum class State {
        IntfcInvalid,
        Closed,
        CalMode,
        PgmMode
    };
private:

    Q_PROPERTY(QObject *intfc READ intfc WRITE setIntfc)
    Q_PROPERTY(int timeout READ timeout WRITE setTimeout)
    Q_PROPERTY(int nvWriteTimeout READ nvWriteTimeout WRITE setNvWriteTimeout)
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
        return fromSlaveEndian(reinterpret_cast<const uchar *>(src));
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
        toSlaveEndian(src, reinterpret_cast<uchar *>(dest));
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
    bool isOpen();
    bool isCalMode();
    bool isPgmMode();

signals:
    void setStateDone(OpResult result);
    void openDone(OpResult result);
    void closeDone(OpResult result);
    void uploadDone(OpResult result, std::vector<quint8> data = std::vector<quint8>());
    void downloadDone(OpResult result);
    void nvWriteDone(OpResult result);
    void setCalPageDone(OpResult result);
    void programStartDone(OpResult result);
    void programClearDone(OpResult result);
    void programRangeDone(OpResult result);
    void programVerifyDone(OpResult result);
    void programResetDone(OpResult result);
    void buildChecksumDone(OpResult result, CksumType type = CksumType::Invalid, quint32 cksum = 0);
    void stateChanged();
public slots:
    OpResult setState(State);
    OpResult open(boost::optional<int> timeoutMsec = boost::optional<int>());
    OpResult close();
    OpResult upload(XcpPtr base, int len, std::vector<quint8> *out);
    OpResult download(XcpPtr base, const std::vector<quint8> data);
    OpResult nvWrite();
    OpResult setCalPage(quint8 segment, quint8 page);
    OpResult programStart();
    OpResult programClear(XcpPtr base, int len);
    OpResult programRange(XcpPtr base, const std::vector<quint8> data);
    OpResult programVerify(quint32 crc);
    OpResult programReset();
    OpResult buildChecksum(XcpPtr base, int len, CksumType *typeOut, quint32 *cksumOut);
private:
    static OpResult getRepliesResult(const std::vector<std::vector<quint8> > &replies, const char *msg = NULL);
    static OpResult getReplyResult(const std::vector<quint8> &reply, const char *msg = NULL);
    OpResult transact(const std::vector<quint8> &cmd, int minReplyBytes, std::vector<quint8> &out, const char *msg = NULL, boost::optional<int> timeoutMsec = boost::optional<int>());
    OpResult uploadSegment(XcpPtr base, int len, std::vector<quint8> &out);
    OpResult downloadSegment(XcpPtr base, const std::vector<quint8> &data);
    OpResult programPacket(XcpPtr base, const std::vector<quint8> &data);
    OpResult programBlock(XcpPtr base, const std::vector<quint8> &data);
    OpResult setMta(XcpPtr ptr);
    OpResult tryQuery(std::function<OpResult (void)> &action);
    OpResult synch();
    quint32 computeCksum(CksumType type, const std::vector<quint8> &data);

    constexpr static const int MAX_RETRIES = 10;
    constexpr static const int NUM_NV_WRITE_POLLS = 10;

    Interface::Interface *mIntfc;
    QReadWriteLock mIntfcLock;
    int mTimeoutMsec, mNvWriteTimeoutMsec, mResetTimeoutMsec;

    bool mConnected;
    bool mIsBigEndian, mSupportsCalPage, mSupportsPgm;
    int mAddrGran, mMaxCto, mMaxDownPayload, mMaxUpPayload;

    bool mPgmStarted, mPgmMasterBlockMode;
    int mPgmMaxCto, mPgmMaxBlocksize, mPgmMaxDownPayload;
    boost::optional<XcpPtr> mCalcMta;
};

class LIBXCONFPROTOSHARED_EXPORT SimpleDataLayer : public QObject
{
    Q_OBJECT
    Q_PROPERTY(QObject *conn READ conn WRITE setConn)
public:
    SimpleDataLayer();

    QObject *conn(void);
    void setConn(QObject *conn);
    Q_INVOKABLE quint32 uploadUint32(quint32 base);
    Q_INVOKABLE void downloadUint32(quint32 base, quint32 data);
private:
    Connection *mConn;
};

}   // namespace Xcp
}   // namespace SetupTools

#endif // XCP_CONNECTION_H
