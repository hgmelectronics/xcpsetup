#include "Xcp_Interface_Ble_Interface.h"
#include <array>

namespace SetupTools {
namespace Xcp {
namespace Interface {
namespace Ble {

//static const QBluetoothUuid XCP_SERVICE_UUID;
//static const QBluetoothUuid TX_CHAR_UUID;
//static const QBluetoothUuid RX_CHAR_UUID;

InterfaceTask::InterfaceTask(QObject * parent) :
    QObject(parent),
    mState(State::Disconnected),
    mError(OpResult::Success),
    mController(nullptr),
    mXcpService(nullptr),
    mPacketLog(false)
{

}

InterfaceTask::~InterfaceTask()
{

}

OpResult InterfaceTask::receive(int timeoutMsec, std::vector<std::vector<quint8> > &out)
{
    std::vector<std::vector<quint8>> gotten = mRxQueue.getAll(timeoutMsec);
    if(gotten.empty())
        return OpResult::Timeout;

    out.resize(gotten.size());
    std::copy(gotten.begin(), gotten.end(), out.begin());
    return OpResult::Success;
}

OpResult InterfaceTask::clearReceived()
{
    mRxQueue.getAll(0);
    return OpResult::Success;
}

OpResult InterfaceTask::waitForConnect()
{
    bool firstTime = true;
    while(1)
    {
        QMutexLocker locker(&mStateMutex);
        if(mState == State::Connected)
            return OpResult::Success;
        if(mState == State::Disconnected && !firstTime)
            return mError;
        firstTime = false;
        mStateCondition.wait(locker.mutex());
    }
}

OpResult InterfaceTask::waitForDisconnect()
{
    while(1)
    {
        QMutexLocker locker(&mStateMutex);
        if(mState == State::Disconnected)
            return OpResult::Success;
        mStateCondition.wait(locker.mutex());   // FIXME this loop releases before state change signal makes it to this thread, so control returns to QML with slave ID still not cleared
    }
}

void InterfaceTask::startConnect(QBluetoothDeviceInfo dev)
{
    {
        QMutexLocker controllerLocker(&mControllerMutex);
        mController = QLowEnergyController::createCentral(dev, this);

        Q_ASSERT(mController->thread() == thread());

        connect(mController, &QLowEnergyController::stateChanged, this, &InterfaceTask::onControllerStateChanged);

        mError = OpResult::Success;
#ifdef Q_OS_MAC
        mRemoteDevUuid = dev.deviceUuid().toString();
#endif
        {
            QMutexLocker locker(&mStateMutex);
            setState(State::Connecting);
        }
        mController->connectToDevice();
    }
}

void InterfaceTask::startDisconnect()
{
    {
        QMutexLocker locker(&mStateMutex);

        mError = OpResult::Success;

        if(mState == State::Disconnected)
            return;

        setState(State::Disconnecting);
    }
    QMutexLocker controllerLocker(&mControllerMutex);
    if(mController)
        mController->disconnectFromDevice();
}

void InterfaceTask::transmit(const std::vector<quint8> &data)
{
    QMutexLocker controllerLocker(&mControllerMutex);
    QMutexLocker serviceLocker(&mXcpServiceMutex);
    if(mXcpService && mController)
        mXcpService->writeCharacteristic(mTxChar,
                                         QByteArray(reinterpret_cast<const char *>(data.data()), data.size()),
                                         QLowEnergyService::WriteWithoutResponse);

    if(mPacketLog)
    {
        QByteArray array(reinterpret_cast<const char *>(data.data()), data.size());
        qDebug() << "TX" << array.toHex();
    }
}

void InterfaceTask::onCharacteristicChanged(const QLowEnergyCharacteristic &characteristic, const QByteArray &newValue)
{
    if(characteristic == mRxChar)
    {
        mRxQueue.put(std::vector<quint8>(newValue.begin(), newValue.end()));
        if(mPacketLog)
            qDebug() << newValue.toHex();
    }
    else
    {
        qDebug() << "Change of unexpected BLE characteristic received";
    }
}

void InterfaceTask::onDescriptorWritten(const QLowEnergyDescriptor &descriptor, const QByteArray &newValue)
{
    qDebug() << "Descriptor" << descriptor.name() << "written" << newValue.toHex();
    QMutexLocker stateLocker(&mStateMutex);
    Q_ASSERT(mState == State::SettingClientCharConfig);
    if(descriptor == mRxCharClientConfig && newValue == QByteArray::fromHex("0100"))
    {
        setState(State::Connected);
    }
    else
    {
        mError = OpResult::BadReply;
        setState(State::Disconnecting);
        stateLocker.unlock();
        QMutexLocker controllerLocker(&mControllerMutex);
        Q_ASSERT(mController);
        mController->disconnectFromDevice();
    }
}

void InterfaceTask::onControllerStateChanged(QLowEnergyController::ControllerState state)
{
    QMutexLocker stateLocker(&mStateMutex);
    switch(state)
    {
    case QLowEnergyController::UnconnectedState:
        {
            QMutexLocker serviceLocker(&mXcpServiceMutex);
            QMutexLocker locker(&mControllerMutex);
            if(mXcpService)
            {
                if(mError == OpResult::Success)
                {
                    auto error = mXcpService->error();
                    if(error != QLowEnergyService::NoError)
                    {
                        qDebug() << "BLE service error" << int(error);
                        mError = OpResult::IntfcIoError;
                    }
                }
                disconnect(mXcpService, &QLowEnergyService::stateChanged, this, &InterfaceTask::onServiceStateChanged);
                disconnect(mXcpService, &QLowEnergyService::characteristicChanged, this, &InterfaceTask::onCharacteristicChanged);
                disconnect(mXcpService, &QLowEnergyService::descriptorWritten, this, &InterfaceTask::onDescriptorWritten);
                mXcpService->deleteLater();
                mXcpService = nullptr;
            }
            if(mController)
            {
                if(mError == OpResult::Success)
                {
                    auto error = mController->error();
                    if(error != QLowEnergyController::NoError)
                    {
                        qDebug() << "BLE controller error" << int(error);
                        mError = OpResult::IntfcIoError;
                    }
                }
                disconnect(mController, &QLowEnergyController::stateChanged, this, &InterfaceTask::onControllerStateChanged);
                mController->deleteLater();
                mController = nullptr;
            }
        }
        if(mState != State::Disconnecting && mError == OpResult::Success)
            mError = OpResult::IntfcUnexpectedResponse;
        mTxChar = QLowEnergyCharacteristic();
        mRxChar = QLowEnergyCharacteristic();
        setState(State::Disconnected);
        break;
    case QLowEnergyController::ConnectingState:
        Q_ASSERT(mState == State::Connecting);
        // do nothing, wait for connected
        break;
    case QLowEnergyController::ConnectedState:
        Q_ASSERT(mState == State::Connecting);
        setState(State::DiscoveringServices);
        stateLocker.unlock();
    {
        QMutexLocker locker(&mControllerMutex);
        Q_ASSERT(mController);
        mController->discoverServices();
    }
        break;
    case QLowEnergyController::DiscoveringState:
        Q_ASSERT(mState == State::DiscoveringServices);
        // do nothing, wait for service discovery to finish
        break;
    case QLowEnergyController::DiscoveredState:
    {
        QMutexLocker controllerLocker(&mControllerMutex);
        Q_ASSERT(mController);
        QMutexLocker serviceLocker(&mXcpServiceMutex);
        Q_ASSERT(mState == State::DiscoveringServices);
        mXcpService = mController->createServiceObject(XCP_SERVICE_UUID, this);

        if(mXcpService)
        {
            connect(mXcpService, &QLowEnergyService::stateChanged, this, &InterfaceTask::onServiceStateChanged);
            connect(mXcpService, &QLowEnergyService::characteristicChanged, this, &InterfaceTask::onCharacteristicChanged);
            connect(mXcpService, &QLowEnergyService::descriptorWritten, this, &InterfaceTask::onDescriptorWritten);
            setState(State::DiscoveringCharacteristics);
            stateLocker.unlock();
            mXcpService->discoverDetails();
        }
        else
        {
            mError = OpResult::BadReply;
            setState(State::Disconnecting);
            stateLocker.unlock();
            mController->disconnectFromDevice();
        }
    }
        break;
    case QLowEnergyController::ClosingState:
        setState(State::Disconnecting);
        break;
    case QLowEnergyController::AdvertisingState:
        Q_ASSERT(state != QLowEnergyController::AdvertisingState);
        break;
    default:
        Q_ASSERT(state != state);
        break;
    }
}

void InterfaceTask::onServiceStateChanged(QLowEnergyService::ServiceState state)
{
    QMutexLocker stateLocker(&mStateMutex);
    switch(state)
    {
    case QLowEnergyService::InvalidService:
        // do nothing, should be handled by onControllerStateChanged
        break;
    case QLowEnergyService::DiscoveryRequired:
        // do nothing, should be handled by onControllerStateChanged
        break;
    case QLowEnergyService::DiscoveringServices:
        Q_ASSERT(mState == State::DiscoveringCharacteristics);
        // do nothing, wait for discovery
        break;
    case QLowEnergyService::ServiceDiscovered:
        Q_ASSERT(mState == State::DiscoveringCharacteristics);

    {
        QMutexLocker controllerLocker(&mControllerMutex);
        QMutexLocker serviceLocker(&mXcpServiceMutex);
        Q_ASSERT(mController);
        Q_ASSERT(mXcpService);
        mTxChar = mXcpService->characteristic(TX_CHAR_UUID);
        mRxChar = mXcpService->characteristic(RX_CHAR_UUID);
        for(auto desc : mRxChar.descriptors())
        {
            if(desc.type() == QBluetoothUuid::ClientCharacteristicConfiguration)
            {
                mRxCharClientConfig = desc;
                break;
            }
        }
    }

        if(mTxChar.isValid() && mRxChar.isValid() && mRxCharClientConfig.isValid())
        {
            QMutexLocker controllerLocker(&mControllerMutex);
            QMutexLocker serviceLocker(&mXcpServiceMutex);

            setState(State::SettingClientCharConfig);
            mXcpService->writeDescriptor(mRxCharClientConfig, QByteArray::fromHex("0100"));
        }
        else
        {
            mError = OpResult::BadReply;
            setState(State::Disconnecting);
            stateLocker.unlock();
            QMutexLocker controllerLocker(&mControllerMutex);
            Q_ASSERT(mController);
            mController->disconnectFromDevice();
        }
        break;
    default:
        Q_ASSERT(state != state);
    }
}

void InterfaceTask::setState(State val)
{
    qDebug() << "Interface task state" << int(mState) << "->" << int(val);
    if(updateDelta<>(mState, val))
    {
        {
            QMutexLocker remoteAddressLocker(&mRemoteAddressMutex);

            if(mState == State::Connected)
#ifdef Q_OS_MAC
                mRemoteAddress = QString::fromUtf16(mRemoteDevUuid.utf16());  // force deep copy
#else
                mRemoteAddress = mController->remoteAddress();
#endif
            else
                mRemoteAddress = QString();
        }
        emit stateChanged();
        mStateCondition.wakeAll();
    }
}

Interface::Interface(QObject *parent) :
    SetupTools::Xcp::Interface::Interface(parent),
    mThread(new QThread(this)),
    mTask(new InterfaceTask(nullptr))
{
    mTask->moveToThread(mThread);
    mThread->start();
    connect(this, &Interface::taskStartConnect, mTask, &InterfaceTask::startConnect, Qt::QueuedConnection);
    connect(this, &Interface::taskStartDisconnect, mTask, &InterfaceTask::startDisconnect, Qt::QueuedConnection);
    connect(this, &Interface::taskTransmit, mTask, &InterfaceTask::transmit, Qt::QueuedConnection);
    connect(mTask, &InterfaceTask::stateChanged, this, &Interface::onTaskStateChanged, Qt::QueuedConnection);
}

Interface::~Interface()
{
    mThread->quit();
    mThread->wait();
}

bool Interface::isConnected()
{
    return !mRemoteAddress.isEmpty();
}

QString Interface::connectedTarget()
{
    return mRemoteAddress;
}

OpResult Interface::setTarget(const QString & target)
{
    QBluetoothDeviceInfo info;
#ifdef Q_OS_MAC
    const QUuid uuid(target);
    if(!uuid.isNull())
        info = QBluetoothDeviceInfo(uuid, "", 0);
#else
    const QBluetoothAddress addr(target);
    if(!addr.isNull())
        info = QBluetoothDeviceInfo(addr, "", 0);
#endif
    if(info.isValid())
        return connectToDevice(info);
    else
        return disconnectFromDevice();
}

OpResult Interface::transmit(const std::vector<quint8> &data, bool replyExpected)
{
    Q_UNUSED(replyExpected);

    if(mTask->state() != InterfaceTask::State::Connected)
        return OpResult::InvalidOperation;

    taskTransmit(data);

    return OpResult::Success;
}

OpResult Interface::receive(int timeoutMsec, std::vector<std::vector<quint8> > &out)
{
    return mTask->receive(timeoutMsec, out);
}

OpResult Interface::clearReceived()
{
    mTask->clearReceived();
    return OpResult::Success;
}

OpResult Interface::setPacketLog(bool enable)
{
    mTask->setPacketLog(enable);
    return OpResult::Success;
}

bool Interface::hasReliableTx()
{
    return true;
}

bool Interface::allowsMultipleReplies()
{
    return true;
}

int Interface::maxReplyTimeout()
{
    return std::numeric_limits<int>::max();
}

void Interface::onTaskStateChanged()
{
    QString oldAddress = mRemoteAddress;
    mRemoteAddress = mTask->remoteAddress();

    if(oldAddress != mRemoteAddress)
        emit connectedTargetChanged(connectedTarget());
    if(oldAddress.isEmpty() != mRemoteAddress.isEmpty())
        emit connectedChanged();
}

OpResult Interface::connectToDevice(QBluetoothDeviceInfo dev)
{
    if(mTask->state() != InterfaceTask::State::Disconnected)
        return OpResult::InvalidOperation;

    taskStartConnect(dev);

    OpResult out = mTask->waitForConnect();
    return out;
}

OpResult Interface::disconnectFromDevice()
{
    if(mTask->state() == InterfaceTask::State::Disconnected)
        return OpResult::Success;
    if(mTask->state() != InterfaceTask::State::Connected)
        return OpResult::InvalidOperation;

    taskStartDisconnect();

    OpResult out = mTask->waitForDisconnect();
    return out;
}

} // namespace Ble
} // namespace Interface
} // namespace Xcp
} // namespace SetupTools
