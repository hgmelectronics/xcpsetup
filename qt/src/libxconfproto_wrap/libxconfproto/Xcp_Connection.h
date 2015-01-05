#ifndef XCP_CONNECTION_H
#define XCP_CONNECTION_H

#include <QObject>
#include <QSharedPointer>
#include <boost/optional.hpp>
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

struct LIBXCONFPROTOSHARED_EXPORT XcpPtr
{
public:
    inline XcpPtr(quint32 addr_in = 0, quint8 ext_in = 0) :
        addr(addr_in),
        ext(ext_in)
    {}

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

class LIBXCONFPROTOSHARED_EXPORT XcpConnection : public QObject
{
    Q_OBJECT
public:
    explicit XcpConnection(QSharedPointer<Interface::Interface> intfc, int timeoutMsec, int nvWriteTimeoutMsec = 0, QObject *parent = 0);
    void open();
    void close();
    std::vector<quint8> upload(XcpPtr base, int len);
    void download(XcpPtr base, const std::vector<quint8> &data);
    void nvWrite();
    void setCalPage(quint8 segment, quint8 page);
    void programStart();
    void programClear(XcpPtr base, int len);
    void programRange(XcpPtr base, const std::vector<quint8> &data);
    void programVerify(quint32 crc);
    void programReset();
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

    static constexpr int MAX_RETRIES = 10;

    QSharedPointer<Interface::Interface> mIntfc;
    int mTimeoutMsec, mNvWriteTimeoutMsec;

    bool mConnected;
    bool mIsBigEndian, mSupportsCalPage, mSupportsPgm;
    int mAddrGran, mMaxCto, mMaxDownPayload, mMaxUpPayload;

    bool mPgmStarted, mPgmMasterBlockMode;
    int mPgmMaxCto, mPgmMaxBlocksize, mPgmMaxDownPayload;
    boost::optional<XcpPtr> mCalcMta;
};

}   // namespace Xcp
}   // namespace SetupTools

#endif // XCP_CONNECTION_H
