#ifndef TESTINGSLAVE_H
#define TESTINGSLAVE_H

#include <QObject>
#include <Xcp_Interface_Loopback_Interface.h>
#include <Xcp_Connection.h>
#include <map>

class TestingSlave : public QObject
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
        NvWrite
    };

    struct ResponseDelay {
        int msec, iterLeft;
    };

    struct MemRange {
        MemType type;
        SetupTools::Xcp::XcpPtr base;
        std::vector<quint8> data;
    };

    explicit TestingSlave(SetupTools::Xcp::Interface::Loopback &intfc, QObject *parent = 0); // starts thread
    ~TestingSlave();
    void setAG(int ag);
    void setMaxCto(int bytes);
    void setMaxDto(int bytes);
    void setMasterBlockSupport(bool enable);
    void setBigEndian(bool isBigEndian);
    int addMemRange(MemType type, SetupTools::Xcp::XcpPtr base, size_t len);
    int addMemRange(MemType type, SetupTools::Xcp::XcpPtr base, std::vector<quint8> data);
    const std::vector<quint8> &getMemRange(int idx);
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
signals:

public slots:

private:
    void run() Q_DECL_OVERRIDE;
    int getResponseDelay(OpType op);
    bool isCalPageSupported();
    bool isPgmSupported();
    void transmitWithDelay(OpType op, const std::vector &data);

    static const int RECEIVE_TIMEOUT = 10;

    SetupTools::Xcp::Interface::Loopback &mIntfc;
    int mAg;
    quint8 mMaxCto;
    quint16 mMaxDto;
    bool mIsBigEndian, mMasterBlockSupport;
    int mNextMemRangeIdx;
    std::map<OpType, ResponseDelay> mResponseDelay;
    std::map<int, MemRange> mMemRanges;
    QMutex mConfigMutex;
    bool mTerminate;
    bool mIsConnected;
};

#endif // TESTINGSLAVE_H
