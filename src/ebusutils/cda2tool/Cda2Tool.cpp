#include "Cda2Tool.h"

namespace SetupTools
{

Cda2Tool::Cda2Tool(QObject *parent) :
    QObject(parent),
    mProgLayer(new Xcp::ProgramLayer(this)),
    mProgFileOkToFlash(false),
    mParamLayer(new Xcp::ParamLayer(ADDR_GRAN, this)),
    mParamFile(new ParamFile(this)),
    mState(State::IntfcNotOk),
    mSlaveCmdId("1F000090"),
    mSlaveResId("1F000091")
{
    connect(mProgLayer, &Xcp::ProgramLayer::calModeDone, this, &Cda2Tool::onProgCalModeDone);
    connect(mProgLayer, &Xcp::ProgramLayer::stateChanged, this, &Cda2Tool::onProgLayerStateChanged);
    connect(mProgLayer, &Xcp::ProgramLayer::programDone, this, &Cda2Tool::onProgramDone);
    connect(mProgLayer, &Xcp::ProgramLayer::programVerifyDone, this, &Cda2Tool::onProgramVerifyDone);
    connect(mProgLayer, &Xcp::ProgramLayer::programResetDone, this, &Cda2Tool::onProgramResetDone);
    connect(mProgLayer, &Xcp::ProgramLayer::opProgressChanged, this, &Cda2Tool::onProgLayerProgressChanged);
    mProgLayer->setSlaveTimeout(TIMEOUT_MSEC);
    mProgLayer->setSlaveResetTimeout(RESET_TIMEOUT_MSEC);
    mProgLayer->setSlaveProgResetIsAcked(false);

    connect(mParamLayer, &Xcp::ParamLayer::stateChanged, this, &Cda2Tool::onParamLayerStateChanged);
    connect(mParamLayer, &Xcp::ParamLayer::opProgressChanged, this, &Cda2Tool::onParamLayerProgressChanged);
    connect(mParamLayer, &Xcp::ParamLayer::writeCacheDirtyChanged, this, &Cda2Tool::onParamLayerWriteCacheDirtyChanged);
    connect(mParamLayer, &Xcp::ParamLayer::connectSlaveDone, this, &Cda2Tool::onParamConnectSlaveDone);
    connect(mParamLayer, &Xcp::ParamLayer::downloadDone, this, &Cda2Tool::onParamDownloadDone);
    connect(mParamLayer, &Xcp::ParamLayer::uploadDone, this, &Cda2Tool::onParamUploadDone);
    connect(mParamLayer, &Xcp::ParamLayer::nvWriteDone, this, &Cda2Tool::onParamNvWriteDone);
    connect(mParamLayer, &Xcp::ParamLayer::disconnectSlaveDone, this, &Cda2Tool::onParamDisconnectSlaveDone);
    mParamLayer->setSlaveTimeout(TIMEOUT_MSEC);
    mParamLayer->setSlaveNvWriteTimeout(NVWRITE_TIMEOUT_MSEC);

    mParamFile->setType(ParamFile::Type::Json);
}


Cda2Tool::~Cda2Tool() {}

FlashProg *Cda2Tool::programData()
{
    return mProgData;
}

void Cda2Tool::setProgramData(FlashProg *prog)
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
         || (mInfilledProgData.base() + mInfilledProgData.size()) > LARGEBLOCK_TOP)
    {
        emit programChanged();
        return;
    }

    int nBlocks = 0;
    nBlocks += nBlocksInRange(mInfilledProgData.base(), mInfilledProgData.size(), SMALLBLOCK_BASE, SMALLBLOCK_TOP, SMALLBLOCK_SIZE);
    nBlocks += nBlocksInRange(mInfilledProgData.base(), mInfilledProgData.size(), LARGEBLOCK_BASE, LARGEBLOCK_TOP, LARGEBLOCK_SIZE);
    mProgLayer->setSlaveProgClearTimeout(PROG_CLEAR_BASE_TIMEOUT_MSEC + PROG_CLEAR_TIMEOUT_PER_BLOCK_MSEC * nBlocks);

    mProgFileOkToFlash = true;
    emit programChanged();
}

QString Cda2Tool::paramFilePath()
{
    return mParamFile->name();
}

void Cda2Tool::setParamFilePath(QString path)
{
    mParamFile->setName(path);
    emit paramFileChanged();
}

int Cda2Tool::programSize()
{
    if(!mProgData)
        return 0;

    int size = 0;
    for(FlashBlock *block : mProgData->blocks())
        size += block->data.size();
    return size;
}

qlonglong Cda2Tool::programBase()
{
    if(!mProgData || mProgData->blocks().size() == 0)
        return -1;

    return mProgData->blocks()[0]->base;
}

qlonglong Cda2Tool::programCksum()
{
    if(mInfilledProgData.blocks().size() != 1)
        return -1;
    boost::optional<quint32> cksum = Xcp::computeCksumStatic(CKSUM_TYPE, mInfilledProgData.blocks().first()->data);
    if(!cksum)
        return -1;
    return cksum.get();
}

bool Cda2Tool::programOk()
{
    return mProgData && mProgFileOkToFlash;
}

bool Cda2Tool::paramFileExists()
{
    return mParamFile->exists();
}

double Cda2Tool::progress()
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
    else if(mState >= State::ParamConnect && mState <= State::ParamNvWrite)
    {
        return mParamLayer->opProgress();
    }
    else    // catch unhandled states
    {
        return 0;
    }
}

double Cda2Tool::programProgress()
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

QUrl Cda2Tool::intfcUri()
{
    return mProgLayer->intfcUri();
}

void Cda2Tool::setIntfcUri(QUrl uri)
{
    if(mState != State::IntfcNotOk && mState != State::Idle)
    {
        emit intfcUriChanged(); // let the caller know we refused the change
        return;
    }

    mProgLayer->setIntfcUri(uri);
    mParamLayer->setIntfc(mProgLayer->intfc(), uri);
    if(mProgLayer->intfc())
    {
        if(QProcessEnvironment::systemEnvironment().value("XCP_PACKET_LOG", "0") == "1")
            mProgLayer->intfc()->setPacketLog(true);
        else
            mProgLayer->intfc()->setPacketLog(false);
    }
    emit intfcUriChanged();
}

QString Cda2Tool::slaveCmdId()
{
    return mSlaveCmdId;
}

void Cda2Tool::setSlaveCmdId(QString id)
{
    mSlaveCmdId = id;
    emit slaveIdChanged();
}

QString Cda2Tool::slaveResId()
{
    return mSlaveResId;
}

void Cda2Tool::setSlaveResId(QString id)
{
    mSlaveResId = id;
    emit slaveIdChanged();
}

bool Cda2Tool::intfcOk()
{
    return mProgLayer->intfcOk();
}

bool Cda2Tool::idle()
{
    return mProgLayer->idle() && mParamLayer->idle();
}

Xcp::ParamLayer *Cda2Tool::paramLayer()
{
    return mParamLayer;
}

bool Cda2Tool::paramWriteCacheDirty()
{
    return mParamLayer->writeCacheDirty();
}

bool Cda2Tool::paramConnected()
{
    return (mState == State::ParamConnected);
}

bool Cda2Tool::progReady()
{
    return (mState == State::Idle || (mState >= State::Program_InitialConnect && mState <= State::Program_CalMode));
}

bool Cda2Tool::paramReady()
{
    return (mState == State::Idle || (mState >= State::ParamConnect && mState <= State::ParamNvWrite));
}

void Cda2Tool::startProgramming()
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

void Cda2Tool::startReset()
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

void Cda2Tool::startParamConnect()
{
    if(mState != State::Idle)
    {
        emit paramConnectDone(static_cast<int>(SetupTools::Xcp::OpResult::InvalidOperation));
        return;
    }

    setState(State::ParamConnect);

    mParamLayer->setSlaveId(mSlaveCmdId + ":" + mSlaveResId);
    mParamLayer->connectSlave();
}

void Cda2Tool::startParamDownload()
{
    if(mState != State::Idle && mState != State::ParamConnected)
    {
        emit paramDownloadDone(static_cast<int>(SetupTools::Xcp::OpResult::InvalidOperation));
        return;
    }

    mParamDisconnectWhenDone = !(mState == State::ParamConnected);

    setState(State::ParamDownload);

    mParamLayer->setSlaveId(mSlaveCmdId + ":" + mSlaveResId);
    mParamLayer->download();
}

void Cda2Tool::startParamUpload()
{
    if(mState != State::Idle && mState != State::ParamConnected)
    {
        emit paramUploadDone(static_cast<int>(SetupTools::Xcp::OpResult::InvalidOperation));
        return;
    }

    mParamDisconnectWhenDone = !(mState == State::ParamConnected);

    setState(State::ParamUpload);

    mParamLayer->setSlaveId(mSlaveCmdId + ":" + mSlaveResId);
    mParamLayer->upload();
}

void Cda2Tool::loadParamFile()
{
    QMap<QString, QVariant> map;
    ParamFile::Result readResult = mParamFile->read(map);
    if(readResult != ParamFile::Result::Ok)
    {
        switch(readResult)
        {
        case ParamFile::Result::Ok:
            emit loadParamFileDone(static_cast<int>(Xcp::OpResult::Success), QStringList());
            break;
        case ParamFile::Result::FileOpenFail:
            emit loadParamFileDone(static_cast<int>(Xcp::OpResult::FileOpenFail), QStringList());
            break;
        case ParamFile::Result::CorruptedFile:
            emit loadParamFileDone(static_cast<int>(Xcp::OpResult::CorruptedFile), QStringList());
            break;
        case ParamFile::Result::InvalidType:
            emit loadParamFileDone(static_cast<int>(Xcp::OpResult::InvalidArgument), QStringList());
            break;
        default:
            emit loadParamFileDone(static_cast<int>(Xcp::OpResult::UnknownError), QStringList());
            break;
        }
        return;
    }
    QStringList failedKeys = mParamLayer->setData(map);
    if(failedKeys.empty())
        emit loadParamFileDone(static_cast<int>(Xcp::OpResult::Success), failedKeys);
    else
        emit loadParamFileDone(static_cast<int>(Xcp::OpResult::WarnKeyLoadFailure), failedKeys);
}

void Cda2Tool::saveParamFile()
{
    ParamFile::Result writeResult = mParamFile->write(mParamLayer->saveableData());
    switch(writeResult)
    {
    case ParamFile::Result::Ok:
        emit saveParamFileDone(static_cast<int>(Xcp::OpResult::Success));
        break;
    case ParamFile::Result::FileOpenFail:
        emit saveParamFileDone(static_cast<int>(Xcp::OpResult::FileOpenFail));
        break;
    case ParamFile::Result::FileWriteFail:
        emit saveParamFileDone(static_cast<int>(Xcp::OpResult::FileWriteFail));
        break;
    case ParamFile::Result::InvalidType:
        emit saveParamFileDone(static_cast<int>(Xcp::OpResult::InvalidArgument));
        break;
    default:
        emit saveParamFileDone(static_cast<int>(Xcp::OpResult::UnknownError));
        break;
    }
}

void Cda2Tool::startParamNvWrite()
{
    if(mState != State::Idle && mState != State::ParamConnected)
    {
        emit paramNvWriteDone(static_cast<int>(SetupTools::Xcp::OpResult::InvalidOperation));
        return;
    }

    mParamDisconnectWhenDone = !(mState == State::ParamConnected);

    setState(State::ParamNvWrite);

    mParamLayer->setSlaveId(mSlaveCmdId + ":" + mSlaveResId);
    mParamLayer->nvWrite();
}

void Cda2Tool::startParamDisconnect()
{
    if(mState != State::Idle && mState != State::ParamConnected)
    {
        emit paramDisconnectDone(static_cast<int>(SetupTools::Xcp::OpResult::InvalidOperation));
        return;
    }

    mParamLayer->disconnectSlave();
}

void Cda2Tool::onProgCalModeDone(Xcp::OpResult result)
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

void Cda2Tool::onProgramDone(SetupTools::Xcp::OpResult result, FlashProg *prog, quint8 addrExt)
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

void Cda2Tool::onProgramVerifyDone(SetupTools::Xcp::OpResult result, FlashProg *prog, Xcp::CksumType type, quint8 addrExt)
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

    setState(State::Program_ResetToApplication);

    mProgLayer->programReset();
}
void Cda2Tool::onProgramResetDone(SetupTools::Xcp::OpResult result)
{
    if(mState == State::Program_ResetToBootloader)
    {
        if(result != SetupTools::Xcp::OpResult::Success)
        {
            setState(State::Idle);
            emit programmingDone(static_cast<int>(result));
            return;
        }
        setState(State::Program_Program);
        mProgLayer->program(&mInfilledProgData);
    }
    else if(mState == State::Program_ResetToApplication)
    {
        if(result != SetupTools::Xcp::OpResult::Success)
        {
            setState(State::Idle);
            emit programmingDone(static_cast<int>(static_cast<int>(result)));
            return;
        }
        setState(State::Program_CalMode);
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

void Cda2Tool::onProgLayerStateChanged()
{
    if(mState == State::IntfcNotOk && mProgLayer->intfcOk())
        setState(State::Idle);
    else if(mState != State::IntfcNotOk && !mProgLayer->intfcOk())
        setState(State::IntfcNotOk);
}

void Cda2Tool::onProgLayerProgressChanged()
{
    emit stateChanged();
}

void Cda2Tool::onParamLayerStateChanged()
{
    // do nothing
}

void Cda2Tool::onParamLayerProgressChanged()
{
    emit stateChanged();
}

void Cda2Tool::onParamLayerWriteCacheDirtyChanged()
{
    emit paramWriteCacheDirtyChanged();
}

void Cda2Tool::onParamConnectSlaveDone(Xcp::OpResult result)
{
    Q_ASSERT(mState == State::ParamConnect);

    if(result == Xcp::OpResult::Success)
        setState(State::ParamConnected);
    else
        setState(State::Idle);
    emit paramConnectDone(static_cast<int>(result));
}

void Cda2Tool::onParamDownloadDone(SetupTools::Xcp::OpResult result, QStringList keys)
{
    Q_UNUSED(keys);

    Q_ASSERT(mState == State::ParamDownload);

    if(mParamDisconnectWhenDone)
    {
        mLastParamResult = result;
        mParamLayer->disconnectSlave();
    }
    else
    {
        setState(State::ParamConnected);
        emit paramDownloadDone(static_cast<int>(result));
    }
}

void Cda2Tool::onParamUploadDone(SetupTools::Xcp::OpResult result, QStringList keys)
{
    Q_UNUSED(keys);

    Q_ASSERT(mState == State::ParamUpload);

    if(mParamDisconnectWhenDone)
    {
        mLastParamResult = result;
        mParamLayer->disconnectSlave();
    }
    else
    {
        setState(State::ParamConnected);
        emit paramUploadDone(static_cast<int>(result));
    }
}

void Cda2Tool::onParamNvWriteDone(SetupTools::Xcp::OpResult result)
{
    Q_ASSERT(mState == State::ParamNvWrite);

    if(mParamDisconnectWhenDone)
    {
        mLastParamResult = result;
        mParamLayer->disconnectSlave();
    }
    else
    {
        setState(State::ParamConnected);
        emit paramNvWriteDone(static_cast<int>(result));
    }
}

void Cda2Tool::onParamDisconnectSlaveDone(Xcp::OpResult result)
{
    Q_ASSERT(mState == State::ParamConnected || mState == State::ParamDownload
             || mState == State::ParamUpload || mState == State::ParamNvWrite);

    State prevState = mState;
    setState(State::Idle);
    switch(prevState)
    {
    case State::ParamConnected:
        emit paramDisconnectDone(static_cast<int>(result));
        break;
    case State::ParamDownload:
        emit paramDownloadDone(static_cast<int>(result));
        break;
    case State::ParamUpload:
        emit paramUploadDone(static_cast<int>(result));
        break;
    case State::ParamNvWrite:
        emit paramNvWriteDone(static_cast<int>(result));
        break;
    default:
        Q_ASSERT(0);
        break;
    }
}

int Cda2Tool::nBlocksInRange(uint progBase, uint progSize, uint rangeBase, uint rangeTop, uint blockSize)
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

void Cda2Tool::setState(Cda2Tool::State newState)
{
    mState = newState;
    emit stateChanged();
}

} // namespace SetupTools
