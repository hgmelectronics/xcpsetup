#include "util.h"

namespace SetupTools
{

GranularTimeSerialPort::GranularTimeSerialPort(QObject *parent) :
    QSerialPort(parent),
    mTimeout(0),
    mInterCharTimeout(0),
    mLogData(false)
{
    mLogTimer.start();
}
GranularTimeSerialPort::GranularTimeSerialPort(const QString &name, QObject *parent) :
    QSerialPort(name, parent),
    mTimeout(0),
    mInterCharTimeout(0),
    mLogData(false)
{
    mLogTimer.start();
}
GranularTimeSerialPort::GranularTimeSerialPort(const QSerialPortInfo &info, QObject *parent) :
    QSerialPort(info, parent),
    mTimeout(0),
    mInterCharTimeout(0),
    mLogData(false)
{
    mLogTimer.start();
}
void GranularTimeSerialPort::setLogging(bool on)
{
    mLogData = on;
}
void GranularTimeSerialPort::setTimeout(int msec)
{
    mTimeout = msec;
}
void GranularTimeSerialPort::setInterCharTimeout(int msec)
{
    if(msec <= 0)
        mInterCharTimeout = (1000 * 10 + baudRate() - 1) / baudRate();   // divide, rounding up
    else
        mInterCharTimeout = msec;
}
QByteArray GranularTimeSerialPort::readGranular(qint64 maxlen)
{
    QElapsedTimer timer;
    timer.start();
    QByteArray ret;
    while(1)
    {
        int bytesLeft = maxlen - ret.size();
        if(timer.hasExpired(mTimeout) || bytesLeft <= 0)
            break;
        waitForReadyRead(mInterCharTimeout);
        QByteArray data = read(bytesLeft);
        Q_ASSERT(data.size() <= bytesLeft);
        if(data.size() > 0)
            ret.append(data);
        else if(ret.size() > 0)
            break;
    }
    return ret;
}
void GranularTimeSerialPort::fullClear()
{
    clear();
    while(1)
    {
        char bitbucket[1024];
        if(read(bitbucket, sizeof(bitbucket)) == 0)
            break;
    }
}
double GranularTimeSerialPort::elapsedSecs()
{
    return mLogTimer.nsecsElapsed() / double(1000000000);
}

qint64 GranularTimeSerialPort::readData(char *data, qint64 maxSize)
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
qint64 GranularTimeSerialPort::writeData(const char *data, qint64 maxSize)
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

IlQByteArray::IlQByteArray(std::initializer_list<quint8> c)
{
    resize(c.size());
    std::copy(c.begin(), c.end(), reinterpret_cast<quint8 *>(data()));
}

}   // namespace SetupTools
