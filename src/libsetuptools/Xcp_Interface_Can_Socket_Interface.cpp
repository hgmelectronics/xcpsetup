#include "Xcp_Interface_Can_Socket_Interface.h"

#ifdef SOCKETCAN

#include <sys/types.h>
#include <sys/socket.h>
#include <linux/can.h>
#include <linux/can/raw.h>
#include <unistd.h>
#include <fcntl.h>

namespace SetupTools {
namespace Xcp {
namespace Interface {
namespace Can {
namespace Socket {

Interface::Interface(QObject *parent) :
    ::SetupTools::Xcp::Interface::Can::Interface(parent),
    mSocket(-1),
    mPacketLog(false)
{}

Interface::Interface(QString ifName, QObject *parent) :
    ::SetupTools::Xcp::Interface::Can::Interface(parent),
    mSocket(-1),
    mPacketLog(false)
{
    setup(ifName);
}

Interface::~Interface() {
    if(mSocket >= 0)
        close(mSocket);
}

OpResult Interface::setup(QString ifName)
{
    struct sockaddr_can intfcSockaddr;
    memset(&intfcSockaddr, 0, sizeof(intfcSockaddr));
    {
        static const QString PREFIX = "can";
        if(!ifName.startsWith(PREFIX))
            return OpResult::InvalidArgument;
        bool indexOk = false;
        intfcSockaddr.can_ifindex = ifName.right(ifName.length() - PREFIX.length()).toInt(&indexOk);
        if(!indexOk)
            return OpResult::InvalidArgument;
    }

    mSocket = socket(AF_CAN, SOCK_RAW, CAN_RAW);
    if(mSocket < 0)
        return OpResult::IntfcConfigError;

    struct timeval timeout;
    timeout.tv_sec = 0;
    timeout.tv_usec = SEND_TIMEOUT_US;
    if(setsockopt(mSocket, SOL_SOCKET, SO_SNDTIMEO, &timeout, sizeof(timeout)))
    {
        teardown();
        return OpResult::IntfcConfigError;
    }

    if(bind(mSocket, reinterpret_cast<const struct sockaddr *>(&intfcSockaddr), sizeof(intfcSockaddr)))
    {
        teardown();
        return OpResult::IntfcConfigError;
    }

    return OpResult::Success;
}

OpResult Interface::teardown()
{
    if(mSocket >= 0)
    {
        close(mSocket);
        mSocket = -1;
    }
    return OpResult::Success;
}

OpResult Interface::connect(SlaveId addr)
{
    if(mSocket < 0)
        return OpResult::InvalidOperation;
    OpResult res = doSetFilter(ExactFilter(addr.res));
    if(res == OpResult::Success)
    {
        mSlaveAddr = addr;
        clearReceived();
        return OpResult::Success;
    }
    else
    {
        mSlaveAddr.reset();
        return res;
    }
}

OpResult Interface::disconnect()
{
    if(mSocket < 0)
        return OpResult::InvalidOperation;
    mSlaveAddr.reset();
    return doSetFilter(mFilter);
}

OpResult Interface::transmit(const std::vector<quint8> & data, bool replyExpected)
{
    if(mSocket < 0)
        return OpResult::InvalidOperation;
    Q_ASSERT(mSlaveAddr);
    return transmitTo(data, mSlaveAddr.get().cmd, replyExpected);
}

OpResult Interface::transmitTo(const std::vector<quint8> & data, Id id, bool replyExpected)
{
    Q_UNUSED(replyExpected);
    if(mSocket < 0)
        return OpResult::InvalidOperation;

    if(data.size() > 8)
        return OpResult::InvalidArgument;

    struct can_frame frame;
    memset(&frame, 0, sizeof(frame));
    frame.can_id = id.addr | (id.type == Id::Type::Ext ? CAN_EFF_FLAG : 0);
    frame.can_dlc = data.size();
    std::copy(data.begin(), data.end(), frame.data);

    while(1)
    {
        int nbytes = write(mSocket, &frame, sizeof(frame));
        if(nbytes >= 0)
        {
            if(mPacketLogEnabled)
            {
                Frame logFrame;
                logFrame.data = data;
                logFrame.id = id;
                qDebug() << QString(logFrame);
            }
            return OpResult::Success;
        }
        else if(errno != ENOBUFS)
        {
            return OpResult::IntfcIoError;
        }
        else
        {
            QThread::usleep(ENOBUFS_WAIT_US);
        }
    }
}

OpResult Interface::receiveFrames(int timeoutMsec, std::vector<Frame> &out, const Filter filter, bool (*validator)(const Frame &))
{
    if(mSocket < 0)
        return OpResult::InvalidOperation;

    if(timeoutMsec < 0)
        return OpResult::InvalidArgument;

    int totalUsec = timeoutMsec * 1000;
    QElapsedTimer timer;
    timer.start();

    quint32 nReceived = 0;
    while(1)
    {
        int remainingUsec = totalUsec - int(timer.nsecsElapsed() / 1000);
        quint32 timeoutThisRead;
        if(remainingUsec < 0 || nReceived > 0)
            timeoutThisRead = 0;
        else
            timeoutThisRead = quint32(remainingUsec);
        RETURN_FAIL(setRxTimeout(timeoutThisRead));

        struct can_frame rawFrame;
        if(read(mSocket, &rawFrame, sizeof(rawFrame)) >= 0)
        {
            Frame frame;
            frame.id.addr = rawFrame.can_id & CAN_EFF_MASK;
            frame.id.type = (rawFrame.can_id & CAN_EFF_FLAG) ? Id::Type::Ext : Id::Type::Std;
            frame.data.resize(rawFrame.can_dlc);
            std::copy(rawFrame.data, rawFrame.data + rawFrame.can_dlc, frame.data.begin());
            if(filter.Matches(frame.id) && (!validator || validator(frame)))
            {
                out.push_back(frame);
                ++nReceived;
                if(mPacketLogEnabled)
                    qDebug() << QString(frame);
            }
        }
        else
        {
            if(errno == ETIMEDOUT || errno == EAGAIN || errno == EWOULDBLOCK)
                break;
            else
                return OpResult::IntfcIoError;
        }
    }

    if(nReceived)
        return OpResult::Success;
    else
        return OpResult::Timeout;
}

OpResult Interface::clearReceived()
{
    if(mSocket < 0)
        return OpResult::InvalidOperation;

    RETURN_FAIL(setRxTimeout(0));

    while(1)
    {
        struct can_frame bitbucket;
        int nbytes = read(mSocket, &bitbucket, sizeof(bitbucket));
        if(nbytes < 0)
            break;
    }
    return OpResult::Success;
}

OpResult Interface::setBitrate(int bps)
{
    qDebug() << QString("Setting bitrate is presently not supported on SocketCAN. Use \"ip link set canN up type can bitrate %1\"").arg(bps);
    return OpResult::InvalidOperation;
}

OpResult Interface::setFilter(Filter filt)
{
    mFilter = filt;
    return doSetFilter(filt);
}

OpResult Interface::setPacketLog(bool enable)
{
    mPacketLogEnabled = enable;
    return OpResult::Success;
}

bool Interface::hasReliableTx()
{
    return true;
}

OpResult Interface::doSetFilter(const Filter & filter)
{
    if(mSocket < 0)
        return OpResult::InvalidOperation;

    struct can_filter filterStruct;
    filterStruct.can_id = filter.filt.addr | (filter.filt.type == Id::Type::Ext ? CAN_EFF_FLAG : 0);
    filterStruct.can_mask = filter.maskId | (filter.maskEff ? CAN_EFF_FLAG : 0);

    if(setsockopt(mSocket, SOL_CAN_RAW, CAN_RAW_FILTER, &filterStruct, sizeof(filterStruct)))
        return OpResult::IntfcIoError;

    return OpResult::Success;
}

OpResult Interface::setRxTimeout(quint32 usec)
{
    if(mSocket < 0)
        return OpResult::InvalidOperation;

    int opts = fcntl(mSocket, F_GETFL);
    if(opts < 0)
        return OpResult::IntfcConfigError;

    if(usec == 0)
    {
        opts |= O_NONBLOCK;
    }
    else
    {
        opts &= ~O_NONBLOCK;
        struct timeval timeout;
        timeout.tv_sec = usec / 1000000;
        timeout.tv_usec = usec - (timeout.tv_sec * 1000000);
        if(setsockopt(mSocket, SOL_SOCKET, SO_RCVTIMEO, &timeout, sizeof(timeout)))
            return OpResult::IntfcConfigError;
    }
    if(fcntl(mSocket, F_SETFL, O_NONBLOCK))
        return OpResult::IntfcConfigError;
    return OpResult::Success;
}

QStringList getIntfcsAvail()
{
    QProcess ipLinkProc;
    ipLinkProc.start("/bin/ip", QStringList() << "link" << "show" << "up");
    ipLinkProc.waitForFinished(1000);
    if(ipLinkProc.exitStatus() != QProcess::NormalExit || ipLinkProc.exitCode() != 0)
        return QStringList();

    QRegularExpression canIntfcRegex("[0-9]+: (can[0-9]+):.*");
    QList<QString> ifNames;

    while(ipLinkProc.bytesAvailable())
    {
        QString line = QString::fromLocal8Bit(ipLinkProc.readLine(1024));
        QRegularExpressionMatch match = canIntfcRegex.match(line);
        if(match.hasMatch())
        {
            QStringRef ifNameRef = match.capturedRef(0);
            if(!ifNameRef.isNull() && ifNameRef.size() >= 4)
                ifNames.append(ifNameRef.toString());
        }
    }

    return ifNames;
}

QList<QUrl> Registry::avail()
{
    QList<QUrl> uris;
    for(QString ifName : getIntfcsAvail())
        uris.append(QString("socketcan:%1").arg(ifName));
    return uris;
}

Interface *Registry::make(QUrl uri)
{
    if(QString::compare(uri.scheme(), "socketcan", Qt::CaseInsensitive) != 0)
        return nullptr;

    Interface *intfc = new Interface();
    if(intfc->setup(uri.path()) != OpResult::Success)
    {
        delete intfc;
        return NULL;
    }

    return intfc;
}

QString Registry::desc(QUrl uri)
{
    if(QString::compare(uri.scheme(), "socketcan", Qt::CaseInsensitive) != 0)
        return QString("");

    return QString("SocketCAN interface %1").arg(uri.path());
}

} // namespace Socket
} // namespace Can
} // namespace Interface
} // namespace Xcp
} // namespace SetupTools

#else /* SOCKETCAN */

namespace SetupTools {
namespace Xcp {
namespace Interface {
namespace Can {
namespace Socket {

Interface::Interface(QObject *parent) :
    ::SetupTools::Xcp::Interface::Can::Interface(parent),
    mSocket(-1),
    mPacketLog(false)
{}

Interface::Interface(QString ifName, QObject *parent) :
    ::SetupTools::Xcp::Interface::Can::Interface(parent),
    mSocket(-1),
    mPacketLog(false)
{}

Interface::~Interface() {
    if(mSocket >= 0)
        close(mSocket);
}

OpResult Interface::setup(QString ifName)
{
    Q_UNUSED(ifName);
    return OpResult::InvalidOperation;
}

OpResult Interface::teardown()
{
    return OpResult::InvalidOperation;
}

OpResult Interface::connect(SlaveId addr)
{
    Q_UNUSED(addr);
    return OpResult::InvalidOperation;
}

OpResult Interface::disconnect()
{
    return OpResult::InvalidOperation;
}

OpResult Interface::transmit(const std::vector<quint8> & data, bool replyExpected)
{
    Q_UNUSED(data);
    Q_UNUSED(replyExpected);
    return OpResult::InvalidOperation;
}

OpResult Interface::transmitTo(const std::vector<quint8> & data, Id id, bool replyExpected)
{
    Q_UNUSED(data);
    Q_UNUSED(id);
    Q_UNUSED(replyExpected);
    return OpResult::InvalidOperation;
}

OpResult Interface::receiveFrames(int timeoutMsec, std::vector<Frame> &out, const Filter filter, bool (*validator)(const Frame &))
{
    Q_UNUSED(timeoutMsec);
    Q_UNUSED(out);
    Q_UNUSED(filter);
    Q_UNUSED(validator);
    return OpResult::InvalidOperation;
}

OpResult Interface::clearReceived()
{
    return OpResult::InvalidOperation;
}

OpResult Interface::setBitrate(int bps)
{
    return OpResult::InvalidOperation;
}

OpResult Interface::setFilter(Filter filt)
{
    Q_UNUSED(filt);
    return OpResult::InvalidOperation;
}

OpResult Interface::setPacketLog(bool enable)
{
    Q_UNUSED(enable);
    return OpResult::InvalidOperation;
}

bool Interface::hasReliableTx()
{
    return false;
}

OpResult Interface::doSetFilter(const Filter & filter)
{
    Q_UNUSED(filter);
    return OpResult::InvalidOperation;
}

QList<QUrl> Registry::avail()
{
    return QList<QUrl>();
}

Interface *Registry::make(QUrl uri)
{
    return nullptr;
}

QString Registry::desc(QUrl uri)
{
    return QString("");
}

} // namespace Socket
} // namespace Can
} // namespace Interface
} // namespace Xcp
} // namespace SetupTools

#endif /* SOCKETCAN */
