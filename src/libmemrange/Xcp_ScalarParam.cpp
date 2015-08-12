#include "Xcp_ScalarParam.h"

namespace SetupTools {

namespace Xcp {

ScalarParam::ScalarParam(ScalarMemoryRange *range, const Slot *slot, QObject *parent) :
    Param(parent),
    mRange(range),
    mSlot(slot)
{
    connect(mRange, &ScalarMemoryRange::valueChanged, this, &ScalarParam::onRangeValChanged);
}

double ScalarParam::floatVal() const
{
    return mSlot->toFloat(mRange->value());
}

QString ScalarParam::stringVal() const
{
    return mSlot->toString(mRange->value());
}

void ScalarParam::setFloatVal(double val)
{
    mRange->setValue(mSlot->toRaw(val));
}

void ScalarParam::setStringVal(QString val)
{
    mRange->setValue(mSlot->toRaw(val));
}
QString ScalarParam::unit() const
{
    return mSlot->unit();
}

const ScalarMemoryRange *ScalarParam::range() const
{
    return mRange;
}

void ScalarParam::onRangeValChanged()
{
    emit valChanged();
}

} // namespace Xcp

} // namespace SetupTools

