#include "Xcp_Interface_Registry.h"
#include "Xcp_Interface_Can_Registry.h"

namespace SetupTools {
namespace Xcp {
namespace Interface {

Info::Info() {}

Info::Info(QString uri, QString text, QObject *parent) :
    QObject(parent),
    mUri(uri),
    mText(text)
{}

QString Info::uri()
{
    return mUri;
}

QString Info::text()
{
    return mText;
}

QList<QString> Registry::avail()
{
    QList<QString> ret;
    ret.append(Can::Registry::avail());
    return ret;
}

Interface *Registry::make(QString uri)
{
    Interface *ret;
    ret = Can::Registry::make(uri);
    /*if(!ret)
        ret = Usb::Registry::make(uri);*/
    return ret;
}

QString Registry::desc(QString uri)
{
    QString ret;
    ret = Can::Registry::desc(uri);
    /*if(!ret.length())
        ret = Usb::Registry::desc(uri);*/
    return ret;
}

QmlRegistry::QmlRegistry(QObject *parent) : QObject(parent)
{
    for(QString uri : Registry::avail())
        mAvail.append(new Info(uri, Registry::desc(uri)));
}

QQmlListProperty<SetupTools::Xcp::Interface::Info> QmlRegistry::avail()
{
    return QQmlListProperty<SetupTools::Xcp::Interface::Info>(this, NULL, &listPropCount, &listPropAt);
}

Info *QmlRegistry::listPropAt(QQmlListProperty<SetupTools::Xcp::Interface::Info> *property, int index)
{
    QmlRegistry *registry = qobject_cast<QmlRegistry *>(property->object);
    return registry->mAvail.at(index);
}

int QmlRegistry::listPropCount(QQmlListProperty<SetupTools::Xcp::Interface::Info> *property)
{
    QmlRegistry *registry = qobject_cast<QmlRegistry *>(property->object);
    return registry->mAvail.size();
}

} // namespace Interface
} // namespace Xcp
} // namespace SetupTools

