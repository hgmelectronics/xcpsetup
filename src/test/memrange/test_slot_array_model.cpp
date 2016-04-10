#include "test.h"
#include "LinearSlot.h"
#include "SlotArrayModel.h"
#include "TransposeProxyModel.h"

namespace SetupTools
{
namespace Xcp
{

void Test::slotArrayModel()
{
    LinearSlot slot;
    slot.setEngrA(0);
    slot.setEngrB(200);
    slot.setRawA(0);
    slot.setRawB(20);

    SlotArrayModel arrayModel(&slot, 6, 5, 2, true, nullptr);
    QCOMPARE(arrayModel.rowCount(), 6);
    QCOMPARE(arrayModel.columnCount(), 1);
    QCOMPARE(arrayModel.data(arrayModel.index(0, 0)), QVariant("50"));
    QCOMPARE(arrayModel.data(arrayModel.index(1, 0)), QVariant("70"));
    QCOMPARE(arrayModel.data(arrayModel.index(2, 0)), QVariant("90"));
    QCOMPARE(arrayModel.data(arrayModel.index(3, 0)), QVariant("110"));
    QCOMPARE(arrayModel.data(arrayModel.index(4, 0)), QVariant("130"));
    QCOMPARE(arrayModel.data(arrayModel.index(5, 0)), QVariant("150"));

    TransposeProxyModel transposeModel;
    transposeModel.setSourceModel(&arrayModel);
    QCOMPARE(transposeModel.rowCount(), 1);
    QCOMPARE(transposeModel.columnCount(), 6);
    QCOMPARE(transposeModel.data(transposeModel.index(0, 0)), QVariant("50"));
    QCOMPARE(transposeModel.data(transposeModel.index(0, 1)), QVariant("70"));
    QCOMPARE(transposeModel.data(transposeModel.index(0, 2)), QVariant("90"));
    QCOMPARE(transposeModel.data(transposeModel.index(0, 3)), QVariant("110"));
    QCOMPARE(transposeModel.data(transposeModel.index(0, 4)), QVariant("130"));
    QCOMPARE(transposeModel.data(transposeModel.index(0, 5)), QVariant("150"));
}

}   // namespace Xcp
}   // namespace SetupTools
