#include "Xcp_ScalarParam.h"

namespace SetupTools {

namespace Xcp {

ScalarParam::ScalarParam(ScalarMemoryRange *range, const Slot *slot, QObject *parent) :
    Param(range, parent),
    mRange(range),
    mSlot(slot)
{
    connect(mRange, &ScalarMemoryRange::valueChanged, this, &ScalarParam::onRangeValChanged);
    connect(mRange, &MemoryRange::uploadDone, this, &ScalarParam::onRangeUploadDone);
    connect(mRange, &MemoryRange::downloadDone, this, &ScalarParam::onRangeDownloadDone);
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

QVariant ScalarParam::getSerializableValue()
{
    return stringVal();
}

bool ScalarParam::setSerializableValue(const QVariant &val)
{
    QString str = val.toString();
    if(!mSlot->engrInRange(str))
        return false;

    setStringVal(str);
    return true;
}

void ScalarParam::onRangeValChanged()
{
    emit valChanged();
}

void ScalarParam::onRangeUploadDone(SetupTools::Xcp::OpResult result)
{
    emit uploadDone(result);
}

void ScalarParam::onRangeDownloadDone(SetupTools::Xcp::OpResult result)
{
    emit downloadDone(result);
}

void ScalarParam::upload()
{
    mRange->upload();
}

void ScalarParam::download()
{
    mRange->download();
}

} // namespace Xcp

} // namespace SetupTools

