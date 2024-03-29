#ifndef IBEMTOOL_H
#define IBEMTOOL_H

#include <QObject>
#include <MultiselectList.h>
#include <ProgFile.h>
#include <Xcp_ProgramLayer.h>
#include "Xcp_Interface_Can_Interface.h"

namespace SetupTools
{

/*
 * Program flow:
 *
 *  User selects program file (button Open Program)
 *  User selects interface (drop-down)
 *  User clicks Open Interface (or maybe it happens on selecting interface)
 *  We poll for IBEMs, stuff slave selection menu
 *  User picks boards to load
 *  User clicks Go
 *  On each board's completion, we uncheck it from the selection menu
 *  On completion of all boards or failure, throw up a dialog
 */

class IbemTool : public QObject
{
    Q_OBJECT
    Q_PROPERTY(MultiselectListModel *slaveListModel READ slaveListModel NOTIFY slaveListModelChanged)
    Q_PROPERTY(FlashProg *programData READ programData WRITE setProgramData NOTIFY programChanged)
    Q_PROPERTY(int programSize READ programSize NOTIFY programChanged)
    Q_PROPERTY(qlonglong programBase READ programBase NOTIFY programChanged)
    Q_PROPERTY(qlonglong programCksum READ programCksum NOTIFY programChanged)
    Q_PROPERTY(bool programOk READ programOk NOTIFY programChanged)
    Q_PROPERTY(bool progReady READ progReady NOTIFY stateChanged)
    Q_PROPERTY(double progress READ progress NOTIFY progressChanged)
    Q_PROPERTY(QUrl intfcUri READ intfcUri WRITE setIntfcUri NOTIFY intfcUriChanged)
    Q_PROPERTY(bool intfcOk READ intfcOk NOTIFY stateChanged)
    Q_PROPERTY(bool idle READ idle NOTIFY stateChanged)
public:
    explicit IbemTool(QObject *parent = 0);
    ~IbemTool();

    MultiselectListModel *slaveListModel();
    FlashProg *programData();
    void setProgramData(FlashProg *prog);
    int programSize();
    qlonglong programBase();
    qlonglong programCksum();
    bool programOk();
    bool progReady();
    double progress();
    QUrl intfcUri();
    void setIntfcUri(QUrl uri);
    bool intfcOk();
    bool idle();
signals:
    void stateChanged();
    void slaveListModelChanged();
    void programChanged();
    void progressChanged();
    void intfcUriChanged();
    void programmingDone(bool ok);

public slots:
    void startProgramming();
    void pollForSlaves();
    void abort();

private:
    void onGetAvailSlavesStrDone(SetupTools::OpResult result, QString bcastId, QString filter, QList<QString> slaveIds);
    void onProgramDone(SetupTools::OpResult result, FlashProg *prog, quint8 addrExt);
    void onProgramVerifyDone(SetupTools::OpResult result, FlashProg *prog, Xcp::CksumType type, quint8 addrExt);
    void onWatchdogExpired();
    void onProgramResetDone(SetupTools::OpResult result);
    void onProgramModeDone(SetupTools::OpResult result);
    void onDisconnectDone(SetupTools::OpResult result);
    void onProgFileChanged();
    void onProgLayerStateChanged();
    void onProgLayerProgressChanged();

    enum class State
    {
        IntfcNotOk = 0,
        Idle,
        Disconnect,
        PollForSlaves,
        Program,
        ProgramVerify,
        ProgramReset1,
        ProgramMode,
        ProgramReset2,
        _N_STATES
    };
    static constexpr int N_STATES = static_cast<int>(State::_N_STATES);
    static const QString BCAST_ID_STR;
    static const SetupTools::Xcp::Interface::Can::Filter SLAVE_FILTER;
    static const QString SLAVE_FILTER_STR;
    static constexpr SetupTools::Xcp::Interface::Can::Id IBEM_BASE_CMD_ID = {0x1F000080, SetupTools::Xcp::Interface::Can::Id::Type::Ext};
    static constexpr SetupTools::Xcp::Interface::Can::SlaveId IBEM_RECOVERY_ID = {{0x1F000010, SetupTools::Xcp::Interface::Can::Id::Type::Ext}, {0x1F000011, SetupTools::Xcp::Interface::Can::Id::Type::Ext}};
    static constexpr SetupTools::Xcp::Interface::Can::SlaveId CDA_ID = {{0x1F000080, SetupTools::Xcp::Interface::Can::Id::Type::Ext}, {0x1F000081, SetupTools::Xcp::Interface::Can::Id::Type::Ext}};
    static constexpr SetupTools::Xcp::Interface::Can::SlaveId CDA2_ID = {{0x1F000090, SetupTools::Xcp::Interface::Can::Id::Type::Ext}, {0x1F000091, SetupTools::Xcp::Interface::Can::Id::Type::Ext}};
    static constexpr SetupTools::Xcp::Interface::Can::SlaveId YTB_ID = {{0x1F0000A0, SetupTools::Xcp::Interface::Can::Id::Type::Ext}, {0x1F0000A1, SetupTools::Xcp::Interface::Can::Id::Type::Ext}};
    static constexpr SetupTools::Xcp::Interface::Can::SlaveId IPC_ID = {{0x1F0000B0, SetupTools::Xcp::Interface::Can::Id::Type::Ext}, {0x1F0000B1, SetupTools::Xcp::Interface::Can::Id::Type::Ext}};
    static constexpr quint32 IBEM_ID_MAX = 0x7F;
    static constexpr int TIMEOUT_MSEC = 100;
    static constexpr int WATCHDOG_MSEC = 2000;
    static constexpr int RESET_TIMEOUT_MSEC = 2000;
    static constexpr int PROG_CLEAR_BASE_TIMEOUT_MSEC = TIMEOUT_MSEC;
    static constexpr int PROG_CLEAR_TIMEOUT_PER_PAGE_MSEC = 40;
    static constexpr int ST_PAGE_SIZE = 2048;
    static constexpr Xcp::CksumType CKSUM_TYPE = Xcp::CksumType::ST_CRC_32;
    static constexpr int N_POLL_ITER = 2;
    static constexpr int N_PROGRAMMODE_TRIES = 25;
    static constexpr int N_PROGRAM_STATES = static_cast<int>(State::ProgramReset2) - static_cast<int>(State::Program) + 1;
    static constexpr double PROGRAM_STATE_PROGRESS_CREDIT = 0.0625;
    static constexpr double PROGRAM_PROGRESS_MULT = 1 - PROGRAM_STATE_PROGRESS_CREDIT * (N_PROGRAM_STATES - 1);
    static constexpr uint32_t PROG_BASE = 0x08004000;
    static constexpr uint32_t PROG_TOP = 0x087F0000;

    Xcp::ProgramLayer *mProgLayer;
    FlashProg *mProgData;
    FlashProg mInfilledProgData;
    bool mProgFileOkToFlash;
    MultiselectListModel *mSlaveListModel;
    int mActiveSlave;
    int mRemainingPollIter;
    int mRemainingProgramModeTries;
    State mState;
    int mTotalSlaves, mSlavesDone;
};

} // namespace SetupTools

#endif // IBEMTOOL_H
