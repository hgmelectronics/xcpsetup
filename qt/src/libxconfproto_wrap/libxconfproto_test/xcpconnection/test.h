#ifndef TEST_H
#define TEST_H

#include <QObject>
#include <QtTest/QtTest>
#include <functional>

#include <Xcp_Connection.h>
#include <Xcp_Interface_Loopback_Interface.h>
#include "testingslave.h"

typedef std::pair<SetupTools::Xcp::CksumType, quint32> CksumPair;
Q_DECLARE_METATYPE(CksumPair)

namespace SetupTools
{
namespace Xcp
{

class Test : public QObject
{
    Q_OBJECT

public:
    Test(QObject *parent = 0);
    virtual ~Test() {}

private slots:
    void initTestCase();
    void connect();
    void upload_data();
    void upload();
    void downloadUpload_data();
    void downloadUpload();
    void downloadCksum_data();
    void downloadCksum();
    void uploadOutOfRange_data();
    void uploadOutOfRange();
    void downloadUploadSmall_data();
    void downloadUploadSmall();
    void downloadNvWrite_data();
    void downloadNvWrite();
    void altCalPage();
    void programSequence_data();
    void programSequence();
private:
    void updateAg(int ag);
    static const int CONN_TIMEOUT = 50;
    static const int CONN_NVWRITE_TIMEOUT = 100;
    static const int CONN_RESET_TIMEOUT = 100;
    Interface::Loopback::Interface *mIntfc;
    Connection *mConn;
    TestingSlave *mSlave;
};

}
}

#endif // TEST_H
