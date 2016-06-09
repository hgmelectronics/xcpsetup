#ifndef SETUPTOOLS_XCP_INTERFACE_REGISTRY_H
#define SETUPTOOLS_XCP_INTERFACE_REGISTRY_H

#include <QObject>
#include <Xcp_Interface_Interface.h>
#include <QtQml/QQmlEngine>
#include <QtQml/QJSEngine>
#include <QAbstractListModel>
#include <QUrl>
#include <QPair>

namespace SetupTools {
namespace Xcp {
namespace Interface {

class Registry : public QObject
{
    Q_OBJECT
public:
    Q_INVOKABLE static QList<QUrl> avail();
    Q_INVOKABLE static Interface *make(QUrl uri);
    Q_INVOKABLE static QString desc(QUrl uri);
};

class QmlRegistry : public QAbstractListModel
{
    Q_OBJECT
public:
    explicit QmlRegistry(QObject *parent = 0);
    Q_INVOKABLE void updateAvail();
    virtual int rowCount(const QModelIndex &parent) const;
    virtual QVariant data(const QModelIndex &index, int role) const;
    virtual QHash<int, QByteArray> roleNames() const;
    Q_INVOKABLE QString text(int index) const;
    Q_INVOKABLE QUrl uri(int index) const;
    Q_INVOKABLE int find(QUrl url) const;
private:
    static const QHash<int, QByteArray> ROLE_NAMES;

    QList<QPair<QUrl, QString> > mAvail;
};

} // namespace Interface
} // namespace Xcp
} // namespace SetupTools

#endif // SETUPTOOLS_XCP_INTERFACE_REGISTRY_H
