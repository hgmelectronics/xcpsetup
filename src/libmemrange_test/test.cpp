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

    mSlave->addMemRange(TestingSlave::MemType::Calib, {0x400, 0}, 16);
}

void Test::uploadNoOverlap_data()
{
    QTest::addColumn<quint32>("ag");
    QTest::addColumn<quint32>("base");
    QTest::addColumn<quint32>("value");
    QTest::addColumn<bool>("constructBeforeOpen");
    QTest::newRow("AG==1 0") << quint32(0x1) << quint32(0x400) << quint32(0xDEADBEEF) << false;
    QTest::newRow("AG==1 1") << quint32(0x1) << quint32(0x404) << quint32(0x0000007F) << false;
    QTest::newRow("AG==1 2") << quint32(0x1) << quint32(0x408) << quint32(0x01234567) << true;
    QTest::newRow("AG==1 3") << quint32(0x1) << quint32(0x40C) << quint32(0x89ABCDEF) << true;
    QTest::newRow("AG==2 0") << quint32(0x2) << quint32(0x200) << quint32(0xDEADBEEF) << false;
    QTest::newRow("AG==2 1") << quint32(0x2) << quint32(0x202) << quint32(0x0000007F) << false;
    QTest::newRow("AG==2 2") << quint32(0x2) << quint32(0x204) << quint32(0x01234567) << true;
    QTest::newRow("AG==2 3") << quint32(0x2) << quint32(0x206) << quint32(0x89ABCDEF) << true;
    QTest::newRow("AG==4 0") << quint32(0x4) << quint32(0x100) << quint32(0xDEADBEEF) << false;
    QTest::newRow("AG==4 1") << quint32(0x4) << quint32(0x101) << quint32(0x0000007F) << false;
    QTest::newRow("AG==4 2") << quint32(0x4) << quint32(0x102) << quint32(0x01234567) << true;
    QTest::newRow("AG==4 3") << quint32(0x4) << quint32(0x103) << quint32(0x89ABCDEF) << true;
}

/**
 * @brief Upload data from a few addresses
 */
void Test::uploadNoOverlap()
{
    QFETCH(quint32, ag);
    QFETCH(quint32, base);
    QFETCH(quint32, value);
    QFETCH(bool, constructBeforeOpen);

    updateAg(ag);
    MemoryRangeTable *table = new MemoryRangeTable(ag, this);
    table->setConnection(mConn);
    std::vector<quint8> &slaveMemRange = mSlave->getMemRange(0);
    quint32 slaveMemRangeOffset = (base * ag) - 0x400;
    quint32 *slaveMemRangeValue = reinterpret_cast<quint32 *>(slaveMemRange.data() + slaveMemRangeOffset);
    *slaveMemRangeValue = value;

    if(!constructBeforeOpen)   // call refresh after open
        QCOMPARE(mConn->open(), OpResult::Success);
    ScalarMemoryRange *range = qobject_cast<ScalarMemoryRange *>(table->addRange(MemoryRange::U32, {base, 0}, 1, false));
    QVERIFY(range != nullptr);
    if(constructBeforeOpen)
        QCOMPARE(mConn->open(), OpResult::Success);
    else
        range->refresh();
    QCOMPARE(range->valid(), true);
    QCOMPARE(range->writable(), false);
    QCOMPARE(range->value().toUInt(), value);
    delete table;
    mConn->close();
}

void Test::downloadNoOverlap_data()
{
    QTest::addColumn<quint32>("ag");
    QTest::addColumn<quint32>("base");
    QTest::addColumn<quint32>("value");
    QTest::newRow("AG==1 0") << quint32(0x1) << quint32(0x400) << quint32(0xDEADBEEF);
    QTest::newRow("AG==1 1") << quint32(0x1) << quint32(0x404) << quint32(0x0000007F);
    QTest::newRow("AG==2 0") << quint32(0x2) << quint32(0x200) << quint32(0xDEADBEEF);
    QTest::newRow("AG==2 1") << quint32(0x2) << quint32(0x202) << quint32(0x0000007F);
    QTest::newRow("AG==4 0") << quint32(0x4) << quint32(0x100) << quint32(0xDEADBEEF);
    QTest::newRow("AG==4 1") << quint32(0x4) << quint32(0x101) << quint32(0x0000007F);
}

/**
 * @brief Download data to a few addresses
 */
void Test::downloadNoOverlap()
{
    QFETCH(quint32, ag);
    QFETCH(quint32, base);
    QFETCH(quint32, value);

    updateAg(ag);
    MemoryRangeTable *table = new MemoryRangeTable(ag, this);
    table->setConnection(mConn);
    std::vector<quint8> &slaveMemRange = mSlave->getMemRange(0);
    quint32 slaveMemRangeOffset = (base * ag) - 0x400;
    quint32 *slaveMemRangeValue = reinterpret_cast<quint32 *>(slaveMemRange.data() + slaveMemRangeOffset);
    *slaveMemRangeValue = 0;

    ScalarMemoryRange *range = qobject_cast<ScalarMemoryRange *>(table->addRange(MemoryRange::U32, {base, 0}, 1, true));
    QVERIFY(range != nullptr);
    QCOMPARE(mConn->open(), OpResult::Success);
    QCOMPARE(range->valid(), true);
    QCOMPARE(range->writable(), true);
    QCOMPARE(range->value().toUInt(), quint32(0));
    range->setValue(value);
    QCOMPARE(range->value().toUInt(), value);
    QCOMPARE(*slaveMemRangeValue, value);
    delete table;
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
