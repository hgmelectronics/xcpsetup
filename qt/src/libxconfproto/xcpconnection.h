#ifndef XCPCONNECTION_H
#define XCPCONNECTION_H

#include "libxconfproto_global.h"
#include "interface.h"

#include <QObject>
#include <QVector>
#include <QSharedPointer>

namespace SetupTools
{
namespace Xcp
{

class ConnException : public ::SetupTools::Xcp::Exception {};

class Timeout : public ConnException {};
class InvalidOperation : public ConnException {};
class BadReply : public ConnException {};
class PacketLost : public ConnException {};
class SlaveError : public ConnException {};

class SlaveErrorBusy : public SlaveError {};
class SlaveErrorDAQActive : public SlaveError {};
class SlaveErrorPgmActive : public SlaveError {};
class SlaveErrorCmdUnknown : public SlaveError {};
class SlaveErrorCmdSyntax : public SlaveError {};
class SlaveErrorOutOfRange : public SlaveError {};
class SlaveErrorWriteProtected : public SlaveError {};
class SlaveErrorAccessDenied : public SlaveError {};
class SlaveErrorAccessLocked : public SlaveError {};
class SlaveErrorPageNotValid : public SlaveError {};
class SlaveErrorModeNotValid : public SlaveError {};
class SlaveErrorSegmentNotValid : public SlaveError {};
class SlaveErrorSequence : public SlaveError {};
class SlaveErrorDAQConfig : public SlaveError {};
class SlaveErrorMemoryOverflow : public SlaveError {};
class SlaveErrorGeneric : public SlaveError {};
class SlaveErrorVerify : public SlaveError {};
class SlaveErrorUndefined : public SlaveError {};

class MultipleReplies : public ConnException {};

struct LIBXCONFPROTOSHARED_EXPORT XcpPtr
{
public:
    XcpPtr(u_int32_t addr_in = 0, u_int8_t ext_in = 0);
    u_int32_t addr;
    u_int8_t ext;
};

class LIBXCONFPROTOSHARED_EXPORT XcpConnection : public QObject
{
    Q_OBJECT
public:
    explicit XcpConnection(QSharedPointer<Interface::Interface> intfc, int timeoutMsec, int nvWriteTimeoutMsec = 0, QObject *parent = 0);
    void Close();
    QByteArray Upload(XcpPtr base, int len);
    void Download(XcpPtr base, const QByteArray &data);
    void NvWrite();
    void SetCalPage(quint8 segment, quint8 page);
    void ProgramStart();
    void ProgramClear(XcpPtr base, int len);
    void ProgramRange(XcpPtr base, const QVector<quint8> data);
    void ProgramVerify(quint32 crc);
    void ProgramReset();
signals:
public slots:
private:
    static void ThrowReply(const QList<QByteArray> &replies, const char *msg = NULL);
    QSharedPointer<Interface::Interface> mIntfc;
    int mTimeoutMsec, mNvWriteTimeoutMsec;
};

}   // namespace Xcp
}   // namespace SetupTools

#endif // XCPCONNECTION_H
