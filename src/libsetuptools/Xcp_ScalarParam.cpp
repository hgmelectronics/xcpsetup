#include "Xcp_ScalarParam.h"

namespace SetupTools {

namespace Xcp {

ScalarParam::ScalarParam(QObject *parent) :
    Param(parent),
    mRange(nullptr)
{
}

ScalarParam::ScalarParam(ScalarMemoryRange *range, Slot *slot, QObject *parent) :
    Param(range, slot, parent),
    mRange(range)
{
    Q_ASSERT(mRange && slot);
    connect(mRange, &ScalarMemoryRange::valueChanged, this, &ScalarParam::onRangeValChanged);
    connect(mRange, &MemoryRange::uploadDone, this, &ScalarParam::onRangeUploadDone);
    connect(mRange, &MemoryRange::downloadDone, this, &ScalarParam::onRangeDownloadDone);
    connect(slot, &Slot::valueParamChanged, this, &ScalarParam::onSlotValueParamChanged);
}

ScalarMemoryRange* ScalarParam::range() const
{
    Q_ASSERT(mRange);
    return mRange;
}


double ScalarParam::floatVal() const
{
    return slot()->asFloat(mRange->value());
}

QString ScalarParam::stringVal() const
{
    return slot()->asString(mRange->value());
}

void ScalarParam::setFloatVal(double val)
{
    mRange->setValue(slot()->asRaw(val));
}

void ScalarParam::setStringVal(QString val)
{
    mRange->setValue(slot()->asRaw(val));
}

QVariant ScalarParam::getSerializableValue(bool *allInRange, bool *anyInRange)
{
    bool inRange = slot()->rawInRange(mRange->value());
    if(allInRange)
        *allInRange = inRange;
    if(anyInRange)
        *anyInRange = inRange;
    return stringVal();
}

QVariant ScalarParam::getSerializableRawValue(bool *allInRange, bool *anyInRange)
{
    bool inRange = slot()->rawInRange(mRange->value());
    if(allInRange)
        *allInRange = inRange;
    if(anyInRange)
        *anyInRange = inRange;
    return mRange->value();
}

bool ScalarParam::setSerializableValue(const QVariant &val)
{
    Q_ASSERT(mRange);
    QString str = val.toString();
    if(!slot()->engrInRange(str))
        return false;

    setStringVal(str);
    return true;
}

bool ScalarParam::setSerializableRawValue(const QVariant &val)
{
    Q_ASSERT(mRange);
    if(!slot()->rawInRange(val))
        return false;

    mRange->setValue(val);
    return true;
}

void ScalarParam::onRangeValChanged()
{
    emit valChanged();
}

void ScalarParam::onSlotValueParamChanged()
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

