#include "Xcp_Interface_Can_Registry.h"
#include "Xcp_Interface_Can_Elm327_Interface.h"

namespace SetupTools
{
namespace Xcp
{
namespace Interface
{
namespace Can
{

Factory::Factory(QObject *parent) : QObject(parent) {}

Info::Info() :
    QObject(),
    mFactory(NULL)
{}
Info::Info(Factory *factory, QObject *parent) :
    QObject(parent),
    mFactory(factory)
{}

SetupTools::Xcp::Interface::Can::Interface *Info::make(QObject *parent)
{
    Q_ASSERT(mFactory);
    return mFactory->make(parent);
}

QString Info::text()
{
    Q_ASSERT(mFactory);
    return mFactory->text();
}

QList<Factory *> getInterfacesAvail(QObject *parent)
{
    QList<Factory *> ret;
    for(auto interface : Elm327::getInterfacesAvail(parent))
        ret.append(static_cast<Factory *>(interface));
    return ret;
}

LegacyRegistry::LegacyRegistry(QObject *parent) :
    QObject(parent),
    mFactoriesAvail(getInterfacesAvail(this))
{
    for(Factory *factory : mFactoriesAvail)
        mInfosAvail.push_back(new Info(factory, this));
}

QQmlListProperty<SetupTools::Xcp::Interface::Can::Info> LegacyRegistry::avail()
{
    return QQmlListProperty<SetupTools::Xcp::Interface::Can::Info>(this, NULL, &listPropCount, &listPropAt);
}

Info *LegacyRegistry::listPropAt(QQmlListProperty<SetupTools::Xcp::Interface::Can::Info> *property, int index)
{
    LegacyRegistry *registry = qobject_cast<LegacyRegistry *>(property->object);
    return registry->mInfosAvail.at(index);
}

int LegacyRegistry::listPropCount(QQmlListProperty<SetupTools::Xcp::Interface::Can::Info> *property)
{
    LegacyRegistry *registry = qobject_cast<LegacyRegistry *>(property->object);
    return registry->mInfosAvail.size();
}

QObject *registryProvider(QQmlEngine *engine, QJSEngine *scriptEngine)
{
    Q_UNUSED(engine);
    Q_UNUSED(scriptEngine);
    return new LegacyRegistry();
}

QList<QUrl> Registry::avail()
{
    QList<QUrl> ret;
    ret.append(Elm327::Registry::avail());
    return ret;
}

Interface *Registry::make(QUrl uri)
{
    Interface *ret;
    ret = Elm327::Registry::make(uri);
    /*if(!ret)
        ret = Ics::Registry::make(uri);*/
    return ret;
}

QString Registry::desc(QUrl uri)
{
    QString ret;
    ret = Elm327::Registry::desc(uri);
    /*if(!ret.length())
        ret = Ics::Registry::desc(uri);*/
    return ret;
}

}
}
}
}
