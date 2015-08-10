#include "LinearSlot.h"
#include "util.h"

namespace SetupTools {

LinearSlot::LinearSlot() :
    engrA(NAN),
    engrB(NAN),
    oorEngr(NAN),
    rawA(quint32(0)),
    rawB(quint32(0)),
    oorRaw(quint32(0xFFFFFFFF))
{}

double LinearSlot::toFloat(QVariant raw)
{
    bool convertedOk = false;
    double rawConv = raw.toDouble(&convertedOk);
    if(!convertedOk || !inRange(rawConv, rawA, rawB))
        return oorEngr;
    return (rawConv - rawA) / (rawB - rawA) * (engrB - engrA) + engrA;
}

QString LinearSlot::toString(QVariant raw)
{
    double engr = toFloat(raw);
    if(base == 10)
        return QString::number(engr, 'f', precision);
    else
        return QString::number(qint64(engr), base);
}

QVariant LinearSlot::toRaw(QVariant engr)
{
    bool convertedOk = false;
    double engrConv;
    if(base == 10 || engr.type() != QVariant::Type::String)
    {
        engrConv = engr.toDouble(&convertedOk);
    }
    else
    {
        QString engrStr = engr.toString();
        engrConv = engrStr.toLongLong(&convertedOk, base);
    }

    if(!convertedOk || !inRange(engrConv, engrA, engrB))
        return oorRaw;
    double raw = (engrConv - engrA) / (engrB - engrA) * (rawB - rawA) + rawA;

    if(storageType != QMetaType::Float && storageType != QMetaType::Double)
        raw = round(raw);
    QVariant rawVar = raw;
    if(rawVar.convert(storageType))
        return rawVar;
    else
        return oorRaw;
}

} // namespace SetupTools
