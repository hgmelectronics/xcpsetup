#include <QCoreApplication>
#include <Xcp_Interface_Can_Elm327_Interface.h>
#include <Xcp_Connection.h>
#include <QtSerialPort/QtSerialPort>

int main(int argc, char *argv[])
{
    QCoreApplication a(argc, argv);

    QTextStream qin(stdin, QIODevice::ReadOnly);
    QTextStream qout(stdout, QIODevice::WriteOnly);

    int iPort = 0;
    qout << "Available serial ports:\n";
    QList<QextPortInfo> ports = QextSerialEnumerator::getPorts();
    for(const QextPortInfo &port : ports)
    {
        qout << iPort << " " << port.portName << " " << port.friendName << "\n";
        ++iPort;
    }
    qout.flush();

    QString serialDevName;
    if(ports.size() == 0)
    {
        qout << "No serial ports detected\n";
        qout.flush();
        exit(1);
    }
    else if(ports.size() == 1)
    {
        qout << "One serial port detected, using it\n";
        qout.flush();
        serialDevName = ports[0].portName;
    }
    else
    {
        int devIdx;
        qout << "Enter index of ELM327 serial port: ";
        qout.flush();
        qin >> devIdx;
        Q_ASSERT(devIdx < ports.size());
        serialDevName = ports[devIdx].portName;
    }

    SetupTools::Xcp::Interface::Can::Elm327::Interface* intfc = new SetupTools::Xcp::Interface::Can::Elm327::Interface(serialDevName, NULL);
    intfc->setBitrate(250000);
    intfc->setFilter(SetupTools::Xcp::Interface::Can::Filter());    // filter that matches everything
    intfc->connect({{0x18FCD403, SetupTools::Xcp::Interface::Can::Id::Type::Ext}, {0x18FCD4F9, SetupTools::Xcp::Interface::Can::Id::Type::Ext}});
    intfc->setPacketLog(true);

    SetupTools::Xcp::Connection *conn = new SetupTools::Xcp::Connection(NULL);
    conn->setIntfc(intfc);
    conn->setTimeout(100);
    conn->setNvWriteTimeout(3000);
    conn->open();

    qout << "Enter XCP address: ";
    qout.flush();
    quint32 xcpAddr;
    qin >> xcpAddr;

    SetupTools::Xcp::XcpPtr ptr = {xcpAddr, 0};
    std::vector<quint8> dataVec = conn->upload(ptr, 4);
    Q_ASSERT(dataVec.size() == 4);
    quint32 value = conn->fromSlaveEndian<quint32>(dataVec.data());
    qout << "Present value: " << value << "\n";
    qout << "New value: ";
    qout.flush();
    qin >> value;
    conn->toSlaveEndian<quint32>(value, dataVec.data());
    conn->download(ptr, dataVec);
    qout << "Write successful\n";
    qout.flush();

    return 0;
}
