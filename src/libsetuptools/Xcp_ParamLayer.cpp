#include "Xcp_ParamLayer.h"

namespace SetupTools {
namespace Xcp {

ParamLayer::ParamLayer(QObject *parent) :
    QObject(parent),
    mConn(new ConnectionFacade(this)),
    mRegistry(nullptr),
    mState(State::IntfcNotOk),
    mOpProgressNotifyPeriod(1),
    mActiveKeyIdx(-1)
{
    connect(mConn, &ConnectionFacade::setStateDone, this, &ParamLayer::onConnSetStateDone);
    connect(mConn, &ConnectionFacade::stateChanged, this, &ParamLayer::onConnStateChanged);
    connect(mConn, &ConnectionFacade::nvWriteDone, this, &ParamLayer::onConnNvWriteDone);
}

ParamLayer::ParamLayer(quint32 addrGran, QObject *parent) :
    ParamLayer(parent)
{
    setAddrGran(addrGran);
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
    emit slaveIdChanged();
}

bool ParamLayer::idle()
{
    switch(mState)
    {
    case State::IntfcNotOk:     return true;    break;
    case State::Disconnected:   return true;    break;
    case State::Connect:        return false;   break;
    case State::Connected:      return true;    break;
    case State::Download:       return false;   break;
    case State::Upload:         return false;   break;
    case State::NvWrite:        return false;   break;
    case State::Disconnect:     return false;   break;
    default:                    return true;    break;
    }
}

bool ParamLayer::intfcOk()
{
    return (mState != State::IntfcNotOk);
}

bool ParamLayer::slaveConnected()
{
    return !(mState == State::Disconnected || mState == State::IntfcNotOk);
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

void ParamLayer::forceSlaveSupportCalPage()
{
    mConn->forceSlaveSupportCalPage();
}

double ParamLayer::opProgress()
{
    if(mActiveKeys.empty() || mActiveKeyIdx < 0)
        return 0;

    Q_ASSERT(mActiveKeyIdx <= mActiveKeys.size());
    return mActiveKeyIdx / double(mActiveKeys.size());
}

ConnectionFacade *ParamLayer::conn()
{
    return mConn;
}

ParamRegistry *ParamLayer::registry()
{
    return mRegistry;
}

quint32 ParamLayer::addrGran()
{
    if(mRegistry)
        return mRegistry->addrGran();
    else
        return 0;
}

void ParamLayer::setAddrGran(quint32 val)
{
    if(!mRegistry)
    {
        mRegistry = new ParamRegistry(val, this);
        mRegistry->setConnectionFacade(mConn);
    }

    emit addrGranChanged();
}

bool ParamLayer::writeCacheDirty()
{
    return mRegistry->writeCacheDirty();
}

QMap<QString, QVariant> ParamLayer::data()
{
    return data(mRegistry->paramKeys());
}

QMap<QString, QVariant> ParamLayer::rawData()
{
    return rawData(mRegistry->paramKeys());
}

QMap<QString, QVariant> ParamLayer::saveableData()
{
    return data(mRegistry->saveableParamKeys());
}

QMap<QString, QVariant> ParamLayer::saveableRawData()
{
    return rawData(mRegistry->saveableParamKeys());
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

QStringList ParamLayer::setData(QVariantMap data)
{
    QStringList failedKeys;

    QStringList keys = data.keys();

    for(QString key : keys)
    {
        Param *param = mRegistry->getParam(key);
        if(param == nullptr)
        {
            continue;
        }

        if(param->setSerializableValue(data[key]))
        {
            param->setValid(true);
        }
        else
        {
            failedKeys.push_back(key);
        }
    }

    return failedKeys;
}

QMap<QString, QVariant> ParamLayer::rawData(const QStringList &keys)
{
    QMap<QString, QVariant> ret;
    for(QString key : keys)
    {
        Param *param = mRegistry->getParam(key);
        Q_ASSERT(param != nullptr);
        if(param->valid())
        {
            bool anyInRange = false;
            QVariant value = param->getSerializableRawValue(nullptr, &anyInRange);
            if(anyInRange)
                ret[key] = value;
        }
    }
    return ret;
}

QStringList ParamLayer::setRawData(QVariantMap data)
{
    QStringList failedKeys;

    QStringList keys = data.keys();

    for(QString key : keys)
    {
        Param *param = mRegistry->getParam(key);
        if(param == nullptr)
        {
            continue;
        }
        if (param->setSerializableRawValue(data[key]))
        {
            param->setValid(true);
        }
        else
        {
            failedKeys.push_back(key);
        }
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
    mActiveKeyIdx = 0;
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
    mActiveKeyIdx = 0;
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
    mActiveKeyIdx = -1;

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
    mActiveKeyIdx = -1;

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
    if(mState == State::Connect && mConn->state() == Connection::State::CalMode)
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

    ++mActiveKeyIdx;
    notifyProgress();
    downloadKey();
}

void ParamLayer::onParamUploadDone(OpResult result)
{
    Q_ASSERT(mState == State::Upload);
    if(result != OpResult::Success && mActiveResult == OpResult::Success)
        mActiveResult = result;

    disconnect(mActiveParamConnection);

    ++mActiveKeyIdx;
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
    Q_ASSERT(mActiveKeyIdx >= 0 && mActiveKeyIdx <= mActiveKeys.size());

    Param *param = getNextParam();
    if(param == nullptr)
    {
        setState(State::Connected);
        mActiveKeyIdx = -1;
        emit opProgressChanged();
        emit downloadDone(mActiveResult, mActiveKeys);
        return;
    }
    mActiveParamConnection = QObject::connect(param, &Param::downloadDone, this, &ParamLayer::onParamDownloadDone);
    param->download();
}

void ParamLayer::uploadKey()
{
    Q_ASSERT(mState == State::Upload);
    Q_ASSERT(mActiveKeyIdx >= 0 && mActiveKeyIdx <= mActiveKeys.size());

    Param *param = getNextParam();
    if(param == nullptr)
    {
        setState(State::Connected);
        mActiveKeyIdx = -1;
        emit opProgressChanged();
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
        if(mActiveKeyIdx >= mActiveKeys.size())
            break;
        param = mRegistry->getParam(mActiveKeys[mActiveKeyIdx]);
        if(param != nullptr)
        {
            break;
        }
        else
        {
            if(mActiveResult == OpResult::Success)
                mActiveResult = OpResult::InvalidArgument;
        }

        ++mActiveKeyIdx;
    }

    return param;
}

void ParamLayer::setState(State val)
{
    if(updateDelta<>(mState, val))
        emit stateChanged();
}

void ParamLayer::notifyProgress()
{
    if((mActiveKeyIdx % mOpProgressNotifyPeriod) == 0
            || mActiveKeyIdx == mActiveKeys.size())
        emit opProgressChanged();
}

} // namespace Xcp
} // namespace SetupTools

