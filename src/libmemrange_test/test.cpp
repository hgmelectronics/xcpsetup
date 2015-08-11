#include "test.h"
#include <memory>
#include <cxxabi.h>
#include <boost/crc.hpp>
#include "Xcp_ScalarMemoryRange.h"
#include "Xcp_TableMemoryRange.h"
#include "LinearSlot.h"
#include "Xcp_ScalarParam.h"
#include "Xcp_ParamRegistry.h"

#include <QPair>
#include <QTime>

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

void Test::updateAg(int ag)
{
    mSlave->setAg(ag);
    mSlave->setMaxBs(255/ag);
    mSlave->setPgmMaxBs(255/ag);
}

void Test::setWaitConnState(const MemoryRangeTable *table, Connection::State state)
{
    if(mConnFacade->state() == state)
        return;

    QSignalSpy spy(table, &MemoryRangeTable::connectionChanged);
    mConnFacade->setState(state);
    spy.wait(100);
}

void Test::initTestCase()
{
    mIntfc = new Interface::Loopback::Interface();
    if(QProcessEnvironment::systemEnvironment().value("XCP_PACKET_LOG", "0") == "1")
        mIntfc->setPacketLog(true);
    mConnFacade = new SetupTools::Xcp::ConnectionFacade(this);
    mConnFacade->setIntfc(mIntfc);
    mConnFacade->setTimeout(CONN_TIMEOUT);
    mConnFacade->setNvWriteTimeout(CONN_NVWRITE_TIMEOUT);
    mConnFacade->setResetTimeout(CONN_RESET_TIMEOUT);
    mConnFacade->setProgClearTimeout(CONN_PROGCLEAR_TIMEOUT);
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

    QCOMPARE(int(mConnFacade->state()), int(Xcp::Connection::State::Closed));

    updateAg(ag);
    std::shared_ptr<MemoryRangeTable> table(new MemoryRangeTable(ag, this));
    table->setConnectionFacade(mConnFacade);
    std::vector<quint8> &slaveMemRange = mSlave->getMemRange(0);
    std::vector<quint32 *> slaveMemRangeValue(base.size());
    for(int idx = 0; idx < base.size(); ++idx)
    {
        slaveMemRangeValue[idx] = reinterpret_cast<quint32 *>(slaveMemRange.data() + idx * sizeof(quint32));
        *slaveMemRangeValue[idx] = value[idx];
    }

    if(!constructBeforeOpen)
    {
        // call refresh after open
        setWaitConnState(table.get(), Xcp::Connection::State::CalMode);
        QCOMPARE(int(mConnFacade->state()), int(Xcp::Connection::State::CalMode));
    }
    std::vector<ScalarMemoryRange *> range(base.size());
    std::vector<std::shared_ptr<QSignalSpy>> rangeSpy;
    for(int idx = 0; idx < base.size(); ++idx)
    {
        range[idx] = qobject_cast<ScalarMemoryRange *>(table->addRange(MemoryRange::U32, {base[idx], 0}, 1, false));
        QVERIFY(range[idx] != nullptr);
        rangeSpy.emplace_back(new QSignalSpy(range[idx], &ScalarMemoryRange::valueChanged));
    }
    if(constructBeforeOpen)
    {
        setWaitConnState(table.get(), Xcp::Connection::State::CalMode);
        QCOMPARE(int(mConnFacade->state()), int(Xcp::Connection::State::CalMode));
    }
    else
    {
        for(int idx = 0; idx < base.size(); ++idx)
            range[idx]->refresh();
    }
    for(int idx = 0; idx < base.size(); ++idx)
    {
        if(range[idx]->value().isNull())    // still has a race condition, but just delays the test worst case
            rangeSpy[idx]->wait(100);       // need to make a SignalSpy equivalent that has thread locking primitives to allow atomic test and wait
        QCOMPARE(range[idx]->valid(), true);
        QCOMPARE(range[idx]->writable(), false);
        QCOMPARE(range[idx]->value().toUInt(), value[idx]);
    }

    setWaitConnState(table.get(), Xcp::Connection::State::Closed);
    QCOMPARE(int(mConnFacade->state()), int(Xcp::Connection::State::Closed));
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

    QCOMPARE(int(mConnFacade->state()), int(Xcp::Connection::State::Closed));

    updateAg(ag);
    std::shared_ptr<MemoryRangeTable> table(new MemoryRangeTable(ag, this));
    table->setConnectionFacade(mConnFacade);
    std::vector<quint8> &slaveMemRange = mSlave->getMemRange(0);
    std::vector<quint32 *> slaveMemRangeValue(base.size());
    for(int idx = 0; idx < base.size(); ++idx)
    {
        slaveMemRangeValue[idx] = reinterpret_cast<quint32 *>(slaveMemRange.data() + idx * sizeof(quint32));
        *slaveMemRangeValue[idx] = 0xFFFFFFFF;  // trick to make valueChanged get emitted later on initial load
    }

    std::vector<ScalarMemoryRange *> range(base.size());
    std::vector<std::shared_ptr<QSignalSpy>> rangeSpy;
    for(int idx = 0; idx < base.size(); ++idx)
    {
        range[idx] = qobject_cast<ScalarMemoryRange *>(table->addRange(MemoryRange::U32, {base[idx], 0}, 1, true));
        QVERIFY(range[idx] != nullptr);
        rangeSpy.emplace_back(new QSignalSpy(range[idx], &ScalarMemoryRange::valueChanged));
    }
    {
        setWaitConnState(table.get(), Xcp::Connection::State::CalMode);
        QCOMPARE(int(mConnFacade->state()), int(Xcp::Connection::State::CalMode));
    }
    for(int idx = 0; idx < base.size(); ++idx)
    {
        if(range[idx]->value().isNull())
            rangeSpy[idx]->wait(100);
        rangeSpy[idx]->clear();
        QCOMPARE(range[idx]->valid(), true);
        QCOMPARE(range[idx]->writable(), true);
        QCOMPARE(range[idx]->value().toUInt(), quint32(0xFFFFFFFF));
    }
    for(int idx = 0; idx < base.size(); ++idx)
        range[idx]->setValue(value[idx]);
    for(int idx = 0; idx < base.size(); ++idx)
    {
        if(range[idx]->value().toUInt() != value[idx])
            rangeSpy[idx]->wait(100);
        rangeSpy[idx]->clear();
        QCOMPARE(range[idx]->value().toUInt(), value[idx]);
        QCOMPARE(*slaveMemRangeValue[idx], value[idx]);
    }

    setWaitConnState(table.get(), Xcp::Connection::State::Closed);
    QCOMPARE(int(mConnFacade->state()), int(Xcp::Connection::State::Closed));
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
    table->setConnectionFacade(mConnFacade);

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
    QTest::addColumn<QList<quint32>>("expectValid");
    QTest::newRow("AG==1 order 0,2") << quint32(0x1) << QList<quint32>({0, 2}) << QList<quint32>({0, 1, 2});
    QTest::newRow("AG==1 order 0,1,2") << quint32(0x1) << QList<quint32>({0, 1, 2}) << QList<quint32>({0, 1, 2});
    QTest::newRow("AG==1 order 2,0") << quint32(0x1) << QList<quint32>({2, 0}) << QList<quint32>({2, 0, 1});
    QTest::newRow("AG==1 order 0") << quint32(0x1) << QList<quint32>({0}) << QList<quint32>({0});
    QTest::newRow("AG==1 order 2") << quint32(0x1) << QList<quint32>({2}) << QList<quint32>({2});
    QTest::newRow("AG==1 order 0,1") << quint32(0x1) << QList<quint32>({0, 1}) << QList<quint32>({0, 1});
    QTest::newRow("AG==2 order 0,2") << quint32(0x2) << QList<quint32>({0, 2}) << QList<quint32>({0, 1, 2});
    QTest::newRow("AG==2 order 0,1,2") << quint32(0x2) << QList<quint32>({0, 1, 2}) << QList<quint32>({0, 1, 2});
    QTest::newRow("AG==2 order 2,0") << quint32(0x2) << QList<quint32>({2, 0}) << QList<quint32>({2, 0, 1});
    QTest::newRow("AG==2 order 0") << quint32(0x2) << QList<quint32>({0}) << QList<quint32>({0});
    QTest::newRow("AG==2 order 2") << quint32(0x2) << QList<quint32>({2}) << QList<quint32>({2});
    QTest::newRow("AG==2 order 0,1") << quint32(0x2) << QList<quint32>({0, 1}) << QList<quint32>({0, 1});
}

/**
 * @brief Make sure read caching works properly
 */
void Test::uploadOverlap()
{
    QFETCH(quint32, ag);
    QFETCH(QList<quint32>, readOrder);
    QFETCH(QList<quint32>, expectValid);

    updateAg(ag);
    std::shared_ptr<MemoryRangeTable> table(new MemoryRangeTable(ag, this));
    table->setConnectionFacade(mConnFacade);

    static constexpr std::array<quint8, 8> DATA = {0x01, 0x02, 0xDE, 0xAD, 0xBE, 0xEF, 0x55, 0xAA};
    static constexpr std::array<quint32, 3> RANGEDATA = {0xADDE0201, 0xEFBEADDE, 0xAA55EFBE};
    std::copy(DATA.begin(), DATA.end(), mSlave->getMemRange(0).data());

    setWaitConnState(table.get(), Xcp::Connection::State::CalMode);
    QCOMPARE(mConnFacade->state(), Xcp::Connection::State::CalMode);

    std::vector<ScalarMemoryRange *> range(3);
    std::vector<std::shared_ptr<QSignalSpy>> rangeSpy;
    for(quint32 idx = 0; idx < range.size(); ++idx)
    {
        range[idx] = qobject_cast<ScalarMemoryRange *>(table->addRange(MemoryRange::U32, {(0x400 + 2 * idx) / ag, 0}, 1, true));
        QVERIFY(range[idx] != nullptr);
        QCOMPARE(range[idx]->value().isNull(), true);
        rangeSpy.emplace_back(new QSignalSpy(range[idx], &ScalarMemoryRange::valueChanged));
    }

    for(quint32 rangeIdx : readOrder)
        range[rangeIdx]->refresh();

    for(quint32 idx : expectValid)
    {
        if(range[idx]->value().isNull())
            rangeSpy[idx]->wait(100);
        QCOMPARE(range[idx]->value().isNull(), false);
        QCOMPARE(range[idx]->value().toUInt(), RANGEDATA[idx]);
    }

    for(quint32 idx = 0; idx < range.size(); ++idx)
    {
        if(!expectValid.contains(idx))
            QCOMPARE(range[idx]->value().isNull(), true);
    }

    setWaitConnState(table.get(), Xcp::Connection::State::Closed);
    QCOMPARE(int(mConnFacade->state()), int(Xcp::Connection::State::Closed));
}

void Test::uploadTableNoOverlap_data()
{
    QTest::addColumn<quint32>("ag");
    QTest::addColumn<quint32>("base");
    QTest::addColumn<QVector<quint32> >("value");
    QTest::addColumn<bool>("constructBeforeOpen");
    QTest::newRow("AG==1 cbo=0") << quint32(0x1) << quint32(0x400) << QVector<quint32>({0xDEADBEEF, 0x7F, 0x01234567, 0x89ABCDEF}) << false;
    QTest::newRow("AG==1 cbo=1") << quint32(0x1) << quint32(0x400) << QVector<quint32>({0xDEADBEEF, 0x7F, 0x01234567, 0x89ABCDEF}) << true;
    QTest::newRow("AG==2 cbo=0") << quint32(0x2) << quint32(0x200) << QVector<quint32>({0xDEADBEEF, 0x7F, 0x01234567, 0x89ABCDEF}) << false;
    QTest::newRow("AG==2 cbo=1") << quint32(0x2) << quint32(0x200) << QVector<quint32>({0xDEADBEEF, 0x7F, 0x01234567, 0x89ABCDEF}) << true;
    QTest::newRow("AG==4 cbo=0") << quint32(0x4) << quint32(0x100) << QVector<quint32>({0xDEADBEEF, 0x7F, 0x01234567, 0x89ABCDEF}) << false;
    QTest::newRow("AG==4 cbo=1") << quint32(0x4) << quint32(0x100) << QVector<quint32>({0xDEADBEEF, 0x7F, 0x01234567, 0x89ABCDEF}) << true;
}

void Test::uploadTableNoOverlap()
{
    QFETCH(quint32, ag);
    QFETCH(quint32, base);
    QFETCH(QVector<quint32>, value);
    QFETCH(bool, constructBeforeOpen);

    QCOMPARE(int(mConnFacade->state()), int(Xcp::Connection::State::Closed));

    updateAg(ag);
    std::shared_ptr<MemoryRangeTable> table(new MemoryRangeTable(ag, this));
    table->setConnectionFacade(mConnFacade);
    std::vector<quint8> &slaveMemRange = mSlave->getMemRange(0);
    Q_ASSERT(base * ag >= mSlave->getMemRangeBase(0).addr);
    quint32 memRangeOffset = base * ag - mSlave->getMemRangeBase(0).addr;
    std::copy(value.begin(), value.end(), reinterpret_cast<decltype(value)::value_type *>(slaveMemRange.data() + memRangeOffset));

    if(!constructBeforeOpen)
    {
        // call refresh after open
        setWaitConnState(table.get(), Xcp::Connection::State::CalMode);
        QCOMPARE(int(mConnFacade->state()), int(Xcp::Connection::State::CalMode));
    }
    TableMemoryRange *range = qobject_cast<TableMemoryRange *>(table->addRange(MemoryRange::U32, {base, 0}, value.size(), false));
    QVERIFY(range != nullptr);
    QSignalSpy rangeSpy(range, &TableMemoryRange::valueChanged);
    if(constructBeforeOpen)
    {
        setWaitConnState(table.get(), Xcp::Connection::State::CalMode);
        QCOMPARE(int(mConnFacade->state()), int(Xcp::Connection::State::CalMode));
    }
    else
    {
        range->refresh();
    }
    for(int idx = 0; idx < value.size(); ++idx)
    {
        if(range->data()[idx].isNull())    // still has a race condition, but just delays the test worst case
            rangeSpy.wait(100);       // need to make a SignalSpy equivalent that has thread locking primitives to allow atomic test and wait
    }

    QCOMPARE(range->valid(), true);
    QCOMPARE(range->writable(), false);
    for(int idx = 0; idx < value.size(); ++idx)
        QCOMPARE(range->data()[idx].toUInt(), value[idx]);

    setWaitConnState(table.get(), Xcp::Connection::State::Closed);
    QCOMPARE(int(mConnFacade->state()), int(Xcp::Connection::State::Closed));
}

void Test::downloadTableNoOverlap_data()
{
    QTest::addColumn<quint32>("ag");
    QTest::addColumn<quint32>("base");
    QTest::addColumn<QVector<quint32> >("value");
    QTest::addColumn<bool>("useSetDataRange");
    QTest::newRow("AG==1 sdr=0") << quint32(0x1) << quint32(0x400) << QVector<quint32>({0xDEADBEEF, 0x7F, 0x01234567, 0x89ABCDEF}) << false;
    QTest::newRow("AG==1 sdr=1") << quint32(0x1) << quint32(0x400) << QVector<quint32>({0xDEADBEEF, 0x7F, 0x01234567, 0x89ABCDEF}) << true;
    QTest::newRow("AG==2 sdr=0") << quint32(0x2) << quint32(0x200) << QVector<quint32>({0xDEADBEEF, 0x7F, 0x01234567, 0x89ABCDEF}) << false;
    QTest::newRow("AG==2 sdr=1") << quint32(0x2) << quint32(0x200) << QVector<quint32>({0xDEADBEEF, 0x7F, 0x01234567, 0x89ABCDEF}) << true;
    QTest::newRow("AG==4 sdr=0") << quint32(0x4) << quint32(0x100) << QVector<quint32>({0xDEADBEEF, 0x7F, 0x01234567, 0x89ABCDEF}) << false;
    QTest::newRow("AG==4 sdr=1") << quint32(0x4) << quint32(0x100) << QVector<quint32>({0xDEADBEEF, 0x7F, 0x01234567, 0x89ABCDEF}) << true;
}

void Test::downloadTableNoOverlap()
{
    QFETCH(quint32, ag);
    QFETCH(quint32, base);
    QFETCH(QVector<quint32>, value);
    QFETCH(bool, useSetDataRange);

    QCOMPARE(int(mConnFacade->state()), int(Xcp::Connection::State::Closed));

    updateAg(ag);
    std::shared_ptr<MemoryRangeTable> table(new MemoryRangeTable(ag, this));
    table->setConnectionFacade(mConnFacade);
    std::vector<quint8> &slaveMemRange = mSlave->getMemRange(0);
    Q_ASSERT(base * ag >= mSlave->getMemRangeBase(0).addr);
    quint32 memRangeOffset = base * ag - mSlave->getMemRangeBase(0).addr;
    quint32 *slaveMemRangeValueBase = reinterpret_cast<decltype(value)::value_type *>(slaveMemRange.data() + memRangeOffset);
    boost::iterator_range<quint32 *> slaveMemRangeValue(slaveMemRangeValueBase, slaveMemRangeValueBase + value.size());
    std::fill(slaveMemRangeValue.begin(), slaveMemRangeValue.end(), 0xFFFFFFFF);  // trick to make valueChanged get emitted later on initial load

    TableMemoryRange *range = qobject_cast<TableMemoryRange *>(table->addRange(MemoryRange::U32, {base, 0}, value.size(), true));
    QVERIFY(range != nullptr);
    QSignalSpy rangeSpy(range, &TableMemoryRange::valueChanged);
    {
        setWaitConnState(table.get(), Xcp::Connection::State::CalMode);
        QCOMPARE(int(mConnFacade->state()), int(Xcp::Connection::State::CalMode));
    }
    for(int idx = 0; idx < value.size(); ++idx)
    {
        if(range->data()[idx].isNull())
            rangeSpy.wait(100);
    }
    rangeSpy.clear();
    QCOMPARE(range->valid(), true);
    QCOMPARE(range->writable(), true);
    for(int idx = 0; idx < value.size(); ++idx)
    {
        QCOMPARE(range->data()[idx].toUInt(), quint32(0xFFFFFFFF));
    }
    if(useSetDataRange)
    {
        QList<QVariant> valueList;
        for(quint32 valueElem : value)
            valueList.push_back(valueElem);
        range->setDataRange(valueList, 0);
    }
    else
    {
        for(int idx = 0; idx < value.size(); ++idx)
            range->setData(value[idx], idx);
    }
    for(int idx = 0; idx < value.size(); ++idx)
    {
        if(range->data()[idx] != value[idx])
            rangeSpy.wait(100);
    }
    rangeSpy.clear();
    for(int idx = 0; idx < value.size(); ++idx)
    {
        QCOMPARE(range->data()[idx].toUInt(), value[idx]);
        QCOMPARE(slaveMemRangeValue[idx], value[idx]);
    }

    setWaitConnState(table.get(), Xcp::Connection::State::Closed);
    QCOMPARE(int(mConnFacade->state()), int(Xcp::Connection::State::Closed));
}

void Test::uploadTableSub_data()
{
    QTest::addColumn<quint32>("ag");
    QTest::addColumn<quint32>("base");
    QTest::addColumn<QVector<quint32> >("value");
    QTest::newRow("AG==1") << quint32(0x1) << quint32(0x400) << QVector<quint32>({0xDEADBEEF, 0x7F, 0x01234567, 0x89ABCDEF});
    QTest::newRow("AG==2") << quint32(0x2) << quint32(0x200) << QVector<quint32>({0xDEADBEEF, 0x7F, 0x01234567, 0x89ABCDEF});
    QTest::newRow("AG==4") << quint32(0x4) << quint32(0x100) << QVector<quint32>({0xDEADBEEF, 0x7F, 0x01234567, 0x89ABCDEF});
}

void Test::uploadTableSub()
{
    QFETCH(quint32, ag);
    QFETCH(quint32, base);
    QFETCH(QVector<quint32>, value);

    QCOMPARE(int(mConnFacade->state()), int(Xcp::Connection::State::Closed));

    updateAg(ag);
    std::shared_ptr<MemoryRangeTable> table(new MemoryRangeTable(ag, this));
    table->setConnectionFacade(mConnFacade);
    std::vector<quint8> &slaveMemRange = mSlave->getMemRange(0);
    Q_ASSERT(base * ag >= mSlave->getMemRangeBase(0).addr);
    quint32 memRangeOffset = base * ag - mSlave->getMemRangeBase(0).addr;
    std::copy(value.begin(), value.end(), reinterpret_cast<decltype(value)::value_type *>(slaveMemRange.data() + memRangeOffset));

    // call refresh after open
    setWaitConnState(table.get(), Xcp::Connection::State::CalMode);
    QCOMPARE(int(mConnFacade->state()), int(Xcp::Connection::State::CalMode));

    TableMemoryRange *range = qobject_cast<TableMemoryRange *>(table->addRange(MemoryRange::U32, {base, 0}, value.size(), false));
    TableMemoryRange *subRange = qobject_cast<TableMemoryRange *>(table->addRange(MemoryRange::U32, {base + sizeof(quint32) / ag, 0}, value.size() - 2, false));
    QVERIFY(range != nullptr);
    QVERIFY(subRange != nullptr);
    QSignalSpy rangeSpy(range, &TableMemoryRange::valueChanged);
    subRange->refresh();
    for(int idx = 1; idx < (value.size() - 1); ++idx)
    {
        if(range->data()[idx].isNull())
            rangeSpy.wait(100);
    }

    QCOMPARE(range->valid(), false);
    QCOMPARE(subRange->valid(), true);
    QCOMPARE(range->writable(), false);
    QCOMPARE(range->data().first().isNull(), true);
    for(int idx = 1; idx < (value.size() - 1); ++idx)
        QCOMPARE(range->data()[idx].toUInt(), value[idx]);
    QCOMPARE(range->data().last().isNull(), true);

    setWaitConnState(table.get(), Xcp::Connection::State::Closed);
    QCOMPARE(int(mConnFacade->state()), int(Xcp::Connection::State::Closed));
}

void Test::uploadTableOverlap_data()
{
    QTest::addColumn<quint32>("ag");
    QTest::addColumn<quint32>("base");
    QTest::addColumn<QVector<quint32> >("value");
    QTest::newRow("AG==1") << quint32(0x1) << quint32(0x400) << QVector<quint32>({0xDEADBEEF, 0x7F, 0x01234567, 0x89ABCDEF});
    QTest::newRow("AG==2") << quint32(0x2) << quint32(0x200) << QVector<quint32>({0xDEADBEEF, 0x7F, 0x01234567, 0x89ABCDEF});
    QTest::newRow("AG==4") << quint32(0x4) << quint32(0x100) << QVector<quint32>({0xDEADBEEF, 0x7F, 0x01234567, 0x89ABCDEF});
}

void Test::uploadTableOverlap()
{
    QFETCH(quint32, ag);
    QFETCH(quint32, base);
    QFETCH(QVector<quint32>, value);

    QCOMPARE(int(mConnFacade->state()), int(Xcp::Connection::State::Closed));

    updateAg(ag);
    std::shared_ptr<MemoryRangeTable> table(new MemoryRangeTable(ag, this));
    table->setConnectionFacade(mConnFacade);
    std::vector<quint8> &slaveMemRange = mSlave->getMemRange(0);
    Q_ASSERT(base * ag >= mSlave->getMemRangeBase(0).addr);
    quint32 memRangeOffset = base * ag - mSlave->getMemRangeBase(0).addr;
    std::copy(value.begin(), value.end(), reinterpret_cast<decltype(value)::value_type *>(slaveMemRange.data() + memRangeOffset));

    // call refresh after open
    setWaitConnState(table.get(), Xcp::Connection::State::CalMode);
    QCOMPARE(int(mConnFacade->state()), int(Xcp::Connection::State::CalMode));

    TableMemoryRange *range = qobject_cast<TableMemoryRange *>(table->addRange(MemoryRange::U32, {base, 0}, value.size(), false));
    QVERIFY(range != nullptr);
    QSignalSpy rangeSpy(range, &TableMemoryRange::valueChanged);
    quint32 tableAgs = value.size() * sizeof(quint32) / ag;
    Q_ASSERT(tableAgs % 2 == 0);
    mConnFacade->upload({base, 0}, (tableAgs / 2 - 1) * ag);
    if(range->data().first().isNull())
        rangeSpy.wait(100);
    rangeSpy.clear();
    mConnFacade->upload({base + tableAgs / 2 - 1, 0}, (tableAgs / 2 + 1) * ag);
    if(range->data().last().isNull())
        rangeSpy.wait(100);
    rangeSpy.clear();

    QCOMPARE(range->valid(), true);
    QCOMPARE(range->writable(), false);
    for(int idx = 0; idx < value.size(); ++idx)
        QCOMPARE(range->data()[idx].toUInt(), value[idx]);

    setWaitConnState(table.get(), Xcp::Connection::State::Closed);
    QCOMPARE(int(mConnFacade->state()), int(Xcp::Connection::State::Closed));
}

void Test::linearSlotToFloat_data()
{
    QTest::addColumn<int>("base");
    QTest::addColumn<int>("precision");
    QTest::addColumn<int>("storageType");
    QTest::addColumn<double>("engrA");
    QTest::addColumn<double>("engrB");
    QTest::addColumn<double>("oorEngr");
    QTest::addColumn<double>("rawA");
    QTest::addColumn<double>("rawB");
    QTest::addColumn<double>("oorRaw");
    QTest::addColumn<QVariant>("rawIn");
    QTest::addColumn<double>("engrOut");


    QTest::newRow("01") << 10 << 0 << int(QMetaType::UInt) << 0.0 << 64255.0 << NAN << 0.0 << 64255.0 << 65535.0 << QVariant(70000) << NAN;
    QTest::newRow("02") << 10 << 0 << int(QMetaType::UInt) << 0.0 << 64255.0 << NAN << 0.0 << 64255.0 << 65535.0 << QVariant(40000) << 40000.0;
    QTest::newRow("03") << 10 << 0 << int(QMetaType::UInt) << 0.0 << 64255.0 << NAN << 0.0 << 64255.0 << 65535.0 << QVariant(0) << 0.0;
    QTest::newRow("04") << 10 << 0 << int(QMetaType::UInt) << 0.0 << 64255.0 << NAN << 0.0 << 64255.0 << 65535.0 << QVariant(64255) << 64255.0;
    QTest::newRow("05") << 10 << 0 << int(QMetaType::UInt) << 0.0 << 64.255 << NAN << 0.0 << 64255.0 << 65535.0 << QVariant(40000) << 40.0;
    QTest::newRow("06") << 10 << 0 << int(QMetaType::UInt) << 0.0 << 64.255 << NAN << 0.0 << 64255.0 << 65535.0 << QVariant(0) << 0.0;
    QTest::newRow("07") << 10 << 0 << int(QMetaType::UInt) << 0.0 << 64.255 << NAN << 0.0 << 64255.0 << 65535.0 << QVariant(64255) << 64.255;
    QTest::newRow("08") << 10 << 0 << int(QMetaType::UInt) << 0.0 << 64.255 << NAN << 0.0 << 64255.0 << 65535.0 << QVariant(402) << 0.402;
    QTest::newRow("09") << 10 << 0 << int(QMetaType::UInt) << 1.0 << 0.0 << NAN << 0.0 << 100.0 << 65535.0 << QVariant(100) << 0.0;
    QTest::newRow("10") << 10 << 0 << int(QMetaType::UInt) << 1.0 << 0.0 << NAN << 0.0 << 100.0 << 65535.0 << QVariant(0) << 1.0;
    QTest::newRow("11") << 10 << 0 << int(QMetaType::UInt) << 1.0 << 0.0 << NAN << 0.0 << 100.0 << 65535.0 << QVariant(25) << 0.75;
    QTest::newRow("12") << 10 << 0 << int(QMetaType::UInt) << 1.0 << 0.0 << NAN << 0.0 << 100.0 << 65535.0 << QVariant(101) << NAN;
}

void Test::linearSlotToFloat()
{
    QFETCH(int, base);
    QFETCH(int, precision);
    QFETCH(int, storageType);
    QFETCH(double, engrA);
    QFETCH(double, engrB);
    QFETCH(double, oorEngr);
    QFETCH(double, rawA);
    QFETCH(double, rawB);
    QFETCH(double, oorRaw);
    QFETCH(QVariant, rawIn);
    QFETCH(double, engrOut);

    LinearSlot slot;

    slot.base = base;
    slot.precision = precision;
    slot.storageType = storageType;
    slot.engrA = engrA;
    slot.engrB = engrB;
    slot.oorEngr = oorEngr;
    slot.rawA = rawA;
    slot.rawB = rawB;
    slot.oorRaw = oorRaw;

    if(std::isnan(engrOut))
        QVERIFY(std::isnan(slot.toFloat(rawIn)));
    else
        QCOMPARE(slot.toFloat(rawIn), engrOut);
}


void Test::linearSlotToString_data()
{
    QTest::addColumn<int>("base");
    QTest::addColumn<int>("precision");
    QTest::addColumn<int>("storageType");
    QTest::addColumn<double>("engrA");
    QTest::addColumn<double>("engrB");
    QTest::addColumn<double>("oorEngr");
    QTest::addColumn<double>("rawA");
    QTest::addColumn<double>("rawB");
    QTest::addColumn<double>("oorRaw");
    QTest::addColumn<QVariant>("rawIn");
    QTest::addColumn<QString>("engrOut");


    QTest::newRow("01") << 10 << 0 << int(QMetaType::UInt) << 0.0 << 64255.0 << NAN << 0.0 << 64255.0 << 65535.0 << QVariant(70000) << QString("nan");
    QTest::newRow("02") << 10 << 0 << int(QMetaType::UInt) << 0.0 << 64255.0 << NAN << 0.0 << 64255.0 << 65535.0 << QVariant(40000) << QString("40000");
    QTest::newRow("03") << 10 << 1 << int(QMetaType::UInt) << 0.0 << 64255.0 << NAN << 0.0 << 64255.0 << 65535.0 << QVariant(0) << QString("0.0");
    QTest::newRow("04") << 10 << 1 << int(QMetaType::UInt) << 0.0 << 64255.0 << NAN << 0.0 << 64255.0 << 65535.0 << QVariant(64255) << QString("64255.0");
    QTest::newRow("05") << 10 << 2 << int(QMetaType::UInt) << 0.0 << 64.255 << NAN << 0.0 << 64255.0 << 65535.0 << QVariant(40000) << QString("40.00");
    QTest::newRow("06") << 10 << 2 << int(QMetaType::UInt) << 0.0 << 64.255 << NAN << 0.0 << 64255.0 << 65535.0 << QVariant(0) << QString("0.00");
    QTest::newRow("07") << 10 << 2 << int(QMetaType::UInt) << 0.0 << 64.255 << NAN << 0.0 << 64255.0 << 65535.0 << QVariant(64255) << QString("64.25");
    QTest::newRow("08") << 10 << 2 << int(QMetaType::UInt) << 0.0 << 64.255 << NAN << 0.0 << 64255.0 << 65535.0 << QVariant(402) << QString("0.40");
    QTest::newRow("09") << 10 << 3 << int(QMetaType::UInt) << 1.0 << 0.0 << NAN << 0.0 << 100.0 << 65535.0 << QVariant(100) << QString("0.000");
    QTest::newRow("10") << 10 << 3 << int(QMetaType::UInt) << 1.0 << 0.0 << NAN << 0.0 << 100.0 << 65535.0 << QVariant(0) << QString("1.000");
    QTest::newRow("11") << 10 << 3 << int(QMetaType::UInt) << 1.0 << 0.0 << NAN << 0.0 << 100.0 << 65535.0 << QVariant(25) << QString("0.750");
    QTest::newRow("12") << 10 << 3 << int(QMetaType::UInt) << 1.0 << 0.0 << NAN << 0.0 << 100.0 << 65535.0 << QVariant(101) << QString("nan");
}

void Test::linearSlotToString()
{
    QFETCH(int, base);
    QFETCH(int, precision);
    QFETCH(int, storageType);
    QFETCH(double, engrA);
    QFETCH(double, engrB);
    QFETCH(double, oorEngr);
    QFETCH(double, rawA);
    QFETCH(double, rawB);
    QFETCH(double, oorRaw);
    QFETCH(QVariant, rawIn);
    QFETCH(QString, engrOut);

    LinearSlot slot;

    slot.base = base;
    slot.precision = precision;
    slot.storageType = storageType;
    slot.engrA = engrA;
    slot.engrB = engrB;
    slot.oorEngr = oorEngr;
    slot.rawA = rawA;
    slot.rawB = rawB;
    slot.oorRaw = oorRaw;

    QCOMPARE(slot.toString(rawIn), engrOut);
}

void Test::linearSlotToRaw_data()
{
    QTest::addColumn<int>("base");
    QTest::addColumn<int>("precision");
    QTest::addColumn<int>("storageType");
    QTest::addColumn<double>("engrA");
    QTest::addColumn<double>("engrB");
    QTest::addColumn<double>("oorEngr");
    QTest::addColumn<double>("rawA");
    QTest::addColumn<double>("rawB");
    QTest::addColumn<double>("oorRaw");
    QTest::addColumn<QVariant>("engrIn");
    QTest::addColumn<QVariant>("rawOut");


    QTest::newRow("01") << 10 << 0 << int(QMetaType::UInt) << 0.0 << 64255.0 << NAN << 0.0 << 64255.0 << 65535.0 << QVariant("70000") << QVariant(quint32(65535));
    QTest::newRow("02") << 10 << 0 << int(QMetaType::UInt) << 0.0 << 64255.0 << NAN << 0.0 << 64255.0 << 65535.0 << QVariant("40000.0") << QVariant(quint32(40000));
    QTest::newRow("03") << 10 << 0 << int(QMetaType::UInt) << 0.0 << 64255.0 << NAN << 0.0 << 64255.0 << 65535.0 << QVariant(0.0) << QVariant(quint32(0));
    QTest::newRow("04") << 16 << 0 << int(QMetaType::UInt) << 0.0 << 64255.0 << NAN << 0.0 << 64255.0 << 65535.0 << QVariant("FAFF") << QVariant(quint32(0xFAFF));
    QTest::newRow("05") << 10 << 0 << int(QMetaType::UInt) << 0.0 << 64.255 << NAN << 0.0 << 64255.0 << 65535.0 << QVariant(40.0) << QVariant(quint32(40000));
    QTest::newRow("06") << 10 << 0 << int(QMetaType::UInt) << 0.0 << 64.255 << NAN << 0.0 << 64255.0 << 65535.0 << QVariant(0) << QVariant(quint32(0));
    QTest::newRow("07") << 10 << 0 << int(QMetaType::UInt) << 0.0 << 64.255 << NAN << 0.0 << 64255.0 << 65535.0 << QVariant("64.255") << QVariant(quint32(64255));
    QTest::newRow("08") << 10 << 0 << int(QMetaType::UInt) << 0.0 << 64.255 << NAN << 0.0 << 64255.0 << 65535.0 << QVariant(0.402) << QVariant(quint32(402));
    QTest::newRow("09") << 10 << 0 << int(QMetaType::UInt) << 1.0 << 0.0 << NAN << 0.0 << 100.0 << 65535.0 << QVariant(0.0) << QVariant(quint32(100));
    QTest::newRow("10") << 10 << 0 << int(QMetaType::UInt) << 1.0 << 0.0 << NAN << 0.0 << 100.0 << 65535.0 << QVariant("1") << QVariant(quint32(0));
    QTest::newRow("11") << 10 << 0 << int(QMetaType::UInt) << 1.0 << 0.0 << NAN << 0.0 << 100.0 << 65535.0 << QVariant(0.75) << QVariant(quint32(25));
    QTest::newRow("12") << 10 << 0 << int(QMetaType::UInt) << 1.0 << 0.0 << NAN << 0.0 << 100.0 << 65535.0 << QVariant("1.2") << QVariant(quint32(65535));
}

void Test::linearSlotToRaw()
{
    QFETCH(int, base);
    QFETCH(int, precision);
    QFETCH(int, storageType);
    QFETCH(double, engrA);
    QFETCH(double, engrB);
    QFETCH(double, oorEngr);
    QFETCH(double, rawA);
    QFETCH(double, rawB);
    QFETCH(double, oorRaw);
    QFETCH(QVariant, engrIn);
    QFETCH(QVariant, rawOut);

    LinearSlot slot;

    slot.base = base;
    slot.precision = precision;
    slot.storageType = storageType;
    slot.engrA = engrA;
    slot.engrB = engrB;
    slot.oorEngr = oorEngr;
    slot.rawA = rawA;
    slot.rawB = rawB;
    slot.oorRaw = oorRaw;

    QCOMPARE(slot.toRaw(engrIn), rawOut);
}

void Test::paramDownloadUpload_data()
{
    QTest::addColumn<int>("ag");
    QTest::addColumn<double>("floatEngr");
    QTest::addColumn<QString>("stringEngr");
    QTest::addColumn<quint32>("raw");

    QTest::newRow("64.255 ag==1") << 1 << 64.255 << "64.255" << quint32(64255);
    QTest::newRow("64.000 ag==1") << 1 << 64.0 << "64.000" << quint32(64000);
    QTest::newRow("00.001 ag==1") << 1 << 0.001 << "0.001" << quint32(1);
    QTest::newRow("00.000 ag==1") << 1 << 0.0 << "0.000" << quint32(0);
    QTest::newRow("64.255 ag==2") << 2 << 64.255 << "64.255" << quint32(64255);
    QTest::newRow("64.000 ag==2") << 2 << 64.0 << "64.000" << quint32(64000);
    QTest::newRow("00.001 ag==2") << 2 << 0.001 << "0.001" << quint32(1);
    QTest::newRow("00.000 ag==2") << 2 << 0.0 << "0.000" << quint32(0);
    QTest::newRow("64.255 ag==4") << 4 << 64.255 << "64.255" << quint32(64255);
    QTest::newRow("64.000 ag==4") << 4 << 64.0 << "64.000" << quint32(64000);
    QTest::newRow("00.001 ag==4") << 4 << 0.001 << "0.001" << quint32(1);
    QTest::newRow("00.000 ag==4") << 4 << 0.0 << "0.000" << quint32(0);
}

void Test::paramDownloadUpload()
{
    QFETCH(int, ag);
    QFETCH(double, floatEngr);
    QFETCH(QString, stringEngr);
    QFETCH(quint32, raw);

    quint32 base = 0x400 / ag;

    static const QString KEY("fnord");

    LinearSlot slot;
    slot.base = 10;
    slot.precision = 3;
    slot.storageType = int(QMetaType::UInt);
    slot.engrA = 0.0;
    slot.engrB = 64.255;
    slot.oorEngr = NAN;
    slot.rawA = 0;
    slot.rawB = 64255;
    slot.oorRaw = 65535;

    QCOMPARE(int(mConnFacade->state()), int(Xcp::Connection::State::Closed));

    updateAg(ag);
    std::shared_ptr<ParamRegistry> registry(new ParamRegistry(ag));
    registry->setConnectionFacade(mConnFacade);
    std::vector<quint8> &slaveMemRange = mSlave->getMemRange(0);
    Q_ASSERT(base * ag == mSlave->getMemRangeBase(0).addr);
    quint32 *slaveMemRangeValue = reinterpret_cast<quint32 *>(slaveMemRange.data());
    *slaveMemRangeValue = 0xFFFFFFFF;  // trick to make valueChanged get emitted later on initial load

    ScalarParam *param = qobject_cast<ScalarParam *>(registry->addParam(MemoryRange::MemoryRangeType::U32, {base, 0}, 1, true, false, &slot, KEY));
    QCOMPARE(param, qobject_cast<ScalarParam *>(registry->getParam(KEY)));
    QSignalSpy paramSpy(param, &ScalarParam::valChanged);

    {
        setWaitConnState(registry->table(), Xcp::Connection::State::CalMode);
        QCOMPARE(int(mConnFacade->state()), int(Xcp::Connection::State::CalMode));
    }

    paramSpy.wait(100);
    paramSpy.clear();
    QVERIFY(std::isnan(param->floatVal()));
    QCOMPARE(param->stringVal(), QString("nan"));

    param->setFloatVal(floatEngr);
    paramSpy.wait(100);
    paramSpy.clear();
    QCOMPARE(param->floatVal(), floatEngr);
    QCOMPARE(param->stringVal(), stringEngr);
    QCOMPARE(*slaveMemRangeValue, raw);

    param->setStringVal("nan");
    paramSpy.wait(100);
    paramSpy.clear();
    QVERIFY(std::isnan(param->floatVal()));
    QCOMPARE(param->stringVal(), QString("nan"));

    param->setStringVal(stringEngr);
    paramSpy.wait(100);
    paramSpy.clear();
    QCOMPARE(param->floatVal(), floatEngr);
    QCOMPARE(param->stringVal(), stringEngr);
    QCOMPARE(*slaveMemRangeValue, raw);

    setWaitConnState(registry->table(), Xcp::Connection::State::Closed);
    QCOMPARE(int(mConnFacade->state()), int(Xcp::Connection::State::Closed));
}

}
}
