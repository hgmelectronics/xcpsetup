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
EBUSSETUPTOOLSSHARED_EXPORT QList<MultiselectListWrapper *> &MultiselectListModel::list() { return mList; }
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
        QList<MultiselectListWrapper *>::iterator firstIt = std::find(model->list().begin(), model->list().end(), wrapper);
        QList<MultiselectListWrapper *>::iterator clickedLastIt = std::find_if(model->list().begin(), model->list().end(), IsClickedLast);
        QList<MultiselectListWrapper *>::iterator lastIt = clickedLastIt;

        if(firstIt != model->list().end() && lastIt != model->list().end())
        {
            // found the beginning and end of the range
            // put them in the right order
            if(firstIt > lastIt)
                std::swap(firstIt, lastIt);
            // increment lastIt so we actually set the element it refers to
            ++lastIt;

            // make all elements in the range like the one clicked last time
            for(QList<MultiselectListWrapper *>::iterator it = firstIt; it != lastIt; ++it)
                (*it)->setSelected((*clickedLastIt)->selected());
        }
    }
    else if(modifiers & Qt::ControlModifier)
    {
        for(MultiselectListWrapper *item: model->list())
            item->setClickedLast(item == wrapper);
        wrapper->setSelected(!wrapper->selected());
    }
    else
    {
        for(MultiselectListWrapper *item: model->list())
        {
            item->setClickedLast(item == wrapper);
            item->setSelected(item == wrapper);
        }
    }
}

EBUSSETUPTOOLSSHARED_EXPORT QVariantObject::QVariantObject(QObject *parent) : QObject(parent) {}
EBUSSETUPTOOLSSHARED_EXPORT QVariantObject::QVariantObject(const QVariant &var, QObject *parent) : QObject(parent), QVariant(var) {}
