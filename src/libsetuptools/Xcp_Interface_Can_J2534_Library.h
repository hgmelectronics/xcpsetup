#ifndef J2534LIBRARY_H
#define J2534LIBRARY_H

#ifdef J2534_INTFC
#include <QString>
#include <QLibrary>

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

namespace detail
{
extern "C" typedef quint32  __attribute__((__stdcall__)) (* PassThruOpen)(const char * pName, quint32 * pDeviceId);
extern "C" typedef quint32  __attribute__((__stdcall__)) (* PassThruClose)(quint32 deviceId);
extern "C" typedef quint32  __attribute__((__stdcall__)) (* PassThruConnect)(quint32 deviceId, quint32 protocolId, quint32 flags, quint32 baudRate, quint32 * pChannelId) __attribute__((__stdcall__));
extern "C" typedef quint32  __attribute__((__stdcall__)) (* PassThruDisconnect)(quint32 channelId) __attribute__((__stdcall__));
extern "C" typedef quint32  __attribute__((__stdcall__)) (* PassThruReadMsgs)(quint32 channelId, void * pMsg, quint32 * pNumMsgs, quint32 timeout) __attribute__((__stdcall__));
extern "C" typedef quint32  __attribute__((__stdcall__)) (* PassThruWriteMsgs)(quint32 channelId, void * pMsg, quint32 * pNumMsgs, quint32 timeout) __attribute__((__stdcall__));
extern "C" typedef quint32  __attribute__((__stdcall__)) (* PassThruStartPeriodicMsg)(quint32 channelId, void * pMsg, quint32 * pMsgId, quint32 timeInterval) __attribute__((__stdcall__));
extern "C" typedef quint32  __attribute__((__stdcall__)) (* PassThruStopPeriodicMsg)(quint32 channelId, quint32 msgId) __attribute__((__stdcall__));
extern "C" typedef quint32  __attribute__((__stdcall__)) (* PassThruStartMsgFilter)(quint32 channelId, quint32 filterType, void * pMaskMsg,
                                          void * pPatternMsg, void * pFlowControlMsg, quint32 * pMsgId) __attribute__((__stdcall__));
extern "C" typedef quint32  __attribute__((__stdcall__)) (* PassThruStopMsgFilter)(quint32 channelId, quint32 msgId) __attribute__((__stdcall__));
extern "C" typedef quint32  __attribute__((__stdcall__)) (* PassThruSetProgrammingVoltage)(quint32 deviceId, quint32 pinNumber, quint32 voltage) __attribute__((__stdcall__));
extern "C" typedef quint32  __attribute__((__stdcall__)) (* PassThruReadVersion)(quint32 deviceId, char * pFirmwareVersion, char * pDllVersion, char * pApiVersion) __attribute__((__stdcall__));
extern "C" typedef quint32  __attribute__((__stdcall__)) (* PassThruGetLastError)(char * pErrorDescription) __attribute__((__stdcall__));
extern "C" typedef quint32  __attribute__((__stdcall__)) (* PassThruIoctl)(quint32 handleId, quint32 ioctlId, void * pInput, void * pOutput) __attribute__((__stdcall__));
}
// PassThru DLL API
class Library
{
public:
    enum class ProtocolId : quint32
    {
        J1850Vpw                = 1,
        J1850Pwm                = 2,
        Iso9141                 = 3,
        Iso14230                = 4,
        Can                     = 5,
        Iso15765                = 6,
        SciAEngine              = 7,
        SciATrans               = 8,
        SciBEngine              = 9,
        SciBTrans               = 10,
    };
    enum class FilterType : quint32
    {
        Pass                    = 1,
        Block                   = 2,
        FlowControl             = 3,
    };
    enum IoctlId : quint32
    {
        GetConfig               = 0x00000001,
        SetConfig               = 0x00000002,
        ReadVbatt               = 0x00000003,
        ReadProgVoltage         = 0x0000000E,
        FiveBaudInit            = 0x00000004,
        FastInit                = 0x00000005,
        ClearTXBuffer           = 0x00000007,
        ClearRXBuffer           = 0x00000008,
        ClearPeriodicMsgs       = 0x00000009,
        ClearMsgFilters         = 0x0000000A,
        ClearFunctMsgLookupTable        = 0x0000000B,
        AddToFunctMsgLookupTable        = 0x0000000C,
        DeleteFromFunctMsgLookupTable   = 0x0000000D,
    };
    enum class Result : qint32
    {
        NoError                 = 0x00000000,
        ErrNotSupported         = 0x00000001,
        ErrInvalidChannelId     = 0x00000002,
        ErrInvalidProtocolId    = 0x00000003,
        ErrNullParameter        = 0x00000004,
        ErrInvalidIoctl         = 0x00000005,
        ErrInvalidFlags         = 0x00000006,
        ErrFailed               = 0x00000007,
        ErrDeviceNotConnected   = 0x00000008,
        ErrTimeout              = 0x00000009,
        ErrInvalidMsg           = 0x0000000A,
        ErrInvalidTimeInterval  = 0x0000000B,
        ErrExceededLimit        = 0x0000000C,
        ErrInvalidMsgId         = 0x0000000D,
        ErrInvalidErrorId       = 0x0000000E,
        ErrInvalidIoctlId       = 0x0000000F,
        ErrBufferEmpty          = 0x00000010,
        ErrBufferFull           = 0x00000011,
        ErrBufferOverflow       = 0x00000012,
        ErrPinInvalid           = 0x00000013,
        ErrChannelInUse         = 0x00000014,
        ErrMsgProtocolId        = 0x00000015,
        ErrInvalidDeviceId      = 0x0000001A,   // not standard - observed from Intrepid Control Systems DLLs
        ErrNotImplemented       = 0x7FFFFFFF,   // not standard - indicates DLL does not implement function
    };
    enum RxStatus : quint32
    {
        TxMsgType               = 0x00000001,
        Iso15765FirstFrame      = 0x00000002,
        RxBreak                 = 0x00000004,
        Iso15765TxDone          = 0x00000008,
    };
    enum TxFlags : quint32
    {
        Normal                  = 0x00000000,
        Iso15765FramePad        = 0x00000040,
        Iso15765ExtAddr         = 0x00000080,
        Can29BitId              = 0x00000100,
        TxBlocking              = 0x00010000,
        SciTxVoltage            = 0x00800000,
    };

    using DeviceId = quint32;
    using ChannelId = quint32;
    using MessageId = quint32;
    struct PassThruMessage
    {
        PassThruMessage()
        {
            memset(this, 0, sizeof(*this));
        }

        ProtocolId protocolID;
        quint32 rxStatus;
        quint32 txFlags;
        quint32 timestamp;
        quint32 dataSize;
        quint32 extraDataIndex;
        quint8 data[4128];
    };
    struct PassThruConfig
    {
        quint32 parameter;
        quint32 value;
    };
    struct PassThruConfigList
    {
        quint32 numOfParams;
        PassThruConfig *configPtr;
    };
    struct PassThruByteArray
    {
        quint32 numOfBytes;
        quint8 *bytePtr;
    };

    Library();
    bool setDllPath(QString path);
    void setCallTrace(bool enabled);

    // Bindings for DLL functions. Without force_align_arg_pointer, crashes when using Intrepid DLLs (which increment esp by 8 across the call)
    Result open(const char * pName, DeviceId * pDeviceId);
    Result close(DeviceId deviceId);
    Result connect(DeviceId deviceId, ProtocolId protocolId, quint32 flags, quint32 baudRate, ChannelId * pChannelId);
    Result disconnect(ChannelId channelId);
    Result readMsgs(ChannelId channelId, PassThruMessage * pMsg, quint32 * pNumMsgs, quint32 timeout);
    Result writeMsgs(ChannelId channelId, PassThruMessage * pMsg, quint32 * pNumMsgs, quint32 timeout);
    Result startPeriodicMsg(ChannelId channelId, PassThruMessage * pMsg, MessageId * pMsgId, quint32 timeInterval);
    Result stopPeriodicMsg(ChannelId channelId, MessageId msgId);
    Result startMsgFilter(ChannelId channelId, FilterType filterType, PassThruMessage * pMaskMsg,
                          PassThruMessage * pPatternMsg, PassThruMessage * pFlowControlMsg, MessageId * pMsgId);
    Result stopMsgFilter(ChannelId channelId, MessageId msgId);
    Result setProgrammingVoltage(DeviceId deviceId, quint32 pinNumber, quint32 voltage);
    Result readVersion(DeviceId deviceId, char * pFirmwareVersion, char * pDllVersion, char * pApiVersion);
    Result getLastError(char * pErrorDescription);
    Result ioctl(quint32 handleId, quint32 ioctlId, void * pInput, void * pOutput);

    QString lastErrorInfo(Result result);
private:
    void clearPtrs();

    QLibrary mLibrary;
    detail::PassThruOpen mOpenPtr;
    detail::PassThruClose mClosePtr;
    detail::PassThruConnect mConnectPtr;
    detail::PassThruDisconnect mDisconnectPtr;
    detail::PassThruReadMsgs mReadMsgsPtr;
    detail::PassThruWriteMsgs mWriteMsgsPtr;
    detail::PassThruStartPeriodicMsg mStartPeriodicMsgPtr;
    detail::PassThruStopPeriodicMsg mStopPeriodicMsgPtr;
    detail::PassThruStartMsgFilter mStartMsgFilterPtr;
    detail::PassThruStopMsgFilter mStopMsgFilterPtr;
    detail::PassThruSetProgrammingVoltage mSetProgrammingVoltagePtr;
    detail::PassThruReadVersion mReadVersionPtr;
    detail::PassThruGetLastError mGetLastErrorPtr;
    detail::PassThruIoctl mIoctlPtr;
    bool mCallTrace;
};

}   // namespace J2534
}   // namespace Can
}   // namespace Interface
}   // namespace Xcp
}   // namespace SetupTools

#endif
#endif // J2534LIBRARY_H
