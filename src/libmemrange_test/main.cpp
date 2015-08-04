#include <QCoreApplication>

#include <SetupTools.h>
#include "test.h"

int main(int argc, char *argv[])
{
    QCoreApplication a(argc, argv);

    SetupTools::registerTypes();

    SetupTools::Xcp::Test test;

    return QTest::qExec(&test, argc, argv);
}
