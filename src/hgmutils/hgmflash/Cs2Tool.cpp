#include "Cs2Tool.h"

namespace SetupTools
{

Cs2Tool::Cs2Tool(QObject *parent) :
    QObject(parent),
    mProgLayer(new Xcp::ProgramLayer(this)),
    mProgFile(new ProgFile(this)),
    mProgFileOkToFlash(false),
    mParamLayer(new Xcp::ParamLayer(ADDR_GRAN, this)),
    mParamFile(new ParamFile(this)),
    mState(State::IntfcNotOk),
    mSlaveCmdId("18FCD403"),
    mSlaveResId("18FCD4F9")
{
    connect(mProgFile, &ProgFile::progChanged, this, &Cs2Tool::onProgFileChanged);
    connect(mProgLayer, &Xcp::ProgramLayer::calModeDone, this, &Cs2Tool::onProgCalModeDone);
    connect(mProgLayer, &Xcp::ProgramLayer::stateChanged, this, &Cs2Tool::onProgLayerStateChanged);
    connect(mProgLayer, &Xcp::ProgramLayer::programDone, this, &Cs2Tool::onProgramDone);
    connect(mProgLayer, &Xcp::ProgramLayer::programVerifyDone, this, &Cs2Tool::onProgramVerifyDone);
    connect(mProgLayer, &Xcp::ProgramLayer::programResetDone, this, &Cs2Tool::onProgramResetDone);
    connect(mProgLayer, &Xcp::ProgramLayer::opProgressChanged, this, &Cs2Tool::onProgLayerProgressChanged);
    mProgLayer->setSlaveTimeout(TIMEOUT_MSEC);
    mProgLayer->setSlaveResetTimeout(RESET_TIMEOUT_MSEC);
    mProgLayer->setSlaveProgResetIsAcked(false);

    connect(mParamLayer, &Xcp::ParamLayer::stateChanged, this, &Cs2Tool::onParamLayerStateChanged);
    connect(mParamLayer, &Xcp::ParamLayer::opProgressChanged, this, &Cs2Tool::onParamLayerProgressChanged);
    connect(mParamLayer, &Xcp::ParamLayer::writeCacheDirtyChanged, this, &Cs2Tool::onParamLayerWriteCacheDirtyChanged);
    connect(mParamLayer, &Xcp::ParamLayer::connectSlaveDone, this, &Cs2Tool::onParamConnectSlaveDone);
    connect(mParamLayer, &Xcp::ParamLayer::downloadDone, this, &Cs2Tool::onParamDownloadDone);
    connect(mParamLayer, &Xcp::ParamLayer::uploadDone, this, &Cs2Tool::onParamUploadDone);
    connect(mParamLayer, &Xcp::ParamLayer::nvWriteDone, this, &Cs2Tool::onParamNvWriteDone);
    connect(mParamLayer, &Xcp::ParamLayer::disconnectSlaveDone, this, &Cs2Tool::onParamDisconnectSlaveDone);
    mParamLayer->setSlaveTimeout(TIMEOUT_MSEC);
    mParamLayer->setSlaveNvWriteTimeout(NVWRITE_TIMEOUT_MSEC);

    mParamFile->setType(ParamFile::Type::Json);
}


Cs2Tool::~Cs2Tool() {}

QString Cs2Tool::programFilePath()
{
    return mProgFile->name();
}

void Cs2Tool::setProgramFilePath(QString path)
{
    mProgFile->setName(path);

    rereadProgFile();
}

QString Cs2Tool::paramFilePath()
{
    return mParamFile->name();
}

void Cs2Tool::setParamFilePath(QString path)
{
    mParamFile->setName(path);
    emit paramFileChanged();
}

int Cs2Tool::programFileType()
{
    return mProgFile->type();
}

void Cs2Tool::setProgramFileType(int type)
{
    mProgFile->setType(static_cast<ProgFile::Type>(type));

    rereadProgFile();
}

int Cs2Tool::programSize()
{
    return mProgFile->size();
}

qlonglong Cs2Tool::programBase()
{
    if(mProgFile->prog().blocks().size() != 1)
        return -1;

    return mProgFile->base();
}

qlonglong Cs2Tool::programCksum()
{
    if(mProgFile->prog().blocks().size() != 1)
        return -1;
    boost::optional<quint32> cksum = Xcp::computeCksumStatic(CKSUM_TYPE, mProgFile->prog().blocks().first()->data);
    if(!cksum)
        return -1;
    return cksum.get();
}

bool Cs2Tool::programOk()
{
    return mProgFile->valid() && mProgFileOkToFlash;
}

bool Cs2Tool::paramFileExists()
{
    return mParamFile->exists();
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
    else if(mState >= State::ParamConnect && mState <= State::ParamNvWrite)
    {
        return mParamLayer->opProgress();
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
    return mProgLayer->idle() && mParamLayer->idle();
}

Xcp::ParamLayer *Cs2Tool::paramLayer()
{
    return mParamLayer;
}

bool Cs2Tool::paramWriteCacheDirty()
{
    return mParamLayer->writeCacheDirty();
}

bool Cs2Tool::paramConnected()
{
    return (mState == State::ParamConnected);
}

bool Cs2Tool::progReady()
{
    return (mState == State::Idle || (mState >= State::Program_InitialConnect && mState <= State::Program_CalMode));
}

bool Cs2Tool::paramReady()
{
    return (mState == State::Idle || (mState >= State::ParamConnect && mState <= State::ParamNvWrite));
}

void Cs2Tool::startProgramming()
{
    if(!mProgFile->valid()
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

void Cs2Tool::startParamConnect()
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

void Cs2Tool::startParamDownload()
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

void Cs2Tool::startParamUpload()
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

void Cs2Tool::loadParamFile()
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

void Cs2Tool::saveParamFile()
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

void Cs2Tool::startParamNvWrite()
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

void Cs2Tool::startParamDisconnect()
{
    if(mState != State::Idle && mState != State::ParamConnected)
    {
        emit paramDisconnectDone(static_cast<int>(SetupTools::Xcp::OpResult::InvalidOperation));
        return;
    }

    mParamLayer->disconnectSlave();
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
                mProgLayer->program(mProgFile->progPtr());
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

    mProgLayer->programVerify(mProgFile->progPtr(), CKSUM_TYPE);
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

    setState(State::Program_ResetToApplication);

    mProgLayer->programReset();
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
        setState(State::Program_Program);
        mProgLayer->program(mProgFile->progPtr());
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

void Cs2Tool::onProgFileChanged()
{
    emit programChanged();
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

void Cs2Tool::onParamLayerStateChanged()
{
    // do nothing
}

void Cs2Tool::onParamLayerProgressChanged()
{
    emit stateChanged();
}

void Cs2Tool::onParamLayerWriteCacheDirtyChanged()
{
    emit paramWriteCacheDirtyChanged();
}

void Cs2Tool::onParamConnectSlaveDone(Xcp::OpResult result)
{
    Q_ASSERT(mState == State::ParamConnect);

    setState(State::ParamConnected);
    emit paramConnectDone(static_cast<int>(result));
}

void Cs2Tool::onParamDownloadDone(SetupTools::Xcp::OpResult result, QStringList keys)
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

void Cs2Tool::onParamUploadDone(SetupTools::Xcp::OpResult result, QStringList keys)
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

void Cs2Tool::onParamNvWriteDone(SetupTools::Xcp::OpResult result)
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

void Cs2Tool::onParamDisconnectSlaveDone(Xcp::OpResult result)
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

void Cs2Tool::rereadProgFile()
{
    mProgFileOkToFlash = false;
    emit programChanged();

    if(mProgFile->name().size() <= 0 ||  mProgFile->type() == ProgFile::Type::Invalid)
        return;

    if(mProgFile->read() != ProgFile::Result::Ok)
        return;

    mProgFile->prog().infillToSingleBlock();

    if(mProgFile->prog().base() < SMALLBLOCK_BASE
            || (mProgFile->prog().base() + mProgFile->prog().size()) > LARGEBLOCK_TOP)
        return; // program is outside of LPC2929 flash

    int nBlocks = 0;
    nBlocks += nBlocksInRange(mProgFile->prog().base(), mProgFile->prog().size(), SMALLBLOCK_BASE, SMALLBLOCK_TOP, SMALLBLOCK_SIZE);
    nBlocks += nBlocksInRange(mProgFile->prog().base(), mProgFile->prog().size(), LARGEBLOCK_BASE, LARGEBLOCK_TOP, LARGEBLOCK_SIZE);
    mProgLayer->setSlaveProgClearTimeout(PROG_CLEAR_BASE_TIMEOUT_MSEC + PROG_CLEAR_TIMEOUT_PER_BLOCK_MSEC * nBlocks);

    mProgFileOkToFlash = true;
    emit programChanged();
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
