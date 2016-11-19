#include "Xcp_Interface_Ble_Interface.h"

namespace SetupTools {
namespace Xcp {
namespace Interface {
namespace Ble {

static const QBluetoothUuid XCP_SERVICE_UUID(QString("e7fc7a82-5947-4aad-8e90-c88ac2deca6c"));
static const QBluetoothUuid TX_CHAR_UUID(QString("89c5f9cf-b2a4-444f-ac01-8b87c8625a00"));
static const QBluetoothUuid RX_CHAR_UUID(QString("89c5f9cf-b2a4-444f-ac01-8b87c8625a01"));

InterfaceTask::InterfaceTask(QObject * parent) :
    QObject(parent),
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
    while(1)
    {
        QMutexLocker locker(&mStateMutex);
        if(mState == State::Connected)
            return OpResult::Success;
        if(mState == State::Disconnected)
            return mError;
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
        mStateCondition.wait(locker.mutex());
    }
}

void InterfaceTask::startConnect(QBluetoothAddress dev)
{
    {
        QMutexLocker locker(&mStateMutex);
        mController = QLowEnergyController::createCentral(QBluetoothDeviceInfo(dev, "", 0), this);

        connect(mController, &QLowEnergyController::stateChanged, this, &InterfaceTask::onControllerStateChanged);

        mError = OpResult::Success;
        setState(State::Connecting);
    }

    mController->connectToDevice();
}

void InterfaceTask::startDisconnect()
{
    {
        QMutexLocker locker(&mStateMutex);

        if(mState == State::Disconnected)
            return;

        mError = OpResult::Success;
        setState(State::Disconnecting);
    }

    mController->disconnectFromDevice();
}

void InterfaceTask::transmit(const std::vector<quint8> &data)
{
    mXcpService->writeCharacteristic(mTxChar,
                                     QByteArray::fromRawData(reinterpret_cast<const char *>(data.data()), data.size()),
                                     QLowEnergyService::WriteWithoutResponse);
}

void InterfaceTask::onCharacteristicChanged(const QLowEnergyCharacteristic &characteristic, const QByteArray &newValue)
{
    if(characteristic == mRxChar)
        mRxQueue.put(std::vector<quint8>(newValue.begin(), newValue.end()));
}

void InterfaceTask::onControllerStateChanged(QLowEnergyController::ControllerState state)
{
    switch(state)
    {
    case QLowEnergyController::UnconnectedState:
    {
        QMutexLocker locker(&mStateMutex);
        if(mXcpService)
        {
            disconnect(mXcpService, &QLowEnergyService::stateChanged, this, &InterfaceTask::onServiceStateChanged);
            delete mXcpService;
            mXcpService = nullptr;
        }
        if(mController)
        {
            disconnect(mController, &QLowEnergyController::stateChanged, this, &InterfaceTask::onControllerStateChanged);
            delete mController;
            mController = nullptr;
        }
        mTxChar = QLowEnergyCharacteristic();
        mRxChar = QLowEnergyCharacteristic();
        setState(State::Disconnected);
    }
        break;
    case QLowEnergyController::ConnectingState:
    {
        QMutexLocker locker(&mStateMutex);
        Q_ASSERT(mState == State::Connecting);
    }
        // do nothing, wait for connected
        break;
    case QLowEnergyController::ConnectedState:
    {
        QMutexLocker locker(&mStateMutex);
        Q_ASSERT(mState == State::Connecting);
        setState(State::DiscoveringServices);
        locker.unlock();
        mController->discoverServices();
    }
        break;
    case QLowEnergyController::DiscoveringState:
    {
        QMutexLocker locker(&mStateMutex);
        Q_ASSERT(mState == State::DiscoveringServices);
    }
        // do nothing, wait for service discovery to finish
        break;
    case QLowEnergyController::DiscoveredState:
    {
        QMutexLocker locker(&mStateMutex);
        Q_ASSERT(mState == State::DiscoveringServices);
        mXcpService = mController->createServiceObject(XCP_SERVICE_UUID, this);

        if(mXcpService)
        {
            connect(mXcpService, &QLowEnergyService::stateChanged, this, &InterfaceTask::onServiceStateChanged);
            setState(State::DiscoveringCharacteristics);
            locker.unlock();
            mXcpService->discoverDetails();
        }
        else
        {
            mError = OpResult::BadReply;
            setState(State::Disconnecting);
            locker.unlock();
            mController->disconnectFromDevice();
        }
    }
        break;
    case QLowEnergyController::ClosingState:
    {
        QMutexLocker locker(&mStateMutex);
        setState(State::Disconnecting);
    }
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
    switch(state)
    {
    case QLowEnergyService::InvalidService:
        // do nothing, should be handled by onControllerStateChanged
        break;
    case QLowEnergyService::DiscoveryRequired:
        // do nothing, should be handled by onControllerStateChanged
        break;
    case QLowEnergyService::DiscoveringServices:
    {
        QMutexLocker locker(&mStateMutex);
        Q_ASSERT(mState == State::DiscoveringCharacteristics);
    }
        // do nothing, wait for discovery
        break;
    case QLowEnergyService::ServiceDiscovered:
    {
        QMutexLocker locker(&mStateMutex);
        Q_ASSERT(mState == State::DiscoveringCharacteristics);

        mTxChar = mXcpService->characteristic(TX_CHAR_UUID);
        mRxChar = mXcpService->characteristic(RX_CHAR_UUID);

        if(mTxChar.isValid() && mRxChar.isValid())
        {
            setState(State::Connected);
        }
        else
        {
            mError = OpResult::BadReply;
            setState(State::Disconnecting);
            locker.unlock();
            mController->disconnectFromDevice();
        }
    }
        break;
    default:
        Q_ASSERT(state != state);
    }
}

void InterfaceTask::setState(State val)
{
    if(updateDelta<>(mState, val))
        emit stateChanged();
    mStateCondition.wakeAll();
}

Interface::Interface(QObject *parent) :
    SetupTools::Xcp::Interface::Interface(parent),
    mThread(new QThread(this)),
    mTask(new InterfaceTask(this))
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

}

bool Interface::isConnected()
{
    return !mRemoteAddress.isNull();
}

QString Interface::connectedTarget()
{
    return mRemoteAddress.toString();
}

OpResult Interface::setTarget(const QString & target)
{
    QBluetoothAddress addr(target);
    if(addr.isNull())
        return disconnectFromDevice();
    else
        return connectToDevice(addr);
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
    mRemoteAddress = mTask->remoteAddress();
    emit connectedChanged();
    emit connectedTargetChanged(connectedTarget());
}

OpResult Interface::connectToDevice(QBluetoothAddress dev)
{
    if(mTask->state() != InterfaceTask::State::Disconnected)
        return OpResult::InvalidOperation;

    taskStartConnect(dev);

    return mTask->waitForConnect();
}

OpResult Interface::disconnectFromDevice()
{
    if(mTask->state() != InterfaceTask::State::Connected)
        return OpResult::InvalidOperation;

    taskStartDisconnect();

    return mTask->waitForDisconnect();
}

} // namespace Ble
} // namespace Interface
} // namespace Xcp
} // namespace SetupTools
