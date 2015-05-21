#ifndef SETUPTOOLS_XCP_INTERFACE_REGISTRY_H
#define SETUPTOOLS_XCP_INTERFACE_REGISTRY_H

#include <QObject>
#include <Xcp_Interface_Interface.h>
#include <QtQml/QQmlEngine>
#include <QtQml/QJSEngine>
#include <QtQml/QQmlListProperty>
#include <QUrl>

namespace SetupTools {
namespace Xcp {
namespace Interface {

class  Registry : public QObject
{
    Q_OBJECT
public:
    Q_INVOKABLE static QList<QUrl> avail();
    Q_INVOKABLE static Interface *make(QUrl uri);
    Q_INVOKABLE static QString desc(QUrl uri);
};

class  Info : public QObject
{
    Q_OBJECT
    Q_PROPERTY(QUrl uri READ uri CONSTANT)
    Q_PROPERTY(QUrl text READ text CONSTANT)
public:
    Info();
    Info(QUrl uri, QString text, QObject *parent = 0);
    QUrl uri();
    QString text();
private:
    QUrl mUri;
    QString mText;
};

class  QmlRegistry : public QObject
{
    Q_OBJECT
    Q_PROPERTY(QQmlListProperty<SetupTools::Xcp::Interface::Info> avail READ avail CONSTANT)
public:
    explicit QmlRegistry(QObject *parent = 0);
    static Info *listPropAt(QQmlListProperty<SetupTools::Xcp::Interface::Info> *property, int index);
    static int listPropCount(QQmlListProperty<SetupTools::Xcp::Interface::Info> *property);
    QQmlListProperty<SetupTools::Xcp::Interface::Info> avail();
private:
    QList<Info *> mAvail;
};


} // namespace Interface
} // namespace Xcp
} // namespace SetupTools

#endif // SETUPTOOLS_XCP_INTERFACE_REGISTRY_H
