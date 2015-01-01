#include "util.h"

namespace SetupTools
{

GranularTimeSerialPort::GranularTimeSerialPort(QObject *parent) :
    QSerialPort(parent),
    mTimeout(0),
    mInterCharTimeout(0)
{}
GranularTimeSerialPort::GranularTimeSerialPort(const QString &name, QObject *parent) :
    QSerialPort(name, parent),
    mTimeout(0),
    mInterCharTimeout(0)
{}
GranularTimeSerialPort::GranularTimeSerialPort(const QSerialPortInfo &info, QObject *parent) :
    QSerialPort(info, parent),
    mTimeout(0),
    mInterCharTimeout(0)
{}
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
            return ret;
        waitForReadyRead(mInterCharTimeout);
        QByteArray data = read(bytesLeft);
        if(data.size() > 0)
            ret.append(data);
        else
            return ret;
    }
}

}   // namespace SetupTools
