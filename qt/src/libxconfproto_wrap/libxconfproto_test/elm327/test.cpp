#include "test.h"

namespace SetupTools
{
namespace Xcp
{
namespace Interface
{
namespace Can
{
namespace Elm327
{

Test::Test(const QString &devName, QObject *parent) :
    QObject(parent),
    mDevName(devName)
{}

void Test::initTestCase()
{
    QSerialPortInfo info(mDevName);
    mIntfc = new Interface(info, true, this);
    mIntfc->setBitrate(250000);
    mIntfc->setFilter(Filter());    // filter that matches everything
}

void Test::echoTest()
{
    QList<IlQByteArray> datas =
    {
        {0x82, 0x00, 0xFF, 0x55, 0x12, 0x45, 0x3F, 0xBA},
        {'s', 'k', 'j', 'd'},
        {'A', 'B', 'C', 'D', 'E', 'F', 'G'}
    };
    QList<Id> ids =
    {
        Id(0x234, Id::Type::Std),
        Id(0x7FE, Id::Type::Std),
        Id(0x001, Id::Type::Std),
        Id(0x00000002, Id::Type::Ext),
        Id(0x18FF03C0, Id::Type::Ext),
        Id(0x012302F1, Id::Type::Ext)
    };

    for(const IlQByteArray &data : datas)
    {
        for(const Id &id : ids)
        {
            mIntfc->transmitTo(data, id);
            QList<Frame> rxFrames = mIntfc->receiveFrames(100);
            qDebug() << mIntfc->elapsedSecs() << "Received" << rxFrames.size() << "frames";
            if(id.addr % 2 == 0)
            {
                QCOMPARE(rxFrames.size(), 1);
                QCOMPARE(rxFrames[0].id.addr, id.addr + 1);
                QCOMPARE(rxFrames[0].id.type, id.type);
                QCOMPARE(rxFrames[0].data, QByteArray(data));
            }
            else
            {
                QCOMPARE(rxFrames.size(), 0);
            }
        }

        int nEchoable = 0;
        for(const Id &id : ids)
        {
            mIntfc->transmitTo(data, id);
            if(id.addr % 2 == 0)
                ++nEchoable;
        }
        QThread::msleep(20);
        QList<Frame> rxFrames = mIntfc->receiveFrames(100);
        QCOMPARE(rxFrames.size(), nEchoable);
        QList<Frame>::iterator rxFrameIt = rxFrames.begin();
        for(const Id &id : ids)
        {
            if(id.addr % 2 == 0)
            {
                QCOMPARE(rxFrameIt->id.addr, id.addr + 1);
                QCOMPARE(rxFrameIt->id.type, id.type);
                QCOMPARE(rxFrameIt->data, QByteArray(data));
                ++rxFrameIt;
            }
        }
    }
}

}
}
}
}
}
