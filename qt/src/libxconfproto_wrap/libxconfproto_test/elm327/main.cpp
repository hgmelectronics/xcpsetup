#include <QtTest/QtTest>
#include <QIODevice>
#include <QTextStream>
#include <QtSerialPort/QtSerialPort>

#include <Xcp_Interface_Can_Elm327_Interface.h>

int main(void)
{
    QTextStream qin(stdin, QIODevice::ReadOnly);
    QTextStream qout(stdout, QIODevice::ReadOnly);

    qout << "This test requires a functional CAN with another node that receives any packet with even ID and echoes it with ID incremented.";
    qout << "Enter ELM327 serial device: ";
    QString devname;
    qin >> devname;

    QSerialPortInfo portInfo(devname);
    SetupTools::Xcp::Interface::Can::Elm327::Interface iface(portInfo);

    return 0;
}
