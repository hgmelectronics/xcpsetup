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
    connect(mConn, &ConnectionFacade::opMsg, this, &ParamLayer::onConnOpMsg);
    connect(mConn, &ConnectionFacade::stateChanged, this, &ParamLayer::onConnStateChanged);
    connect(mConn, &ConnectionFacade::nvWriteDone, this, &ParamLayer::onConnNvWriteDone);
    connect(mConn, &ConnectionFacade::uploadDone, this, &ParamLayer::onParamUploadDone);
    connect(mConn, &ConnectionFacade::downloadDone, this, &ParamLayer::onParamDownloadDone);
}

QUrl ParamLayer::intfcUri()
{
    return mConn->intfcUri();
}

void ParamLayer::setIntfcUri(QUrl uri)
{
    if(mConn->intfc() && qobject_cast<Interface::Can::Interface *>(mConn->intfc()))
        disconnect(qobject_cast<Interface::Can::Interface *>(mConn->intfc()), &Interface::Can::Interface::slaveIdChanged, this, &ParamLayer::onIntfcSlaveIdChanged);
    mConn->setIntfcUri(uri);
    if(mConn->intfc())
    {
        if(mConn->intfc() && qobject_cast<Interface::Can::Interface *>(mConn->intfc()))
            connect(qobject_cast<Interface::Can::Interface *>(mConn->intfc()), &Interface::Can::Interface::slaveIdChanged, this, &ParamLayer::onIntfcSlaveIdChanged);
        if(QProcessEnvironment::systemEnvironment().value("XCP_PACKET_LOG", "0") == "1")
            mConn->intfc()->setPacketLog(true);
        else
            mConn->intfc()->setPacketLog(false);
    }
    emit intfcChanged();
}

Interface::Interface *ParamLayer::intfc()
{
    return mConn->intfc();
}

void ParamLayer::setIntfc(Interface::Interface *intfc, QUrl uri)
{
    if(mConn->intfc() && qobject_cast<Interface::Can::Interface *>(mConn->intfc()))
        disconnect(qobject_cast<Interface::Can::Interface *>(mConn->intfc()), &Interface::Can::Interface::slaveIdChanged, this, &ParamLayer::onIntfcSlaveIdChanged);
    mConn->setIntfc(intfc, uri);
    if(mConn->intfc())
    {
        if(mConn->intfc() && qobject_cast<Interface::Can::Interface *>(mConn->intfc()))
            connect(qobject_cast<Interface::Can::Interface *>(mConn->intfc()), &Interface::Can::Interface::slaveIdChanged, this, &ParamLayer::onIntfcSlaveIdChanged);
        if(QProcessEnvironment::systemEnvironment().value("XCP_PACKET_LOG", "0") == "1")
            mConn->intfc()->setPacketLog(true);
        else
            mConn->intfc()->setPacketLog(false);
    }
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
    case State::IntfcNotOk:     return true;
    case State::Disconnected:   return true;
    case State::Connect:        return false;
    case State::Connected:      return true;
    case State::Download:       return false;
    case State::Upload:         return false;
    case State::NvWrite:        return false;
    case State::Disconnect:     return false;
    default:                    return true;
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

void ParamLayer::setSlaveCalPage()
{
    mConn->setCalPage(0, 0);
}

double ParamLayer::opProgress()
{
    if(mActiveKeys.empty() || mActiveKeyIdx < 0)
        return 0;

    Q_ASSERT(mActiveKeyIdx <= mActiveKeys.size());
    return mActiveKeyIdx / double(mActiveKeys.size());
}

ConnectionFacade * ParamLayer::conn()
{
    return mConn;
}

ParamRegistry * ParamLayer::registry()
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

QStringList ParamLayer::setData(QVariantMap data, bool eraseOld)
{
    ParamHistoryElide elide = mRegistry->historyElide();

    QStringList failedKeys;

    QStringList keys = data.keys();

    for(QString key : keys)
    {
        Param *param = mRegistry->getParam(key);
        if(param != nullptr)
        {
            if(param->setSerializableValue(data[key]))
                param->setValid(true);
            else
                failedKeys.push_back(key);
        }
    }

    if(eraseOld)
    {
        QSet<QString> keysSet = QSet<QString>::fromList(mRegistry->paramKeys());
        keysSet.subtract(QSet<QString>::fromList(keys));    // remove the keys that were given as data
        keysSet.unite(QSet<QString>::fromList(failedKeys)); // add back keys that didn't set successfully
        for(QString key : keysSet)
        {
            Param *param = mRegistry->getParam(key);
            if(param != nullptr)
                param->setSerializableRawValue(QVariant());
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

QStringList ParamLayer::setRawData(QVariantMap data, bool eraseOld)
{
    ParamHistoryElide elide = mRegistry->historyElide();

    QStringList failedKeys;

    QStringList keys = data.keys();

    for(QString key : keys)
    {
        Param *param = mRegistry->getParam(key);
        if(param != nullptr)
        {
            if (param->setSerializableRawValue(data[key]))
                param->setValid(true);
            else
                failedKeys.push_back(key);
        }
    }

    if(eraseOld)
    {
        QSet<QString> keysSet = QSet<QString>::fromList(mRegistry->paramKeys());
        keysSet.subtract(QSet<QString>::fromList(keys));    // remove the keys that were given as data
        keysSet.unite(QSet<QString>::fromList(failedKeys)); // add back keys that didn't set successfully
        for(QString key : keysSet)
        {
            Param *param = mRegistry->getParam(key);
            if(param != nullptr)
                param->setSerializableRawValue(QVariant());
        }
    }

    return failedKeys;
}

QMap<QString, QVariant> ParamLayer::names()
{
    return names(mRegistry->paramKeys());
}

QMap<QString, QVariant> ParamLayer::names(const QStringList &keys)
{
    QMap<QString, QVariant> map;
    for(QString key : keys)
    {
        Param *param = mRegistry->getParam(key);
        if(param == nullptr)
            continue;

        map.insert(key, param->name());
    }
    return map;
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
    {
        mConn->setState(Connection::State::CalMode);
    }
    else
    {
        mParamHistoryElide = mRegistry->historyElide();
        downloadKey();
    }
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
    {
        mConn->setState(Connection::State::CalMode);
    }
    else
    {
        mParamHistoryElide = mRegistry->historyElide();
        uploadKey();
    }
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
            mParamHistoryElide = mRegistry->historyElide();
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
            mParamHistoryElide = mRegistry->historyElide();
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

void ParamLayer::onConnOpMsg(SetupTools::OpResult result, QString str, SetupTools::Xcp::Connection::OpExtInfo ext)
{
    QString extStr = str;
    if(ext.addr && mActiveParam)
    {
        if(mActiveParam->minSize() > mActiveParam->dataTypeSize())
        {
            // looks like an array
            XcpPtr paramAddr = XcpPtr::fromVariant(mActiveParam->addr());
            quint32 offset = (ext.addr.get().addr - paramAddr.addr) * mConn->addrGran() / mActiveParam->dataTypeSize();

            extStr = tr("%1 (%2, offset %3)").arg(str).arg(mActiveParam->name()).arg(offset);
        }
        else
        {
            extStr = tr("%1 (%2)").arg(str).arg(mActiveParam->name());
        }
    }

    if(ext.type == Connection::OpType::Upload && result == OpResult::SlaveErrorOutOfRange)
        emit info(result, extStr);
    else
        emit fault(result, extStr);
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

void ParamLayer::onParamDownloadDone(OpResult result, XcpPtr base, const std::vector<quint8> &data)
{
    Q_ASSERT(mState == State::Download);
    if(result != OpResult::Success && mActiveResult == OpResult::Success)
        mActiveResult = result;

    if(mActiveParam->fullReload())
        mConn->upload(XcpPtr::fromVariant(mActiveParam->addr()), mActiveParam->loadedBytes());
    else
        mConn->upload(base, data.size());
}

void ParamLayer::onParamUploadDone(OpResult result, XcpPtr base, int len, const std::vector<quint8> &data)
{
    XcpPtr paramBase = XcpPtr::fromVariant(mActiveParam->addr());
    quint32 offset = (base.addr - paramBase.addr) * mConn->addrGran();

    bool doNotAdvance = false;

    if(mState == State::Upload)
    {
        Q_ASSERT(offset > 0 || len == int(mActiveParam->minSize()));   // if upload base is param base, upload should be of minSize

        if(result == OpResult::Success && mActiveParam->maxSize() > (offset + len))
        {
            // can do another element
            XcpPtr newBase = base;
            newBase.addr += len / mConn->addrGran();
            mConn->upload(newBase, mActiveParam->dataTypeSize());
            doNotAdvance = true;
        }
        else if(result == OpResult::SlaveErrorOutOfRange)
        {
            if(offset < mActiveParam->minSize())
                mActiveParam->setValid(false);  // slave does not have the minimum number of bytes, param is invalid, but do not capture the error

            // otherwise, out of range, but we already have min size loaded; do not capture this result
        }
        else if(result != OpResult::Success && mActiveResult == OpResult::Success)
        {
            mActiveResult = result;
        }
    }
    else if(mState == State::Download)
    {
        if(result != OpResult::Success && mActiveResult == OpResult::Success)
            mActiveResult = result;
    }
    else if(mState == State::Disconnect)
    {
        return;
    }
    else
    {
        Q_ASSERT(mState == State::Upload || mState == State::Download || mState == State::Disconnect);
    }

    if(!data.empty())
        mActiveParam->setSlaveBytes({data.data(), data.data() + data.size()}, offset);

    if(doNotAdvance)
        return;

    if(mState == State::Upload)
        emit mActiveParam->uploadDone(result);
    else if(mState == State::Download)
        emit mActiveParam->downloadDone(result);

    ++mActiveKeyIdx;
    notifyProgress();

    if(mState == State::Upload)
        uploadKey();
    else // if(mState == State::Download)
        downloadKey();
}

void ParamLayer::onRegistryWriteCacheDirtyChanged()
{
    emit writeCacheDirtyChanged();
}

void ParamLayer::downloadKey()
{
    Q_ASSERT(mState == State::Download);
    Q_ASSERT(mActiveKeyIdx >= 0 && mActiveKeyIdx <= mActiveKeys.size());

    while(1)
    {
        mActiveParam = getNextParam();
        if(mActiveParam == nullptr)
        {
            setState(State::Connected);
            mParamHistoryElide.reset();
            mActiveKeyIdx = -1;
            emit opProgressChanged();
            emit downloadDone(mActiveResult, mActiveKeys);
            break;
        }
        if(mActiveParam->writeCacheDirty() && mActiveParam->valid())
        {
            qDebug() << mActiveParam->name() << "dirty";
            int ag = mConn->addrGran();
            QPair<quint32, quint32> changed = mActiveParam->changedBytes();
            std::vector<quint8> data(mActiveParam->bytes().begin() + changed.first / ag * ag,               // round down to next AG
                                     mActiveParam->bytes().begin() + (changed.second + ag - 1) / ag * ag);  // round up to next AG
            XcpPtr base = XcpPtr::fromVariant(mActiveParam->addr());
            base.addr += changed.first / mConn->addrGran();
            mConn->download(base, data);
            break;
        }
        ++mActiveKeyIdx;
    }
}

void ParamLayer::uploadKey()
{
    Q_ASSERT(mState == State::Upload);
    Q_ASSERT(mActiveKeyIdx >= 0 && mActiveKeyIdx <= mActiveKeys.size());

    mActiveParam = getNextParam();
    if(mActiveParam == nullptr)
    {
        setState(State::Connected);
        mParamHistoryElide.reset();
        mActiveKeyIdx = -1;
        emit opProgressChanged();
        emit uploadDone(mActiveResult, mActiveKeys);
        return;
    }

    mConn->upload(XcpPtr::fromVariant(mActiveParam->addr()), mActiveParam->minSize());
}

void ParamLayer::onIntfcSlaveIdChanged()
{
    emit slaveIdChanged();
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

