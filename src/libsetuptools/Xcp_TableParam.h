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

    Q_PROPERTY(TableParamListModel *stringModel READ stringModel NOTIFY modelDataChanged)
    Q_PROPERTY(TableParamListModel *floatModel READ floatModel NOTIFY modelDataChanged)
    Q_PROPERTY(QString name MEMBER name)
    Q_PROPERTY(QString xLabel READ xLabel WRITE setXLabel NOTIFY xLabelChanged)
    Q_PROPERTY(QString yLabel READ yLabel WRITE setYLabel NOTIFY yLabelChanged)
    Q_PROPERTY(QString valueLabel READ valueLabel WRITE setValueLabel NOTIFY valueLabelChanged)
    Q_PROPERTY(QString xUnit READ xUnit NOTIFY xUnitChanged)
    Q_PROPERTY(QString yUnit READ yUnit NOTIFY yUnitChanged)
    Q_PROPERTY(QString valueUnit READ valueUnit NOTIFY valueUnitChanged)
public:
    TableParam(QObject *parent = nullptr);
    TableParam(TableMemoryRange *range, const Slot *slot, const TableAxis *axis, QObject *parent = nullptr);

    Q_INVOKABLE QString unit(int role);
    TableParamListModel *stringModel();
    TableParamListModel *floatModel();
    QString xLabel() const;
    void setXLabel(QString);
    QString yLabel() const;
    void setYLabel(QString);
    QString valueLabel() const;
    void setValueLabel(QString);
    QString xUnit() const;
    QString yUnit() const;
    QString valueUnit() const;
    const TableMemoryRange *range() const;
    const Slot *slot() const;
    const TableAxis *axis() const;

    virtual QVariant getSerializableValue();
    virtual bool setSerializableValue(const QVariant &val);
    virtual void resetCaches();

    QString name;
signals:
    void xLabelChanged();
    void yLabelChanged();
    void valueLabelChanged();
    void xUnitChanged();
    void yUnitChanged();
    void valueUnitChanged();
    void modelDataChanged();
public slots:
    void onAxisXUnitChanged();
    void onAxisYUnitChanged();
    void onSlotUnitChanged();
    void onRangeUploadDone(SetupTools::Xcp::OpResult result);
    void onRangeDownloadDone(SetupTools::Xcp::OpResult result);
    void onRangeDataChanged(quint32 beginChanged, quint32 endChanged);
    virtual void upload();
    virtual void download();
private:
    TableMemoryRange * const mRange;    // owned by the ParamRegistry
    const Slot * const mSlot;           // owned by QML
    const TableAxis * const mAxis;      // owned by QML
    TableParamListModel *mStringModel;  // owned by this
    TableParamListModel *mFloatModel;   // owned by this
    QString mXLabel, mYLabel, mValueLabel;
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
public slots:
    void onTableLabelChanged();
    void onValueParamChanged();
    void onRangeDataChanged(quint32 beginChanged, quint32 endChanged);
private:
    TableParam *mParam;
    bool mStringFormat;
};

} // namespace Xcp
} // namespace SetupTools

#endif // SETUPTOOLS_XCP_TABLEPARAM_H
