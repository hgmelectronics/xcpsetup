#include "testingslave.h"
#include <boost/crc.hpp>
#include <boost/range/iterator_range.hpp>
#include <numeric>

TestingSlave::TestingSlave(QSharedPointer<SetupTools::Xcp::Interface::Loopback::Interface> intfc, QObject *parent) :
    QThread(parent),
    mIntfc(intfc),
    mTerminate(false),
    mNvWriteDelayMsec(0),
    mAg(1),
    mMaxCto(8),
    mPgmMaxCto(8),
    mMaxDto(8),
    mMaxBs(255 / mAg),
    mPgmMaxBs(255 / mAg),
    mMinSt(0),
    mPgmMinSt(0),
    mIsBigEndian(false),
    mMasterBlockSupport(false),
    mPgmMasterBlockSupport(false),
    mSendsEvStoreCal(false),
    mNextMemRangeIdx(0),
    mCrcCalc(NULL),
    mIsConnected(false),
    mIsProgramMode(false),
    mStoreCalReqSet(false),
    mSegment(0),
    mMta({0, 0})
{
    start();
}

TestingSlave::~TestingSlave()
{
    mTerminate = true;
    wait();
}
void TestingSlave::setAg(int ag)
{
    QMutexLocker locker(&mConfigMutex);
    Q_ASSERT(ag == 1 || ag == 2 || ag == 4);
    mAg = ag;
}
void TestingSlave::setMaxCto(quint8 bytes)
{
    QMutexLocker locker(&mConfigMutex);
    Q_ASSERT(bytes >= 8);
    mMaxCto = bytes;
}
void TestingSlave::setPgmMaxCto(quint8 bytes)
{
    QMutexLocker locker(&mConfigMutex);
    Q_ASSERT(bytes >= 8);
    mPgmMaxCto = bytes;
}
void TestingSlave::setMaxDto(quint16 bytes)
{
    QMutexLocker locker(&mConfigMutex);
    Q_ASSERT(bytes >= 8);
    mMaxDto = bytes;
}
void TestingSlave::setMaxBs(quint8 pkts)
{
    QMutexLocker locker(&mConfigMutex);
    Q_ASSERT(pkts >= 1);
    mMaxBs = pkts;
}
void TestingSlave::setPgmMaxBs(quint8 pkts)
{
    QMutexLocker locker(&mConfigMutex);
    Q_ASSERT(pkts >= 1);
    mPgmMaxBs = pkts;
}
void TestingSlave::setMinSt(quint8 time)
{
    QMutexLocker locker(&mConfigMutex);
    Q_ASSERT(time >= 1);
    mMinSt = time;
}
void TestingSlave::setPgmMinSt(quint8 time)
{
    QMutexLocker locker(&mConfigMutex);
    Q_ASSERT(time >= 1);
    mPgmMinSt = time;
}
void TestingSlave::setMasterBlockSupport(bool enable)
{
    QMutexLocker locker(&mConfigMutex);
    mMasterBlockSupport = enable;
}
void TestingSlave::setPgmMasterBlockSupport(bool enable)
{
    QMutexLocker locker(&mConfigMutex);
    mPgmMasterBlockSupport = enable;
}
void TestingSlave::setBigEndian(bool isBigEndian)
{
    QMutexLocker locker(&mConfigMutex);
    mIsBigEndian = isBigEndian;
}
void TestingSlave::setSendsEvStoreCal(bool enable)
{
    QMutexLocker locker(&mConfigMutex);
    mSendsEvStoreCal = enable;
}

void TestingSlave::setCksumType(SetupTools::Xcp::CksumType type)
{
    QMutexLocker locker(&mConfigMutex);
    Q_ASSERT(type != SetupTools::Xcp::CksumType::XCP_USER_DEFINED);
    mCksumType = type;
    switch(type) {
        case SetupTools::Xcp::CksumType::XCP_ADD_11:
            mCrcCalc = [this](boost::iterator_range<std::vector<quint8>::const_iterator> data)
                { return additiveChecksum<quint8, quint8>(data); };
            break;
        case SetupTools::Xcp::CksumType::XCP_ADD_12:
            mCrcCalc = [this](boost::iterator_range<std::vector<quint8>::const_iterator> data)
                { return additiveChecksum<quint16, quint8>(data); };
            break;
        case SetupTools::Xcp::CksumType::XCP_ADD_14:
            mCrcCalc = [this](boost::iterator_range<std::vector<quint8>::const_iterator> data)
                { return additiveChecksum<quint32, quint8>(data); };
            break;
        case SetupTools::Xcp::CksumType::XCP_ADD_22:
            mCrcCalc = [this](boost::iterator_range<std::vector<quint8>::const_iterator> data)
                { return additiveChecksum<quint16, quint16>(data); };
            break;
        case SetupTools::Xcp::CksumType::XCP_ADD_24:
            mCrcCalc = [this](boost::iterator_range<std::vector<quint8>::const_iterator> data)
                { return additiveChecksum<quint32, quint16>(data); };
            break;
        case SetupTools::Xcp::CksumType::XCP_ADD_44:
            mCrcCalc = [this](boost::iterator_range<std::vector<quint8>::const_iterator> data)
                { return additiveChecksum<quint32, quint32>(data); };
            break;
        case SetupTools::Xcp::CksumType::XCP_CRC_16:
            mCrcCalc = [](boost::iterator_range<std::vector<quint8>::const_iterator> data)
            {
                boost::crc_16_type computer;
                computer.process_block(&*data.begin(), &*data.end());
                return computer.checksum();
            };
            break;
        case SetupTools::Xcp::CksumType::XCP_CRC_16_CITT:
            mCrcCalc = [](boost::iterator_range<std::vector<quint8>::const_iterator> data)
            {
                boost::crc_ccitt_type computer;
                computer.process_block(&*data.begin(), &*data.end());
                return computer.checksum();
            };
            break;
        case SetupTools::Xcp::CksumType::XCP_CRC_32:
            mCrcCalc = [](boost::iterator_range<std::vector<quint8>::const_iterator> data)
            {
                boost::crc_32_type computer;
                computer.process_block(&*data.begin(), &*data.end());
                return computer.checksum();
            };
            break;
        case SetupTools::Xcp::CksumType::XCP_USER_DEFINED:
            Q_ASSERT(type != SetupTools::Xcp::CksumType::XCP_USER_DEFINED);
            break;
        default:
            Q_ASSERT(0);
            break;
    }
}
void TestingSlave::setCrcCalc(std::function<quint32(boost::iterator_range<std::vector<quint8>::const_iterator>)> func)
{
    QMutexLocker locker(&mConfigMutex);
    mCksumType = SetupTools::Xcp::CksumType::XCP_USER_DEFINED;
    mCrcCalc = func;
}

int TestingSlave::addMemRange(MemType type, SetupTools::Xcp::XcpPtr base, size_t len, quint8 segment, std::vector<quint8> validPages)
{
    std::vector<quint8> data;
    data.assign(len, 0);
    return addMemRange(type, base, data, segment, validPages);
}
int TestingSlave::addMemRange(MemType type, SetupTools::Xcp::XcpPtr base, std::vector<quint8> data, quint8 segment, std::vector<quint8> validPages)
{
    Q_ASSERT(validPages.size() >= 1);
    QMutexLocker locker(&mConfigMutex);
    int idx = mNextMemRangeIdx;
    mMemRanges.insert({idx, {type, base, data, segment, validPages[0], validPages}});
    ++mNextMemRangeIdx;
    return idx;
}
const std::vector<quint8> &TestingSlave::getMemRange(int idx)
{
    QMutexLocker locker(&mConfigMutex);
    return mMemRanges[idx].data;         // will throw if idx doesn't exist
}
void TestingSlave::setMemRange(int idx, const std::vector<quint8> &data)
{
    QMutexLocker locker(&mConfigMutex);
    mMemRanges[idx].data = data;    // will throw if idx doesn't exist
}
void TestingSlave::removeMemRange(int idx)
{
    QMutexLocker locker(&mConfigMutex);
    std::map<int, MemRange>::iterator it = mMemRanges.find(idx);
    if(it != mMemRanges.end())
        mMemRanges.erase(it);
}
void TestingSlave::setResponseDelay(OpType op, int delayMsec, int lifetimeIter)
{
    QMutexLocker locker(&mConfigMutex);
    mResponseDelay.erase(op);
    mResponseDelay.insert({op, {delayMsec, lifetimeIter}});
}

int TestingSlave::getResponseDelay(OpType op)
{
    std::map<OpType, ResponseDelay>::iterator it = mResponseDelay.find(op);
    if(it == mResponseDelay.end())
        return 0;
    else if(it->second.iterLeft <= 0)
        return 0;
    else
    {
        --(it->second.iterLeft);
        return it->second.msec;
    }
}
bool TestingSlave::isCalPageSupported()
{
    for(std::pair<const int, MemRange> &memRange : mMemRanges) {
        if(memRange.second.type == MemType::Calib)
            return true;
    }
    return false;
}
bool TestingSlave::isPgmSupported()
{
    for(std::pair<const int, MemRange> &memRange : mMemRanges) {
        if(memRange.second.type == MemType::Prog)
            return true;
    }
    return false;
}
void TestingSlave::transmitWithDelay(OpType op, const std::vector<quint8> &data)
{
    int msec = getResponseDelay(op);
    if(msec < 0)
        return;
    else if(msec > 0)
        QThread::msleep(msec);
    mIntfc->slaveTransmit(data);
}
void TestingSlave::finishNvWrite()
{
    if(mIsConnected)
    {
        if(mSendsEvStoreCal)
            mIntfc->slaveTransmit({0xFD, 0x03});
        mStoreCalReqSet = false;
    }
}

void TestingSlave::run()
{
    while(!mTerminate)
    {
        if(mNvWriteTimer.isValid() && mNvWriteTimer.hasExpired(mNvWriteDelayMsec))
        {
            finishNvWrite();
            mNvWriteTimer.invalidate();
        }
        std::vector<std::vector<quint8> > packets = mIntfc->slaveReceive(RECEIVE_TIMEOUT);
        QMutexLocker locker(&mConfigMutex);
        for(auto & packet : packets)
        {
            if(packet.size() < 1)
                continue;
            quint8 cmdCode = packet[0];
            if(!mIsConnected && cmdCode != 0xFF)  // not connected, and packet is not a command to connect
            {
                continue;
            }
            std::vector<quint8> reply;
            switch(cmdCode)
            {
                case CONNECT:
                    if(packet.size() < 2 || packet[1] != 0)
                    {
                        reply = {0xFE, 0x21};   // ERR_CMD_SYNTAX
                        transmitWithDelay(OpType::Connect, reply);
                    }
                    else
                    {
                        reply = {0xFF, 0, 0, 0, 0, 0, 1, 1};
                        if(isCalPageSupported())
                            reply[1] |= 0x01;
                        if(isPgmSupported())
                            reply[1] |= 0x10;
                        if(mIsBigEndian)
                            reply[2] |= 0x01;
                        if(mAg == 2)
                            reply[2] |= 0x02;
                        else if(mAg == 4)
                            reply[2] |= 0x04;
                        reply[3] = mMaxCto;
                        toSlaveEndian(mMaxDto, reply.data() + 4);
                        mIsConnected = true;
                        mIsProgramMode = false;
                        mProgramBlockModeRemBytes.reset();
                        mStoreCalReqSet = false;
                        mSegment = 0;
                        mMta = {0, 0};

                        transmitWithDelay(OpType::Connect, reply);
                    }
                    break;
                case DISCONNECT:
                    mIsConnected = false;
                    reply = {0xFF};
                    transmitWithDelay(OpType::Disconnect, reply);
                    break;
                case GET_STATUS:
                    reply = {0xFF, quint8(mStoreCalReqSet ? 0x01 : 0x00), 0, 0, 0, 0};
                    transmitWithDelay(OpType::GetStatus, reply);
                    break;
                case SYNCH:
                    reply = {0xFE, 0x00};
                    transmitWithDelay(OpType::Synch, reply);
                    break;
                case GET_COMM_MODE_INFO:
                    reply.assign(8, 0);
                    reply[0] = 0xFF;
                    if(mMasterBlockSupport)
                        reply[2] = 0x01;
                    reply[4] = mMaxBs;
                    reply[5] = mMinSt;
                    reply[7] = 0x01;    // XCP driver version number
                    transmitWithDelay(OpType::GetCommModeInfo, reply);
                    break;
                case SET_REQUEST:
                    reply = {0xFF};
                    transmitWithDelay(OpType::SetRequest, reply);
                    mNvWriteDelayMsec = getResponseDelay(OpType::NvWrite);
                    if(mNvWriteDelayMsec > 0)
                        mNvWriteTimer.start();
                    else
                        finishNvWrite();
                    break;
                case SET_MTA:
                    if(packet.size() < 8 || packet[1] != 0 || packet[2] != 0)
                    {
                        reply = {0xFE, ERR_CMD_SYNTAX};
                        transmitWithDelay(OpType::SetMta, reply);
                    }
                    else
                    {
                        mMta.ext = packet[3];
                        mMta.addr = fromSlaveEndian<quint32>(packet.data() + 4);

                        reply = {0xFF};
                        transmitWithDelay(OpType::SetMta, reply);
                    }
                    break;
                case UPLOAD:
                    if(packet.size() < 2)
                    {
                        reply = {0xFE, ERR_CMD_SYNTAX};
                    }
                    else
                    {
                        quint8 nElem = packet[1];
                        auto subRange = findMemRange(nElem, mIsProgramMode ? MemType::Prog : MemType::Calib);
                        if(subRange)
                        {
                            reply.assign(mAg + nElem * mAg, 0);
                            reply[0] = 0xFF;
                            std::copy(subRange.get().begin(), subRange.get().end(), reply.begin() + mAg);
                            mMta.addr += nElem;
                        }
                        else
                        {
                            reply = {0xFE, ERR_OUT_OF_RANGE};
                        }
                    }
                    transmitWithDelay(OpType::Upload, reply);
                    break;
                case SHORT_UPLOAD:
                    if(packet.size() < 8)
                    {
                        reply = {0xFE, ERR_CMD_SYNTAX};
                    }
                    else
                    {
                        mMta.ext = packet[3];
                        mMta.addr = fromSlaveEndian<quint32>(packet.data() + 4);

                        if(packet[1] >= 1 && packet[1] <= (mMaxCto / mAg - 1))
                        {
                            quint8 nElem = packet[1];
                            auto subRange = findMemRange(nElem, mIsProgramMode ? MemType::Prog : MemType::Calib);
                            if(subRange)
                            {
                                reply.assign(mAg + nElem * mAg, 0);
                                reply[0] = 0xFF;
                                std::copy(subRange.get().begin(), subRange.get().end(), reply.begin() + mAg);
                                mMta.addr += nElem;
                            }
                            else
                            {
                                reply = {0xFE, ERR_OUT_OF_RANGE};
                            }
                        }
                    }
                    transmitWithDelay(OpType::ShortUpload, reply);
                    break;
                case BUILD_CHECKSUM:
                    if(packet.size() < 8)
                    {
                        reply = {0xFE, ERR_CMD_SYNTAX};
                    }
                    else
                    {
                        size_t nElem = fromSlaveEndian<quint32>(packet.data() + 4);

                        auto subRange = findMemRange(nElem, mIsProgramMode ? MemType::Prog : MemType::Calib);
                        if(subRange)
                        {
                            Q_ASSERT(mCrcCalc);
                            quint32 checksum = mCrcCalc({subRange.get().begin(), subRange.get().end()});
                            static const std::map<SetupTools::Xcp::CksumType, quint8> CKSUM_TYPE_CODES = {
                                {SetupTools::Xcp::CksumType::XCP_ADD_11, 0x01},
                                {SetupTools::Xcp::CksumType::XCP_ADD_12, 0x02},
                                {SetupTools::Xcp::CksumType::XCP_ADD_14, 0x03},
                                {SetupTools::Xcp::CksumType::XCP_ADD_22, 0x04},
                                {SetupTools::Xcp::CksumType::XCP_ADD_24, 0x05},
                                {SetupTools::Xcp::CksumType::XCP_ADD_44, 0x06},
                                {SetupTools::Xcp::CksumType::XCP_CRC_16, 0x07},
                                {SetupTools::Xcp::CksumType::XCP_CRC_16_CITT, 0x08},
                                {SetupTools::Xcp::CksumType::XCP_CRC_32, 0x09},
                                {SetupTools::Xcp::CksumType::XCP_USER_DEFINED, 0xFF}
                            };
                            reply = {0xFF, CKSUM_TYPE_CODES.at(mCksumType), 0, 0, 0, 0, 0, 0};
                            toSlaveEndian<quint32>(checksum, reply.data() + 4);
                        }
                        else
                        {
                            reply = {0xFE, ERR_OUT_OF_RANGE};
                        }
                    }
                    transmitWithDelay(OpType::BuildChecksum, reply);
                    break;
                case DOWNLOAD:
                    if(mIsProgramMode)
                    {
                        reply = {0xFE, ERR_PGM_ACTIVE};
                    }
                    else if(packet.size() < 2)
                    {
                        reply = {0xFE, ERR_CMD_SYNTAX};
                    }
                    else
                    {
                        quint8 nElem = packet[1];
                        size_t dataBeginIdx = std::max(2, mAg);
                        size_t dataEndIdx = dataBeginIdx + nElem * mAg;    // one past the last byte
                        if(packet.size() < dataEndIdx)
                        {
                            reply = {0xFE, ERR_CMD_SYNTAX};
                        }
                        else
                        {
                            auto subRange = findMemRange(nElem, MemType::Calib);
                            if(subRange)
                            {
                                std::copy(packet.begin() + dataBeginIdx, packet.begin() + dataEndIdx, subRange.get().begin());
                                mMta.addr += nElem;
                                reply = {0xFF};
                            }
                            else
                            {
                                reply = {0xFE, ERR_OUT_OF_RANGE};
                            }
                        }
                    }
                    transmitWithDelay(OpType::Download, reply);
                    break;
                case SET_CAL_PAGE:
                    if(mIsProgramMode)
                    {
                        reply = {0xFE, ERR_PGM_ACTIVE};
                    }
                    else if(packet.size() < 4)
                    {
                        reply = {0xFE, ERR_CMD_SYNTAX};
                    }
                    else
                    {
                        bool allSegments = (packet[1] & 0x80);
                        quint8 segment = packet[2];
                        quint8 page = packet[3];
                        bool segmentNotValid = true;
                        bool pageNotValid = false;
                        for(std::pair<const int, MemRange> &memRange : mMemRanges)
                        {
                            if(memRange.second.type == MemType::Calib
                                    && (allSegments || memRange.second.segment == segment))
                            {
                                segmentNotValid = false;
                                if(std::find(memRange.second.validPages.begin(), memRange.second.validPages.end(), page)
                                        == memRange.second.validPages.end())
                                {
                                    pageNotValid = true;
                                }
                                else
                                {
                                    memRange.second.page = page;
                                }
                            }
                        }
                        if(segmentNotValid)
                            reply = {0xFE, ERR_SEGMENT_NOT_VALID};
                        else if(pageNotValid)
                            reply = {0xFE, ERR_PAGE_NOT_VALID};
                        else
                            reply = {0xFF};
                    }
                    transmitWithDelay(OpType::SetCalPage, reply);
                    break;
                case GET_CAL_PAGE:
                    if(mIsProgramMode)
                    {
                        reply = {0xFE, ERR_PGM_ACTIVE};
                    }
                    else if(packet.size() < 3 || (packet[1] != 0x01 && packet[1] != 0x02))
                    {
                        reply = {0xFE, ERR_CMD_SYNTAX};
                    }
                    else
                    {
                        quint8 segment = packet[2];
                        bool segmentNotValid = true;
                        for(const std::pair<const int, MemRange> &memRange : mMemRanges)
                        {
                            if(memRange.second.type == MemType::Calib
                                    && memRange.second.segment == segment)
                            {
                                segmentNotValid = false;
                                reply = {0xFF, 0, 0, memRange.second.page};
                            }
                        }
                        if(segmentNotValid)
                            reply = {0xFE, ERR_SEGMENT_NOT_VALID};
                        // if not segmentNotValid, then reply was set above
                    }
                    transmitWithDelay(OpType::GetCalPage, reply);
                    break;
                case PROGRAM_START:
                    mIsProgramMode = true;
                    if(mProgramBlockModeRemBytes)
                    {
                        reply = {0xFE, ERR_SEQUENCE};
                        mProgramBlockModeRemBytes.reset();
                    }
                    else
                    {
                        reply.assign(7, 0);
                        reply[0] = 0xFF;
                        if(mPgmMasterBlockSupport)
                            reply[2] = 0x01;
                        reply[3] = mPgmMaxCto;
                        reply[4] = mPgmMaxBs;
                        reply[5] = mPgmMinSt;
                        reply[6] = 0;
                        transmitWithDelay(OpType::ProgramStart, reply);
                    }
                    break;
                case PROGRAM_CLEAR:
                    if(!mIsProgramMode)
                    {
                        reply = {0xFE, ERR_GENERIC};
                    }
                    else if(mProgramBlockModeRemBytes)
                    {
                        reply = {0xFE, ERR_SEQUENCE};
                        mProgramBlockModeRemBytes.reset();
                    }
                    else if(packet.size() < 8 || fromSlaveEndian<quint16>(packet.data() + 2) != 0)
                    {
                        reply = {0xFE, ERR_CMD_SYNTAX};
                    }
                    else if(packet[1] > 0x01)
                    {
                        reply = {0xFE, ERR_OUT_OF_RANGE};
                    }
                    else
                    {
                        quint32 clearRange = fromSlaveEndian<quint32>(packet.data() + 4);
                        if(packet[1] == 0)
                        {
                            auto subRange = findMemRange(clearRange, MemType::Calib);
                            if(subRange)
                            {
                                for(quint8 &byte : subRange.get())
                                    byte = 0xFF;
                                reply = {0xFF};
                            }
                            else
                            {
                                reply = {0xFE, ERR_OUT_OF_RANGE};
                            }
                        }
                        else    // if(packet[1] == 0x01)
                        {
                            if(!(clearRange & 0x03))
                            {
                                bool clearCalib = (clearRange & 0x01);
                                bool clearPgm = (clearRange & 0x02);
                                for(std::pair<const int, MemRange> &memRange : mMemRanges)
                                {
                                    if((clearCalib && memRange.second.type == MemType::Calib)
                                            || (clearPgm && memRange.second.type == MemType::Prog))
                                        memRange.second.data.assign(0xFF, memRange.second.data.size());
                                }
                                reply = {0xFF};
                            }
                            else
                            {
                                reply = {0xFE, ERR_OUT_OF_RANGE};
                            }
                        }
                    }
                    transmitWithDelay(OpType::ProgramClear, reply);
                    break;
                case PROGRAM:
                    if(!mIsProgramMode)
                    {
                        reply = {0xFE, ERR_GENERIC};
                    }
                    else if(mProgramBlockModeRemBytes)
                    {
                        reply = {0xFE, ERR_SEQUENCE};
                        mProgramBlockModeRemBytes.reset();
                    }
                    else if(packet.size() < 2)
                    {
                        reply = {0xFE, ERR_CMD_SYNTAX};
                    }
                    else if(packet[1] < 1 || packet[1] > mPgmMaxBs)
                    {
                        reply = {0xFE, ERR_OUT_OF_RANGE};
                    }
                    else
                    {
                        size_t nElem = packet[1];
                        mProgramBlockModeRemBytes = nElem * mAg;
                        reply = doProgramBlock(packet);
                    }
                    if(reply.size())
                        transmitWithDelay(OpType::Program, reply);
                    break;
                case PROGRAM_RESET:
                    if(!mIsProgramMode)
                    {
                        reply = {0xFE, ERR_GENERIC};
                    }
                    else if(mProgramBlockModeRemBytes)
                    {
                        reply = {0xFE, ERR_SEQUENCE};
                        mProgramBlockModeRemBytes.reset();
                    }
                    else
                    {
                        mIsProgramMode = false;
                        mProgramBlockModeRemBytes.reset();
                        reply = {0xFF};
                    }
                    transmitWithDelay(OpType::ProgramReset, reply);
                    break;
                case PROGRAM_NEXT:
                    if(!mIsProgramMode)
                    {
                        reply = {0xFE, ERR_GENERIC};
                    }
                    else if(!mProgramBlockModeRemBytes)
                    {
                        reply = {0xFE, ERR_SEQUENCE};
                    }
                    else
                    {
                        reply = doProgramBlock(packet);
                    }
                    if(reply.size())
                        transmitWithDelay(OpType::Program, reply);
                    break;
                    break;
                case PROGRAM_VERIFY:
                    if(!mIsProgramMode)
                    {
                        reply = {0xFE, ERR_GENERIC};
                    }
                    else if(mProgramBlockModeRemBytes)
                    {
                        reply = {0xFE, ERR_SEQUENCE};
                        mProgramBlockModeRemBytes.reset();
                    }
                    else if(packet.size() < 8)
                    {
                        reply = {0xFE, ERR_CMD_SYNTAX};
                    }
                    else if(packet[1] != 1 || fromSlaveEndian<quint16>(packet.data() + 2) != 0x0001)
                    {
                        reply = {0xFE, ERR_OUT_OF_RANGE};
                    }
                    else
                    {
                        quint32 masterChecksum = fromSlaveEndian<quint32>(packet.data() + 4);
                        bool foundMemRange = false;
                        for(std::pair<const int, MemRange> &memRange : mMemRanges)
                        {
                            if(memRange.second.type == MemType::Prog
                                    && mMta.ext == memRange.second.base.ext
                                    && mMta.addr >= memRange.second.base.addr
                                    && mMta.addr <= memRange.second.base.addr + memRange.second.data.size() / mAg)
                            {
                                Q_ASSERT(mCrcCalc);
                                quint32 checksum = mCrcCalc({memRange.second.data.begin(), memRange.second.data.end()});
                                if(checksum == masterChecksum)
                                    reply = {0xFF};
                                else
                                    reply = {0xFE, ERR_VERIFY};
                                foundMemRange = true;
                                break;
                            }
                        }
                        if(!foundMemRange)
                            reply = {0xFE, ERR_OUT_OF_RANGE};
                    }
                    transmitWithDelay(OpType::ProgramVerify, reply);
                    break;
                default:
                    reply = {0xFE, ERR_CMD_UNKNOWN};
                    transmitWithDelay(OpType::UnknownCmd, reply);
                    break;
            }
        }
    }
}

boost::optional<boost::iterator_range<std::vector<quint8>::iterator> > TestingSlave::findMemRange(size_t nElem, MemType type)
{
    for(std::pair<const int, MemRange> &memRange : mMemRanges)
    {
        if(memRange.second.type == type
                && mSegment == memRange.second.segment
                && mMta.ext == memRange.second.base.ext
                && mMta.addr >= memRange.second.base.addr
                && mMta.addr + nElem <= memRange.second.base.addr + memRange.second.data.size() / mAg)
        {
            size_t offset = (mMta.addr - memRange.second.base.addr) * mAg;
            std::vector<quint8>::iterator itBegin = memRange.second.data.begin() + offset;
            return boost::iterator_range<std::vector<quint8>::iterator>(itBegin, itBegin + nElem * mAg);
        }
    }
    return boost::optional<boost::iterator_range<std::vector<quint8>::iterator> >();
}

std::vector<quint8> TestingSlave::doProgramBlock(const std::vector<quint8> packet)
{
    size_t payload = std::min(int(mProgramBlockModeRemBytes.get()), mPgmMaxCto - std::max(2, mAg)) / mAg;

    if(packet.size() < payload * mAg + std::max(2, mAg))
    {
        mProgramBlockModeRemBytes.reset();
        return {0xFE, ERR_CMD_SYNTAX};
    }

    if(packet[1] != mProgramBlockModeRemBytes.get() / mAg)
    {
        mProgramBlockModeRemBytes.reset();
        return {0xFE, ERR_SEQUENCE};
    }

    auto subRange = findMemRange(payload, MemType::Prog);
    if(!subRange)
    {
        mProgramBlockModeRemBytes.reset();
        return {0xFE, ERR_OUT_OF_RANGE};
    }
    size_t dataBeginIdx = std::max(2, mAg);
    size_t dataEndIdx = dataBeginIdx + payload * mAg;    // one past the last byte
    std::copy(packet.begin() + dataBeginIdx, packet.begin() + dataEndIdx, subRange.get().begin());
    mMta.addr += payload;
    mProgramBlockModeRemBytes = mProgramBlockModeRemBytes.get() - payload * mAg;
    if(mProgramBlockModeRemBytes.get() == 0)
    {
        mProgramBlockModeRemBytes.reset();
        return {0xFF};
    }
    else
        return {};
}
