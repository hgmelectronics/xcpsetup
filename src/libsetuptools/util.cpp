#include "util.h"
#include <QUrl>
#include <QGuiApplication>

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
        qDebug() << mLogTimer.nsecsElapsed() / double(1000000000) << "Serial RX" << ToHexString(data, data + res);
    }
    return res;
}
qint64 SerialPort::writeData(const char *data, qint64 maxSize)
{
    qint64 res = QSerialPort::writeData(data, maxSize);
    if(mLogData && res > 0)
    {
        qDebug() << mLogTimer.nsecsElapsed() / double(1000000000) << "Serial TX" << ToHexString(data, data + res);
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
    return mCond.wait(locker.mutex(), timeoutMsec);
}

QString UrlUtil::urlToLocalFile(QString urlStr)
{
    QUrl url(urlStr);
    return url.toLocalFile();
}

QObject *UrlUtil::create(QQmlEngine *engine, QJSEngine *scriptEngine)
{
    Q_UNUSED(engine);
    Q_UNUSED(scriptEngine);
    return new UrlUtil();
}

Clipboard::Clipboard() : mClipboard(QGuiApplication::clipboard())
{
    connect(mClipboard, &QClipboard::changed, this, &Clipboard::onChanged);
}

void Clipboard::clear()
{
    mClipboard->clear(QClipboard::Clipboard);
}

bool Clipboard::ownsClipboard() const
{
    return mClipboard->ownsClipboard();
}

QString Clipboard::text() const
{
    return mClipboard->text();
}

QString Clipboard::text(QString &subtype) const
{
    return mClipboard->text(subtype);
}

void Clipboard::setText(const QString &val)
{
    mClipboard->setText(val);
}

QObject *Clipboard::create(QQmlEngine *engine, QJSEngine *scriptEngine)
{
    Q_UNUSED(engine);
    Q_UNUSED(scriptEngine);
    return new Clipboard();
}

void Clipboard::onChanged(QClipboard::Mode mode)
{
    if(mode == QClipboard::Clipboard)
        emit changed();
}

TabSeparated::TabSeparated(QObject *parent) : QObject(parent) {}

int TabSeparated::rows() const
{
    return mArray.size();
}

int TabSeparated::columns() const
{
    if(mArray.size() == 0)
        return 0;
    else
        return mArray[0].size();
}

void TabSeparated::setRows(int newRows)
{
    int clampedNewRows = std::max(newRows, 0);
    int deltaRows = clampedNewRows - rows();
    if(deltaRows < 0)
    {
        mArray.erase(mArray.begin() + clampedNewRows, mArray.end());
    }
    else if(deltaRows > 0)
    {
        QStringList blank;
        blank.reserve(columns());
        for(int i = 0, end = columns(); i < end; ++i)
            blank.append(QString());
        mArray.reserve(clampedNewRows);
        for(int i = 0, end = deltaRows; i < end; ++i)
            mArray.append(blank);
    }

    if(deltaRows != 0)
    {
        emit textChanged();
        emit rowsChanged();
    }
}

void TabSeparated::setColumns(int newColumns)
{
    int clampedNewColumns = std::max(newColumns, 0);
    int deltaColumns = clampedNewColumns - columns();

    if(deltaColumns < 0)
    {
        for(QStringList &arrayRow : mArray)
            arrayRow.erase(arrayRow.begin() + clampedNewColumns, arrayRow.end());
    }
    else if(deltaColumns > 0)
    {
        for(QStringList &arrayRow : mArray)
        {
            arrayRow.reserve(clampedNewColumns);
            for(int i = 0; i < deltaColumns; ++i)
                arrayRow.append(QString());
        }
    }

    if(deltaColumns != 0)
    {
        emit textChanged();
        emit columnsChanged();
    }
}

QVariant TabSeparated::get(int row, int column)
{
    if(row >= rows() || column >= columns())
        return QVariant();

    return mArray[row][column];
}

bool TabSeparated::set(int row, int column, QString value)
{
    if(row >= rows() || column >= columns())
        return false;

    if(updateDelta<>(mArray[row][column], value))
        emit textChanged();

    return true;
}

QString TabSeparated::text() const
{
    QString out;
    for(const QStringList &arrayRow : mArray)
    {
        out.append(arrayRow.join(QChar('\t')));
        out.append(QChar('\n'));
    }
    return out;
}

void TabSeparated::setText(QString newText)
{
    int oldRows = rows();
    int oldColumns = columns();

    mArray.clear();

    QStringList rowStrings = newText.split(QChar('\n'));
    mArray.reserve(rowStrings.length());

    int newColumns = 0;
    for(int i = 0; i < rowStrings.length(); ++i)
    {
        if(rowStrings[i].length() != 0 || i < rowStrings.length() - 1)
        {
            QStringList row = rowStrings[i].split(QChar('\t'));
            newColumns = std::max(newColumns, row.length());
            mArray.append(row);
        }
    }

    for(QStringList &arrayRow : mArray)
    {
        int fieldsDelta = newColumns - arrayRow.length();

        arrayRow.reserve(newColumns);
        for(int i = 0; i < fieldsDelta; ++i)
            arrayRow.append(QString());
    }
    emit textChanged();
    if(rows() != oldRows)
        emit rowsChanged();
    if(columns() != oldColumns)
        emit columnsChanged();
}

bool inRange(double val, double a, double b)
{
    if(a < b)
        return (val >= a) && (val <= b);
    else if(b < a)
        return (val >= b) && (val <= a);
    else
        return false;
}

bool inRange(QVariant val, QVariant a, QVariant b)
{
    if(a < b)
        return (val >= a) && (val <= b);
    else if(b < a)
        return (val >= b) && (val <= a);
    else
        return false;
}

ScopeExit::ScopeExit(std::function<void()> func) : mFunc(func)
{}
ScopeExit::~ScopeExit()
{
    mFunc();
}

const QString AppVersion::HASH = QString(GIT_VERSION);

QObject *AppVersion::create(QQmlEngine *engine, QJSEngine *scriptEngine)
{
    Q_UNUSED(engine);
    Q_UNUSED(scriptEngine);
    return new AppVersion();
}


}   // namespace SetupTools
