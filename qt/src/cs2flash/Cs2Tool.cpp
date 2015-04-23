#include "Cs2Tool.h"

namespace SetupTools
{

const QString Cs2Tool::SLAVE_ID_STR = "0x18FCD403:0x18FCD4F9";

Cs2Tool::Cs2Tool(QObject *parent) :
    QObject(parent),
    mProgLayer(new Xcp::ProgramLayer(this)),
    mProgFile(new ProgFile(this)),
    mState(State::IntfcNotOk)
{
    connect(mProgFile, &ProgFile::progChanged, this, &Cs2Tool::onProgFileChanged);
    connect(mProgLayer->conn(), &Xcp::ConnectionFacade::setStateDone, this, &Cs2Tool::onSetStateDone);
    connect(mProgLayer, &Xcp::ProgramLayer::stateChanged, this, &Cs2Tool::onProgLayerStateChanged);
    connect(mProgLayer, &Xcp::ProgramLayer::programDone, this, &Cs2Tool::onProgramDone);
    connect(mProgLayer, &Xcp::ProgramLayer::programVerifyDone, this, &Cs2Tool::onProgramVerifyDone);
    connect(mProgLayer, &Xcp::ProgramLayer::programResetDone, this, &Cs2Tool::onProgramResetDone);
    mProgLayer->setSlaveTimeout(TIMEOUT_MSEC);
    mProgLayer->setSlaveResetTimeout(RESET_TIMEOUT_MSEC);
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

int Cs2Tool::programFileType()
{
    return mProgFile->type();
}

void Cs2Tool::setProgramFileType(int type)
{
    mProgFile->setType(static_cast<ProgFile::Type>(type));

    rereadProgFile();
}

void Cs2Tool::rereadProgFile()
{
    if(mProgFile->name().size() > 0 &&
            mProgFile->type() != ProgFile::Type::Invalid)
    {
        mProgFile->read();
        mProgFile->prog().infillToSingleBlock();
    }
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
    return mProgFile->valid();
}

double Cs2Tool::progress()
{
    return double(static_cast<int>(mState)) / N_STATES;
}

QString Cs2Tool::intfcUri()
{
    return mProgLayer->intfcUri();
}

void Cs2Tool::setIntfcUri(QString uri)
{
    if(mState != State::IntfcNotOk && mState != State::Idle)
    {
        emit intfcUriChanged(); // let the caller know we refused the change
        return;
    }

    mProgLayer->setIntfcUri(uri);
    emit intfcUriChanged();
}

bool Cs2Tool::intfcOk()
{
    return mProgLayer->intfcOk();
}

bool Cs2Tool::idle()
{
    return mProgLayer->idle();
}

void Cs2Tool::startProgramming()
{
    if(!mProgFile->valid()
            || mState != State::Idle)
    {
        emit programmingDone(false);
        return;
    }

    mState = State::InitialConnect;

    mProgLayer->conn()->setState(Xcp::Connection::State::CalMode);
}
void Cs2Tool::onSetStateDone(Xcp::OpResult result)
{

    if(mState == State::InitialConnect)
    {
        if(result != Xcp::OpResult::Success)
        {
            mState = State::Idle;
            emit programmingDone(false);
            return;
        }
        if(mProgLayer->conn()->addrGran() == 1)
        {
            // already in bootloader
            doProgram();
        }
        else
        {
            // in application code - program reset needed
            mState = State::ProgramResetToBootloader;
            mProgLayer->programReset();
        }
    }
    else if(mState == State::CalMode)
    {
        if(result == Xcp::OpResult::Success)
        {
            mState = State::Idle;
            emit programmingDone(true);
            return;
        }
        else
        {
            if(mRemainingCalTries > 0)
            {
                --mRemainingCalTries;
                mProgLayer->conn()->setState(Xcp::Connection::State::CalMode);
            }
            else
            {
                mState = State::Idle;
                emit programmingDone(false);
                return;
            }
        }
    }
    else
    {
        Q_ASSERT(0);
    }
}

void Cs2Tool::doProgram()
{
    mState = State::Program;
    emit progressChanged();

    mProgLayer->setSlaveId(SLAVE_ID_STR);

    int firstPage = mProgFile->prog().base() / PAGE_SIZE;
    int lastPage = (mProgFile->prog().base() + mProgFile->prog().size() - 1) / PAGE_SIZE;
    int nPages = lastPage - firstPage + 1;
    mProgLayer->setSlaveProgClearTimeout(PROG_CLEAR_BASE_TIMEOUT_MSEC + PROG_CLEAR_TIMEOUT_PER_PAGE_MSEC * nPages);
    mProgLayer->program(mProgFile->progPtr());
}

void Cs2Tool::onProgramDone(Xcp::OpResult result, FlashProg *prog, quint8 addrExt)
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

    mProgLayer->programVerify(mProgFile->progPtr(), CKSUM_TYPE);
}

void Cs2Tool::onProgramVerifyDone(Xcp::OpResult result, FlashProg *prog, Xcp::CksumType type, quint8 addrExt)
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

    mState = State::ProgramResetToApplication;
    emit progressChanged();

    mProgLayer->programReset();
}
void Cs2Tool::onProgramResetDone(Xcp::OpResult result)
{
    if(result != Xcp::OpResult::Success)
    {
        mState = State::Idle;
        emit progressChanged();
        emit programmingDone(false);
        return;
    }

    if(mState == State::ProgramResetToBootloader)
    {
        doProgram();
    }
    if(mState == State::ProgramResetToApplication)
    {
        mState = State::CalMode;
        mProgLayer->conn()->setState(Xcp::Connection::State::CalMode);
    }
}

void Cs2Tool::onProgFileChanged()
{
    emit programChanged();
}

void Cs2Tool::onProgLayerStateChanged()
{
    if(mState == State::IntfcNotOk && mProgLayer->intfcOk())
    {
        mState = State::Idle;
    }
    if(mState != State::IntfcNotOk && !mProgLayer->intfcOk())
    {
        mState = State::IntfcNotOk;
    }
    emit stateChanged();
}

} // namespace SetupTools
