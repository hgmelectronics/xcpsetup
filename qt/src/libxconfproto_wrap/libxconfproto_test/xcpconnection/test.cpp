#include "test.h"

namespace SetupTools
{
namespace Xcp
{

EbusBoardTest::EbusBoardTest(QObject *parent) : QObject(parent) {}

void EbusBoardTest::initTestCase()
{
    mIntfc = QSharedPointer<Interface::Loopback::Interface>::create();
    mConn = new SetupTools::Xcp::Connection(mIntfc, CONN_TIMEOUT, CONN_NVWRITE_TIMEOUT, this);
    mSlave = new TestingSlave(mIntfc, this);
    mSlave->setAg(1);
    mSlave->setPgmMaxBs(255);
    mSlave->setBigEndian(false);
    mSlave->setPgmMasterBlockSupport(true);
    mSlave->setSendsEvStoreCal(true);
    mSlave->addMemRange(TestingSlave::MemType::Calib, {0, 0}, 1024);
    mSlave->addMemRange(TestingSlave::MemType::Prog, {0x08004000, 0}, 0x7A800);
}

void EbusBoardTest::connectTest()
{
    try
    {
        mConn->open();
        mConn->close();
    }
    catch(SetupTools::Xcp::Exception &exc)
    {
        qDebug() << demangleName(typeid(exc).name()).c_str();
        QFAIL("Exception thrown");
    }
}

void EbusBoardTest::uploadTest()
{
    try
    {
        mConn->open();
        std::vector<quint8> data = mConn->upload({0, 0}, 64);
        std::vector<quint8> expectedData;
        expectedData.assign(64, 0);
        QCOMPARE(data, expectedData);
        mConn->close();
    }
    catch(SetupTools::Xcp::Exception &exc)
    {
        qDebug() << demangleName(typeid(exc).name()).c_str();
        QFAIL("Exception thrown");
    }
}

void EbusBoardTest::downloadUploadTest()
{
    try
    {
        mConn->open();
        XcpPtr base = {234, 0};
        QByteArray dataArr("Please do not press this button again.");
        std::vector<quint8> data(reinterpret_cast<const quint8 *>(dataArr.begin()), reinterpret_cast<const quint8 *>(dataArr.end()));
        mConn->download(base, data);
        std::vector<quint8> uploadData = mConn->upload(base, data.size());
        QCOMPARE(uploadData, data);
        mConn->close();
    }
    catch(SetupTools::Xcp::Exception &exc)
    {
        qDebug() << demangleName(typeid(exc).name()).c_str();
        QFAIL("Exception thrown");
    }
}

}
}
