#include "test.h"
#include <memory>
#include <cxxabi.h>
#include <boost/crc.hpp>

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
    mIntfc = QSharedPointer<Interface::Loopback::Interface>::create();
    mConn = new SetupTools::Xcp::Connection(mIntfc, CONN_TIMEOUT, CONN_NVWRITE_TIMEOUT, this);
    mSlave = new TestingSlave(mIntfc, this);
    updateAg(1);
    mSlave->setBigEndian(false);
    mSlave->setPgmMasterBlockSupport(true);
    mSlave->setSendsEvStoreCal(true);
    mSlave->addMemRange(TestingSlave::MemType::Calib, {0x400, 0}, 0x400);
    mSlave->addMemRange(TestingSlave::MemType::Calib, {0x400, 0}, 0x400, 1, {0, 3});
    mSlave->addMemRange(TestingSlave::MemType::Prog, {0x08004000, 0}, 0x7A800);
}

/**
 * @brief Basic ability to connect
 */
void Test::connect()
{
    try
    {
        mConn->open();
        mConn->close();
    }
    catch(ConnException &exc)
    {
        FailOnExc(exc);
    }
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
    try
    {
        mConn->open();
        std::vector<quint8> data = mConn->upload({quint32(0x400/ag), 0}, 64);
        std::vector<quint8> expectedData;
        expectedData.assign(64, 0);
        QCOMPARE(data, expectedData);
        mConn->close();
    }
    catch(ConnException &exc)
    {
        FailOnExc(exc);
    }
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
    try
    {
        mConn->open();
        XcpPtr base = {quint32(0x515/ag), 0};
        std::vector<quint8> data(VectorFromQByteArray("Please do not press this button again."));
        mConn->download(base, data);
        std::vector<quint8> uploadData = mConn->upload(base, data.size());
        QCOMPARE(uploadData, data);
        mConn->close();
    }
    catch(ConnException &exc)
    {
        FailOnExc(exc);
    }
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
    try
    {
        mConn->open();
        XcpPtr base = {quint32(0x400/ag), 0};
        QByteArray dataArr("Please do not press this button again..."); // Make it 40 bytes long so all checksum types work
        std::vector<quint8> data(reinterpret_cast<const quint8 *>(dataArr.begin()), reinterpret_cast<const quint8 *>(dataArr.end()));
        mConn->download(base, data);

        mSlave->setCksumType(expectedCksum.first);
        std::pair<SetupTools::Xcp::CksumType, quint32> cksum;
        cksum = mConn->buildChecksum(base, data.size());
        QCOMPARE(cksum, expectedCksum);

        mConn->close();
    }
    catch(ConnException &exc)
    {
        FailOnExc(exc);
    }
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
    try
    {
        mConn->open();
        mConn->upload({quint32(0x7FE/ag), 0}, 64);
        QFAIL("Failed to throw exception");
    }
    catch(SlaveErrorOutOfRange)
    {
        // do nothing - expected result
    }
    catch(ConnException &exc)
    {
        FailOnExc(exc);
    }
    mConn->close();
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
    try
    {
        mConn->open();
        std::vector<quint8> downloadData(reinterpret_cast<const quint8 *>(downloadDataArr.begin()), reinterpret_cast<const quint8 *>(downloadDataArr.end()));
        std::vector<quint8> uploadData(reinterpret_cast<const quint8 *>(uploadDataArr.begin()), reinterpret_cast<const quint8 *>(uploadDataArr.end()));
        mConn->download(XcpPtr({quint32(downloadBase), 0}), downloadData);
        std::vector<quint8> uploadedData = mConn->upload(XcpPtr({quint32(uploadBase), 0}), uploadData.size());
        QCOMPARE(uploadData, uploadedData);
        mConn->close();
    }
    catch(ConnException &exc)
    {
        FailOnExc(exc);
    }
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
    QTest::newRow("110ms") << 110 << true << true;
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
    try
    {
        mSlave->setResponseDelay(TestingSlave::OpType::NvWrite, delayMsec, 1);
        mSlave->setSendsEvStoreCal(sendEvStoreCal);
        mConn->open();
        XcpPtr base = {0x515, 0};
        QByteArray dataArr("Please do not press this button again.");
        std::vector<quint8> data(reinterpret_cast<const quint8 *>(dataArr.begin()), reinterpret_cast<const quint8 *>(dataArr.end()));
        mConn->download(base, data);
        mConn->nvWrite();
        if(expectFail)
            QFAIL("Exception not thrown as it should have been");
        std::vector<quint8> uploadData = mConn->upload(base, data.size());
        QCOMPARE(uploadData, data);
        mConn->close();
    }
    catch(Timeout &exc)
    {
        if(!expectFail)
            FailOnExc(exc);
    }
    catch(ConnException &exc)
    {
        FailOnExc(exc);
    }
}

/**
 * @brief Verify calibration page switching works
 */
void Test::altCalPage()
{
    updateAg(1);
    try
    {
        mConn->open();
        XcpPtr base = {0x600, 0};
        QByteArray data1Arr("Please do not press this button again.");
        std::vector<quint8> data1(reinterpret_cast<const quint8 *>(data1Arr.begin()), reinterpret_cast<const quint8 *>(data1Arr.end()));
        QByteArray data2Arr("Look at me, brain the size of a planet...");
        std::vector<quint8> data2(reinterpret_cast<const quint8 *>(data2Arr.begin()), reinterpret_cast<const quint8 *>(data2Arr.end()));
        mConn->setCalPage(1, 3);
        mConn->download(base, data1);
        mConn->setCalPage(0, 0);
        mConn->download(base, data2);
        mConn->setCalPage(1, 3);
        std::vector<quint8> uploadData1 = mConn->upload(base, data1.size());
        mConn->setCalPage(0, 0);
        std::vector<quint8> uploadData2 = mConn->upload(base, data2.size());
        QCOMPARE(uploadData1, data1);
        QCOMPARE(uploadData2, data2);
        mConn->close();
    }
    catch(ConnException &exc)
    {
        FailOnExc(exc);
    }
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

    try
    {
        mConn->open();
        XcpPtr base = {0x0804000, 0};
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

        mConn->programStart();

        mConn->programClear(base, prog.size());
        std::vector<quint8> uploadedBlank = mConn->upload(base, prog.size());
        QCOMPARE(blankForProg, uploadedBlank);

        mConn->programRange(base, prog);

        mSlave->setCksumType(SetupTools::Xcp::CksumType::XCP_CRC_32);
        mConn->programVerify(progCrc);

        std::vector<quint8> uploadedProg = mConn->upload(base, prog.size());
        QCOMPARE(prog, uploadedProg);

        CksumPair expectedCksum = {SetupTools::Xcp::CksumType::XCP_CRC_32, progCrc};
        CksumPair cksum = mConn->buildChecksum(base, prog.size());
        QCOMPARE(expectedCksum, cksum);

        mConn->programReset();

        // now a command that requires calibration mode, to confirm the reset worked
        XcpPtr calBase = {0x515, 0};
        std::vector<quint8> calData(VectorFromQByteArray("Please do not press this button again."));
        mConn->download(calBase, calData);
    }
    catch(ConnException &exc)
    {
        FailOnExc(exc);
    }
}

void Test::updateAg(int ag)
{
    mSlave->setAg(ag);
    mSlave->setMaxBs(255/ag);
    mSlave->setPgmMaxBs(255/ag);
}

}
}
