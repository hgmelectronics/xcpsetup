#include "EncodingSlot.h"
#include "util.h"

namespace SetupTools {

EncodingSlot::EncodingSlot(QObject *parent) :
    Slot(parent),
    oorFloat(NAN),
    mUnencodedSlot(nullptr),
    mValidator(new EncodingValidator(this))
{}

Slot *EncodingSlot::unencodedSlot()
{
    return mUnencodedSlot;
}

void EncodingSlot::setUnencodedSlot(Slot *slot)
{
    if(mUnencodedSlot != slot)
    {
        if(mUnencodedSlot) {
            disconnect(mUnencodedSlot, &Slot::unitChanged, this, &EncodingSlot::onUnencodedSlotUnitChanged);
            disconnect(mUnencodedSlot, &Slot::valueParamChanged, this, &EncodingSlot::onUnencodedSlotValueParamChanged);
        }
        mUnencodedSlot = slot;
        connect(mUnencodedSlot, &Slot::unitChanged, this, &EncodingSlot::onUnencodedSlotUnitChanged);
        connect(mUnencodedSlot, &Slot::valueParamChanged, this, &EncodingSlot::onUnencodedSlotValueParamChanged);
        emit valueParamChanged();
        emit unencodedSlotChanged();
        setUnit(mUnencodedSlot->unit());
    }
}

QVariant EncodingSlot::encodingList()
{
    QVariantList list;
    for(const EncodingPair &pair : mList)
    {
        QMap<QString, QVariant> map;
        map["raw"] = pair.raw;
        map["engr"] = pair.text;
        list.append(QVariant(map));
    }
    return list;
}

void EncodingSlot::setEncodingList(QVariant listVar)
{
    mList.clear();
    mRawToEngr.clear();
    mEngrToRaw.clear();
    mEngrToIndex.clear();

    mRawMin = std::numeric_limits<double>::max();
    mRawMax = std::numeric_limits<double>::lowest();

    QVariantList list = listVar.toList();
    for(QVariant listElem : list)
    {
        QMap<QString, QVariant> map = listElem.toMap();
        if(map.count("raw") && map.count("engr"))
        {
            bool rawOk = false;
            double raw = map["raw"].toDouble(&rawOk);
            QString engr = map["engr"].toString();
            if(rawOk && engr.size() > 0
                    && mEngrToRaw.count(engr) == 0
                    && mRawToEngr.count(raw) == 0)
            {
                mList.append({raw, engr});
                mRawToEngr[raw] = engr;
                mEngrToRaw[engr] = raw;
                mEngrToIndex[engr] = mList.size() - 1;
                mRawMin = std::min(mRawMin, raw);
                mRawMax = std::max(mRawMax, raw);
            }
        }
    }
    emit valueParamChanged();
    emit encodingListChanged();
}

QStringList EncodingSlot::encodingStringList()
{
    QStringList list;
    for(const EncodingPair &pair : mList)
        list.append(pair.text);
    return list;
}

double EncodingSlot::asFloat(QVariant raw) const
{
    bool convOk;
    double rawDouble = raw.toDouble(&convOk);
    if(!convOk)
        rawDouble = NAN;

    if(mUnencodedSlot)
        return mUnencodedSlot->asFloat(raw);
    if(mRawToEngr.count(rawDouble))
        return rawDouble;
    return oorFloat;
}

QString EncodingSlot::asString(QVariant raw) const
{
    bool convOk;
    double rawDouble = raw.toDouble(&convOk);

    QString str = oorString;

    if(convOk)
    {
        if(mRawToEngr.count(rawDouble))
            str = mRawToEngr[rawDouble];
        else if(mUnencodedSlot)
            str = mUnencodedSlot->asString(raw);
    }

    return str;
}

QVariant EncodingSlot::asRaw(QVariant engr) const
{
    if(engr.type() == QVariant::Type::String && mEngrToRaw.count(engr.toString()))
    {
        QVariant rawVar = mEngrToRaw[engr.toString()];
        rawVar.convert(storageType());
        return rawVar;
    }

    if(mUnencodedSlot)
        return mUnencodedSlot->asRaw(engr);

    return oorRaw;
}

bool EncodingSlot::rawInRange(QVariant raw) const
{
    bool convOk;
    double rawDouble = raw.toDouble(&convOk);
    if(!convOk)
        rawDouble = NAN;


    if(mRawToEngr.count(rawDouble))
        return true;
    else if(mUnencodedSlot)
        return mUnencodedSlot->rawInRange(raw);
    else
        return false;
}

bool EncodingSlot::engrInRange(QVariant engr) const
{
    if(mEngrToRaw.count(engr.toString()))
        return true;
    else if(mUnencodedSlot)
        return mUnencodedSlot->engrInRange(engr);
    else
        return false;
}

int EncodingSlot::engrToEncodingIndex(QVariant engr) const
{
    QString engrString = engr.toString();
    if(mEngrToIndex.count(engrString))
        return mEngrToIndex[engrString];
    else
        return -1;
}

void EncodingSlot::append(double raw, QString engr)
{
    if(engr.size() > 0
            && mRawToEngr.count(raw) == 0
            && mEngrToRaw.count(engr) == 0)
    {
        mList.append({raw, engr});
        mRawToEngr[raw] = engr;
        mEngrToRaw[engr] = raw;
        mEngrToIndex[engr] = mList.size() - 1;
        emit valueParamChanged();
        emit encodingListChanged();
    }
}

QValidator *EncodingSlot::validator()
{
    return mValidator;
}

QVariant EncodingSlot::rawMin() const
{
    if(mUnencodedSlot)
        return std::min(mUnencodedSlot->rawMin().toDouble(), mRawMin);
    else
        return mRawMin;
}

QVariant EncodingSlot::rawMax() const
{
    if(mUnencodedSlot)
        return std::max(mUnencodedSlot->rawMax().toDouble(), mRawMax);
    else
        return mRawMax;
}

QVariant EncodingSlot::engrMin() const
{
    return asString(rawMin());
}

QVariant EncodingSlot::engrMax() const
{
    return asString(rawMax());
}

void EncodingSlot::onUnencodedSlotUnitChanged()
{
    setUnit(mUnencodedSlot->unit());
}

void EncodingSlot::onUnencodedSlotValueParamChanged()
{
    emit valueParamChanged();
}

EncodingValidator::EncodingValidator(EncodingSlot *parent) :
    QValidator(parent)
{
    connect(parent, &Slot::valueParamChanged, this, &EncodingValidator::slotChanged);
}

void EncodingValidator::slotChanged()
{
    emit changed();
}

QValidator::State EncodingValidator::validate(QString &input, int &pos) const
{
    static_assert(QValidator::State::Acceptable > QValidator::State::Intermediate, "Sorting order for QValidator::State not as expected");
    static_assert(QValidator::State::Intermediate > QValidator::State::Invalid, "Sorting order for QValidator::State not as expected");
    Q_UNUSED(pos);

    EncodingSlot *slot = qobject_cast<EncodingSlot *>(parent());
    Q_ASSERT(slot);

    QValidator::State encodedValid = QValidator::State::Invalid;
    QValidator::State unencodedValid = QValidator::State::Invalid;
    if(slot->mUnencodedSlot)
        unencodedValid = slot->mUnencodedSlot->validator()->validate(input, pos);

    if(slot->mEngrToRaw.count(input))
        encodedValid = QValidator::State::Acceptable;
    else
    {
        for(QString engr : slot->mEngrToRaw.keys())
        {
            if(engr.startsWith(input))
                encodedValid = QValidator::State::Intermediate;
        }
    }

    return std::max(encodedValid, unencodedValid);
}

} // namespace SetupTools

