#include "EncodingSlot.h"
#include "util.h"

namespace SetupTools {

EncodingSlot::EncodingSlot(QObject *parent) :
    Slot(parent),
    oorFloat(NAN),
    mUnencodedSlot(nullptr)
{}

Slot *EncodingSlot::unencodedSlot()
{
    return mUnencodedSlot;
}

void EncodingSlot::setUnencodedSlot(Slot *slot)
{
    if(mUnencodedSlot != slot)
    {
        if(mUnencodedSlot)
            disconnect(mUnencodedSlot, &Slot::unitChanged, this, &EncodingSlot::onUnencodedSlotUnitChanged);
        mUnencodedSlot = slot;
        connect(mUnencodedSlot, &Slot::unitChanged, this, &EncodingSlot::onUnencodedSlotUnitChanged);
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
            }
        }
    }
    emit encodingListChanged();
}

QStringList EncodingSlot::encodingStringList()
{
    QStringList list;
    for(const EncodingPair &pair : mList)
        list.append(pair.text);
    return list;
}

double EncodingSlot::toFloat(QVariant raw) const
{
    bool convOk;
    double rawDouble = raw.toDouble(&convOk);
    if(!convOk)
        rawDouble = NAN;

    if(mRawToEngr.count(rawDouble))
        return rawDouble;
    else if(mUnencodedSlot)
        return mUnencodedSlot->toFloat(raw);
    else
        return oorFloat;
}

QString EncodingSlot::toString(QVariant raw) const
{
    bool convOk;
    double rawDouble = raw.toDouble(&convOk);
    if(!convOk)
        rawDouble = NAN;

    if(mRawToEngr.count(rawDouble))
        return mRawToEngr[rawDouble];
    else if(mUnencodedSlot)
        return mUnencodedSlot->toString(raw);
    else
        return oorString;
}

QVariant EncodingSlot::toRaw(QVariant engr) const
{
    QString engrString = engr.toString();
    if(mEngrToRaw.count(engrString))
    {
        QVariant rawVar = mEngrToRaw[engrString];
        rawVar.convert(storageType());
        return rawVar;
    }
    else if(mUnencodedSlot)
    {
        return mUnencodedSlot->toRaw(engr);
    }
    else
    {
        return oorRaw;
    }
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
    }
}

void EncodingSlot::onUnencodedSlotUnitChanged()
{
    setUnit(mUnencodedSlot->unit());
}

} // namespace SetupTools

