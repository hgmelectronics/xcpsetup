#ifndef SETUPTOOLS_XCP_INTERFACE_BLE_DEVICEDISCOVERER_H
#define SETUPTOOLS_XCP_INTERFACE_BLE_DEVICEDISCOVERER_H

#include <QObject>
#include <QBluetoothDeviceDiscoveryAgent>
#include <QAbstractListModel>

namespace SetupTools {
namespace Xcp {
namespace Interface {
namespace Ble {

class DeviceModel : public QAbstractListModel
{
    Q_OBJECT
    Q_PROPERTY(bool isActive READ isActive NOTIFY isActiveChanged)
    Q_PROPERTY(QVariantList saveList READ saveList WRITE setSaveList NOTIFY saveListChanged)
public:
    explicit DeviceModel(QObject *parent = 0);

    int rowCount(const QModelIndex &parent) const override;
    QVariant data(const QModelIndex &index, int role) const override;
    QHash<int, QByteArray> roleNames() const override;
    bool isActive();
    const QVariantList & saveList() const
    {
        return mSaveList;
    }
    void setSaveList(const QVariantList & list);

    Q_INVOKABLE QString addr(int row);
    Q_INVOKABLE QString name(int row);
    Q_INVOKABLE int find(QString addr);
signals:
    void isActiveChanged();
    void error(QString error);
    void saveListChanged();
public slots:
    void start();
    void stop();

    void onAgentCanceled();
    void onAgentDeviceDiscovered(const QBluetoothDeviceInfo & info);
    void onAgentError(QBluetoothDeviceDiscoveryAgent::Error error);
    void onAgentFinished();
private:
    void append(const QBluetoothDeviceInfo & info);
    void clearAll();
    bool isPossibleSlave(const QBluetoothDeviceInfo & info);

    bool mUsingSaveList;    // if true, setSaveList also writes to mDevices. set to false as soon as first scan for devices begins.
    QBluetoothDeviceDiscoveryAgent mAgent;
    bool mRestartQueued;
    QList<QBluetoothDeviceInfo> mDevices;
    QVariantList mSaveList;
};

} // namespace Ble
} // namespace Interface
} // namespace Xcp
} // namespace SetupTools

#endif // SETUPTOOLS_XCP_INTERFACE_BLE_DEVICEDISCOVERER_H
