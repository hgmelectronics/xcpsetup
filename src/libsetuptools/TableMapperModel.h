#ifndef SETUPTOOLS_TABLEMAPPERMODEL_H
#define SETUPTOOLS_TABLEMAPPERMODEL_H

#include <QObject>
#include <QAbstractItemModel>

namespace SetupTools {

class TableMapperModel : public QAbstractItemModel
{
    Q_OBJECT

    /**
      * @brief QVariant form of a QMap<QString, QAbstractItemModel *>, where the key is a role name.
      * Normally the QAbstractItemModel will be an Xcp::ArrayParam, but this is not required.
      *
      * ArrayParams are overlaid to form the final model, which is M rows by N columns,
      * where M is the maximum number of rows of any ArrayParam and N is the maximum
      * number of columns. The final model contains all the roles defined in mapping,
      * and passes through the arrays' ORed flags.
      *
      * Permissible sizes for ArrayParams are MxN, Mx1, and 1xN. ArrayParams with a singleton
      * dimension less than the final model (e.g. an independent variable in a 2D table) are
      * duplicated across the corresponding dimension of the final model. ArrayParams with
      * 1 < rows < M or 1 < columns < N will produce an assertion failure.
      *
      * Create a 1D table (most common use case) by passing in a number of Mx1 arrays.
      * Create a 2D table by passing in an Mx1 row-wise independent variable, a 1xN column-wise
      * independent variable (may be created by using TransposeProxyModel), and an MxN dependent
      * variable.
      */
    Q_PROPERTY(QVariantMap mapping READ mapping WRITE setMapping NOTIFY mappingChanged)
public:
    explicit TableMapperModel(QObject *parent = 0);

    QVariantMap mapping() const
    {
        return mMapping;
    }
    void setMapping(const QVariantMap &mapping);

    virtual int rowCount(const QModelIndex & parent = QModelIndex()) const;
    virtual int columnCount(const QModelIndex & parent = QModelIndex()) const;
    virtual QVariant data(const QModelIndex &index, int role) const;
    virtual QVariant headerData(int section, Qt::Orientation orientation, int role) const;
    virtual bool setData(const QModelIndex &index, const QVariant &value, int role);
    virtual Qt::ItemFlags flags(const QModelIndex &index) const;
    virtual QHash<int, QByteArray> roleNames() const;
    virtual QModelIndex parent(const QModelIndex &child) const;
    virtual QModelIndex index(int row, int column, const QModelIndex &parent = QModelIndex()) const;

signals:
    void mappingChanged();

public slots:
    void onMappedDataChanged(const QModelIndex &topLeft, const QModelIndex &bottomRight, const QVector<int> &roles = QVector<int>());
    void onSubmodelRowsColsAddedRemoved(const QModelIndex & parent, int first, int last);   // one slot for all since we ignore the params

private:
    bool isValidRole(int role) const;
    bool isValidIndex(const QModelIndex &index) const;
    QModelIndex subModelIndex(int subModelNum, const QModelIndex &index) const;
    QModelIndex subModelIndex(QAbstractItemModel *subModel, const QModelIndex &index) const;
    bool tryUpdateMapping();

    QVariantMap mMapping;
    QList<QAbstractItemModel *> mSubModels;
    QHash<int, QByteArray> mRoleNames;
    int mRowCount;
    int mColumnCount;
};

} // namespace SetupTools

#endif // SETUPTOOLS_TABLEMAPPERMODEL_H
