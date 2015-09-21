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
    return mRange;
}


double ScalarParam::floatVal() const
{
    if(slot() && mRange)
        return slot()->asFloat(mRange->value());
    else
        return NAN;
}

QString ScalarParam::stringVal() const
{
    if(slot() && mRange)
        return slot()->asString(mRange->value());
    else
        return QString();
}

void ScalarParam::setFloatVal(double val)
{
    if(slot() && mRange)
        mRange->setValue(slot()->asRaw(val));
}

void ScalarParam::setStringVal(QString val)
{
    if(slot() && mRange)
        mRange->setValue(slot()->asRaw(val));
}

QVariant ScalarParam::getSerializableValue(bool *allInRange, bool *anyInRange)
{
    if(slot() && mRange)
    {
        bool inRange = slot()->rawInRange(mRange->value());
        if(allInRange)
            *allInRange = inRange;
        if(anyInRange)
            *anyInRange = inRange;
        return stringVal();
    }
    else
    {
        return QVariant();
    }
}

QVariant ScalarParam::getSerializableRawValue(bool *allInRange, bool *anyInRange)
{
    if(slot() && mRange)
    {
        bool inRange = slot()->rawInRange(mRange->value());
        if(allInRange)
            *allInRange = inRange;
        if(anyInRange)
            *anyInRange = inRange;
    }
    if(mRange)
        return mRange->value();
    else
        return QVariant();
}

bool ScalarParam::setSerializableValue(const QVariant &val)
{
    if(slot() && mRange)
    {
        QString str = val.toString();
        if(!slot()->engrInRange(str))
            return false;

        setStringVal(str);
        return true;
    }
    else
    {
        return false;
    }
}

bool ScalarParam::setSerializableRawValue(const QVariant &val)
{
    if(slot() && mRange)
    {
        if(!slot()->rawInRange(val))
            return false;

        mRange->setValue(val);
        return true;
    }
    else
    {
        return false;
    }
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
    if(mRange)
        mRange->upload();
}

void ScalarParam::download()
{
    if(mRange)
        mRange->download();
}

} // namespace Xcp

} // namespace SetupTools

