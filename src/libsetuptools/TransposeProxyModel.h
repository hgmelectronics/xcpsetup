#ifndef SETUPTOOLS_TRANSPOSEPROXYMODEL_H
#define SETUPTOOLS_TRANSPOSEPROXYMODEL_H

#include <QObject>
#include <QAbstractProxyModel>

namespace SetupTools {

class TransposeProxyModel : public QAbstractProxyModel
{
    Q_OBJECT
public:
    explicit TransposeProxyModel(QObject *parent = 0);
    virtual QModelIndex mapFromSource(const QModelIndex &sourceIndex) const;
    virtual QModelIndex mapToSource(const QModelIndex &proxyIndex) const;
    virtual int rowCount(const QModelIndex &parent = QModelIndex()) const;
    virtual int columnCount(const QModelIndex &parent = QModelIndex()) const;
    virtual QModelIndex parent(const QModelIndex &child = QModelIndex()) const;
    virtual QModelIndex index(int row, int column, const QModelIndex &parent = QModelIndex()) const;
signals:
public slots:
    void onSourceModelChanged();
    void onSourceDataChanged(const QModelIndex &topLeft, const QModelIndex &bottomRight, const QVector<int> &roles);
private:
    QMetaObject::Connection mDataChangedConnection;
};

} // namespace SetupTools

#endif // SETUPTOOLS_TRANSPOSEPROXYMODEL_H
