#include "Xcp_Interface_Can_Socket_Interface.h"

#ifdef SOCKETCAN

#include <sys/types.h>
#include <sys/socket.h>
#include <sys/ioctl.h>
#include <net/if.h>
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
    mSocket(-1)
{}

Interface::Interface(QString ifName, QObject *parent) :
    ::SetupTools::Xcp::Interface::Can::Interface(parent),
    mSocket(-1)
{
    setup(ifName);
}

Interface::~Interface() {
    if(mSocket >= 0)
        close(mSocket);
}

OpResult Interface::setup(QString ifName)
{
    QByteArray ifNameArray = ifName.toLocal8Bit();
    struct ifreq ifr;
    if(size_t(ifNameArray.size()) >= sizeof(ifr.ifr_name))
        return OpResult::InvalidArgument;
    std::copy(ifNameArray.data(), ifNameArray.data() + ifNameArray.size() + 1, ifr.ifr_name);

    mSocket = socket(AF_CAN, SOCK_RAW, CAN_RAW);
    if(mSocket < 0)
        return OpResult::IntfcConfigError;

    if(ioctl(mSocket, SIOCGIFINDEX, &ifr))
    {
        teardown();
        return OpResult::IntfcConfigError;
    }

    struct sockaddr_can intfcSockaddr = {0, 0, 0, 0};
    intfcSockaddr.can_family = AF_CAN;
    intfcSockaddr.can_ifindex = ifr.ifr_ifindex;

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
            qDebug() << "Error" << errno;
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

bool Interface::hasReliableTx()
{
    return true;
}

bool Interface::allowsMultipleReplies()
{
    return true;
}

int Interface::maxReplyTimeout()
{
    return std::numeric_limits<int>::max();
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
    if(fcntl(mSocket, F_SETFL, opts))
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

    QRegularExpression canIntfcRegex("[0-9]+: (can[0-9]+)[@:].*");
    QList<QString> ifNames;

    while(ipLinkProc.bytesAvailable())
    {
        QString line = QString::fromLocal8Bit(ipLinkProc.readLine(1024));
        QRegularExpressionMatch match = canIntfcRegex.match(line);
        if(match.hasMatch() && match.lastCapturedIndex() >= 1)
        {
            QStringRef ifNameRef = match.capturedRef(1);
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
    mSocket(-1)
{}

Interface::Interface(QString ifName, QObject *parent) :
    ::SetupTools::Xcp::Interface::Can::Interface(parent),
    mSocket(-1)
{
    Q_UNUSED(ifName);
}

Interface::~Interface() {
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
    Q_UNUSED(bps);
    return OpResult::InvalidOperation;
}

OpResult Interface::setFilter(Filter filt)
{
    Q_UNUSED(filt);
    return OpResult::InvalidOperation;
}

bool Interface::hasReliableTx()
{
    return true;
}
bool Interface::allowsMultipleReplies()
{
    return true;
}
int Interface::maxReplyTimeout()
{
    return std::numeric_limits<int>::max();
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
    Q_UNUSED(uri);
    return nullptr;
}

QString Registry::desc(QUrl uri)
{
    Q_UNUSED(uri);
    return QString("");
}

} // namespace Socket
} // namespace Can
} // namespace Interface
} // namespace Xcp
} // namespace SetupTools

#endif /* SOCKETCAN */
