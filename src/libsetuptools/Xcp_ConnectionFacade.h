#ifndef SETUPTOOLS_XCP_CONNECTIONFACADE_H
#define SETUPTOOLS_XCP_CONNECTIONFACADE_H

#include <QObject>
#include "Xcp_Connection.h"

namespace SetupTools {
namespace Xcp {

class ConnectionFacade : public QObject
{
    Q_OBJECT
    Q_PROPERTY(QUrl intfcUri READ intfcUri WRITE setIntfcUri)
    Q_PROPERTY(int timeout READ timeout WRITE setTimeout)
    Q_PROPERTY(int nvWriteTimeout READ nvWriteTimeout WRITE setNvWriteTimeout)
    Q_PROPERTY(int bootDelay READ bootDelay WRITE setBootDelay)
    Q_PROPERTY(int progClearTimeout READ progClearTimeout WRITE setProgClearTimeout)
    Q_PROPERTY(double opProgressNotifyFrac READ opProgressNotifyFrac WRITE setOpProgressNotifyFrac)
    Q_PROPERTY(SetupTools::Xcp::Connection::State state READ state WRITE setState NOTIFY stateChanged)
    Q_PROPERTY(bool progResetIsAcked READ progResetIsAcked WRITE setProgResetIsAcked)

    /**
     * Progress through a long operation with interim state notification (upload and download
     * of more than one packet, program range). Resets to zero immediately after completion signals are emitted.
     */
    Q_PROPERTY(double opProgress READ opProgress NOTIFY opProgressChanged)
public:
    explicit ConnectionFacade(QObject *parent = 0);
    ~ConnectionFacade();
    QUrl intfcUri();
    void setIntfcUri(QUrl);
    Interface::Interface *intfc();
    void setIntfc(Interface::Interface *intfc, QUrl uri = QUrl("testing")); // for interfaces shared between higher layers - use with caution!
    int timeout();
    void setTimeout(int);
    int nvWriteTimeout();
    void setNvWriteTimeout(int);
    int bootDelay();
    void setBootDelay(int);
    double opProgressNotifyFrac();
    void setOpProgressNotifyFrac(double);
    int progClearTimeout(void);
    void setProgClearTimeout(int msec);
    bool progResetIsAcked(void);
    void setProgResetIsAcked(bool val);
    double opProgress();
    void forceSlaveSupportCalPage();
    ::SetupTools::Xcp::Connection::State state();
    void setState(::SetupTools::Xcp::Connection::State val);
    void setTarget(QString target);
    quint32 computeCksum(CksumType type, const std::vector<quint8> &data);
    QString connectedTarget()
    {
        return mConnectedTarget;
    }

    template <typename T>
    T fromSlaveEndian(const uchar *src) { return mConn->fromSlaveEndian<T>(src); }
    template <typename T>
    T fromSlaveEndian(const char *src) { return mConn->fromSlaveEndian<T>(reinterpret_cast<const uchar *>(src)); }
    template <typename T>
    T fromSlaveEndian(T src) { return mConn->fromSlaveEndian<T>(src); }
    template <typename T>
    void toSlaveEndian(T src, uchar *dest) { mConn->toSlaveEndian<T>(src, dest); }
    template <typename T>
    void toSlaveEndian(T src, char *dest) { mConn->toSlaveEndian<T>(src, reinterpret_cast<uchar *>(dest)); }
    template <typename T>
    T toSlaveEndian(T src) { return mConn->toSlaveEndian<T>(src); }

    int addrGran();

signals:
    void uploadDone(SetupTools::OpResult result, XcpPtr base, int len, const std::vector<quint8> &data);
    void downloadDone(SetupTools::OpResult result, XcpPtr base, const std::vector<quint8> &data);
    void nvWriteDone(SetupTools::OpResult result);
    void setCalPageDone(SetupTools::OpResult result, quint8 segment, quint8 page);
    void copyCalPageDone(SetupTools::OpResult result, quint8 fromSegment, quint8 fromPage, quint8 toSegment, quint8 toPage);
    void programClearDone(SetupTools::OpResult result, XcpPtr base, int len);
    void programRangeDone(SetupTools::OpResult result, XcpPtr base, const std::vector<quint8> &data, bool finalEmptyPacket);
    void programVerifyDone(SetupTools::OpResult result, XcpPtr mta, quint32 crc);
    void programResetDone(SetupTools::OpResult result);
    void buildChecksumDone(SetupTools::OpResult result, XcpPtr base, int len, CksumType type, quint32 cksum);
    void getAvailSlavesStrDone(SetupTools::OpResult result, QString bcastId, QString filter, QList<QString> slaveIds);
    void setStateDone(SetupTools::OpResult result);
    void setTargetDone(SetupTools::OpResult result);
    void opMsg(SetupTools::OpResult result, QString info, SetupTools::Xcp::Connection::OpExtInfo ext);
    void stateChanged();
    void opProgressChanged();
    void connectedTargetChanged(QString target);

    void connSetTarget(QString target);
    void connSetState(Connection::State val);
    void connUpload(XcpPtr base, int len, std::vector<quint8> *out);
    void connDownload(XcpPtr base, const std::vector<quint8> data); // must pass by value, reference gets invalidated when caller returns but Connection thread is still using it
    void connNvWrite();
    void connSetCalPage(quint8 segment, quint8 page);
    void connCopyCalPage(quint8 fromSegment, quint8 fromPage, quint8 toSegment, quint8 toPage);
    void connProgramClear(XcpPtr base, int len);
    void connProgramRange(XcpPtr base, const std::vector<quint8> data, bool finalEmptyPacket);
    void connProgramVerify(XcpPtr mta, quint32 crc);
    void connProgramReset();
    void connBuildChecksum(XcpPtr base, int len, CksumType *typeOut, quint32 *cksumOut);
    void connGetAvailSlavesStr(QString bcastId, QString filter, QList<QString> *out);

public slots:
    void upload(XcpPtr base, int len);
    void download(XcpPtr base, const std::vector<quint8> data);
    void nvWrite();
    void setCalPage(quint8 segment, quint8 page);
    void copyCalPage(quint8 fromSegment, quint8 fromPage, quint8 toSegment, quint8 toPage);
    void programClear(XcpPtr base, int len);
    void programRange(XcpPtr base, const std::vector<quint8> data, bool finalEmptyPacket = true);
    void programVerify(XcpPtr mta, quint32 crc);
    void programReset();
    void buildChecksum(XcpPtr base, int len);
    void getAvailSlavesStr(QString bcastId, QString filter);
private:
    void onConnConnectedTargetChanged(QString);

    Interface::Interface* mIntfc;
    bool mIntfcOwned;
    QUrl mIntfcUri;
    Connection *mConn;
    QThread *mConnThread;
    QString mConnectedTarget;
};

} // namespace Xcp
} // namespace SetupTools

#endif // SETUPTOOLS_XCP_CONNECTIONFACADE_H
