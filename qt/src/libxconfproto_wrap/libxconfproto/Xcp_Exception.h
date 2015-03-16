#ifndef XCP_EXCEPTION_H
#define XCP_EXCEPTION_H

#include <QException>
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

enum class OpResult {
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

#define RETURN_FAIL(a) { OpResult res; if((res = (a)) != OpResult::Success) return res; }

class LIBXCONFPROTOSHARED_EXPORT Exception : public QException {};

}
}

#endif // XCP_EXCEPTION_H
