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

void Test::varArrayParamReupload_data()
{
    QTest::addColumn<int>("ag");

    QTest::newRow("ag==1") << 1;
//    QTest::newRow("ag==2") << 2;
//    QTest::newRow("ag==4") << 4;
}

void Test::varArrayParamReupload()
{
    QFETCH(int, ag);
    static constexpr int count = 10;

    quint32 base = 0x800 / ag;

    static const QString KEY("fnord");

    LinearSlot slot;
    slot.setBase(10);
    slot.setPrecision(4);
    slot.setStorageType(int(QMetaType::UInt));
    slot.setEngrA(0.0);
    slot.setEngrB(6.4255);
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
        slaveMemRangeValue[i] = 30000 + i;

    VarArrayParam *param = qobject_cast<VarArrayParam *>(registry->addVarArrayParam(MemoryRange::MemoryRangeType::U32, {base,0}, 8, count, false, false, &slot, KEY));
    QCOMPARE(param, qobject_cast<VarArrayParam *>(registry->getParam(KEY)));

    QSignalSpy uploadedSpy(param, &Param::uploadDone);
    QSignalSpy modelChangedSpy(param, &VarArrayParam::modelChanged);
    QSignalSpy modelDataChangedSpy(param->stringModel(), &VarArrayParamModel::dataChanged);
    {
        setWaitConnState(registry->table(), Xcp::Connection::State::CalMode);
        QCOMPARE(int(mConnFacade->state()), int(Xcp::Connection::State::CalMode));
    }
    QCOMPARE(param->valid(), false);
    QCOMPARE(param->count(), 0);
    QVERIFY(uploadedSpy.isEmpty());
    QVERIFY(modelChangedSpy.isEmpty());
    QVERIFY(modelDataChangedSpy.isEmpty());
    QCOMPARE(uploadedSpy.count(), 0);
    QCOMPARE(modelChangedSpy.count(), 0);
    QCOMPARE(modelDataChangedSpy.count(), 0);

    param->upload();
    waitSignalSpyCount(100, 1, uploadedSpy);
    waitSignalSpyCount(50, 2, modelChangedSpy);
    waitSignalSpyCount(50, 2, modelDataChangedSpy);
    QCOMPARE(uploadedSpy.count(), 1);
    QVERIFY(modelChangedSpy.count() >= 1 && modelChangedSpy.count() <= 2);
    QVERIFY(modelDataChangedSpy.count() >= 1 && modelDataChangedSpy.count() <= 2); // One for each of resize and data change
    uploadedSpy.clear();
    modelChangedSpy.clear();
    modelDataChangedSpy.clear();

    param->upload();
    waitSignalSpyCount(100, 1, uploadedSpy);
    waitSignalSpyCount(50, 1, modelChangedSpy);
    waitSignalSpyCount(50, 1, modelDataChangedSpy);
    QCOMPARE(uploadedSpy.count(), 1);
    QCOMPARE(modelChangedSpy.count(), 0);
    QCOMPARE(modelDataChangedSpy.count(), 0);
    uploadedSpy.clear();
    modelChangedSpy.clear();
    modelDataChangedSpy.clear();

    for(int i = 0; i < count; ++i)
        slaveMemRangeValue[i] = 32000 + i;

    param->upload();
    waitSignalSpyCount(100, 1, uploadedSpy);
    waitSignalSpyCount(10, 1, modelChangedSpy);
    waitSignalSpyCount(10, 1, modelDataChangedSpy);
    QCOMPARE(uploadedSpy.count(), 1);
    QCOMPARE(modelChangedSpy.count(), 1);
    QCOMPARE(modelDataChangedSpy.count(), 1);
    uploadedSpy.clear();
    modelChangedSpy.clear();
    modelDataChangedSpy.clear();
}

}   // namespace Xcp
}   // namespace SetupTools
