#include "ScalarParam.h"

namespace SetupTools {

ScalarParam::ScalarParam(QObject *parent) : Param(parent)
{
}

double ScalarParam::floatVal() const
{
    if(valid() && slot())
        return slot()->asFloat(rawVal());
    else
        return NAN;
}

QString ScalarParam::stringVal() const
{
    if(valid() && slot())
        return slot()->asString(rawVal());
    else
        return QString();
}

void ScalarParam::setFloatVal(double val)
{
    if(slot())
        setRawVal(slot()->asRaw(val));
}

void ScalarParam::setStringVal(QString val)
{
    if(slot())
        setRawVal(slot()->asRaw(val));
}

QVariant ScalarParam::getSerializableValue(bool *allInRange, bool *anyInRange)
{
    QVariant value = rawVal();
    if(valid() && slot())
    {
        bool inRange = slot()->rawInRange(value);
        if(allInRange)
            *allInRange = inRange;
        if(anyInRange)
            *anyInRange = inRange;
        return slot()->asString(value);
    }
    else
    {
        return QVariant();
    }
}

QVariant ScalarParam::getSerializableRawValue(bool *allInRange, bool *anyInRange)
{
    QVariant value = rawVal();
    if(valid() && slot())
    {
        bool inRange = slot()->rawInRange(value);
        if(allInRange)
            *allInRange = inRange;
        if(anyInRange)
            *anyInRange = inRange;
        return value;
    }
    else
        return QVariant();
}

bool ScalarParam::setSerializableValue(const QVariant &val)
{
    if(!val.isValid())
    {
        setValid(false);
        return true;
    }
    QString str = val.toString();
    if(!slot() || !slot()->engrInRange(str))
        return false;

    setStringVal(str);
    return true;
}

bool ScalarParam::setSerializableRawValue(const QVariant &val)
{
    if(!val.isValid())
    {
        setValid(false);
        return true;
    }
    if(!slot() || !slot()->rawInRange(val))
        return false;

    setRawVal(val);
    return true;
}

void ScalarParam::onSlotValueParamChanged()
{
    emit valChanged();
}

void ScalarParam::updateEngrFromRaw(quint32 begin, quint32 end)
{
    Q_UNUSED(begin);
    Q_UNUSED(end);

    emit valChanged();
}

quint32 ScalarParam::minSize()
{
    return dataTypeSize();
}

quint32 ScalarParam::maxSize()
{
    return dataTypeSize();
}

quint32 ScalarParam::size()
{
    return dataTypeSize();
}

QVariant ScalarParam::rawVal() const
{
    if(valid())
        return convertFromSlave(bytes().begin());
    else
        return QVariant();
}

bool ScalarParam::setRawVal(const QVariant & val)
{
    quint8 buf[dataTypeSize()];
    bool ok = convertToSlave(val, buf);
    setBytes({buf, buf + dataTypeSize()}, 0);
    return ok;
}

} // namespace SetupTools
