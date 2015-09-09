#ifndef SETUPTOOLS_MODELLISTPROXY_H
#define SETUPTOOLS_MODELLISTPROXY_H

#include <QObject>
#include <QAbstractListModel>

namespace SetupTools {

class ModelListProxy : public QObject
{
    Q_OBJECT
    Q_PROPERTY(QAbstractItemModel *source MEMBER mSource WRITE setSource)
    Q_PROPERTY(QString roleName MEMBER mRoleName WRITE setRoleName)
    Q_PROPERTY(QVariantList list READ list NOTIFY listChanged)
    Q_PROPERTY(int coercedType MEMBER mCoercedType WRITE setCoercedType)
    Q_PROPERTY(int shape MEMBER mShape WRITE setShape)
    Q_ENUMS(Type)
    Q_ENUMS(Shape)
public:
    enum Type {
        Invalid = QMetaType::UnknownType,
        Bool = QMetaType::Bool,
        Int = QMetaType::Int,
        UInt = QMetaType::UInt,
        LongLong = QMetaType::LongLong,
        ULongLong = QMetaType::ULongLong,
        Double = QMetaType::Double,
        String = QMetaType::QString,
        ByteArray = QMetaType::QByteArray
    };

    enum Shape {
        ColumnVector = 0,
        RowVector,
        Matrix
    };

    explicit ModelListProxy(QObject *parent = 0);

    QVariantList list() const;
    void setSource(QAbstractItemModel *source);
    void setCoercedType(int type);
    void setRoleName(QString roleName);
    void setShape(int shape);
signals:
    listChanged();
public slots:
    void onSourceDataChanged(const QModelIndex &topLeft, const QModelIndex &bottomRight, const QVector<int> &roles);
    void onSourceLayoutChanged(const QList<QPersistentModelIndex> &parents, QAbstractItemModel::LayoutChangeHint hint);
private:
    QVariant coerceData(QVariant data);
    void createListData();
    void updateListData(int topRow, int leftColumn, int bottomRow, int rightColumn);
    void updateRole();

    QVariantList mList;
    QAbstractItemModel *mSource;
    QMetaObject::Connection mDataChangedConnection;
    QMetaObject::Connection mLayoutChangedConnection;
    int mCoercedType;
    int mShape;
    QString mRoleName;
    int mRole;
};

} // namespace SetupTools

#endif // SETUPTOOLS_MODELLISTPROXY_H
