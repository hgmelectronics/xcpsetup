#ifndef SETUPTOOLS_XCP_PARAMLAYER_H
#define SETUPTOOLS_XCP_PARAMLAYER_H

#include <QObject>
#include "Xcp_ConnectionFacade.h"
#include "FlashProg.h"
#include "ParamRegistry.h"

namespace SetupTools {
namespace Xcp {

/**
 * @brief The ParamLayer class
 *
 * Handles parameter transfer to/from slaves.
 */

class ParamLayer : public QObject
{
    Q_OBJECT
    Q_PROPERTY(QUrl intfcUri READ intfcUri WRITE setIntfcUri NOTIFY intfcChanged)
    Q_PROPERTY(QString slaveId READ slaveId WRITE setSlaveId NOTIFY slaveIdChanged)
    Q_PROPERTY(ConnectionFacade *conn READ conn CONSTANT)
    Q_PROPERTY(ParamRegistry *registry MEMBER mRegistry)
    Q_PROPERTY(bool idle READ idle NOTIFY stateChanged)
    Q_PROPERTY(bool intfcOk READ intfcOk NOTIFY stateChanged)
    Q_PROPERTY(bool slaveConnected READ slaveConnected NOTIFY stateChanged)
    Q_PROPERTY(int slaveTimeout READ slaveTimeout WRITE setSlaveTimeout)
    Q_PROPERTY(int slaveNvWriteTimeout READ slaveNvWriteTimeout WRITE setSlaveNvWriteTimeout)
    Q_PROPERTY(int opProgressNotifyPeriod READ opProgressNotifyPeriod WRITE setOpProgressNotifyPeriod)
    Q_PROPERTY(double opProgress READ opProgress NOTIFY opProgressChanged)
    Q_PROPERTY(bool writeCacheDirty READ writeCacheDirty NOTIFY writeCacheDirtyChanged)
    Q_PROPERTY(int slaveBootDelay READ slaveBootDelay WRITE setSlaveBootDelay)
    Q_PROPERTY(bool slaveProgResetIsAcked READ slaveProgResetIsAcked WRITE setSlaveProgResetIsAcked)
public:
    explicit ParamLayer(QObject *parent = nullptr);
    virtual ~ParamLayer() {}

    enum SetDataPolicy
    {
        KeepExisting,   // validity is not changed; params that are valid in the registry and not present in supplied dataset are unchanged, params that are in supplied dataset but not valid in the registry are left invalid
        SetToNew,       // params that are in supplied dataset are loaded and set to valid, params that are not in supplied dataset are invalidated
        Union,          // params that are in supplied dataset are loaded and set to valid, params that are not in supplied dataset are unchanged
        Intersection    // params that are in valid in the registry and present in the supplied dataset are loaded, all others are invalidated
    };

    Q_ENUMS(SetDataPolicy)

    QUrl intfcUri();
    void setIntfcUri(QUrl);
    Interface::Interface *intfc();
    void setIntfc(Interface::Interface *intfc, QUrl uri = QUrl("testing")); // for interfaces shared between higher layers - use with caution!
    QString slaveId();
    void setSlaveId(QString);
    ConnectionFacade *conn();
    ParamRegistry *registry();
    bool idle();
    bool intfcOk();
    bool slaveConnected();
    int slaveTimeout();
    void setSlaveTimeout(int);
    int slaveNvWriteTimeout();
    void setSlaveNvWriteTimeout(int);
    int slaveBootDelay();
    void setSlaveBootDelay(int);
    bool slaveProgResetIsAcked();
    void setSlaveProgResetIsAcked(bool);
    int opProgressNotifyPeriod();
    void setOpProgressNotifyPeriod(int);
    Q_INVOKABLE void forceSlaveSupportCalPage();    //!< Call after connecting for slaves that erroneously report they do not support calibration/paging
    Q_INVOKABLE void setSlaveCalPage();    //!< Call after connecting for slaves that need segment and page initialized
    double opProgress();
    bool writeCacheDirty();

    Q_INVOKABLE QMap<QString, QVariant> data();
    Q_INVOKABLE QMap<QString, QVariant> rawData();
    Q_INVOKABLE QMap<QString, QVariant> saveableData();
    Q_INVOKABLE QMap<QString, QVariant> saveableRawData();
    Q_INVOKABLE QMap<QString, QVariant> data(const QStringList &keys);
    Q_INVOKABLE QStringList setData(QVariantMap data, bool raw, int policy);   //!< Returns keys that did not set successfully
    Q_INVOKABLE QMap<QString, QVariant> rawData(const QStringList &keys);
    Q_INVOKABLE QMap<QString, QVariant> names();
    Q_INVOKABLE QMap<QString, QVariant> names(const QStringList &keys);
signals:
    void downloadDone(SetupTools::OpResult result, QStringList keys);
    void uploadDone(SetupTools::OpResult result, QStringList keys);
    void connectSlaveDone(SetupTools::OpResult result);
    void disconnectSlaveDone(SetupTools::OpResult result);
    void nvWriteDone(SetupTools::OpResult result);
    void copyCalPageDone(SetupTools::OpResult result, quint8 fromSegment, quint8 fromPage, quint8 toSegment, quint8 toPage);
    void programResetSlaveDone(SetupTools::OpResult result);
    void calResetSlaveDone(SetupTools::OpResult result);
    void fault(SetupTools::OpResult result, QString info);
    void warn(SetupTools::OpResult result, QString info);
    void info(SetupTools::OpResult result, QString info);
    void stateChanged();
    void opProgressChanged();
    void writeCacheDirtyChanged();
    void intfcChanged();
    void addrGranChanged();
    void slaveIdChanged();
    void setSlaveIdDone(SetupTools::OpResult result);

public slots:
    void download();
    void upload();
    void download(QStringList keys);
    void upload(QStringList keys);
    void nvWrite();
    void copyCalPage(quint8 fromSegment, quint8 fromPage, quint8 toSegment, quint8 toPage);
    void programResetSlave();   // Switch to program mode and then reset
    void calResetSlave();       // Issue PROGRAM_RESET while still in cal mode
    void connectSlave();
    void disconnectSlave();

private:
    void onConnSetStateDone(SetupTools::OpResult result);
    void onConnOpMsg(SetupTools::OpResult result, QString info, SetupTools::Xcp::Connection::OpExtInfo ext);
    void onConnStateChanged();
    void onConnNvWriteDone(SetupTools::OpResult result);
    void onConnCopyCalPageDone(SetupTools::OpResult result, quint8 fromSegment, quint8 fromPage, quint8 toSegment, quint8 toPage);
    void onConnProgramResetDone(SetupTools::OpResult result);
    void onParamDownloadDone(SetupTools::OpResult result, XcpPtr base, const std::vector<quint8> &data);
    void onParamUploadDone(SetupTools::OpResult result, XcpPtr base, int len, const std::vector<quint8> &data);
    void onRegistryWriteCacheDirtyChanged();
    void onConnSetTargetDone(SetupTools::OpResult result);

    enum class State
    {
        IntfcNotOk,
        SettingTarget,
        Disconnected,
        Connect,
        Connected,
        Download,
        Upload,
        NvWrite,
        CopyCalPage,
        ProgramReset,
        CalReset,
        Disconnect
    };

    void downloadKey();
    void uploadKey();
    Param *getNextParam();
    void setState(State);
    void notifyProgress();

    ConnectionFacade * mConn;
    ParamRegistry * mRegistry;
    State mState;
    boost::optional<ParamHistoryElide> mParamHistoryElide;
    int mOpProgressNotifyPeriod;

    QStringList mActiveKeys;
    int mActiveKeyIdx;
    Param * mActiveParam;
    bool mActiveParamSizeIsKnown;
    std::vector<quint8> mActiveParamUploadedData;
    SetupTools::OpResult mActiveResult;
};

} // namespace Xcp
} // namespace SetupTools

#endif // SETUPTOOLS_XCP_PARAMLAYER_H
