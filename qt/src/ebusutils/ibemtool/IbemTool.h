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
    Q_PROPERTY(QString programFilePath READ programFilePath WRITE setProgramFilePath NOTIFY programChanged)
    Q_PROPERTY(int programFileType READ programFileType WRITE setProgramFileType NOTIFY programChanged)
    Q_PROPERTY(int programSize READ programSize NOTIFY programChanged)
    Q_PROPERTY(uint programBase READ programBase NOTIFY programChanged)
    Q_PROPERTY(bool programOk READ programOk NOTIFY programChanged)
    Q_PROPERTY(double progress READ progress NOTIFY progressChanged)
    Q_PROPERTY(QString intfcUri READ intfcUri WRITE setIntfcUri NOTIFY intfcUriChanged)
public:
    explicit IbemTool(QObject *parent = 0);
    ~IbemTool();

    MultiselectListModel *slaveListModel();
    QString programFilePath();
    void setProgramFilePath(QString path);
    int programFileType();
    void setProgramFileType(int type);
    int programSize();
    uint programBase();
    bool programOk();
    double progress();
    QString intfcUri();
    void setIntfcUri(QString uri);
signals:
    void slaveListModelChanged();
    void programChanged();
    void progressChanged();
    void intfcUriChanged();

    void programmingDone(bool ok);
public slots:
    void onGetAvailSlavesStrDone(Xcp::OpResult result, QString bcastId, QString filter, QList<QString> slaveIds);
    void startProgramming();
    void onProgramDone(Xcp::OpResult result, FlashProg *prog, quint8 addrExt);
    void onProgramVerifyDone(Xcp::OpResult result, FlashProg *prog, Xcp::CksumType type, quint8 addrExt);
    void onProgramResetDone(Xcp::OpResult result);
    void onProgFileChanged();
private:
    enum class State
    {
        Idle = 0,
        Program,
        ProgramVerify,
        ProgramReset1,
        ProgramReset2,
        _N_STATES
    };
    constexpr static const int N_STATES = static_cast<int>(State::_N_STATES);
    static const QString BCAST_ID_STR;
    static const Xcp::Interface::Can::Filter SLAVE_FILTER;
    static const QString SLAVE_FILTER_STR;

    Xcp::ProgramLayer *mProgLayer;
    ProgFile *mProgFile;
    MultiselectListModel *mSlaveListModel;
    QList<MultiselectListWrapper *>::iterator mActiveSlave;
    State mState;
    int mTotalSlaves, mSlavesDone;
};

} // namespace SetupTools

#endif // IBEMTOOL_H
