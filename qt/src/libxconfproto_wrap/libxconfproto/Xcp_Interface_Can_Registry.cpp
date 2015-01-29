#include "Xcp_Interface_Can_Registry.h"
#include <Xcp_Interface_Can_Elm327_Interface.h>

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

Registry::Registry(QObject *parent) :
    QObject(parent),
    mFactoriesAvail(getInterfacesAvail(this))
{
    for(Factory *factory : mFactoriesAvail)
        mInfosAvail.push_back(new Info(factory, this));
}

QQmlListProperty<SetupTools::Xcp::Interface::Can::Info> Registry::avail()
{
    return QQmlListProperty<SetupTools::Xcp::Interface::Can::Info>(this, NULL, &listPropCount, &listPropAt);
}

Info *Registry::listPropAt(QQmlListProperty<SetupTools::Xcp::Interface::Can::Info> *property, int index)
{
    Registry *registry = qobject_cast<Registry *>(property->object);
    return registry->mInfosAvail.at(index);
}

int Registry::listPropCount(QQmlListProperty<SetupTools::Xcp::Interface::Can::Info> *property)
{
    Registry *registry = qobject_cast<Registry *>(property->object);
    return registry->mInfosAvail.size();
}

QObject *registryProvider(QQmlEngine *engine, QJSEngine *scriptEngine)
{
    Q_UNUSED(engine);
    Q_UNUSED(scriptEngine);
    return new Registry();
}

}
}
}
}
