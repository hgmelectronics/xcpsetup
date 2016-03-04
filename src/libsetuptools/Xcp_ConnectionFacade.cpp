#include "Xcp_ConnectionFacade.h"
#include "Xcp_Interface_Registry.h"
#include "Xcp_Interface_Can_Interface.h"

namespace SetupTools {
namespace Xcp {

ConnectionFacade::ConnectionFacade(QObject *parent) :
    QObject(parent),
    mIntfc(),
    mIntfcOwned(false),
    mConn(new Connection(nullptr)),
    mConnThread(new QThread(this))
{
    mConn->moveToThread(mConnThread);
    connect(mConnThread, &QThread::finished, mConn, &ConnectionFacade::deleteLater);
    mConnThread->start();

    connect(this, &ConnectionFacade::connSetState, mConn, &Connection::setState, Qt::QueuedConnection);
    connect(this, &ConnectionFacade::connUpload, mConn, &Connection::upload, Qt::QueuedConnection);
    connect(this, &ConnectionFacade::connDownload, mConn, &Connection::download, Qt::QueuedConnection);
    connect(this, &ConnectionFacade::connNvWrite, mConn, &Connection::nvWrite, Qt::QueuedConnection);
    connect(this, &ConnectionFacade::connSetCalPage, mConn, &Connection::setCalPage, Qt::QueuedConnection);
    connect(this, &ConnectionFacade::connProgramClear, mConn, &Connection::programClear, Qt::QueuedConnection);
    connect(this, &ConnectionFacade::connProgramRange, mConn, &Connection::programRange, Qt::QueuedConnection);
    connect(this, &ConnectionFacade::connProgramVerify, mConn, &Connection::programVerify, Qt::QueuedConnection);
    connect(this, &ConnectionFacade::connProgramReset, mConn, &Connection::programReset, Qt::QueuedConnection);
    connect(this, &ConnectionFacade::connBuildChecksum, mConn, &Connection::buildChecksum, Qt::QueuedConnection);
    connect(this, &ConnectionFacade::connGetAvailSlavesStr, mConn, &Connection::getAvailSlavesStr, Qt::QueuedConnection);

    connect(mConn, &Connection::setStateDone, this, &ConnectionFacade::onConnSetStateDone, Qt::QueuedConnection);
    connect(mConn, &Connection::uploadDone, this, &ConnectionFacade::onConnUploadDone, Qt::QueuedConnection);
    connect(mConn, &Connection::downloadDone, this, &ConnectionFacade::onConnDownloadDone, Qt::QueuedConnection);
    connect(mConn, &Connection::nvWriteDone, this, &ConnectionFacade::onConnNvWriteDone, Qt::QueuedConnection);
    connect(mConn, &Connection::setCalPageDone, this, &ConnectionFacade::onConnSetCalPageDone, Qt::QueuedConnection);
    connect(mConn, &Connection::programClearDone, this, &ConnectionFacade::onConnProgramClearDone, Qt::QueuedConnection);
    connect(mConn, &Connection::programRangeDone, this, &ConnectionFacade::onConnProgramRangeDone, Qt::QueuedConnection);
    connect(mConn, &Connection::programVerifyDone, this, &ConnectionFacade::onConnProgramVerifyDone, Qt::QueuedConnection);
    connect(mConn, &Connection::programResetDone, this, &ConnectionFacade::onConnProgramResetDone, Qt::QueuedConnection);
    connect(mConn, &Connection::buildChecksumDone, this, &ConnectionFacade::onConnBuildChecksumDone, Qt::QueuedConnection);
    connect(mConn, &Connection::getAvailSlavesStrDone, this, &ConnectionFacade::onConnGetAvailSlavesStrDone, Qt::QueuedConnection);
    connect(mConn, &Connection::opMsg, this, &ConnectionFacade::onConnOpMsg, Qt::QueuedConnection);
    connect(mConn, &Connection::stateChanged, this, &ConnectionFacade::onConnStateChanged, Qt::QueuedConnection);
    connect(mConn, &Connection::opProgressChanged, this, &ConnectionFacade::onConnOpProgressChanged, Qt::QueuedConnection);
}

ConnectionFacade::~ConnectionFacade()
{
    mConnThread->quit();
    mConnThread->wait();
}

QUrl ConnectionFacade::intfcUri()
{
    return mIntfcUri;
}

void ConnectionFacade::setIntfcUri(QUrl val)
{
    if(mIntfcUri != val)
    {
        if(mIntfc && mIntfcOwned)
            delete mIntfc;
        mIntfcUri = val;
        mIntfc = Interface::Registry().make(mIntfcUri);
        mIntfcOwned = true;
        mConn->setIntfc(mIntfc);
    }
}

Interface::Interface *ConnectionFacade::intfc()
{
    return mIntfc;
}

void ConnectionFacade::setIntfc(Interface::Interface *intfc, QUrl uri)
{
    if(mIntfc != intfc)
    {
        if(mIntfc && mIntfcOwned)
            delete mIntfc;
        mIntfcUri = uri;
        mIntfc = intfc;
        mIntfcOwned = false;
        mConn->setIntfc(intfc);
    }
}

QString ConnectionFacade::slaveId()
{
    SetupTools::Xcp::Interface::Can::Interface *canIntfc = qobject_cast<SetupTools::Xcp::Interface::Can::Interface *>(mIntfc);
    if(!canIntfc)
        return QString("");

    boost::optional<Interface::Can::SlaveId> id = canIntfc->getSlaveId();
    if(!id)
        return QString("");

    return Xcp::Interface::Can::SlaveIdToStr(id.get());
}

void ConnectionFacade::setSlaveId(QString val)
{
    SetupTools::Xcp::Interface::Can::Interface *canIntfc = qobject_cast<SetupTools::Xcp::Interface::Can::Interface *>(mIntfc);
    if(!canIntfc)
        return;

    boost::optional<Interface::Can::SlaveId> slaveId = Interface::Can::StrToSlaveId(val);
    if(slaveId)
        canIntfc->connect(slaveId.get());
}

int ConnectionFacade::timeout()
{
    return mConn->timeout();
}

void ConnectionFacade::setTimeout(int val)
{
    mConn->setTimeout(val);
}

int ConnectionFacade::nvWriteTimeout()
{
    return mConn->nvWriteTimeout();
}

void ConnectionFacade::setNvWriteTimeout(int val)
{
    mConn->setNvWriteTimeout(val);
}

int ConnectionFacade::bootDelay()
{
    return mConn->bootDelay();
}

void ConnectionFacade::setBootDelay(int val)
{
    mConn->setBootDelay(val);
}

double ConnectionFacade::opProgressNotifyFrac()
{
    return mConn->opProgressNotifyFrac();
}

void ConnectionFacade::setOpProgressNotifyFrac(double val)
{
    mConn->setOpProgressNotifyFrac(val);
}

int ConnectionFacade::progClearTimeout()
{
    return mConn->progClearTimeout();
}

void ConnectionFacade::setProgClearTimeout(int val)
{
    mConn->setProgClearTimeout(val);
}

bool ConnectionFacade::progResetIsAcked()
{
    return mConn->progResetIsAcked();
}

void ConnectionFacade::setProgResetIsAcked(bool val)
{
    mConn->setProgResetIsAcked(val);
}

Connection::State ConnectionFacade::state()
{
    return mConn->state();
}

void ConnectionFacade::setState(Connection::State val)
{
    emit connSetState(val);
}

double ConnectionFacade::opProgress()
{
    return mConn->opProgress();
}

void ConnectionFacade::forceSlaveSupportCalPage()
{
    mConn->forceSlaveSupportCalPage();
}

quint32 ConnectionFacade::computeCksum(CksumType type, const std::vector<quint8> &data)
{
    return mConn->computeCksum(type, data);
}

int ConnectionFacade::addrGran()
{
    return mConn->addrGran();
}

void ConnectionFacade::upload(XcpPtr base, int len)
{
    emit connUpload(base, len, NULL);
}

void ConnectionFacade::download(XcpPtr base, const std::vector<quint8> data)
{
    emit connDownload(base, data);
}

void ConnectionFacade::nvWrite()
{
    emit connNvWrite();
}

void ConnectionFacade::setCalPage(quint8 segment, quint8 page)
{
    emit connSetCalPage(segment, page);
}

void ConnectionFacade::programClear(XcpPtr base, int len)
{
    emit connProgramClear(base, len);
}

void ConnectionFacade::programRange(XcpPtr base, const std::vector<quint8> data, bool finalEmptyPacket)
{
    emit connProgramRange(base, data, finalEmptyPacket);
}

void ConnectionFacade::programVerify(XcpPtr mta, quint32 crc)
{
    emit connProgramVerify(mta, crc);
}

void ConnectionFacade::programReset()
{
    emit connProgramReset();
}

void ConnectionFacade::buildChecksum(XcpPtr base, int len)
{
    emit connBuildChecksum(base, len, NULL, NULL);
}

void ConnectionFacade::getAvailSlavesStr(QString bcastId, QString filter)
{
    emit connGetAvailSlavesStr(bcastId, filter, NULL);
}

void ConnectionFacade::onConnOpMsg(SetupTools::Xcp::OpResult result, QString info, SetupTools::Xcp::Connection::OpExtInfo ext)
{
    emit opMsg(result, info, ext);
}

void ConnectionFacade::onConnStateChanged()
{
    emit stateChanged();
}

void ConnectionFacade::onConnOpProgressChanged()
{
    emit opProgressChanged();
}

void ConnectionFacade::onConnSetStateDone(OpResult result)
{
    emit setStateDone(result);
}

void ConnectionFacade::onConnUploadDone(OpResult result, XcpPtr base, int len, std::vector<quint8> data)
{
    emit uploadDone(result, base, len, data);
}

void ConnectionFacade::onConnDownloadDone(OpResult result, XcpPtr base, std::vector<quint8> data)
{
    emit downloadDone(result, base, data);
}

void ConnectionFacade::onConnNvWriteDone(OpResult result)
{
    emit nvWriteDone(result);
}

void ConnectionFacade::onConnSetCalPageDone(OpResult result, quint8 segment, quint8 page)
{
    emit setCalPageDone(result, segment, page);
}

void ConnectionFacade::onConnProgramClearDone(OpResult result, XcpPtr base, int len)
{
    emit programClearDone(result, base, len);
}

void ConnectionFacade::onConnProgramRangeDone(OpResult result, XcpPtr base, std::vector<quint8> data, bool finalEmptyPacket)
{
    emit programRangeDone(result, base, data, finalEmptyPacket);
}

void ConnectionFacade::onConnProgramVerifyDone(OpResult result, XcpPtr mta, quint32 crc)
{
    emit programVerifyDone(result, mta, crc);
}

void ConnectionFacade::onConnProgramResetDone(OpResult result)
{
    emit programResetDone(result);
}

void ConnectionFacade::onConnBuildChecksumDone(OpResult result, XcpPtr base, int len, CksumType type, quint32 cksum)
{
    emit buildChecksumDone(result, base, len, type, cksum);
}

void ConnectionFacade::onConnGetAvailSlavesStrDone(OpResult result, QString bcastId, QString filter, QList<QString> slaveIds)
{
    emit getAvailSlavesStrDone(result, bcastId, filter, slaveIds);
}


SimpleDataLayer::SimpleDataLayer() : mConn(new ConnectionFacade(this))
{
    connect(mConn, &ConnectionFacade::uploadDone, this, &SimpleDataLayer::onConnUploadDone);
    connect(mConn, &ConnectionFacade::downloadDone, this, &SimpleDataLayer::onConnDownloadDone);
    mConn->setTimeout(100);
}

QUrl SimpleDataLayer::intfcUri()
{
    return mConn->intfcUri();
}

void SimpleDataLayer::setIntfcUri(QUrl val)
{
    mConn->setIntfcUri(val);
}

QString SimpleDataLayer::slaveId()
{
    return mConn->slaveId();
}

void SimpleDataLayer::setSlaveId(QString val)
{
    if(val.size() == 0)
    {
        mConn->setState(Connection::State::Closed);
    }
    else
    {
        mConn->setSlaveId(val);
        mConn->setState(Connection::State::CalMode);    // normally would have something more sophisticated, like open only when needed and close during cleanup
    }
}

void SimpleDataLayer::uploadUint32(quint32 base)
{
    mConn->setCalPage(0, 0);
    SetupTools::Xcp::XcpPtr ptr = {base, 0};
    mConn->upload(ptr, 4); // ignoring return values for this test case
}

void SimpleDataLayer::onConnUploadDone(OpResult result, XcpPtr base, int len, const std::vector<quint8> &dataVec)
{
    Q_UNUSED(base);
    Q_UNUSED(len);
    if(result != OpResult::Success)
        emit uploadUint32Done(static_cast<int>(result), 0);
    else if(dataVec.size() != 4)
        emit uploadUint32Done(static_cast<int>(OpResult::BadReply), 0);
    else
        emit uploadUint32Done(static_cast<int>(OpResult::Success), mConn->fromSlaveEndian<quint32>(dataVec.data()));
}

void SimpleDataLayer::downloadUint32(quint32 base, quint32 data)
{
    mConn->setCalPage(0, 0);
    SetupTools::Xcp::XcpPtr ptr = {base, 0};
    std::vector<quint8> dataVec;
    dataVec.assign(4, 0);
    mConn->toSlaveEndian<quint32>(data, dataVec.data());
    mConn->download(ptr, dataVec);
}

void SimpleDataLayer::onConnDownloadDone(OpResult result, XcpPtr base, const std::vector<quint8> &data)
{
    Q_UNUSED(base);
    Q_UNUSED(data);
    emit downloadUint32Done(static_cast<int>(result));
}

} // namespace Xcp
} // namespace SetupTools

