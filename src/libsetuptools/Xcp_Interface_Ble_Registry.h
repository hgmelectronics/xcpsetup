#ifndef SETUPTOOLS_XCP_INTERFACE_BLE_REGISTRY_H
#define SETUPTOOLS_XCP_INTERFACE_BLE_REGISTRY_H

#include <QList>
#include <QUrl>
#include <Xcp_Interface_Ble_Interface.h>
#include <Xcp_Interface_Registry.h>

namespace SetupTools {
namespace Xcp {
namespace Interface {
namespace Ble {

class Registry
{
public:
    static QList<QUrl> avail();
    static Interface *make(QUrl uri);
    static QString desc(QUrl uri);
};

} // namespace Ble
} // namespace Interface
} // namespace Xcp
} // namespace SetupTools

#endif // SETUPTOOLS_XCP_INTERFACE_BLE_REGISTRY_H
