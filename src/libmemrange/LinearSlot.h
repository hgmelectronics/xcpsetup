#ifndef SETUPTOOLSLINEARSLOT_H
#define SETUPTOOLSLINEARSLOT_H

#include <QObject>
#include <Slot.h>

namespace SetupTools {

class LinearSlot : public Slot
{
    Q_GADGET

    Q_PROPERTY(double engrA MEMBER engrA)       //!< Engineering value corresponding to point A
    Q_PROPERTY(double engrB MEMBER engrB)       //!< Engineering value corresponding to point B
    Q_PROPERTY(double oorEngr MEMBER oorEngr)   //!< Engineering value returned when raw value is not between A and B, or of the wrong type
    Q_PROPERTY(double rawA MEMBER rawA)         //!< Raw value corresponding to point A
    Q_PROPERTY(double rawB MEMBER rawB)         //!< Raw value corresponding to point B
    Q_PROPERTY(double oorRaw MEMBER oorRaw)     //!< Raw value returned when engineering value is not between A and B, or not convertible to a number
public:
    LinearSlot();

    Q_INVOKABLE virtual double toFloat(QVariant raw) const;
    Q_INVOKABLE virtual QString toString(QVariant raw) const;
    Q_INVOKABLE virtual QVariant toRaw(QVariant engr) const;

    double engrA;
    double engrB;
    double oorEngr;
    double rawA;
    double rawB;
    double oorRaw;
};

} // namespace SetupTools

#endif // SETUPTOOLSLINEARSLOT_H
