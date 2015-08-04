#include "test.h"
#include <memory>
#include <cxxabi.h>
#include <boost/crc.hpp>
#include "Xcp_ScalarMemoryRange.h"

#include <QPair>

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

typedef QList<QPair<quint32, quint32> > ListDescList;
void Test::setupOverlap_data()
{
    QTest::addColumn<quint32>("ag");
    QTest::addColumn<QList<quint32> >("base");
    QTest::addColumn<ListDescList>("lists");
    QTest::newRow("AG==1 no-overlap") << quint32(0x1) << QList<quint32>({0x400, 0x404, 0x408}) << QList<QPair<quint32, quint32> >({{0x400, 4}, {0x404, 4}, {0x408, 4}});
    QTest::newRow("AG==1 overlap 1") << quint32(0x1) << QList<quint32>({0x400, 0x406, 0x408}) << QList<QPair<quint32, quint32> >({{0x400, 4}, {0x406, 6}});
    QTest::newRow("AG==1 overlap 2") << quint32(0x1) << QList<quint32>({0x400, 0x408, 0x406}) << QList<QPair<quint32, quint32> >({{0x400, 4}, {0x406, 6}});
    QTest::newRow("AG==1 overlap 3") << quint32(0x1) << QList<quint32>({0x406, 0x408, 0x400}) << QList<QPair<quint32, quint32> >({{0x400, 4}, {0x406, 6}});
    QTest::newRow("AG==1 overlap 4") << quint32(0x1) << QList<quint32>({0x400, 0x402, 0x404}) << QList<QPair<quint32, quint32> >({{0x400, 8}});
    QTest::newRow("AG==1 overlap 5") << quint32(0x1) << QList<quint32>({0x400, 0x404, 0x402}) << QList<QPair<quint32, quint32> >({{0x400, 8}});
    QTest::newRow("AG==2 no-overlap") << quint32(0x2) << QList<quint32>({0x200, 0x202, 0x204}) << QList<QPair<quint32, quint32> >({{0x200, 4}, {0x202, 4}, {0x204, 4}});
    QTest::newRow("AG==2 overlap 1") << quint32(0x2) << QList<quint32>({0x200, 0x203, 0x204}) << QList<QPair<quint32, quint32> >({{0x200, 4}, {0x203, 6}});
    QTest::newRow("AG==2 overlap 2") << quint32(0x2) << QList<quint32>({0x200, 0x204, 0x203}) << QList<QPair<quint32, quint32> >({{0x200, 4}, {0x203, 6}});
    QTest::newRow("AG==2 overlap 3") << quint32(0x2) << QList<quint32>({0x203, 0x204, 0x200}) << QList<QPair<quint32, quint32> >({{0x200, 4}, {0x203, 6}});
    QTest::newRow("AG==2 overlap 4") << quint32(0x2) << QList<quint32>({0x200, 0x201, 0x202}) << QList<QPair<quint32, quint32> >({{0x200, 8}});
    QTest::newRow("AG==2 overlap 5") << quint32(0x2) << QList<quint32>({0x200, 0x202, 0x201}) << QList<QPair<quint32, quint32> >({{0x200, 8}});
}

/**
 * @brief Check construction of memory range table when overlapped ranges exist
 */
void Test::setupOverlap()
{
    QFETCH(quint32, ag);
    QFETCH(QList<quint32>, base);
    QFETCH(ListDescList, lists);

    updateAg(ag);
    std::shared_ptr<MemoryRangeTable> table(new MemoryRangeTable(ag, this));
    table->setConnection(mConn);

    std::vector<ScalarMemoryRange *> range(base.size());
    for(int idx = 0; idx < base.size(); ++idx)
    {
        range[idx] = qobject_cast<ScalarMemoryRange *>(table->addRange(MemoryRange::U32, {base[idx], 0}, 1, true));
        QVERIFY(range[idx] != nullptr);
    }
    ListDescList tableLists;
    for(auto tableList : table->getLists())
        tableLists.append({tableList->base().addr, tableList->size()});
    QCOMPARE(tableLists.size(), lists.size());
    if(tableLists != lists)
    {
        for(int idx = 0; idx < tableLists.size(); ++idx)
            qDebug() << QString().sprintf("List %d: expected %x+%x, got %x+%x", idx, lists[idx].first, lists[idx].second, tableLists[idx].first, tableLists[idx].second);
        QFAIL("MemoryRangeLists do not match");
    }
}

void Test::uploadOverlap_data()
{
    QTest::addColumn<quint32>("ag");
    QTest::addColumn<QList<quint32>>("readOrder");
    QTest::addColumn<QList<bool>>("expectValid");
    QTest::newRow("AG==1 order 0,2") << quint32(0x1) << QList<quint32>({0, 2}) << QList<bool>({true, true, true});
    QTest::newRow("AG==1 order 0,1,2") << quint32(0x1) << QList<quint32>({0, 1, 2}) << QList<bool>({true, true, true});
    QTest::newRow("AG==1 order 2,0") << quint32(0x1) << QList<quint32>({2, 0}) << QList<bool>({true, true, true});
    QTest::newRow("AG==1 order 0") << quint32(0x1) << QList<quint32>({0}) << QList<bool>({true, false, false});
    QTest::newRow("AG==1 order 2") << quint32(0x1) << QList<quint32>({2}) << QList<bool>({false, false, true});
    QTest::newRow("AG==1 order 0,1") << quint32(0x1) << QList<quint32>({0,1}) << QList<bool>({true, true, false});
    QTest::newRow("AG==1 order 2,0") << quint32(0x1) << QList<quint32>({2, 0}) << QList<bool>({true, true, true});
    QTest::newRow("AG==2 order 0,2") << quint32(0x2) << QList<quint32>({0, 2}) << QList<bool>({true, true, true});
    QTest::newRow("AG==2 order 0,1,2") << quint32(0x2) << QList<quint32>({0, 1, 2}) << QList<bool>({true, true, true});
    QTest::newRow("AG==2 order 2,0") << quint32(0x2) << QList<quint32>({2, 0}) << QList<bool>({true, true, true});
    QTest::newRow("AG==2 order 0") << quint32(0x2) << QList<quint32>({0}) << QList<bool>({true, false, false});
    QTest::newRow("AG==2 order 2") << quint32(0x2) << QList<quint32>({2}) << QList<bool>({false, false, true});
    QTest::newRow("AG==2 order 0,1") << quint32(0x2) << QList<quint32>({0,1}) << QList<bool>({true, true, false});
}

/**
 * @brief Make sure read caching works properly
 */
void Test::uploadOverlap()
{
    QFETCH(quint32, ag);
    QFETCH(QList<quint32>, readOrder);
    QFETCH(QList<bool>, expectValid);

    updateAg(ag);
    std::shared_ptr<MemoryRangeTable> table(new MemoryRangeTable(ag, this));
    table->setConnection(mConn);

    static constexpr std::array<quint8, 8> DATA = {0x01, 0x02, 0xDE, 0xAD, 0xBE, 0xEF, 0x55, 0xAA};
    static constexpr std::array<quint32, 3> RANGEDATA = {0xADDE0201, 0xEFBEADDE, 0xAA55EFBE};
    std::copy(DATA.begin(), DATA.end(), mSlave->getMemRange(0).data());

    QCOMPARE(mConn->open(), OpResult::Success);

    std::vector<ScalarMemoryRange *> range(3);
    for(quint32 idx = 0; idx < range.size(); ++idx)
    {
        range[idx] = qobject_cast<ScalarMemoryRange *>(table->addRange(MemoryRange::U32, {(0x400 + 2 * idx) / ag, 0}, 1, true));
        QVERIFY(range[idx] != nullptr);
        QCOMPARE(range[idx]->value().isNull(), true);
    }

    for(quint32 rangeIdx : readOrder)
        range[rangeIdx]->refresh();

    for(quint32 idx = 0; idx < range.size(); ++idx)
    {
        if(expectValid[idx])
        {
            QCOMPARE(range[idx]->value().isNull(), false);
            QCOMPARE(range[idx]->value().toUInt(), RANGEDATA[idx]);
        }
        else
        {
            QCOMPARE(range[idx]->value().isNull(), true);
        }
    }
}

}
}