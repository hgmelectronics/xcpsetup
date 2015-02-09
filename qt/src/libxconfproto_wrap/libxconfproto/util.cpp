#include "util.h"
#include <QDebug>

namespace SetupTools
{

SerialPort::SerialPort(QObject *parent) :
    QextSerialPort(QextSerialPort::EventDriven, parent),
    mTimeout(0),
    mInterCharTimeout(0),
    mLogData(false)
{
    mLogTimer.start();
}
SerialPort::SerialPort(const QString &name, QObject *parent) :
    QextSerialPort(name, QextSerialPort::EventDriven, parent),
    mTimeout(0),
    mInterCharTimeout(0),
    mLogData(false)
{
    mLogTimer.start();
}
SerialPort::SerialPort(const QextPortInfo &info, QObject *parent) :
    QextSerialPort(info.portName, QextSerialPort::EventDriven, parent),
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
    QextSerialPort::flush();
    while(1)
    {
        quint8 bitbucket[1024];
        qint64 bytesToRead = bytesAvailable();
        if(bytesToRead < 0)
            return;
        if(bytesToRead > qint64(sizeof(bitbucket)))
            bytesToRead = sizeof(bitbucket);
        if(read(bitbucket, bytesToRead) == 0)
            break;
    }
}
double SerialPort::elapsedSecs()
{
    return mLogTimer.nsecsElapsed() / double(1000000000);
}

qint64 SerialPort::readData(char *data, qint64 maxSize)
{
    qint64 res = QextSerialPort::readData(data, maxSize);
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
    qint64 res = QextSerialPort::writeData(data, maxSize);
    if(mLogData && res > 0)
    {
        QByteArray arr;
        arr.setRawData(data, res);
        qDebug() << mLogTimer.nsecsElapsed() / double(1000000000) << "Serial TX" << arr.toPercentEncoding();
    }
    return res;
}

QList<QextPortInfo> getValidSerialPorts()
{
    QList<QextPortInfo> ret;
    for(const auto &portInfo : QextSerialEnumerator::getPorts()) {
        QextSerialPort port(portInfo.portName);

        port.open(QIODevice::ReadOnly);
        if(!port.isOpen())
            continue;

        /*port.flush();
        while(1)
        {
            char bitbucket[1024];
            qint64 bytesToRead = port.bytesAvailable();
            if(bytesToRead < 0)
                break;
            if(bytesToRead > qint64(sizeof(bitbucket)))
                bytesToRead = sizeof(bitbucket);
            if(port.read(bitbucket, bytesToRead) == 0)
                break;
        }*/
        if(port.bytesAvailable() >= 0)
            ret.append(portInfo);
        if(port.isOpen())
            port.close();
    }
    return ret;
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
    return mCond.wait(locker.mutex(), timeoutMsec);
}

}   // namespace SetupTools
