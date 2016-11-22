#include "Xcp_ProgramLayer.h"

namespace SetupTools {
namespace Xcp {

ProgramLayer::ProgramLayer(QObject *parent) :
    QObject(parent),
    mConn(new ConnectionFacade(this)),
    mState(State::IntfcNotOk),
    mMaxEraseSize(std::numeric_limits<decltype(mMaxEraseSize)>::max()),
    mActiveProg(NULL),
    mActiveAddrExt(0),
    mActiveCksumType(CksumType::Invalid),
    mActiveFinalEmptyPacket(false),
    mActiveBytesErased(0)
{
    onConnStateChanged();   // make absolutely sure states are consistent
    connect(mConn, &ConnectionFacade::setStateDone, this, &ProgramLayer::onConnSetStateDone);
    connect(mConn, &ConnectionFacade::programClearDone, this, &ProgramLayer::onConnProgramClearDone);
    connect(mConn, &ConnectionFacade::programRangeDone, this, &ProgramLayer::onConnProgramRangeDone);
    connect(mConn, &ConnectionFacade::programVerifyDone, this, &ProgramLayer::onConnProgramVerifyDone);
    connect(mConn, &ConnectionFacade::buildChecksumDone, this, &ProgramLayer::onConnBuildChecksumDone);
    connect(mConn, &ConnectionFacade::programResetDone, this, &ProgramLayer::onConnProgramResetDone);
    connect(mConn, &ConnectionFacade::stateChanged, this, &ProgramLayer::onConnStateChanged);
    connect(mConn, &ConnectionFacade::opProgressChanged, this, &ProgramLayer::onConnOpProgressChanged);
    connect(mConn, &ConnectionFacade::opMsg, this, &ProgramLayer::onConnOpMsg);
    connect(mConn, &ConnectionFacade::connectedTargetChanged, this, &ProgramLayer::slaveIdChanged);
    connect(mConn, &ConnectionFacade::setTargetDone, this, &ProgramLayer::setSlaveIdDone);
}

ProgramLayer::~ProgramLayer()
{}

QUrl ProgramLayer::intfcUri()
{
    return mConn->intfcUri();
}

void ProgramLayer::setIntfcUri(QUrl uri)
{
    mConn->setIntfcUri(uri);
    if(mConn->intfc())
    {
        if(QProcessEnvironment::systemEnvironment().value("XCP_PACKET_LOG", "0") == "1")
            mConn->intfc()->setPacketLog(true);
        else
            mConn->intfc()->setPacketLog(false);
    }
    emit intfcChanged();
}

Interface::Interface *ProgramLayer::intfc()
{
    return mConn->intfc();
}

void ProgramLayer::setIntfc(Interface::Interface *intfc, QUrl uri)
{
    mConn->setIntfc(intfc, uri);
    if(mConn->intfc())
    {
        if(QProcessEnvironment::systemEnvironment().value("XCP_PACKET_LOG", "0") == "1")
            mConn->intfc()->setPacketLog(true);
        else
            mConn->intfc()->setPacketLog(false);
    }
    emit intfcChanged();
}

QString ProgramLayer::slaveId()
{
    return mConn->connectedTarget();
}

void ProgramLayer::setSlaveId(QString id)
{
    mConn->setTarget(id);
}

bool ProgramLayer::idle()
{
    return (mState == State::Idle || mState == State::IntfcNotOk);
}

bool ProgramLayer::intfcOk()
{
    return (mState != State::IntfcNotOk);
}

int ProgramLayer::slaveTimeout()
{
    return mConn->timeout();
}

void ProgramLayer::setSlaveTimeout(int timeout)
{
    mConn->setTimeout(timeout);
}

int ProgramLayer::slaveBootDelay()
{
    return mConn->bootDelay();
}

void ProgramLayer::setSlaveBootDelay(int timeout)
{
    mConn->setBootDelay(timeout);
}

int ProgramLayer::slaveProgClearTimeout()
{
    return mConn->progClearTimeout();
}

void ProgramLayer::setSlaveProgClearTimeout(int val)
{
    mConn->setProgClearTimeout(val);
}

bool ProgramLayer::slaveProgResetIsAcked()
{
    return mConn->progResetIsAcked();
}

void ProgramLayer::setSlaveProgResetIsAcked(bool val)
{
    mConn->setProgResetIsAcked(val);
}

double ProgramLayer::opProgressNotifyFrac()
{
    return mConn->opProgressNotifyFrac();
}

void ProgramLayer::setOpProgressNotifyFrac(double val)
{
    mConn->setOpProgressNotifyFrac(val);
}

int ProgramLayer::maxEraseSize()
{
    return int(mMaxEraseSize);
}

void ProgramLayer::setMaxEraseSize(int val)
{
    if(val > 0)
        mMaxEraseSize = quint32(val);
}

double ProgramLayer::opProgress()
{
    return mConn->opProgress();
}

ConnectionFacade *ProgramLayer::conn()
{
    return mConn;
}

void ProgramLayer::program(FlashProg *prog, quint8 addrExt, bool finalEmptyPacket)
{
    if(mState != State::Idle)
    {
        emit programDone(OpResult::InvalidOperation, prog, addrExt);
        return;
    }

    if(prog->blocks().size() == 0)
    {
        emit programDone(OpResult::Success, prog, addrExt);
        return;
    }

    mActiveProg = prog;
    mActiveAddrExt = addrExt;
    mActiveFinalEmptyPacket = finalEmptyPacket;
    mState = State::Program;
    emit stateChanged();

    mConn->setState(Connection::State::PgmMode);
}

void ProgramLayer::programVerify(FlashProg *prog, CksumType type, quint8 addrExt)
{
    if(mState != State::Idle)
    {
        emit programVerifyDone(OpResult::InvalidOperation, prog, type, addrExt);
        return;
    }

    if(prog->blocks().size() == 0)
    {
        emit programVerifyDone(OpResult::Success, prog, type, addrExt);
        return;
    }

    if(prog->blocks().size() > 1)   // result is undefined for multiple blocks - what is in the intervening space?
    {
        emit programVerifyDone(OpResult::InvalidArgument, prog, type, addrExt);
        return;
    }

    mActiveProg = prog;
    mActiveAddrExt = addrExt;
    mActiveCksumType = type;
    mState = State::ProgramVerify;
    emit stateChanged();

    mConn->setState(Connection::State::PgmMode);
}

void ProgramLayer::buildChecksumVerify(FlashProg *prog, quint8 addrExt)
{
    if(mState != State::Idle)
    {
        emit buildChecksumVerifyDone(OpResult::InvalidOperation, prog, addrExt);
        return;
    }

    if(prog->blocks().size() == 0)
    {
        emit buildChecksumVerifyDone(OpResult::Success, prog, addrExt);
        return;
    }

    mActiveProg = prog;
    mActiveAddrExt = addrExt;
    mState = State::BuildChecksumVerify;
    emit stateChanged();

    mConn->setState(Connection::State::PgmMode);
}

void ProgramLayer::programReset()
{
    if(mState != State::Idle)
    {
        emit programResetDone(OpResult::InvalidOperation);
        return;
    }

    mState = State::ProgramReset;

    if(mConn->state() == Connection::State::Closed)
        mConn->setState(Connection::State::CalMode);    // just connect, don't need to start a programming sequence
    else
        mConn->programReset();  // proceed directly to reset
}

void ProgramLayer::calMode()
{
    if(mState != State::Idle)
    {
        emit calModeDone(OpResult::InvalidOperation);
        return;
    }

    mState = State::CalMode;

    if(mConn->state() == Connection::State::Closed)
        mConn->setState(Connection::State::CalMode);    // just connect, don't need to start a programming sequence
    else
        mConn->programReset();  // proceed directly to reset
}

void ProgramLayer::pgmMode()
{
    if(mState != State::Idle)
    {
        emit pgmModeDone(OpResult::InvalidOperation);
        return;
    }

    if(mConn->state() == Connection::State::PgmMode)
    {
        emit pgmModeDone(OpResult::Success);
        return;
    }

    mState = State::PgmMode;

    mConn->setState(Connection::State::PgmMode);
}

void ProgramLayer::disconnect()
{
    if(mState != State::Idle)
    {
        emit disconnectDone(OpResult::InvalidOperation);
        return;
    }

    if(mConn->state() == Connection::State::Closed)
    {
        emit disconnectDone(OpResult::Success);
        return;
    }

    mState = State::Disconnect;

    mConn->setState(Connection::State::Closed);
}

void ProgramLayer::onConnSetStateDone(OpResult result)
{
    switch(mState)
    {
    case State::IntfcNotOk:
        Q_ASSERT(mState != State::IntfcNotOk);
        break;
    case State::Idle:
        Q_ASSERT(mState != State::Idle);
        break;
    case State::Program:
        if(result != OpResult::Success)
        {
            mState = State::Idle;
            emit stateChanged();
            emit programDone(result, mActiveProg, mActiveAddrExt);
            return;
        }
        if(mConn->state() != Connection::State::PgmMode)
        {
            mState = State::Idle;
            emit stateChanged();
            emit programDone(SetupTools::OpResult::BadReply, mActiveProg, mActiveAddrExt);
        }
        mActiveProgBlock = mActiveProg->blocks().begin();
        mActiveBytesErased = 0;
        doProgramClear();
        break;
    case State::ProgramVerify:
        if(result != OpResult::Success)
        {
            mState = State::Idle;
            emit stateChanged();
            emit programVerifyDone(result, mActiveProg, mActiveCksumType, mActiveAddrExt);
            return;
        }
        if(mConn->state() != Connection::State::PgmMode)
        {
            mState = State::Idle;
            emit stateChanged();
            emit programDone(SetupTools::OpResult::BadReply, mActiveProg, mActiveAddrExt);
        }
        {
            Q_ASSERT(mActiveProg->blocks().size() == 1);
            FlashBlock *progBlock = mActiveProg->blocks().front();
            Q_ASSERT(quint32(progBlock->base + progBlock->data.size()) == progBlock->base + progBlock->data.size());
            XcpPtr progEnd = {quint32(progBlock->base + progBlock->data.size()), mActiveAddrExt};
            quint32 masterCksum = mConn->computeCksum(mActiveCksumType, progBlock->data);
            mConn->programVerify(progEnd, masterCksum);
        }
        break;
    case State::BuildChecksumVerify:
        if(result != OpResult::Success)
        {
            mState = State::Idle;
            emit stateChanged();
            emit buildChecksumVerifyDone(result, mActiveProg, mActiveAddrExt);
            return;
        }
        if(mConn->state() != Connection::State::PgmMode)
        {
            mState = State::Idle;
            emit stateChanged();
            emit programDone(SetupTools::OpResult::BadReply, mActiveProg, mActiveAddrExt);
        }
        mActiveProgBlock = mActiveProg->blocks().begin();
        mConn->buildChecksum({(*mActiveProgBlock)->base, mActiveAddrExt}, (*mActiveProgBlock)->data.size());
        break;
    case State::ProgramReset:
        if(result != OpResult::Success)
        {
            mState = State::Idle;
            emit stateChanged();
            emit programResetDone(result);
            return;
        }
        if(mConn->state() != Connection::State::PgmMode
                && mConn->state() != Connection::State::CalMode)
        {
            mState = State::Idle;
            emit stateChanged();
            emit programDone(SetupTools::OpResult::BadReply, mActiveProg, mActiveAddrExt);
        }
        mConn->programReset();
        break;
    case State::CalMode:
        mState = State::Idle;
        emit stateChanged();
        emit calModeDone(result);
        break;
    case State::PgmMode:
        mState = State::Idle;
        emit stateChanged();
        emit pgmModeDone(result);
        break;
    case State::Disconnect:
        mState = State::Idle;
        emit stateChanged();
        emit disconnectDone(result);
        break;
    }
}

void ProgramLayer::onConnProgramClearDone(OpResult result, XcpPtr base, int len)
{
    Q_UNUSED(base);
    Q_UNUSED(len);
    Q_ASSERT(mState == State::Program);
    if(result != OpResult::Success)
    {
        mState = State::Idle;
        emit stateChanged();
        emit programDone(result, mActiveProg, mActiveAddrExt);
        return;
    }
    if(mActiveBytesErased < (*mActiveProgBlock)->data.size())
        doProgramClear();
    else
        mConn->programRange({(*mActiveProgBlock)->base, mActiveAddrExt}, (*mActiveProgBlock)->data, mActiveFinalEmptyPacket);
}

void ProgramLayer::onConnProgramRangeDone(OpResult result, XcpPtr base, std::vector<quint8> data, bool finalEmptyPacket)
{
    Q_UNUSED(base);
    Q_UNUSED(data);
    Q_UNUSED(finalEmptyPacket);
    Q_ASSERT(mState == State::Program);
    if(result != OpResult::Success)
    {
        mState = State::Idle;
        emit stateChanged();
        emit programDone(result, mActiveProg, mActiveAddrExt);
        return;
    }

    ++mActiveProgBlock;
    mActiveBytesErased = 0;

    if(mActiveProgBlock != mActiveProg->blocks().end())
    {
        doProgramClear();
    }
    else
    {
        mState = State::Idle;
        emit stateChanged();
        emit programDone(OpResult::Success, mActiveProg, mActiveAddrExt);
    }
}

void ProgramLayer::onConnProgramVerifyDone(OpResult result, XcpPtr mta, quint32 crc)
{
    Q_UNUSED(mta);
    Q_UNUSED(crc);
    Q_ASSERT(mState == State::ProgramVerify);
    mState = State::Idle;
    emit stateChanged();
    emit programVerifyDone(result, mActiveProg, mActiveCksumType, mActiveAddrExt);
}

void ProgramLayer::onConnBuildChecksumDone(OpResult result, XcpPtr base, int len, CksumType type, quint32 cksum)
{
    Q_UNUSED(base);
    Q_UNUSED(len);
    Q_ASSERT(mState == State::BuildChecksumVerify);
    if(result != OpResult::Success)
    {
        mState = State::Idle;
        emit stateChanged();
        emit buildChecksumVerifyDone(result, mActiveProg, mActiveAddrExt, type, cksum);
        return;
    }

    // Device returned a checksum, compare it with the program
    quint32 masterCksum = mConn->computeCksum(type, (*mActiveProgBlock)->data);
    if(masterCksum != cksum)
    {
        mState = State::Idle;
        emit stateChanged();
        emit buildChecksumVerifyDone(OpResult::BadCksum, mActiveProg, mActiveAddrExt, type, cksum);
        return;
    }

    ++mActiveProgBlock;

    if(mActiveProgBlock != mActiveProg->blocks().end())
    {
        mConn->buildChecksum({(*mActiveProgBlock)->base, mActiveAddrExt}, (*mActiveProgBlock)->data.size());
    }
    else
    {
        mState = State::Idle;
        emit stateChanged();
        emit buildChecksumVerifyDone(OpResult::Success, mActiveProg, mActiveAddrExt, type, cksum);
    }
}

void ProgramLayer::onConnProgramResetDone(OpResult result)
{
    if(mState == State::ProgramReset)
    {
        mState = State::Idle;
        emit stateChanged();
        emit programResetDone(result);
    }
    else if(mState == State::CalMode)
    {
        mConn->setState(Connection::State::CalMode);
    }
    else
        Q_ASSERT(mState != mState);
}

void ProgramLayer::onConnStateChanged()
{
    Connection::State newState = mConn->state();
    if(newState == Connection::State::IntfcInvalid)
        mState = State::IntfcNotOk;
    else if(mState == State::IntfcNotOk && newState == Connection::State::Closed)
        mState = State::Idle;
    emit stateChanged();
}

void ProgramLayer::onConnOpProgressChanged()
{
    emit opProgressChanged();
}

void ProgramLayer::onConnOpMsg(OpResult result, QString info, Connection::OpExtInfo ext)
{
    emit opMsg(result, info, ext);
}

void ProgramLayer::doProgramClear()
{
    quint32 bytesRemaining = (*mActiveProgBlock)->data.size() - mActiveBytesErased;
    quint32 bytesToErase = std::min(bytesRemaining, quint32(mMaxEraseSize));
    quint32 eraseBase = (*mActiveProgBlock)->base + mActiveBytesErased;
    mActiveBytesErased += bytesToErase;
    mConn->programClear({eraseBase, mActiveAddrExt}, bytesToErase);
}

} // namespace Xcp
} // namespace SetupTools

