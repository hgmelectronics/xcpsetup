#include "Cs2Tool.h"

namespace SetupTools
{

Cs2Tool::Cs2Tool(QObject *parent) :
    QObject(parent),
    mProgLayer(new Xcp::ProgramLayer(this)),
    mProgFileOkToFlash(false),
    mState(State::IntfcNotOk),
    mSlaveCmdId("18FCD403"),
    mSlaveResId("18FCD4F9")
{
    connect(mProgLayer, &Xcp::ProgramLayer::calModeDone, this, &Cs2Tool::onProgCalModeDone);
    connect(mProgLayer, &Xcp::ProgramLayer::stateChanged, this, &Cs2Tool::onProgLayerStateChanged);
    connect(mProgLayer, &Xcp::ProgramLayer::programDone, this, &Cs2Tool::onProgramDone);
    connect(mProgLayer, &Xcp::ProgramLayer::programVerifyDone, this, &Cs2Tool::onProgramVerifyDone);
    connect(mProgLayer, &Xcp::ProgramLayer::programResetDone, this, &Cs2Tool::onProgramResetDone);
    connect(mProgLayer, &Xcp::ProgramLayer::opProgressChanged, this, &Cs2Tool::onProgLayerProgressChanged);
    connect(mProgLayer, &Xcp::ProgramLayer::opMsg, this, &Cs2Tool::onProgLayerOpMsg);
    mProgLayer->setSlaveTimeout(TIMEOUT_MSEC);
    mProgLayer->setSlaveBootDelay(BOOT_DELAY_MSEC);
    mProgLayer->setSlaveProgResetIsAcked(false);
}


Cs2Tool::~Cs2Tool() {}

FlashProg *Cs2Tool::programData()
{
    return mProgData;
}

void Cs2Tool::setProgramData(FlashProg *prog)
{
    mProgData = prog;

    mProgFileOkToFlash = false;

    if(!mProgData)
    {
        emit programChanged();
        return;
    }

    mInfilledProgData = *mProgData;

    mInfilledProgData.infillToSingleBlock();

    if(mInfilledProgData.base() < SMALLBLOCK_BASE
            || mInfilledProgData.base() < APPLIC_BASE
            || (mInfilledProgData.base() + mInfilledProgData.size()) > LARGEBLOCK_TOP)
    {
        emit programChanged();
        return;
    }

    int nSmallBlocks = nBlocksInRange(mInfilledProgData.base(), mInfilledProgData.size(), SMALLBLOCK_BASE, SMALLBLOCK_TOP, SMALLBLOCK_SIZE);
    int nBlocks = nSmallBlocks + nBlocksInRange(mInfilledProgData.base(), mInfilledProgData.size(), SMALLBLOCK_BASE, SMALLBLOCK_TOP, SMALLBLOCK_SIZE);

    int minBlockSize = nSmallBlocks ? SMALLBLOCK_SIZE : LARGEBLOCK_SIZE;
    int maxClearBlocks = (mProgLayer->intfc()->maxReplyTimeout() - PROG_CLEAR_BASE_TIMEOUT_MSEC) / PROG_CLEAR_TIMEOUT_PER_BLOCK_MSEC;
    if(maxClearBlocks == 0)
        maxClearBlocks = 1; // If we technically cannot do even one, fudge it and hope
    mProgLayer->setMaxEraseSize(minBlockSize * maxClearBlocks);
    mProgLayer->setSlaveProgClearTimeout(PROG_CLEAR_BASE_TIMEOUT_MSEC + PROG_CLEAR_TIMEOUT_PER_BLOCK_MSEC * std::min(maxClearBlocks, nBlocks));

    mProgFileOkToFlash = true;
    emit programChanged();
}

int Cs2Tool::programSize()
{
    if(!mProgData)
        return 0;

    int size = 0;
    for(FlashBlock *block : mProgData->blocks())
        size += block->data.size();
    return size;
}

qlonglong Cs2Tool::programBase()
{
    if(!mProgData || mProgData->blocks().size() == 0)
        return -1;

    return mProgData->blocks()[0]->base;
}

qlonglong Cs2Tool::programCksum()
{
    if(mInfilledProgData.blocks().size() != 1)
        return -1;
    boost::optional<quint32> cksum = Xcp::computeCksumStatic(CKSUM_TYPE, mInfilledProgData.blocks().first()->data);
    if(!cksum)
        return -1;
    return cksum.get();
}

bool Cs2Tool::programOk()
{
    return mProgData && mProgFileOkToFlash;
}

double Cs2Tool::progress()
{
    if(mState == State::Idle
            || mState == State::IntfcNotOk)
    {
        return 0;
    }
    else if(mState >= State::Program_InitialConnect
            && mState <= State::Program_CalMode)
    {
        // calculate progress for a program sequence
        // stateProgress = 1/5 for first state, 5/5 for last state (so user gets to see progress reach 100%)
        double stateProgress = double(static_cast<int>(mState) - static_cast<int>(State::Program_InitialConnect) + 1)
                / (N_PROGRAM_STATES - 1);

        return stateProgress * PROGRAM_STATE_PROGRESS_CREDIT + programProgress() * PROGRAM_PROGRESS_MULT;
    }
    else if(mState == State::Reset_Reset)
    {
        return 1;
    }
    else    // catch unhandled states
    {
        return 0;
    }
}

double Cs2Tool::programProgress()
{
    if(mState < State::Program_Program)
        return 0;
    else if(mState == State::Program_Program)
        return mProgLayer->opProgress();
    else if(mState <= State::Program_CalMode)
        return 1;
    else
        return 0;
}

QUrl Cs2Tool::intfcUri()
{
    return mProgLayer->intfcUri();
}

void Cs2Tool::setIntfcUri(QUrl uri)
{
    if(mState != State::IntfcNotOk && mState != State::Idle)
    {
        emit intfcUriChanged(); // let the caller know we refused the change
        return;
    }

    mProgLayer->setIntfcUri(uri);
    if(mProgLayer->intfc())
    {
        if(QProcessEnvironment::systemEnvironment().value("XCP_PACKET_LOG", "0") == "1")
            mProgLayer->intfc()->setPacketLog(true);
        else
            mProgLayer->intfc()->setPacketLog(false);
    }
    emit intfcUriChanged();
}

QString Cs2Tool::slaveCmdId()
{
    return mSlaveCmdId;
}

void Cs2Tool::setSlaveCmdId(QString id)
{
    mSlaveCmdId = id;
    emit slaveIdChanged();
}

QString Cs2Tool::slaveResId()
{
    return mSlaveResId;
}

void Cs2Tool::setSlaveResId(QString id)
{
    mSlaveResId = id;
    emit slaveIdChanged();
}

bool Cs2Tool::intfcOk()
{
    return mProgLayer->intfcOk();
}

bool Cs2Tool::idle()
{
    return mProgLayer->idle();
}

bool Cs2Tool::progReady()
{
    return (mState == State::Idle || (mState >= State::Program_InitialConnect && mState <= State::Program_CalMode));
}
void Cs2Tool::startProgramming()
{
    if(!mProgData
            || !mProgFileOkToFlash
            || mState != State::Idle)
    {
        emit programmingDone(static_cast<int>(SetupTools::Xcp::OpResult::InvalidOperation));
        return;
    }

    setState(State::Program_InitialConnect);
    
    mProgLayer->setSlaveId(mSlaveCmdId + ":" + mSlaveResId);
    mProgLayer->calMode();
}

void Cs2Tool::startReset()
{
    if(mState != State::Idle)
    {
        emit resetDone(static_cast<int>(SetupTools::Xcp::OpResult::InvalidOperation));
        return;
    }

    setState(State::Reset_Reset);

    mProgLayer->setSlaveId(mSlaveCmdId + ":" + mSlaveResId);
    mProgLayer->programReset();
}

void Cs2Tool::onProgCalModeDone(Xcp::OpResult result)
{
    if(mState == State::Program_InitialConnect)
    {
        if(result != SetupTools::Xcp::OpResult::Success)
        {
            setState(State::Idle);
            emit programmingDone(static_cast<int>(result));
        }
        else
        {
            if(mProgLayer->conn()->addrGran() == 1)
            {
                // already in bootloader
                setState(State::Program_Program);
                mProgLayer->program(&mInfilledProgData);
            }
            else
            {
                // in application code - program reset needed
                setState(State::Program_ResetToBootloader);
                mProgLayer->programReset();
            }
        }
    }
    if(mState == State::Program_Reconnect)
    {
        if(result != SetupTools::Xcp::OpResult::Success)
        {
            setState(State::Idle);
            emit programmingDone(static_cast<int>(result));
        }
        else
        {
            if(mProgLayer->conn()->addrGran() == 1)
            {
                // in bootloader
                setState(State::Program_Program);
                mProgLayer->program(&mInfilledProgData);
            }
            else
            {
                setState(State::Idle);
                emit programmingDone(static_cast<int>(Xcp::OpResult::BadReply));
            }
        }
    }
    else if(mState == State::Program_CalMode)
    {
        if(result == SetupTools::Xcp::OpResult::Success)
        {
            setState(State::Idle);
            emit programmingDone(static_cast<int>(SetupTools::Xcp::OpResult::Success));
        }
        else
        {
            if(mRemainingCalTries > 0)
            {
                --mRemainingCalTries;
                mProgLayer->calMode();
            }
            else
            {
                setState(State::Idle);
                emit programmingDone(static_cast<int>(result));
            }
        }
    }
    else
    {
        Q_ASSERT(0);
    }
}

void Cs2Tool::onProgramDone(SetupTools::Xcp::OpResult result, FlashProg *prog, quint8 addrExt)
{
    Q_UNUSED(prog);
    Q_UNUSED(addrExt);
    Q_ASSERT(mState == State::Program_Program);
    if(result != SetupTools::Xcp::OpResult::Success)
    {
        setState(State::Idle);
        emit programmingDone(static_cast<int>(result));
        return;
    }
    setState(State::Program_Verify);

    mProgLayer->programVerify(&mInfilledProgData, CKSUM_TYPE);
}

void Cs2Tool::onProgramVerifyDone(SetupTools::Xcp::OpResult result, FlashProg *prog, Xcp::CksumType type, quint8 addrExt)
{
    Q_UNUSED(prog);
    Q_UNUSED(type);
    Q_UNUSED(addrExt);
    Q_ASSERT(mState == State::Program_Verify);
    if(result != SetupTools::Xcp::OpResult::Success)
    {
        setState(State::Idle);
        emit programmingDone(static_cast<int>(result));
        return;
    }

    setState(State::Program_CalMode);
    mProgLayer->calMode();
}
void Cs2Tool::onProgramResetDone(SetupTools::Xcp::OpResult result)
{
    if(mState == State::Program_ResetToBootloader)
    {
        if(result != SetupTools::Xcp::OpResult::Success)
        {
            setState(State::Idle);
            emit programmingDone(static_cast<int>(result));
            return;
        }
        setState(State::Program_Reconnect);
        mProgLayer->calMode();
    }
    else if(mState == State::Reset_Reset)
    {
        setState(State::Idle);
        emit resetDone(static_cast<int>(result));
    }
    else
    {
        Q_ASSERT(0);
    }
}

void Cs2Tool::onProgLayerStateChanged()
{
    if(mState == State::IntfcNotOk && mProgLayer->intfcOk())
        setState(State::Idle);
    else if(mState != State::IntfcNotOk && !mProgLayer->intfcOk())
        setState(State::IntfcNotOk);
}

void Cs2Tool::onProgLayerProgressChanged()
{
    emit stateChanged();
}

void Cs2Tool::onProgLayerOpMsg(SetupTools::Xcp::OpResult result, QString str, SetupTools::Xcp::Connection::OpExtInfo ext)
{
    Q_UNUSED(ext);
    emit fault(result, str);
}

int Cs2Tool::nBlocksInRange(uint progBase, uint progSize, uint rangeBase, uint rangeTop, uint blockSize)
{
    Q_ASSERT(rangeTop > rangeBase);
    Q_ASSERT(blockSize > 0);

    uint progTop = progBase + progSize;
    uint progBaseInRange = std::max(std::min(progBase, rangeTop), rangeBase);
    uint progTopInRange = std::max(std::min(progTop, rangeTop), rangeBase);
    if(progBaseInRange == progTopInRange)
        return 0;
    uint firstBlock = (progBase - rangeBase) / blockSize;
    uint lastBlock = (progTop - rangeBase) / blockSize;
    return lastBlock - firstBlock + 1;
}

void Cs2Tool::setState(Cs2Tool::State newState)
{
    mState = newState;
    emit stateChanged();
}

} // namespace SetupTools
