#ifndef UTIL_H
#define UTIL_H

#include <boost/optional.hpp>
#include <QtSerialPort/QtSerialPort>
#include <QThread>

namespace SetupTools
{

class GranularTimeSerialPort : public QSerialPort
{
public:
    explicit GranularTimeSerialPort(QObject *parent = Q_NULLPTR);
    explicit GranularTimeSerialPort(const QString &name, QObject *parent = Q_NULLPTR);
    explicit GranularTimeSerialPort(const QSerialPortInfo &info, QObject *parent = Q_NULLPTR);
    virtual ~GranularTimeSerialPort() {}
    void setLogging(bool on);
    void setTimeout(int msec);
    void setInterCharTimeout(int msec = -1);    // Any value <= 0 means auto calculate
    QByteArray readGranular(qint64 maxlen);
    void fullClear();
    double elapsedSecs();
protected:
    virtual qint64 readData(char *data, qint64 maxSize);
    virtual qint64 writeData(const char *data, qint64 maxSize);
private:
    int mTimeout, mInterCharTimeout;
    QElapsedTimer mLogTimer;
    bool mLogData;
};

template <typename T>
bool containsNonHex(const T & container)
{
    for(char c : container)
    {
        if(c < '0')
            return true;
        else if(c <= '9')
            continue;
        else if(c < 'A')
            return true;
        else if(c <= 'F')
            continue;
        else if(c < 'a')
            return true;
        else if(c <= 'f')
            continue;
        else
            return true;
    }
    return false;
}

/*!
 * \brief A queue that works like the Python queue.Queue
 *
 * Provides thread-safe producer-consumer queue without the need to have a Qt event loop
 */
template <typename T>
class PythonicQueue
{
public:
    boost::optional<T> get(int timeoutMsec = 0)
    {
        QMutexLocker locker(&mMutex);

        if(!mQueue.isEmpty())
            return mQueue.takeFirst();
        else if(timeoutMsec == 0)
            return boost::optional<T>();
        else
        {
            mCond.wait(locker.mutex(), timeoutMsec);
            if(!mQueue.isEmpty())
                return mQueue.takeFirst();
            else
                return boost::optional<T>();
        }
    }

    QList<T> getAll(int timeoutMsec = 0)
    {
        QMutexLocker locker(&mMutex);
        QList<T> ret;

        if(!mQueue.isEmpty())
            mQueue.swap(ret);
        else if(timeoutMsec > 0)
        {
            mCond.wait(locker.mutex(), timeoutMsec);
            if(!mQueue.isEmpty())
                mQueue.swap(ret);
        }
        return ret;
    }

    bool empty()
    {
        QMutexLocker locker(&mMutex);
        return mQueue.empty();
    }

    void put(const T &obj)
    {
        QMutexLocker locker(&mMutex);
        mQueue.append(obj);
        mCond.wakeOne();
    }

private:
    QList<T> mQueue;
    QMutex mMutex;
    QWaitCondition mCond;
};

class IlQByteArray : public QByteArray
{
public:
    IlQByteArray(std::initializer_list<quint8> c);
};

}   // namespace SetupTools
#endif // UTIL_H
