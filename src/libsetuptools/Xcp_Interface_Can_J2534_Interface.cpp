#include "Xcp_Interface_Can_J2534_Interface.h"

namespace SetupTools {
namespace Xcp {
namespace Interface {
namespace Can {
namespace J2534 {

#ifdef J2534_INTFC

quint32 idFlags(Id id)
{
    return (id.type == Id::Type::Ext) ? quint32(Library::TxFlags::Can29BitId) : 0;
}

void setMessageId(Library::PassThruMessage & message, quint32 addr)
{
    message.data[0] = addr >> 24;
    message.data[1] = addr >> 16;
    message.data[2] = addr >> 8;
    message.data[3] = addr;
}

Interface::Interface(QObject *parent) :
    ::SetupTools::Xcp::Interface::Can::Interface(parent),
    mLibrary(),
    mDeviceId(),
    mChannelId(),
    mFilterId(),
    mFilter({0, Id::Type::Ext}, 0, true),
    mBitrate(500000)
{}

Interface::Interface(QString dllPath, QObject *parent) :
    ::SetupTools::Xcp::Interface::Can::Interface(parent),
    mLibrary(),
    mDeviceId(),
    mChannelId(),
    mFilterId(),
    mFilter({0, Id::Type::Ext}, 0, true),
    mBitrate(500000)
{
    setup(dllPath);
}

Interface::~Interface() {
    teardown();
    mLibrary.setDllPath("");
}

OpResult Interface::setup(QString dllPath)
{
    teardown();

    if(!mLibrary.setDllPath(dllPath))
        return OpResult::IntfcConfigError;

    Library::DeviceId devId;
    Library::Result result = mLibrary.open(nullptr, &devId);
    if(result != Library::Result::NoError)
    {
        qDebug() << mLibrary.lastErrorInfo(result);
        return OpResult::IntfcConfigError;
    }

    mDeviceId = devId;

    doSetFilterBitrate();

    return OpResult::Success;
}

OpResult Interface::teardown()
{
    if(mFilterId)
    {
        mLibrary.stopMsgFilter(mChannelId.get(), mFilterId.get());
        mFilterId.reset();
    }
    if(mChannelId)
    {
        mLibrary.disconnect(mChannelId.get());
        mChannelId.reset();
    }
    if(mDeviceId)
    {
        mLibrary.close(mDeviceId.get());
        mDeviceId.reset();
    }

    return OpResult::Success;
}

OpResult Interface::connect(SlaveId addr)
{
    if(!mDeviceId)
        return OpResult::InvalidOperation;

    mActiveFilter = ExactFilter(addr.res);
    OpResult res = doSetFilterBitrate();
    if(res == OpResult::Success)
    {
        mSlaveAddr = addr;
        emit slaveIdChanged();
        clearReceived();
        return OpResult::Success;
    }
    else
    {
        mSlaveAddr.reset();
        mActiveFilter.reset();
        emit slaveIdChanged();
        doSetFilterBitrate();
        return res;
    }
}

OpResult Interface::disconnect()
{
    if(!mDeviceId)
        return OpResult::InvalidOperation;
    mSlaveAddr.reset();
    mActiveFilter.reset();
    emit slaveIdChanged();
    return doSetFilterBitrate();
}

OpResult Interface::transmit(const std::vector<quint8> & data, bool replyExpected)
{
    if(!mDeviceId)
        return OpResult::InvalidOperation;
    Q_ASSERT(mSlaveAddr);
    return transmitTo(data, mSlaveAddr.get().cmd, replyExpected);
}

OpResult Interface::transmitTo(const std::vector<quint8> & data, Id id, bool replyExpected)
{
    Q_UNUSED(replyExpected);

    if(!mDeviceId || !mChannelId)
        return OpResult::InvalidOperation;

    if(data.size() > 8)
        return OpResult::InvalidArgument;

    Library::PassThruMessage message;
    message.protocolID = Library::ProtocolId::Can;
    message.txFlags = idFlags(id);
    message.dataSize = data.size() + 4;
    setMessageId(message, id.addr);
    std::copy(data.begin(), data.end(), message.data + 4);
    quint32 nMsgs = 1;

    if(mPacketLogEnabled)
    {
        Frame frame(id, data);
        qDebug() << QString(frame);
    }

    Library::Result result = mLibrary.writeMsgs(mChannelId.get(), &message, &nMsgs, SEND_TIMEOUT_MS);

    switch(result)
    {
    case Library::Result::NoError:
        if(nMsgs == 1)
            return OpResult::Success;
        else
        {
            qDebug() << "TX nMsgs" << nMsgs;
            return OpResult::IntfcUnexpectedResponse;
        }
    case Library::Result::ErrTimeout:
        return OpResult::Timeout;
    default:
        qDebug() << "TX failed, PassThru error" << int(result);
        return OpResult::IntfcIoError;
    }
}

OpResult Interface::setPacketLog(bool enable)
{
    mPacketLogEnabled = enable;
    return OpResult::Success;
}

OpResult Interface::receiveFrames(int timeoutMsec, std::vector<Frame> &out, const Filter filter, bool (*validator)(const Frame &))
{
    if(!mDeviceId || !mChannelId)
        return OpResult::InvalidOperation;

    if(timeoutMsec < 0)
        return OpResult::InvalidArgument;

    QElapsedTimer timer;
    timer.start();

    Library::Result result;

    do
    {
        int queueReadTimeout = std::max(timeoutMsec - int(timer.elapsed()), 0);

        Library::PassThruMessage msg;
        quint32 nMsgs = 1;

        result = mLibrary.readMsgs(mChannelId.get(), &msg, &nMsgs, queueReadTimeout);

        if(result != Library::Result::NoError && result != Library::Result::ErrTimeout && result != Library::Result::ErrBufferEmpty)
        {
            qDebug() << "RX failed, PassThru error" << int(result);
            return OpResult::IntfcIoError;
        }

        if(nMsgs > 1)
            return OpResult::IntfcUnexpectedResponse;

        if(msg.protocolID != Library::ProtocolId::Can || msg.dataSize < 4 || msg.dataSize > 12
                || (msg.rxStatus & Library::RxStatus::TxMsgType))
            continue;

        Frame frame;
        frame.id.addr = msg.data[0] << 24 | msg.data[1] << 16 | msg.data[2] << 8 | msg.data[3];
        frame.id.type = msg.rxStatus & Library::Can29BitId ? Id::Type::Ext : Id::Type::Std;
        frame.data.resize(msg.dataSize - 4);
        std::copy(msg.data + 4, msg.data + msg.dataSize, frame.data.data());

        if(filter.Matches(frame.id) && (!validator || validator(frame)))
        {
            out.push_back(frame);
            if(mPacketLogEnabled)
                qDebug() << QString(frame);
        }
    } while(timer.elapsed() <= timeoutMsec && !out.size());


    if(out.size() > 0)
        return OpResult::Success;
    else
        return OpResult::Timeout;

}

OpResult Interface::clearReceived()
{
    if(!mDeviceId || !mChannelId)
        return OpResult::InvalidOperation;
    Library::Result result = mLibrary.ioctl(mChannelId.get(), Library::IoctlId::ClearRXBuffer, nullptr, nullptr);
    if(result != Library::Result::NoError)
    {
        qDebug() << mLibrary.lastErrorInfo(result);
        return OpResult::IntfcConfigError;
    }
    return OpResult::Success;
}

OpResult Interface::setBitrate(int bps)
{
    mBitrate = bps;
    return doSetFilterBitrate();
}

OpResult Interface::setFilter(Filter filt)
{
    mFilter = filt;
    return doSetFilterBitrate();
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

OpResult Interface::doSetFilterBitrate()
{
    Library::Result result;

    if(mFilterId)
    {
        mLibrary.stopMsgFilter(mChannelId.get(), mFilterId.get());
        mFilterId.reset();
    }
    if(mChannelId)
    {
        mLibrary.disconnect(mChannelId.get());
        mChannelId.reset();
    }

    Filter & filter = mActiveFilter ? mActiveFilter.get() : mFilter;

    Library::ChannelId channelId;
    quint32 flags = filter.filt.type == Id::Type::Ext ? quint32(Library::TxFlags::Can29BitId) : 0;
    result = mLibrary.connect(mDeviceId.get(), Library::ProtocolId::Can, flags, mBitrate, &channelId);
    if(result != Library::Result::NoError)
    {
        qDebug() << mLibrary.lastErrorInfo(result);
        return OpResult::IntfcConfigError;
    }
    mChannelId = channelId;

    Q_ASSERT(filter.maskEff);
    Library::PassThruMessage patternMsg;
    patternMsg.protocolID = Library::ProtocolId::Can;
    patternMsg.txFlags = flags;
    patternMsg.dataSize = 4;
    setMessageId(patternMsg, filter.filt.addr);
    Library::PassThruMessage maskMsg;
    maskMsg.protocolID = Library::ProtocolId::Can;
    maskMsg.txFlags = Library::TxFlags::Can29BitId;
    maskMsg.dataSize = 4;
    setMessageId(maskMsg, filter.maskId);

    Library::MessageId filterId;
    result = mLibrary.startMsgFilter(channelId, Library::FilterType::Pass, &maskMsg, &patternMsg, nullptr, &filterId);
    if(result != Library::Result::NoError)
    {
        qDebug() << mLibrary.lastErrorInfo(result);
        return OpResult::IntfcConfigError;
    }
    mFilterId = filterId;

    mLibrary.ioctl(channelId, Library::IoctlId::ClearRXBuffer, nullptr, nullptr);

    return OpResult::Success;
}

QList<QUrl> Registry::avail()
{
    QList<QUrl> uris;

    QSettings passthru("HKEY_LOCAL_MACHINE\\SOFTWARE\\PassThruSupport.04.04", QSettings::NativeFormat);
    for(QString name : passthru.childGroups())
    {
        passthru.beginGroup(name);
        QString dllPath = passthru.value("FunctionLibrary").toString();
        passthru.endGroup();

        Library library;
        if(!library.setDllPath(dllPath))
            continue;

        // Check if it can actually be opened - this may or may not be a good idea,
        // if multiple devices of the same flavor are attached the user will get a dialog every time we refresh the menu
        // Unfortunately there is no "silently check if any device is present" function in the PassThru API
        Library::DeviceId deviceId;
        Library::Result openResult = library.open(nullptr, &deviceId);
        if(openResult != Library::Result::NoError)
            continue;
        library.close(deviceId);

        QUrl uri = QUrl::fromLocalFile(dllPath);
        uri.setScheme("j2534");
        QUrlQuery nameQuery;
        nameQuery.addQueryItem("name", name);
        uri.setQuery(nameQuery);
        uris.append(uri);
    }

    return uris;
}

Interface * Registry::make(QUrl uri)
{
    if(QString::compare(uri.scheme(), "j2534", Qt::CaseInsensitive) != 0)
        return nullptr;

    Interface *intfc = new Interface();
    uri.setScheme("file");  // needed for toLocalFile to work
    if(intfc->setup(uri.toLocalFile()) != OpResult::Success)
    {
        delete intfc;
        return NULL;
    }

    bool setBitrate = false;
    QUrlQuery uriQuery(uri.query());
    QString bitrateStr = uriQuery.queryItemValue("bitrate");
    int bitrate = bitrateStr.toInt(&setBitrate);
    if(setBitrate)
    {
        if(intfc->setBitrate(bitrate) != OpResult::Success)
        {
            delete intfc;
            return NULL;
        }
    }


    return intfc;
}

QString Registry::desc(QUrl uri)
{
    if(QString::compare(uri.scheme(), "j2534", Qt::CaseInsensitive) != 0)
        return QString("");

    QString name = QUrlQuery(uri.query()).queryItemValue("name");

    return QString("%1 (J2534)").arg(name);
}

#else /* J2534_INTFC */

Interface::Interface(QObject *parent) :
    ::SetupTools::Xcp::Interface::Can::Interface(parent)
{}

Interface::Interface(QString dllPath, QObject *parent) :
    ::SetupTools::Xcp::Interface::Can::Interface(parent)
{
    Q_UNUSED(dllPath);
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

OpResult Interface::setPacketLog(bool enable)
{
    Q_UNUSED(enable);
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
#endif /* J2534_INTFC */

} // namespace J2534
} // namespace Can
} // namespace Interface
} // namespace Xcp
} // namespace SetupTools

