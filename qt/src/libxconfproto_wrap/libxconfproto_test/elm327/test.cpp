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
    mIntfc = new Interface(info, false, this);
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
    QList<int> nreps =
    {
        1,
        2,
        3,
        4
    };

    for(int nrep : nreps)
    {
        for(const IlQByteArray &data : datas)
        {
            int nEchoable = 0;
            for(const Id &id : ids)
            {
                for(int i = 0; i < nrep; ++i)
                {
                    mIntfc->transmitTo(data, id);
                    if(id.addr % 2 == 0)
                        ++nEchoable;
                }
            }
            QThread::msleep(20);
            QList<Frame> rxFrames = mIntfc->receiveFrames(100);
            QCOMPARE(rxFrames.size(), nEchoable);
            QList<Frame>::iterator rxFrameIt = rxFrames.begin();
            for(const Id &id : ids)
            {
                for(int i = 0; i < nrep; ++i)
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

void Test::filterTest()
{
    IlQByteArray data =
        {0x82, 0x00, 0xFF, 0x55, 0x12, 0x45, 0x3F, 0xBA};
    QList<Id> ids =
    {
        Id(0x234, Id::Type::Std),
        Id(0x18FF03C0, Id::Type::Ext)
    };
    QList<Filter> filters =
    {
        Filter(Id(0x00000200, Id::Type::Ext), 0x00000E0A, false),
        Filter(Id(0x180000C1, Id::Type::Ext), 0x1F0000F1, false),
        Filter(Id(0x000000C0, Id::Type::Ext), 0x1FFFF8F0, false),
        Filter(Id(0x00FF0300, Id::Type::Ext), 0x00FFFF00, false)
    };

    for(const Filter &filter : filters)
    {
        int nEchoable = 0;
        mIntfc->setFilter(filter);
        for(const Id &id : ids)
        {
            mIntfc->transmitTo(data, id);
            if(((id.addr + 1) & filter.maskId) == filter.filt.addr)
                ++nEchoable;
        }
        QThread::msleep(20);
        QList<Frame> rxFrames = mIntfc->receiveFrames(100);
        QCOMPARE(rxFrames.size(), nEchoable);
        QList<Frame>::iterator rxFrameIt = rxFrames.begin();
        for(const Id &id : ids)
        {
            if((id.addr & filter.maskId) == filter.filt.addr)
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
