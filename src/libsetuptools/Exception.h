#ifndef EXCEPTION_H
#define EXCEPTION_H

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
        Success =                   static_cast<int>(SetupTools::OpResult::Success),
        NoIntfc =                   static_cast<int>(SetupTools::OpResult::NoIntfc),
        NotConnected =              static_cast<int>(SetupTools::OpResult::NotConnected),
        WrongMode =                 static_cast<int>(SetupTools::OpResult::WrongMode),
        IntfcConfigError =          static_cast<int>(SetupTools::OpResult::IntfcConfigError),
        IntfcIoError =              static_cast<int>(SetupTools::OpResult::IntfcIoError),
        IntfcUnexpectedResponse =   static_cast<int>(SetupTools::OpResult::IntfcUnexpectedResponse),
        IntfcNoResponse =           static_cast<int>(SetupTools::OpResult::IntfcNoResponse),
        Timeout =                   static_cast<int>(SetupTools::OpResult::Timeout),
        InvalidOperation =          static_cast<int>(SetupTools::OpResult::InvalidOperation),
        InvalidArgument =           static_cast<int>(SetupTools::OpResult::InvalidArgument),
        BadReply =                  static_cast<int>(SetupTools::OpResult::BadReply),
        BadCksum =                  static_cast<int>(SetupTools::OpResult::BadCksum),
        PacketLost =                static_cast<int>(SetupTools::OpResult::PacketLost),
        AddrGranError =             static_cast<int>(SetupTools::OpResult::AddrGranError),
        MultipleReplies =           static_cast<int>(SetupTools::OpResult::MultipleReplies),
        SlaveErrorBusy =            static_cast<int>(SetupTools::OpResult::SlaveErrorBusy),
        SlaveErrorDaqActive =       static_cast<int>(SetupTools::OpResult::SlaveErrorDaqActive),
        SlaveErrorPgmActive =       static_cast<int>(SetupTools::OpResult::SlaveErrorPgmActive),
        SlaveErrorCmdUnknown =      static_cast<int>(SetupTools::OpResult::SlaveErrorCmdUnknown),
        SlaveErrorCmdSyntax =       static_cast<int>(SetupTools::OpResult::SlaveErrorCmdSyntax),
        SlaveErrorOutOfRange =      static_cast<int>(SetupTools::OpResult::SlaveErrorOutOfRange),
        SlaveErrorWriteProtected =  static_cast<int>(SetupTools::OpResult::SlaveErrorWriteProtected),
        SlaveErrorAccessDenied =    static_cast<int>(SetupTools::OpResult::SlaveErrorAccessDenied),
        SlaveErrorAccessLocked =    static_cast<int>(SetupTools::OpResult::SlaveErrorAccessLocked),
        SlaveErrorPageNotValid =    static_cast<int>(SetupTools::OpResult::SlaveErrorPageNotValid),
        SlaveErrorModeNotValid =    static_cast<int>(SetupTools::OpResult::SlaveErrorModeNotValid),
        SlaveErrorSegmentNotValid = static_cast<int>(SetupTools::OpResult::SlaveErrorSegmentNotValid),
        SlaveErrorSequence =        static_cast<int>(SetupTools::OpResult::SlaveErrorSequence),
        SlaveErrorDAQConfig =       static_cast<int>(SetupTools::OpResult::SlaveErrorDAQConfig),
        SlaveErrorMemoryOverflow =  static_cast<int>(SetupTools::OpResult::SlaveErrorMemoryOverflow),
        SlaveErrorGeneric =         static_cast<int>(SetupTools::OpResult::SlaveErrorGeneric),
        SlaveErrorVerify =          static_cast<int>(SetupTools::OpResult::SlaveErrorVerify),
        SlaveErrorUndefined =       static_cast<int>(SetupTools::OpResult::SlaveErrorUndefined),
        UnknownError =              static_cast<int>(SetupTools::OpResult::UnknownError),
        CorruptedFile =             static_cast<int>(SetupTools::OpResult::CorruptedFile),
        FileOpenFail =              static_cast<int>(SetupTools::OpResult::FileOpenFail),
        FileReadFail =              static_cast<int>(SetupTools::OpResult::FileReadFail),
        FileWriteFail =             static_cast<int>(SetupTools::OpResult::FileWriteFail),
        WarnKeyLoadFailure =        static_cast<int>(SetupTools::OpResult::WarnKeyLoadFailure)
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

Q_DECLARE_METATYPE(SetupTools::OpResult)
Q_DECLARE_METATYPE(SetupTools::OpResultWrapper::OpResult)

#endif // EXCEPTION_H
