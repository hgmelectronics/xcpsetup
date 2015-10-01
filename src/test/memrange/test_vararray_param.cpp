#include "test.h"
#include <memory>
#include "Xcp_ArrayMemoryRange.h"
#include "LinearSlot.h"
#include "Xcp_ArrayParam.h"
#include "Xcp_ParamRegistry.h"

#include <QPair>
#include <QTime>

namespace SetupTools
{
namespace Xcp
{

void Test::varArrayParamDownloadUpload_data()
{
    QTest::addColumn<int>("ag");
    QTest::addColumn<int>("count");

    QTest::newRow("ag==1 count==2") << 1 << 2;
    QTest::newRow("ag==2 count==2") << 2 << 2;
    QTest::newRow("ag==4 count==2") << 4 << 2;
    QTest::newRow("ag==1 count==3") << 1 << 3;
    QTest::newRow("ag==2 count==3") << 2 << 3;
    QTest::newRow("ag==4 count==3") << 4 << 3;
    QTest::newRow("ag==1 count==4") << 1 << 4;
    QTest::newRow("ag==2 count==4") << 2 << 4;
    QTest::newRow("ag==4 count==4") << 4 << 4;
    QTest::newRow("ag==1 count==5") << 1 << 5;
    QTest::newRow("ag==2 count==5") << 2 << 5;
    QTest::newRow("ag==4 count==5") << 4 << 5;
}

void Test::varArrayParamDownloadUpload()
{
    QFETCH(int, ag);
    QFETCH(int, count);

    static const QList<double> FLOAT_ENGR({64.255, 64.0, 40.0, 0.001, 0.0});
    static const QList<QString> STRING_ENGR({"64.255", "64.000", "40.000", "0.001", "0.000"});
    static const QList<quint32> RAW({64255, 64000, 40000, 1, 0});
    static constexpr int MIN_SIZE = 3;

    Q_ASSERT(FLOAT_ENGR.size() == STRING_ENGR.size());
    Q_ASSERT(FLOAT_ENGR.size() == RAW.size());

    quint32 base = 0x800 / ag;

    static const QString KEY("fnord");

    LinearSlot slot;
    slot.setBase(10);
    slot.setPrecision(3);
    slot.setStorageType(int(QMetaType::UInt));
    slot.setEngrA(0.0);
    slot.setEngrB(64.255);
    slot.setOorEngr(NAN);
    slot.setRawA(0);
    slot.setRawB(64255);
    slot.setOorRaw(65535);

    QCOMPARE(int(mConnFacade->state()), int(Xcp::Connection::State::Closed));

    updateAg(ag);
    std::shared_ptr<ParamRegistry> registry(new ParamRegistry(ag));
    registry->setConnectionFacade(mConnFacade);
    int slaveMemRangeIdx = mSlave->addMemRange(TestingSlave::MemType::Calib, {0x800, 0}, count * sizeof(quint32));
    ScopeExit cleanup([this, registry, slaveMemRangeIdx](){
        setWaitConnState(registry->table(), Xcp::Connection::State::Closed);
        QCOMPARE(int(mConnFacade->state()), int(Xcp::Connection::State::Closed));
        mSlave->removeMemRange(slaveMemRangeIdx);
    });
    std::vector<quint8> &slaveMemRange = mSlave->getMemRange(slaveMemRangeIdx);
    Q_ASSERT(base * ag == mSlave->getMemRangeBase(slaveMemRangeIdx).addr);
    quint32 *slaveMemRangeValue = reinterpret_cast<quint32 *>(slaveMemRange.data());
    for(int i = 0; i < count; ++i)
        slaveMemRangeValue[i] = 0xFFFFFFFF;  // make initially read value be NAN

    VarArrayParam *param = qobject_cast<VarArrayParam *>(registry->addVarArrayParam(MemoryRange::MemoryRangeType::U32, {base,0}, MIN_SIZE, RAW.size(), true, false, &slot, KEY));
    QCOMPARE(param, qobject_cast<VarArrayParam *>(registry->getParam(KEY)));
    MemoryRange *lastValidRange;
    MemoryRange *lastValidRangePlus;
    if(count < MIN_SIZE)
    {
        lastValidRange = param->range();
        lastValidRangePlus = param->range();
    }
    else if(count == MIN_SIZE)
    {
        lastValidRange = param->range();
        lastValidRangePlus = param->extRanges().front();
    }
    else if(count < RAW.size())
    {
        lastValidRange = param->extRanges()[count - MIN_SIZE - 1];
        lastValidRangePlus = param->extRanges()[count - MIN_SIZE];
    }
    else
    {
        lastValidRange = param->extRanges().back();
        lastValidRangePlus = param->extRanges().back();
    }
    QSignalSpy lastValidUploadedSpy(lastValidRange, &MemoryRange::uploadDone);
    QSignalSpy lastUploadedSpy(lastValidRangePlus, &MemoryRange::uploadDone);
    {
        setWaitConnState(registry->table(), Xcp::Connection::State::CalMode);
        QCOMPARE(int(mConnFacade->state()), int(Xcp::Connection::State::CalMode));
    }
    QCOMPARE(param->valid(), false);
    QCOMPARE(param->count(), 0);
    QCOMPARE(param->stringModel()->rowCount(), 0);
    QVERIFY(lastUploadedSpy.isEmpty());

    param->upload();
    if(lastUploadedSpy.isEmpty())
        lastUploadedSpy.wait(100);
    lastUploadedSpy.clear();
    lastValidUploadedSpy.clear();

    if(count < MIN_SIZE)
    {
        QCOMPARE(param->valid(), false);
        QCOMPARE(param->count(), 0);
        QCOMPARE(param->stringModel()->rowCount(), 0);
        return;
    }

    QCOMPARE(param->count(), count);

    for(int i = 0; i < count; ++i)
    {
        QVERIFY(std::isnan(param->floatModel()->data(param->floatModel()->index(i), Qt::DisplayRole).toDouble()));
        QCOMPARE(param->stringModel()->data(param->stringModel()->index(i), Qt::DisplayRole).toString(), QString("nan"));
        QVERIFY(param->floatModel()->setData(param->floatModel()->index(i), QVariant(FLOAT_ENGR[i]), Qt::DisplayRole));
    }

    QVERIFY(lastValidUploadedSpy.isEmpty());
    param->download();
    if(lastValidUploadedSpy.isEmpty())
        lastValidUploadedSpy.wait(100);
    lastUploadedSpy.clear();
    lastValidUploadedSpy.clear();


    for(int i = 0; i < count; ++i)
    {
        QCOMPARE(param->floatModel()->data(param->floatModel()->index(i), Qt::DisplayRole).toDouble(), FLOAT_ENGR[i]);
        QCOMPARE(param->stringModel()->data(param->stringModel()->index(i), Qt::DisplayRole).toString(), STRING_ENGR[i]);
        QCOMPARE(slaveMemRangeValue[i], RAW[i]);
        QVERIFY(param->stringModel()->setData(param->stringModel()->index(i), QVariant("nan"), Qt::DisplayRole));
    }

    QVERIFY(lastValidUploadedSpy.isEmpty());
    param->download();
    if(lastValidUploadedSpy.isEmpty())
        lastValidUploadedSpy.wait(100);
    lastUploadedSpy.clear();
    lastValidUploadedSpy.clear();


    for(int i = 0; i < count; ++i)
    {
        QVERIFY(std::isnan(param->floatModel()->data(param->floatModel()->index(i), Qt::DisplayRole).toDouble()));
        QCOMPARE(param->stringModel()->data(param->stringModel()->index(i), Qt::DisplayRole).toString(), QString("nan"));
        QVERIFY(param->stringModel()->setData(param->stringModel()->index(i), QVariant(STRING_ENGR[i]), Qt::DisplayRole));
    }

    QVERIFY(lastValidUploadedSpy.isEmpty());
    param->download();
    if(lastValidUploadedSpy.isEmpty())
        lastValidUploadedSpy.wait(100);
    lastUploadedSpy.clear();
    lastValidUploadedSpy.clear();


    for(int i = 0; i < count; ++i)
    {
        QCOMPARE(param->floatModel()->data(param->floatModel()->index(i), Qt::DisplayRole).toDouble(), FLOAT_ENGR[i]);
        QCOMPARE(param->stringModel()->data(param->stringModel()->index(i), Qt::DisplayRole).toString(), STRING_ENGR[i]);
        QCOMPARE(slaveMemRangeValue[i], RAW[i]);
    }
}

}   // namespace Xcp
}   // namespace SetupTools
