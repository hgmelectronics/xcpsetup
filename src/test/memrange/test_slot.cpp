#include "test.h"
#include "LinearSlot.h"

namespace SetupTools
{
namespace Xcp
{

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

    slot.setBase(base);
    slot.setPrecision(precision);
    slot.setStorageType(storageType);
    slot.setEngrA(engrA);
    slot.setEngrB(engrB);
    slot.setOorEngr(oorEngr);
    slot.setRawA(rawA);
    slot.setRawB(rawB);
    slot.setOorRaw(oorRaw);

    if(std::isnan(engrOut))
        QVERIFY(std::isnan(slot.asFloat(rawIn)));
    else
        QCOMPARE(slot.asFloat(rawIn), engrOut);
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

    slot.setBase(base);
    slot.setPrecision(precision);
    slot.setStorageType(storageType);
    slot.setEngrA(engrA);
    slot.setEngrB(engrB);
    slot.setOorEngr(oorEngr);
    slot.setRawA(rawA);
    slot.setRawB(rawB);
    slot.setOorRaw(oorRaw);

    QCOMPARE(slot.asString(rawIn), engrOut);
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

    slot.setBase(base);
    slot.setPrecision(precision);
    slot.setStorageType(storageType);
    slot.setEngrA(engrA);
    slot.setEngrB(engrB);
    slot.setOorEngr(oorEngr);
    slot.setRawA(rawA);
    slot.setRawB(rawB);
    slot.setOorRaw(oorRaw);

    QCOMPARE(slot.asRaw(engrIn), rawOut);
}

}   // namespace Xcp
}   // namespace SetupTools
