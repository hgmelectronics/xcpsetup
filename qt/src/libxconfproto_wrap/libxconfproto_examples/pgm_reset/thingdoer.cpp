#include "thingdoer.h"

ThingDoer::ThingDoer() :
    mConn(new SetupTools::Xcp::ConnectionFacade(this)),
    mQin(stdin, QIODevice::ReadOnly),
    mQout(stdout, QIODevice::WriteOnly),
    mGetAvailIter(0)
{
    connect(mConn, &SetupTools::Xcp::ConnectionFacade::getAvailSlavesStrDone, this, &ThingDoer::onGetAvailSlavesStrDone);
    connect(mConn, &SetupTools::Xcp::ConnectionFacade::setStateDone, this, &ThingDoer::onSetStateDone);
    connect(mConn, &SetupTools::Xcp::ConnectionFacade::programResetDone, this, &ThingDoer::onResetDone);
}

void ThingDoer::start()
{
    int iPort = 0;
    mQout << "Available serial ports:\n";
    QList<QSerialPortInfo> ports = QSerialPortInfo::availablePorts();
    for(const auto &port : ports)
    {
        mQout << iPort << " " << port.portName() << " " << port.description() << "\n";
        ++iPort;
    }
    mQout.flush();

    QString serialDevName;
    if(ports.size() == 0)
    {
        mQout << "No serial ports detected\n";
        mQout.flush();
        exit(1);
    }
    else if(ports.size() == 1)
    {
        mQout << "One serial port detected, using it\n";
        mQout.flush();
        serialDevName = ports[0].portName();
    }
    else
    {
        int devIdx;
        mQout << "Enter index of ELM327 serial port: ";
        mQout.flush();
        mQin >> devIdx;
        Q_ASSERT(devIdx < ports.size());
        serialDevName = ports[devIdx].portName();
    }

    mConn->setIntfcUri(QString("elm327:%1?bitrate=250000").arg(serialDevName));
    mConn->setTimeout(100);
    mConn->setNvWriteTimeout(3000);
    mConn->getAvailSlavesStr("0x1F000000", "0x1F000100:0x1FFFFF00");
}

void ThingDoer::onGetAvailSlavesStrDone(SetupTools::Xcp::OpResult result, QList<QString> slaves)
{
    if(result != SetupTools::Xcp::OpResult::Success)
    {
        qDebug() << static_cast<int>(result);
        exit(1);
    }

    ++mGetAvailIter;
    if(mGetAvailIter < N_GET_AVAIL_ITER)
    {
        mConn->getAvailSlavesStr("0x1F000000", "0x1F000100:0x1FFFFF00");
        return;
    }

    int iSlave = 0;
    mQout << "Available slaves:\n";
    for(const auto &slave : slaves)
    {
        mQout << iSlave << " " << slave << "\n";
        ++iSlave;
    }
    mQout << "Enter index of slave: ";
    mQout.flush();
    mQin >> iSlave;

    mConn->setSlaveId(slaves[iSlave]);
    mConn->setState(SetupTools::Xcp::Connection::State::PgmMode);
}

void ThingDoer::onSetStateDone(SetupTools::Xcp::OpResult result)
{
    if(result != SetupTools::Xcp::OpResult::Success)
    {
        qDebug() << static_cast<int>(result);
        exit(1);
    }

    mConn->programReset();
}

void ThingDoer::onResetDone(SetupTools::Xcp::OpResult result)
{
    if(result != SetupTools::Xcp::OpResult::Success)
    {
        qDebug() << static_cast<int>(result);
        exit(1);
    }

    QCoreApplication::instance()->quit();
}
