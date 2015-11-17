#ifndef SETUPTOOLS_TEST_H
#define SETUPTOOLS_TEST_H

#include <QObject>
#include <QtTest/QtTest>
#include <util.h>

namespace SetupTools {

class Test : public QObject
{
    Q_OBJECT
public:
    explicit Test(QObject *parent = 0);
    virtual ~Test() = default;

signals:

private slots:
    void initTestCase();

    void tabSeparatedFromText_data();
    void tabSeparatedFromText();
    void tabSeparatedFromArray();
//    void tabSeparatedColumnChange();
//    void tabSeparatedRowChange();
private:
    TabSeparated *mTabSep;
};

} // namespace SetupTools

#endif // SETUPTOOLS_TEST_H
