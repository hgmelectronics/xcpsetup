#ifndef SETUPTOOLS_XCP_PROGRAMLAYER_H
#define SETUPTOOLS_XCP_PROGRAMLAYER_H

#include <QObject>
#include "Xcp_ConnectionFacade.h"
#include "FlashProg.h"

namespace SetupTools {
namespace Xcp {

class ProgramLayer : public QObject
{
    Q_OBJECT
    Q_PROPERTY(QUrl intfcUri READ intfcUri WRITE setIntfcUri NOTIFY intfcChanged)
    Q_PROPERTY(QString slaveId READ slaveId WRITE setSlaveId NOTIFY slaveIdChanged)
    Q_PROPERTY(ConnectionFacade *conn READ conn)
    Q_PROPERTY(bool idle READ idle NOTIFY stateChanged)
    Q_PROPERTY(bool intfcOk READ intfcOk NOTIFY stateChanged)
    Q_PROPERTY(int slaveTimeout READ slaveTimeout WRITE setSlaveTimeout)
    Q_PROPERTY(int slaveBootDelay READ slaveBootDelay WRITE setSlaveBootDelay)
    Q_PROPERTY(int slaveProgClearTimeout READ slaveProgClearTimeout WRITE setSlaveProgClearTimeout)
    Q_PROPERTY(int maxEraseSize READ maxEraseSize WRITE setMaxEraseSize)
    Q_PROPERTY(bool slaveProgResetIsAcked READ slaveProgResetIsAcked WRITE setSlaveProgResetIsAcked)
    Q_PROPERTY(double opProgressNotifyFrac READ opProgressNotifyFrac WRITE setOpProgressNotifyFrac)
    Q_PROPERTY(double opProgress READ opProgress NOTIFY opProgressChanged)
public:
    explicit ProgramLayer(QObject *parent = 0);
    virtual ~ProgramLayer();

    QUrl intfcUri();
    void setIntfcUri(QUrl);
    Interface::Interface *intfc();
    void setIntfc(Interface::Interface *intfc, QUrl uri = QUrl("testing")); // for interfaces shared between higher layers - use with caution!
    QString slaveId();
    void setSlaveId(QString);
    ConnectionFacade *conn();
    bool idle();
    bool intfcOk();
    int slaveTimeout();
    void setSlaveTimeout(int);
    int slaveBootDelay();
    void setSlaveBootDelay(int);
    int slaveProgClearTimeout();
    void setSlaveProgClearTimeout(int);
    bool slaveProgResetIsAcked();
    void setSlaveProgResetIsAcked(bool);
    double opProgressNotifyFrac();
    void setOpProgressNotifyFrac(double);
    int maxEraseSize();
    void setMaxEraseSize(int);
    double opProgress();
signals:
    void programDone(OpResult result, FlashProg *prog, quint8 addrExt);
    void programVerifyDone(OpResult result, FlashProg *prog, CksumType type, quint8 addrExt);
    void buildChecksumVerifyDone(OpResult result, FlashProg *prog, quint8 addrExt, CksumType type = CksumType::Invalid, quint32 cksum = 0);
    void programResetDone(OpResult result);
    void calModeDone(OpResult result);
    void pgmModeDone(OpResult result);
    void disconnectDone(OpResult result);
    void stateChanged();
    void opProgressChanged();
    void intfcChanged();
    void opMsg(SetupTools::OpResult result, QString info, SetupTools::Xcp::Connection::OpExtInfo ext);
    void slaveIdChanged();
public slots:
    void program(FlashProg *prog, quint8 addrExt = 0, bool finalEmptyPacket = true);
    void programVerify(FlashProg *prog, CksumType type, quint8 addrExt = 0);    // For bootloaders that need PROGRAM_VERIFY to finish their flash write
    void buildChecksumVerify(FlashProg *prog, quint8 addrExt = 0);
    void programReset();
    void calMode();
    void pgmMode();
    void disconnect();

private:
    void onConnSetStateDone(OpResult result);
    void onConnProgramClearDone(OpResult result, XcpPtr base, int len);
    void onConnProgramRangeDone(OpResult result, XcpPtr base, std::vector<quint8> data, bool finalEmptyPacket);
    void onConnProgramVerifyDone(OpResult result, XcpPtr mta, quint32 crc);
    void onConnBuildChecksumDone(OpResult result, XcpPtr base, int len, CksumType type, quint32 cksum);
    void onConnProgramResetDone(OpResult result);
    void onConnStateChanged();
    void onConnOpProgressChanged();
    void onConnOpMsg(SetupTools::OpResult result, QString info, SetupTools::Xcp::Connection::OpExtInfo ext);
    void onIntfcSlaveIdChanged();

    void doProgramClear();   // Clear program bytes, as many as possible

    enum class State
    {
        IntfcNotOk,
        Idle,
        Program,
        ProgramVerify,
        BuildChecksumVerify,
        ProgramReset,
        CalMode,
        PgmMode,
        Disconnect
    };

    ConnectionFacade *mConn;
    State mState;
    quint32 mMaxEraseSize;
    FlashProg *mActiveProg;
    quint8 mActiveAddrExt;
    CksumType mActiveCksumType;
    bool mActiveFinalEmptyPacket;
    quint32 mActiveBytesErased;
    QList<FlashBlock *>::const_iterator mActiveProgBlock;
};

} // namespace Xcp
} // namespace SetupTools

#endif // SETUPTOOLS_XCP_PROGRAMLAYER_H
