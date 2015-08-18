#ifndef SETUPTOOLS_LINEARTABLEAXIS_H
#define SETUPTOOLS_LINEARTABLEAXIS_H

#include <QObject>
#include <QAbstractListModel>
#include "TableAxis.h"

namespace SetupTools {

class LinearTableAxis : public TableAxis
{
    Q_OBJECT

    Q_PROPERTY(float min READ min WRITE setMin NOTIFY dimChanged)
    Q_PROPERTY(float max READ max WRITE setMax NOTIFY dimChanged)
    Q_PROPERTY(float step READ step NOTIFY dimChanged)
    Q_PROPERTY(int size READ size WRITE setSize NOTIFY dimChanged)
public:
    explicit LinearTableAxis(QObject *parent = 0);
    float min() const;
    void setMin(float);
    float max() const;
    void setMax(float);
    float step() const;
    int size() const;
    void setSize(int size);
    virtual int rowCount(const QModelIndex & parent = QModelIndex()) const;
    virtual QVariant data(const QModelIndex &index, int role = TableAxisRole::XRole) const;
    virtual QHash<int, QByteArray> roleNames() const;
signals:
    void dimChanged();
private:
    float mMin;
    float mMax;
    int mSize;
};

} // namespace SetupTools

#endif // SETUPTOOLS_LINEARTABLEAXIS_H
