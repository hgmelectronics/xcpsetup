#include "test.h"
#include <memory>
#include <cxxabi.h>
#include <boost/crc.hpp>

#include <QPair>
#include <QTime>

namespace QTest
{
char *toString(const SetupTools::Xcp::OpResult &res)
{
    QByteArray ba = "OpResult(";
    ba += QByteArray::number(static_cast<int>(res));
    ba += ")";
    return qstrdup(ba.data());
}
}

namespace SetupTools
{
namespace Xcp
{

void FailOnExc(ConnException &exc)
{
    std::string demangled;
    int status = 1;

    std::unique_ptr<char, void(*)(void*)> res {
        abi::__cxa_demangle(typeid(exc).name(), NULL, NULL, &status),
        std::free
    };

    if(status == 0)
        demangled = res.get();
    else
        demangled = typeid(exc).name();

    const char prefix[] = "Exception: ";
    char msg[sizeof(prefix) + demangled.size()];
    strcpy(msg, prefix);
    strcat(msg, demangled.c_str());
    QFAIL(msg);
}

std::vector<quint8> VectorFromQByteArray(const QByteArray &arr)
{
    return std::vector<quint8>(reinterpret_cast<const quint8 *>(arr.begin()), reinterpret_cast<const quint8 *>(arr.end()));
}

Test::Test(QObject *parent) : QObject(parent) {}

void Test::updateAg(int ag)
{
    mSlave->setAg(ag);
    mSlave->setMaxBs(255/ag);
    mSlave->setPgmMaxBs(255/ag);
}

void Test::setWaitConnState(const MemoryRangeTable *table, Connection::State state)
{
    for(int i = 0; i < 2; ++i)
    {
        if(mConnFacade->state() == state)
            return;

        QSignalSpy spy(table, &MemoryRangeTable::connectionChanged);
        mConnFacade->setState(state);
        spy.wait(100);
    }
}

void Test::initTestCase()
{
    qRegisterMetaType<SetupTools::Xcp::OpResult>();
    mIntfc = new Interface::Loopback::Interface();
    if(QProcessEnvironment::systemEnvironment().value("XCP_PACKET_LOG", "0") == "1")
        mIntfc->setPacketLog(true);
    mConnFacade = new SetupTools::Xcp::ConnectionFacade(this);
    mConnFacade->setIntfc(mIntfc);
    mConnFacade->setTimeout(CONN_TIMEOUT);
    mConnFacade->setNvWriteTimeout(CONN_NVWRITE_TIMEOUT);
    mConnFacade->setResetTimeout(CONN_RESET_TIMEOUT);
    mConnFacade->setProgClearTimeout(CONN_PROGCLEAR_TIMEOUT);
    mSlave = new TestingSlave(mIntfc, this);
    updateAg(1);
    mSlave->setBigEndian(false);
    mSlave->setPgmMasterBlockSupport(true);
    mSlave->setSendsEvStoreCal(true);

    mSlave->addMemRange(TestingSlave::MemType::Calib, {0x400, 0}, 256);
}

}   // namespace Xcp
}   // namespace SetupTools
