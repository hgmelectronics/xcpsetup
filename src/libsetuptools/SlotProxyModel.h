#ifndef SETUPTOOLS_SLOTPROXYMODEL_H
#define SETUPTOOLS_SLOTPROXYMODEL_H

#include <QObject>
#include <QAbstractProxyModel>
#include <QSet>
#include "Slot.h"

namespace SetupTools {

class SlotProxyModel : public QAbstractProxyModel
{
    Q_OBJECT
    Q_PROPERTY(bool stringFormat MEMBER mStringFormat WRITE setStringFormat NOTIFY stringFormatChanged)
    Q_PROPERTY(bool targetAllRoles MEMBER mTargetAllRoles WRITE setTargetAllRoles NOTIFY targetAllRolesChanged)
    Q_PROPERTY(QStringList targetRoleNames READ targetRoleNames WRITE setTargetRoleNames NOTIFY targetRoleNamesChanged)
    Q_PROPERTY(Slot *slot MEMBER mSlot WRITE setSlot NOTIFY slotChanged)
public:
    explicit SlotProxyModel(QObject *parent = 0);

    void setTargetAllRoles(bool);
    QStringList targetRoleNames() const;
    void setTargetRoleNames(QStringList);
    void setStringFormat(bool);
    void setSlot(Slot *formatSlot);

    virtual QModelIndex mapFromSource(const QModelIndex &sourceIndex) const;
    virtual QModelIndex mapToSource(const QModelIndex &proxyIndex) const;
    virtual int rowCount(const QModelIndex &parent = QModelIndex()) const;
    virtual int columnCount(const QModelIndex &parent = QModelIndex()) const;
    virtual QModelIndex parent(const QModelIndex &child = QModelIndex()) const;
    virtual QModelIndex index(int row, int column, const QModelIndex &parent = QModelIndex()) const;
    QVariant data(const QModelIndex &proxyIndex, int role) const;
    bool setData(const QModelIndex &index, const QVariant &value, int role);
signals:
    void targetRoleNamesChanged();
    void targetAllRolesChanged();
    void slotChanged();
    void stringFormatChanged();
public slots:
    void onSourceModelChanged();
    void onSourceDataChanged(const QModelIndex &topLeft, const QModelIndex &bottomRight, const QVector<int> &roles);
    void onSourceColumnsAboutToBeInserted(const QModelIndex &parent, int first, int last);
    void onSourceColumnsAboutToBeRemoved(const QModelIndex &parent, int first, int last);
    void onSourceColumnsInserted(const QModelIndex &parent, int first, int last);
    void onSourceColumnsRemoved(const QModelIndex &parent, int first, int last);
    void onSourceRowsAboutToBeInserted(const QModelIndex &parent, int first, int last);
    void onSourceRowsAboutToBeRemoved(const QModelIndex &parent, int first, int last);
    void onSourceRowsInserted(const QModelIndex &parent, int first, int last);
    void onSourceRowsRemoved(const QModelIndex &parent, int first, int last);
private:
    void updateTargetRoles();

    QMetaObject::Connection mDataChangedConnection;
    QMetaObject::Connection mColumnsAboutToBeInsertedConnection;
    QMetaObject::Connection mColumnsAboutToBeRemovedConnection;
    QMetaObject::Connection mColumnsInsertedConnection;
    QMetaObject::Connection mColumnsRemovedConnection;
    QMetaObject::Connection mRowsAboutToBeInsertedConnection;
    QMetaObject::Connection mRowsAboutToBeRemovedConnection;
    QMetaObject::Connection mRowsInsertedConnection;
    QMetaObject::Connection mRowsRemovedConnection;
    bool mTargetAllRoles;
    QStringList mTargetRoleNames;
    Slot *mSlot;
    bool mStringFormat;
    QSet<int> mTargetRoles;
    QHash<QString, int> mSourceRoleNumbers;
};

} // namespace SetupTools

#endif // SETUPTOOLS_SLOTPROXYMODEL_H
