#include "Xcp_ConnectionFacade.h"
#include "Xcp_Interface_Registry.h"
#include "Xcp_Interface_Can_Interface.h"

namespace SetupTools {
namespace Xcp {

ConnectionFacade::ConnectionFacade(QObject *parent) :
    QObject(parent),
    mIntfc(NULL),
    mConn(new Connection(NULL)),
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
    connect(mConn, &Connection::stateChanged, this, &ConnectionFacade::onConnStateChanged, Qt::QueuedConnection);
}

ConnectionFacade::~ConnectionFacade()
{
    mConnThread->quit();
    mConnThread->wait();
}

QString ConnectionFacade::intfcUri()
{
    return mIntfcUri;
}

void ConnectionFacade::setIntfcUri(QString val)
{
    if(mIntfcUri != val)
    {
        delete mIntfc;
        mIntfcUri = val;
        mIntfc = Interface::Registry().make(mIntfcUri);
        mConn->setIntfc(mIntfc);
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

    return QString("%1:%2").
            arg(id.get().cmd.addr, (id.get().cmd.type == Interface::Can::Id::Type::Ext) ? 8 : 3, 16, QChar('0')).
            arg(id.get().res.addr, (id.get().res.type == Interface::Can::Id::Type::Ext) ? 8 : 3, 16, QChar('0'));
}

void ConnectionFacade::setSlaveId(QString val)
{
    SetupTools::Xcp::Interface::Can::Interface *canIntfc = qobject_cast<SetupTools::Xcp::Interface::Can::Interface *>(mIntfc);
    if(!canIntfc)
        return;

    QStringList parts = val.split(":");
    if(parts.size() != 2)
        return;

    Interface::Can::SlaveId id;
    bool ok;

    id.cmd.addr = parts[0].toUInt(&ok, 16);
    if(!ok) return;
    id.cmd.type = (parts[0].size() > 3) ? Interface::Can::Id::Type::Ext : Interface::Can::Id::Type::Std;

    id.res.addr = parts[1].toUInt(&ok, 16);
    if(!ok) return;
    id.res.type = (parts[1].size() > 3) ? Interface::Can::Id::Type::Ext : Interface::Can::Id::Type::Std;

    canIntfc->connect(id);
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

int ConnectionFacade::resetTimeout()
{
    return mConn->resetTimeout();
}

void ConnectionFacade::setResetTimeout(int val)
{
    mConn->setResetTimeout(val);
}

Connection::State ConnectionFacade::state()
{
    return mConn->state();
}

void ConnectionFacade::setState(Connection::State val)
{
    emit connSetState(val);
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

void ConnectionFacade::programRange(XcpPtr base, const std::vector<quint8> data)
{
    emit connProgramRange(base, data);
}

void ConnectionFacade::programVerify(quint32 crc)
{
    emit connProgramVerify(crc);
}

void ConnectionFacade::programReset()
{
    emit connProgramReset();
}

void ConnectionFacade::buildChecksum(XcpPtr base, int len)
{
    emit connBuildChecksum(base, len, NULL, NULL);
}

void ConnectionFacade::onConnStateChanged()
{
    emit stateChanged();
}

void ConnectionFacade::onConnSetStateDone(OpResult result)
{
    emit setStateDone(result);
}

void ConnectionFacade::onConnUploadDone(OpResult result, std::vector<quint8> data)
{
    emit uploadDone(result, data);
}

void ConnectionFacade::onConnDownloadDone(OpResult result)
{
    emit downloadDone(result);
}

void ConnectionFacade::onConnNvWriteDone(OpResult result)
{
    emit nvWriteDone(result);
}

void ConnectionFacade::onConnSetCalPageDone(OpResult result)
{
    emit setCalPageDone(result);
}

void ConnectionFacade::onConnProgramClearDone(OpResult result)
{
    emit programClearDone(result);
}

void ConnectionFacade::onConnProgramRangeDone(OpResult result)
{
    emit programRangeDone(result);
}

void ConnectionFacade::onConnProgramVerifyDone(OpResult result)
{
    emit programVerifyDone(result);
}

void ConnectionFacade::onConnProgramResetDone(OpResult result)
{
    emit programResetDone(result);
}

void ConnectionFacade::onConnBuildChecksumDone(OpResult result, CksumType type, quint32 cksum)
{
    emit buildChecksumDone(result, type, cksum);
}


SimpleDataLayer::SimpleDataLayer() : mConn(new ConnectionFacade(this))
{
    connect(mConn, &ConnectionFacade::uploadDone, this, &SimpleDataLayer::onConnUploadDone);
    connect(mConn, &ConnectionFacade::downloadDone, this, &SimpleDataLayer::onConnDownloadDone);
}

QString SimpleDataLayer::intfcUri(void)
{
    return mConn->intfcUri();
}

void SimpleDataLayer::setIntfcUri(QString val)
{
    mConn->setIntfcUri(val);
}

QString SimpleDataLayer::slaveId(void)
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
    SetupTools::Xcp::XcpPtr ptr = {base, 0};
    mConn->upload(ptr, 4); // ignoring return values for this test case
}

void SimpleDataLayer::onConnUploadDone(OpResult result, std::vector<quint8> dataVec)
{
    if(result != OpResult::Success)
        emit uploadUint32Done(static_cast<int>(result), 0);
    else if(dataVec.size() != 4)
        emit uploadUint32Done(static_cast<int>(OpResult::BadReply), 0);
    else
        emit uploadUint32Done(static_cast<int>(OpResult::Success), mConn->fromSlaveEndian<quint32>(dataVec.data()));
}

void SimpleDataLayer::downloadUint32(quint32 base, quint32 data)
{
    SetupTools::Xcp::XcpPtr ptr = {base, 0};
    std::vector<quint8> dataVec;
    dataVec.assign(4, 0);
    mConn->toSlaveEndian<quint32>(data, dataVec.data());
    mConn->download(ptr, dataVec);
}

void SimpleDataLayer::onConnDownloadDone(OpResult result)
{
    emit downloadUint32Done(static_cast<int>(result));
}

} // namespace Xcp
} // namespace SetupTools

