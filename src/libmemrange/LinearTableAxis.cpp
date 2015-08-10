#include "LinearTableAxis.h"
#include <util.h>

namespace SetupTools {

LinearTableAxis::LinearTableAxis(QObject *parent) :
    QAbstractListModel(parent),
    mMin(NAN),
    mMax(NAN),
    mSize(0)
{}

float LinearTableAxis::min() const
{
    return mMin;
}

void LinearTableAxis::setMin(float min)
{
    if(updateDelta<>(mMin, min))
        emit dimChanged();
}

float LinearTableAxis::max() const
{
    return mMax;
}

void LinearTableAxis::setMax(float max)
{
    if(updateDelta<>(mMax, max))
        emit dimChanged();
}

float LinearTableAxis::step() const
{
    return (mMax - mMin) / float(mSize);
}

int LinearTableAxis::size() const
{
    return mSize;
}

void LinearTableAxis::setSize(int size)
{
    if(size <= 0)
        return;

    if(updateDelta<>(mSize, size))
        emit dimChanged();
}

int LinearTableAxis::rowCount() const
{
    return mSize;
}

QVariant LinearTableAxis::data(const QModelIndex &index, int role) const
{
    if(index.column() != 0
            || role != Qt::DisplayRole
            || index.row() < 0
            || index.row() >= size())
        return QVariant();
    else
        return mMin + ((mMax - mMin) * index.row()) / mSize;
}

} // namespace SetupTools

