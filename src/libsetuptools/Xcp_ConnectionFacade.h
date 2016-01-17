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
    Q_PROPERTY(int resetTimeout READ resetTimeout WRITE setResetTimeout)
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
    QString slaveId();
    void setSlaveId(QString);
    int timeout();
    void setTimeout(int);
    int nvWriteTimeout();
    void setNvWriteTimeout(int);
    int resetTimeout();
    void setResetTimeout(int);
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
    quint32 computeCksum(CksumType type, const std::vector<quint8> &data);

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
    void uploadDone(SetupTools::Xcp::OpResult result, XcpPtr base, int len, const std::vector<quint8> &data);
    void downloadDone(SetupTools::Xcp::OpResult result, XcpPtr base, const std::vector<quint8> &data);
    void nvWriteDone(SetupTools::Xcp::OpResult result);
    void setCalPageDone(SetupTools::Xcp::OpResult result, quint8 segment, quint8 page);
    void programClearDone(SetupTools::Xcp::OpResult result, XcpPtr base, int len);
    void programRangeDone(SetupTools::Xcp::OpResult result, XcpPtr base, const std::vector<quint8> &data, bool finalEmptyPacket);
    void programVerifyDone(SetupTools::Xcp::OpResult result, XcpPtr mta, quint32 crc);
    void programResetDone(SetupTools::Xcp::OpResult result);
    void buildChecksumDone(SetupTools::Xcp::OpResult result, XcpPtr base, int len, CksumType type, quint32 cksum);
    void getAvailSlavesStrDone(SetupTools::Xcp::OpResult result, QString bcastId, QString filter, QList<QString> slaveIds);
    void setStateDone(SetupTools::Xcp::OpResult result);
    void fault(SetupTools::Xcp::OpResult result, QString info);
    void stateChanged();
    void opProgressChanged();

    void connSetState(Connection::State val);
    void connUpload(XcpPtr base, int len, std::vector<quint8> *out);
    void connDownload(XcpPtr base, const std::vector<quint8> data); // must pass by value, reference gets invalidated when caller returns but Connection thread is still using it
    void connNvWrite();
    void connSetCalPage(quint8 segment, quint8 page);
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
    void programClear(XcpPtr base, int len);
    void programRange(XcpPtr base, const std::vector<quint8> data, bool finalEmptyPacket = true);
    void programVerify(XcpPtr mta, quint32 crc);
    void programReset();
    void buildChecksum(XcpPtr base, int len);
    void getAvailSlavesStr(QString bcastId, QString filter);

private:
    void onConnSetStateDone(SetupTools::Xcp::OpResult);
    void onConnUploadDone(SetupTools::Xcp::OpResult result, XcpPtr base, int len, std::vector<quint8> data);
    void onConnDownloadDone(SetupTools::Xcp::OpResult result, XcpPtr base, std::vector<quint8> data);
    void onConnNvWriteDone(SetupTools::Xcp::OpResult result);
    void onConnSetCalPageDone(SetupTools::Xcp::OpResult result, quint8 segment, quint8 page);
    void onConnProgramClearDone(SetupTools::Xcp::OpResult result, XcpPtr base, int len);
    void onConnProgramRangeDone(SetupTools::Xcp::OpResult result, XcpPtr base, std::vector<quint8> data, bool finalEmptyPacket);
    void onConnProgramVerifyDone(SetupTools::Xcp::OpResult result, XcpPtr mta, quint32 crc);
    void onConnProgramResetDone(SetupTools::Xcp::OpResult result);
    void onConnBuildChecksumDone(SetupTools::Xcp::OpResult result, XcpPtr base, int len, CksumType type, quint32 cksum);
    void onConnGetAvailSlavesStrDone(SetupTools::Xcp::OpResult result, QString bcastId, QString filter, QList<QString> slaveIds);
    void onConnFault(SetupTools::Xcp::OpResult result, QString info);
    void onConnStateChanged();
    void onConnOpProgressChanged();

    Interface::Interface* mIntfc;
    bool mIntfcOwned;
    QUrl mIntfcUri;
    Connection *mConn;
    QThread *mConnThread;
};

class SimpleDataLayer : public QObject
{
    Q_OBJECT
    Q_PROPERTY(QUrl intfcUri READ intfcUri WRITE setIntfcUri)
    Q_PROPERTY(QString slaveId READ slaveId WRITE setSlaveId)
public:
    SimpleDataLayer();

    QUrl intfcUri(void);
    void setIntfcUri(QUrl);
    QString slaveId();
    void setSlaveId(QString);
signals:
    void uploadUint32Done(int result, quint32 data);
    void downloadUint32Done(int result);

public slots:
    void uploadUint32(quint32 base);
    void downloadUint32(quint32 base, quint32 data);

private:
    void onConnUploadDone(SetupTools::Xcp::OpResult, XcpPtr, int, const std::vector<quint8> &);
    void onConnDownloadDone(SetupTools::Xcp::OpResult, XcpPtr, const std::vector<quint8> &);
    ConnectionFacade *mConn;
};

} // namespace Xcp
} // namespace SetupTools

#endif // SETUPTOOLS_XCP_CONNECTIONFACADE_H
