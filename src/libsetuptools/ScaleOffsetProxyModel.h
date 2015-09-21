#ifndef SETUPTOOLS_SCALEOFFSETPROXYMODEL_H
#define SETUPTOOLS_SCALEOFFSETPROXYMODEL_H

#include <QObject>
#include <QAbstractProxyModel>
#include <QSet>
#include "Slot.h"

namespace SetupTools {

class ScaleOffsetProxyModel : public QAbstractProxyModel
{
    Q_OBJECT
    Q_PROPERTY(double scale MEMBER mScale WRITE setScale NOTIFY scaleChanged)
    Q_PROPERTY(double offset MEMBER mOffset WRITE setOffset NOTIFY offsetChanged)
    Q_PROPERTY(bool targetAllRoles MEMBER mTargetAllRoles WRITE setTargetAllRoles NOTIFY targetAllRolesChanged)
    Q_PROPERTY(QStringList targetRoleNames READ targetRoleNames WRITE setTargetRoleNames NOTIFY targetRoleNamesChanged)
    Q_PROPERTY(Slot *formatSlot MEMBER mFormatSlot WRITE setFormatSlot NOTIFY formatSlotChanged)
public:
    explicit ScaleOffsetProxyModel(QObject *parent = 0);

    void setScale(double);
    void setOffset(double);
    void setTargetAllRoles(bool);
    QStringList targetRoleNames() const;
    void setTargetRoleNames(QStringList);
    void setFormatSlot(Slot *formatSlot);

    virtual QModelIndex mapFromSource(const QModelIndex &sourceIndex) const;
    virtual QModelIndex mapToSource(const QModelIndex &proxyIndex) const;
    virtual int rowCount(const QModelIndex &parent = QModelIndex()) const;
    virtual int columnCount(const QModelIndex &parent = QModelIndex()) const;
    virtual QModelIndex parent(const QModelIndex &child = QModelIndex()) const;
    virtual QModelIndex index(int row, int column, const QModelIndex &parent = QModelIndex()) const;
    QVariant data(const QModelIndex &proxyIndex, int role) const;
    bool setData(const QModelIndex &index, const QVariant &value, int role);
signals:
    void scaleChanged();
    void offsetChanged();
    void targetRoleNamesChanged();
    void targetAllRolesChanged();
    void formatSlotChanged();
public slots:
    void onSourceModelChanged();
    void onSourceDataChanged(const QModelIndex &topLeft, const QModelIndex &bottomRight, const QVector<int> &roles);
private:
    void updateTargetRoles();

    QMetaObject::Connection mDataChangedConnection;
    double mScale;
    double mOffset;
    bool mTargetAllRoles;
    QStringList mTargetRoleNames;
    Slot *mFormatSlot;
    QSet<int> mTargetRoles;
    QHash<QString, int> mSourceRoleNumbers;
};

} // namespace SetupTools

#endif // SETUPTOOLS_SCALEOFFSETPROXYMODEL_H
