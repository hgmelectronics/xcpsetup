#ifndef TEST_H
#define TEST_H

#include <QObject>
#include <QtTest/QtTest>

#include <Xcp_Connection.h>
#include <Xcp_Interface_Loopback_Interface.h>
#include "testingslave.h"

namespace SetupTools
{
namespace Xcp
{

class EbusBoardTest : public QObject
{
    Q_OBJECT
public:
    EbusBoardTest(QObject *parent = 0);
    virtual ~EbusBoardTest() {}

private slots:
    void initTestCase();
    void connectTest();
    void uploadTest();
    void downloadUploadTest();

private:
    static const int CONN_TIMEOUT = 100;
    static const int CONN_NVWRITE_TIMEOUT = 200;
    QSharedPointer<Interface::Loopback::Interface> mIntfc;
    Connection *mConn;
    TestingSlave *mSlave;
};

}
}

#endif // TEST_H
