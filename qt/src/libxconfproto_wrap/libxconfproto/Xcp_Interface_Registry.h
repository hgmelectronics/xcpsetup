#ifndef SETUPTOOLS_XCP_INTERFACE_REGISTRY_H
#define SETUPTOOLS_XCP_INTERFACE_REGISTRY_H

#include <QObject>
#include <Xcp_Interface_Interface.h>
#include <QtQml/QQmlEngine>
#include <QtQml/QJSEngine>
#include <QtQml/QQmlListProperty>

namespace SetupTools {
namespace Xcp {
namespace Interface {

class LIBXCONFPROTOSHARED_EXPORT Registry : public QObject
{
    Q_OBJECT
public:
    Q_INVOKABLE static QList<QString> avail();
    Q_INVOKABLE static Interface *make(QString uri);
    Q_INVOKABLE static QString desc(QString uri);
};

class LIBXCONFPROTOSHARED_EXPORT Info : public QObject
{
    Q_OBJECT
    Q_PROPERTY(QString uri READ uri CONSTANT)
    Q_PROPERTY(QString text READ text CONSTANT)
public:
    Info();
    Info(QString uri, QString text, QObject *parent = 0);
    QString uri();
    QString text();
private:
    QString mUri, mText;
};

class LIBXCONFPROTOSHARED_EXPORT QmlRegistry : public QObject
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
