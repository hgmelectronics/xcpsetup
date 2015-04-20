#include "IbemTool.h"

namespace SetupTools
{

const QString IbemTool::BCAST_ID_STR = "0x1F000000";
const Xcp::Interface::Can::Filter IbemTool::SLAVE_FILTER =
    {{0x1F000100, Xcp::Interface::Can::Id::Type::Ext},
     0x1FFFFF00,
     true};
const QString IbemTool::SLAVE_FILTER_STR = Xcp::Interface::Can::FilterToStr(IbemTool::SLAVE_FILTER);

IbemTool::IbemTool(QObject *parent) :
    QObject(parent),
    mProgLayer(new Xcp::ProgramLayer(this)),
    mProgFile(new ProgFile(this)),
    mSlaveListModel(new MultiselectListModel(this)),
    mState(State::Idle),
    mTotalSlaves(0),
    mSlavesDone(0)
{
    connect(mProgFile, &ProgFile::progChanged, this, &IbemTool::onProgFileChanged);
    connect(mProgLayer->conn(), &Xcp::ConnectionFacade::getAvailSlavesStrDone, this, &IbemTool::onGetAvailSlavesStrDone);
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

    if(mProgFile->name().size() > 0 &&
            mProgFile->type() != ProgFile::Type::Invalid)
        mProgFile->read();
}

int IbemTool::programFileType()
{
    return mProgFile->type();
}

void IbemTool::setProgramFileType(int type)
{
    mProgFile->setType(static_cast<ProgFile::Type>(type));

    if(mProgFile->name().size() > 0 &&
            mProgFile->type() != ProgFile::Type::Invalid)
        mProgFile->read();
}

int IbemTool::programSize()
{
    return mProgFile->size();
}

uint IbemTool::programBase()
{
    return mProgFile->base();
}

bool IbemTool::programOk()
{
    return mProgFile->valid();
}

double IbemTool::progress()
{
    if(mTotalSlaves == 0)
        return 0;
    else
        return double(mSlavesDone * N_STATES + static_cast<int>(mState))
                / (mTotalSlaves * N_STATES);
}

QString IbemTool::intfcUri()
{
    return mProgLayer->intfcUri();
}

void IbemTool::setIntfcUri(QString uri)
{
    mProgLayer->setIntfcUri(uri);
    emit intfcUriChanged();
    // Look for IBEMs to stuff slave selection menu
    mProgLayer->conn()->getAvailSlavesStr(BCAST_ID_STR, SLAVE_FILTER_STR);
}

void IbemTool::onGetAvailSlavesStrDone(Xcp::OpResult result, QString bcastId, QString filter, QList<QString> slaveIds)
{
    Q_UNUSED(bcastId);
    Q_UNUSED(filter);

    for(MultiselectListWrapper *wrap : mSlaveListModel->list())
        delete wrap;
    mSlaveListModel->list().clear();

    if(result != Xcp::OpResult::Success)
    {
        emit slaveListModelChanged();
        return;
    }

    for(QString idStr : slaveIds)
    {
        boost::optional<Xcp::Interface::Can::SlaveId> idOpt = Xcp::Interface::Can::StrToSlaveId(idStr);
        Q_ASSERT(idOpt);
        Xcp::Interface::Can::SlaveId id = idOpt.get();
        Q_ASSERT(id.cmd.type == SLAVE_FILTER.filt.type);
        Q_ASSERT((id.cmd.addr & SLAVE_FILTER.maskId) == SLAVE_FILTER.filt.addr);
        int ibemId = (id.cmd.addr - SLAVE_FILTER.filt.addr) / 2;

        MultiselectListWrapper *wrap = new MultiselectListWrapper(mSlaveListModel);
        QVariantObject *idVar = new QVariantObject(QVariant(idStr), wrap);
        wrap->setObj(idVar);
        wrap->setDisplayText(QString("ID %1").arg(ibemId));
        mSlaveListModel->list().push_back(wrap);
    }
    emit slaveListModelChanged();
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
    for(MultiselectListWrapper *wrap : mSlaveListModel->list())
    {
        if(wrap->selected())
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
    mActiveSlave = mSlaveListModel->list().end();
    for(QList<MultiselectListWrapper *>::iterator it = mSlaveListModel->list().begin();
        it != mSlaveListModel->list().end();
        ++it)
    {
        if((*it)->selected())
        {
            mActiveSlave = it;
            break;
        }
    }
    Q_ASSERT(mActiveSlave != mSlaveListModel->list().end());
    QVariant activeSlaveIdVar = *qobject_cast<QVariantObject *>((*mActiveSlave)->obj());
    Q_ASSERT(activeSlaveIdVar.isValid());
    mProgLayer->setSlaveId(activeSlaveIdVar.toString());

    mProgLayer->program(mProgFile->progPtr());
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
    mProgLayer->programVerify(mProgFile->progPtr(), Xcp::CksumType::ST_CRC_32);
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

void IbemTool::onProgramResetDone(Xcp::OpResult result)
{
    Q_ASSERT(mState == State::ProgramReset1 ||
             mState == State::ProgramReset2);
    if(result != Xcp::OpResult::Success)
    {
        mState = State::Idle;
        emit progressChanged();
        emit programmingDone(false);
        return;
    }

    if(mState == State::ProgramReset1)
    {
        mState = State::ProgramReset2;
        emit progressChanged();

        // start second program reset
        mProgLayer->programReset();
    }
    else
    {
        // update mSlavesDone
        ++mSlavesDone;
        // deselect the active slave
        (*mActiveSlave)->setSelected(false);
        if(mSlavesDone == mTotalSlaves)
        {
            mState = State::Idle;
            emit progressChanged();
            emit programmingDone(true);
            return;
        }
        // at least one slave remains, find it
        mActiveSlave = mSlaveListModel->list().end();
        for(QList<MultiselectListWrapper *>::iterator it = (mActiveSlave + 1);
            it != mSlaveListModel->list().end();
            ++it)
        {
            if((*it)->selected())
            {
                mActiveSlave = it;
                break;
            }
        }
        Q_ASSERT(mActiveSlave != mSlaveListModel->list().end());

        // point prog layer to it
        QVariant activeSlaveIdVar = *qobject_cast<QVariantObject *>((*mActiveSlave)->obj());
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

} // namespace SetupTools
