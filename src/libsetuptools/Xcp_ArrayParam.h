#ifndef SETUPTOOLS_XCP_ARRAYPARAM_H
#define SETUPTOOLS_XCP_ARRAYPARAM_H

#include <QObject>
#include "Xcp_Param.h"
#include "Xcp_ArrayMemoryRange.h"
#include "Slot.h"

namespace SetupTools {
namespace Xcp {

class ArrayParamModel;
class ParamRegistry;

class ArrayParam : public SetupTools::Xcp::Param
{
    Q_OBJECT

    friend class ArrayParamModel;

    Q_PROPERTY(ArrayParamModel* stringModel READ stringModel NOTIFY modelChanged)
    Q_PROPERTY(ArrayParamModel* floatModel READ floatModel NOTIFY modelChanged)
    Q_PROPERTY(ArrayParamModel* rawModel READ rawModel NOTIFY modelChanged)
    Q_PROPERTY(int count READ count CONSTANT)
    Q_PROPERTY(ArrayMemoryRange* range READ range CONSTANT)

public:
    ArrayParam(QObject *parent = nullptr);
    ArrayParam(ArrayMemoryRange* range, Slot* slot, ParamRegistry *parent);

    // gets the value in enginering units
    Q_INVOKABLE QVariant get(int row) const;

    // sets the value in engineering units
    Q_INVOKABLE bool set(int row, const QVariant& value);

    int count() const;

    ArrayParamModel* stringModel() const
    {
        return mStringModel;
    }

    ArrayParamModel* floatModel() const
    {
        return mFloatModel;
    }

    ArrayParamModel* rawModel() const
    {
        return mRawModel;
    }

    ArrayMemoryRange* range() const
    {
        return mRange;
    }

    virtual QVariant getSerializableValue(bool *allInRange = nullptr, bool *anyInRange = nullptr);
    virtual bool setSerializableValue(const QVariant &val);
    virtual QVariant getSerializableRawValue(bool *allInRange = nullptr, bool *anyInRange = nullptr);
    virtual bool setSerializableRawValue(const QVariant &val);

signals:
    void modelChanged();

public slots:
    virtual void upload();
    virtual void download();

private slots:
    void onRangeUploadDone(SetupTools::OpResult result);
    void onRangeDownloadDone(SetupTools::OpResult result);
    void onRangeDataChanged(quint32 beginChanged, quint32 endChanged);
private:
    ArrayMemoryRange* const mRange;    // owned by the ParamRegistry
    ArrayParamModel* const mStringModel;  // owned by this
    ArrayParamModel* const mFloatModel;   // owned by this
    ArrayParamModel* const mRawModel;   // owned by this
};


class ArrayParamModel : public QAbstractListModel
{
    Q_OBJECT
    Q_PROPERTY(int count READ count CONSTANT)
public:
    ArrayParamModel(bool stringFormat, bool raw, ArrayParam *parent);

    Q_INVOKABLE QVariant get(int row) const;
    Q_INVOKABLE bool set(int row, const QVariant& value);

    int count() const;
    virtual int rowCount(const QModelIndex & parent = QModelIndex()) const;
    virtual QVariant data(const QModelIndex &index, int role) const;
    virtual bool setData(const QModelIndex &index, const QVariant &value, int role);
    virtual Qt::ItemFlags flags(const QModelIndex &index) const;

private slots:
    void onValueParamChanged();
    void onRangeDataChanged(quint32 beginChanged, quint32 endChanged);
private:
    ArrayParam* const mParam;
    const bool mStringFormat;
    const bool mRaw;
};

} // namespace Xcp
} // namespace SetupTools

#endif // SETUPTOOLS_XCP_TABLEPARAM_H
