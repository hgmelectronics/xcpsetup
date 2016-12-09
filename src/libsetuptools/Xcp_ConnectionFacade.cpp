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

    connect(this, &ConnectionFacade::connSetTarget, mConn, &Connection::setTarget, Qt::QueuedConnection);
    connect(this, &ConnectionFacade::connSetState, mConn, &Connection::setState, Qt::QueuedConnection);
    connect(this, &ConnectionFacade::connUpload, mConn, &Connection::upload, Qt::QueuedConnection);
    connect(this, &ConnectionFacade::connDownload, mConn, &Connection::download, Qt::QueuedConnection);
    connect(this, &ConnectionFacade::connNvWrite, mConn, &Connection::nvWrite, Qt::QueuedConnection);
    connect(this, &ConnectionFacade::connSetCalPage, mConn, &Connection::setCalPage, Qt::QueuedConnection);
    connect(this, &ConnectionFacade::connCopyCalPage, mConn, &Connection::copyCalPage, Qt::QueuedConnection);
    connect(this, &ConnectionFacade::connProgramClear, mConn, &Connection::programClear, Qt::QueuedConnection);
    connect(this, &ConnectionFacade::connProgramRange, mConn, &Connection::programRange, Qt::QueuedConnection);
    connect(this, &ConnectionFacade::connProgramVerify, mConn, &Connection::programVerify, Qt::QueuedConnection);
    connect(this, &ConnectionFacade::connProgramReset, mConn, &Connection::programReset, Qt::QueuedConnection);
    connect(this, &ConnectionFacade::connBuildChecksum, mConn, &Connection::buildChecksum, Qt::QueuedConnection);
    connect(this, &ConnectionFacade::connGetAvailSlavesStr, mConn, &Connection::getAvailSlavesStr, Qt::QueuedConnection);

    connect(mConn, &Connection::setTargetDone, this, &ConnectionFacade::setTargetDone, Qt::QueuedConnection);
    connect(mConn, &Connection::setStateDone, this, &ConnectionFacade::setStateDone, Qt::QueuedConnection);
    connect(mConn, &Connection::uploadDone, this, &ConnectionFacade::uploadDone, Qt::QueuedConnection);
    connect(mConn, &Connection::downloadDone, this, &ConnectionFacade::downloadDone, Qt::QueuedConnection);
    connect(mConn, &Connection::nvWriteDone, this, &ConnectionFacade::nvWriteDone, Qt::QueuedConnection);
    connect(mConn, &Connection::setCalPageDone, this, &ConnectionFacade::setCalPageDone, Qt::QueuedConnection);
    connect(mConn, &Connection::copyCalPageDone, this, &ConnectionFacade::copyCalPageDone, Qt::QueuedConnection);
    connect(mConn, &Connection::programClearDone, this, &ConnectionFacade::programClearDone, Qt::QueuedConnection);
    connect(mConn, &Connection::programRangeDone, this, &ConnectionFacade::programRangeDone, Qt::QueuedConnection);
    connect(mConn, &Connection::programVerifyDone, this, &ConnectionFacade::programVerifyDone, Qt::QueuedConnection);
    connect(mConn, &Connection::programResetDone, this, &ConnectionFacade::programResetDone, Qt::QueuedConnection);
    connect(mConn, &Connection::buildChecksumDone, this, &ConnectionFacade::buildChecksumDone, Qt::QueuedConnection);
    connect(mConn, &Connection::getAvailSlavesStrDone, this, &ConnectionFacade::getAvailSlavesStrDone, Qt::QueuedConnection);
    connect(mConn, &Connection::opMsg, this, &ConnectionFacade::opMsg, Qt::QueuedConnection);
    connect(mConn, &Connection::stateChanged, this, &ConnectionFacade::stateChanged, Qt::QueuedConnection);
    connect(mConn, &Connection::opProgressChanged, this, &ConnectionFacade::opProgressChanged, Qt::QueuedConnection);
    connect(mConn, &Connection::connectedTargetChanged, this, &ConnectionFacade::onConnConnectedTargetChanged, Qt::QueuedConnection);
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
        Interface::Interface *intfcToDelete = nullptr; // must delete after calling mConn->setIntfc(), which needs the old interface to exist
        if(mIntfc && mIntfcOwned)
            intfcToDelete = mIntfc;
        mIntfcUri = val;
        mIntfc = Interface::Registry().make(mIntfcUri);
        mIntfcOwned = true;
        mConn->setIntfc(mIntfc);
        if(intfcToDelete)
            delete intfcToDelete;
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

void ConnectionFacade::setTarget(QString val)
{
    emit connSetTarget(val);
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

void ConnectionFacade::copyCalPage(quint8 fromSegment, quint8 fromPage, quint8 toSegment, quint8 toPage)
{
    emit connCopyCalPage(fromSegment, fromPage, toSegment, toPage);
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

void ConnectionFacade::onConnConnectedTargetChanged(QString val)
{
    qDebug() << "ConnectionFacade::onConnConnectedTargetChanged";
    mConnectedTarget = val;
    emit connectedTargetChanged(val);
}


} // namespace Xcp
} // namespace SetupTools

