#ifndef SETUPTOOLS_XCP_SCALARPARAM_H
#define SETUPTOOLS_XCP_SCALARPARAM_H

#include <QObject>
#include "Xcp_Param.h"
#include "Xcp_ScalarMemoryRange.h"
#include "Slot.h"

namespace SetupTools {

namespace Xcp {

class ScalarParam : public Param
{
    Q_OBJECT

    Q_PROPERTY(double floatVal READ floatVal WRITE setFloatVal NOTIFY valChanged)
    Q_PROPERTY(QString stringVal READ stringVal WRITE setStringVal NOTIFY valChanged)
    Q_PROPERTY(QString unit READ unit NOTIFY unitChanged)
    Q_PROPERTY(QString name MEMBER name)
    Q_PROPERTY(SetupTools::Slot *slot READ slot NOTIFY neverChanges)
public:
    ScalarParam(QObject *parent = nullptr);
    ScalarParam(ScalarMemoryRange *range, Slot *slot, QObject *parent = nullptr);
    double floatVal() const;
    QString stringVal() const;
    void setFloatVal(double);
    void setStringVal(QString);
    QString unit() const;
    const ScalarMemoryRange *range() const;
    const SetupTools::Slot *slot() const;
    SetupTools::Slot *slot();
    virtual QVariant getSerializableValue(bool *allInRange = nullptr, bool *anyInRange = nullptr);
    virtual bool setSerializableValue(const QVariant &val);
    virtual void resetCaches();

    QString name;
signals:
    void valChanged();
    void unitChanged();
    void neverChanges();
public slots:
    void onRangeValChanged();
    void onRangeUploadDone(SetupTools::Xcp::OpResult result);
    void onRangeDownloadDone(SetupTools::Xcp::OpResult result);
    void onSlotUnitChanged();
    void onSlotValueParamChanged();
    virtual void upload();
    virtual void download();
private:
    ScalarMemoryRange * const mRange;   // owned by the ParamRegistry
    Slot * const mSlot;                 // owned by QML
};

} // namespace Xcp

} // namespace SetupTools

#endif // SETUPTOOLS_XCP_SCALARPARAM_H
