#ifndef TESTINGSLAVE_H
#define TESTINGSLAVE_H

#include <QObject>
#include <QTimer>
#include <QtTest>
#include <Xcp_Interface_Loopback_Interface.h>
#include <Xcp_Connection.h>
#include <util.h>
#include <map>
#include <functional>
#include <boost/range/iterator_range.hpp>

class TestingSlave : public QThread
{
    Q_OBJECT
public:
    enum class MemType {
        Calib,
        Prog
    };
    enum class OpType {
        Connect,
        Disconnect,
        GetStatus,
        Synch,
        GetCommModeInfo,
        SetRequest,
        SetMta,
        Upload,
        ShortUpload,
        BuildChecksum,
        TransportLayerCmd,
        Download,
        DownloadNext,
        SetCalPage,
        GetCalPage,
        ProgramStart,
        ProgramClear,
        Program,
        ProgramReset,
        ProgramVerify,
        ProgramNext,
        NvWrite,
        UnknownCmd
    };
    typedef enum
    {
        ERR_CMD_SYNCH = 0x00,
        ERR_CMD_BUSY = 0x10,
        ERR_DAQ_ACTIVE = 0x11,
        ERR_PGM_ACTIVE = 0x12,
        ERR_CMD_UNKNOWN = 0x20,
        ERR_CMD_SYNTAX = 0x21,
        ERR_OUT_OF_RANGE = 0x22,
        ERR_WRITE_PROTECTED = 0x23,
        ERR_ACCESS_DENIED = 0x24,
        ERR_ACCESS_LOCKED = 0x25,
        ERR_PAGE_NOT_VALID = 0x26,
        ERR_MODE_NOT_VALID = 0x27,
        ERR_SEGMENT_NOT_VALID = 0x28,
        ERR_SEQUENCE = 0x29,
        ERR_DAQ_CONFIG = 0x2A,
        ERR_MEMORY_OVERFLOW = 0x30,
        ERR_GENERIC = 0x31,
        ERR_VERIFY = 0x32
    } ErrCode;
    typedef enum
    {
        CONNECT = 0xFF,
        DISCONNECT = 0xFE,
        GET_STATUS = 0xFD,
        SYNCH = 0xFC,
        GET_COMM_MODE_INFO = 0xFB,
        GET_ID = 0xFA,
        SET_REQUEST = 0xF9,
        GET_SEED = 0xF8,
        UNLOCK = 0xF7,
        SET_MTA = 0xF6,
        UPLOAD = 0xF5,
        SHORT_UPLOAD = 0xF4,
        BUILD_CHECKSUM = 0xF3,
        TRANSPORT_LAYER_CMD = 0xF2,
        USER_CMD = 0xF1,
        DOWNLOAD = 0xF0,
        DOWNLOAD_NEXT = 0xEF,
        DOWNLOAD_MAX = 0xEE,
        SHORT_DOWNLOAD = 0xED,
        MODIFY_BITS = 0xEC,
        SET_CAL_PAGE = 0xEB,
        GET_CAL_PAGE = 0xEA,
        GET_PAG_PROCESSOR_INFO = 0xE9,
        GET_SEGMENT_INFO = 0xE8,
        GET_PAGE_INFO = 0xE7,
        SET_SEGMENT_MODE = 0xE6,
        GET_SEGMENT_MODE = 0xE5,
        COPY_CAL_PAGE = 0xE4,
        CLEAR_DAQ_LIST = 0xE3,
        SET_DAQ_PTR = 0xE2,
        WRITE_DAQ = 0xE1,
        SET_DAQ_LIST_MODE = 0xE0,
        GET_DAQ_LIST_MODE = 0xDF,
        START_STOP_DAQ_LIST = 0xDE,
        START_STOP_SYNCH = 0xDD,
        GET_DAQ_CLOCK = 0xDC,
        READ_DAQ = 0xDB,
        GET_DAQ_PROCESSOR_INFO = 0xDA,
        GET_DAQ_RESOLUTION_INFO = 0xD9,
        GET_DAQ_LIST_INFO = 0xD8,
        GET_DAQ_EVENT_INFO = 0xD7,
        FREE_DAQ = 0xD6,
        ALLOC_DAQ = 0xD5,
        ALLOC_ODT = 0xD4,
        ALLOC_ODT_ENTRY = 0xD3,
        PROGRAM_START = 0xD2,
        PROGRAM_CLEAR = 0xD1,
        PROGRAM = 0xD0,
        PROGRAM_RESET = 0xCF,
        GET_PGM_PROCESSOR_INFO = 0xCE,
        GET_SECTOR_INFO = 0xCD,
        PROGRAM_PREPARE = 0xCC,
        PROGRAM_FORMAT = 0xCB,
        PROGRAM_NEXT = 0xCA,
        PROGRAM_MAX = 0xC9,
        PROGRAM_VERIFY = 0xC8
    } CmdCode;

    struct ResponseDelay {
        int msec, iterLeft;
    };

    struct MemRange {
        MemType type;
        SetupTools::Xcp::XcpPtr base;
        std::vector<quint8> data;
        quint8 segment, page;
        std::vector<quint8> validPages;
    };

    explicit TestingSlave(SetupTools::Xcp::Interface::Loopback::Interface *intfc, QObject *parent = 0); // starts thread
    ~TestingSlave();
    void setAg(int ag);
    void setMaxCto(quint8 bytes);
    void setPgmMaxCto(quint8 bytes);
    void setMaxDto(quint16 bytes);
    void setMaxBs(quint8 pkts);
    void setPgmMaxBs(quint8 pkts);
    void setMinSt(quint8 time);
    void setPgmMinSt(quint8 time);
    void setBigEndian(bool isBigEndian);
    void setMasterBlockSupport(bool enable);
    void setPgmMasterBlockSupport(bool enable);
    void setSendsEvStoreCal(bool enable);
    void setCksumType(SetupTools::Xcp::CksumType type);
    void setCrcCalc(std::function<quint32(boost::iterator_range<std::vector<quint8>::const_iterator>)> func); // sets user-defined checksum type
    int addMemRange(MemType type, SetupTools::Xcp::XcpPtr base, size_t len, quint8 segment = 0, std::vector<quint8> validPages = {0});
    int addMemRange(MemType type, SetupTools::Xcp::XcpPtr base, std::vector<quint8> data, quint8 segment = 0, std::vector<quint8> validPages = {0});
    std::vector<quint8> &getMemRange(int idx);
    void setMemRange(int idx, const std::vector<quint8> &data);
    void removeMemRange(int idx);
    void setResponseDelay(OpType op, int delayMsec, int lifetimeIter);	// delayMsec < 0 means never respond, lifetimeIter < 0 means lasts forever

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
signals:

public slots:

private:
    void run() Q_DECL_OVERRIDE;
    int getResponseDelay(OpType op);
    bool isCalPageSupported();
    bool isPgmSupported();
    void transmitWithDelay(OpType op, const std::vector<quint8> &data);
    void finishNvWrite();
    boost::optional<boost::iterator_range<std::vector<quint8>::iterator>> findMemRange(size_t nElem, MemType type);
    std::vector<quint8> doProgramBlock(const std::vector<quint8> packet);

    static const int RECEIVE_TIMEOUT = 10;


    SetupTools::Xcp::Interface::Loopback::Interface *mIntfc;
    QMutex mConfigMutex;
    QElapsedTimer mNvWriteTimer;

    bool mTerminate;

    int mNvWriteDelayMsec;
    int mAg;
    quint8 mMaxCto, mPgmMaxCto;
    quint16 mMaxDto;
    quint8 mMaxBs, mPgmMaxBs;
    quint8 mMinSt, mPgmMinSt;   // FIXME verify these when doing block transfer
    bool mIsBigEndian, mMasterBlockSupport, mPgmMasterBlockSupport, mSendsEvStoreCal;
    std::map<OpType, ResponseDelay> mResponseDelay;
    std::map<int, MemRange> mMemRanges;
    int mNextMemRangeIdx;
    SetupTools::Xcp::CksumType mCksumType;
    std::function<quint32(boost::iterator_range<std::vector<quint8>::const_iterator>)> mCrcCalc;

    bool mIsConnected;
    bool mIsProgramMode;
    boost::optional<quint8> mProgramBlockModeRemBytes;
    bool mStoreCalReqSet;
    SetupTools::Xcp::XcpPtr mMta;
};

#endif // TESTINGSLAVE_H
