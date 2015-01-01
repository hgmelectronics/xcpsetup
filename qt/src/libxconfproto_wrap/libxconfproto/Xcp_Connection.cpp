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
        // Throw appropriate exception for error code
    }
}

}   // namespace Xcp
}   // namespace SetupTools
