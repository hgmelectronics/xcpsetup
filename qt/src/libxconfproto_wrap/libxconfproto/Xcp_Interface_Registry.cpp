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
    if((ret = Can::Registry::make(uri)))
        return ret;
    return NULL;
}

} // namespace Interface
} // namespace Xcp
} // namespace SetupTools

