#ifndef TEST_H
#define TEST_H

#include <QObject>
#include <QtTest/QtTest>
#include <functional>

#include <Xcp_Connection.h>
#include <Xcp_Interface_Loopback_Interface.h>
#include <Xcp_MemoryRangeTable.h>
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
    void uploadNoOverlap_data();
    void uploadNoOverlap();
    void downloadNoOverlap_data();
    void downloadNoOverlap();
private:
    void updateAg(int ag);
    static const int CONN_TIMEOUT = 50;
    static const int CONN_NVWRITE_TIMEOUT = 100;
    static const int CONN_RESET_TIMEOUT = 100;
    static const int CONN_PROGCLEAR_TIMEOUT = 100;
    Interface::Loopback::Interface *mIntfc;
    Connection *mConn;
    TestingSlave *mSlave;
};

}
}

#endif // TEST_H
