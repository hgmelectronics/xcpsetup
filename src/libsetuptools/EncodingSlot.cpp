#include "EncodingSlot.h"
#include "util.h"

namespace SetupTools {

EncodingListModel::EncodingListModel(QObject *parent) :
    QAbstractListModel(parent)
{}

int EncodingListModel::rowCount(const QModelIndex &parent) const
{
    if(parent == QModelIndex())
        return mList.size();
    else
        return 0;
}

QVariant EncodingListModel::data(const QModelIndex &index, int role) const {
    if(index.column() != 0
            || index.row() < 0
            || index.row() >= mList.size())
        return QVariant();
    if(role == TEXT_ROLE)
        return mList[index.row()].text;
    else if(role == RAW_ROLE)
        return mList[index.row()].raw;
    else
        return QVariant();
}

bool EncodingListModel::setData(const QModelIndex &index, const QVariant &value, int role)
{
    if(index.column() != 0
            || index.row() < 0
            || index.row() >= mList.size())
        return false;
    EncodingPair &listPair = mList[index.row()];
    EncodingPair newPair = listPair;

    if(role == TEXT_ROLE)
    {
        newPair.text = value.toString();
        if(!newPair.text.size() || mEngrToRaw.count(newPair.text))
            return false;
    }
    else if(role == RAW_ROLE)
    {
        bool convOk = false;
        newPair.raw = value.toDouble(&convOk);
        if(!convOk || mRawToEngr.count(newPair.raw))
            return false;
    }
    else
    {
        return false;
    }

    if(newPair == listPair)
        return true;

    removeRowFromMaps(listPair);

    listPair = newPair;
    mRawToEngr[newPair.raw] = newPair.text;
    mEngrToRaw[newPair.text] = newPair.raw;

    emit changed();

    return true;
}

Qt::ItemFlags EncodingListModel::flags(const QModelIndex &index) const
{
    Q_UNUSED(index);
    return Qt::ItemIsEnabled | Qt::ItemIsSelectable | Qt::ItemIsEditable;
}

const int EncodingListModel::TEXT_ROLE;
const int EncodingListModel::RAW_ROLE;

QHash<int, QByteArray> EncodingListModel::roleNames() const
{
    static const QHash<int, QByteArray> ROLE_NAMES = {{TEXT_ROLE, "text"}, {RAW_ROLE, "raw"}};
    return ROLE_NAMES;
}

bool EncodingListModel::insertRows(int row, int count, const QModelIndex &parent)
{
    if(parent != QModelIndex()
            || row < 0
            || row > mList.size()
            || count < 0)
        return false;
    if(count == 0)
        return true;

    beginInsertRows(QModelIndex(), row, row + count - 1);
    mList.reserve(mList.size() + count);
    for(int i = 0; i < count; ++i)
        mList.insert(row, EncodingPair());
    endInsertRows();
    emit changed();
    return true;
}

bool EncodingListModel::removeRows(int row, int count, const QModelIndex &parent)
{
    if(parent != QModelIndex()
            || row < 0
            || (row + count) > mList.size()
            || count < 0)
        return false;
    if(count == 0)
        return true;

    beginRemoveRows(QModelIndex(), row, row + count - 1);
    for(int i = 0; i < count; ++i)
    {
        removeRowFromMaps(mList[row]);
        mList.removeAt(row);
    }
    endRemoveRows();
    emit changed();
    return true;
}

void EncodingListModel::append(double raw, QString engr)
{
    if(engr.size() > 0
            && mRawToEngr.count(raw) == 0
            && mEngrToRaw.count(engr) == 0)
    {
        beginInsertRows(QModelIndex(), mList.size(), mList.size());
        mList.append({raw, engr});
        mRawToEngr[raw] = engr;
        mEngrToRaw[engr] = raw;
        endInsertRows();
        emit changed();
    }
}

boost::optional<QString> EncodingListModel::rawToEngr(double raw) const
{
    if(mRawToEngr.count(raw) > 0)
        return mRawToEngr[raw];
    else
        return boost::optional<QString>();
}

boost::optional<double> EncodingListModel::engrToRaw(QString engr) const
{
    if(mEngrToRaw.count(engr) > 0)
        return mEngrToRaw[engr];
    else
        return boost::optional<double>();
}

void EncodingListModel::removeRowFromMaps(const EncodingPair &row)
{
    if(row.text.size() != 0)
    {
        mRawToEngr.erase(mRawToEngr.find(row.raw));
        mEngrToRaw.erase(mEngrToRaw.find(row.text));
    }
}

EncodingSlot::EncodingSlot(QObject *parent) :
    Slot(parent),
    oorFloat(NAN),
    mUnencodedSlot(nullptr),
    mModel(new EncodingListModel(this))
{
    connect(mModel, &EncodingListModel::changed, this, &EncodingSlot::onModelChanged);
}

Slot *EncodingSlot::unencodedSlot()
{
    return mUnencodedSlot;
}

void EncodingSlot::setUnencodedSlot(Slot *slot)
{
    if(updateDelta<>(mUnencodedSlot, slot))
        emit unencodedSlotChanged();
}

EncodingListModel *EncodingSlot::model()
{
    return mModel;
}

double EncodingSlot::toFloat(QVariant raw) const
{
    bool convOk;
    double rawDouble = raw.toDouble(&convOk);
    if(convOk)
        return rawDouble;
    else
        return oorFloat;
}

QString EncodingSlot::toString(QVariant raw) const
{
    bool convOk;
    double rawDouble = raw.toDouble(&convOk);
    if(!convOk)
        rawDouble = NAN;

    boost::optional<QString> engr = mModel->rawToEngr(rawDouble);
    if(engr)
        return engr.get();
    else if(mUnencodedSlot)
        return mUnencodedSlot->toString(raw);
    else
        return oorString;
}

QVariant EncodingSlot::toRaw(QVariant engr) const
{
    boost::optional<double> modelRawDouble = mModel->engrToRaw(engr.toString());
    if(modelRawDouble)
    {
        QVariant rawVar = modelRawDouble.get();
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


    boost::optional<QString> engr = mModel->rawToEngr(rawDouble);
    if(engr)
        return true;
    else if(mUnencodedSlot)
        return mUnencodedSlot->rawInRange(raw);
    else
        return false;
}

bool EncodingSlot::engrInRange(QVariant engr) const
{
    boost::optional<double> modelRawDouble = mModel->engrToRaw(engr.toString());
    if(modelRawDouble)
        return true;
    else if(mUnencodedSlot)
        return mUnencodedSlot->engrInRange(engr);
    else
        return false;
}

void EncodingSlot::onModelChanged()
{
    emit modelChanged();
}

} // namespace SetupTools

