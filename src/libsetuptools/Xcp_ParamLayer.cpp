#include "Xcp_ParamLayer.h"

namespace SetupTools {
namespace Xcp {

ParamLayer::ParamLayer(quint32 addrGran, QObject *parent) :
    QObject(parent),
    mConn(new ConnectionFacade(this)),
    mRegistry(new ParamRegistry(addrGran, this)),
    mState(State::IntfcNotOk),
    mOpProgressNotifyPeriod(1),
    mActiveKeyIt(mActiveKeys.end())
{
    mRegistry->setConnectionFacade(mConn);
    connect(mConn, &ConnectionFacade::setStateDone, this, &ParamLayer::onConnSetStateDone);
    connect(mConn, &ConnectionFacade::stateChanged, this, &ParamLayer::onConnStateChanged);
    connect(mConn, &ConnectionFacade::nvWriteDone, this, &ParamLayer::onConnNvWriteDone);
}

QUrl ParamLayer::intfcUri()
{
    return mConn->intfcUri();
}

void ParamLayer::setIntfcUri(QUrl uri)
{
    mConn->setIntfcUri(uri);
    emit intfcChanged();
}

Interface::Interface *ParamLayer::intfc()
{
    return mConn->intfc();
}

void ParamLayer::setIntfc(Interface::Interface *intfc, QUrl uri)
{
    mConn->setIntfc(intfc, uri);
    emit intfcChanged();
}

QString ParamLayer::slaveId()
{
    return mConn->slaveId();
}

void ParamLayer::setSlaveId(QString id)
{
    mConn->setSlaveId(id);
}

bool ParamLayer::idle()
{
    return (mState == State::Disconnected || mState == State::IntfcNotOk);
}

bool ParamLayer::intfcOk()
{
    return (mState != State::IntfcNotOk);
}

int ParamLayer::slaveTimeout()
{
    return mConn->timeout();
}

void ParamLayer::setSlaveTimeout(int timeout)
{
    mConn->setTimeout(timeout);
}

int ParamLayer::slaveNvWriteTimeout()
{
    return mConn->nvWriteTimeout();
}

void ParamLayer::setSlaveNvWriteTimeout(int timeout)
{
    mConn->setNvWriteTimeout(timeout);
}

int ParamLayer::opProgressNotifyPeriod()
{
    return mOpProgressNotifyPeriod;
}

void ParamLayer::setOpProgressNotifyPeriod(int val)
{
    Q_ASSERT(val > 0);
    mOpProgressNotifyPeriod = val;
}

double ParamLayer::opProgress()
{
    if(mActiveKeys.empty())
        return 0;

    return std::distance(mActiveKeys.begin(), mActiveKeyIt) / double(mActiveKeys.size());
}

ConnectionFacade *ParamLayer::conn()
{
    return mConn;
}

ParamRegistry *ParamLayer::registry()
{
    return mRegistry;
}

bool ParamLayer::writeCacheDirty()
{
    return mRegistry->writeCacheDirty();
}

QMap<QString, QVariant> ParamLayer::data()
{
    return data(mRegistry->paramKeys());
}

QMap<QString, QVariant> ParamLayer::saveableData()
{
    return data(mRegistry->saveableParamKeys());
}

QMap<QString, QVariant> ParamLayer::data(const QStringList &keys)
{
    QMap<QString, QVariant> ret;
    for(QString key : keys)
    {
        Param *param = mRegistry->getParam(key);
        Q_ASSERT(param != nullptr);
        if(param->valid())
        {
            bool anyInRange = false;
            QVariant value = param->getSerializableValue(nullptr, &anyInRange);
            if(anyInRange)
                ret[key] = value;
        }
    }
    return ret;
}

QStringList ParamLayer::setData(const QMap<QString, QVariant> &data)
{
    QStringList failedKeys;

    QStringList keys = data.keys();

    for(QString key : keys)
    {
        bool ok = false;

        Param *param = mRegistry->getParam(key);
        if(param != nullptr)
            ok = param->setSerializableValue(data[key]);

        if(!ok)
            failedKeys.push_back(key);
    }

    return failedKeys;
}

void ParamLayer::download()
{
    download(mRegistry->paramKeys());
}

void ParamLayer::upload()
{
    upload(mRegistry->paramKeys());
}

void ParamLayer::download(QStringList keys)
{
    if(!(mState == State::Disconnected || mState == State::Connected)
            || !(mConn->state() == Connection::State::Closed || mConn->state() == Connection::State::CalMode))
    {
        emit downloadDone(OpResult::InvalidOperation, keys);
        return;
    }

    mActiveKeys = keys;
    mActiveKeyIt = mActiveKeys.begin();
    mActiveResult = OpResult::Success;
    emit opProgressChanged();

    if(keys.empty())
    {
        emit downloadDone(OpResult::Success, keys);
        return;
    }

    setState(State::Download);

    if(mConn->state() != Connection::State::CalMode)
        mConn->setState(Connection::State::CalMode);
    else
        downloadKey();
}

void ParamLayer::upload(QStringList keys)
{
    if(!(mState == State::Disconnected || mState == State::Connected)
            || !(mConn->state() == Connection::State::Closed || mConn->state() == Connection::State::CalMode))
    {
        emit uploadDone(OpResult::InvalidOperation, keys);
        return;
    }

    mActiveKeys = keys;
    mActiveKeyIt = mActiveKeys.begin();
    mActiveResult = OpResult::Success;
    emit opProgressChanged();

    if(keys.empty())
    {
        emit uploadDone(OpResult::Success, keys);
        return;
    }

    setState(State::Upload);

    if(mConn->state() != Connection::State::CalMode)
        mConn->setState(Connection::State::CalMode);
    else
        uploadKey();
}

void ParamLayer::nvWrite()
{
    if(!(mState == State::Disconnected || mState == State::Connected)
            || !(mConn->state() == Connection::State::Closed || mConn->state() == Connection::State::CalMode))
    {
        emit nvWriteDone(OpResult::InvalidOperation);
        return;
    }

    mActiveResult = OpResult::Success;

    setState(State::NvWrite);

    if(mConn->state() != Connection::State::CalMode)
        mConn->setState(Connection::State::CalMode);
    else
        mConn->nvWrite();
}

void ParamLayer::connectSlave()
{
    if(!(mState == State::Disconnected || mState == State::Connected)
            || !(mConn->state() == Connection::State::Closed || mConn->state() == Connection::State::CalMode))
    {
        emit connectSlaveDone(OpResult::InvalidOperation);
        return;
    }

    disconnect(mActiveParamConnection);
    mActiveKeys.clear();
    mActiveKeyIt = mActiveKeys.end();

    if(mConn->state() == Connection::State::CalMode)
    {
        setState(State::Connected);
        emit connectSlaveDone(OpResult::Success);
    }
    else
    {
        setState(State::Connect);
        mConn->setState(Connection::State::CalMode);
    }
}

void ParamLayer::disconnectSlave()
{
    if(mState == State::Connect)
    {
        emit disconnectSlaveDone(OpResult::InvalidOperation);
        return;
    }

    disconnect(mActiveParamConnection);
    mActiveKeys.clear();
    mActiveKeyIt = mActiveKeys.end();

    if(mConn->state() == Connection::State::IntfcInvalid)
    {
        emit disconnectSlaveDone(OpResult::Success);
        return;
    }

    setState(State::Disconnect);
    mConn->setState(Connection::State::Closed);
}

void ParamLayer::onConnSetStateDone(OpResult result)
{
    switch(mState)
    {
    case State::Connect:
        if(result == OpResult::Success)
        {
            Q_ASSERT(mConn->state() == Connection::State::CalMode);
            setState(State::Connected);
        }
        else
        {
            setState(State::Disconnected);
        }
        emit connectSlaveDone(result);
        break;
    case State::Download:
        if(result == OpResult::Success)
        {
            Q_ASSERT(mConn->state() == Connection::State::CalMode);
            downloadKey();
        }
        else
        {
            setState(State::Disconnected);
            emit downloadDone(result, mActiveKeys);
        }
        break;
    case State::Upload:
        if(result == OpResult::Success)
        {
            Q_ASSERT(mConn->state() == Connection::State::CalMode);
            uploadKey();
        }
        else
        {
            setState(State::Disconnected);
            emit uploadDone(result, mActiveKeys);
        }
        break;
    case State::NvWrite:
        if(result == OpResult::Success)
        {
            Q_ASSERT(mConn->state() == Connection::State::CalMode);
            mConn->nvWrite();
        }
        else
        {
            setState(State::Disconnected);
            emit nvWriteDone(result);
        }
        break;
    case State::Disconnect:
        setState(State::Disconnected);
        emit disconnectSlaveDone(result);
        break;
    case State::IntfcNotOk:
    case State::Disconnected:
        break;  // do nothing - interface may be shared with another data layer e.g. ProgramLayer
    case State::Connected:
    default:
        Q_ASSERT(0);
        break;
    }
}

void ParamLayer::onConnStateChanged()
{
    if(mState == State::Disconnected && mConn->state() == Connection::State::CalMode)
        mRegistry->resetCaches();

    Connection::State newState = mConn->state();
    if(newState == Connection::State::IntfcInvalid)
        setState(State::IntfcNotOk);
    else if(mState == State::IntfcNotOk && newState == Connection::State::Closed)
        setState(State::Disconnected);
}

void ParamLayer::onConnNvWriteDone(OpResult result)
{
    if(mState == State::NvWrite)    // set state only if actually in NV write state, because if not,
        setState(State::Connected); // the user probably aborted the operation with a disconnect

    emit nvWriteDone(result);
}

void ParamLayer::onParamDownloadDone(OpResult result)
{
    Q_ASSERT(mState == State::Download);
    if(result != OpResult::Success && mActiveResult == OpResult::Success)
        mActiveResult = result;

    disconnect(mActiveParamConnection);

    ++mActiveKeyIt;
    notifyProgress();
    downloadKey();
}

void ParamLayer::onParamUploadDone(OpResult result)
{
    Q_ASSERT(mState == State::Upload);
    if(result != OpResult::Success && mActiveResult == OpResult::Success)
        mActiveResult = result;

    disconnect(mActiveParamConnection);

    ++mActiveKeyIt;
    notifyProgress();
    uploadKey();
}

void ParamLayer::onRegistryWriteCacheDirtyChanged()
{
    emit writeCacheDirtyChanged();
}

void ParamLayer::downloadKey()
{
    Q_ASSERT(mState == State::Download);
    Q_ASSERT(mActiveKeyIt >= mActiveKeys.begin() && mActiveKeyIt <= mActiveKeys.end());

    Param *param = getNextParam();
    if(param == nullptr)
    {
        setState(State::Connected);
        emit downloadDone(mActiveResult, mActiveKeys);
        return;
    }
    mActiveParamConnection = QObject::connect(param, &Param::downloadDone, this, &ParamLayer::onParamDownloadDone);
    param->download();
}

void ParamLayer::uploadKey()
{
    Q_ASSERT(mState == State::Upload);
    Q_ASSERT(mActiveKeyIt >= mActiveKeys.begin() && mActiveKeyIt <= mActiveKeys.end());

    Param *param = getNextParam();
    if(param == nullptr)
    {
        setState(State::Connected);
        emit uploadDone(mActiveResult, mActiveKeys);
        return;
    }
    mActiveParamConnection = QObject::connect(param, &Param::uploadDone, this, &ParamLayer::onParamUploadDone);
    param->upload();
}

Param *ParamLayer::getNextParam()
{
    Param *param = nullptr;
    while(1)
    {
        if(mActiveKeyIt == mActiveKeys.end())
            break;
        param = mRegistry->getParam(*mActiveKeyIt);
        if(param != nullptr)
        {
            break;
        }
        else
        {
            if(mActiveResult == OpResult::Success)
                mActiveResult = OpResult::InvalidArgument;
        }

        ++mActiveKeyIt;
    }

    return param;
}

void ParamLayer::setState(State val)
{
    qDebug() << "Xcp::ParamLayer setState" << static_cast<int>(val);
    if(updateDelta<>(mState, val))
        emit stateChanged();
}

void ParamLayer::notifyProgress()
{
    if((std::distance(mActiveKeys.begin(), mActiveKeyIt) % mOpProgressNotifyPeriod) == 0)
        emit opProgressChanged();
}

} // namespace Xcp
} // namespace SetupTools

