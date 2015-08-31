#include "Xcp_TableParamModel.h"
#include "Xcp_TableParam.h"
#include <QVector>

namespace SetupTools {
namespace Xcp {

static int roleToIndex(int role)
{
    return role - Qt::UserRole;
}

static int indexToRole(int index)
{
    return index +  Qt::UserRole;
}

TableParamMapper::TableParamMapper(QObject* parent) :
    QAbstractListModel(parent),
    mStringFormat(false),
    mMapping(),
    mParamEntries(),
    mRoleNames(),
    mRowCount(0)
{

}


/**
 * @brief TableParamModel::rowCount
 * @param parent
 * @return returns number of rows of the longest model, hopefully all the same.
 */
int TableParamMapper::rowCount(const QModelIndex &parent) const
{
    return parent.isValid() ? 0 : mRowCount;
}

bool TableParamMapper::isValidRole(int role) const
{
    int index = roleToIndex(role);
    return 0 <= index && index < mParamEntries.count();
}

bool TableParamMapper::isValidIndexAndRole(const QModelIndex &index, int role) const
{
    return index.isValid()
            && index.column() == 0
            && index.row() >= 0
            && index.row() < mRowCount
            && isValidRole(role);

}

void TableParamMapper::setStringFormat(bool format)
{
    if(format==mStringFormat)
    {
        return;
    }
    mStringFormat = format;
    emit stringFormatChanged();
    emit onValueParamChanged();
}


void TableParamMapper::setMapping(const QVariantMap& map)
{
    if(map==mMapping)
        return;

    mMapping = map;

    for(TableParam* param: mParamEntries)
    {
        disconnect(param->slot(), &Slot::valueParamChanged, this, &TableParamMapper::onValueParamChanged);
        disconnect(param->range(), &TableMemoryRange::dataChanged, this, &TableParamMapper::onRangeDataChanged);
    }

    mRowCount = 0;
    mRoleNames.clear();

    for(QVariantMap::const_iterator i = map.constBegin(); i != map.constEnd(); ++i)
    {
        QVariant value = i.value();
        if(!value.canConvert<TableParam*>())
        {
            return;
        }

        TableParam* param = value.value<TableParam*>();

        connect(param->slot(), &Slot::valueParamChanged, this, &TableParamMapper::onValueParamChanged);
        connect(param->range(), &TableMemoryRange::dataChanged, this, &TableParamMapper::onRangeDataChanged);

        int rowCount = param->count();
        if(rowCount > mRowCount)
        {
            mRowCount = rowCount;
        }

        int count = mParamEntries.count();
        mRoleNames.insert(indexToRole(count),i.key().toUtf8());
        mParamEntries.append(param);
    }

    onValueParamChanged();
    emit mappingChanged();
}


QVariant TableParamMapper::data(const QModelIndex &index, int role) const
{
    if(!isValidIndexAndRole(index, role))
    {
        return QVariant();
    }

    TableParam* param = mParamEntries[roleToIndex(role)];

    QVariant rawData = param->range()->get(index.row());

    if(mStringFormat)
        return param->slot()->asString(rawData);
    else
        return param->slot()->asFloat(rawData);
}

QVariant TableParamMapper::headerData(int section, Qt::Orientation orientation, int role) const
{
    if(section != 0 || orientation != Qt::Horizontal || !isValidRole(role))
    {
        return QVariant();
    }

    return mRoleNames[role];
}

bool TableParamMapper::setData(const QModelIndex &index, const QVariant &value, int role)
{
    if(!isValidIndexAndRole(index, role))
    {
        return false;
    }

    TableParam* param = mParamEntries[roleToIndex(role)];

    return param->set(index.row(), value);
}

Qt::ItemFlags TableParamMapper::flags(const QModelIndex &index) const
{
    Q_UNUSED(index);
    return Qt::ItemIsEnabled | Qt::ItemIsSelectable | Qt::ItemIsEditable;
}

QHash<int, QByteArray> TableParamMapper::roleNames() const
{
    return mRoleNames;
}

void TableParamMapper::onValueParamChanged()
{
    onRangeDataChanged(0, mRowCount);
}

void TableParamMapper::onRangeDataChanged(quint32 beginChanged, quint32 endChanged)
{
    QVector<int> roleVector(mRoleNames.keys().toVector());
    emit dataChanged(index(beginChanged), index(endChanged - 1), roleVector);
}


} // namespace Xcp
} // namespace SetupTools

