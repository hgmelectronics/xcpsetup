#ifndef UTIL_H
#define UTIL_H

#include <boost/optional.hpp>
#include <QObject>
#include <QtSerialPort/QtSerialPort>
#include <QThread>
#include <QByteArray>
#include <deque>

namespace SetupTools
{

class SerialPort : public QSerialPort
{
public:
    explicit SerialPort(QObject *parent = Q_NULLPTR);
    explicit SerialPort(const QString &name, QObject *parent = Q_NULLPTR);
    explicit SerialPort(const QSerialPortInfo &info, QObject *parent = Q_NULLPTR);
    virtual ~SerialPort() {}
    void setLogging(bool on);
    void setTimeout(int msec);
    void setInterCharTimeout(int msec = -1);    // Any value <= 0 means auto calculate
    std::vector<quint8> readGranular(qint64 maxlen);
    inline qint64 read(quint8 *data, qint64 maxlen)
    {
        return QSerialPort::read(reinterpret_cast<char *>(data), maxlen);
    }
    inline std::vector<quint8> read(qint64 maxlen)
    {
        std::vector<quint8> ret;
        ret.resize(maxlen);
        qint64 actualSize = read(ret.data(), maxlen);
        if(actualSize >= 0)
            ret.resize(actualSize);
        else
            ret.resize(0);
        return ret;
    }
    inline qint64 write(const quint8 *data, qint64 maxlen)
    {
        return QSerialPort::write(reinterpret_cast<const char *>(data), maxlen);
    }
    inline qint64 write(const std::vector<quint8> &data)
    {
        return QSerialPort::write(reinterpret_cast<const char *>(data.data()), data.size());
    }
    inline qint64 write(const QByteArray &data)
    {
        return QSerialPort::write(data);
    }
    inline qint64 write(const char *data)
    {
        return QSerialPort::write(data);
    }

    void fullClear();
    double elapsedSecs();
protected:
    virtual qint64 readData(char *data, qint64 maxSize);
    virtual qint64 writeData(const char *data, qint64 maxSize);
private:
    qint64 mTimeout;
    int mInterCharTimeout;
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
    boost::optional<T> getLocked(int timeoutMsec = 0)
    {
        if(!mQueue.empty())
        {
            T first = std::move(mQueue.front());
            mQueue.pop_front();
            return first;
        }
        else if(timeoutMsec == 0)
            return boost::optional<T>();
        else
        {
            mCond.wait(&mMutex, timeoutMsec);
            if(!mQueue.empty())
            {
                T first = std::move(mQueue.front());
                mQueue.pop_front();
                return first;
            }
            else
                return boost::optional<T>();
        }
    }

    boost::optional<T> get(int timeoutMsec = 0)
    {
        QMutexLocker locker(&mMutex);

        return getLocked(timeoutMsec);
    }

    std::vector<T> getAllLocked(int timeoutMsec = 0)
    {
        std::vector<T> ret;

        if(!mQueue.empty())
        {
            for(auto & elem : mQueue)
                ret.emplace_back(std::move(elem));
            mQueue.clear();
        }
        else if(timeoutMsec > 0)
        {
            mCond.wait(&mMutex, timeoutMsec);
            if(!mQueue.empty())
            {
                for(auto & elem : mQueue)
                    ret.emplace_back(std::move(elem));
                mQueue.clear();
            }
        }
        return ret;
    }

    std::vector<T> getAll(int timeoutMsec = 0)
    {
        QMutexLocker locker(&mMutex);
        return getAllLocked(timeoutMsec);
    }

    bool empty()
    {
        QMutexLocker locker(&mMutex);
        return mQueue.empty();
    }

    void put(const T &obj)
    {
        QMutexLocker locker(&mMutex);
        mQueue.push_back(obj);
        mCond.wakeOne();
    }

    QMutex &mutex()
    {
        return mMutex;
    }

private:
    std::deque<T> mQueue;
    QMutex mMutex;
    QWaitCondition mCond;
};

class PythonicEvent : public QObject
{
    Q_OBJECT
public:
    explicit PythonicEvent(QObject *parent = 0);
    virtual ~PythonicEvent();
    bool isSet();
    bool wait(unsigned long timeoutMsec = ULONG_MAX);
signals:
public slots:
    void set();
    void clear();
private:
    QMutex mMutex;
    QWaitCondition mCond;
    bool mFlag;
};

}   // namespace SetupTools
#endif // UTIL_H
