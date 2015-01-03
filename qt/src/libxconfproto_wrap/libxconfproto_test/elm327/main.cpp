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

    int iPort = 0;
    qDebug() << "Available serial ports:";
    QList<QSerialPortInfo> ports = QSerialPortInfo::availablePorts();
    for(const auto &port : ports)
    {
        qDebug() << iPort << port.portName() << port.description();
        ++iPort;
    }

    QString devName;
    if(ports.size() == 0)
    {
        qDebug() << "No serial ports detected";
        exit(1);
    }
    else if(ports.size() == 1)
    {
        qDebug() << "One serial port detected, using it";
        devName = ports[0].portName();
    }
    else
    {
        int devIdx;
        qout << "Enter index of ELM327 serial port: ";
        qout.flush();
        qin >> devIdx;
        Q_ASSERT(devIdx < ports.size());
        devName = ports[devIdx].portName();
    }

    SetupTools::Xcp::Interface::Can::Elm327::Test test(devName);

    return QTest::qExec(&test, argc, argv);
}
