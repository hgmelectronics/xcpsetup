#include "Xcp_Interface_Registry.h"
#include "Xcp_Interface_Can_Registry.h"

namespace SetupTools {
namespace Xcp {
namespace Interface {

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

} // namespace Interface
} // namespace Xcp
} // namespace SetupTools

