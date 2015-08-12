#include "test.h"
#include <memory>
#include "Xcp_ScalarMemoryRange.h"
#include "Xcp_TableMemoryRange.h"
#include "LinearSlot.h"
#include "Xcp_ScalarParam.h"
#include "Xcp_ParamRegistry.h"

#include <QPair>
#include <QTime>

namespace SetupTools
{
namespace Xcp
{

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
    ScopeExit connCloser([this, table](){
        setWaitConnState(table.get(), Xcp::Connection::State::Closed);
        QCOMPARE(int(mConnFacade->state()), int(Xcp::Connection::State::Closed));
    });
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
        range[idx] = qobject_cast<ScalarMemoryRange *>(table->addScalarRange(MemoryRange::U32, {base[idx], 0}, false));
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
        if(rangeSpy[idx]->isEmpty())
            rangeSpy[idx]->wait(100);
        QCOMPARE(range[idx]->valid(), true);
        QCOMPARE(range[idx]->writable(), false);
        QCOMPARE(range[idx]->value().toUInt(), value[idx]);
    }
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
    ScopeExit connCloser([this, table](){
        setWaitConnState(table.get(), Xcp::Connection::State::Closed);
        QCOMPARE(int(mConnFacade->state()), int(Xcp::Connection::State::Closed));
    });
    std::vector<quint8> &slaveMemRange = mSlave->getMemRange(0);
    std::vector<quint32 *> slaveMemRangeValue(base.size());
    for(int idx = 0; idx < base.size(); ++idx)
    {
        slaveMemRangeValue[idx] = reinterpret_cast<quint32 *>(slaveMemRange.data() + idx * sizeof(quint32));
        *slaveMemRangeValue[idx] = 0;
    }

    std::vector<ScalarMemoryRange *> range(base.size());
    std::vector<std::shared_ptr<QSignalSpy>> rangeSpy;
    for(int idx = 0; idx < base.size(); ++idx)
    {
        range[idx] = qobject_cast<ScalarMemoryRange *>(table->addScalarRange(MemoryRange::U32, {base[idx], 0}, true));
        QVERIFY(range[idx] != nullptr);
        rangeSpy.emplace_back(new QSignalSpy(range[idx], &ScalarMemoryRange::valueUploaded));
    }
    {
        setWaitConnState(table.get(), Xcp::Connection::State::CalMode);
        QCOMPARE(int(mConnFacade->state()), int(Xcp::Connection::State::CalMode));
    }
    for(int idx = 0; idx < base.size(); ++idx)
    {
        if(rangeSpy[idx]->isEmpty())
            rangeSpy[idx]->wait(100);
        rangeSpy[idx]->clear();
        QCOMPARE(range[idx]->valid(), true);
        QCOMPARE(range[idx]->writable(), true);
        QCOMPARE(range[idx]->value().toUInt(), quint32(0));
    }
    for(int idx = 0; idx < base.size(); ++idx)
        range[idx]->setValue(value[idx]);
    for(int idx = 0; idx < base.size(); ++idx)
    {
        if(rangeSpy[idx]->isEmpty())
            rangeSpy[idx]->wait(100);
        rangeSpy[idx]->clear();
        QCOMPARE(range[idx]->value().toUInt(), value[idx]);
        QCOMPARE(*slaveMemRangeValue[idx], value[idx]);
    }
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
        range[idx] = qobject_cast<ScalarMemoryRange *>(table->addScalarRange(MemoryRange::U32, {base[idx], 0}, true));
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
    ScopeExit connCloser([this, table](){
        setWaitConnState(table.get(), Xcp::Connection::State::Closed);
        QCOMPARE(int(mConnFacade->state()), int(Xcp::Connection::State::Closed));
    });

    static constexpr std::array<quint8, 8> DATA = {0x01, 0x02, 0xDE, 0xAD, 0xBE, 0xEF, 0x55, 0xAA};
    static constexpr std::array<quint32, 3> RANGEDATA = {0xADDE0201, 0xEFBEADDE, 0xAA55EFBE};
    std::copy(DATA.begin(), DATA.end(), mSlave->getMemRange(0).data());

    setWaitConnState(table.get(), Xcp::Connection::State::CalMode);
    QCOMPARE(mConnFacade->state(), Xcp::Connection::State::CalMode);

    std::vector<ScalarMemoryRange *> range(3);
    std::vector<std::shared_ptr<QSignalSpy>> rangeSpy;
    for(quint32 idx = 0; idx < range.size(); ++idx)
    {
        range[idx] = qobject_cast<ScalarMemoryRange *>(table->addScalarRange(MemoryRange::U32, {(0x400 + 2 * idx) / ag, 0}, true));
        QVERIFY(range[idx] != nullptr);
        QCOMPARE(range[idx]->value().isNull(), true);
        rangeSpy.emplace_back(new QSignalSpy(range[idx], &ScalarMemoryRange::valueChanged));
    }

    for(quint32 rangeIdx : readOrder)
        range[rangeIdx]->refresh();

    for(quint32 idx : expectValid)
    {
        if(rangeSpy[idx]->isEmpty())
            rangeSpy[idx]->wait(100);
        rangeSpy[idx]->clear();
        if(range[idx]->value().isNull())
        {
            if(rangeSpy[idx]->isEmpty())
                rangeSpy[idx]->wait(100);
        }
        rangeSpy[idx]->clear();
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

}   // namespace Xcp
}   // namespace SetupTools
