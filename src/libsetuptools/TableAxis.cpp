#include "TableAxis.h"
#include "util.h"

namespace SetupTools {

TableAxis::TableAxis(QObject *parent) :
    QAbstractListModel(parent)
{}

QString TableAxis::xUnit() const
{
    return mXUnit;
}
QString TableAxis::yUnit() const
{
    return mYUnit;
}
void TableAxis::setXUnit(QString newVal)
{
    if(updateDelta<>(mXUnit, newVal))
        emit xUnitChanged();
}
void TableAxis::setYUnit(QString newVal)
{
    if(updateDelta<>(mYUnit, newVal))
        emit yUnitChanged();
}

} // namespace SetupTools
