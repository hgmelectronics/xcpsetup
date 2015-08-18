#ifndef SETUPTOOLS_SLOT_H
#define SETUPTOOLS_SLOT_H

#include <QObject>
#include <QVariant>

namespace SetupTools {

class Slot : public QObject
{
    Q_OBJECT

    Q_PROPERTY(QString unit READ unit WRITE setUnit NOTIFY unitChanged)                         //!< Unit name if any, e.g. "mph"
    Q_PROPERTY(int base READ base WRITE setBase NOTIFY valueParamChanged)                       //!< Base to print - if != 10 then precision is ignored
    Q_PROPERTY(int precision READ precision WRITE setPrecision NOTIFY valueParamChanged)        //!< Number of digits to print after decimal point when rendering to a string
    Q_PROPERTY(int storageType READ storageType WRITE setStorageType NOTIFY valueParamChanged)  //!< Qt metatype code for the QVariant format for raw storage, e.g. QMetaType::UInt or QMetaType::Float
public:
    Slot(QObject *parent = nullptr);

    QString unit() const;
    void setUnit(QString);
    int base() const;
    void setBase(int);
    int precision() const;
    void setPrecision(int);
    int storageType() const;
    void setStorageType(int);

    Q_INVOKABLE virtual double toFloat(QVariant raw) const = 0;
    Q_INVOKABLE virtual QString toString(QVariant raw) const = 0;
    Q_INVOKABLE virtual QVariant toRaw(QVariant engr) const = 0;
    Q_INVOKABLE virtual bool engrInRange(QVariant engr) const = 0;
signals:
    void unitChanged();
    void valueParamChanged();
private:
    QString mUnit;
    int mBase;
    int mPrecision;
    int mStorageType;
};

} // namespace SetupTools

#endif // SETUPTOOLS_SLOT_H
