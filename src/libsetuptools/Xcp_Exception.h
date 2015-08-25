#ifndef XCP_EXCEPTION_H
#define XCP_EXCEPTION_H

#include <QException>
#include <QObject>
#include <QQmlEngine>

#define EMIT_RETURN(signal, value, ...) { OpResult EMIT_RETURN__ret = (value); emit (signal)(EMIT_RETURN__ret, ##__VA_ARGS__); return EMIT_RETURN__ret; }
#define EMIT_RETURN_ON_FAIL(signal, value, ...) { OpResult EMIT_RETURN__ret = (value); if(EMIT_RETURN__ret != OpResult::Success) { emit (signal)(EMIT_RETURN__ret, ##__VA_ARGS__); return EMIT_RETURN__ret; } }
#define RETURN_ON_FAIL(value) { OpResult EMIT_RETURN__ret = (value); if(EMIT_RETURN__ret != OpResult::Success) { return EMIT_RETURN__ret; } }
#define EMIT_RETURN_VOID(signal, value, ...) { OpResult EMIT_RETURN__ret = (value); emit (signal)(EMIT_RETURN__ret, ##__VA_ARGS__); return; }
#define EMIT_RETURN_VOID_ON_FAIL(signal, value, ...) { OpResult EMIT_RETURN__ret = (value); if(EMIT_RETURN__ret != OpResult::Success) { emit (signal)(EMIT_RETURN__ret, ##__VA_ARGS__); return; } }
#define RETURN_VOID_ON_FAIL(value) { OpResult EMIT_RETURN__ret = (value); if(EMIT_RETURN__ret != OpResult::Success) { return; } }

namespace SetupTools
{
namespace Xcp
{

enum class OpResult {
    Success,
    _FAILURE_BEGIN,
    NoIntfc,
    NotConnected,
    WrongMode,
    IntfcConfigError,
    IntfcIoError,
    IntfcUnexpectedResponse,
    IntfcNoResponse,
    Timeout,
    InvalidOperation,
    InvalidArgument,
    BadReply,
    BadCksum,
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
    SlaveErrorUndefined,
    UnknownError,
    CorruptedFile,
    FileOpenFail,
    FileReadFail,
    FileWriteFail,
    _WARNING_BEGIN,
    WarnKeyLoadFailure
};

class OpResultWrapper : public QObject
{
    Q_OBJECT
    Q_ENUMS(OpResult)
public:
    enum OpResult
    {
        Success =                   static_cast<int>(SetupTools::Xcp::OpResult::Success),
        NoIntfc =                   static_cast<int>(SetupTools::Xcp::OpResult::NoIntfc),
        NotConnected =              static_cast<int>(SetupTools::Xcp::OpResult::NotConnected),
        WrongMode =                 static_cast<int>(SetupTools::Xcp::OpResult::WrongMode),
        IntfcConfigError =          static_cast<int>(SetupTools::Xcp::OpResult::IntfcConfigError),
        IntfcIoError =              static_cast<int>(SetupTools::Xcp::OpResult::IntfcIoError),
        IntfcUnexpectedResponse =   static_cast<int>(SetupTools::Xcp::OpResult::IntfcUnexpectedResponse),
        IntfcNoResponse =           static_cast<int>(SetupTools::Xcp::OpResult::IntfcNoResponse),
        Timeout =                   static_cast<int>(SetupTools::Xcp::OpResult::Timeout),
        InvalidOperation =          static_cast<int>(SetupTools::Xcp::OpResult::InvalidOperation),
        InvalidArgument =           static_cast<int>(SetupTools::Xcp::OpResult::InvalidArgument),
        BadReply =                  static_cast<int>(SetupTools::Xcp::OpResult::BadReply),
        BadCksum =                  static_cast<int>(SetupTools::Xcp::OpResult::BadCksum),
        PacketLost =                static_cast<int>(SetupTools::Xcp::OpResult::PacketLost),
        AddrGranError =             static_cast<int>(SetupTools::Xcp::OpResult::AddrGranError),
        MultipleReplies =           static_cast<int>(SetupTools::Xcp::OpResult::MultipleReplies),
        SlaveErrorBusy =            static_cast<int>(SetupTools::Xcp::OpResult::SlaveErrorBusy),
        SlaveErrorDaqActive =       static_cast<int>(SetupTools::Xcp::OpResult::SlaveErrorDaqActive),
        SlaveErrorPgmActive =       static_cast<int>(SetupTools::Xcp::OpResult::SlaveErrorPgmActive),
        SlaveErrorCmdUnknown =      static_cast<int>(SetupTools::Xcp::OpResult::SlaveErrorCmdUnknown),
        SlaveErrorCmdSyntax =       static_cast<int>(SetupTools::Xcp::OpResult::SlaveErrorCmdSyntax),
        SlaveErrorOutOfRange =      static_cast<int>(SetupTools::Xcp::OpResult::SlaveErrorOutOfRange),
        SlaveErrorWriteProtected =  static_cast<int>(SetupTools::Xcp::OpResult::SlaveErrorWriteProtected),
        SlaveErrorAccessDenied =    static_cast<int>(SetupTools::Xcp::OpResult::SlaveErrorAccessDenied),
        SlaveErrorAccessLocked =    static_cast<int>(SetupTools::Xcp::OpResult::SlaveErrorAccessLocked),
        SlaveErrorPageNotValid =    static_cast<int>(SetupTools::Xcp::OpResult::SlaveErrorPageNotValid),
        SlaveErrorModeNotValid =    static_cast<int>(SetupTools::Xcp::OpResult::SlaveErrorModeNotValid),
        SlaveErrorSegmentNotValid = static_cast<int>(SetupTools::Xcp::OpResult::SlaveErrorSegmentNotValid),
        SlaveErrorSequence =        static_cast<int>(SetupTools::Xcp::OpResult::SlaveErrorSequence),
        SlaveErrorDAQConfig =       static_cast<int>(SetupTools::Xcp::OpResult::SlaveErrorDAQConfig),
        SlaveErrorMemoryOverflow =  static_cast<int>(SetupTools::Xcp::OpResult::SlaveErrorMemoryOverflow),
        SlaveErrorGeneric =         static_cast<int>(SetupTools::Xcp::OpResult::SlaveErrorGeneric),
        SlaveErrorVerify =          static_cast<int>(SetupTools::Xcp::OpResult::SlaveErrorVerify),
        SlaveErrorUndefined =       static_cast<int>(SetupTools::Xcp::OpResult::SlaveErrorUndefined),
        UnknownError =              static_cast<int>(SetupTools::Xcp::OpResult::UnknownError),
        CorruptedFile =             static_cast<int>(SetupTools::Xcp::OpResult::CorruptedFile),
        FileOpenFail =              static_cast<int>(SetupTools::Xcp::OpResult::FileOpenFail),
        FileReadFail =              static_cast<int>(SetupTools::Xcp::OpResult::FileReadFail),
        FileWriteFail =             static_cast<int>(SetupTools::Xcp::OpResult::FileWriteFail),
        WarnKeyLoadFailure =        static_cast<int>(SetupTools::Xcp::OpResult::WarnKeyLoadFailure)
    };

    Q_INVOKABLE QString asString(int result);
    Q_INVOKABLE bool isOk(int result);
    Q_INVOKABLE bool isFailure(int result);
    Q_INVOKABLE bool isWarning(int result);

    static QObject *create(QQmlEngine *engine, QJSEngine *scriptEngine);
private:
    OpResultWrapper();
};

#define RETURN_FAIL(a) { OpResult res; if((res = (a)) != OpResult::Success) return res; }

class Exception : public QException {};

}
}

Q_DECLARE_METATYPE(SetupTools::Xcp::OpResult)
Q_DECLARE_METATYPE(SetupTools::Xcp::OpResultWrapper::OpResult)

#endif // XCP_EXCEPTION_H
