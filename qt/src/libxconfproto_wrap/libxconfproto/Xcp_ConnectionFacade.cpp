#include "Xcp_ConnectionFacade.h"
#include "Xcp_Interface_Registry.h"

namespace SetupTools {
namespace Xcp {

ConnectionFacade::ConnectionFacade(QObject *parent) :
    QObject(parent),
    mConn(new Connection(this)),
    mConnThread(new QThread(this))
{
    mConn->moveToThread(mConnThread);
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
    mIntfcUri = val;
    mConn->setIntfc(Interface::Registry().make(mIntfcUri));
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


} // namespace Xcp
} // namespace SetupTools

