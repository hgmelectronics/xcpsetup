#ifndef TESTINGSLAVE_H
#define TESTINGSLAVE_H

#include <QObject>

class TestingSlave : public QObject
{
    Q_OBJECT
public:
    explicit TestingSlave(QObject *parent = 0);

signals:

public slots:

};

#endif // TESTINGSLAVE_H
