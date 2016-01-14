#ifndef UTIL_H
#define UTIL_H

#include <boost/optional.hpp>
#include <QObject>
#include <QtSerialPort/QtSerialPort>
#include <QThread>
#include <QByteArray>
#include <deque>
#include <functional>
#include <QtQml/QQmlEngine>
#include <QtQml/QJSEngine>
#include <QtQml/QQmlListProperty>
#include <QClipboard>

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

class UrlUtil : public QObject
{
    Q_OBJECT
public:
    ~UrlUtil() = default;
    Q_INVOKABLE QString urlToLocalFile(QString url);

    static QObject *create(QQmlEngine *engine, QJSEngine *scriptEngine);

private:
    UrlUtil() = default;


// possible alternative
//    onAccepted: {
//            var path = myFileDialog.fileUrl.toString();
//            // remove prefixed "file:///"
//            path = path.replace(/^(file:\/{3})/,"");
//            // unescape html codes like '%23' for '#'
//            cleanPath = decodeURIComponent(path);
//            console.log(cleanPath)
//        }
//    }


};

class Clipboard : public QObject
{
    Q_OBJECT
    Q_PROPERTY(QString text READ text WRITE setText NOTIFY changed)
public:
    ~Clipboard() = default;

    Q_INVOKABLE void clear();

    Q_INVOKABLE bool ownsClipboard() const;

    Q_INVOKABLE QString text() const;
    Q_INVOKABLE QString text(QString &subtype) const;
    Q_INVOKABLE void setText(const QString &);

    static QObject *create(QQmlEngine *engine, QJSEngine *scriptEngine);
signals:
    void changed();
public slots:
    void onChanged(QClipboard::Mode mode);
private:
    Clipboard();

    QClipboard *mClipboard;
};

class TabSeparated : public QObject
{
    Q_OBJECT
    Q_PROPERTY(QString text READ text WRITE setText NOTIFY textChanged)
    Q_PROPERTY(int rows READ rows WRITE setRows NOTIFY rowsChanged)
    Q_PROPERTY(int columns READ columns WRITE setColumns NOTIFY columnsChanged)
public:
    TabSeparated(QObject *parent = nullptr);
    ~TabSeparated() = default;

    int rows() const;
    int columns() const;
    QString text() const;
    void setRows(int newRows);
    void setColumns(int newColumns);
    void setText(QString newText);
    Q_INVOKABLE QVariant get(int row, int column);
    Q_INVOKABLE bool set(int row, int column, QString value);
signals:
    void textChanged();
    void rowsChanged();
    void columnsChanged();
private:
    QList<QStringList> mArray;
};

template <typename T>
bool updateDelta(T &val, T newVal)
{
    T oldVal = val;
    val = newVal;
    return !(oldVal == newVal);
}

template <typename Ii>
QString ToHexString(Ii begin, Ii end)
{
    QString hex;
    Ii it = begin;
    while(1)
    {
        hex += QString("%1").arg(*it, 2, 16, QChar('0')).toUpper();
        ++it;
        if(it == end)
            break;
        else
            hex += QString(" ");
    }
    return hex;
}

bool inRange(double val, double a, double b); //!< Determines if val is between a and b inclusive; a and b can be in either order.
bool inRange(QVariant val, QVariant a, QVariant b); //!< Determines if val is between a and b inclusive; a and b can be in either order.

class ScopeExit
{
public:
    ScopeExit(std::function<void()> func);
    ~ScopeExit();
private:
    std::function<void()> mFunc;
};

class AppVersion : public QObject
{
    Q_OBJECT
public:
    ~AppVersion() = default;
    Q_PROPERTY(QString hash MEMBER HASH CONSTANT)

    static QObject *create(QQmlEngine *engine, QJSEngine *scriptEngine);

private:
    AppVersion() = default;

    static const QString HASH;
};

}   // namespace SetupTools
#endif // UTIL_H
