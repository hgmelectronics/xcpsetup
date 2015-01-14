#include "testingslave.h"

TestingSlave::TestingSlave(SetupTools::Xcp::Interface::Loopback &intfc, QObject *parent = 0) :
    QThread(parent),
    mIntfc(intfc),
    mAg(1),
    mMaxCto(8),
    mMaxDto(8),
    mMasterBlockSupport(false),
    mNextMemRangeIdx(0),
    mTerminate(false),
    mIsConnected(false)
{
    start();
}

TestingSlave::~TestingSlave()
{
    mTerminate = true;
    wait();
}
void TestingSlave::setAG(int ag)
{
    QMutexLocker locker(&mConfigMutex);
    Q_ASSERT(ag == 1 || ag == 2 || ag == 4);
    mAg = ag;
}
void TestingSlave::setMaxCto(int bytes)
{
    QMutexLocker locker(&mConfigMutex);
    Q_ASSERT(bytes >= 8);
    mMaxCto = bytes;
}
void TestingSlave::setMaxDto(int bytes)
{
    QMutexLocker locker(&mConfigMutex);
    Q_ASSERT(bytes >= 8);
    mMaxDto = bytes;
}
void TestingSlave::setMasterBlockSupport(bool enable)
{
    QMutexLocker locker(&mConfigMutex);
    mMasterBlockSupport = enable;
}
void TestingSlave::setBigEndian(bool isBigEndian)
{
    QMutexLocker locker(&mConfigMutex);
    mIsBigEndian = isBigEndian;
}
int TestingSlave::addMemRange(MemType type, SetupTools::Xcp::XcpPtr base, size_t len)
{
    QMutexLocker locker(&mConfigMutex);
    std::vector<quint8> data;
    data.assign(len, 0);
    return addMemRange(type, base, data);
}
int TestingSlave::addMemRange(MemType type, SetupTools::Xcp::XcpPtr base, std::vector<quint8> data)
{
    QMutexLocker locker(&mConfigMutex);
    int idx = mNextMemRangeIdx;
    mMemRanges.insert({idx, {type, base, data}});
    ++mNextMemRangeIdx;
    return idx;
}
const std::vector<quint8> &TestingSlave::getMemRange(int idx)
{
    QMutexLocker locker(&mConfigMutex);
    return mMemRanges[idx];         // will throw if idx doesn't exist
}
void TestingSlave::setMemRange(int idx, const std::vector<quint8> &data)
{
    QMutexLocker locker(&mConfigMutex);
    mMemRanges[idx].data = data;    // will throw if idx doesn't exist
}
void TestingSlave::removeMemRange(int idx)
{
    QMutexLocker locker(&mConfigMutex);
    std::map<OpType, ResponseDelay>::iterator it = mResponseDelay.find(op);
    if(it != mResponseDelay.end())
        mResponseDelay.erase(it);
}
void TestingSlave::setResponseDelay(OpType op, int delayMsec, int lifetimeIter)
{
    QMutexLocker locker(&mConfigMutex);
    mResponseDelay.erase(op);
    mResponseDelay.insert({op, {delayMsec, lifetimeIter}});
}

void TestingSlave::getResponseDelay(OpType op)
{
    std::map<OpType, ResponseDelay>::iterator it = mResponseDelay.find(op);
    if(it == mResponseDelay.end())
        return 0;
    else if(it->second.lifetimeIter <= 0)
        return 0;
    else
    {
        --(it->second.lifetimeIter);
        return it->second.msec;
    }
}
bool TestingSlave::isCalPageSupported()
{
    for(MemRange &memRange : mMemRanges) {
        if(memRange.type == MemType::Calib)
            return true;
    }
    return false;
}
bool TestingSlave::isPgmSupported()
{
    for(MemRange &memRange : mMemRanges) {
        if(memRange.type == MemType::Pgm)
            return true;
    }
    return false;
}
void TestingSlave::transmitWithDelay(OpType op, const std::vector &data)
{
    int msec = getResponseDelay(op);
    if(msec < 0)
        return;
    else if(msec > 0)
        QThread::msleep(msec);
    mIntfc.slaveTransmit(data);
}

void TestingSlave::run()
{
    while(!mTerminate)
    {
        std::vector<std::vector<quint8> > packets = mIntfc.slaveReceive(RECEIVE_TIMEOUT);
        QMutexLocker locker(&mConfigMutex);
        for(auto & packet : packets)
        {
            if(packet.size() < 1)
                continue;
            std::vector<quint8> reply;
            switch(packet[0])
            {
                case 0xFF:
                    if(packet.size() >= 2 && packet[1] == 0)
                    {\
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

                        transmitWithDelay(OpType::Connect, reply);
                    }
                    break;
                case 0xFE:
                    mIsConnected = false;
                    transmitWithDelay(OpType::Disconnect, {0xFF});
                    break;
            }
        }
    }
}
