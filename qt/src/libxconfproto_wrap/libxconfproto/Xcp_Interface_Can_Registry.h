#ifndef XCP_INTERFACE_REGISTRY_H
#define XCP_INTERFACE_REGISTRY_H

#include "libxconfproto_global.h"

#include <QObject>
#include <QList>
#include <QSharedPointer>
#include <QtQml/QQmlEngine>
#include <QtQml/QJSEngine>
#include <QtQml/QQmlListProperty>
#include <Xcp_Interface_Can_Interface.h>
#include <Xcp_Interface_Registry.h>

namespace SetupTools
{
namespace Xcp
{
namespace Interface
{
namespace Can
{

class LIBXCONFPROTOSHARED_EXPORT Factory : public QObject
{
    Q_OBJECT
    Q_PROPERTY(QString text READ text CONSTANT)
public:
    Factory(QObject *parent = 0);
    virtual ~Factory() {}
    virtual Interface *make(QObject *parent = 0) = 0;
    virtual QString text() = 0;
};

class LIBXCONFPROTOSHARED_EXPORT Info : public QObject
{
    Q_OBJECT
    Q_PROPERTY(QString text READ text CONSTANT)
public:
    Info();
    Info(Factory *factory, QObject *parent = 0);
    Q_INVOKABLE SetupTools::Xcp::Interface::Can::Interface *make(QObject *parent = 0);
    QString text();
private:
    Factory *mFactory;
};

QList<Factory *> LIBXCONFPROTOSHARED_EXPORT getInterfacesAvail(QObject *parent = 0);

class LIBXCONFPROTOSHARED_EXPORT LegacyRegistry : public QObject
{
    Q_OBJECT
    Q_PROPERTY(QQmlListProperty<SetupTools::Xcp::Interface::Can::Info> avail READ avail CONSTANT)
public:
    explicit LegacyRegistry(QObject *parent = 0);
    virtual ~LegacyRegistry() {}
    static Info *listPropAt(QQmlListProperty<SetupTools::Xcp::Interface::Can::Info> *property, int index);
    static int listPropCount(QQmlListProperty<SetupTools::Xcp::Interface::Can::Info> *property);
    QQmlListProperty<SetupTools::Xcp::Interface::Can::Info> avail();
signals:

public slots:
private:
    QList<Factory *> mFactoriesAvail;
    QList<Info *> mInfosAvail;
};

LIBXCONFPROTOSHARED_EXPORT QObject *registryProvider(QQmlEngine *engine, QJSEngine *scriptEngine);

class LIBXCONFPROTOSHARED_EXPORT Registry
{
public:
    static QList<QString> avail();
    static Interface *make(QString uri);
    static QString desc(QString uri);
};

}
}
}
}

#endif // XCP_INTERFACE_REGISTRY_H
