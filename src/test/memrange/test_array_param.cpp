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

void Test::arrayParamDownloadUpload_data()
{
    QTest::addColumn<int>("ag");

    QTest::newRow("ag==1") << 1;
    QTest::newRow("ag==2") << 2;
    QTest::newRow("ag==4") << 4;
}

void Test::arrayParamDownloadUpload()
{
    QFETCH(int, ag);

    static const QList<double> FLOAT_ENGR({64.255, 64.0, 40.0, 0.001, 0.0});
    static const QList<QString> STRING_ENGR({"64.255", "64.000", "40.000", "0.001", "0.000"});
    static const QList<quint32> RAW({64255, 64000, 40000, 1, 0});

    Q_ASSERT(FLOAT_ENGR.size() == STRING_ENGR.size());
    Q_ASSERT(FLOAT_ENGR.size() == RAW.size());

    quint32 base = 0x400 / ag;

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
    ScopeExit connCloser([this, registry](){
        setWaitConnState(registry->table(), Xcp::Connection::State::Closed);
        QCOMPARE(int(mConnFacade->state()), int(Xcp::Connection::State::Closed));
    });
    std::vector<quint8> &slaveMemRange = mSlave->getMemRange(0);
    Q_ASSERT(base * ag == mSlave->getMemRangeBase(0).addr);
    quint32 *slaveMemRangeValue = reinterpret_cast<quint32 *>(slaveMemRange.data());
    for(int i = 0; i < RAW.size(); ++i)
        slaveMemRangeValue[i] = 0xFFFFFFFF;  // make initially read value be NAN

    ArrayParam *param = qobject_cast<ArrayParam *>(registry->addArrayParam(MemoryRange::MemoryRangeType::U32, {base,0}, RAW.size(), true, false, &slot, KEY));
    QCOMPARE(param, qobject_cast<ArrayParam *>(registry->getParam(KEY)));
    QSignalSpy spy(param->range(), &ArrayMemoryRange::uploadDone);

    {
        setWaitConnState(registry->table(), Xcp::Connection::State::CalMode);
        QCOMPARE(int(mConnFacade->state()), int(Xcp::Connection::State::CalMode));
    }
    for(int i = 0; i < param->stringModel()->rowCount(); ++i)
    {
        QVERIFY(std::isnan(param->floatModel()->data(param->floatModel()->index(i), Qt::DisplayRole).toDouble()));
        QCOMPARE(param->stringModel()->data(param->stringModel()->index(i), Qt::DisplayRole).toString(), QString("nan"));
        QVERIFY(param->floatModel()->setData(param->floatModel()->index(i), QVariant(FLOAT_ENGR[i]), Qt::DisplayRole));
    }
    QVERIFY(spy.isEmpty());
    param->download();
    if(spy.isEmpty())
        spy.wait(100);
    spy.clear();

    for(int i = 0; i < param->stringModel()->rowCount(); ++i)
    {
        QCOMPARE(param->floatModel()->data(param->floatModel()->index(i), Qt::DisplayRole).toDouble(), FLOAT_ENGR[i]);
        QCOMPARE(param->stringModel()->data(param->stringModel()->index(i), Qt::DisplayRole).toString(), STRING_ENGR[i]);
        QCOMPARE(slaveMemRangeValue[i], RAW[i]);
        QVERIFY(param->stringModel()->setData(param->stringModel()->index(i), QVariant("nan"), Qt::DisplayRole));
    }

    param->download();
    if(spy.isEmpty())
        spy.wait(100);
    spy.clear();

    for(int i = 0; i < param->stringModel()->rowCount(); ++i)
    {
        QVERIFY(std::isnan(param->floatModel()->data(param->floatModel()->index(i), Qt::DisplayRole).toDouble()));
        QCOMPARE(param->stringModel()->data(param->stringModel()->index(i), Qt::DisplayRole).toString(), QString("nan"));
        QVERIFY(param->stringModel()->setData(param->stringModel()->index(i), QVariant(STRING_ENGR[i]), Qt::DisplayRole));
    }

    param->download();
    if(spy.isEmpty())
        spy.wait(100);
    spy.clear();

    for(int i = 0; i < param->stringModel()->rowCount(); ++i)
    {
        QCOMPARE(param->floatModel()->data(param->floatModel()->index(i), Qt::DisplayRole).toDouble(), FLOAT_ENGR[i]);
        QCOMPARE(param->stringModel()->data(param->stringModel()->index(i), Qt::DisplayRole).toString(), STRING_ENGR[i]);
        QCOMPARE(slaveMemRangeValue[i], RAW[i]);
    }
}

}   // namespace Xcp
}   // namespace SetupTools
