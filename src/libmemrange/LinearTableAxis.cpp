#include "LinearTableAxis.h"
#include <util.h>

namespace SetupTools {

LinearTableAxis::LinearTableAxis(QObject *parent) :
    TableAxis(parent),
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

int LinearTableAxis::rowCount(const QModelIndex & parent) const
{
    if(parent.isValid())
        return 0;
    else
        return mSize;
}

QVariant LinearTableAxis::data(const QModelIndex &index, int role) const
{
    if(index.column() != 0
            || role != int(TableAxisRole::XRole)
            || index.row() < 0
            || index.row() >= size())
        return QVariant();
    else
        return mMin + ((mMax - mMin) * index.row()) / mSize;
}

QHash<int, QByteArray> LinearTableAxis::roleNames() const
{
    static const QHash<int, QByteArray> ROLENAMES({ {TableAxisRole::XRole,     "x"},
                                                    {TableAxisRole::ValueRole, "value"}});
    return ROLENAMES;
}

} // namespace SetupTools

