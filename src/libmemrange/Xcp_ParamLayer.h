#ifndef SETUPTOOLS_XCP_PARAMLAYER_H
#define SETUPTOOLS_XCP_PARAMLAYER_H

#include <QObject>
#include "libxconfproto_global.h"
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
    Q_PROPERTY(QUrl intfcUri READ intfcUri WRITE setIntfcUri)
    Q_PROPERTY(QString slaveId READ slaveId WRITE setSlaveId)
    Q_PROPERTY(ConnectionFacade *conn READ conn)
    Q_PROPERTY(ParamRegistry *registry READ registry)
    Q_PROPERTY(bool idle READ idle NOTIFY stateChanged)
    Q_PROPERTY(bool intfcOk READ intfcOk NOTIFY stateChanged)
    Q_PROPERTY(int slaveTimeout READ slaveTimeout WRITE setSlaveTimeout)
    Q_PROPERTY(int slaveNvWriteTimeout READ slaveNvWriteTimeout WRITE setSlaveNvWriteTimeout)
    Q_PROPERTY(int opProgressNotifyPeriod READ opProgressNotifyPeriod WRITE setOpProgressNotifyPeriod)
    Q_PROPERTY(double opProgress READ opProgress NOTIFY opProgressChanged)
    Q_PROPERTY(bool writeCacheDirty READ writeCacheDirty NOTIFY writeCacheDirtyChanged)
public:
    explicit ParamLayer(quint32 addrGran, QObject *parent = 0);
    virtual ~ParamLayer();

    QUrl intfcUri();
    void setIntfcUri(QUrl);
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
    double opProgress();
    bool writeCacheDirty();

    QMap<QString, QVariant> data();
    QMap<QString, QVariant> data(const QStringList &keys);
    QStringList setData(const QMap<QString, QVariant> &data);   //!< Returns keys that did not set successfully
signals:
    void downloadDone(SetupTools::Xcp::OpResult result, QStringList keys);
    void uploadDone(SetupTools::Xcp::OpResult result, QStringList keys);
    void connectSlaveDone(SetupTools::Xcp::OpResult result);
    void disconnectSlaveDone(SetupTools::Xcp::OpResult result);
    void stateChanged();
    void opProgressChanged();
    void writeCacheDirtyChanged();
public slots:
    void download();
    void upload();
    void download(QStringList keys);
    void upload(QStringList keys);
    void connectSlave();
    void disconnectSlave();

    void onConnSetStateDone(SetupTools::Xcp::OpResult result);
    void onConnStateChanged();

    void onParamDownloadDone(SetupTools::Xcp::OpResult result);
    void onParamUploadDone(SetupTools::Xcp::OpResult result);

    void onRegistryWriteCacheDirtyChanged();
private:
    enum class State
    {
        IntfcNotOk,
        Disconnected,
        Connect,
        Connected,
        Download,
        Upload,
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
    QStringList::iterator mActiveKeyIt;
    QMetaObject::Connection mActiveParamConnection;
    SetupTools::Xcp::OpResult mActiveResult;
};

} // namespace Xcp
} // namespace SetupTools

#endif // SETUPTOOLS_XCP_PARAMLAYER_H
