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
void FlashProg::clear()
{
    for(FlashBlock *block : mBlocks)
        delete block;
    mBlocks.clear();
}
FlashProg &FlashProg::operator=(const FlashProg &other)
{
    clear();
    for(const FlashBlock *otherBlock : other.mBlocks)
    {
        FlashBlock *block = new FlashBlock(this);
        block->base = otherBlock->base;
        block->data = otherBlock->data;
        mBlocks.append(block);
    }
    return *this;
}

void FlashProg::infillToSingleBlock(quint8 fillValue)
{
    if(mBlocks.size() < 2)
        return;

    FlashBlock *first = mBlocks.front();
    FlashBlock *last = mBlocks.back();

    int combinedSize = last->base + last->data.size() - first->base;

    FlashBlock *combined = new FlashBlock(this);
    combined->base = first->base;
    combined->data.resize(combinedSize, fillValue);

    for(FlashBlock *block : mBlocks)
    {
        int offset = block->base - combined->base;
        Q_ASSERT(offset >= 0);
        Q_ASSERT((block->base + block->data.size()) <= (combined->base + combined->data.size()));
        std::copy(block->data.begin(), block->data.end(), combined->data.begin() + offset);
    }

    clear();
    mBlocks.append(combined);
    emit changed();
}
int FlashProg::size()
{
    int size = 0;
    for(FlashBlock *block : mBlocks)
        size += block->data.size();
    return size;
}

uint FlashProg::base()
{
    if(mBlocks.size() == 0)
        return 0;
    return mBlocks[0]->base;
}

}   // namespace SetupTools
