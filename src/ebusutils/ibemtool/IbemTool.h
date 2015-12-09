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
    void onGetAvailSlavesStrDone(SetupTools::Xcp::OpResult result, QString bcastId, QString filter, QList<QString> slaveIds);
    void onProgramDone(SetupTools::Xcp::OpResult result, FlashProg *prog, quint8 addrExt);
    void onProgramVerifyDone(SetupTools::Xcp::OpResult result, FlashProg *prog, Xcp::CksumType type, quint8 addrExt);
    void onWatchdogExpired();
    void onProgramResetDone(SetupTools::Xcp::OpResult result);
    void onProgramModeDone(SetupTools::Xcp::OpResult result);
    void onProgFileChanged();
    void onProgLayerStateChanged();
    void onProgLayerProgressChanged();

    enum class State
    {
        IntfcNotOk = 0,
        Idle,
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
    static const Xcp::Interface::Can::Filter SLAVE_FILTER;
    static const QString SLAVE_FILTER_STR;
    static constexpr int RECOVERY_IBEMID_OFFSET = 0x08;
    static constexpr int CDA_IBEMID_OFFSET = 0x40;
    static constexpr int CDA2_IBEMID_OFFSET = 0x48;
    static constexpr int REGULAR_IBEMID_OFFSET = 0x80;
    static constexpr int TIMEOUT_MSEC = 100;
    static constexpr int WATCHDOG_MSEC = 2000;
    static constexpr int RESET_TIMEOUT_MSEC = 2000;
    static constexpr int PROG_CLEAR_BASE_TIMEOUT_MSEC = TIMEOUT_MSEC;
    static constexpr int PROG_CLEAR_TIMEOUT_PER_PAGE_MSEC = 40;
    static constexpr int PAGE_SIZE = 2048;
    static constexpr Xcp::CksumType CKSUM_TYPE = Xcp::CksumType::ST_CRC_32;
    static constexpr int N_POLL_ITER = 20;
    static constexpr int N_PROGRAMMODE_TRIES = 25;
    static constexpr int N_PROGRAM_STATES = static_cast<int>(State::ProgramReset2) - static_cast<int>(State::Program) + 1;
    static constexpr double PROGRAM_STATE_PROGRESS_CREDIT = 0.0625;
    static constexpr double PROGRAM_PROGRESS_MULT = 1 - PROGRAM_STATE_PROGRESS_CREDIT * (N_PROGRAM_STATES - 1);
    static constexpr uint32_t PROG_BASE = 0x08004000;
    static constexpr uint32_t PROG_TOP = 0x0807EFFF;

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
