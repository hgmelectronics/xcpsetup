#include <QtTest/QtTest>
#include <QIODevice>
#include <QTextStream>
#include <QtSerialPort/QtSerialPort>
#include <QtGlobal>

#include "test.h"

int main(int argc, char **argv)
{
    QCoreApplication app(argc, argv);
    QTextStream qin(stdin, QIODevice::ReadOnly);
    QTextStream qout(stdout, QIODevice::WriteOnly);

    qDebug() << "This test requires a functional CAN with another node that receives any packet with even ID and echoes it with ID incremented.";

    int iUri = 0;
    qDebug() << "Available interfaces:";
    QList<QString> uris = SetupTools::Xcp::Interface::Can::Elm327::Registry().avail();
    for(const auto &uri : uris)
    {
        qDebug() << iUri << uri;
        ++iUri;
    }

    QString uri;
    if(uris.size() == 0)
    {
        qDebug() << "No interfaces detected";
        exit(1);
    }
    else if(uris.size() == 1)
    {
        qDebug() << "One interface detected, using it";
        uri = uris[0];
    }
    else
    {
        qout << "Enter index of ELM327 interface: ";
        qout.flush();
        qin >> iUri;
        Q_ASSERT(iUri < uris.size());
        uri = uris[iUri];
    }

    SetupTools::Xcp::Interface::Can::Elm327::Test test(uri);

    return QTest::qExec(&test, argc, argv);
}
