#ifndef XCP_CONNECTION_H
#define XCP_CONNECTION_H

#include <QObject>
#include <QSharedPointer>
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
    Q_INVOKABLE void open();
    Q_INVOKABLE void close();
    Q_INVOKABLE std::vector<quint8> upload(XcpPtr base, int len);
    Q_INVOKABLE void download(XcpPtr base, const std::vector<quint8> &data);
    Q_INVOKABLE void nvWrite();
    Q_INVOKABLE void setCalPage(quint8 segment, quint8 page);
    Q_INVOKABLE void programStart();
    Q_INVOKABLE void programClear(XcpPtr base, int len);
    Q_INVOKABLE void programRange(XcpPtr base, const std::vector<quint8> &data);
    Q_INVOKABLE void programVerify(quint32 crc);
    Q_INVOKABLE void programReset();
    std::pair<CksumType, quint32> buildChecksum(XcpPtr base, int len);
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

        A accum;
        while(it != end)
        {
            accum += toSlaveEndian<D>(*it);
            ++it;
        }
        return accum;
    }

signals:
public slots:
private:
    static void throwReplies(const std::vector<std::vector<quint8> > &replies, const char *msg = NULL);
    static void throwReply(const std::vector<quint8> &reply, const char *msg = NULL);
    std::vector<quint8> transact(const std::vector<quint8> &cmd, int minReplyBytes, const char *msg = NULL, int timeoutMsec = -1);
    std::vector<quint8> uploadSegment(XcpPtr base, int len);
    void downloadSegment(XcpPtr base, const std::vector<quint8> &data);
    void programPacket(XcpPtr base, const std::vector<quint8> &data);
    void programBlock(XcpPtr base, const std::vector<quint8> &data);
    void setMta(XcpPtr ptr);
    void tryQuery(std::function<void (void)> &action);
    void synch();
    quint32 computeCksum(CksumType type, const std::vector<quint8> &data);

    static constexpr int MAX_RETRIES = 10;

    Interface::Interface *mIntfc;
    int mTimeoutMsec, mNvWriteTimeoutMsec;

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
