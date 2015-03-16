#ifndef SETUPTOOLS_XCP_INTERFACE_REGISTRY_H
#define SETUPTOOLS_XCP_INTERFACE_REGISTRY_H

#include <QObject>
#include <Xcp_Interface_Interface.h>

namespace SetupTools {
namespace Xcp {
namespace Interface {

class LIBXCONFPROTOSHARED_EXPORT Registry
{
public:
    static QList<QString> avail();
    static Interface *make(QString uri);
    static QString desc(QString uri);
};

} // namespace Interface
} // namespace Xcp
} // namespace SetupTools

#endif // SETUPTOOLS_XCP_INTERFACE_REGISTRY_H
