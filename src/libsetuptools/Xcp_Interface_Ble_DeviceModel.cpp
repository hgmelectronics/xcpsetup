#include "Xcp_Interface_Ble_DeviceModel.h"
#include "Xcp_Interface_Ble_Interface.h"

namespace SetupTools {
namespace Xcp {
namespace Interface {
namespace Ble {

DeviceModel::DeviceModel(QObject *parent) :
    QAbstractListModel(parent),
    mRestartQueued(false)
{
    connect(&mAgent, &QBluetoothDeviceDiscoveryAgent::canceled, this, &DeviceModel::onAgentCanceled);
    connect(&mAgent, &QBluetoothDeviceDiscoveryAgent::deviceDiscovered, this, &DeviceModel::onAgentDeviceDiscovered);
    connect(&mAgent, static_cast<void(QBluetoothDeviceDiscoveryAgent::*)(QBluetoothDeviceDiscoveryAgent::Error)>(&QBluetoothDeviceDiscoveryAgent::error), this, &DeviceModel::onAgentError);
    connect(&mAgent, &QBluetoothDeviceDiscoveryAgent::finished, this, &DeviceModel::onAgentFinished);
}

int DeviceModel::rowCount(const QModelIndex &parent) const
{
    Q_UNUSED(parent);
    return mDevices.size();
}

QVariant DeviceModel::data(const QModelIndex &index, int role) const
{
    if(!index.isValid()
            || index.column() != 0
            || index.row() < 0
            || index.row() >= mDevices.size())
        return QVariant();

    if(role == Qt::DisplayRole)
        return mDevices[index.row()].name();
    else if(role == Qt::UserRole)
#ifdef Q_OS_MAC
        return mDevices[index.row()].deviceUuid().toString();
#else
        return mDevices[index.row()].address().toString();
#endif

    return QVariant();
}

QHash<int, QByteArray> DeviceModel::roleNames() const
{
    const QHash<int, QByteArray> ROLE_NAMES = {{
        {Qt::DisplayRole, "display"},
        {Qt::UserRole, "addr"}
    }};

    return ROLE_NAMES;
}

bool DeviceModel::isActive()
{
    return mAgent.isActive();
}

void DeviceModel::start()
{
    if(mAgent.isActive())
    {
        mRestartQueued = true;
        mAgent.stop();
    }
    else
    {
        clearAll();
        mAgent.setInquiryType(QBluetoothDeviceDiscoveryAgent::LimitedInquiry);
        mAgent.start();
        emit isActiveChanged();
    }
}

void DeviceModel::stop()
{
    mRestartQueued = false;
    if(mAgent.isActive())
        mAgent.stop();
}

void DeviceModel::onAgentCanceled()
{
    emit isActiveChanged();
    if(mRestartQueued)
    {
        mAgent.setInquiryType(QBluetoothDeviceDiscoveryAgent::LimitedInquiry);
        mAgent.start();
        emit isActiveChanged();
    }
}

void DeviceModel::onAgentDeviceDiscovered(const QBluetoothDeviceInfo &info)
{
    if(isPossibleSlave(info))
        append(info);
}

void DeviceModel::onAgentError(QBluetoothDeviceDiscoveryAgent::Error err)
{
    Q_UNUSED(err);

    emit isActiveChanged();
    emit error(mAgent.errorString());
}

void DeviceModel::onAgentFinished()
{
    emit isActiveChanged();
}

void DeviceModel::append(const QBluetoothDeviceInfo & info)
{
    beginInsertRows(QModelIndex(), mDevices.size(), mDevices.size());
    mDevices.append(info);
    endInsertRows();
}

void DeviceModel::clearAll()
{
    beginRemoveRows(QModelIndex(), 0, mDevices.size() - 1);
    mDevices.clear();
    endRemoveRows();
}

bool DeviceModel::isPossibleSlave(const QBluetoothDeviceInfo & info)
{
    QBluetoothDeviceInfo::DataCompleteness completeness;
    QList<QBluetoothUuid> serviceUuids = info.serviceUuids(&completeness);

    QStringList serviceUuidStrings;
    for(QBluetoothUuid uuid : serviceUuids)
        serviceUuidStrings.append(uuid.toString());
    qDebug() << "Discovered device, uuid" << info.deviceUuid().toString() << "name" << info.name() << "services" << serviceUuidStrings << "completeness" << completeness;

    if(serviceUuids.contains(XCP_SERVICE_UUID))
        return true;
    if(serviceUuids.isEmpty() && completeness == QBluetoothDeviceInfo::DataUnavailable)
        return true;
    return false;
}

} // namespace Ble
} // namespace Interface
} // namespace Xcp
} // namespace SetupTools
