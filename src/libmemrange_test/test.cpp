#include "test.h"
#include <memory>
#include <cxxabi.h>
#include <boost/crc.hpp>
#include "Xcp_ScalarMemoryRange.h"

namespace QTest
{
template<>
char *toString(const SetupTools::Xcp::OpResult &res)
{
    QByteArray ba = "OpResult(";
    ba += QByteArray::number(static_cast<int>(res));
    ba += ")";
    return qstrdup(ba.data());
}
}

namespace SetupTools
{
namespace Xcp
{

void FailOnExc(ConnException &exc)
{
    std::string demangled;
    int status = 1;

    std::unique_ptr<char, void(*)(void*)> res {
        abi::__cxa_demangle(typeid(exc).name(), NULL, NULL, &status),
        std::free
    };

    if(status == 0)
        demangled = res.get();
    else
        demangled = typeid(exc).name();

    const char prefix[] = "Exception: ";
    char msg[sizeof(prefix) + demangled.size()];
    strcpy(msg, prefix);
    strcat(msg, demangled.c_str());
    QFAIL(msg);
}

std::vector<quint8> VectorFromQByteArray(const QByteArray &arr)
{
    return std::vector<quint8>(reinterpret_cast<const quint8 *>(arr.begin()), reinterpret_cast<const quint8 *>(arr.end()));
}

Test::Test(QObject *parent) : QObject(parent) {}

void Test::initTestCase()
{
    mIntfc = new Interface::Loopback::Interface();
    //mIntfc->setPacketLog(true);
    mConn = new SetupTools::Xcp::Connection(this);
    mConn->setIntfc(mIntfc);
    mConn->setTimeout(CONN_TIMEOUT);
    mConn->setNvWriteTimeout(CONN_NVWRITE_TIMEOUT);
    mConn->setResetTimeout(CONN_RESET_TIMEOUT);
    mConn->setProgClearTimeout(CONN_PROGCLEAR_TIMEOUT);
    mSlave = new TestingSlave(mIntfc, this);
    updateAg(1);
    mSlave->setBigEndian(false);
    mSlave->setPgmMasterBlockSupport(true);
    mSlave->setSendsEvStoreCal(true);

    mSlave->addMemRange(TestingSlave::MemType::Calib, {0x400, 0}, 256);
}

void Test::uploadNoOverlap_data()
{
    QTest::addColumn<quint32>("ag");
    QTest::addColumn<QList<quint32> >("base");
    QTest::addColumn<QList<quint32> >("value");
    QTest::addColumn<bool>("constructBeforeOpen");
    QTest::newRow("AG==1 cbo=0") << quint32(0x1) << QList<quint32>({0x400, 0x404, 0x408, 0x40C}) << QList<quint32>({0xDEADBEEF, 0x7F, 0x01234567, 0x89ABCDEF}) << false;
    QTest::newRow("AG==1 cbo=1") << quint32(0x1) << QList<quint32>({0x400, 0x404, 0x408, 0x40C}) << QList<quint32>({0xDEADBEEF, 0x7F, 0x01234567, 0x89ABCDEF}) << true;
    QTest::newRow("AG==2 cbo=0") << quint32(0x2) << QList<quint32>({0x200, 0x202, 0x204, 0x206}) << QList<quint32>({0xDEADBEEF, 0x7F, 0x01234567, 0x89ABCDEF}) << false;
    QTest::newRow("AG==2 cbo=1") << quint32(0x2) << QList<quint32>({0x200, 0x202, 0x204, 0x206}) << QList<quint32>({0xDEADBEEF, 0x7F, 0x01234567, 0x89ABCDEF}) << true;
    QTest::newRow("AG==4 cbo=0") << quint32(0x4) << QList<quint32>({0x100, 0x101, 0x102, 0x103}) << QList<quint32>({0xDEADBEEF, 0x7F, 0x01234567, 0x89ABCDEF}) << false;
    QTest::newRow("AG==4 cbo=1") << quint32(0x4) << QList<quint32>({0x100, 0x101, 0x102, 0x103}) << QList<quint32>({0xDEADBEEF, 0x7F, 0x01234567, 0x89ABCDEF}) << true;
}

/**
 * @brief Upload data from a few addresses
 */
void Test::uploadNoOverlap()
{
    QFETCH(quint32, ag);
    QFETCH(QList<quint32>, base);
    QFETCH(QList<quint32>, value);
    QFETCH(bool, constructBeforeOpen);

    updateAg(ag);
    std::shared_ptr<MemoryRangeTable> table(new MemoryRangeTable(ag, this));
    table->setConnection(mConn);
    std::vector<quint8> &slaveMemRange = mSlave->getMemRange(0);
    std::vector<quint32 *> slaveMemRangeValue(base.size());
    for(int idx = 0; idx < base.size(); ++idx)
    {
        slaveMemRangeValue[idx] = reinterpret_cast<quint32 *>(slaveMemRange.data() + idx * sizeof(quint32));
        *slaveMemRangeValue[idx] = value[idx];
    }

    if(!constructBeforeOpen)   // call refresh after open
        QCOMPARE(mConn->open(), OpResult::Success);
    std::vector<ScalarMemoryRange *> range(base.size());
    for(int idx = 0; idx < base.size(); ++idx)
    {
        range[idx] = qobject_cast<ScalarMemoryRange *>(table->addRange(MemoryRange::U32, {base[idx], 0}, 1, false));
        QVERIFY(range[idx] != nullptr);
    }
    if(constructBeforeOpen)
    {
        QCOMPARE(mConn->open(), OpResult::Success);
    }
    else
    {
        for(int idx = 0; idx < base.size(); ++idx)
            range[idx]->refresh();
    }
    for(int idx = 0; idx < base.size(); ++idx)
    {
        QCOMPARE(range[idx]->valid(), true);
        QCOMPARE(range[idx]->writable(), false);
        QCOMPARE(range[idx]->value().toUInt(), value[idx]);
    }
    mConn->close();
}

void Test::downloadNoOverlap_data()
{
    QTest::addColumn<quint32>("ag");
    QTest::addColumn<QList<quint32> >("base");
    QTest::addColumn<QList<quint32> >("value");
    QTest::newRow("AG==1") << quint32(0x1) << QList<quint32>({0x400, 0x404, 0x408, 0x40C}) << QList<quint32>({0xDEADBEEF, 0x7F, 0x01234567, 0x89ABCDEF});
    QTest::newRow("AG==2") << quint32(0x2) << QList<quint32>({0x200, 0x202, 0x204, 0x206}) << QList<quint32>({0xDEADBEEF, 0x7F, 0x01234567, 0x89ABCDEF});
    QTest::newRow("AG==4") << quint32(0x4) << QList<quint32>({0x100, 0x101, 0x102, 0x103}) << QList<quint32>({0xDEADBEEF, 0x7F, 0x01234567, 0x89ABCDEF});
}

/**
 * @brief Download data to a few addresses
 */
void Test::downloadNoOverlap()
{
    QFETCH(quint32, ag);
    QFETCH(QList<quint32>, base);
    QFETCH(QList<quint32>, value);

    updateAg(ag);
    std::shared_ptr<MemoryRangeTable> table(new MemoryRangeTable(ag, this));
    table->setConnection(mConn);
    std::vector<quint8> &slaveMemRange = mSlave->getMemRange(0);
    std::vector<quint32 *> slaveMemRangeValue(base.size());
    for(int idx = 0; idx < base.size(); ++idx)
    {
        slaveMemRangeValue[idx] = reinterpret_cast<quint32 *>(slaveMemRange.data() + idx * sizeof(quint32));
        *slaveMemRangeValue[idx] = 0;
    }

    std::vector<ScalarMemoryRange *> range(base.size());
    for(int idx = 0; idx < base.size(); ++idx)
    {
        range[idx] = qobject_cast<ScalarMemoryRange *>(table->addRange(MemoryRange::U32, {base[idx], 0}, 1, true));
        QVERIFY(range[idx] != nullptr);
    }
    QCOMPARE(mConn->open(), OpResult::Success);
    for(int idx = 0; idx < base.size(); ++idx)
    {
        QCOMPARE(range[idx]->valid(), true);
        QCOMPARE(range[idx]->writable(), true);
        QCOMPARE(range[idx]->value().toUInt(), quint32(0));
    }
    for(int idx = 0; idx < base.size(); ++idx)
        range[idx]->setValue(value[idx]);
    for(int idx = 0; idx < base.size(); ++idx)
    {
        QCOMPARE(range[idx]->value().toUInt(), value[idx]);
        QCOMPARE(*slaveMemRangeValue[idx], value[idx]);
    }
    mConn->close();
}

void Test::updateAg(int ag)
{
    mSlave->setAg(ag);
    mSlave->setMaxBs(255/ag);
    mSlave->setPgmMaxBs(255/ag);
}

}
}
