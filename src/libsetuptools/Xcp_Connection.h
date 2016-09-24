#ifndef XCP_CONNECTION_H
#define XCP_CONNECTION_H

#include <QObject>
#include <QReadWriteLock>
#include <boost/optional.hpp>
#include <boost/range/iterator_range.hpp>
#include <vector>

#include "Xcp_Interface_Interface.h"
#include "Xcp_Interface_Can_Interface.h"

namespace SetupTools
{
namespace Xcp
{

class ConnException : public ::SetupTools::Exception {};

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

class XcpPtr
{
    Q_GADGET

    Q_PROPERTY(quint32 addr MEMBER addr)
    Q_PROPERTY(quint8 ext MEMBER ext)
public:
    XcpPtr() : addr(0), ext(0) {}
    XcpPtr(quint64 addrAndExt) : addr(addrAndExt), ext(addrAndExt >> 32) {}
    XcpPtr(quint32 addr_in, quint8 ext_in) : addr(addr_in), ext(ext_in) {}
    XcpPtr(QVariant addr);
    QString toString() const;

    static XcpPtr fromString(QString str, bool *ok = nullptr);
    static XcpPtr fromVariant(const QVariant & var, bool * ok = nullptr)
    {
        return fromString(var.toString(), ok);
    }

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

boost::optional<quint32> computeCksumStatic(CksumType type, const std::vector<quint8> &data);

class Connection : public QObject
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

    enum CmdCode : quint8 {
        CmdCode_Connect = 0xFF,
        CmdCode_Disconnect = 0xFE,
        CmdCode_GetStatus = 0xFD,
        CmdCode_Synch = 0xFC,
        CmdCode_GetCommModeInfo = 0xFB,
        CmdCode_GetId = 0xFA,
        CmdCode_SetRequest = 0xF9,
        CmdCode_GetSeed = 0xF8,
        CmdCode_Unlock = 0xF7,
        CmdCode_SetMta = 0xF6,
        CmdCode_Upload = 0xF5,
        CmdCode_ShortUpload = 0xF4,
        CmdCode_BuildChecksum = 0xF3,
        CmdCode_TransportLayerCmd = 0xF2,
        CmdCode_UserCmd = 0xF1,
        CmdCode_Download = 0xF0,
        CmdCode_DownloadNext = 0xEF,
        CmdCode_DownloadMax = 0xEE,
        CmdCode_ShortDownload = 0xED,
        CmdCode_ModifyBits = 0xEC,
        CmdCode_SetCalPage = 0xEB,
        CmdCode_GetCalPage = 0xEA,
        CmdCode_GetPagProcessorInfo = 0xE9,
        CmdCode_GetSegmentInfo = 0xE8,
        CmdCode_GetPageInfo = 0xE7,
        CmdCode_SetSegmentMode = 0xE6,
        CmdCode_GetSegmentMode = 0xE5,
        CmdCode_CopyCalPage = 0xE4,
        CmdCode_ClearDaqList = 0xE3,
        CmdCode_SetDaqPtr = 0xE2,
        CmdCode_WriteDaq = 0xE1,
        CmdCode_SetDaqListMode = 0xE0,
        CmdCode_GetDaqListMode = 0xDF,
        CmdCode_StartStopDaqList = 0xDE,
        CmdCode_StartStopSynch = 0xDD,
        CmdCode_GetDaqClock = 0xDC,
        CmdCode_ReadDaq = 0xDB,
        CmdCode_GetDaqProcessorInfo = 0xDA,
        CmdCode_GetDaqResolutionInfo = 0xD9,
        CmdCode_GetDaqListInfo = 0xD8,
        CmdCode_GetDaqEventInfo = 0xD7,
        CmdCode_FreeDaq = 0xD6,
        CmdCode_AllocDaq = 0xD5,
        CmdCode_AllocOdt = 0xD4,
        CmdCode_AllocOdtEntry = 0xD3,
        CmdCode_ProgramStart = 0xD2,
        CmdCode_ProgramClear = 0xD1,
        CmdCode_Program = 0xD0,
        CmdCode_ProgramReset = 0xCF,
        CmdCode_GetPgmProcessorInfo = 0xCE,
        CmdCode_GetSectorInfo = 0xCD,
        CmdCode_ProgramPrepare = 0xCC,
        CmdCode_ProgramFormat = 0xCB,
        CmdCode_ProgramNext = 0xCA,
        CmdCode_ProgramMax = 0xC9,
        CmdCode_ProgramVerify = 0xC8,
    };

    enum class OpType {
        SetState,
        Open,
        Close,
        Upload,
        Download,
        NvWrite,
        SetCalPage,
        CopyCalPage,
        ProgramStart,
        ProgramClear,
        ProgramRange,
        ProgramVerify,
        ProgramReset,
        BuildChecksum,
        GetAvailSlaves
    };

    struct OpExtInfo {
        OpType type;
        boost::optional<quint8> cmd;
        boost::optional<XcpPtr> addr;
        boost::optional<int> len;
    };

private:

    Q_PROPERTY(QObject *intfc READ intfc WRITE setIntfc)
    Q_PROPERTY(int timeout READ timeout WRITE setTimeout)
    Q_PROPERTY(int nvWriteTimeout READ nvWriteTimeout WRITE setNvWriteTimeout)
    Q_PROPERTY(int bootDelay READ bootDelay WRITE setBootDelay)
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
    int bootDelay(void);
    void setBootDelay(int msec);
    double opProgressNotifyFrac();
    void setOpProgressNotifyFrac(double);
    int progClearTimeout(void);
    void setProgClearTimeout(int msec);
    bool progResetIsAcked(void);
    void setProgResetIsAcked(bool val);
    double opProgress();
    void forceSlaveSupportCalPage();
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
    void setStateDone(SetupTools::OpResult result);
    void openDone(SetupTools::OpResult result);
    void closeDone(SetupTools::OpResult result);
    void uploadDone(SetupTools::OpResult result, XcpPtr base, int len, std::vector<quint8> data = std::vector<quint8> ());
    void downloadDone(SetupTools::OpResult result, XcpPtr base, std::vector<quint8> data);
    void nvWriteDone(SetupTools::OpResult result);
    void setCalPageDone(SetupTools::OpResult result, quint8 segment, quint8 page);
    void copyCalPageDone(SetupTools::OpResult result, quint8 fromSegment, quint8 fromPage, quint8 toSegment, quint8 toPage);
    void programStartDone(SetupTools::OpResult result);
    void programClearDone(SetupTools::OpResult result, XcpPtr base, int len);
    void programRangeDone(SetupTools::OpResult result, XcpPtr base, std::vector<quint8> data, bool finalEmptyPacket);
    void programVerifyDone(SetupTools::OpResult result, XcpPtr mta, quint32 crc);
    void programResetDone(SetupTools::OpResult result);
    void buildChecksumDone(SetupTools::OpResult result, XcpPtr base, int len, CksumType type, quint32 cksum);
    void getAvailSlavesDone(SetupTools::OpResult result, Xcp::Interface::Can::Id bcastId, Xcp::Interface::Can::Filter filter, std::vector<Xcp::Interface::Can::SlaveId> slaveIds);
    void getAvailSlavesStrDone(SetupTools::OpResult result, QString bcastId, QString filter, QList<QString> slaveIds);
    void opMsg(SetupTools::OpResult result, QString info, OpExtInfo ext);
    void stateChanged();
    void opProgressChanged();
public slots:
    SetupTools::OpResult setState(State);
    SetupTools::OpResult open(boost::optional<int> timeoutMsec = boost::optional<int>());
    SetupTools::OpResult close();
    SetupTools::OpResult upload(XcpPtr base, int len, std::vector<quint8> *out=nullptr);
    SetupTools::OpResult download(XcpPtr base, const std::vector<quint8> data);
    SetupTools::OpResult nvWrite();
    SetupTools::OpResult setCalPage(quint8 segment, quint8 page);
    SetupTools::OpResult copyCalPage(quint8 fromSegment, quint8 fromPage, quint8 toSegment, quint8 toPage);
    SetupTools::OpResult programStart();
    SetupTools::OpResult programClear(XcpPtr base, int len);
    SetupTools::OpResult programRange(XcpPtr base, const std::vector<quint8> data, bool finalEmptyPacket = true);
    SetupTools::OpResult programVerify(XcpPtr mta, quint32 crc);
    SetupTools::OpResult programReset();
    SetupTools::OpResult buildChecksum(XcpPtr base, int len, CksumType *typeOut, quint32 *cksumOut);
    SetupTools::OpResult getAvailSlavesStr(QString bcastId, QString filter, QList<QString> *out);
    SetupTools::OpResult getAvailSlaves(Xcp::Interface::Can::Id bcastId, Xcp::Interface::Can::Filter filter, std::vector<Xcp::Interface::Can::SlaveId> *out);
private:
    SetupTools::OpResult getRepliesResult(const std::vector<std::vector<quint8> > &replies, QString info, OpExtInfo ext);
    SetupTools::OpResult getReplyResult(const std::vector<quint8> &reply, QString info, OpExtInfo ext);
    SetupTools::OpResult transact(const std::vector<quint8> &cmd, int minReplyBytes, std::vector<quint8> &out, QString info, OpExtInfo ext, boost::optional<int> timeoutMsec = boost::optional<int>());
    SetupTools::OpResult uploadSegment(XcpPtr base, int len, std::vector<quint8> &out, OpType type);
    SetupTools::OpResult downloadSegment(XcpPtr base, const std::vector<quint8> &data, OpType type);
    SetupTools::OpResult programPacket(XcpPtr base, const std::vector<quint8> &data, OpType type);
    SetupTools::OpResult programBlock(XcpPtr base, const std::vector<quint8> &data, OpType type);
    SetupTools::OpResult setMta(XcpPtr ptr, OpType type);
    SetupTools::OpResult tryQuery(std::function<SetupTools::OpResult (void)> &action, OpType type);
    SetupTools::OpResult synch(OpType type);
    void updateEmitOpProgress(double newVal);

    constexpr static const int MAX_RETRIES = 10;
    constexpr static const int NUM_NV_WRITE_POLLS = 10;

    Interface::Interface *mIntfc;
    QReadWriteLock mIntfcLock;
    int mTimeoutMsec, mNvWriteTimeoutMsec, mBootDelayMsec, mProgClearTimeoutMsec;
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
Q_DECLARE_METATYPE(SetupTools::Xcp::Connection::OpExtInfo)
Q_DECLARE_METATYPE(SetupTools::Xcp::CksumType)
Q_DECLARE_METATYPE(std::vector<quint8>)

#endif // XCP_CONNECTION_H
