#ifndef SETUPTOOLS_XCP_INTERFACE_BLE_INTERFACE_H
#define SETUPTOOLS_XCP_INTERFACE_BLE_INTERFACE_H

#include <QObject>
#include <QLowEnergyController>
#include <boost/optional.hpp>

#include "Xcp_Interface_Interface.h"

namespace SetupTools {
namespace Xcp {
namespace Interface {
namespace Ble {

static const QBluetoothUuid XCP_SERVICE_UUID(QString("e7fc7a82-5947-4aad-8e90-c88ac2deca6c"));
static const QBluetoothUuid TX_CHAR_UUID(QString("89c5f9cf-b2a4-444f-ac01-8b87c8625a00"));
static const QBluetoothUuid RX_CHAR_UUID(QString("89c5f9cf-b2a4-444f-ac01-8b87c8625a01"));

class InterfaceTask : public QObject
{
    Q_OBJECT
public:
    explicit InterfaceTask(QObject * parent = 0);
    virtual ~InterfaceTask();

    enum class State
    {
        Disconnected,
        Connecting,
        DiscoveringServices,
        DiscoveringCharacteristics,
        SettingClientCharConfig,
        Connected,
        Disconnecting
    };

    OpResult receive(int timeoutMsec, std::vector<std::vector<quint8> > &out);
    OpResult clearReceived();
    void setPacketLog(bool enable)
    {
        mPacketLog = enable;
    }
    OpResult waitForConnect();
    OpResult waitForDisconnect();

    State state()
    {
        State out;
        {
            QMutexLocker locker(&mStateMutex);
            out = mState;
        }
        return out;
    }

    QString remoteAddress()
    {
        QString out;
        {
            QMutexLocker locker(&mRemoteAddressMutex);
            out = mRemoteAddress;
        }
        return mRemoteAddress;
    }

signals:
    void stateChanged();
public slots:
    void startConnect(QBluetoothDeviceInfo dev);
    void startDisconnect();
    void transmit(const std::vector<quint8> & data);
    void onCharacteristicChanged(const QLowEnergyCharacteristic & characteristic, const QByteArray & newValue);
    void onDescriptorWritten(const QLowEnergyDescriptor & descriptor, const QByteArray & newValue);
    void onControllerStateChanged(QLowEnergyController::ControllerState state);
    void onServiceStateChanged(QLowEnergyService::ServiceState state);
private:
    void setState(State);

    QMutex mStateMutex;
    QWaitCondition mStateCondition;
    State mState;
#ifdef Q_OS_MAC
    QString mRemoteDevUuid;
#endif
    QMutex mRemoteAddressMutex;
    QString mRemoteAddress;
    OpResult mError;

    QMutex mControllerMutex;
    QLowEnergyController * mController;
    QMutex mXcpServiceMutex;
    QLowEnergyService * mXcpService;
    QLowEnergyCharacteristic mTxChar;
    QLowEnergyCharacteristic mRxChar;
    QLowEnergyDescriptor mRxCharClientConfig;
    PythonicQueue<std::vector<quint8>> mRxQueue;
    bool mPacketLog;
};

class Interface : public SetupTools::Xcp::Interface::Interface
{
    Q_OBJECT
public:
    explicit Interface(QObject *parent = 0);
    virtual ~Interface();

    bool isConnected();

    virtual QString connectedTarget() override;
    OpResult setTarget(const QString & target) override;
    virtual OpResult transmit(const std::vector<quint8> & data, bool replyExpected = true) override;
    virtual OpResult receive(int timeoutMsec, std::vector<std::vector<quint8> > &out) override;
    virtual OpResult clearReceived() override;
    virtual OpResult setPacketLog(bool enable) override;
    virtual bool hasReliableTx() override;
    virtual bool allowsMultipleReplies() override;
    virtual int maxReplyTimeout() override;
signals:
    void connectedChanged();

    void taskStartConnect(QBluetoothDeviceInfo dev);
    void taskStartDisconnect();
    void taskTransmit(const std::vector<quint8> & data);
public slots:
    void onTaskStateChanged();
private:
    OpResult connectToDevice(QBluetoothDeviceInfo);
    OpResult disconnectFromDevice();

    QThread * mThread;
    InterfaceTask * mTask;
    QString mRemoteAddress;
};

} // namespace Ble
} // namespace Interface
} // namespace Xcp
} // namespace SetupTools

#endif // SETUPTOOLS_XCP_INTERFACE_BLE_INTERFACE_H
