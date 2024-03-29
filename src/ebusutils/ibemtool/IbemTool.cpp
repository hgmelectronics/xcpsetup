#include "IbemTool.h"

namespace SetupTools
{

const QString IbemTool::BCAST_ID_STR = "0x1F000000";
const Xcp::Interface::Can::Filter IbemTool::SLAVE_FILTER =
    {{0x1F000000, Xcp::Interface::Can::Id::Type::Ext},
     0x1FFFF000,
     true};
const QString IbemTool::SLAVE_FILTER_STR = Xcp::Interface::Can::FilterToStr(IbemTool::SLAVE_FILTER);
constexpr Xcp::Interface::Can::SlaveId IbemTool::IBEM_RECOVERY_ID;
constexpr Xcp::Interface::Can::SlaveId IbemTool::CDA_ID;
constexpr Xcp::Interface::Can::SlaveId IbemTool::CDA2_ID;
constexpr Xcp::Interface::Can::SlaveId IbemTool::YTB_ID;
constexpr Xcp::Interface::Can::SlaveId IbemTool::IPC_ID;

IbemTool::IbemTool(QObject *parent) :
    QObject(parent),
    mProgLayer(new Xcp::ProgramLayer(this)),
    mSlaveListModel(new MultiselectListModel(this)),
    mActiveSlave(-1),
    mState(State::IntfcNotOk),
    mTotalSlaves(0),
    mSlavesDone(0)
{
    connect(mProgLayer->conn(), &Xcp::ConnectionFacade::getAvailSlavesStrDone, this, &IbemTool::onGetAvailSlavesStrDone);
    connect(mProgLayer, &Xcp::ProgramLayer::stateChanged, this, &IbemTool::onProgLayerStateChanged);
    connect(mProgLayer, &Xcp::ProgramLayer::programDone, this, &IbemTool::onProgramDone);
    connect(mProgLayer, &Xcp::ProgramLayer::programVerifyDone, this, &IbemTool::onProgramVerifyDone);
    connect(mProgLayer, &Xcp::ProgramLayer::programResetDone, this, &IbemTool::onProgramResetDone);
    connect(mProgLayer, &Xcp::ProgramLayer::pgmModeDone, this, &IbemTool::onProgramModeDone);
    connect(mProgLayer, &Xcp::ProgramLayer::disconnectDone, this, &IbemTool::onDisconnectDone);
    mProgLayer->setSlaveTimeout(TIMEOUT_MSEC);
    mProgLayer->setSlaveBootDelay(RESET_TIMEOUT_MSEC);
}

IbemTool::~IbemTool() {}

MultiselectListModel *IbemTool::slaveListModel()
{
    return mSlaveListModel;
}

FlashProg *IbemTool::programData()
{
    return mProgData;
}

void IbemTool::setProgramData(FlashProg *prog)
{
    mProgData = prog;

    mProgFileOkToFlash = false;

    if(mProgData)
    {
        mInfilledProgData = *mProgData;

        mInfilledProgData.infillToSingleBlock();

        quint32 base = mInfilledProgData.base();
        quint32 top = base + mInfilledProgData.size();

        if((base >= PROG_BASE
             && top <= PROG_TOP)
                || (base >= 0x10000
                    && top <= 0x140000))
            mProgFileOkToFlash = true;
    }

    emit programChanged();
}


int IbemTool::programSize()
{
    if(!mProgData)
        return 0;

    int size = 0;
    for(FlashBlock *block : mProgData->blocks())
        size += block->data.size();
    return size;
}

qlonglong IbemTool::programBase()
{
    if(!mProgData || mProgData->blocks().size() == 0)
        return -1;

    return mProgData->blocks()[0]->base;
}

qlonglong IbemTool::programCksum()
{
    if(mInfilledProgData.blocks().size() != 1)
        return -1;
    boost::optional<quint32> cksum = Xcp::computeCksumStatic(CKSUM_TYPE, mInfilledProgData.blocks().first()->data);
    if(!cksum)
        return -1;
    return cksum.get();
}

bool IbemTool::programOk()
{
    return mProgData && mProgFileOkToFlash;
}

double IbemTool::progress()
{
    if(mState == State::PollForSlaves)
    {
        return 1.0 - double(mRemainingPollIter) / N_POLL_ITER;
    }
    else if(mTotalSlaves > 0)
    {
        double stateProgress = double(static_cast<int>(mState) - static_cast<int>(State::Program))
                / (N_PROGRAM_STATES - 1);
        double programProgress = 0;
        if(mState == State::Program)
            programProgress = mProgLayer->opProgress();
        else if(mState > State::Program)
            programProgress = 1;

        double slaveProgress = stateProgress * PROGRAM_STATE_PROGRESS_CREDIT + programProgress * PROGRAM_PROGRESS_MULT;

        return (mSlavesDone + slaveProgress) / mTotalSlaves;
    }
    else
    {
        return 0;
    }
}

QUrl IbemTool::intfcUri()
{
    return mProgLayer->intfcUri();
}

void IbemTool::setIntfcUri(QUrl uri)
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

bool IbemTool::intfcOk()
{
    return mProgLayer->intfcOk();
}

bool IbemTool::idle()
{
    return mProgLayer->idle() && mRemainingPollIter == 0;
}

bool IbemTool::progReady()
{
    return (mState == State::Idle);
}

void IbemTool::pollForSlaves()
{
    if(mState != State::Idle)
        return;
    if(!mProgLayer->intfcOk())
        return;

    mState = State::PollForSlaves;
    mRemainingPollIter = N_POLL_ITER;
    emit stateChanged();
    emit progressChanged();
    mProgLayer->conn()->getAvailSlavesStr(BCAST_ID_STR, SLAVE_FILTER_STR);
}

void IbemTool::abort()
{
    if(mState == State::PollForSlaves)
    {
        mRemainingPollIter = 0;
        emit progressChanged();
    }
    else if(mState != State::IntfcNotOk && mState != State::Idle)
    {
        for(int iRow = 0; iRow < mSlaveListModel->rowCount(); ++iRow)
        {
            mSlaveListModel->wrapper(iRow)->setSelected(false);
        }
        mSlaveListModel->alteredData(0, mSlaveListModel->rowCount() - 1);
        emit progressChanged();
    }
}

void IbemTool::onGetAvailSlavesStrDone(SetupTools::OpResult result, QString bcastId, QString filter, QList<QString> slaveIds)
{
    Q_UNUSED(bcastId);
    Q_UNUSED(filter);

    Q_ASSERT(mState == State::PollForSlaves);

    mState = State::Idle;

    mSlaveListModel->removeRows(0, mSlaveListModel->rowCount());

    if(result != SetupTools::OpResult::Success)
    {
        emit slaveListModelChanged();
        return;
    }

    mSlaveListModel->insertRows(0, slaveIds.size());
    int iRow = 0;
    for(QString idStr : slaveIds)
    {
        boost::optional<Xcp::Interface::Can::SlaveId> idOpt = Xcp::Interface::Can::StrToSlaveId(idStr);
        Q_ASSERT(idOpt);
        Xcp::Interface::Can::SlaveId id = idOpt.get();
        Q_ASSERT((id.cmd.addr & SLAVE_FILTER.maskId) == SLAVE_FILTER.filt.addr);

        quint32 ibemId = (id.cmd.addr - SLAVE_FILTER.filt.addr) / 2;

        bool idOk = true;
        QString displayText;

        if(id == IBEM_RECOVERY_ID)
        {
            displayText = tr("IBEM Recovery");
        }
        else if(id == CDA_ID)
        {
            displayText = tr("CDA");
        }
        else if(id == CDA2_ID)
        {
            displayText = tr("CDA2");
        }
        else if(id == YTB_ID)
        {
            displayText = tr("YTB");
        }
        else if(id == IPC_ID)
        {
            displayText = tr("IPC");
        }
        else if(ibemId <= IBEM_ID_MAX)
        {
            displayText = tr("ID %1").arg(ibemId);
        }
        else
        {
            idOk = false;
        }

        if(idOk)
        {
            MultiselectListWrapper *wrap = new MultiselectListWrapper(mSlaveListModel);
            QVariantObject *idVar = new QVariantObject(QVariant(idStr), wrap);
            wrap->setObj(idVar);
            wrap->setDisplayText(displayText);
            mSlaveListModel->setData(mSlaveListModel->index(iRow),
                                     QVariant::fromValue(static_cast<QObject *>(wrap)),
                                     0);
            ++iRow;
        }
    }
    if(mSlaveListModel->rowCount() > iRow)
        mSlaveListModel->removeRows(iRow, mSlaveListModel->rowCount() - iRow);
    emit slaveListModelChanged();

    if(mRemainingPollIter > 0)
        --mRemainingPollIter;
    if(mRemainingPollIter)
    {
        mState = State::PollForSlaves;
        emit progressChanged();
        mProgLayer->conn()->getAvailSlavesStr(BCAST_ID_STR, SLAVE_FILTER_STR);
        return;
    }
    else
    {
        emit progressChanged();
        emit stateChanged();
    }
    return;
}

void IbemTool::startProgramming()
{
    if(!mProgData
            || !mProgFileOkToFlash
            || mState != State::Idle)
    {
        emit programmingDone(false);
        return;
    }
    mState = State::Program;
    // Set mTotalSlaves and mSlavesDone
    mTotalSlaves = 0;
    mSlavesDone = 0;
    for(int iRow = 0; iRow < mSlaveListModel->rowCount(); ++iRow)
    {
        if(mSlaveListModel->wrapper(iRow)->selected())
            ++mTotalSlaves;
    }
    if(mTotalSlaves == 0)
    {
        mState = State::Idle;
        emit programmingDone(true);
        return;
    }
    emit progressChanged();

    // Find a slave selected, point prog layer to it
    mActiveSlave = -1;
    for(int iRow = 0; iRow < mSlaveListModel->rowCount(); ++iRow)
    {
        if(mSlaveListModel->wrapper(iRow)->selected())
        {
            mActiveSlave = iRow;
            break;
        }
    }
    Q_ASSERT(mActiveSlave >= 0);
    QVariant activeSlaveIdVar = *qobject_cast<QVariantObject *>(mSlaveListModel->wrapper(mActiveSlave)->obj());
    Q_ASSERT(activeSlaveIdVar.isValid());
    mProgLayer->setSlaveId(activeSlaveIdVar.toString());
    if(mProgLayer->slaveId().toLower() != activeSlaveIdVar.toString().toLower())
    {
        mState = State::Idle;
        emit programmingDone(false);
        return;
    }

    int firstPage = mInfilledProgData.base() / ST_PAGE_SIZE;
    int lastPage = (mInfilledProgData.base() + mInfilledProgData.size() - 1) / ST_PAGE_SIZE;
    int nPages = lastPage - firstPage + 1;
    int maxProgClearPages = (mProgLayer->intfc()->maxReplyTimeout() - PROG_CLEAR_BASE_TIMEOUT_MSEC) / PROG_CLEAR_TIMEOUT_PER_PAGE_MSEC;
    mProgLayer->setMaxEraseSize(maxProgClearPages * ST_PAGE_SIZE);
    mProgLayer->setSlaveProgClearTimeout(PROG_CLEAR_BASE_TIMEOUT_MSEC + PROG_CLEAR_TIMEOUT_PER_PAGE_MSEC * std::min(nPages, maxProgClearPages));
    mProgLayer->program(&mInfilledProgData, 0, false);
}
void IbemTool::onProgramDone(SetupTools::OpResult result, FlashProg *prog, quint8 addrExt)
{
    Q_UNUSED(prog);
    Q_UNUSED(addrExt);
    Q_ASSERT(mState == State::Program);
    if(result != SetupTools::OpResult::Success)
    {
        emit programmingDone(false);
        mState = State::Disconnect;
        mProgLayer->disconnect();
        return;
    }
    mState = State::ProgramVerify;
    emit progressChanged();

    // start program verify on active slave
    mProgLayer->programVerify(&mInfilledProgData, CKSUM_TYPE);
}

void IbemTool::onProgramVerifyDone(SetupTools::OpResult result, FlashProg *prog, Xcp::CksumType type, quint8 addrExt)
{
    Q_UNUSED(prog);
    Q_UNUSED(type);
    Q_UNUSED(addrExt);
    Q_ASSERT(mState == State::ProgramVerify);
    if(result != SetupTools::OpResult::Success)
    {
        emit programmingDone(false);
        mState = State::Disconnect;
        emit progressChanged();
        mProgLayer->disconnect();
    }

    mState = State::ProgramReset1;
    emit progressChanged();

    // start program reset
    mProgLayer->programReset();
}

void IbemTool::onWatchdogExpired()
{
    Q_ASSERT(mState == State::ProgramReset1);
    mState = State::ProgramMode;
    emit progressChanged();

    // start trying to connect and go into program mode
    mRemainingProgramModeTries = N_PROGRAMMODE_TRIES - 1;
    mProgLayer->pgmMode();
}

void IbemTool::onProgramResetDone(SetupTools::OpResult result)
{
    Q_ASSERT(mState == State::ProgramReset1 ||
             mState == State::ProgramReset2);

    if(result != SetupTools::OpResult::Success)
    {
        emit programmingDone(false);
        mState = State::Disconnect;
        emit progressChanged();
        mProgLayer->disconnect();
        return;
    }

    if(mState == State::ProgramReset1)
    {
        QTimer::singleShot(WATCHDOG_MSEC, Qt::PreciseTimer, this, &IbemTool::onWatchdogExpired);
    }
    else // mState == State::ProgramReset2
    {
        // update mSlavesDone
        ++mSlavesDone;
        // deselect the active slave
        mSlaveListModel->wrapper(mActiveSlave)->setSelected(false);
        mSlaveListModel->alteredData(mActiveSlave);
        if(mSlavesDone == mTotalSlaves)
        {
            mState = State::Idle;
            emit progressChanged();
            emit programmingDone(true);
            return;
        }
        // at least one slave remains, find it
        mActiveSlave = -1;
        for(int iRow = 0; iRow < mSlaveListModel->rowCount(); ++iRow)
        {
            if(mSlaveListModel->wrapper(iRow)->selected())
            {
                mActiveSlave = iRow;
                break;
            }
        }
        Q_ASSERT(mActiveSlave >= 0);

        // point prog layer to it
        QVariant activeSlaveIdVar = *qobject_cast<QVariantObject *>(mSlaveListModel->wrapper(mActiveSlave)->obj());
        Q_ASSERT(activeSlaveIdVar.isValid());
        mProgLayer->setSlaveId(activeSlaveIdVar.toString());

        // tell prog layer to start programming it
        mProgLayer->program(&mInfilledProgData);
    }
}

void IbemTool::onProgramModeDone(SetupTools::OpResult result)
{
    Q_ASSERT(mState == State::ProgramMode);
    if(result == SetupTools::OpResult::Timeout
            && mRemainingProgramModeTries > 0)
    {
        // Timeout is OK, means slave is not yet awake - try again
        --mRemainingProgramModeTries;
        mProgLayer->pgmMode();
        return;
    }
    if(result != SetupTools::OpResult::Success)
    {
        emit programmingDone(false);
        mState = State::Disconnect;
        emit progressChanged();
        mProgLayer->disconnect();
        return;
    }

    mState = State::ProgramReset2;
    emit progressChanged();
    mProgLayer->programReset();
}

void IbemTool::onDisconnectDone(SetupTools::OpResult result)
{
    Q_UNUSED(result);
    Q_ASSERT(mState == State::Disconnect);

    mState = State::Idle;
    emit progressChanged();
}

void IbemTool::onProgLayerStateChanged()
{
    if(mState == State::IntfcNotOk && mProgLayer->intfcOk())
    {
        mState = State::Idle;
        pollForSlaves();
    }
    if(mState != State::IntfcNotOk && !mProgLayer->intfcOk())
    {
        mState = State::IntfcNotOk;
    }
    emit stateChanged();
}

void IbemTool::onProgLayerProgressChanged()
{
    emit progressChanged();
}

} // namespace SetupTools
