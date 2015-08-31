#ifndef SETUPTOOLS_XCP_TABLEPARAMMODEL_H
#define SETUPTOOLS_XCP_TABLEPARAMMODEL_H

#include <QObject>
#include <QString>
#include <QAbstractListModel>
#include <QVariantMap>
#include <QHash>
#include <QList>
#include <QByteArray>


namespace SetupTools {
namespace Xcp {

class TableParam;

class TableParamMapper: public QAbstractListModel
{
    Q_OBJECT
    Q_PROPERTY(QVariantMap mapping READ mapping WRITE setMapping NOTIFY mappingChanged)
    Q_PROPERTY(bool stringFormat READ stringFormat WRITE setStringFormat NOTIFY stringFormatChanged)
public:
    TableParamMapper(QObject* parent = nullptr);

    virtual int rowCount(const QModelIndex & parent = QModelIndex()) const;
    virtual QVariant data(const QModelIndex &index, int role) const;
    virtual QVariant headerData(int section, Qt::Orientation orientation, int role) const;
    virtual bool setData(const QModelIndex &index, const QVariant &value, int role);
    virtual Qt::ItemFlags flags(const QModelIndex &index) const;
    virtual QHash<int, QByteArray> roleNames() const;

    QVariantMap mapping() const
    {
        return mMapping;
    }

    void setMapping(const QVariantMap& mapping);


    bool stringFormat() const
    {
        return mStringFormat;
    }

    void setStringFormat(bool format);

signals:
    void stringFormatChanged();
    void mappingChanged();

private:
    void onValueParamChanged();
    void onRangeDataChanged(quint32 beginChanged, quint32 endChanged);

    bool isValidRole(int role) const;
    bool isValidIndexAndRole(const QModelIndex &index, int role) const;

    bool mStringFormat;
    QVariantMap mMapping;
    QList<TableParam*> mParamEntries;
    QHash<int, QByteArray> mRoleNames;
    int mRowCount;
};
}
}
#endif // SETUPTOOLS_XCP_TABLEPARAMMODEL_H
