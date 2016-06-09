#include "Xcp_Interface_Registry.h"
#include "Xcp_Interface_Can_Registry.h"
#include <QDebug>

namespace SetupTools {
namespace Xcp {
namespace Interface {

QList<QUrl> Registry::avail()
{
    QList<QUrl> ret;
    ret.append(Can::Registry::avail());
    return ret;
}

Interface *Registry::make(QUrl uri)
{
    Interface *ret;
    ret = Can::Registry::make(uri);
    /*if(!ret)
        ret = Usb::Registry::make(uri);*/
    return ret;
}

QString Registry::desc(QUrl uri)
{
    QString ret;
    ret = Can::Registry::desc(uri);
    /*if(!ret.length())
        ret = Usb::Registry::desc(uri);*/
    return ret;
}

const QHash<int, QByteArray> QmlRegistry::ROLE_NAMES =
        QHash<int, QByteArray>({
                                   {Qt::DisplayRole, "display"},
                                   {Qt::UserRole, "uri"}
                               });

QmlRegistry::QmlRegistry(QObject *parent) : QAbstractListModel(parent)
{
    QList<QUrl> newUri = Registry::avail();

    mAvail.reserve(newUri.size());

    for(QUrl uri : newUri)
        mAvail.append(QPair<QUrl, QString>(uri, Registry::desc(uri)));
}

int QmlRegistry::rowCount(const QModelIndex &parent) const
{
    if(parent.isValid())
        return 0;

    return mAvail.size();
}

QVariant QmlRegistry::data(const QModelIndex &index, int role) const
{
    if(index.parent().isValid()
            || index.column() != 0
            || index.row() < 0
            || index.row() >= int(mAvail.size()))
        return QVariant();
    else if(role == Qt::DisplayRole)
        return mAvail[index.row()].second;
    else if(role == Qt::UserRole)
        return mAvail[index.row()].first;
    else
        return QVariant();
}

QHash<int, QByteArray> QmlRegistry::roleNames() const
{
    return ROLE_NAMES;
}

QString QmlRegistry::text(int index) const
{
    if(index < 0 || index >= mAvail.size())
        return QString();
    else
        return mAvail[index].second;
}

QUrl QmlRegistry::uri(int index) const
{
    if(index < 0 || index >= mAvail.size())
        return QUrl();
    else
        return mAvail[index].first;
}

int QmlRegistry::find(QUrl url) const
{
    for(int i = 0; i < mAvail.size(); ++i)
        if(url == mAvail[i].first)
            return i;
    return -1;
}

void QmlRegistry::updateAvail()
{
    QList<QUrl> newUris = Registry::avail();

    int newCount = newUris.count();
    int oldCount = mAvail.size();

    if(newCount == oldCount)
    {
        bool equal = true;
        for(int i = 0; i < newCount; ++i)
        {
            if(newUris[i] != mAvail[i].first)
            {
                equal = false;
                break;
            }
        }
        if(equal)
            return;
    }

    if(newCount > oldCount)
        beginInsertRows(QModelIndex(), oldCount, newCount - 1);
    else if(newCount < oldCount)
        beginRemoveRows(QModelIndex(), newCount, oldCount - 1);

    mAvail.clear();

    for(QUrl uri : newUris)
        mAvail.append(QPair<QUrl, QString>(uri, Registry::desc(uri)));

    if(newCount > oldCount)
        endInsertRows();
    else if(newCount < oldCount)
        endRemoveRows();

    emit dataChanged(index(0), index(newCount - 1), {Qt::DisplayRole, Qt::UserRole});
}

} // namespace Interface
} // namespace Xcp
} // namespace SetupTools

