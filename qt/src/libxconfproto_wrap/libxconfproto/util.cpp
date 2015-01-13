#include "util.h"

namespace SetupTools
{

SerialPort::SerialPort(QObject *parent) :
    QSerialPort(parent),
    mTimeout(0),
    mInterCharTimeout(0),
    mLogData(false)
{
    mLogTimer.start();
}
SerialPort::SerialPort(const QString &name, QObject *parent) :
    QSerialPort(name, parent),
    mTimeout(0),
    mInterCharTimeout(0),
    mLogData(false)
{
    mLogTimer.start();
}
SerialPort::SerialPort(const QSerialPortInfo &info, QObject *parent) :
    QSerialPort(info, parent),
    mTimeout(0),
    mInterCharTimeout(0),
    mLogData(false)
{
    mLogTimer.start();
}
void SerialPort::setLogging(bool on)
{
    mLogData = on;
}
void SerialPort::setTimeout(int msec)
{
    mTimeout = qint64(msec) * 1000000;
}
void SerialPort::setInterCharTimeout(int msec)
{
    if(msec <= 0)
        mInterCharTimeout = (1000 * 10 + baudRate() - 1) / baudRate();   // divide, rounding up
    else
        mInterCharTimeout = msec;
}
std::vector<quint8> SerialPort::readGranular(qint64 maxlen)
{
    QElapsedTimer timer;
    timer.start();
    std::vector<quint8> ret;
    while(1)
    {
        int bytesLeft = maxlen - ret.size();
        if(timer.nsecsElapsed() > mTimeout || bytesLeft <= 0)
            break;
        waitForReadyRead(mInterCharTimeout);
        std::vector<quint8> data(read(bytesLeft));
        Q_ASSERT(int(data.size()) <= bytesLeft);
        if(data.size() > 0)
            ret.insert(ret.end(), data.begin(), data.end());
        else if(ret.size() > 0)
            break;
    }
    return ret;
}
void SerialPort::fullClear()
{
    clear();
    while(1)
    {
        quint8 bitbucket[1024];
        if(read(bitbucket, sizeof(bitbucket)) == 0)
            break;
    }
}
double SerialPort::elapsedSecs()
{
    return mLogTimer.nsecsElapsed() / double(1000000000);
}

qint64 SerialPort::readData(char *data, qint64 maxSize)
{
    qint64 res = QSerialPort::readData(data, maxSize);
    if(mLogData && res > 0)
    {
        QByteArray arr;
        arr.setRawData(data, res);
        qDebug() << mLogTimer.nsecsElapsed() / double(1000000000) << "Serial RX" << arr.toPercentEncoding();
    }
    return res;
}
qint64 SerialPort::writeData(const char *data, qint64 maxSize)
{
    qint64 res = QSerialPort::writeData(data, maxSize);
    if(mLogData && res > 0)
    {
        QByteArray arr;
        arr.setRawData(data, res);
        qDebug() << mLogTimer.nsecsElapsed() / double(1000000000) << "Serial TX" << arr.toPercentEncoding();
    }
    return res;
}

PythonicEvent::PythonicEvent(QObject *parent) :
    QObject(parent),
    mFlag(false)
{}
PythonicEvent::~PythonicEvent() {}
bool PythonicEvent::isSet()
{
    QMutexLocker locker(&mMutex);
    return mFlag;
}
void PythonicEvent::set()
{
    QMutexLocker locker(&mMutex);
    mFlag = true;
    mCond.wakeAll();
}
void PythonicEvent::clear()
{
    QMutexLocker locker(&mMutex);
    mFlag = false;
}
bool PythonicEvent::wait(unsigned long timeoutMsec)
{
    QMutexLocker locker(&mMutex);
    if(mFlag)
        return true;
    if(mCond.wait(locker.mutex(), timeoutMsec))
        return true;
    return mFlag;
    /*
     * Recheck of mFlag may not have any effect - but if implementation is such that this thread can be
     * preempted after taking timestamp for timeout and before beginning wait, it seems plausible that
     * this thread will never actually check the condition (since thread setting the condition will be prevented
     * from getting the mutex until after timeout has expired).
     */
}

}   // namespace SetupTools
