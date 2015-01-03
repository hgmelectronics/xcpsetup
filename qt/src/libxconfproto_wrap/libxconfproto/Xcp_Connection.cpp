#include "Xcp_Connection.h"

#include <string.h>

namespace SetupTools
{
namespace Xcp
{

XcpConnection::XcpConnection(QSharedPointer<Interface::Interface> intfc, int timeoutMsec, int nvWriteTimeoutMsec, QObject *parent) :
    QObject(parent),
    mIntfc(intfc)
{}

void XcpConnection::ThrowReply(const QList<QByteArray> &replies, const char *msg)
{
    typedef std::pair<QString, SlaveError> ErrCodeData;
    static const std::map<quint8, ErrCodeData> ERR_CODE_MAP =
    {
        {0x10, {"busy", SlaveErrorBusy()}},
        {0x11, {"DAQ active", SlaveErrorDaqActive()}},
        {0x12, {"program active", SlaveErrorPgmActive()}},
        {0x20, {"command unknown", SlaveErrorCmdUnknown()}},
        {0x21, {"command syntax invalid", SlaveErrorCmdSyntax()}},
        {0x22, {"parameter out of range", SlaveErrorOutOfRange()}},
        {0x23, {"write protected", SlaveErrorWriteProtected()}},
        {0x24, {"access denied", SlaveErrorAccessDenied()}},
        {0x25, {"access locked", SlaveErrorAccessLocked()}},
        {0x26, {"page invalid", SlaveErrorPageNotValid()}},
        {0x27, {"page mode invalid", SlaveErrorModeNotValid()}},
        {0x28, {"segment invalid", SlaveErrorSegmentNotValid()}},
        {0x29, {"sequence", SlaveErrorSequence()}},
        {0x2A, {"DAQ configuration invalid", SlaveErrorDAQConfig()}},
        {0x30, {"memory overflow", SlaveErrorMemoryOverflow()}},
        {0x31, {"generic", SlaveErrorGeneric()}},
        {0x32, {"program verify failed", SlaveErrorVerify()}}
    };
    static const ErrCodeData ERR_CODE_UNDEF = {"undefined error code", SlaveErrorUndefined()};
    char appendMsg[256];
    Q_ASSERT(replies.size() >= 1);
    Q_ASSERT(!msg || strlen(msg) < sizeof(appendMsg) - 2);
    if(msg) {
        strcpy(appendMsg, " ");
        strcat(appendMsg, msg);
    }
    else
        appendMsg[0] = '\0';

    if(replies.size() > 1)
    {
        qCritical("Multiple replies received%s", appendMsg);
        for(const QByteArray &reply : replies)
            qDebug() << "  " << reply.toHex();
        throw MultipleReplies();
    }

    if(replies[0].size() == 2 && quint8(replies[0][0]) == 0xFE)
    {
        // Look up message for error code, print to qCritical along with caller supplied message
        ErrCodeData codeData;
        typedef decltype(ERR_CODE_MAP) CodeMapType;
        CodeMapType::const_iterator itCodeData = ERR_CODE_MAP.find(quint8(replies[0][1]));
        if(itCodeData != ERR_CODE_MAP.end())
            codeData = itCodeData->second;
        else
            codeData = ERR_CODE_UNDEF;
        qCritical("Slave error: %s%s", reinterpret_cast<const char *>(codeData.first.constData()), appendMsg);

        // Throw appropriate exception for error code
        throw codeData.second;
    }
}

}   // namespace Xcp
}   // namespace SetupTools
