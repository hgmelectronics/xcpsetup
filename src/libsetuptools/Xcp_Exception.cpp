#include "Xcp_Exception.h"

namespace SetupTools
{
    namespace Xcp
    {

        OpResultWrapper::OpResultWrapper()
        {

        }

        QObject *OpResultWrapper::create(QQmlEngine *engine, QJSEngine *scriptEngine)
        {
            Q_UNUSED(engine);
            Q_UNUSED(scriptEngine);
            return new OpResultWrapper();
        }

        QString OpResultWrapper::asString(int result)
        {
            switch(result) {
            case Success:                   return "Success";
            case NoIntfc:                   return "No interface";
            case NotConnected:              return "Not connected";
            case WrongMode:                 return "Wrong mode set";
            case IntfcConfigError:          return "Interface configuration error";
            case IntfcIoError:              return "Interface I/O error";
            case IntfcUnexpectedResponse:   return "Unexpected response from interface";
            case IntfcNoResponse:           return "No response from interface";
            case Timeout:                   return "Timeout";
            case InvalidOperation:          return "Invalid operation attempted";
            case InvalidArgument:           return "Invalid argument passed";
            case BadReply:                  return "Bad XCP reply";
            case BadCksum:                  return "Bad checksum";
            case PacketLost:                return "XCP packet lost";
            case AddrGranError:             return "Address granularity violation";
            case MultipleReplies:           return "Unexpected multiple replies";
            case SlaveErrorBusy:            return "Slave error: busy";
            case SlaveErrorDaqActive:       return "Slave error: DAQ mode active";
            case SlaveErrorPgmActive:       return "Slave error: program sequence active";
            case SlaveErrorCmdUnknown:      return "Slave error: command unknown";
            case SlaveErrorCmdSyntax:       return "Slave error: command syntax invalid";
            case SlaveErrorOutOfRange:      return "Slave error: parameter out of range";
            case SlaveErrorWriteProtected:  return "Slave error: write protected";
            case SlaveErrorAccessDenied:    return "Slave error: access denied";
            case SlaveErrorAccessLocked:    return "Slave error: access locked";
            case SlaveErrorPageNotValid:    return "Slave error: page not valid";
            case SlaveErrorModeNotValid:    return "Slave error: page mode not valid";
            case SlaveErrorSegmentNotValid: return "Slave error: page segment not valid";
            case SlaveErrorSequence:        return "Slave error: sequence violation";
            case SlaveErrorDAQConfig:       return "Slave error: DAQ configuration invalid";
            case SlaveErrorMemoryOverflow:  return "Slave error: memory overflow";
            case SlaveErrorGeneric:         return "Slave error: generic";
            case SlaveErrorVerify:          return "Slave error: verification failed";
            case SlaveErrorUndefined:       return "Slave error: undefined error";
            case UnknownError:              return "Unknown error";
            case CorruptedFile:             return "Corrupted file";
            case FileOpenFail:              return "Unable to open file";
            case FileReadFail:              return "Unable to read file";
            case FileWriteFail:             return "Unable to write file";
            case WarnKeyLoadFailure:        return "Some keys failed to load";
            default:                        return "Untranslated error";
            }
        }

        bool OpResultWrapper::isOk(int result)
        {
            return (result == Success);
        }

        bool OpResultWrapper::isFailure(int result)
        {
            return (result > static_cast<int>(SetupTools::Xcp::OpResult::_FAILURE_BEGIN)) && (result < static_cast<int>(SetupTools::Xcp::OpResult::_WARNING_BEGIN));
        }

        bool OpResultWrapper::isWarning(int result)
        {
            return (result > static_cast<int>(SetupTools::Xcp::OpResult::_WARNING_BEGIN));
        }
    }
}
