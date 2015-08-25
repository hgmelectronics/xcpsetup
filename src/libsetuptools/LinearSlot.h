#ifndef SETUPTOOLSLINEARSLOT_H
#define SETUPTOOLSLINEARSLOT_H

#include <QObject>
#include <Slot.h>

namespace SetupTools {

class LinearSlot : public Slot
{
    Q_OBJECT

    Q_PROPERTY(double engrA READ engrA WRITE setEngrA NOTIFY linearValueParamChanged)       //!< Engineering value corresponding to point A
    Q_PROPERTY(double engrB READ engrB WRITE setEngrB NOTIFY linearValueParamChanged)       //!< Engineering value corresponding to point B
    Q_PROPERTY(double oorEngr READ oorEngr WRITE setOorEngr NOTIFY linearValueParamChanged) //!< Engineering value returned when raw value is not between A and B, or of the wrong type
    Q_PROPERTY(double rawA READ rawA WRITE setRawA NOTIFY linearValueParamChanged)          //!< Raw value corresponding to point A
    Q_PROPERTY(double rawB READ rawB WRITE setRawB NOTIFY linearValueParamChanged)          //!< Raw value corresponding to point B
    Q_PROPERTY(double oorRaw READ oorRaw WRITE setOorRaw NOTIFY linearValueParamChanged)    //!< Raw value returned when engineering value is not between A and B, or not convertible to a number
public:
    LinearSlot(QObject *parent = nullptr);

    double engrA() const;
    void setEngrA(double newVal);
    double engrB() const;
    void setEngrB(double newVal);
    double oorEngr() const;
    void setOorEngr(double newVal);
    double rawA() const;
    void setRawA(double newVal);
    double rawB() const;
    void setRawB(double newVal);
    double oorRaw() const;
    void setOorRaw(double newVal);

    Q_INVOKABLE virtual double toFloat(QVariant raw) const;
    Q_INVOKABLE virtual QString toString(QVariant raw) const;
    Q_INVOKABLE virtual QVariant toRaw(QVariant engr) const;
    Q_INVOKABLE virtual bool engrInRange(QVariant engr) const;
signals:
    void linearValueParamChanged();
private:
    double mEngrA;
    double mEngrB;
    double mOorEngr;
    double mRawA;
    double mRawB;
    double mOorRaw;
};

} // namespace SetupTools

#endif // SETUPTOOLSLINEARSLOT_H
