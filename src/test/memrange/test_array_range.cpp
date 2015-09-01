#include "test.h"
#include "Xcp_ArrayMemoryRange.h"

namespace SetupTools
{
namespace Xcp
{

void Test::uploadTableNoOverlap_data()
{
    QTest::addColumn<quint32>("ag");
    QTest::addColumn<quint32>("base");
    QTest::addColumn<QVector<quint32> >("value");
    QTest::newRow("AG==1 cbo=0") << quint32(0x1) << quint32(0x400) << QVector<quint32>({0xDEADBEEF, 0x7F, 0x01234567, 0x89ABCDEF});
    QTest::newRow("AG==2 cbo=0") << quint32(0x2) << quint32(0x200) << QVector<quint32>({0xDEADBEEF, 0x7F, 0x01234567, 0x89ABCDEF});
    QTest::newRow("AG==4 cbo=0") << quint32(0x4) << quint32(0x100) << QVector<quint32>({0xDEADBEEF, 0x7F, 0x01234567, 0x89ABCDEF});
}

void Test::uploadTableNoOverlap()
{
    QFETCH(quint32, ag);
    QFETCH(quint32, base);
    QFETCH(QVector<quint32>, value);

    QCOMPARE(int(mConnFacade->state()), int(Xcp::Connection::State::Closed));

    updateAg(ag);
    std::shared_ptr<MemoryRangeTable> table(new MemoryRangeTable(ag, this));
    table->setConnectionFacade(mConnFacade);
    ScopeExit connCloser([this, table](){
        setWaitConnState(table.get(), Xcp::Connection::State::Closed);
        QCOMPARE(int(mConnFacade->state()), int(Xcp::Connection::State::Closed));
    });
    std::vector<quint8> &slaveMemRange = mSlave->getMemRange(0);
    Q_ASSERT(base * ag >= mSlave->getMemRangeBase(0).addr);
    quint32 memRangeOffset = base * ag - mSlave->getMemRangeBase(0).addr;
    std::copy(value.begin(), value.end(), reinterpret_cast<decltype(value)::value_type *>(slaveMemRange.data() + memRangeOffset));

    setWaitConnState(table.get(), Xcp::Connection::State::CalMode);
    QCOMPARE(int(mConnFacade->state()), int(Xcp::Connection::State::CalMode));

    ArrayMemoryRange *range = qobject_cast<ArrayMemoryRange *>(table->addTableRange(MemoryRange::U32, {base, 0}, value.size(), false));
    QVERIFY(range != nullptr);
    QSignalSpy rangeSpy(range, &ArrayMemoryRange::uploadDone);

    range->upload();
    for(int idx = 0; idx < value.size(); ++idx)
    {
        if(range->data()[idx].isNull() && rangeSpy.isEmpty())
            rangeSpy.wait(100);
    }
    rangeSpy.clear();

    QCOMPARE(range->valid(), true);
    QCOMPARE(range->writable(), false);
    for(int idx = 0; idx < value.size(); ++idx)
        QCOMPARE(range->data()[idx].toUInt(), value[idx]);
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
    ScopeExit connCloser([this, table](){
        setWaitConnState(table.get(), Xcp::Connection::State::Closed);
        QCOMPARE(int(mConnFacade->state()), int(Xcp::Connection::State::Closed));
    });
    std::vector<quint8> &slaveMemRange = mSlave->getMemRange(0);
    Q_ASSERT(base * ag >= mSlave->getMemRangeBase(0).addr);
    quint32 memRangeOffset = base * ag - mSlave->getMemRangeBase(0).addr;
    quint32 *slaveMemRangeValueBase = reinterpret_cast<decltype(value)::value_type *>(slaveMemRange.data() + memRangeOffset);
    boost::iterator_range<quint32 *> slaveMemRangeValue(slaveMemRangeValueBase, slaveMemRangeValueBase + value.size());
    std::fill(slaveMemRangeValue.begin(), slaveMemRangeValue.end(), 0);

    ArrayMemoryRange *range = qobject_cast<ArrayMemoryRange *>(table->addTableRange(MemoryRange::U32, {base, 0}, value.size(), true));
    QVERIFY(range != nullptr);
    QSignalSpy rangeSpy(range, &ArrayMemoryRange::dataUploaded);
    {
        setWaitConnState(table.get(), Xcp::Connection::State::CalMode);
        QCOMPARE(int(mConnFacade->state()), int(Xcp::Connection::State::CalMode));
    }
    range->upload();
    for(int endIdxUploaded = 0; endIdxUploaded < range->count(); )
    {
        if(rangeSpy.isEmpty())
            rangeSpy.wait(100);
        if(rangeSpy.isEmpty())
            break;
        endIdxUploaded = rangeSpy.takeFirst()[1].toInt();
    }
    QCOMPARE(range->valid(), true);
    QCOMPARE(range->writable(), true);
    for(int idx = 0; idx < value.size(); ++idx)
    {
        QCOMPARE(range->data()[idx].toUInt(), quint32(0));
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
            range->set(idx, value[idx]);
    }
    range->download();
    for(int endIdxUploaded = 0; endIdxUploaded < range->count(); )
    {
        if(rangeSpy.isEmpty())
            rangeSpy.wait(100);
        if(rangeSpy.isEmpty())
            break;
        endIdxUploaded = rangeSpy.takeFirst()[1].toInt();
    }
    for(int idx = 0; idx < value.size(); ++idx)
    {
        QCOMPARE(range->data()[idx].toUInt(), value[idx]);
        QCOMPARE(slaveMemRangeValue[idx], value[idx]);
    }
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
    ScopeExit connCloser([this, table](){
        setWaitConnState(table.get(), Xcp::Connection::State::Closed);
        QCOMPARE(int(mConnFacade->state()), int(Xcp::Connection::State::Closed));
    });
    std::vector<quint8> &slaveMemRange = mSlave->getMemRange(0);
    Q_ASSERT(base * ag >= mSlave->getMemRangeBase(0).addr);
    quint32 memRangeOffset = base * ag - mSlave->getMemRangeBase(0).addr;
    std::copy(value.begin(), value.end(), reinterpret_cast<decltype(value)::value_type *>(slaveMemRange.data() + memRangeOffset));

    // call refresh after open
    setWaitConnState(table.get(), Xcp::Connection::State::CalMode);
    QCOMPARE(int(mConnFacade->state()), int(Xcp::Connection::State::CalMode));

    ArrayMemoryRange *range = qobject_cast<ArrayMemoryRange *>(table->addTableRange(MemoryRange::U32, {base, 0}, value.size(), false));
    ArrayMemoryRange *subRange = qobject_cast<ArrayMemoryRange *>(table->addTableRange(MemoryRange::U32, {base + sizeof(quint32) / ag, 0}, value.size() - 2, false));
    QVERIFY(range != nullptr);
    QVERIFY(subRange != nullptr);
    QSignalSpy rangeSpy(range, &ArrayMemoryRange::dataChanged);
    subRange->upload();
    for(int idx = 1; idx < (value.size() - 1); ++idx)
    {
        if(range->data()[idx].isNull())
            rangeSpy.wait(100);
    }
    rangeSpy.clear();

    QCOMPARE(range->writable(), false);
    QCOMPARE(range->data().first().isNull(), true);
    for(int idx = 1; idx < (value.size() - 1); ++idx)
        QCOMPARE(range->data()[idx].toUInt(), value[idx]);
    QCOMPARE(range->data().last().isNull(), true);
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
    ScopeExit connCloser([this, table](){
        setWaitConnState(table.get(), Xcp::Connection::State::Closed);
        QCOMPARE(int(mConnFacade->state()), int(Xcp::Connection::State::Closed));
    });
    std::vector<quint8> &slaveMemRange = mSlave->getMemRange(0);
    Q_ASSERT(base * ag >= mSlave->getMemRangeBase(0).addr);
    quint32 memRangeOffset = base * ag - mSlave->getMemRangeBase(0).addr;
    std::copy(value.begin(), value.end(), reinterpret_cast<decltype(value)::value_type *>(slaveMemRange.data() + memRangeOffset));

    // call refresh after open
    setWaitConnState(table.get(), Xcp::Connection::State::CalMode);
    QCOMPARE(int(mConnFacade->state()), int(Xcp::Connection::State::CalMode));

    ArrayMemoryRange *range = qobject_cast<ArrayMemoryRange *>(table->addTableRange(MemoryRange::U32, {base, 0}, value.size(), false));
    QVERIFY(range != nullptr);
    QSignalSpy rangeSpy(range, &ArrayMemoryRange::uploadDone);
    quint32 tableAgs = value.size() * sizeof(quint32) / ag;
    Q_ASSERT(tableAgs % 2 == 0);
    mConnFacade->upload({base, 0}, (tableAgs / 2 - 1) * ag);
    if(rangeSpy.isEmpty())
        rangeSpy.wait(100);
    rangeSpy.clear();
    mConnFacade->upload({base + tableAgs / 2 - 1, 0}, (tableAgs / 2 + 1) * ag);
    if(rangeSpy.isEmpty())
        rangeSpy.wait(100);
    rangeSpy.clear();

    QCOMPARE(range->valid(), true);
    QCOMPARE(range->writable(), false);
    for(int idx = 0; idx < value.size(); ++idx)
        QCOMPARE(range->data()[idx].toUInt(), value[idx]);
}

}   // namespace Xcp
}   // namespace SetupTools
