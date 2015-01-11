#ifndef TEST_H
#define TEST_H

#include <QObject>
#include <QtTest/QtTest>

#include <Xcp_Connection.h>

namespace SetupTools
{
namespace Xcp
{

class Test : public QObject
{
    Q_OBJECT
public:
    Test(QObject *parent = 0);
    virtual ~Test() {}

private slots:
    //void initTestCase();

private:
};

}
}

#endif // TEST_H
