#include "Xcp_Interface_Ble_Registry.h"

#include <QObject>
#include "QBluetoothDeviceDiscoveryAgent"

namespace SetupTools {
namespace Xcp {
namespace Interface {
namespace Ble {

QList<QUrl> Registry::avail()
{
    static const QList<QUrl> defaultList {QUrl("qtble:default")};

    QLowEnergyController * controller = QLowEnergyController::createCentral(QBluetoothDeviceInfo());
    auto error = controller->error();
    if(error == QLowEnergyController::InvalidBluetoothAdapterError || error == QLowEnergyController::UnknownError)
        return QList<QUrl>();
    else
        return defaultList;
}

Interface * Registry::make(QUrl uri)
{
    if(QString::compare(uri.scheme(), "qtble", Qt::CaseInsensitive) != 0
            || QString::compare(uri.fileName(), "default", Qt::CaseInsensitive) != 0)
        return nullptr;

    return new Interface();
}

QString Registry::desc(QUrl uri)
{
    if(QString::compare(uri.scheme(), "qtble", Qt::CaseInsensitive) != 0
            || QString::compare(uri.fileName(), "default", Qt::CaseInsensitive) != 0)
        return QString("");

    return QObject::tr("Bluetooth LE adapter");
}

} // namespace Ble
} // namespace Interface
} // namespace Xcp
} // namespace SetupTools
