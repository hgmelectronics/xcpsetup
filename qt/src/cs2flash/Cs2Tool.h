#ifndef CS2TOOL_H
#define CS2TOOL_H

#include <QObject>
#include <ProgFile.h>
#include <Xcp_ProgramLayer.h>
#include "Xcp_Interface_Can_Interface.h"

namespace SetupTools
{

class Cs2Tool : public QObject
{
    Q_OBJECT
    Q_PROPERTY(QString programFilePath READ programFilePath WRITE setProgramFilePath NOTIFY programChanged)
    Q_PROPERTY(int programFileType READ programFileType WRITE setProgramFileType NOTIFY programChanged)
    Q_PROPERTY(int programSize READ programSize NOTIFY programChanged)
    Q_PROPERTY(qlonglong programBase READ programBase NOTIFY programChanged)
    Q_PROPERTY(qlonglong programCksum READ programCksum NOTIFY programChanged)
    Q_PROPERTY(bool programOk READ programOk NOTIFY programChanged)
    Q_PROPERTY(double progress READ progress NOTIFY stateChanged)
    Q_PROPERTY(QString intfcUri READ intfcUri WRITE setIntfcUri NOTIFY intfcUriChanged)
    Q_PROPERTY(bool intfcOk READ intfcOk NOTIFY stateChanged)
    Q_PROPERTY(bool idle READ idle NOTIFY stateChanged)
public:
    explicit Cs2Tool(QObject *parent = 0);
    ~Cs2Tool();

    QString programFilePath();
    void setProgramFilePath(QString path);
    int programFileType();
    void setProgramFileType(int type);
    int programSize();
    qlonglong programBase();
    qlonglong programCksum();
    bool programOk();
    double progress();
    QString intfcUri();
    void setIntfcUri(QString uri);
    bool intfcOk();
    bool idle();
signals:
    void stateChanged();
    void programChanged();
    void intfcUriChanged();

    void programmingDone(bool ok);
public slots:
    void startProgramming();
    void onSetStateDone(Xcp::OpResult result);
    void onProgramDone(Xcp::OpResult result, FlashProg *prog, quint8 addrExt);
    void onProgramVerifyDone(Xcp::OpResult result, FlashProg *prog, Xcp::CksumType type, quint8 addrExt);
    void onProgramResetDone(Xcp::OpResult result);
    void onProgFileChanged();
    void onProgLayerStateChanged();
private:
    enum class State
    {
        IntfcNotOk = 0,
        Idle,
        InitialConnect,
        ProgramResetToBootloader,
        Program,
        ProgramVerify,
        ProgramResetToApplication,
        CalMode,
        _N_STATES
    };
    constexpr static const int N_STATES = static_cast<int>(State::_N_STATES);
    static const QString SLAVE_ID_STR;
    constexpr static const int TIMEOUT_MSEC = 100;
    constexpr static const int RESET_TIMEOUT_MSEC = 3000;
    constexpr static const int PROG_CLEAR_BASE_TIMEOUT_MSEC = TIMEOUT_MSEC;
    constexpr static const int PROG_CLEAR_TIMEOUT_PER_BLOCK_MSEC = 105;
    constexpr static const uint SMALLBLOCK_BASE = 0x20000000;
    constexpr static const uint SMALLBLOCK_TOP = 0x20010000;
    constexpr static const uint LARGEBLOCK_BASE = SMALLBLOCK_TOP;
    constexpr static const uint LARGEBLOCK_TOP = 0x200C0000;
    constexpr static const int SMALLBLOCK_SIZE = 8192;
    constexpr static const int LARGEBLOCK_SIZE = 65536;
    constexpr static const Xcp::CksumType CKSUM_TYPE = Xcp::CksumType::XCP_CRC_32;
    constexpr static const int N_CAL_TRIES = 25;

    void rereadProgFile();
    static int nBlocksInRange(uint progBase, uint progSize, uint rangeBase, uint rangeTop, uint blockSize);
    void setState(State newState);

    Xcp::ProgramLayer *mProgLayer;
    ProgFile *mProgFile;
    bool mProgFileOkToFlash;
    int mRemainingCalTries;
    State mState;
};

} // namespace SetupTools

#endif // Cs2TOOL_H
