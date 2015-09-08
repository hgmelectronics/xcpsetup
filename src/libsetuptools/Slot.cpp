#include "Slot.h"
#include "util.h"

namespace SetupTools {

Slot::Slot(QObject *parent) :
    QObject(parent),
    mUnit(""),
    mBase(10),
    mPrecision(0),
    mStorageType(QMetaType::UInt)
{}

QString Slot::unit() const
{
    return mUnit;
}
void Slot::setUnit(QString newVal)
{
    if(updateDelta<>(mUnit, newVal))
        emit unitChanged();
}
int Slot::base() const
{
    return mBase;
}
void Slot::setBase(int newVal)
{
    if(updateDelta<>(mBase, newVal))
        emit valueParamChanged();
}
int Slot::precision() const
{
    return mPrecision;
}
void Slot::setPrecision(int newVal)
{
    if(updateDelta<>(mPrecision, newVal))
        emit valueParamChanged();
}
int Slot::storageType() const
{
    return mStorageType;
}
void Slot::setStorageType(int newVal)
{
    if(updateDelta<>(mStorageType, newVal))
        emit valueParamChanged();
}

QVariant Slot::rawMin() const
{
    return QVariant();
}
QVariant Slot::rawMax() const
{
    return QVariant();
}
QVariant Slot::engrMin() const
{
    return QVariant();
}
QVariant Slot::engrMax() const
{
    return QVariant();
}

}   // namespace SetupTools
