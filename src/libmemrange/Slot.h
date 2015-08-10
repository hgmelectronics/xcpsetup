#ifndef SETUPTOOLS_SLOT_H
#define SETUPTOOLS_SLOT_H

#include <QObject>
#include <QVariant>

namespace SetupTools {

class Slot
{
    Q_GADGET

    Q_PROPERTY(QString unit MEMBER unit)            //!< Unit name if any, e.g. "mph"
    Q_PROPERTY(int base MEMBER base)                //!< Base to print - if != 10 then precision is ignored
    Q_PROPERTY(int precision MEMBER precision)      //!< Number of digits to print after decimal point when rendering to a string
    Q_PROPERTY(int storageType MEMBER storageType)  //!< Qt metatype code for the QVariant format for raw storage, e.g. QMetaType::UInt or QMetaType::Float
public:
    Slot();

    Q_INVOKABLE virtual double toFloat(QVariant raw) = 0;
    Q_INVOKABLE virtual QString toString(QVariant raw) = 0;
    Q_INVOKABLE virtual QVariant toRaw(QVariant engr) = 0;

    QString unit;
    int base;
    int precision;
    int storageType;
};

} // namespace SetupTools

#endif // SETUPTOOLS_SLOT_H
