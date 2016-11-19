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
        QMutexLocker locker(&mStateMutex);
        return mState;
    }

    QBluetoothAddress remoteAddress()
    {
        QMutexLocker locker(&mStateMutex);
        if(mState == State::Connected)
            return mController->remoteAddress();
        else
            return QBluetoothAddress();
    }

signals:
    void stateChanged();
public slots:
    void startConnect(QBluetoothAddress dev);
    void startDisconnect();
    void transmit(const std::vector<quint8> & data);
    void onCharacteristicChanged(const QLowEnergyCharacteristic & characteristic, const QByteArray & newValue);

    void onControllerStateChanged(QLowEnergyController::ControllerState state);
    void onServiceStateChanged(QLowEnergyService::ServiceState state);
private:
    void setState(State);

    QMutex mStateMutex;
    QWaitCondition mStateCondition;
    State mState;
    OpResult mError;

    QLowEnergyController * mController;
    QLowEnergyService * mXcpService;
    QLowEnergyCharacteristic mTxChar;
    QLowEnergyCharacteristic mRxChar;
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

    void taskStartConnect(QBluetoothAddress dev);
    void taskStartDisconnect();
    void taskTransmit(const std::vector<quint8> & data);
public slots:
    void onTaskStateChanged();
private:
    OpResult connectToDevice(QBluetoothAddress);
    OpResult disconnectFromDevice();

    QThread * mThread;
    InterfaceTask * mTask;
    QBluetoothAddress mRemoteAddress;
};

} // namespace Ble
} // namespace Interface
} // namespace Xcp
} // namespace SetupTools

#endif // SETUPTOOLS_XCP_INTERFACE_BLE_INTERFACE_H
