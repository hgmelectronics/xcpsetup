#include "test.h"
#include <memory>
#include <cxxabi.h>
#include <boost/crc.hpp>

namespace QTest
{
template<>
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

void Test::initTestCase()
{
    mIntfc = new Interface::Loopback::Interface();
    mConn = new SetupTools::Xcp::Connection(this);
    mConn->setIntfc(mIntfc);
    mConn->setTimeout(CONN_TIMEOUT);
    mConn->setNvWriteTimeout(CONN_NVWRITE_TIMEOUT);
    mConn->setResetTimeout(CONN_RESET_TIMEOUT);
    mSlave = new TestingSlave(mIntfc, this);
    updateAg(1);
    mSlave->setBigEndian(false);
    mSlave->setPgmMasterBlockSupport(true);
    mSlave->setSendsEvStoreCal(true);
    mSlave->addMemRange(TestingSlave::MemType::Calib, {0x400, 0}, 0x400);
    mSlave->addMemRange(TestingSlave::MemType::Calib, {0x10000, 0}, 0x400, 1, {0, 3});
    mSlave->addMemRange(TestingSlave::MemType::Prog, {0x08004000, 0}, 0x7A800);
    //mIntfc->setPacketLog(true);
}

/**
 * @brief Basic ability to connect
 */
void Test::connect()
{
    QCOMPARE(mConn->open(), OpResult::Success);
    QCOMPARE(mConn->close(), OpResult::Success);
}

void Test::upload_data()
{
    QTest::addColumn<int>("ag");
    QTest::newRow("AG==1") << 1;
    QTest::newRow("AG==2") << 2;
    QTest::newRow("AG==4") << 4;
}

/**
 * @brief Upload the zeros with which the memory was initialized
 */
void Test::upload()
{
    QFETCH(int, ag);
    updateAg(ag);
    QCOMPARE(mConn->open(), OpResult::Success);
    std::vector<quint8> data;
    QCOMPARE(mConn->upload({quint32(0x400/ag), 0}, 64, &data), OpResult::Success);
    std::vector<quint8> expectedData;
    expectedData.assign(64, 0);
    QCOMPARE(data, expectedData);
    QCOMPARE(mConn->close(), OpResult::Success);
}

void Test::downloadUpload_data()
{
    QTest::addColumn<int>("ag");
    QTest::newRow("AG==1") << 1;
    QTest::newRow("AG==2") << 2;
    QTest::newRow("AG==4") << 4;
}

/**
 * @brief Download some data and read it back
 */
void Test::downloadUpload()
{
    QFETCH(int, ag);
    updateAg(ag);
    QCOMPARE(mConn->open(), OpResult::Success);
    XcpPtr base = {quint32(0x515/ag), 0};
    std::vector<quint8> data(VectorFromQByteArray("Please do not press this button again..."));
    QCOMPARE(mConn->download(base, data), OpResult::Success);
    std::vector<quint8> uploadData;
    QCOMPARE(mConn->upload(base, data.size(), &uploadData), OpResult::Success);
    QCOMPARE(uploadData, data);
    QCOMPARE(mConn->close(), OpResult::Success);
}

void Test::downloadCksum_data()
{
    QTest::addColumn<int>("ag");
    QTest::addColumn<CksumPair>("expectedCksum");
    QTest::newRow("Add byte into bytes") << 1 << CksumPair({SetupTools::Xcp::CksumType::XCP_ADD_11, 0x49});
    QTest::newRow("Add byte into WORD") << 1 << CksumPair({SetupTools::Xcp::CksumType::XCP_ADD_12, 0xE49});
    QTest::newRow("Add byte into DWORD") << 1 << CksumPair({SetupTools::Xcp::CksumType::XCP_ADD_14, 0xE49});
    QTest::newRow("Add WORD into WORD") << 1 << CksumPair({SetupTools::Xcp::CksumType::XCP_ADD_22, 0xBD93});
    QTest::newRow("Add WORD into DWORD") << 1 << CksumPair({SetupTools::Xcp::CksumType::XCP_ADD_24, 0x6BD93});
    QTest::newRow("Add DWORD into DWORD") << 1 << CksumPair({SetupTools::Xcp::CksumType::XCP_ADD_44, 0x67B455E2});
    QTest::newRow("CRC16") << 1 << CksumPair({SetupTools::Xcp::CksumType::XCP_CRC_16, 0x9687});
    QTest::newRow("CRC16-CCITT") << 1 << CksumPair({SetupTools::Xcp::CksumType::XCP_CRC_16_CITT, 0x3C14});
    QTest::newRow("CRC32") << 1 << CksumPair({SetupTools::Xcp::CksumType::XCP_CRC_32, 0x938B86E9});
    QTest::newRow("CRC32, AG==2") << 2 << CksumPair({SetupTools::Xcp::CksumType::XCP_CRC_32, 0x938B86E9});
    QTest::newRow("CRC32, AG==4") << 4 << CksumPair({SetupTools::Xcp::CksumType::XCP_CRC_32, 0x938B86E9});
}

/**
 * @brief Download some data and test all predefined checksum modes
 */
void Test::downloadCksum()
{
    QFETCH(int, ag);
    QFETCH(CksumPair, expectedCksum);
    updateAg(ag);
    QCOMPARE(mConn->open(), OpResult::Success);
    XcpPtr base = {quint32(0x400/ag), 0};
    QByteArray dataArr("Please do not press this button again..."); // Make it 40 bytes long so all checksum types work
    std::vector<quint8> data(reinterpret_cast<const quint8 *>(dataArr.begin()), reinterpret_cast<const quint8 *>(dataArr.end()));
    QCOMPARE(mConn->download(base, data), OpResult::Success);

    mSlave->setCksumType(expectedCksum.first);
    std::pair<SetupTools::Xcp::CksumType, quint32> cksum;
    QCOMPARE(mConn->buildChecksum(base, data.size(), &cksum.first, &cksum.second), OpResult::Success);
    QCOMPARE(cksum, expectedCksum);

    QCOMPARE(mConn->close(), OpResult::Success);
}

void Test::uploadOutOfRange_data()
{
    QTest::addColumn<int>("ag");
    QTest::newRow("AG==1") << 1;
    QTest::newRow("AG==2") << 2;
    QTest::newRow("AG==4") << 4;
}

/**
 * @brief Make sure the out-of-range error is handled properly
 */
void Test::uploadOutOfRange()
{
    QFETCH(int, ag);
    updateAg(ag);
    QCOMPARE(mConn->open(), OpResult::Success);
    std::vector<quint8> data;
    QCOMPARE(mConn->upload({quint32(0x7FE/ag), 0}, 64, &data), OpResult::SlaveErrorOutOfRange);
    QCOMPARE(mConn->close(), OpResult::Success);
}

void Test::downloadUploadSmall_data()
{
    QTest::addColumn<int>("ag");
    QTest::addColumn<int>("downloadBase");
    QTest::addColumn<QByteArray>("downloadDataArr");
    QTest::addColumn<int>("uploadBase");
    QTest::addColumn<QByteArray>("uploadDataArr");
    QTest::newRow("AG==1") << 1 << 0x400 << QByteArray("fnords") << 0x401 << QByteArray("nords");
    QTest::newRow("AG==2") << 2 << 0x200 << QByteArray("fnords") << 0x201 << QByteArray("ords");
    QTest::newRow("AG==4") << 4 << 0x100 << QByteArray("nord") << 0x100 << QByteArray("nord");
}

/**
 * @brief Download and read back data small enough to fit in a single packet; also read back at a different starting address
 */
void Test::downloadUploadSmall()
{
    QFETCH(int, ag);
    QFETCH(int, downloadBase);
    QFETCH(QByteArray, downloadDataArr);
    QFETCH(int, uploadBase);
    QFETCH(QByteArray, uploadDataArr);
    updateAg(ag);
    QCOMPARE(mConn->open(), OpResult::Success);
    std::vector<quint8> downloadData(reinterpret_cast<const quint8 *>(downloadDataArr.begin()), reinterpret_cast<const quint8 *>(downloadDataArr.end()));
    std::vector<quint8> uploadData(reinterpret_cast<const quint8 *>(uploadDataArr.begin()), reinterpret_cast<const quint8 *>(uploadDataArr.end()));
    QCOMPARE(mConn->download(XcpPtr({quint32(downloadBase), 0}), downloadData), OpResult::Success);
    std::vector<quint8> uploadedData;
    QCOMPARE(mConn->upload(XcpPtr({quint32(uploadBase), 0}), uploadData.size(), &uploadedData), OpResult::Success);
    QCOMPARE(uploadData, uploadedData);
    QCOMPARE(mConn->close(), OpResult::Success);
}

void Test::downloadNvWrite_data()
{
    QTest::addColumn<int>("delayMsec");
    QTest::addColumn<bool>("sendEvStoreCal");
    QTest::addColumn<bool>("expectFail");
    QTest::newRow("Instant completion") << 0 << true << false;
    QTest::newRow("Instant completion, no EV_STORE_CAL") << 0 << false << false;
    QTest::newRow("10ms") << 10 << true << false;
    QTest::newRow("10ms, no EV_STORE_CAL") << 10 << false << false;
    QTest::newRow("200ms") << 200 << true << true;
}

/**
 * @brief Test NV write, including operation afterwards to make sure double reply doesn't mess up Connection
 */
void Test::downloadNvWrite()
{
    QFETCH(int, delayMsec);
    QFETCH(bool, sendEvStoreCal);
    QFETCH(bool, expectFail);
    updateAg(1);
    mSlave->setResponseDelay(TestingSlave::OpType::NvWrite, delayMsec, 100);
    mSlave->setSendsEvStoreCal(sendEvStoreCal);
    QCOMPARE(mConn->open(), OpResult::Success);
    XcpPtr base = {0x515, 0};
    QByteArray dataArr("Please do not press this button again.");
    std::vector<quint8> data(reinterpret_cast<const quint8 *>(dataArr.begin()), reinterpret_cast<const quint8 *>(dataArr.end()));
    QCOMPARE(mConn->download(base, data), OpResult::Success);
    OpResult nvWriteRes = mConn->nvWrite();
    mSlave->setResponseDelay(TestingSlave::OpType::NvWrite, 0, 0);
    if(expectFail)
    {
        QThread::msleep(200);
        std::vector<std::vector<quint8> > dummy;
        mIntfc->receive(0, dummy); // flush the buffers so we don't get confused on next operation
        QCOMPARE(nvWriteRes, OpResult::Timeout);
    }
    else
    {
        QCOMPARE(nvWriteRes, OpResult::Success);
    }
}

/**
 * @brief Verify calibration page switching works
 */
void Test::altCalPage()
{
    updateAg(1);
    QCOMPARE(mConn->open(), OpResult::Success);
    QCOMPARE(mConn->setCalPage(0, 0), OpResult::Success);
    QCOMPARE(mConn->setCalPage(1, 0), OpResult::Success);
    QCOMPARE(mConn->setCalPage(1, 3), OpResult::Success);
    QCOMPARE(mConn->close(), OpResult::Success);
}

void Test::programSequence_data()
{
    QTest::addColumn<int>("ag");
    QTest::addColumn<bool>("pgmMasterBlockSupport");
    QTest::newRow("Packet transfer, AG==1") << 1 << false;
    QTest::newRow("Block transfer, AG==1") << 1 << true;
    QTest::newRow("Packet transfer, AG==2") << 2 << false;
    QTest::newRow("Block transfer, AG==2") << 2 << true;
    QTest::newRow("Packet transfer, AG==4") << 4 << false;
    QTest::newRow("Block transfer, AG==4") << 4 << true;
}

void Test::programSequence()
{
    QFETCH(int, ag);
    updateAg(ag);
    QFETCH(bool, pgmMasterBlockSupport);
    mSlave->setPgmMasterBlockSupport(pgmMasterBlockSupport);

    XcpPtr base = {quint32(0x08004000 / ag), 0};
    std::vector<quint8> prog(VectorFromQByteArray(
                                 "Four score and seven years ago our fathers brought forth on this continent "
                                 "a new nation, conceived in liberty, and dedicated to the proposition that all "
                                 "men are created equal. Now we are engaged in a great civil war, testing "
                                 "whether that nation, or any nation so conceived and so dedicated, can long "
                                 "endure. We are met on a great battlefield of that war. We have come to "
                                 "dedicate a portion of that field, as a final resting place for those who here "
                                 "gave their lives that that nation might live. It is altogether fitting and "
                                 "proper that we should do this. But, in a larger sense, we can not dedicate, "
                                 "we can not consecrate, we can not hallow this ground. The brave men, living "
                                 "and dead, who struggled here, have consecrated it, far above our poor power "
                                 "to add or detract. The world will little note, nor long remember what we say "
                                 "here, but it can never forget what they did here. It is for us the living, "
                                 "rather, to be dedicated here to the unfinished work which they who fought "
                                 "here have thus far so nobly advanced. It is rather for us to be here "
                                 "dedicated to the great task remaining before us—that from these honored dead "
                                 "we take increased devotion to that cause for which they gave the last full "
                                 "measure of devotion—that we here highly resolve that these dead shall not "
                                 "have died in vain—that this nation, under God, shall have a new birth of "
                                 "freedom—and that government of the people, by the people, for the people, "
                                 "shall not perish from the earth."));  // long enough to require multiple block transfers
    boost::crc_32_type crcComputer;
    crcComputer.process_block(&*prog.begin(), &*prog.end());
    quint32 progCrc = crcComputer.checksum();
    std::vector<quint8> blankForProg;
    blankForProg.assign(prog.size(), 0xFF);
    mConn->setTimeout(100);

    QCOMPARE(mConn->setState(Connection::State::Closed), OpResult::Success);
    QCOMPARE(mConn->setState(Connection::State::PgmMode), OpResult::Success);

    QCOMPARE(mConn->programClear(base, prog.size()), OpResult::Success);
    std::vector<quint8> uploadedBlank;
    QCOMPARE(mConn->upload(base, prog.size(), &uploadedBlank), OpResult::Success);
    QCOMPARE(blankForProg, uploadedBlank);

    QCOMPARE(mConn->programRange(base, prog), OpResult::Success);

    mSlave->setCksumType(SetupTools::Xcp::CksumType::XCP_CRC_32);
    Q_ASSERT(quint32(base.addr + prog.size()) == base.addr + prog.size());
    QCOMPARE(mConn->programVerify({quint32(base.addr + prog.size()), base.ext}, progCrc), OpResult::Success);

    std::vector<quint8> uploadedProg;
    QCOMPARE(mConn->upload(base, prog.size(), &uploadedProg), OpResult::Success);
    QCOMPARE(prog, uploadedProg);

    CksumPair expectedCksum = {SetupTools::Xcp::CksumType::XCP_CRC_32, progCrc};
    CksumPair cksum;
    QCOMPARE(mConn->buildChecksum(base, prog.size(), &cksum.first, &cksum.second), OpResult::Success);
    QCOMPARE(expectedCksum, cksum);

    QCOMPARE(mConn->setState(Connection::State::CalMode), OpResult::Success);

    // now a command that requires calibration mode, to confirm the reset worked
    XcpPtr calBase = {quint32(0x514 / ag), 0};
    std::vector<quint8> calData(VectorFromQByteArray("Please do not press this button again..."));
    QCOMPARE(mConn->download(calBase, calData), OpResult::Success);
}

void Test::updateAg(int ag)
{
    mSlave->setAg(ag);
    mSlave->setMaxBs(255/ag);
    mSlave->setPgmMaxBs(255/ag);
}

}
}
