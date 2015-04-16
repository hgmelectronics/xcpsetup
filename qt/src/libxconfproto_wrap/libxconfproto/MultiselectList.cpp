#include "MultiselectList.h"

LIBXCONFPROTOSHARED_EXPORT MultiselectListWrapper::MultiselectListWrapper(QObject *parent) :
    QObject(parent),
    mSelected(false),
    mClickedLast(false),
    mObj(NULL)
{}

LIBXCONFPROTOSHARED_EXPORT MultiselectListWrapper::~MultiselectListWrapper() {}

LIBXCONFPROTOSHARED_EXPORT QString MultiselectListWrapper::displayText() const { return mDisplayText; }

LIBXCONFPROTOSHARED_EXPORT void MultiselectListWrapper::setDisplayText(QString text)
{
    if(mDisplayText != text)
    {
        mDisplayText = text;
        emit displayTextChanged();
    }
}

LIBXCONFPROTOSHARED_EXPORT bool MultiselectListWrapper::selected() const { return mSelected; }

LIBXCONFPROTOSHARED_EXPORT void MultiselectListWrapper::setSelected(bool selected)
{
    if(mSelected != selected)
    {
        mSelected = selected;
        emit selectedChanged();
    }
}

LIBXCONFPROTOSHARED_EXPORT bool MultiselectListWrapper::clickedLast() const { return mClickedLast; }

LIBXCONFPROTOSHARED_EXPORT void MultiselectListWrapper::setClickedLast(bool clickedLast)
{
    if(mClickedLast != clickedLast)
    {
        mClickedLast = clickedLast;
        emit clickedLastChanged();
    }
}

LIBXCONFPROTOSHARED_EXPORT QObject *MultiselectListWrapper::obj() const { return mObj; }

LIBXCONFPROTOSHARED_EXPORT void MultiselectListWrapper::setObj(QObject *obj)
{
    if(mObj != obj)
    {
        obj->setParent(this);
        mObj = obj;
        emit objChanged();
    }
}

LIBXCONFPROTOSHARED_EXPORT MultiselectListModel::MultiselectListModel(QObject *parent) :
    QAbstractListModel(parent)
{}
LIBXCONFPROTOSHARED_EXPORT MultiselectListModel::~MultiselectListModel() {}
LIBXCONFPROTOSHARED_EXPORT int MultiselectListModel::rowCount(const QModelIndex & parent) const
{
    Q_UNUSED(parent);
    return mList.size();
}
LIBXCONFPROTOSHARED_EXPORT QHash<int, QByteArray> MultiselectListModel::roleNames() const
{
    static const QHash<int, QByteArray> NAMES({{0, "wrapper"}});
    return NAMES;
}
LIBXCONFPROTOSHARED_EXPORT QList<MultiselectListWrapper *> &MultiselectListModel::list() { return mList; }
LIBXCONFPROTOSHARED_EXPORT std::unordered_set<MultiselectListWrapper *> MultiselectListModel::checked()
{
    std::unordered_set<MultiselectListWrapper *> checkedItems;
    for(MultiselectListWrapper *item : mList)
        if(item->selected())
            checkedItems.insert(item);
    return checkedItems;
}
LIBXCONFPROTOSHARED_EXPORT QVariant MultiselectListModel::data(const QModelIndex &index, int role) const
{
    if(index.column() > 0)
        return QVariant();
    if(index.row() >= mList.size())
        return QVariant();

    if(role == 0)
        return QVariant::fromValue(mList[index.row()]);

    return QVariant();
}
LIBXCONFPROTOSHARED_EXPORT QVariant MultiselectListModel::headerData(int section, Qt::Orientation orientation, int role) const
{
    Q_UNUSED(section);
    Q_UNUSED(orientation);
    Q_UNUSED(role);

    return QVariant();
}

LIBXCONFPROTOSHARED_EXPORT bool IsClickedLast(MultiselectListWrapper *a)
{
    return a->clickedLast();
}

LIBXCONFPROTOSHARED_EXPORT MultiselectListController::MultiselectListController(QObject *parent) :
    QObject(parent)
{}
LIBXCONFPROTOSHARED_EXPORT MultiselectListController::~MultiselectListController() {}
LIBXCONFPROTOSHARED_EXPORT void MultiselectListController::clicked(int modifiers, MultiselectListModel *model, MultiselectListWrapper *wrapper)
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
    else
    {
        for(MultiselectListWrapper *item: model->list())
            item->setClickedLast(item == wrapper);
        wrapper->setSelected(!wrapper->selected());
    }
}
