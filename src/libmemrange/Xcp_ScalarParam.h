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
    Q_PROPERTY(QString unit READ unit)
    Q_PROPERTY(QString name MEMBER name)
public:
    ScalarParam(ScalarMemoryRange *range, const Slot *slot, QObject *parent = nullptr);
    double floatVal() const;
    QString stringVal() const;
    void setFloatVal(double);
    void setStringVal(QString);
    QString unit() const;
    const ScalarMemoryRange *range() const;
    virtual QVariant getSerializableValue();
    virtual bool setSerializableValue(const QVariant &val);
    virtual void resetCaches();

    QString name;
signals:
    void valChanged();
public slots:
    void onRangeValChanged();
    void onRangeUploadDone(SetupTools::Xcp::OpResult result);
    void onRangeDownloadDone(SetupTools::Xcp::OpResult result);
    virtual void upload();
    virtual void download();
private:
    ScalarMemoryRange * const mRange;   // owned by the ParamRegistry
    const Slot * const mSlot;           // owned by QML
};

} // namespace Xcp

} // namespace SetupTools

#endif // SETUPTOOLS_XCP_SCALARPARAM_H
