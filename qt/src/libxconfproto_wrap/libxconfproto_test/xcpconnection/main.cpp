#include <QtTest/QtTest>
#include <QtGlobal>

#include "test.h"

int main(int argc, char **argv)
{
    QCoreApplication app(argc, argv);

    SetupTools::Xcp::EbusBoardTest test;

    return QTest::qExec(&test, argc, argv);
}
