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
    mIntfc = new Interface(info, this);
    mIntfc->setBitrate(250000);
    mIntfc->setFilter(Filter());    // filter that matches everything
}

void Test::echoTest()
{
    std::vector<std::vector<quint8> > datas =
    {
        {0x82, 0x00, 0xFF, 0x55, 0x12, 0x45, 0x3F, 0xBA},
        {'s', 'k', 'j', 'd'},
        {'A', 'B', 'C', 'D', 'E', 'F', 'G'}
    };
    std::vector<Id> ids =
    {
        Id(0x234, Id::Type::Std),
        Id(0x7FE, Id::Type::Std),
        Id(0x001, Id::Type::Std),
        Id(0x00000002, Id::Type::Ext),
        Id(0x18FF03C0, Id::Type::Ext),
        Id(0x012302F1, Id::Type::Ext)
    };
    std::vector<int> nreps =
    {
        1,
        2,
        3,
        4
    };

    for(int nrep : nreps)
    {
        for(const std::vector<quint8> &data : datas)
        {
            for(const Id &id : ids)
            {
                for(int i = 0; i < nrep; ++i)
                {
                    mIntfc->transmitTo(data, id);
                    if(id.addr % 2 == 0)
                    {
                        std::vector<Frame> rxFrames = mIntfc->receiveFrames(100);
                        QCOMPARE(rxFrames.size(), size_t(1));
                        QCOMPARE(rxFrames[0].id.addr, id.addr + 1);
                        QCOMPARE(rxFrames[0].id.type, id.type);
                        QCOMPARE(rxFrames[0].data, data);
                    }
                }
            }
        }
    }
}

void Test::filterTest()
{
    std::vector<quint8> data =
        {0x82, 0x00, 0xFF, 0x55, 0x12, 0x45, 0x3F, 0xBA};
    std::vector<Id> ids =
    {
        Id(0x234, Id::Type::Std),
        Id(0x18FF03C0, Id::Type::Ext)
    };
    std::vector<Filter> filters =
    {
        Filter(Id(0x00000200, Id::Type::Ext), 0x00000E0A, false),
        Filter(Id(0x180000C1, Id::Type::Ext), 0x1F0000F1, false),
        Filter(Id(0x000000C0, Id::Type::Ext), 0x1FFFF8F0, false),
        Filter(Id(0x00FF0300, Id::Type::Ext), 0x00FFFF00, false)
    };

    for(const Filter &filter : filters)
    {
        mIntfc->setFilter(filter);
        for(const Id &id : ids)
        {
            mIntfc->transmitTo(data, id);
            if(((id.addr + 1) & filter.maskId) == filter.filt.addr)
            {
                std::vector<Frame> rxFrames = mIntfc->receiveFrames(100);
                QCOMPARE(rxFrames.size(), size_t(1));
                QCOMPARE(rxFrames[0].id.addr, id.addr + 1);
                QCOMPARE(rxFrames[0].id.type, id.type);
                QCOMPARE(rxFrames[0].data, data);
            }
        }
    }
    mIntfc->setFilter(Filter());    // restore "match all" filter
}

void Test::sameEchoTest()
{
    std::vector<quint8> data =
        {0x82, 0x00, 0xFF, 0x55, 0x12, 0x45, 0x3F, 0xBA};
    Id id(0x234, Id::Type::Std);
    int nrep = 100;

    // do once to set the ID
    mIntfc->transmitTo(data, id);
    mIntfc->receiveFrames(100);

    QBENCHMARK
    {
        for(int i = 0; i < nrep; ++i)
        {
            mIntfc->transmitTo(data, id);
            std::vector<Frame> rxFrames = mIntfc->receiveFrames(100);
            QCOMPARE(rxFrames.size(), size_t(1));
            QCOMPARE(rxFrames[0].id.addr, id.addr + 1);
            QCOMPARE(rxFrames[0].id.type, id.type);
            QCOMPARE(rxFrames[0].data, data);
        }
    }
}

void Test::sameTxTest()
{
    std::vector<quint8> data =
        {0x82, 0x00, 0xFF, 0x55, 0x12, 0x45, 0x3F, 0xBA};
    Id id(0x235, Id::Type::Std);
    int nrep = 100;

    // do once to set the ID
    mIntfc->transmitTo(data, id);
    mIntfc->receiveFrames(100);

    QBENCHMARK
    {
        for(int i = 0; i < nrep; ++i)
        {
            mIntfc->transmitTo(data, id);
        }
    }
}

}
}
}
}
}
