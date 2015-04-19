#include "Xcp_ProgramLayer.h"

namespace SetupTools {
namespace Xcp {

ProgramLayer::ProgramLayer(QObject *parent) :
    QObject(parent),
    mConn(new ConnectionFacade(this)),
    mState(State::Idle),
    mActiveProg(NULL),
    mActiveAddrExt(0),
    mActiveCksumType(CksumType::Invalid)
{
    connect(mConn, &ConnectionFacade::setStateDone, this, &ProgramLayer::onConnSetStateDone);
    connect(mConn, &ConnectionFacade::programClearDone, this, &ProgramLayer::onConnProgramClearDone);
    connect(mConn, &ConnectionFacade::programRangeDone, this, &ProgramLayer::onConnProgramRangeDone);
    connect(mConn, &ConnectionFacade::programVerifyDone, this, &ProgramLayer::onConnProgramVerifyDone);
    connect(mConn, &ConnectionFacade::buildChecksumDone, this, &ProgramLayer::onConnBuildChecksumDone);
    connect(mConn, &ConnectionFacade::programResetDone, this, &ProgramLayer::onConnProgramResetDone);
}

ProgramLayer::~ProgramLayer()
{}

QString ProgramLayer::intfcUri(void)
{
    return mConn->intfcUri();
}

void ProgramLayer::setIntfcUri(QString uri)
{
    mConn->setIntfcUri(uri);
}

QString ProgramLayer::slaveId()
{
    return mConn->slaveId();
}

void ProgramLayer::setSlaveId(QString id)
{
    mConn->setSlaveId(id);
}

ConnectionFacade *ProgramLayer::conn()
{
    return mConn;
}

void ProgramLayer::program(FlashProg *prog, quint8 addrExt)
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
    mState = State::Program;

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

    mConn->setState(Connection::State::PgmMode);
}

void ProgramLayer::onConnSetStateDone(OpResult result)
{
    if(result == OpResult::Success)
        Q_ASSERT(mConn->state() == Connection::State::PgmMode);
    switch(mState)
    {
    case State::Idle:
        Q_ASSERT(mState != State::Idle);
        break;
    case State::Program:
        if(result != OpResult::Success)
        {
            mState = State::Idle;
            emit programDone(result, mActiveProg, mActiveAddrExt);
            return;
        }
        mActiveProgBlock = mActiveProg->blocks().begin();
        mConn->programClear({(*mActiveProgBlock)->base, mActiveAddrExt}, (*mActiveProgBlock)->data.size());
        break;
    case State::ProgramVerify:
        if(result != OpResult::Success)
        {
            mState = State::Idle;
            emit programVerifyDone(result, mActiveProg, mActiveCksumType, mActiveAddrExt);
            return;
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
            emit buildChecksumVerifyDone(result, mActiveProg, mActiveAddrExt);
            return;
        }
        mActiveProgBlock = mActiveProg->blocks().begin();
        mConn->buildChecksum({(*mActiveProgBlock)->base, mActiveAddrExt}, (*mActiveProgBlock)->data.size());
        break;
    case State::ProgramReset:
        if(result != OpResult::Success)
        {
            mState = State::Idle;
            emit programResetDone(result);
            return;
        }
        mConn->programReset();
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
        emit programDone(result, mActiveProg, mActiveAddrExt);
        return;
    }
    mConn->programRange({(*mActiveProgBlock)->base, mActiveAddrExt}, (*mActiveProgBlock)->data);
}

void ProgramLayer::onConnProgramRangeDone(OpResult result, XcpPtr base, std::vector<quint8> data)
{
    Q_UNUSED(base);
    Q_UNUSED(data);
    Q_ASSERT(mState == State::Program);
    if(result != OpResult::Success)
    {
        mState = State::Idle;
        emit programDone(result, mActiveProg, mActiveAddrExt);
        return;
    }

    ++mActiveProgBlock;

    if(mActiveProgBlock != mActiveProg->blocks().end())
    {
        mConn->programClear({(*mActiveProgBlock)->base, mActiveAddrExt}, (*mActiveProgBlock)->data.size());
    }
    else
    {
        mState = State::Idle;
        emit programDone(OpResult::Success, mActiveProg, mActiveAddrExt);
    }
}

void ProgramLayer::onConnProgramVerifyDone(OpResult result, XcpPtr mta, quint32 crc)
{
    Q_UNUSED(mta);
    Q_UNUSED(crc);
    Q_ASSERT(mState == State::ProgramVerify);
    mState = State::Idle;
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
        emit buildChecksumVerifyDone(result, mActiveProg, mActiveAddrExt, type, cksum);
        return;
    }

    // Device returned a checksum, compare it with the program
    quint32 masterCksum = mConn->computeCksum(type, (*mActiveProgBlock)->data);
    if(masterCksum != cksum)
    {
        mState = State::Idle;
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
        emit buildChecksumVerifyDone(OpResult::Success, mActiveProg, mActiveAddrExt, type, cksum);
    }
}

void ProgramLayer::onConnProgramResetDone(OpResult result)
{
    Q_ASSERT(mState == State::ProgramReset);
    mState = State::Idle;
    emit programResetDone(result);
}

} // namespace Xcp
} // namespace SetupTools

