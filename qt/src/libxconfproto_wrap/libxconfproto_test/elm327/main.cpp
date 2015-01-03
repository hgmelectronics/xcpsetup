#include <QtTest/QtTest>
#include <QIODevice>
#include <QTextStream>
#include <QtSerialPort/QtSerialPort>
#include <QtGlobal>

#include "test.h"

int main(int argc, char **argv)
{
    for(const auto &port : QSerialPortInfo::availablePorts())
    {
        qDebug() << "Available serial port:" << port.portName();
    }
    QString devname("ttyUSB0");
    /*QTextStream qin(stdin, QIODevice::ReadOnly);
    QTextStream qout(stdout, QIODevice::WriteOnly);

    qout << "This test requires a functional CAN with another node that receives any packet with even ID and echoes it with ID incremented.";
    qout << "Enter ELM327 serial device: ";
    qin >> devname;*/
    QCoreApplication app(argc, argv);

    SetupTools::Xcp::Interface::Can::Elm327::Test test(devname);

    return QTest::qExec(&test, argc, argv);
}
