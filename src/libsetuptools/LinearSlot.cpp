#include "LinearSlot.h"
#include "util.h"

namespace SetupTools {

LinearSlot::LinearSlot(QObject *parent) :
    Slot(parent),
    mEngrA(NAN),
    mEngrB(NAN),
    mOorEngr(NAN),
    mRawA(quint32(0)),
    mRawB(quint32(0)),
    mOorRaw(quint32(0xFFFFFFFF)),
    mValidator(new QDoubleValidator(this))
{
    connect(this, &Slot::valueParamChanged, this, &LinearSlot::updateValidator);
}

double LinearSlot::engrA() const
{
    return mEngrA;
}
void LinearSlot::setEngrA(double newVal)
{
    if(updateDelta<>(mEngrA, newVal))
    {
        emit valueParamChanged();
        emit linearValueParamChanged();
    }
}
double LinearSlot::engrB() const
{
    return mEngrB;
}
void LinearSlot::setEngrB(double newVal)
{
    if(updateDelta<>(mEngrB, newVal))
    {
        emit valueParamChanged();
        emit linearValueParamChanged();
    }
}
double LinearSlot::oorEngr() const
{
    return mOorEngr;
}
void LinearSlot::setOorEngr(double newVal)
{
    if(updateDelta<>(mOorEngr, newVal))
    {
        emit valueParamChanged();
        emit linearValueParamChanged();
    }
}
double LinearSlot::rawA() const
{
    return mRawA;
}
void LinearSlot::setRawA(double newVal)
{
    if(updateDelta<>(mRawA, newVal))
    {
        emit valueParamChanged();
        emit linearValueParamChanged();
    }
}
double LinearSlot::rawB() const
{
    return mRawB;
}
void LinearSlot::setRawB(double newVal)
{
    if(updateDelta<>(mRawB, newVal))
    {
        emit valueParamChanged();
        emit linearValueParamChanged();
    }
}
double LinearSlot::oorRaw() const
{
    return mOorRaw;
}
void LinearSlot::setOorRaw(double newVal)
{
    if(updateDelta<>(mOorRaw, newVal))
    {
        emit valueParamChanged();
        emit linearValueParamChanged();
    }
}

double LinearSlot::asFloat(QVariant raw) const
{
    bool convertedOk = false;
    double rawConv = raw.toDouble(&convertedOk);
    if(!convertedOk || !inRange(rawConv, mRawA, mRawB))
        return mOorEngr;
    return (rawConv - mRawA) / (mRawB - mRawA) * (mEngrB - mEngrA) + mEngrA;
}

QString LinearSlot::asString(QVariant raw) const
{
    double engr = asFloat(raw);
    if(base() == 10)
        return QString::number(engr, 'f', precision());
    else
        return QString::number(qint64(engr), base());
}

QVariant LinearSlot::asRaw(QVariant engr) const
{
    bool convertedOk = false;
    double engrConv;
    if(base() == 10 || engr.type() != QVariant::Type::String)
    {
        engrConv = engr.toDouble(&convertedOk);
    }
    else
    {
        QString engrStr = engr.toString();
        engrConv = engrStr.toLongLong(&convertedOk, base());
    }

    if(!convertedOk || !inRange(engrConv, mEngrA, mEngrB))
        return mOorRaw;
    double raw = (engrConv - mEngrA) / (mEngrB - mEngrA) * (mRawB - mRawA) + mRawA;

    if(storageType() != QMetaType::Float && storageType() != QMetaType::Double)
        raw = round(raw);
    QVariant rawVar = raw;
    if(rawVar.convert(storageType()))
        return rawVar;
    else
        return mOorRaw;
}

bool LinearSlot::rawInRange(QVariant raw) const
{
    bool convertedOk = false;
    double rawConv = raw.toDouble(&convertedOk);
    return (convertedOk && inRange(rawConv, mRawA, mRawB));
}

bool LinearSlot::engrInRange(QVariant engr) const
{
    bool convertedOk = false;
    double engrConv;
    if(base() == 10 || engr.type() != QVariant::Type::String)
    {
        engrConv = engr.toDouble(&convertedOk);
    }
    else
    {
        QString engrStr = engr.toString();
        engrConv = engrStr.toLongLong(&convertedOk, base());
    }

    return (convertedOk && inRange(engrConv, mEngrA, mEngrB));
}

QVariant LinearSlot::rawMin() const
{
    return std::min(mRawA, mRawB);
}

QVariant LinearSlot::rawMax() const
{
    return std::max(mRawA, mRawB);
}

QVariant LinearSlot::engrMin() const
{
    return std::min(mEngrA, mEngrB);
}

QVariant LinearSlot::engrMax() const
{
    return std::max(mEngrA, mEngrB);
}

QValidator *LinearSlot::validator()
{
    return mValidator;
}

void LinearSlot::updateValidator()
{
    if(mEngrA > mEngrB)
        mValidator->setRange(mEngrB, mEngrA, precision());
    else
        mValidator->setRange(mEngrA, mEngrB, precision());
}

} // namespace SetupTools
