#ifndef XCP_EXCEPTION_H
#define XCP_EXCEPTION_H

#include <QException>
#include <QObject>
#include "libxconfproto_global.h"

#define EMIT_RETURN(signal, value) { OpResult EMIT_RETURN__ret = (value); emit (signal)(EMIT_RETURN__ret); return EMIT_RETURN__ret; }
#define EMIT_RETURN_ON_FAIL(signal, value) { OpResult EMIT_RETURN__ret = (value); if(EMIT_RETURN__ret != OpResult::Success) { emit (signal)(EMIT_RETURN__ret); return EMIT_RETURN__ret; } }
#define RETURN_ON_FAIL(value) { OpResult EMIT_RETURN__ret = (value); if(EMIT_RETURN__ret != OpResult::Success) { return EMIT_RETURN__ret; } }
#define EMIT_RETURN_VOID(signal, value) { OpResult EMIT_RETURN__ret = (value); emit (signal)(EMIT_RETURN__ret); return; }
#define EMIT_RETURN_VOID_ON_FAIL(signal, value) { OpResult EMIT_RETURN__ret = (value); if(EMIT_RETURN__ret != OpResult::Success) { emit (signal)(EMIT_RETURN__ret); return; } }
#define RETURN_VOID_ON_FAIL(value) { OpResult EMIT_RETURN__ret = (value); if(EMIT_RETURN__ret != OpResult::Success) { return; } }

namespace SetupTools
{
namespace Xcp
{

enum OpResult {
    Success,
    NoIntfc,
    NotConnected,
    WrongMode,
    IntfcConfigError,
    IntfcIoError,
    IntfcUnexpectedResponse,
    IntfcNoResponse,
    Timeout,
    InvalidOperation,
    BadReply,
    PacketLost,
    AddrGranError,
    MultipleReplies,
    SlaveErrorBusy,
    SlaveErrorDaqActive,
    SlaveErrorPgmActive,
    SlaveErrorCmdUnknown,
    SlaveErrorCmdSyntax,
    SlaveErrorOutOfRange,
    SlaveErrorWriteProtected,
    SlaveErrorAccessDenied,
    SlaveErrorAccessLocked,
    SlaveErrorPageNotValid,
    SlaveErrorModeNotValid,
    SlaveErrorSegmentNotValid,
    SlaveErrorSequence,
    SlaveErrorDAQConfig,
    SlaveErrorMemoryOverflow,
    SlaveErrorGeneric,
    SlaveErrorVerify,
    SlaveErrorUndefined
};

class OpResultWrapper : public QObject
{
    Q_OBJECT
    Q_ENUMS(OpResult)
public:
    enum OpResult
    {
        Success = Xcp::OpResult::Success,
        NoIntfc = Xcp::OpResult::NoIntfc,
        NotConnected = Xcp::OpResult::NotConnected,
        WrongMode = Xcp::OpResult::WrongMode,
        IntfcConfigError = Xcp::OpResult::IntfcConfigError,
        IntfcIoError = Xcp::OpResult::IntfcIoError,
        IntfcUnexpectedResponse = Xcp::OpResult::IntfcUnexpectedResponse,
        IntfcNoResponse = Xcp::OpResult::IntfcNoResponse,
        Timeout = Xcp::OpResult::Timeout,
        InvalidOperation = Xcp::OpResult::InvalidOperation,
        BadReply = Xcp::OpResult::BadReply,
        PacketLost = Xcp::OpResult::PacketLost,
        AddrGranError = Xcp::OpResult::AddrGranError,
        MultipleReplies = Xcp::OpResult::MultipleReplies,
        SlaveErrorBusy = Xcp::OpResult::SlaveErrorBusy,
        SlaveErrorDaqActive = Xcp::OpResult::SlaveErrorDaqActive,
        SlaveErrorPgmActive = Xcp::OpResult::SlaveErrorPgmActive,
        SlaveErrorCmdUnknown = Xcp::OpResult::SlaveErrorCmdUnknown,
        SlaveErrorCmdSyntax = Xcp::OpResult::SlaveErrorCmdSyntax,
        SlaveErrorOutOfRange = Xcp::OpResult::SlaveErrorOutOfRange,
        SlaveErrorWriteProtected = Xcp::OpResult::SlaveErrorWriteProtected,
        SlaveErrorAccessDenied = Xcp::OpResult::SlaveErrorAccessDenied,
        SlaveErrorAccessLocked = Xcp::OpResult::SlaveErrorAccessLocked,
        SlaveErrorPageNotValid = Xcp::OpResult::SlaveErrorPageNotValid,
        SlaveErrorModeNotValid = Xcp::OpResult::SlaveErrorModeNotValid,
        SlaveErrorSegmentNotValid = Xcp::OpResult::SlaveErrorSegmentNotValid,
        SlaveErrorSequence = Xcp::OpResult::SlaveErrorSequence,
        SlaveErrorDAQConfig = Xcp::OpResult::SlaveErrorDAQConfig,
        SlaveErrorMemoryOverflow = Xcp::OpResult::SlaveErrorMemoryOverflow,
        SlaveErrorGeneric = Xcp::OpResult::SlaveErrorGeneric,
        SlaveErrorVerify = Xcp::OpResult::SlaveErrorVerify,
        SlaveErrorUndefined = Xcp::OpResult::SlaveErrorUndefined
    };
};

#define RETURN_FAIL(a) { OpResult res; if((res = (a)) != OpResult::Success) return res; }

class LIBXCONFPROTOSHARED_EXPORT Exception : public QException {};

}
}

#endif // XCP_EXCEPTION_H
