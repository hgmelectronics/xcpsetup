#ifndef SETUPTOOLS_MODELSTRINGPROXY_H
#define SETUPTOOLS_MODELSTRINGPROXY_H

#include <QObject>
#include <QAbstractListModel>

namespace SetupTools {

class ModelStringProxy : public QObject
{
    Q_OBJECT
    Q_PROPERTY(QAbstractItemModel *source MEMBER mSource WRITE setSource)
    Q_PROPERTY(QString roleName MEMBER mRoleName WRITE setRoleName)
    Q_PROPERTY(QString string READ string NOTIFY stringChanged)
    Q_PROPERTY(int packing MEMBER mPacking WRITE setPacking)
    Q_ENUMS(Packing)
public:
    enum Packing {
        Char = 0,
        BigEndian16 = 1,
        LittleEndian16 = 2,
        BigEndian32 = 3,
        LittleEndian32 = 4,
        COUNT = 5
    };
    explicit ModelStringProxy(QObject *parent = 0);

    QString string() const;
    void setSource(QAbstractItemModel *source);
    void setRoleName(QString roleName);
    void setPacking(int packing);
signals:
    void stringChanged();
public slots:
    void onSourceDataChanged(const QModelIndex &topLeft, const QModelIndex &bottomRight, const QVector<int> &roles);
    void onSourceRowsColsAddedRemoved(const QModelIndex &parent, int first, int last);
private:
    void createStringData();
    void updateRole();

    QString mString;
    QAbstractItemModel *mSource;
    QMetaObject::Connection mDataChangedConnection;
    QMetaObject::Connection mRowsInsertedConnection, mRowsRemovedConnection;
    QMetaObject::Connection mColsInsertedConnection, mColsRemovedConnection;
    QString mRoleName;
    int mRole;
    int mPacking;
};

} // namespace SetupTools

#endif // SETUPTOOLS_MODELSTRINGPROXY_H
