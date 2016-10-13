#ifndef SETUPTOOLS_ARRAYPARAM_H
#define SETUPTOOLS_ARRAYPARAM_H

#include <QObject>
#include <QAbstractListModel>
#include <boost/dynamic_bitset.hpp>
#include "Param.h"

namespace SetupTools {

class ParamRegistry;
class ArrayParamModel;

class ArrayParam : public Param
{
    Q_OBJECT

    friend class ArrayParamModel;

    Q_PROPERTY(ArrayParamModel* stringModel READ stringModel NOTIFY modelChanged)
    Q_PROPERTY(ArrayParamModel* floatModel READ floatModel NOTIFY modelChanged)
    Q_PROPERTY(ArrayParamModel* rawModel READ rawModel NOTIFY modelChanged)
    Q_PROPERTY(int count READ count NOTIFY countChanged)
    Q_PROPERTY(int minCount READ minCount WRITE setMinCount NOTIFY minCountChanged)
    Q_PROPERTY(int maxCount READ maxCount WRITE setMaxCount NOTIFY maxCountChanged)

public:
    explicit ArrayParam(Param *parent = 0);
    virtual ~ArrayParam() = default;

    // gets the value in enginering units
    Q_INVOKABLE QVariant get(int row) const;

    // sets the value in engineering units
    Q_INVOKABLE bool set(int row, const QVariant& value);

    ArrayParamModel *stringModel() const
    {
        return mStringModel;
    }

    ArrayParamModel *floatModel() const
    {
        return mFloatModel;
    }

    ArrayParamModel *rawModel() const
    {
        return mRawModel;
    }

    virtual QVariant getSerializableValue(bool *allInRange = nullptr, bool *anyInRange = nullptr);
    virtual bool setSerializableValue(const QVariant &val);
    virtual QVariant getSerializableRawValue(bool *allInRange = nullptr, bool *anyInRange = nullptr);
    virtual bool setSerializableRawValue(const QVariant &val);

    int count() const
    {
        return std::max(mActualDim, minCount());
    }

    int minCount() const
    {
        if(mMinCount > 0 && (mMinCount <= mMaxCount || mMaxCount == 0))
            return mMinCount;
        else if(mMaxCount > 0)
            return mMaxCount;
        else
            return 0;
    }


    int maxCount() const
    {
        if(mMaxCount > 0)
            return mMaxCount;
        else if(mMinCount > 0)
            return mMinCount;
        else
            return 0;
    }

    void setMinCount(int val);
    void setMaxCount(int val);
    virtual quint32 minSize() override;
    virtual quint32 maxSize() override;
    virtual quint32 size() override;

signals:
    void modelChanged();
    void countChanged();
    void modelDataChanged(quint32 begin, quint32 end);
    void minCountChanged();
    void maxCountChanged();

public slots:
    void onValidChanged();

private:
    virtual void updateEngrFromRaw(quint32 begin, quint32 end);
    QVariant rawVal(int row) const;
    bool setRawVal(int row, const QVariant & val);

    int mActualDim;
    int mMinCount, mMaxCount;
    ArrayParamModel * const mStringModel;  // owned by this
    ArrayParamModel * const mFloatModel;   // owned by this
    ArrayParamModel * const mRawModel;   // owned by this
};

class ArrayParamModel : public QAbstractListModel
{
    Q_OBJECT
    Q_PROPERTY(int count READ count NOTIFY countChanged)
public:
    ArrayParamModel(bool stringFormat, bool raw, ArrayParam * parent);

    int count() const;
    virtual int rowCount(const QModelIndex & parent = QModelIndex()) const;
    virtual QVariant data(const QModelIndex &index, int role) const;
    virtual bool setData(const QModelIndex &index, const QVariant &value, int role);
    virtual Qt::ItemFlags flags(const QModelIndex &index) const;
signals:
    void countChanged();
private slots:
    void onValueParamChanged();
    void onParamDataChanged(quint32 beginChanged, quint32 endChanged);
    void onParamCountChanged();
    void onParamSlotChanged();
private:
    ArrayParam * const mParam;
    int mPrevCount;
    const bool mStringFormat;
    const bool mRaw;
    Slot * mConnectedSlot;
};

} // namespace SetupTools

#endif // SETUPTOOLS_ARRAYPARAM_H
