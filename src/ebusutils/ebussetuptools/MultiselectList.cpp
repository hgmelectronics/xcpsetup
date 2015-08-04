#include "MultiselectList.h"

MultiselectListWrapper::MultiselectListWrapper(QObject *parent) :
    QObject(parent),
    mSelected(false),
    mClickedLast(false),
    mObj(NULL)
{}

MultiselectListWrapper::~MultiselectListWrapper() {}

QString MultiselectListWrapper::displayText() const { return mDisplayText; }

void MultiselectListWrapper::setDisplayText(QString text)
{
    if(mDisplayText != text)
    {
        mDisplayText = text;
        emit displayTextChanged();
    }
}

bool MultiselectListWrapper::selected() const { return mSelected; }

void MultiselectListWrapper::setSelected(bool selected)
{
    if(mSelected != selected)
    {
        mSelected = selected;
        emit selectedChanged();
    }
}

bool MultiselectListWrapper::clickedLast() const { return mClickedLast; }

void MultiselectListWrapper::setClickedLast(bool clickedLast)
{
    if(mClickedLast != clickedLast)
    {
        mClickedLast = clickedLast;
        emit clickedLastChanged();
    }
}

QObject *MultiselectListWrapper::obj() const { return mObj; }

void MultiselectListWrapper::setObj(QObject *obj)
{
    if(mObj != obj)
    {
        obj->setParent(this);
        mObj = obj;
        emit objChanged();
    }
}

MultiselectListModel::MultiselectListModel(QObject *parent) :
    QAbstractListModel(parent)
{}
MultiselectListModel::~MultiselectListModel() {}
int MultiselectListModel::rowCount(const QModelIndex & parent) const
{
    Q_UNUSED(parent);
    return mList.size();
}

QHash<int, QByteArray> MultiselectListModel::roleNames() const
{
    static const QHash<int, QByteArray> NAMES({{0, "wrapper"}});
    return NAMES;
}

bool MultiselectListModel::insertRows(int row, int count, const QModelIndex &parent)
{
    if(parent != QModelIndex()
            || row > rowCount()
            || count <= 0)
        return false;
    beginInsertRows(QModelIndex(), row, row + count - 1);
    for(int iRow = 0; iRow < count; ++iRow)
        mList.insert(row, NULL);
    endInsertRows();
    return true;
}

bool MultiselectListModel::removeRows(int row, int count, const QModelIndex &parent)
{
    if(parent != QModelIndex()
            || row < 0
            || count <= 0
            || (row + count) > mList.size())
        return false;
    beginRemoveRows(QModelIndex(), row, row + count - 1);
    for(int iRow = row; iRow < (row + count); ++iRow)
    {
        if(mList[iRow] != NULL)
            delete mList[iRow];
    }
    mList.erase(mList.begin() + row, mList.begin() + row + count);
    endRemoveRows();
    return true;
}

std::unordered_set<MultiselectListWrapper *> MultiselectListModel::checked()
{
    std::unordered_set<MultiselectListWrapper *> checkedItems;
    for(MultiselectListWrapper *item : mList)
        if(item->selected())
            checkedItems.insert(item);
    return checkedItems;
}
QVariant MultiselectListModel::data(const QModelIndex &index, int role) const
{
    if(index.column() > 0)
        return QVariant();
    if(index.row() >= mList.size())
        return QVariant();

    if(role == 0)
        return QVariant::fromValue(mList[index.row()]);

    return QVariant();
}

MultiselectListWrapper *MultiselectListModel::wrapper(int row)
{
    if(row >= mList.size())
        return NULL;
    return mList[row];
}

void MultiselectListModel::alteredData(int row)
{
    if(row >= mList.size())
        return;

    emit dataChanged(index(row), index(row), {0});
}

void MultiselectListModel::alteredData(int firstRow, int lastRow)
{
    if(firstRow >= mList.size()
            || lastRow >= mList.size()
            || firstRow > lastRow)
        return;

    emit dataChanged(index(firstRow), index(lastRow), {0});
}

bool MultiselectListModel::setData(const QModelIndex &dataIndex, const QVariant &value, int role)
{
    if(role != 0
            || dataIndex.column() != 0
            || dataIndex.row() < 0
            || dataIndex.row() >= mList.size())
        return false;

    if(mList[dataIndex.row()] != NULL)
        delete mList[dataIndex.row()];
    MultiselectListWrapper *newObj = value.value<MultiselectListWrapper *>();
    newObj->setParent(this);
    mList[dataIndex.row()] = newObj;
    emit dataChanged(index(dataIndex.row()), index(dataIndex.row()), {0});
    return true;
}

QVariant MultiselectListModel::headerData(int section, Qt::Orientation orientation, int role) const
{
    Q_UNUSED(section);
    Q_UNUSED(orientation);
    Q_UNUSED(role);

    return QVariant();
}

bool IsClickedLast(MultiselectListWrapper *a)
{
    return a->clickedLast();
}

MultiselectListController::MultiselectListController(QObject *parent) :
    QObject(parent)
{}
MultiselectListController::~MultiselectListController() {}

void MultiselectListController::clicked(int modifiers, MultiselectListModel *model, MultiselectListWrapper *wrapper)
{
    if(modifiers & Qt::ShiftModifier)
    {
        int firstRow = -1;
        bool newSelectState = false;
        int lastRow = -1;
        for(int iRow = 0; iRow < model->rowCount(); ++iRow)
        {
           if(model->wrapper(iRow) == wrapper)
                firstRow = iRow;
            if(model->wrapper(iRow)->clickedLast())
            {
                lastRow = iRow;
                newSelectState = model->wrapper(iRow)->selected();
            }
        }

        if(firstRow >= 0 && lastRow >= 0)
        {
            // found the beginning and end of the range
            // put them in the right order
            if(firstRow > lastRow)
                std::swap(firstRow, lastRow);

            for(int iRow = firstRow; iRow <= lastRow; ++iRow)
                model->wrapper(iRow)->setSelected(newSelectState);
            model->alteredData(firstRow, lastRow);
        }
    }
    else if(modifiers & Qt::ControlModifier)
    {
        for(int iRow = 0; iRow < model->rowCount(); ++iRow)
        {
            MultiselectListWrapper *rowWrapper = model->wrapper(iRow);
            if(model->wrapper(iRow) == wrapper)
            {
                if(!rowWrapper->clickedLast())
                    rowWrapper->setClickedLast(true);
                rowWrapper->setSelected(!rowWrapper->selected());
                model->alteredData(iRow);
            }
            else
            {
                if(rowWrapper->clickedLast())
                {
                    rowWrapper->setClickedLast(false);
                    model->alteredData(iRow);
                }
            }
        }
    }
    else
    {
        for(int iRow = 0; iRow < model->rowCount(); ++iRow)
        {
            MultiselectListWrapper *rowWrapper = model->wrapper(iRow);
            if(rowWrapper == wrapper)
            {
                if(!rowWrapper->clickedLast() || !rowWrapper->selected())
                {
                    rowWrapper->setClickedLast(true);
                    rowWrapper->setSelected(true);
                    model->alteredData(iRow);
                }
            }
            else
            {
                if(rowWrapper->clickedLast() || rowWrapper->selected())
                {
                    rowWrapper->setClickedLast(false);
                    rowWrapper->setSelected(false);
                    model->alteredData(iRow);
                }
            }
        }
    }
}

QVariantObject::QVariantObject(QObject *parent) : QObject(parent) {}
QVariantObject::QVariantObject(const QVariant &var, QObject *parent) : QObject(parent), QVariant(var) {}
