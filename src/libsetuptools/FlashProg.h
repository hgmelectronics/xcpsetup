#ifndef FLASHPROG_H
#define FLASHPROG_H

#include <boost/optional.hpp>
#include <QObject>
#include <QQmlListProperty>

namespace SetupTools
{

class FlashBlock : public QObject
{
    Q_OBJECT
    // FIXME add properties for QML as desired
public:
    FlashBlock(QObject *parent = NULL);
    quint32 base;
    std::vector<quint8> data;
};

class FlashProg : public QObject
{
    Q_OBJECT
    Q_PROPERTY(QQmlListProperty<FlashBlock> blocks READ blocksQml)
public:
    FlashProg(QObject *parent = NULL);
    virtual ~FlashProg();

    QList<FlashBlock *> &blocks();
    QQmlListProperty<FlashBlock> blocksQml();
    Q_INVOKABLE void infillToSingleBlock(quint8 fillValue = 0xFF);
    int size();
    uint base();
signals:
    void changed();
private:
    QList<FlashBlock *> mBlocks;
};

}   // namespace SetupTools

#endif // FLASHPROG_H
