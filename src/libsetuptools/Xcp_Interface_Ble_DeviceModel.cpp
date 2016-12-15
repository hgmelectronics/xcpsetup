#include "Xcp_Interface_Ble_DeviceModel.h"
#include "Xcp_Interface_Ble_Interface.h"

namespace SetupTools {
namespace Xcp {
namespace Interface {
namespace Ble {

static QString deviceAddr(const QBluetoothDeviceInfo & info)
{
#ifdef Q_OS_MAC
        return info.deviceUuid().toString();
#else
        return info.address().toString();
#endif
}

static QVariant saveFromInfo(const QBluetoothDeviceInfo & info)
{
    return QVariant(QStringList({deviceAddr(info), info.name()}));
}

static QBluetoothDeviceInfo infoFromSave(const QVariantList & save)
{
    if(save.size() != 2)
        return QBluetoothDeviceInfo();
    const QString & addr = save[0].toString();
    const QString & name = save[1].toString();
    if(addr.isEmpty())
        return QBluetoothDeviceInfo();
#ifdef Q_OS_MAC
    return QBluetoothDeviceInfo(QBluetoothUuid(addr), name, 0);
#else
    return QBluetoothDeviceInfo(QBluetoothAddress(addr), name, 0);
#endif
}

DeviceModel::DeviceModel(QObject *parent) :
    QAbstractListModel(parent),
    mUsingSaveList(true),
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
        return QString("%1 [%2]").arg(mDevices[index.row()].name()).arg(deviceAddr(mDevices[index.row()]));
    else if(role == Qt::UserRole)
        return deviceAddr(mDevices[index.row()]);
    else if(role == Qt::UserRole + 1)
        return mDevices[index.row()].name();

    return QVariant();
}

QHash<int, QByteArray> DeviceModel::roleNames() const
{
    const QHash<int, QByteArray> ROLE_NAMES = {{
        {Qt::DisplayRole, "display"},
        {Qt::UserRole, "addr"},
        {Qt::UserRole + 1, "name"}
    }};

    return ROLE_NAMES;
}

bool DeviceModel::isActive()
{
    return mAgent.isActive();
}

void DeviceModel::setSaveList(const QVariantList & list)
{
    if(!mUsingSaveList)
        return;

    mSaveList.clear();

    beginRemoveRows(QModelIndex(), 0, mDevices.size() - 1);
    mDevices.clear();
    endRemoveRows();

    QList<QBluetoothDeviceInfo> infoList;
    for(const QVariant & var : list)
    {
        QBluetoothDeviceInfo info = infoFromSave(var.toList());
        if(info.isValid())
        {
            infoList.append(info);
            mSaveList.append(var);
        }
    }
    emit saveListChanged();

    beginInsertRows(QModelIndex(), 0, infoList.size() - 1);
    for(const QBluetoothDeviceInfo & info : infoList)
        mDevices.append(info);
    endInsertRows();
}

QString DeviceModel::addr(int row)
{
    if(row < 0 || row >= mDevices.size())
        return QString();

    return deviceAddr(mDevices[row]);
}

QString DeviceModel::name(int row)
{
    if(row < 0 || row >= mDevices.size())
        return QString();
    return mDevices[row].name();
}

int DeviceModel::find(QString addr)
{
    static const QRegularExpression NOT_HEX("[^0-9a-f]");
    for(int i = 0; i < mDevices.size(); ++i)
        if(deviceAddr(mDevices[i]).toLower().replace(NOT_HEX, "") ==
                addr.toLower().replace(NOT_HEX, ""))
            return i;
    return -1;
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
        clearAll();
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
    mSaveList.clear();
    for(const QBluetoothDeviceInfo & info : mDevices)
        mSaveList.append(saveFromInfo(info));
    emit saveListChanged();
}

void DeviceModel::append(const QBluetoothDeviceInfo & info)
{
    mUsingSaveList = false;
    beginInsertRows(QModelIndex(), mDevices.size(), mDevices.size());
    mDevices.append(info);
    endInsertRows();
}

void DeviceModel::clearAll()
{
    mUsingSaveList = false;
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

    if(serviceUuids.contains(XCP_SERVICE_UUID))
        return true;
    if(serviceUuids.isEmpty() && completeness == QBluetoothDeviceInfo::DataUnavailable && !info.name().isEmpty())
        return true;
    return false;
}

} // namespace Ble
} // namespace Interface
} // namespace Xcp
} // namespace SetupTools
