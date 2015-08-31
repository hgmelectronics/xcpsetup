#ifndef SETUPTOOLS_XCP_TABLEPARAM_H
#define SETUPTOOLS_XCP_TABLEPARAM_H

#include <QObject>
#include "Xcp_Param.h"
#include "Xcp_TableMemoryRange.h"
#include "LinearTableAxis.h"
#include "Slot.h"

namespace SetupTools {
namespace Xcp {

class TableParamListModel;

class TableParam : public SetupTools::Xcp::Param
{
    Q_OBJECT

    friend class TableParamListModel;

    Q_PROPERTY(TableParamListModel* stringModel READ stringModel NOTIFY modelDataChanged)
    Q_PROPERTY(TableParamListModel* floatModel READ floatModel NOTIFY modelDataChanged)
    Q_PROPERTY(int count READ count CONSTANT)
    Q_PROPERTY(TableMemoryRange* range READ range CONSTANT)
    Q_PROPERTY(TableAxis* axis READ axis CONSTANT)

public:
    TableParam(QObject *parent = nullptr);
    TableParam(TableMemoryRange* range, Slot* slot, TableAxis* axis, QObject *parent = nullptr);

    // gets the value in enginering units
    Q_INVOKABLE QVariant get(int row) const;

    // sets the value in engineering units
    Q_INVOKABLE bool set(int row, const QVariant& data) const;

    int count() const;

    TableParamListModel* stringModel() const
    {
        return mStringModel;
    }

    TableParamListModel* floatModel() const
    {
        return mFloatModel;
    }

    TableMemoryRange* range() const
    {
        return mRange;
    }

    TableAxis* axis() const
    {
        return mAxis;
    }

    virtual QVariant getSerializableValue(bool *allInRange = nullptr, bool *anyInRange = nullptr);
    virtual bool setSerializableValue(const QVariant &val);
    virtual void resetCaches();

signals:
    void modelDataChanged();

public slots:
    virtual void upload();
    virtual void download();

private slots:
    void onRangeUploadDone(SetupTools::Xcp::OpResult result);
    void onRangeDownloadDone(SetupTools::Xcp::OpResult result);
    void onRangeDataChanged(quint32 beginChanged, quint32 endChanged);
private:
    TableMemoryRange* const mRange;    // owned by the ParamRegistry
    TableAxis* const mAxis;      // owned by QML
    TableParamListModel* const mStringModel;  // owned by this
    TableParamListModel* const mFloatModel;   // owned by this
};


class TableParamListModel : public QAbstractListModel
{
    Q_OBJECT
public:
    TableParamListModel(bool stringFormat, TableParam *parent);

    virtual int rowCount(const QModelIndex & parent = QModelIndex()) const;
    virtual QVariant data(const QModelIndex &index, int role) const;
    virtual QVariant headerData(int section, Qt::Orientation orientation, int role) const;
    virtual bool setData(const QModelIndex &index, const QVariant &value, int role);
    virtual Qt::ItemFlags flags(const QModelIndex &index) const;
    virtual QHash<int, QByteArray> roleNames() const;

private:
    void onValueParamChanged();
    void onRangeDataChanged(quint32 beginChanged, quint32 endChanged);
    TableParam* const mParam;
    const bool mStringFormat;
    QHash<int, QByteArray> mRoleNames;
};

} // namespace Xcp
} // namespace SetupTools

#endif // SETUPTOOLS_XCP_TABLEPARAM_H
