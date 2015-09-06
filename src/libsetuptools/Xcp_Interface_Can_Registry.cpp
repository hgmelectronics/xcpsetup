#include "Xcp_Interface_Can_Registry.h"
#include "Xcp_Interface_Can_Elm327_Interface.h"
#include "Xcp_Interface_Can_Socket_Interface.h"

namespace SetupTools
{
namespace Xcp
{
namespace Interface
{
namespace Can
{

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
    if(!ret)
        ret = Socket::Registry::make(uri);
    /*if(!ret)
        ret = Ics::Registry::make(uri);*/
    return ret;
}

QString Registry::desc(QUrl uri)
{
    QString ret;
    ret = Elm327::Registry::desc(uri);
    if(!ret.length())
        ret = Socket::Registry::desc(uri);
    /*if(!ret.length())
        ret = Ics::Registry::desc(uri);*/
    return ret;
}

}
}
}
}
