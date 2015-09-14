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
    Q_PROPERTY(ScalarMemoryRange* range READ range CONSTANT)

public:
    ScalarParam(QObject *parent = nullptr);
    ScalarParam(ScalarMemoryRange *range, Slot *slot, QObject *parent = nullptr);

    double floatVal() const;
    void setFloatVal(double);

    QString stringVal() const;
    void setStringVal(QString);

    ScalarMemoryRange* range() const;

    virtual QVariant getSerializableValue(bool *allInRange = nullptr, bool *anyInRange = nullptr);
    virtual bool setSerializableValue(const QVariant &val);
    virtual QVariant getSerializableRawValue(bool *allInRange = nullptr, bool *anyInRange = nullptr);
    virtual bool setSerializableRawValue(const QVariant &val);

signals:
    void valChanged();

public slots:
    virtual void upload();
    virtual void download();

private:
    void onRangeValChanged();
    void onRangeUploadDone(SetupTools::Xcp::OpResult result);
    void onRangeDownloadDone(SetupTools::Xcp::OpResult result);
    void onSlotValueParamChanged();
    ScalarMemoryRange * const mRange;   // owned by the ParamRegistry
};

} // namespace Xcp

} // namespace SetupTools

#endif // SETUPTOOLS_XCP_SCALARPARAM_H
