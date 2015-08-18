#ifndef XCP_INTERFACE_REGISTRY_H
#define XCP_INTERFACE_REGISTRY_H

#include <QList>
#include <QUrl>
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

class Registry
{
public:
    static QList<QUrl> avail();
    static Interface *make(QUrl uri);
    static QString desc(QUrl uri);
};

}
}
}
}

#endif // XCP_INTERFACE_REGISTRY_H
