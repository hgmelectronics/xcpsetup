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
    *slaveMemRangeValue = 0xFFFFFFFF;  // trick to make valueChanged get emitted later on initial load

    ScalarParam *param = qobject_cast<ScalarParam *>(registry->addParam(MemoryRange::MemoryRangeType::U32, {base, 0}, 1, true, false, &slot, KEY));
    QCOMPARE(param, qobject_cast<ScalarParam *>(registry->getParam(KEY)));
    QSignalSpy spy(param->range(), &ScalarMemoryRange::valueUploaded);

    {
        setWaitConnState(registry->table(), Xcp::Connection::State::CalMode);
        QCOMPARE(int(mConnFacade->state()), int(Xcp::Connection::State::CalMode));
    }

    if(spy.isEmpty())
        spy.wait(100);
    spy.clear();
    QVERIFY(std::isnan(param->floatVal()));
    QCOMPARE(param->stringVal(), QString("nan"));

    param->setFloatVal(floatEngr);
    if(spy.isEmpty())
        spy.wait(100);
    spy.clear();
    QCOMPARE(param->floatVal(), floatEngr);
    QCOMPARE(param->stringVal(), stringEngr);
    QCOMPARE(*slaveMemRangeValue, raw);

    param->setStringVal("nan");
    if(spy.isEmpty())
        spy.wait(100);
    spy.clear();
    QVERIFY(std::isnan(param->floatVal()));
    QCOMPARE(param->stringVal(), QString("nan"));

    param->setStringVal(stringEngr);
    if(spy.isEmpty())
        spy.wait(100);
    spy.clear();
    QCOMPARE(param->floatVal(), floatEngr);
    QCOMPARE(param->stringVal(), stringEngr);
    QCOMPARE(*slaveMemRangeValue, raw);
}

}   // namespace Xcp
}   // namespace SetupTools
