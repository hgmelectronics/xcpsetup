#include "test.h"

namespace SetupTools {

Test::Test(QObject *parent) :
    QObject(parent),
    mTabSep(nullptr)
{}

void Test::initTestCase()
{
    mTabSep = new TabSeparated();
}

void Test::tabSeparatedFromText_data()
{
    QTest::addColumn<QString>("text");
    QTest::newRow("trailing newline") << QString("1\t2\n\t4\n5\t\n");
    QTest::newRow("no trailing newline") << QString("1\t2\n\t4\n5\t");
}

void Test::tabSeparatedFromText()
{
    QFETCH(QString, text);

    mTabSep->setRows(0);
    QSignalSpy textChangedSpy(mTabSep, &TabSeparated::textChanged);
    QSignalSpy rowsChangedSpy(mTabSep, &TabSeparated::rowsChanged);
    QSignalSpy columnsChangedSpy(mTabSep, &TabSeparated::columnsChanged);

    mTabSep->setText(text);

    QCOMPARE(textChangedSpy.count(), 1);
    QCOMPARE(rowsChangedSpy.count(), 1);
    QCOMPARE(columnsChangedSpy.count(), 1);

    QCOMPARE(mTabSep->rows(), 3);
    QCOMPARE(mTabSep->columns(), 2);

    QCOMPARE(mTabSep->get(0, 0), QVariant(QString("1")));
    QCOMPARE(mTabSep->get(0, 1), QVariant(QString("2")));
    QCOMPARE(mTabSep->get(1, 0), QVariant(QString("")));
    QCOMPARE(mTabSep->get(1, 1), QVariant(QString("4")));
    QCOMPARE(mTabSep->get(2, 0), QVariant(QString("5")));
    QCOMPARE(mTabSep->get(2, 1), QVariant(QString("")));

    QCOMPARE(mTabSep->text(), QString("1\t2\n\t4\n5\t\n"));
}

void Test::tabSeparatedFromArray()
{
    mTabSep->setRows(0);

    QSignalSpy rowsChangedSpy(mTabSep, &TabSeparated::rowsChanged);
    QSignalSpy columnsChangedSpy(mTabSep, &TabSeparated::columnsChanged);
    mTabSep->setRows(3);
    mTabSep->setColumns(2);
    QCOMPARE(rowsChangedSpy.count(), 1);
    QCOMPARE(columnsChangedSpy.count(), 1);

    QSignalSpy textChangedSpy(mTabSep, &TabSeparated::textChanged);

    QVERIFY(mTabSep->set(0, 0, QString("1")));
    QVERIFY(mTabSep->set(0, 1, QString("2")));
    QVERIFY(mTabSep->set(1, 0, QString("")));
    QVERIFY(mTabSep->set(1, 1, QString("4")));
    QVERIFY(mTabSep->set(2, 0, QString("5")));
    QVERIFY(mTabSep->set(2, 1, QString("")));

    QCOMPARE(textChangedSpy.count(), 4);

    QCOMPARE(mTabSep->text(), QString("1\t2\n\t4\n5\t\n"));
}

} // namespace SetupTools

