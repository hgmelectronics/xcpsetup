#ifndef SETUPTOOLS_LINEARTABLEAXIS_H
#define SETUPTOOLS_LINEARTABLEAXIS_H

#include <QObject>
#include <QAbstractListModel>

namespace SetupTools {

class LinearTableAxis : public QAbstractListModel
{
    Q_OBJECT

    Q_PROPERTY(float min READ min WRITE setMin NOTIFY dimChanged)
    Q_PROPERTY(float max READ max WRITE setMax NOTIFY dimChanged)
    Q_PROPERTY(float step READ step NOTIFY dimChanged)
    Q_PROPERTY(int size READ size WRITE setSize NOTIFY dimChanged)
    Q_PROPERTY(QString unit MEMBER mUnit)
    Q_PROPERTY(QString label MEMBER mLabel)
public:
    explicit LinearTableAxis(QObject *parent = 0);
    float min() const;
    void setMin(float);
    float max() const;
    void setMax(float);
    float step() const;
    int size() const;
    void setSize(int size);
    virtual int rowCount() const;
    virtual QVariant data(const QModelIndex &index, int role = Qt::DisplayRole) const;
signals:
    void dimChanged();
private:
    float mMin;
    float mMax;
    int mSize;
    QString mUnit;
    QString mLabel;
};

} // namespace SetupTools

#endif // SETUPTOOLS_LINEARTABLEAXIS_H
