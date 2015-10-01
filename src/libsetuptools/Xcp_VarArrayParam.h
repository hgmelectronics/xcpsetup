#ifndef SETUPTOOLS_XCP_VARARRAYPARAM_H
#define SETUPTOOLS_XCP_VARARRAYPARAM_H

#include <QObject>
#include "Xcp_Param.h"
#include "Xcp_ArrayMemoryRange.h"
#include "Xcp_ScalarMemoryRange.h"
#include "Slot.h"

namespace SetupTools {
namespace Xcp {

class VarArrayParamModel;

class VarArrayParam : public SetupTools::Xcp::Param
{
    Q_OBJECT

    friend class VarArrayParamModel;

    Q_PROPERTY(VarArrayParamModel* stringModel READ stringModel NOTIFY modelChanged)
    Q_PROPERTY(VarArrayParamModel* floatModel READ floatModel NOTIFY modelChanged)
    Q_PROPERTY(VarArrayParamModel* rawModel READ rawModel NOTIFY modelChanged)
    Q_PROPERTY(int count READ count NOTIFY countChanged)
    Q_PROPERTY(int minCount READ minCount CONSTANT)
    Q_PROPERTY(int maxCount READ maxCount CONSTANT)
    Q_PROPERTY(ArrayMemoryRange *range READ range CONSTANT)
    Q_PROPERTY(QList<ScalarMemoryRange *> extRanges READ extRanges CONSTANT)

public:
    VarArrayParam(QObject *parent = nullptr);
    VarArrayParam(ArrayMemoryRange *range, QList<ScalarMemoryRange *> extRanges, Slot *slot, QObject *parent = nullptr);

    // gets the value in enginering units
    Q_INVOKABLE QVariant get(int row) const;

    // sets the value in engineering units
    Q_INVOKABLE bool set(int row, const QVariant& value) const;

    int count() const;

    int minCount() const;

    int maxCount() const;

    VarArrayParamModel *stringModel() const
    {
        return mStringModel;
    }

    VarArrayParamModel *floatModel() const
    {
        return mFloatModel;
    }

    VarArrayParamModel *rawModel() const
    {
        return mRawModel;
    }

    ArrayMemoryRange *range()
    {
        return mRange;
    }

    QList<ScalarMemoryRange *> extRanges()
    {
        return mExtRanges;
    }

    virtual QVariant getSerializableValue(bool *allInRange = nullptr, bool *anyInRange = nullptr);
    virtual bool setSerializableValue(const QVariant &val);
    virtual QVariant getSerializableRawValue(bool *allInRange = nullptr, bool *anyInRange = nullptr);
    virtual bool setSerializableRawValue(const QVariant &val);

signals:
    void modelChanged();
    void countChanged();
    void modelDataChanged(quint32 begin, quint32 end);

public slots:
    virtual void upload();
    virtual void download();

private slots:
    void onCachesReset();
    void onRangeUploadDone(SetupTools::Xcp::OpResult result);
    void onRangeDownloadDone(SetupTools::Xcp::OpResult result);
    void onRangeDataChanged(quint32 beginChanged, quint32 endChanged);
    void onExtRangeUploadDone(SetupTools::Xcp::OpResult result);
    void onExtRangeDownloadDone(SetupTools::Xcp::OpResult result);
    void onExtRangeValueChanged(int index);
private:
    ArrayMemoryRange *mRange;   // owned by the ParamRegistry
    QList<ScalarMemoryRange *> const mExtRanges;    // owned by the ParamRegistry
    QSignalMapper mExtRangeChangedMapper;
    boost::optional<int> mActualDim;
    boost::optional<int> mExtRangeUploadIdx, mExtRangeDownloadIdx;
    bool mUploadingRange;
    VarArrayParamModel * const mStringModel;  // owned by this
    VarArrayParamModel * const mFloatModel;   // owned by this
    VarArrayParamModel * const mRawModel;   // owned by this
};


class VarArrayParamModel : public QAbstractListModel
{
    Q_OBJECT
public:
    VarArrayParamModel(bool stringFormat, bool raw, VarArrayParam *parent);

    virtual int rowCount(const QModelIndex & parent = QModelIndex()) const;
    virtual QVariant data(const QModelIndex &index, int role) const;
    virtual bool setData(const QModelIndex &index, const QVariant &value, int role);
    virtual Qt::ItemFlags flags(const QModelIndex &index) const;

private:
    void onValueParamChanged();
    void onParamDataChanged(quint32 beginChanged, quint32 endChanged);
    void onParamCountChanged();
private:
    VarArrayParam * const mParam;
    int mPrevCount;
    const bool mStringFormat;
    const bool mRaw;
};

} // namespace Xcp
} // namespace SetupTools

#endif // SETUPTOOLS_XCP_VARARRAYPARAM_H
