#include "IbemTool.h"

namespace SetupTools
{

const QString IbemTool::BCAST_ID_STR = "0x1F000000";
const Xcp::Interface::Can::Filter IbemTool::SLAVE_FILTER =
    {{0x1F000000, Xcp::Interface::Can::Id::Type::Ext},
     0x1FFFF000,
     true};
const QString IbemTool::SLAVE_FILTER_STR = Xcp::Interface::Can::FilterToStr(IbemTool::SLAVE_FILTER);

IbemTool::IbemTool(QObject *parent) :
    QObject(parent),
    mProgLayer(new Xcp::ProgramLayer(this)),
    mProgFile(new ProgFile(this)),
    mSlaveListModel(new MultiselectListModel(this)),
    mActiveSlave(-1),
    mState(State::IntfcNotOk),
    mTotalSlaves(0),
    mSlavesDone(0)
{
    connect(mProgFile, &ProgFile::progChanged, this, &IbemTool::onProgFileChanged);
    connect(mProgLayer->conn(), &Xcp::ConnectionFacade::getAvailSlavesStrDone, this, &IbemTool::onGetAvailSlavesStrDone);
    connect(mProgLayer, &Xcp::ProgramLayer::stateChanged, this, &IbemTool::onProgLayerStateChanged);
    connect(mProgLayer, &Xcp::ProgramLayer::programDone, this, &IbemTool::onProgramDone);
    connect(mProgLayer, &Xcp::ProgramLayer::programVerifyDone, this, &IbemTool::onProgramVerifyDone);
    connect(mProgLayer, &Xcp::ProgramLayer::programResetDone, this, &IbemTool::onProgramResetDone);
    mProgLayer->setSlaveTimeout(TIMEOUT_MSEC);
    mProgLayer->setSlaveResetTimeout(RESET_TIMEOUT_MSEC);
}

IbemTool::~IbemTool() {}

MultiselectListModel *IbemTool::slaveListModel()
{
    return mSlaveListModel;
}

QString IbemTool::programFilePath()
{
    return mProgFile->name();
}

void IbemTool::setProgramFilePath(QString path)
{
    mProgFile->setName(path);

    rereadProgFile();
}

int IbemTool::programFileType()
{
    return mProgFile->type();
}

void IbemTool::setProgramFileType(int type)
{
    mProgFile->setType(static_cast<ProgFile::Type>(type));

    rereadProgFile();
}

void IbemTool::rereadProgFile()
{
    if(mProgFile->name().size() > 0 &&
            mProgFile->type() != ProgFile::Type::Invalid)
    {
        mProgFile->read();
        mProgFile->prog().infillToSingleBlock();
    }
}

int IbemTool::programSize()
{
    return mProgFile->size();
}

qlonglong IbemTool::programBase()
{
    if(mProgFile->prog().blocks().size() != 1)
        return -1;

    return mProgFile->base();
}

qlonglong IbemTool::programCksum()
{
    if(mProgFile->prog().blocks().size() != 1)
        return -1;
    boost::optional<quint32> cksum = Xcp::computeCksumStatic(CKSUM_TYPE, mProgFile->prog().blocks().first()->data);
    if(!cksum)
        return -1;
    return cksum.get();
}

bool IbemTool::programOk()
{
    return mProgFile->valid();
}

double IbemTool::progress()
{
    double ret = 0;
    if(mState == State::PollForSlaves)
        ret = 1.0 - double(mRemainingPollIter) / N_POLL_ITER;
    else if(mTotalSlaves > 0)
        ret = double(mSlavesDone * N_STATES + static_cast<int>(mState))
                / (mTotalSlaves * N_STATES);
    return ret;
}

QString IbemTool::intfcUri()
{
    return mProgLayer->intfcUri();
}

void IbemTool::setIntfcUri(QString uri)
{
    if(mState != State::IntfcNotOk && mState != State::Idle)
    {
        emit intfcUriChanged(); // let the caller know we refused the change
        return;
    }

    mProgLayer->setIntfcUri(uri);
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

void IbemTool::onGetAvailSlavesStrDone(Xcp::OpResult result, QString bcastId, QString filter, QList<QString> slaveIds)
{
    Q_UNUSED(bcastId);
    Q_UNUSED(filter);

    Q_ASSERT(mState == State::PollForSlaves);

    mState = State::Idle;

    mSlaveListModel->removeRows(0, mSlaveListModel->rowCount());

    if(result != Xcp::OpResult::Success)
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
        Q_ASSERT(id.cmd.type == SLAVE_FILTER.filt.type);
        Q_ASSERT((id.cmd.addr & SLAVE_FILTER.maskId) == SLAVE_FILTER.filt.addr);
        int ibemId = (id.cmd.addr - SLAVE_FILTER.filt.addr) / 2;

        bool idOk = false;
        QString displayText;
        if(ibemId == RECOVERY_IBEMID_OFFSET)
        {
            displayText = "Recovery";
            idOk = true;
        }
        else if(ibemId >= REGULAR_IBEMID_OFFSET)
        {
            displayText = QString("ID %1").arg(ibemId - REGULAR_IBEMID_OFFSET);
            idOk = true;
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
    if(!mProgFile->valid()
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

    int firstPage = mProgFile->prog().base() / PAGE_SIZE;
    int lastPage = (mProgFile->prog().base() + mProgFile->prog().size() - 1) / PAGE_SIZE;
    int nPages = lastPage - firstPage + 1;
    mProgLayer->setSlaveProgClearTimeout(PROG_CLEAR_BASE_TIMEOUT_MSEC + PROG_CLEAR_TIMEOUT_PER_PAGE_MSEC * nPages);
    mProgLayer->program(mProgFile->progPtr(), 0, false);
}
void IbemTool::onProgramDone(Xcp::OpResult result, FlashProg *prog, quint8 addrExt)
{
    Q_UNUSED(prog);
    Q_UNUSED(addrExt);
    Q_ASSERT(mState == State::Program);
    if(result != Xcp::OpResult::Success)
    {
        mState = State::Idle;
        emit programmingDone(false);
        return;
    }
    mState = State::ProgramVerify;
    emit progressChanged();

    // start program verify on active slave
    mProgLayer->programVerify(mProgFile->progPtr(), CKSUM_TYPE);
}

void IbemTool::onProgramVerifyDone(Xcp::OpResult result, FlashProg *prog, Xcp::CksumType type, quint8 addrExt)
{
    Q_UNUSED(prog);
    Q_UNUSED(type);
    Q_UNUSED(addrExt);
    Q_ASSERT(mState == State::ProgramVerify);
    if(result != Xcp::OpResult::Success)
    {
        mState = State::Idle;
        emit programmingDone(false);
        return;
    }

    mState = State::ProgramReset1;
    emit progressChanged();

    // start program reset
    mProgLayer->programReset();
}

void IbemTool::onWatchdogExpired()
{
    Q_ASSERT(mState == State::ProgramReset1);
    mState = State::ProgramReset2;
    emit progressChanged();

    // start second program reset
    mRemainingReset2Tries = N_RESET2_TRIES - 1;
    mProgLayer->programReset();
}

void IbemTool::onProgramResetDone(Xcp::OpResult result)
{
    Q_ASSERT(mState == State::ProgramReset1 ||
             mState == State::ProgramReset2);
    if(mState == State::ProgramReset2
            && result == Xcp::OpResult::Timeout
            && mRemainingReset2Tries > 0)
    {
        // Timeout is OK, means slave is not yet awake - try again
        --mRemainingReset2Tries;
        mProgLayer->programReset();
        return;
    }
    if(result != Xcp::OpResult::Success)
    {
        mState = State::Idle;
        emit progressChanged();
        emit programmingDone(false);
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
        mProgLayer->program(mProgFile->progPtr());
    }
}

void IbemTool::onProgFileChanged()
{
    emit programChanged();
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

} // namespace SetupTools
