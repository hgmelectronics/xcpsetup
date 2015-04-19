#ifndef SETUPTOOLS_XCP_PROGRAMLAYER_H
#define SETUPTOOLS_XCP_PROGRAMLAYER_H

#include <QObject>
#include "libxconfproto_global.h"
#include "Xcp_ConnectionFacade.h"
#include "FlashProg.h"

namespace SetupTools {
namespace Xcp {

class LIBXCONFPROTOSHARED_EXPORT ProgramLayer : public QObject
{
    Q_OBJECT
    Q_PROPERTY(QString intfcUri READ intfcUri WRITE setIntfcUri)
    Q_PROPERTY(QString slaveId READ slaveId WRITE setSlaveId)
    Q_PROPERTY(ConnectionFacade *conn READ conn)
public:
    explicit ProgramLayer(QObject *parent = 0);
    virtual ~ProgramLayer();

    QString intfcUri(void);
    void setIntfcUri(QString);
    QString slaveId();
    void setSlaveId(QString);
    ConnectionFacade *conn();
signals:
    void programDone(OpResult result, FlashProg *prog, quint8 addrExt);
    void programVerifyDone(OpResult result, FlashProg *prog, CksumType type, quint8 addrExt);
    void buildChecksumVerifyDone(OpResult result, FlashProg *prog, quint8 addrExt, CksumType type = CksumType::Invalid, quint32 cksum = 0);
    void programResetDone(OpResult result);
public slots:
    void program(FlashProg *prog, quint8 addrExt = 0);
    void programVerify(FlashProg *prog, CksumType type, quint8 addrExt = 0);    // For bootloaders that need PROGRAM_VERIFY to finish their flash write
    void buildChecksumVerify(FlashProg *prog, quint8 addrExt = 0);
    void programReset();

    void onConnSetStateDone(OpResult result);
    void onConnProgramClearDone(OpResult result, XcpPtr base, int len);
    void onConnProgramRangeDone(OpResult result, XcpPtr base, std::vector<quint8> data);
    void onConnProgramVerifyDone(OpResult result, XcpPtr mta, quint32 crc);
    void onConnBuildChecksumDone(OpResult result, XcpPtr base, int len, CksumType type, quint32 cksum);
    void onConnProgramResetDone(OpResult result);
private:
    enum class State
    {
        Idle,
        Program,
        ProgramVerify,
        BuildChecksumVerify,
        ProgramReset
    };

    ConnectionFacade *mConn;
    State mState;
    FlashProg *mActiveProg;
    quint8 mActiveAddrExt;
    CksumType mActiveCksumType;
    QList<FlashBlock *>::const_iterator mActiveProgBlock;
};

} // namespace Xcp
} // namespace SetupTools

#endif // SETUPTOOLS_XCP_PROGRAMLAYER_H
