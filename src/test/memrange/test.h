#ifndef TEST_H
#define TEST_H

#include <QObject>
#include <QtTest/QtTest>
#include <functional>

#include <Xcp_Connection.h>
#include <Xcp_Interface_Loopback_Interface.h>
#include <Xcp_MemoryRangeTable.h>
#include <Xcp_TestingSlave.h>

typedef std::pair<SetupTools::Xcp::CksumType, quint32> CksumPair;
Q_DECLARE_METATYPE(CksumPair)

namespace QTest
{
char *toString(const SetupTools::Xcp::OpResult &res);
}

void waitSignalSpyCount(int delay, int count, QSignalSpy &spy);

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

    void linearSlotToFloat_data();
    void linearSlotToFloat();
    void linearSlotToString_data();
    void linearSlotToString();
    void linearSlotToRaw_data();
    void linearSlotToRaw();

    void uploadNoOverlap_data();
    void uploadNoOverlap();
    void downloadNoOverlap_data();
    void downloadNoOverlap();
    void setupOverlap_data();
    void setupOverlap();
    void uploadOverlap_data();
    void uploadOverlap();

    void uploadArrayNoOverlap_data();
    void uploadArrayNoOverlap();
    void downloadArrayNoOverlap_data();
    void downloadArrayNoOverlap();
    void uploadArraySub_data();
    void uploadArraySub();
    void uploadArrayOverlap_data();
    void uploadArrayOverlap();

    void paramDownloadUpload_data();
    void paramDownloadUpload();

    void arrayParamDownloadUpload_data();
    void arrayParamDownloadUpload();

    void slotArrayModel();

    void varArrayParamDownloadUpload_data();
    void varArrayParamDownloadUpload();

    void varArrayParamReupload_data();
    void varArrayParamReupload();
private:
    void updateAg(int ag);
    void setWaitConnState(const MemoryRangeTable *table, Connection::State state);
    static const int CONN_TIMEOUT = 100;
    static const int CONN_NVWRITE_TIMEOUT = 100;
    static const int CONN_RESET_TIMEOUT = 100;
    static const int CONN_PROGCLEAR_TIMEOUT = 100;
    Interface::Loopback::Interface *mIntfc;
    ConnectionFacade *mConnFacade;
    TestingSlave *mSlave;
};

}
}

#endif // TEST_H
