#include "Xcp_ScalarParam.h"

namespace SetupTools {

namespace Xcp {

ScalarParam::ScalarParam(QObject *parent) :
    Param(parent),
    mRange(nullptr),
    mSlot(nullptr)
{}

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
    Q_ASSERT(mRange && mSlot);
    return mSlot->toFloat(mRange->value());
}

QString ScalarParam::stringVal() const
{
    Q_ASSERT(mRange && mSlot);
    return mSlot->toString(mRange->value());
}

void ScalarParam::setFloatVal(double val)
{
    Q_ASSERT(mRange && mSlot);
    mRange->setValue(mSlot->toRaw(val));
}

void ScalarParam::setStringVal(QString val)
{
    Q_ASSERT(mRange && mSlot);
    mRange->setValue(mSlot->toRaw(val));
}
QString ScalarParam::unit() const
{
    Q_ASSERT(mRange && mSlot);
    return mSlot->unit();
}

const ScalarMemoryRange *ScalarParam::range() const
{
    Q_ASSERT(mRange && mSlot);
    return mRange;
}

QVariant ScalarParam::getSerializableValue()
{
    return stringVal();
}

bool ScalarParam::setSerializableValue(const QVariant &val)
{
    Q_ASSERT(mRange && mSlot);
    QString str = val.toString();
    if(!mSlot->engrInRange(str))
        return false;

    setStringVal(str);
    return true;
}

void ScalarParam::resetCaches()
{
    Q_ASSERT(mRange && mSlot);
    mRange->resetCaches();
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
    Q_ASSERT(mRange && mSlot);
    mRange->upload();
}

void ScalarParam::download()
{
    Q_ASSERT(mRange && mSlot);
    mRange->download();
}

} // namespace Xcp

} // namespace SetupTools

