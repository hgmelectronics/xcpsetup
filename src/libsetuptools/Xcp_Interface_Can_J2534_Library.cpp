#ifdef J2534_INTFC
#include "Xcp_Interface_Can_J2534_Library.h"
#include <QMap>
#include <QDebug>
#include "util.h"

namespace SetupTools
{
namespace Xcp
{
namespace Interface
{
namespace Can
{
namespace J2534
{

using namespace detail;

Library::Library() :
    mLibrary(),
    mCallTrace(false)
{
    clearPtrs();
}

bool Library::setDllPath(QString path)
{
    mLibrary.setFileName(path);

    if(!mLibrary.load())
    {
        clearPtrs();
        return false;
    }

    mOpenPtr = reinterpret_cast<PassThruOpen>(mLibrary.resolve("PassThruOpen"));
    mClosePtr = reinterpret_cast<PassThruClose>(mLibrary.resolve("PassThruClose"));
    mConnectPtr = reinterpret_cast<PassThruConnect>(mLibrary.resolve("PassThruConnect"));
    mDisconnectPtr = reinterpret_cast<PassThruDisconnect>(mLibrary.resolve("PassThruDisconnect"));
    mReadMsgsPtr = reinterpret_cast<PassThruReadMsgs>(mLibrary.resolve("PassThruReadMsgs"));
    mWriteMsgsPtr = reinterpret_cast<PassThruWriteMsgs>(mLibrary.resolve("PassThruWriteMsgs"));
    mStartPeriodicMsgPtr = reinterpret_cast<PassThruStartPeriodicMsg>(mLibrary.resolve("PassThruStartPeriodicMsg"));
    mStopPeriodicMsgPtr = reinterpret_cast<PassThruStopPeriodicMsg>(mLibrary.resolve("PassThruStopPeriodicMsg"));
    mStartMsgFilterPtr = reinterpret_cast<PassThruStartMsgFilter>(mLibrary.resolve("PassThruStartMsgFilter"));
    mStopMsgFilterPtr = reinterpret_cast<PassThruStopMsgFilter>(mLibrary.resolve("PassThruStopMsgFilter"));
    mSetProgrammingVoltagePtr = reinterpret_cast<PassThruSetProgrammingVoltage>(mLibrary.resolve("PassThruSetProgrammingVoltage"));
    mReadVersionPtr = reinterpret_cast<PassThruReadVersion>(mLibrary.resolve("PassThruReadVersion"));
    mGetLastErrorPtr = reinterpret_cast<PassThruGetLastError>(mLibrary.resolve("PassThruGetLastError"));
    mIoctlPtr = reinterpret_cast<PassThruIoctl>(mLibrary.resolve("PassThruIoctl"));

    return true;
}

void Library::setCallTrace(bool enabled)
{
    mCallTrace = enabled;
}

void printMsgs(QString prefix, const Library::PassThruMessage * pMsgs, quint32 numMsgs)
{
    for(quint32 i = 0; i < numMsgs; ++i)
    {
        const Library::PassThruMessage & msg = pMsgs[i];
        QString msgDataHexString = ToHexString(msg.data, msg.data + msg.dataSize);
        QString report = QString("%1%2 %3 %4 %5 [%6]").arg(prefix).arg(int(msg.protocolID)).arg(msg.rxStatus, 0, 16).arg(msg.txFlags, 0, 16).arg(msg.dataSize).arg(msgDataHexString);
        qDebug() << report.toStdString().c_str();
    }
}

Library::Result Library::open(const char * pName, DeviceId * deviceId)
{
    Result result = Result::ErrNotImplemented;
    if(mOpenPtr)
        result = Result(mOpenPtr(pName, deviceId));
    if(mCallTrace)
        qDebug() << "PassThruOpen(" << (pName ? pName : "nullptr") << ") ==" << int(result) << ", *pDeviceId == " << int(*deviceId);
    return result;
}

Library::Result Library::close(DeviceId deviceId)
{
    Result result = Result::ErrNotImplemented;
    if(mClosePtr)
        result = Result(mClosePtr(deviceId));
    if(mCallTrace)
        qDebug() << "PassThruClose(" << deviceId << ") ==" << int(result);
    return result;
}

Library::Result Library::connect(DeviceId deviceId, ProtocolId protocolId, quint32 flags, quint32 baudRate, ChannelId * pChannelId)
{
    Result result = Result::ErrNotImplemented;
    if(mConnectPtr)
        result = Result(mConnectPtr(deviceId, quint32(protocolId), flags, baudRate, pChannelId));
    if(mCallTrace)
        qDebug() << "PassThruConnect(" << int(deviceId) << "," << int(protocolId) << "," << flags << "," << baudRate << ") ==" << int(result) << ", *pChannelId == " << int(*pChannelId);
    return result;
}

Library::Result Library::disconnect(ChannelId channelId)
{
    Result result = Result::ErrNotImplemented;
    if(mDisconnectPtr)
        result = Result(mDisconnectPtr(channelId));
    if(mCallTrace)
        qDebug() << "PassThruDisconnect(" << channelId << ") ==" << int(result);
    return result;
}

Library::Result Library::readMsgs(ChannelId channelId, PassThruMessage * pMsg, quint32 * pNumMsgs, quint32 timeout)
{
    quint32 numMsgsAtEntry = *pNumMsgs;
    Result result = Result::ErrNotImplemented;
    if(mReadMsgsPtr)
        result = Result(mReadMsgsPtr(channelId, pMsg, pNumMsgs, timeout));
    if(mCallTrace)
    {
        qDebug() << "PassThruReadMsgs(" << channelId << ", pMsg ," << numMsgsAtEntry << ","  << timeout << ") ==" << int(result) << ", *pNumMsgs == " << *pNumMsgs;
        if(*pNumMsgs <= numMsgsAtEntry)  // sanity check
            printMsgs(" ", pMsg, *pNumMsgs);
    }

    return result;
}

Library::Result Library::writeMsgs(ChannelId channelId, PassThruMessage * pMsg, quint32 * pNumMsgs, quint32 timeout)
{
    quint32 numMsgsAtEntry = *pNumMsgs;
    Result result = Result::ErrNotImplemented;
    if(mWriteMsgsPtr)
        result = Result(mWriteMsgsPtr(channelId, pMsg, pNumMsgs, timeout));
    if(mCallTrace)
    {
        qDebug() << "PassThruWriteMsgs(" << channelId << ", pMsg ," << numMsgsAtEntry << "," << timeout << ") ==" << int(result) << ", *pNumMsgs == " << *pNumMsgs;
        printMsgs(" ", pMsg, numMsgsAtEntry);
    }
    return result;
}

Library::Result Library::startPeriodicMsg(ChannelId channelId, PassThruMessage * pMsg, MessageId * pMsgId, quint32 timeInterval)
{
    Result result = Result::ErrNotImplemented;
    if(mStartPeriodicMsgPtr)
        result = Result(mStartPeriodicMsgPtr(channelId, pMsg, pMsgId, timeInterval));
    if(mCallTrace)
    {
        qDebug() << "PassThruStartPeriodicMsg(" << channelId << ", pMsg, pMsgId ," << timeInterval << ") ==" << int(result) << ", *pMsgId == " << *pMsgId;
        printMsgs(" ", pMsg, 1);
    }
    return result;
}

Library::Result Library::stopPeriodicMsg(ChannelId channelId, MessageId msgId)
{
    Result result = Result::ErrNotImplemented;
    if(mStopPeriodicMsgPtr)
        result = Result(mStopPeriodicMsgPtr(channelId, msgId));
    if(mCallTrace)
        qDebug() << "PassThruStartPeriodicMsg(" << channelId << "," << msgId << ") ==" << int(result);
    return result;
}

Library::Result Library::startMsgFilter(ChannelId channelId, FilterType filterType, PassThruMessage * pMaskMsg,
                                        PassThruMessage * pPatternMsg, PassThruMessage * pFlowControlMsg, MessageId * pMsgId)
{
    Result result = Result::ErrNotImplemented;
    if(mStartMsgFilterPtr)
        result = Result(mStartMsgFilterPtr(channelId, quint32(filterType), pMaskMsg, pPatternMsg, pFlowControlMsg, pMsgId));
    if(mCallTrace)
    {
        qDebug() << "PassThruStartMsgFilter(" << channelId << ", pMaskMsg , pPatternMsg , pFlowControlMsg ," << quint32(filterType) << ") ==" << int(result) << ", *pMsgId == " << *pMsgId;
        printMsgs(" mask ", pMaskMsg, 1);
        printMsgs(" pattern ", pPatternMsg, 1);
    }
    return result;
}

Library::Result Library::stopMsgFilter(ChannelId channelId, MessageId msgId)
{
    Result result = Result::ErrNotImplemented;
    if(mStopMsgFilterPtr)
        result = Result(mStopMsgFilterPtr(channelId, msgId));
    if(mCallTrace)
        qDebug() << "PassThruStopMsgFilter(" << channelId << "," << msgId << ") ==" << int(result);
    return result;
}

Library::Result Library::setProgrammingVoltage(DeviceId deviceId, quint32 pinNumber, quint32 voltage)
{
    Result result = Result::ErrNotImplemented;
    if(mSetProgrammingVoltagePtr)
        result = Result(mSetProgrammingVoltagePtr(deviceId, pinNumber, voltage));
    if(mCallTrace)
        qDebug() << "PassThruSetProgrammingVoltage(" << deviceId << "," << pinNumber << "," << voltage << ") ==" << int(result);
    return result;
}

Library::Result Library::readVersion(DeviceId deviceId, char * pFirmwareVersion, char * pDllVersion, char * pApiVersion)
{
    Result result = Result::ErrNotImplemented;
    if(mReadVersionPtr)
        result = Result(mReadVersionPtr(deviceId, pFirmwareVersion, pDllVersion, pApiVersion));
    if(mCallTrace)
        qDebug() << "PassThruReadVersion(" << deviceId << ") ==" << int(result) << ", pFirmwareVersion ==" << pFirmwareVersion << ", pDllVersion ==" << pDllVersion << ", pApiVersion ==" << pApiVersion;
    return result;
}

Library::Result Library::getLastError(char * pErrorDescription)
{
    Result result = Result::ErrNotImplemented;
    if(mGetLastErrorPtr)
        result = Result(mGetLastErrorPtr(pErrorDescription));
    if(mCallTrace)
        qDebug() << "PassThruGetLastError() ==" << int(result) << ", pErrorDescription ==" << pErrorDescription;
    return result;
}

Library::Result Library::ioctl(quint32 handleId, quint32 ioctlId, void * pInput, void * pOutput)
{
    Result result = Result::ErrNotImplemented;
    if(mIoctlPtr)
        result = Result(mIoctlPtr(handleId, ioctlId, pInput, pOutput));
    if(mCallTrace)
        qDebug() << "PassThruIoctl(" << handleId << "," << ioctlId << ", pInput, pOutput" << ") ==" << int(result);
    return result;
}

static const QMap<Library::Result, QString> RESULT_STRINGS {
    { Library::Result::NoError, ("No error") },
    { Library::Result::ErrNotSupported, ("Function option is not supported") },
    { Library::Result::ErrInvalidChannelId, ("Channel Identifier or handle is not recognized") },
    { Library::Result::ErrInvalidProtocolId, ("Protocol Identifier is not recognized") },
    { Library::Result::ErrNullParameter, ("NULL pointer presented as a function parameter") },
    { Library::Result::ErrInvalidIoctl, ("Ioctl GET_CONFIG/SET_CONFIG parameter value is not recognized") },
    { Library::Result::ErrInvalidFlags, ("Flags bit field(s) contain(s) an invalid value") },
    { Library::Result::ErrFailed, ("Unspecified error, use PassThruGetLastError for obtaining error text string") },
    { Library::Result::ErrDeviceNotConnected, ("PassThru device is not connected to the PC") },
    { Library::Result::ErrTimeout, ("Timeout violation") },
    { Library::Result::ErrInvalidMsg, ("Message contained a min/max length, ExtraData support or J1850PWM specific source address conflict violation") },
    { Library::Result::ErrInvalidTimeInterval, ("The time interval value is outside the specified range") },
    { Library::Result::ErrExceededLimit, ("The limit of filter/periodic messages has been exceeded") },
    { Library::Result::ErrInvalidMsgId, ("The message identifier or handle is not recognized") },
    { Library::Result::ErrInvalidErrorId, ("Error ID not returned by any of the API functions") },
    { Library::Result::ErrInvalidIoctlId, ("Ioctl identifier is not recognized") },
    { Library::Result::ErrBufferEmpty, ("PassThru device could not read any messages from the vehicle network") },
    { Library::Result::ErrBufferFull, ("PassThru device could not queue any more transmit messages destined for the vehicle network") },
    { Library::Result::ErrBufferOverflow, ("PassThru device experienced a buffer overflow and receive messages were lost") },
    { Library::Result::ErrPinInvalid, ("Unknown pin number specified for the J1962 connector") },
    { Library::Result::ErrChannelInUse, ("An existing communications channel is currently using the specified network protocol") },
    { Library::Result::ErrMsgProtocolId, ("The specified protocol type within the message structure is different from the protocol associated with the communications channel when it was opened") },
    { Library::Result::ErrInvalidDeviceId, ("Intrepid error 26") },
    { Library::Result::ErrNotImplemented, ("Function not implemented in DLL") }
};

QString Library::lastErrorInfo(Result result)
{
    if(result == Result::ErrFailed)
    {
        char string[80] = "";
        Result getStringResult = getLastError(string);
        if(getStringResult == Result::NoError)
            return QString(string);
    }
    if(RESULT_STRINGS.contains(result))
        return RESULT_STRINGS[result];
    return ("Unknown error");
}

void Library::clearPtrs()
{
    mOpenPtr = nullptr;
    mClosePtr = nullptr;
    mConnectPtr = nullptr;
    mDisconnectPtr = nullptr;
    mReadMsgsPtr = nullptr;
    mWriteMsgsPtr = nullptr;
    mStartPeriodicMsgPtr = nullptr;
    mStopPeriodicMsgPtr = nullptr;
    mStartMsgFilterPtr = nullptr;
    mStopMsgFilterPtr = nullptr;
    mSetProgrammingVoltagePtr = nullptr;
    mReadVersionPtr = nullptr;
    mGetLastErrorPtr = nullptr;
    mIoctlPtr = nullptr;
}

}   // namespace J2534
}   // namespace Can
}   // namespace Interface
}   // namespace Xcp
}   // namespace SetupTools
#endif
