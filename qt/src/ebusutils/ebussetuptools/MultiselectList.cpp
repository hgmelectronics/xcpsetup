#include "MultiselectList.h"

EBUSSETUPTOOLSSHARED_EXPORT MultiselectListWrapper::MultiselectListWrapper(QObject *parent) :
    QObject(parent),
    mSelected(false),
    mClickedLast(false),
    mObj(NULL)
{}

EBUSSETUPTOOLSSHARED_EXPORT MultiselectListWrapper::~MultiselectListWrapper() {}

EBUSSETUPTOOLSSHARED_EXPORT QString MultiselectListWrapper::displayText() const { return mDisplayText; }

EBUSSETUPTOOLSSHARED_EXPORT void MultiselectListWrapper::setDisplayText(QString text)
{
    if(mDisplayText != text)
    {
        mDisplayText = text;
        emit displayTextChanged();
    }
}

EBUSSETUPTOOLSSHARED_EXPORT bool MultiselectListWrapper::selected() const { return mSelected; }

EBUSSETUPTOOLSSHARED_EXPORT void MultiselectListWrapper::setSelected(bool selected)
{
    if(mSelected != selected)
    {
        mSelected = selected;
        emit selectedChanged();
    }
}

EBUSSETUPTOOLSSHARED_EXPORT bool MultiselectListWrapper::clickedLast() const { return mClickedLast; }

EBUSSETUPTOOLSSHARED_EXPORT void MultiselectListWrapper::setClickedLast(bool clickedLast)
{
    if(mClickedLast != clickedLast)
    {
        mClickedLast = clickedLast;
        emit clickedLastChanged();
    }
}

EBUSSETUPTOOLSSHARED_EXPORT QObject *MultiselectListWrapper::obj() const { return mObj; }

EBUSSETUPTOOLSSHARED_EXPORT void MultiselectListWrapper::setObj(QObject *obj)
{
    if(mObj != obj)
    {
        obj->setParent(this);
        mObj = obj;
        emit objChanged();
    }
}

EBUSSETUPTOOLSSHARED_EXPORT MultiselectListModel::MultiselectListModel(QObject *parent) :
    QAbstractListModel(parent)
{}
EBUSSETUPTOOLSSHARED_EXPORT MultiselectListModel::~MultiselectListModel() {}
EBUSSETUPTOOLSSHARED_EXPORT int MultiselectListModel::rowCount(const QModelIndex & parent) const
{
    Q_UNUSED(parent);
    return mList.size();
}

EBUSSETUPTOOLSSHARED_EXPORT QHash<int, QByteArray> MultiselectListModel::roleNames() const
{
    static const QHash<int, QByteArray> NAMES({{0, "wrapper"}});
    return NAMES;
}

EBUSSETUPTOOLSSHARED_EXPORT bool MultiselectListModel::insertRows(int row, int count, const QModelIndex &parent)
{
    if(parent != QModelIndex()
            || row > rowCount()
            || count < 0)
        return false;
    beginInsertRows(QModelIndex(), row, row + count - 1);
    for(int iRow = 0; iRow < count; ++iRow)
        mList.insert(row, NULL);
    endInsertRows();
    return true;
}

EBUSSETUPTOOLSSHARED_EXPORT bool MultiselectListModel::removeRows(int row, int count, const QModelIndex &parent)
{
    if(parent != QModelIndex()
            || row < 0
            || count < 0
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

EBUSSETUPTOOLSSHARED_EXPORT std::unordered_set<MultiselectListWrapper *> MultiselectListModel::checked()
{
    std::unordered_set<MultiselectListWrapper *> checkedItems;
    for(MultiselectListWrapper *item : mList)
        if(item->selected())
            checkedItems.insert(item);
    return checkedItems;
}
EBUSSETUPTOOLSSHARED_EXPORT QVariant MultiselectListModel::data(const QModelIndex &index, int role) const
{
    if(index.column() > 0)
        return QVariant();
    if(index.row() >= mList.size())
        return QVariant();

    if(role == 0)
        return QVariant::fromValue(mList[index.row()]);

    return QVariant();
}

EBUSSETUPTOOLSSHARED_EXPORT MultiselectListWrapper *MultiselectListModel::wrapper(int row)
{
    if(row >= mList.size())
        return NULL;
    return mList[row];
}

EBUSSETUPTOOLSSHARED_EXPORT void MultiselectListModel::alteredData(int row)
{
    if(row >= mList.size())
        return;

    emit dataChanged(index(row), index(row), {0});
}

EBUSSETUPTOOLSSHARED_EXPORT void MultiselectListModel::alteredData(int firstRow, int lastRow)
{
    if(firstRow >= mList.size()
            || lastRow >= mList.size()
            || firstRow > lastRow)
        return;

    emit dataChanged(index(firstRow), index(lastRow), {0});
}

EBUSSETUPTOOLSSHARED_EXPORT bool MultiselectListModel::setData(const QModelIndex &dataIndex, const QVariant &value, int role)
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

EBUSSETUPTOOLSSHARED_EXPORT QVariant MultiselectListModel::headerData(int section, Qt::Orientation orientation, int role) const
{
    Q_UNUSED(section);
    Q_UNUSED(orientation);
    Q_UNUSED(role);

    return QVariant();
}

EBUSSETUPTOOLSSHARED_EXPORT bool IsClickedLast(MultiselectListWrapper *a)
{
    return a->clickedLast();
}

EBUSSETUPTOOLSSHARED_EXPORT MultiselectListController::MultiselectListController(QObject *parent) :
    QObject(parent)
{}
EBUSSETUPTOOLSSHARED_EXPORT MultiselectListController::~MultiselectListController() {}

EBUSSETUPTOOLSSHARED_EXPORT void MultiselectListController::clicked(int modifiers, MultiselectListModel *model, MultiselectListWrapper *wrapper)
{
    if(modifiers & Qt::ShiftModifier)
    {
        int firstRow = -1;
        bool newSelectState;
        int lastRow;
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

EBUSSETUPTOOLSSHARED_EXPORT QVariantObject::QVariantObject(QObject *parent) : QObject(parent) {}
EBUSSETUPTOOLSSHARED_EXPORT QVariantObject::QVariantObject(const QVariant &var, QObject *parent) : QObject(parent), QVariant(var) {}
