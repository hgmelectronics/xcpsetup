#ifndef CS2TOOL_H
#define CS2TOOL_H

#include <QObject>
#include <ProgFile.h>
#include <Xcp_ProgramLayer.h>
#include <ParamFile.h>
#include <Xcp_ParamLayer.h>
#include <Xcp_Interface_Can_Interface.h>

namespace SetupTools
{

class Cs2Tool : public QObject
{
    Q_OBJECT
    Q_PROPERTY(QString programFilePath READ programFilePath WRITE setProgramFilePath NOTIFY programChanged)
    Q_PROPERTY(int programFileType READ programFileType WRITE setProgramFileType NOTIFY programChanged)
    Q_PROPERTY(QString paramFilePath READ paramFilePath WRITE setParamFilePath NOTIFY paramFileChanged)
    Q_PROPERTY(int programSize READ programSize NOTIFY programChanged)
    Q_PROPERTY(qlonglong programBase READ programBase NOTIFY programChanged)
    Q_PROPERTY(qlonglong programCksum READ programCksum NOTIFY programChanged)
    Q_PROPERTY(bool programOk READ programOk NOTIFY programChanged)
    Q_PROPERTY(bool paramFileExists READ paramFileExists NOTIFY paramFileChanged)
    Q_PROPERTY(bool paramConnected READ paramConnected NOTIFY stateChanged)
    Q_PROPERTY(bool progReady READ progReady NOTIFY stateChanged)
    Q_PROPERTY(bool paramReady READ paramReady NOTIFY stateChanged)
    Q_PROPERTY(double progress READ progress NOTIFY stateChanged)
    Q_PROPERTY(double programProgress READ programProgress NOTIFY stateChanged)
    Q_PROPERTY(QUrl intfcUri READ intfcUri WRITE setIntfcUri NOTIFY intfcUriChanged)
    Q_PROPERTY(bool intfcOk READ intfcOk NOTIFY stateChanged)
    Q_PROPERTY(bool idle READ idle NOTIFY stateChanged)
    Q_PROPERTY(QString slaveCmdId READ slaveCmdId WRITE setSlaveCmdId NOTIFY slaveIdChanged)
    Q_PROPERTY(QString slaveResId READ slaveResId WRITE setSlaveResId NOTIFY slaveIdChanged)
    Q_PROPERTY(SetupTools::Xcp::ParamLayer *paramLayer READ paramLayer NOTIFY never)
    Q_PROPERTY(bool paramWriteCacheDirty READ paramWriteCacheDirty NOTIFY paramWriteCacheDirtyChanged)
public:
    explicit Cs2Tool(QObject *parent = 0);
    ~Cs2Tool();

    QString programFilePath();
    void setProgramFilePath(QString path);
    QString paramFilePath();
    void setParamFilePath(QString path);
    int programFileType();
    void setProgramFileType(int type);
    int programSize();
    qlonglong programBase();
    qlonglong programCksum();
    bool programOk();
    bool paramFileExists();
    bool paramConnected();
    bool paramReady();
    bool progReady();
    double progress();
    double programProgress();
    QUrl intfcUri();
    void setIntfcUri(QUrl uri);
    QString slaveCmdId();
    void setSlaveCmdId(QString id);
    QString slaveResId();
    void setSlaveResId(QString id);
    bool intfcOk();
    bool idle();
    Xcp::ParamLayer *paramLayer();
    bool paramWriteCacheDirty();

signals:
    void stateChanged();
    void programChanged();
    void intfcUriChanged();
    void slaveIdChanged();
    void paramFileChanged();

    void programmingDone(int result);
    void resetDone(int result);
    void paramConnectDone(int result);
    void saveParamFileDone(int result);
    void loadParamFileDone(int result, QStringList failedKeys);
    void paramDownloadDone(int result);
    void paramUploadDone(int result);
    void paramDisconnectDone(int result);
    void paramNvWriteDone(int result);

    void paramWriteCacheDirtyChanged();

    void never();
public slots:
    void startProgramming();

    void startReset();

    void startParamConnect();           //!< Connect with the intent of staying connected over multiple read/write operations
    void startParamDownload();          //!< If already connected, download and stay connected; else connect, download, and disconnect
    void startParamUpload();
    void loadParamFile();
    void saveParamFile();
    void startParamNvWrite();
    void startParamDisconnect();

    void onProgCalModeDone(SetupTools::Xcp::OpResult result);
    void onProgramDone(SetupTools::Xcp::OpResult result, FlashProg *prog, quint8 addrExt);
    void onProgramVerifyDone(SetupTools::Xcp::OpResult result, FlashProg *prog, SetupTools::Xcp::CksumType type, quint8 addrExt);
    void onProgramResetDone(SetupTools::Xcp::OpResult result);
    void onProgFileChanged();

    void onProgLayerStateChanged();
    void onProgLayerProgressChanged();

    void onParamLayerStateChanged();
    void onParamLayerProgressChanged();
    void onParamLayerWriteCacheDirtyChanged();

    void onParamConnectSlaveDone(SetupTools::Xcp::OpResult);
    void onParamDownloadDone(SetupTools::Xcp::OpResult result, QStringList keys);
    void onParamUploadDone(SetupTools::Xcp::OpResult result, QStringList keys);
    void onParamNvWriteDone(SetupTools::Xcp::OpResult result);
    void onParamDisconnectSlaveDone(SetupTools::Xcp::OpResult);
private:
    enum class State
    {
        IntfcNotOk = 0,
        Idle,
        Program_InitialConnect,
        Program_ResetToBootloader,
        Program_Program,
        Program_Verify,
        Program_ResetToApplication,
        Program_CalMode,
        Reset_Reset,
        ParamConnect,
        ParamConnected,
        ParamDownload,
        ParamUpload,
        ParamNvWrite,
        _N_STATES
    };
    static constexpr int N_STATES = static_cast<int>(State::_N_STATES);
    static constexpr int TIMEOUT_MSEC = 250;
    static constexpr int NVWRITE_TIMEOUT_MSEC = 250;
    static constexpr int RESET_TIMEOUT_MSEC = 3000;
    static constexpr int ADDR_GRAN = 4;
    static constexpr int PROG_CLEAR_BASE_TIMEOUT_MSEC = TIMEOUT_MSEC;
    static constexpr int PROG_CLEAR_TIMEOUT_PER_BLOCK_MSEC = 1050;
    static constexpr uint SMALLBLOCK_BASE = 0x20000000;
    static constexpr uint SMALLBLOCK_TOP = 0x20010000;
    static constexpr uint LARGEBLOCK_BASE = SMALLBLOCK_TOP;
    static constexpr uint LARGEBLOCK_TOP = 0x200C0000;
    static constexpr int SMALLBLOCK_SIZE = 8192;
    static constexpr int LARGEBLOCK_SIZE = 65536;
    static constexpr Xcp::CksumType CKSUM_TYPE = Xcp::CksumType::XCP_CRC_32;
    static constexpr int N_CAL_TRIES = 25;
    static constexpr int N_PROGRAM_STATES = static_cast<int>(State::Program_CalMode) - static_cast<int>(State::Program_InitialConnect) + 1;
    static constexpr double PROGRAM_STATE_PROGRESS_CREDIT = 0.0625;
    static constexpr double PROGRAM_PROGRESS_MULT = 1 - PROGRAM_STATE_PROGRESS_CREDIT * (N_PROGRAM_STATES - 1);

    void rereadProgFile();
    static int nBlocksInRange(uint progBase, uint progSize, uint rangeBase, uint rangeTop, uint blockSize);
    void setState(State newState);

    Xcp::ProgramLayer *mProgLayer;
    ProgFile *mProgFile;
    bool mProgFileOkToFlash;
    int mRemainingCalTries;
    Xcp::ParamLayer *mParamLayer;
    ParamFile *mParamFile;
    bool mParamDisconnectWhenDone;
    SetupTools::Xcp::OpResult mLastParamResult;
    State mState;
    QString mSlaveCmdId, mSlaveResId;
};

} // namespace SetupTools

#endif // Cs2TOOL_H
