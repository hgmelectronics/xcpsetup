#include "FlashProg.h"

namespace SetupTools
{

FlashBlock::FlashBlock(QObject *parent) : QObject(parent) {}

FlashProg::FlashProg(QObject *parent) : QObject(parent) {}
FlashProg::~FlashProg() {}
QList<FlashBlock *> &FlashProg::blocks()
{
    return mBlocks;
}
QQmlListProperty<FlashBlock> FlashProg::blocksQml()
{
    return QQmlListProperty<FlashBlock>(this, mBlocks);
}

}   // namespace SetupTools
