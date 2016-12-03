#ifndef SETUPTOOLS_SCALARPARAM_H
#define SETUPTOOLS_SCALARPARAM_H

#include "Param.h"

namespace SetupTools {

class ScalarParam : public Param
{
    Q_OBJECT

    Q_PROPERTY(double floatVal READ floatVal WRITE setFloatVal NOTIFY valChanged)
    Q_PROPERTY(QString stringVal READ stringVal WRITE setStringVal NOTIFY valChanged)

public:
    explicit ScalarParam(QObject *parent = 0);
    virtual ~ScalarParam() = default;

    double floatVal() const;
    void setFloatVal(double);

    QString stringVal() const;
    void setStringVal(QString);

    virtual QVariant getSerializableValue(bool *allInRange = nullptr, bool *anyInRange = nullptr) override;
    virtual bool setSerializableValue(const QVariant &val) override;
    virtual QVariant getSerializableRawValue(bool *allInRange = nullptr, bool *anyInRange = nullptr) override;
    virtual bool setSerializableRawValue(const QVariant &val) override;

    virtual quint32 minSize() override;
    virtual quint32 maxSize() override;
    virtual quint32 size() override;
signals:
    void valChanged();

public slots:
    void onParamSlotChanged();
    void onSlotValueParamChanged();

private:
    virtual void updateEngrFromRaw(quint32 begin, quint32 end) override;
    QVariant rawVal() const;
    bool setRawVal(const QVariant & val);
    Slot * mConnectedSlot;
};

} // namespace SetupTools

#endif // SETUPTOOLS_SCALARPARAM_H
