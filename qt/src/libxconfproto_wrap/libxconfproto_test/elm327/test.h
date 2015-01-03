#ifndef TEST_H
#define TEST_H

#include <QObject>
#include <QtTest/QtTest>
#include <QIODevice>
#include <QTextStream>
#include <QtSerialPort/QtSerialPort>

#include <Xcp_Interface_Can_Elm327_Interface.h>

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
class Test : public QObject
{
    Q_OBJECT
public:
    Test(const QString &devName, QObject *parent = 0);
    virtual ~Test() {}

private slots:
    void initTestCase();
    void echoTest();

private:
    QString mDevName;
    Interface *mIntfc;
};
}
}
}
}
}

#endif // TEST_H
