#ifndef SETUPTOOLS_XCP_CONNECTIONFACADE_H
#define SETUPTOOLS_XCP_CONNECTIONFACADE_H

#include <QObject>
#include "Xcp_Connection.h"

namespace SetupTools {
namespace Xcp {

class LIBXCONFPROTOSHARED_EXPORT ConnectionFacade : public QObject
{
    Q_OBJECT
    Q_PROPERTY(QString intfcUri READ intfcUri WRITE setIntfcUri)
    Q_PROPERTY(int timeout READ timeout WRITE setTimeout)
    Q_PROPERTY(int nvWriteTimeout READ nvWriteTimeout WRITE setNvWriteTimeout)
    Q_PROPERTY(int resetTimeout READ resetTimeout WRITE setResetTimeout)
    Q_PROPERTY(Connection::State state READ state WRITE setState NOTIFY stateChanged)
public:
    explicit ConnectionFacade(QObject *parent = 0);
    ~ConnectionFacade();
    QString intfcUri();
    void setIntfcUri(QString);
    QString slaveId();
    void setSlaveId(QString);
    int timeout();
    void setTimeout(int);
    int nvWriteTimeout();
    void setNvWriteTimeout(int);
    int resetTimeout();
    void setResetTimeout(int);
    ::SetupTools::Xcp::Connection::State state();
    void setState(::SetupTools::Xcp::Connection::State val);

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

signals:
    void stateChanged();

    void uploadDone(OpResult result, std::vector<quint8> data);
    void downloadDone(OpResult result);
    void nvWriteDone(OpResult result);
    void setCalPageDone(OpResult result);
    void programClearDone(OpResult result);
    void programRangeDone(OpResult result);
    void programVerifyDone(OpResult result);
    void programResetDone(OpResult result);
    void buildChecksumDone(OpResult result, CksumType type, quint32 cksum);
    void setStateDone(OpResult result);

    void connSetState(Connection::State val);
    void connUpload(XcpPtr base, int len, std::vector<quint8> *out);
    void connDownload(XcpPtr base, const std::vector<quint8> data); // must pass by value, reference gets invalidated when caller returns but Connection thread is still using it
    void connNvWrite();
    void connSetCalPage(quint8 segment, quint8 page);
    void connProgramClear(XcpPtr base, int len);
    void connProgramRange(XcpPtr base, const std::vector<quint8> data);
    void connProgramVerify(quint32 crc);
    void connProgramReset();
    void connBuildChecksum(XcpPtr base, int len, CksumType *typeOut, quint32 *cksumOut);

public slots:
    void upload(XcpPtr base, int len);
    void download(XcpPtr base, const std::vector<quint8> data);
    void nvWrite();
    void setCalPage(quint8 segment, quint8 page);
    void programClear(XcpPtr base, int len);
    void programRange(XcpPtr base, const std::vector<quint8> data);
    void programVerify(quint32 crc);
    void programReset();
    void buildChecksum(XcpPtr base, int len);

    void onConnStateChanged();
    void onConnSetStateDone(OpResult);
    void onConnUploadDone(OpResult result, std::vector<quint8> data);
    void onConnDownloadDone(OpResult result);
    void onConnNvWriteDone(OpResult result);
    void onConnSetCalPageDone(OpResult result);
    void onConnProgramClearDone(OpResult result);
    void onConnProgramRangeDone(OpResult result);
    void onConnProgramVerifyDone(OpResult result);
    void onConnProgramResetDone(OpResult result);
    void onConnBuildChecksumDone(OpResult result, CksumType type, quint32 cksum);

private:
    Interface::Interface *mIntfc;
    QString mIntfcUri;
    Connection *mConn;
    QThread *mConnThread;
};

class LIBXCONFPROTOSHARED_EXPORT SimpleDataLayer : public QObject
{
    Q_OBJECT
    Q_PROPERTY(QString intfcUri READ intfcUri WRITE setIntfcUri)
    Q_PROPERTY(QString slaveId READ slaveId WRITE setSlaveId)
public:
    SimpleDataLayer();

    QString intfcUri(void);
    void setIntfcUri(QString);
    QString slaveId();
    void setSlaveId(QString);
signals:
    void uploadUint32Done(int result, quint32 data);
    void downloadUint32Done(int result);
public slots:
    void uploadUint32(quint32 base);
    void downloadUint32(quint32 base, quint32 data);
    void onConnUploadDone(OpResult, std::vector<quint8>);
    void onConnDownloadDone(OpResult);
private:
    ConnectionFacade *mConn;
};

} // namespace Xcp
} // namespace SetupTools

#endif // SETUPTOOLS_XCP_CONNECTIONFACADE_H