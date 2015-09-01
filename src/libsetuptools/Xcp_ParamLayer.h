#ifndef SETUPTOOLS_XCP_PARAMLAYER_H
#define SETUPTOOLS_XCP_PARAMLAYER_H

#include <QObject>
#include "Xcp_ConnectionFacade.h"
#include "FlashProg.h"
#include "Xcp_ParamRegistry.h"

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
    Q_PROPERTY(QString slaveId READ slaveId WRITE setSlaveId)
    Q_PROPERTY(ConnectionFacade *conn READ conn NOTIFY never)
    Q_PROPERTY(ParamRegistry *registry READ registry NOTIFY never)
    Q_PROPERTY(bool idle READ idle NOTIFY stateChanged)
    Q_PROPERTY(bool intfcOk READ intfcOk NOTIFY stateChanged)
    Q_PROPERTY(int slaveTimeout READ slaveTimeout WRITE setSlaveTimeout)
    Q_PROPERTY(int slaveNvWriteTimeout READ slaveNvWriteTimeout WRITE setSlaveNvWriteTimeout)
    Q_PROPERTY(int opProgressNotifyPeriod READ opProgressNotifyPeriod WRITE setOpProgressNotifyPeriod)
    Q_PROPERTY(double opProgress READ opProgress NOTIFY opProgressChanged)
    Q_PROPERTY(bool writeCacheDirty READ writeCacheDirty NOTIFY writeCacheDirtyChanged)
public:
    explicit ParamLayer(quint32 addrGran, QObject *parent = 0);
    virtual ~ParamLayer() {}

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
    int slaveTimeout();
    void setSlaveTimeout(int);
    int slaveNvWriteTimeout();
    void setSlaveNvWriteTimeout(int);
    int opProgressNotifyPeriod();
    void setOpProgressNotifyPeriod(int);
    Q_INVOKABLE void forceSlaveSupportCalPage();    //!< Call after connecting for slaves that erroneously report they do not support calibration/paging
    double opProgress();
    bool writeCacheDirty();

    QMap<QString, QVariant> data();
    QMap<QString, QVariant> saveableData();
    QMap<QString, QVariant> data(const QStringList &keys);
    QStringList setData(const QMap<QString, QVariant> &data);   //!< Returns keys that did not set successfully
signals:
    void downloadDone(SetupTools::Xcp::OpResult result, QStringList keys);
    void uploadDone(SetupTools::Xcp::OpResult result, QStringList keys);
    void connectSlaveDone(SetupTools::Xcp::OpResult result);
    void disconnectSlaveDone(SetupTools::Xcp::OpResult result);
    void nvWriteDone(SetupTools::Xcp::OpResult result);
    void stateChanged();
    void opProgressChanged();
    void writeCacheDirtyChanged();
    void intfcChanged();

    void never();
public slots:
    void download();
    void upload();
    void download(QStringList keys);
    void upload(QStringList keys);
    void nvWrite();
    void connectSlave();
    void disconnectSlave();

private:
    void onConnSetStateDone(SetupTools::Xcp::OpResult result);
    void onConnStateChanged();
    void onConnNvWriteDone(SetupTools::Xcp::OpResult result);
    void onParamDownloadDone(SetupTools::Xcp::OpResult result);
    void onParamUploadDone(SetupTools::Xcp::OpResult result);
    void onRegistryWriteCacheDirtyChanged();

    enum class State
    {
        IntfcNotOk,
        Disconnected,
        Connect,
        Connected,
        Download,
        Upload,
        NvWrite,
        Disconnect
    };

    void downloadKey();
    void uploadKey();
    Param *getNextParam();
    void setState(State);
    void notifyProgress();

    ConnectionFacade *mConn;
    ParamRegistry *mRegistry;
    State mState;
    int mOpProgressNotifyPeriod;

    QStringList mActiveKeys;
    int mActiveKeyIdx;
    QMetaObject::Connection mActiveParamConnection;
    SetupTools::Xcp::OpResult mActiveResult;
};

} // namespace Xcp
} // namespace SetupTools

#endif // SETUPTOOLS_XCP_PARAMLAYER_H
