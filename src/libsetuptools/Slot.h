#ifndef SETUPTOOLS_SLOT_H
#define SETUPTOOLS_SLOT_H

#include <QObject>
#include <QVariant>
#include <QValidator>

namespace SetupTools {

class Slot : public QObject
{
    Q_OBJECT

    Q_PROPERTY(QString unit READ unit WRITE setUnit NOTIFY unitChanged)                         //!< Unit name if any, e.g. "mph"
    Q_PROPERTY(int base READ base WRITE setBase NOTIFY valueParamChanged)                       //!< Base to print - if != 10 then precision is ignored
    Q_PROPERTY(int precision READ precision WRITE setPrecision NOTIFY valueParamChanged)        //!< Number of digits to print after decimal point when rendering to a string
    Q_PROPERTY(int storageType READ storageType WRITE setStorageType NOTIFY valueParamChanged)  //!< Qt metatype code for the QVariant format for raw storage, e.g. QMetaType::UInt or QMetaType::Float
    Q_PROPERTY(QVariant rawMin READ rawMin NOTIFY valueParamChanged)
    Q_PROPERTY(QVariant rawMax READ rawMax NOTIFY valueParamChanged)
    Q_PROPERTY(QVariant engrMin READ engrMin NOTIFY valueParamChanged)
    Q_PROPERTY(QVariant engrMax READ engrMax NOTIFY valueParamChanged)
    Q_PROPERTY(QValidator *validator READ validator NOTIFY valueParamChanged)
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

    Q_INVOKABLE virtual double asFloat(QVariant raw) const = 0;
    Q_INVOKABLE virtual QString asString(QVariant raw) const = 0;
    Q_INVOKABLE virtual QVariant asRaw(QVariant engr) const = 0;
    Q_INVOKABLE virtual QVariant stringRoundtrip(QVariant engr);
    Q_INVOKABLE virtual bool rawInRange(QVariant engr) const = 0;
    Q_INVOKABLE virtual bool engrInRange(QVariant engr) const = 0;
    virtual QVariant rawMin() const;
    virtual QVariant rawMax() const;
    virtual QVariant engrMin() const;
    virtual QVariant engrMax() const;
    virtual QValidator *validator();
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
